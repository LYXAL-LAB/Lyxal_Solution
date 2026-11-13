//! Base embarquée avec `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` et
//! `lyxal_secrets` installés comme le fait l'hôte ; clés maîtresses éphémères tirées par les
//! tests ; jetons de session signés par une méthode d'accès de test (comme le banc SurrealQL).

use lyxal_crypto::hmac::sign_hmac_sha256;
use lyxal_crypto::{EncryptionKey, HmacKey, KeyId, ResolvedKey, SecretBytes};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_secrets::models::{AuditItem, AuditListParams, SecretCreateParams, Stage};
use lyxal_secrets::{MasterKeys, PutValue, RevealRequest, SecretsService, SecretsStore};
use lyxal_surreal::ToSql;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const NS: &str = "secrets";
pub const DB: &str = "test";
/// Méthode d'accès de test : jetons HS256 signés par les tests (clé de test, jamais une vraie
/// clé).
const ACCESS: &str = "lyxal_test";
const ACCESS_KEY: &str = "0123456789abcdef0123456789abcdef";

pub const ALPHA: &str = "auth_organization:alpha";
pub const BETA: &str = "auth_organization:beta";

pub async fn installed_client() -> Surreal<Any> {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client.use_ns(NS).use_db(DB).await.expect("ns/db");
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
    for name in ["lyxal_event", "lyxal_auth", "lyxal_secrets"] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    client
        .query(format!(
            "DEFINE ACCESS {ACCESS} ON DATABASE TYPE RECORD WITH JWT ALGORITHM HS256 KEY '{ACCESS_KEY}';"
        ))
        .await
        .and_then(|r| r.check())
        .expect("méthode d'accès de test");
    client
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

/// Clé maîtresse éphémère.
pub fn master_key(id: &str) -> ResolvedKey {
    ResolvedKey::new(
        KeyId::parse(id).expect("identifiant"),
        Arc::new(EncryptionKey::generate().expect("clé")),
    )
}

/// Banc : base installée, deux organisations, service de la session système.
pub struct Bench {
    pub client: Surreal<Any>,
    pub store: SecretsStore,
    pub master: MasterKeys,
    pub service: SecretsService,
}

pub async fn bench() -> Bench {
    let client = installed_client().await;
    let master = MasterKeys::from_keys(master_key("vault-1"), None).expect("trousseau maître");
    client
        .query(
            "CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };
             CREATE auth_organization:beta CONTENT { slug: 'beta', name: 'Beta Bois' };",
        )
        .await
        .and_then(|r| r.check())
        .expect("organisations");
    let store = SecretsStore::new(client.clone());
    Bench {
        service: SecretsService::new(store.clone(), store.clone(), Some(master.clone())),
        client,
        store,
        master,
    }
}

impl Bench {
    /// Service de la session système avec un autre trousseau maître.
    pub fn service_with(&self, master: Option<MasterKeys>) -> SecretsService {
        SecretsService::new(self.store.clone(), self.store.clone(), master)
    }

    /// Fiche créée ; rend son identifiant `secrets_secret:<clé>`.
    pub async fn secret(&self, tenant: Option<&str>, path: &str) -> String {
        self.secret_with(SecretCreateParams::new(
            tenant.map(str::to_string),
            path,
            "api_key",
        ))
        .await
    }

    pub async fn secret_with(&self, params: SecretCreateParams) -> String {
        self.store
            .secret_create(params)
            .await
            .expect("fiche")
            .id
            .to_sql()
    }

    /// Valeur écrite par la session système ; rend le numéro de version.
    pub async fn put(&self, secret: &str, value: &[u8]) -> i64 {
        self.service
            .put(put(secret, value))
            .await
            .expect("écriture")
            .version
            .number
    }

    /// Valeur relue par la session système.
    pub async fn read(&self, secret: &str) -> Vec<u8> {
        self.service
            .reveal(reveal(secret))
            .await
            .expect("lecture")
            .value
            .expose_secret()
            .to_vec()
    }

    /// Requête de préparation ou de contrôle sous la session système.
    pub async fn run(&self, query: &str) {
        self.client
            .query(query.to_string())
            .await
            .expect("requête")
            .check()
            .expect("requête refusée");
    }

    /// Valeur d'une requête sous la session système.
    pub async fn value<T: lyxal_surreal::SurrealValue>(&self, query: &str) -> T {
        let mut response = self
            .client
            .query(query.to_string())
            .await
            .expect("requête");
        let value: Option<T> = response.take(0).expect("résultat");
        value.expect("valeur")
    }

    /// Entrées du journal d'une portée, les plus récentes d'abord.
    pub async fn journal(&self, tenant: Option<&str>) -> Vec<AuditItem> {
        self.store
            .audit_list(AuditListParams {
                tenant: tenant.map(str::to_string),
                ..AuditListParams::default()
            })
            .await
            .expect("journal")
            .items
    }

    /// Identité, membre d'une organisation, avec une session ; rend le client SurrealDB de cette
    /// session (jeton aux permissions données).
    pub async fn person(&self, name: &str, tenant: &str, permissions: &[&str]) -> Surreal<Any> {
        self.run(&format!(
            "CREATE auth_identity:{name} CONTENT {{ schema: auth_identity_schema:default_v1, traits: {{ email: '{name}@lyxal.test' }} }};
             RELATE auth_identity:{name}->auth_member_of->{tenant};
             CREATE auth_session:{name} CONTENT {{ identity: auth_identity:{name}, organization: {tenant}, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d }};"
        ))
        .await;
        self.session(name, permissions).await
    }

    /// Compte de service (application) d'une organisation, avec une session de programme.
    pub async fn program(&self, name: &str, tenant: &str, permissions: &[&str]) -> Surreal<Any> {
        self.run(&format!(
            "CREATE auth_application:{name} CONTENT {{ tenant: {tenant}, client_id: 'lyxal-test-{name}', name: '{name}', type: 'machine', redirect_uris: [], state: 'active', permissions_version: 1 }};
             CREATE auth_session:{name} CONTENT {{ application: auth_application:{name}, kind: 'service', organization: {tenant}, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d }};"
        ))
        .await;
        self.session(name, permissions).await
    }

    async fn session(&self, name: &str, permissions: &[&str]) -> Surreal<Any> {
        let user = self.client.clone();
        user.authenticate(token(&format!("auth_session:{name}"), permissions))
            .await
            .expect("jeton de test accepté");
        user
    }

    /// Service d'une session de personne ou de programme (avec la session système de l'hôte).
    pub fn service_for(&self, user: &Surreal<Any>) -> SecretsService {
        SecretsService::new(
            SecretsStore::new(user.clone()),
            self.store.clone(),
            Some(self.master.clone()),
        )
    }
}

pub fn put(secret: &str, value: &[u8]) -> PutValue {
    PutValue {
        secret: secret.to_string(),
        value: SecretBytes::new(value.to_vec()).expect("valeur"),
        expected_version: None,
        stage: Stage::Current,
    }
}

pub fn reveal(secret: &str) -> RevealRequest {
    RevealRequest {
        secret: secret.to_string(),
        label: None,
        number: None,
    }
}

/// Jeton HS256 de la méthode d'accès de test pour une session `lyxal_auth`.
fn token(session: &str, permissions: &[&str]) -> String {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("horloge")
        .as_secs();
    let header = serde_json::json!({ "alg": "HS256", "typ": "JWT" });
    let payload = serde_json::json!({
        "ns": NS, "db": DB, "ac": ACCESS,
        "iat": now, "nbf": now, "exp": now + 900,
        "jti": format!("{session}-{now}"),
        "id": session, "pv": 1, "permissions": permissions,
    });
    let signing_input = format!(
        "{}.{}",
        base64url(header.to_string().as_bytes()),
        base64url(payload.to_string().as_bytes())
    );
    let key = HmacKey::import(SecretBytes::new(ACCESS_KEY.as_bytes().to_vec()).expect("clé"))
        .expect("clé HMAC");
    let signature = sign_hmac_sha256(&key, signing_input.as_bytes()).expect("signature");
    format!("{signing_input}.{}", base64url(&signature))
}

/// Base64 URL sans remplissage (RFC 4648 §5).
fn base64url(bytes: &[u8]) -> String {
    const ALPHABET: &[u8; 64] =
        b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    let mut out = String::new();
    for chunk in bytes.chunks(3) {
        let b = [
            chunk[0],
            chunk.get(1).copied().unwrap_or(0),
            chunk.get(2).copied().unwrap_or(0),
        ];
        let n = (u32::from(b[0]) << 16) | (u32::from(b[1]) << 8) | u32::from(b[2]);
        for i in 0..=chunk.len() {
            out.push(ALPHABET[((n >> (18 - 6 * i)) & 63) as usize] as char);
        }
    }
    out
}

/// Code d'une erreur attendue.
pub fn code<T: std::fmt::Debug>(result: Result<T, lyxal_secrets::SecretsError>) -> String {
    result.expect_err("refus attendu").code()
}
