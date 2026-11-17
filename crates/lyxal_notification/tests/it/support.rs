//! Base embarquée avec `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`, `lyxal_i18n`,
//! `lyxal_scheduler`, `lyxal_secrets` et `lyxal_notification` installés comme le fait l'hôte ;
//! trousseau de clés éphémère ; coffre-fort à clé maîtresse éphémère ; relais SMTP de test comme
//! intégration de l'installation.

use lyxal_crypto::{
    CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, ResolvedKey, SecretBytes,
    StaticKeyResolver,
};
use lyxal_notification::models::{ClaimedIntegration, IntegrationSaveParams, IntegrationSettings};
use lyxal_notification::{EmailDispatcher, EmailProviders, NotificationStore, SECRETS_CONSUMER};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_secrets::models::{SecretCreateParams, Stage};
use lyxal_secrets::{ClientWrite, MasterKeys, SecretsClient, SecretsStore};
use std::path::PathBuf;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub async fn installed_client() -> Surreal<Any> {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client
        .use_ns("notification")
        .use_db("test")
        .await
        .expect("ns/db");
    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    let load = |name: &str| {
        let dir = crates.join(name);
        (
            ManifestParser::parse_file(dir.join("manifest.toml")).expect("manifeste"),
            DirResourceProvider(dir),
        )
    };
    let foundation = [load("lyxal_core"), load("lyxal_error")];
    let batch: Vec<(&ModuleManifest, &dyn ResourceProvider)> = foundation
        .iter()
        .map(|(m, p)| (m, p as &dyn ResourceProvider))
        .collect();
    lyxal_runtime::schema::install_batch(&client, &batch)
        .await
        .expect("noyau");
    lyxal_runtime::schema::install_runtime_schema(&client)
        .await
        .expect("schéma du runtime");
    for name in [
        "lyxal_event",
        "lyxal_auth",
        "lyxal_i18n",
        "lyxal_scheduler",
        "lyxal_secrets",
        "lyxal_notification",
    ] {
        // Release en cours d'installation, comme le runtime : le seed du module déclare ses
        // tâches du planificateur (la garde de scheduler_task l'exige)
        client
            .query("fn::runtime_module_upsert({ module_id: $id, name: $id }); fn::runtime_release_register({ module_id: $id, version: '0.1.0', manifest_version: 1, status: 'Installing' });")
            .bind(("id", name.to_string()))
            .await
            .and_then(|r| r.check())
            .unwrap_or_else(|e| panic!("release de {name} : {e}"));
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    client
}

pub fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("notification-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))))
}

/// Coffre-fort de la base (clé maîtresse éphémère) : client de `lyxal_notification`, comme celui
/// de l'hôte.
pub fn vault(client: &Surreal<Any>) -> SecretsClient {
    let master = MasterKeys::from_keys(
        ResolvedKey::new(
            KeyId::parse("vault-test").expect("identifiant"),
            Arc::new(EncryptionKey::generate().expect("clé")),
        ),
        None,
    )
    .expect("trousseau maître");
    SecretsClient::new(
        SecretsStore::new(client.clone()),
        Some(master),
        SECRETS_CONSUMER,
    )
}

/// Secret `path` de la portée `tenant` (`auth_organization:<clé>`), créé par la session système
/// avec la valeur `value` (JSON).
pub async fn put_secret(
    client: &Surreal<Any>,
    vault: &SecretsClient,
    tenant: Option<&str>,
    path: &str,
    value: &str,
) {
    SecretsStore::new(client.clone())
        .secret_create(SecretCreateParams::new(
            tenant.map(str::to_string),
            path,
            "api_key",
        ))
        .await
        .expect("fiche du secret");
    vault
        .write(ClientWrite {
            tenant: tenant.map(str::to_string),
            path: path.to_string(),
            value: SecretBytes::new(value.as_bytes().to_vec()).expect("valeur"),
            stage: Stage::Current,
        })
        .await
        .expect("valeur du secret");
}

/// Intégration créée par la session système (`fn::notification_integration_create`).
pub async fn integration(
    client: &Surreal<Any>,
    params: IntegrationSaveParams,
) -> lyxal_notification::models::Integration {
    NotificationStore::new(client.clone())
        .integration_create(params)
        .await
        .expect("intégration")
}

/// Relais SMTP de test (boucle locale, sans authentification) comme intégration principale de
/// l'installation, son secret `{}` dans le coffre-fort.
pub async fn smtp_relay(client: &Surreal<Any>, vault: &SecretsClient, port: u16) {
    put_secret(client, vault, None, "notification/smtp/relais", "{}").await;
    integration(
        client,
        IntegrationSaveParams {
            key: "relais".into(),
            provider: Some("smtp".into()),
            name: Some("Relais de test".into()),
            primary: Some(true),
            settings: Some(IntegrationSettings {
                from_address: "noreply@lyxal.test".into(),
                from_name: Some("Lyxal".into()),
                host: Some("127.0.0.1".into()),
                port: Some(i64::from(port)),
                security: Some("local_plain".into()),
                ..IntegrationSettings::default()
            }),
            credentials_path: Some("notification/smtp/relais".into()),
            ..IntegrationSaveParams::default()
        },
    )
    .await;
}

/// Envoi par les intégrations : faux fournisseurs HTTP sous `base` (ou les vrais si absent).
pub fn dispatcher(vault: &SecretsClient, base: Option<&str>) -> EmailDispatcher {
    let providers = match base {
        Some(base) => EmailProviders::for_local_tests(base).expect("faux fournisseurs"),
        None => EmailProviders::new().expect("fournisseurs"),
    };
    EmailDispatcher::new(Arc::new(providers), vault.clone())
}

/// Intégration d'une étape telle que la réserve le worker.
pub async fn claimed(client: &Surreal<Any>, key: &str) -> ClaimedIntegration {
    let mut response = client
        .query("RETURN fn::notification_integration_payload((SELECT * FROM ONLY notification_integration WHERE key = $key LIMIT 1))")
        .bind(("key", key.to_string()))
        .await
        .expect("intégration");
    let integration: Option<ClaimedIntegration> = response.take(0).expect("intégration lue");
    integration.expect("intégration présente")
}

/// Lecteur de test : ressource lue sous le dossier source d'un module.
pub struct DirResourceProvider(PathBuf);

#[async_trait::async_trait]
impl ResourceProvider for DirResourceProvider {
    async fn read(&self, logical_path: &str) -> Result<String, lyxal_runtime::RuntimeError> {
        std::fs::read_to_string(self.0.join(logical_path)).map_err(|_| {
            lyxal_runtime::RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            }
        })
    }
}
