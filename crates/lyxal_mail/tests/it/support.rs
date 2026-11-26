// SPDX-License-Identifier: AGPL-3.0-only

//! Base embarquée avec le socle, `lyxal_event`, `lyxal_auth`, `lyxal_secrets`, `lyxal_storage`
//! et `lyxal_mail` installés comme le fait l'hôte ; clé maîtresse éphémère, support disque ;
//! jetons de session signés par une méthode d'accès de test (comme le banc SurrealQL).

use lyxal_crypto::hmac::sign_hmac_sha256;
use lyxal_crypto::{EncryptionKey, HmacKey, KeyId, ResolvedKey, SecretBytes};
use lyxal_mail::models::{AccountCreateParams, DomainCreateParams, MailboxListParams};
use lyxal_mail::{MailContent, MailIngest, MailMaintenance, MailStore};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_secrets::{FileKeys, MasterKeys, SecretsStore};
use lyxal_storage::models::ObjectGetParams;
use lyxal_storage::{BackendConfig, Backends, StorageService, StorageStore};
use lyxal_surreal::{RootCredentials, SecretString, SurrealConnectOptions, SurrealPool, ToSql};
use std::num::NonZeroUsize;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const NS: &str = "mail";
pub const DB: &str = "test";
/// Méthode d'accès de test : jetons HS256 signés par les tests (clé de test, jamais une vraie
/// clé).
const ACCESS: &str = "lyxal_test";
const ACCESS_KEY: &str = "0123456789abcdef0123456789abcdef";
/// Empreinte d'un défi de vérification de domaine (valeur d'essai).
const CHALLENGE: &str = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";

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

/// Base embarquée en mémoire (`mem://`), ns et base des essais choisis.
pub async fn embedded() -> Surreal<Any> {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client.use_ns(NS).use_db(DB).await.expect("ns/db");
    client
}

/// Base d'un serveur SurrealDB 3.3.4 réel pour les mesures, si `LYXAL_SURREAL_WS_URL`
/// (`ws://hôte:port`), `LYXAL_SURREAL_USER` et `LYXAL_SURREAL_PASS` (compte racine du serveur
/// d'essai) sont posés ; une base neuve par appel. Sinon `None`. Rend le pool de connexions de
/// la session système, comme celui d'un hôte (`[database] connections`) : une connexion, ou
/// `LYXAL_SURREAL_CONNECTIONS=<nombre>` connexions (un serveur SurrealDB ne répartit pas sur
/// ses cœurs les requêtes d'une même connexion).
pub async fn remote() -> Option<(SurrealPool, String)> {
    let url = std::env::var("LYXAL_SURREAL_WS_URL").ok()?;
    let username = std::env::var("LYXAL_SURREAL_USER").expect("LYXAL_SURREAL_USER");
    let password = std::env::var("LYXAL_SURREAL_PASS").expect("LYXAL_SURREAL_PASS");
    let connections = match std::env::var("LYXAL_SURREAL_CONNECTIONS") {
        Ok(text) => text
            .parse::<NonZeroUsize>()
            .expect("LYXAL_SURREAL_CONNECTIONS : nombre de connexions, 1 au moins"),
        Err(_) => NonZeroUsize::MIN,
    };
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("horloge")
        .as_nanos();
    let pool = SurrealPool::connect(
        &SurrealConnectOptions {
            endpoint: url,
            credentials: Some(RootCredentials::new(
                username,
                SecretString::new(password).expect("mot de passe"),
            )),
            namespace: NS.to_string(),
            database: format!("mesures_{nanos}"),
            connect_timeout: Duration::from_secs(15),
        },
        connections,
    )
    .await
    .expect("connexions ws://");
    let engine = format!(
        "serveur SurrealDB (ws://), pool de {} connexion(s)",
        pool.size()
    );
    Some((pool, engine))
}

pub async fn installed_client() -> Surreal<Any> {
    install(embedded().await).await
}

/// Installe le socle et les modules dans la base du client, comme le fait l'hôte.
pub async fn install(client: Surreal<Any>) -> Surreal<Any> {
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
    for name in [
        "lyxal_event",
        "lyxal_auth",
        "lyxal_secrets",
        "lyxal_storage",
        "lyxal_mail",
    ] {
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

/// Clé maîtresse éphémère du coffre-fort.
pub fn master() -> MasterKeys {
    MasterKeys::from_keys(
        ResolvedKey::new(
            KeyId::parse("vault-1").expect("identifiant"),
            Arc::new(EncryptionKey::generate().expect("clé")),
        ),
        None,
    )
    .expect("trousseau")
}

/// Banc : base installée, organisations alpha et beta, domaines, comptes de jean et marie
/// (alpha) et d'autre (beta), services du courrier sur la session système.
pub struct Bench {
    /// Connexion fixe de la session système (préparation, contrôles, sessions des personnes).
    pub client: Surreal<Any>,
    pub system: MailStore,
    pub storage_store: StorageStore,
    pub backends: Arc<Backends>,
    /// Stockage de l'hôte (session système, clés de fichiers).
    pub storage: StorageService,
    /// Clés « fichiers » du coffre-fort (mesures).
    pub file_keys: FileKeys,
    pub ingest: MailIngest,
    pub content: MailContent,
    pub maintenance: MailMaintenance,
    /// Dossier du support disque `default`.
    pub root: tempfile::TempDir,
}

/// Compte de courrier d'une personne et ses dossiers.
pub struct Person {
    /// Session de la personne.
    pub store: MailStore,
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// Boîte de réception.
    pub inbox: String,
    /// Dossier d'archives.
    pub archive: String,
}

pub async fn bench() -> Bench {
    bench_on(installed_client().await).await
}

/// Banc des mesures : sur le serveur SurrealDB désigné par `LYXAL_SURREAL_WS_URL` s'il est posé,
/// sinon sur la base embarquée. Rend aussi le nom du moteur mesuré.
pub async fn measure_bench() -> (Bench, String) {
    match remote().await {
        Some((pool, engine)) => {
            install(pool.fixed().clone()).await;
            (bench_with(pool).await, engine)
        }
        None => (bench().await, "base embarquée (mem://)".to_string()),
    }
}

/// Banc sur une base installée, tous les services sur la même connexion.
pub async fn bench_on(client: Surreal<Any>) -> Bench {
    bench_with(SurrealPool::from(client)).await
}

/// Banc sur une base installée : les stores du courrier, du stockage et du coffre-fort
/// reçoivent le pool de la session système, comme dans l'hôte.
pub async fn bench_with(database: SurrealPool) -> Bench {
    let client = database.fixed().clone();
    let master = master();
    let root = tempfile::tempdir().expect("dossier temporaire");
    let backends = Arc::new(
        Backends::new()
            .with(
                "default",
                BackendConfig::Disk {
                    root: root.path().to_path_buf(),
                },
            )
            .expect("support"),
    );
    let storage_store = StorageStore::new(database.clone());
    let file_keys = FileKeys::new(SecretsStore::new(database.clone()), Some(master.clone()));
    let storage = StorageService::new(storage_store.clone(), backends.clone())
        .with_file_keys(file_keys.clone(), storage_store.clone());
    let system = MailStore::new(database);
    let bench = Bench {
        ingest: MailIngest::new(system.clone(), storage.clone(), "default"),
        content: MailContent::new(storage.clone()),
        maintenance: MailMaintenance::new(system.clone(), 100),
        storage,
        file_keys,
        client,
        system,
        storage_store,
        backends,
        root,
    };
    bench
        .run(&format!(
            "CREATE auth_organization:alpha CONTENT {{ slug: 'alpha', name: 'Alpha BTP' }};
             CREATE auth_organization:beta CONTENT {{ slug: 'beta', name: 'Beta Bois' }};
             CREATE auth_organization_domain:alpha CONTENT {{ organization: auth_organization:alpha, domain: 'alpha.test', state: 'verified', challenge_hash: '{CHALLENGE}' }};
             CREATE auth_organization_domain:beta CONTENT {{ organization: auth_organization:beta, domain: 'beta.test', state: 'verified', challenge_hash: '{CHALLENGE}' }};"
        ))
        .await;
    bench
}

impl Bench {
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
        let mut response = self.client.query(query.to_string()).await.expect("requête");
        let value: Option<T> = response.take(0).expect("résultat");
        value.expect("valeur")
    }

    /// Valeurs d'une requête (liste) sous la session système.
    pub async fn values<T: lyxal_surreal::SurrealValue>(&self, query: &str) -> Vec<T> {
        let mut response = self.client.query(query.to_string()).await.expect("requête");
        response.take(0).expect("résultats")
    }

    /// Domaine de courrier d'une organisation (`alpha` ou `beta`), créé par la session système.
    pub async fn domain(&self, organization: &str) -> String {
        self.system
            .domain_create(DomainCreateParams {
                auth_domain: format!("auth_organization_domain:{organization}"),
                subaddress_separator: None,
            })
            .await
            .expect("domaine")
            .id
            .to_sql()
    }

    /// Identité membre de l'organisation, avec une session (permission `mail.mailbox.access`)
    /// et un compte de courrier sur le domaine `domain` ; rend sa session et ses dossiers.
    pub async fn person(&self, name: &str, organization: &str, domain: &str) -> Person {
        self.run(&format!(
            "CREATE auth_identity:{name} CONTENT {{ schema: auth_identity_schema:default_v1, traits: {{ email: '{name}@lyxal.test' }} }};
             RELATE auth_identity:{name}->auth_member_of->auth_organization:{organization};
             CREATE auth_session:{name} CONTENT {{ identity: auth_identity:{name}, organization: auth_organization:{organization}, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d }};"
        ))
        .await;
        let account = self
            .system
            .account_create(AccountCreateParams {
                identity: format!("auth_identity:{name}"),
                domain: domain.to_string(),
                local_part: name.to_string(),
                quota_bytes: None,
            })
            .await
            .expect("compte")
            .account
            .id
            .to_sql();
        let user = self.client.clone();
        user.authenticate(token(
            &format!("auth_session:{name}"),
            &["mail.mailbox.access"],
        ))
        .await
        .expect("jeton de test accepté");
        let store = MailStore::new(user);
        let boxes = store
            .mailbox_list(MailboxListParams::default())
            .await
            .expect("dossiers");
        let role = |role: &str| {
            boxes
                .iter()
                .find(|mailbox| mailbox.role.as_deref() == Some(role))
                .map(|mailbox| mailbox.id.to_sql())
                .expect("dossier")
        };
        Person {
            inbox: role("inbox"),
            archive: role("archive"),
            account,
            store,
        }
    }

    /// Octets rangés sur le support disque pour un fichier (`storage_object:<clé>`), sans
    /// déchiffrement.
    pub async fn stored_bytes(&self, object: &str) -> Vec<u8> {
        let stored = self
            .storage_store
            .object_get(ObjectGetParams::by_id(object))
            .await
            .expect("fiche");
        std::fs::read(self.root.path().join(&stored.path)).expect("octets rangés")
    }
}

/// Jeton HS256 de la méthode d'accès de test pour une session `lyxal_auth`.
pub fn token(session: &str, permissions: &[&str]) -> String {
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
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
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
pub fn code<T>(result: Result<T, lyxal_mail::MailError>) -> String {
    match result {
        Ok(_) => panic!("refus attendu"),
        Err(error) => error.code(),
    }
}
