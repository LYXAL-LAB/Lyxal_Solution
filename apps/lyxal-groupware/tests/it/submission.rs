// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt authentifié dans l'hôte (lot 6e) sur de vraies sockets : écoute `submission` du port
//! 587 (STARTTLS exigé) et du port 465 (TLS implicite), client TLS de `lyxal_crypto` (mode
//! opportuniste : certificat d'essai) par `tokio-rustls` ; mots de passe d'application de
//! `lyxal_auth` créés comme par `lyxal-server` (même clé applicative), vérifiés par l'hôte.
//!
//! Cas : `AUTH` et `MAIL` refusés avant TLS, mauvais mot de passe (`535`), mot de passe sans
//! `mail.send` (`535`), trois échecs (`421`), usurpation de `MAIL FROM` et de `From`
//! (`550 5.7.1`), destinataire inconnu d'un domaine de l'installation (`550 5.1.1`), envoi
//! accepté et inscrit dans la file (envoi `queued`, fichier chiffré écrit : `Bcc` retiré,
//! `Message-ID` et `Date` ajoutés, `Received` sans adresse IP), limite de destinataires de
//! l'organisation, panne de la base (`451`, rien en file) ; démarrage refusé sans clé applicative.

use crate::mail_service::{test_master_key, MASTER_KEY_VAR};
use crate::support::{toml, TestCertificates};
use base64::Engine as _;
use futures::StreamExt;
use lyxal_auth::models::SessionCaller;
use lyxal_auth::{AppPasswordService, AuthStore, SigningKeyService};
use lyxal_crypto::{tls_client_config, TlsClientOptions, TlsServerVerification};
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::runtime::Started;
use lyxal_mail::models::{AccountCreateParams, DomainCreateParams};
use lyxal_secrets::{FileKeys, SecretsStore};
use lyxal_storage::models::ObjectGetParams;
use lyxal_storage::{StorageService, StorageStore};
use lyxal_surreal::{RecordId, ToSql};
use std::fs;
use std::net::SocketAddr;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::io::{AsyncBufReadExt, AsyncRead, AsyncWrite, AsyncWriteExt, BufReader};
use tokio::net::TcpStream;

/// Variable de la clé applicative lue par l'hôte (même valeur que celle de `lyxal-server`).
const APPLICATION_KEY_VAR: &str = "LYXAL_GROUPWARE__CRYPTO__APPLICATION_KEY";
/// Identifiant de connexion de jean (adresse de son identité).
const JEAN_LOGIN: &str = "jean@exemple.fr";

trait Stream: AsyncRead + AsyncWrite + Unpin + Send {}
impl<T: AsyncRead + AsyncWrite + Unpin + Send> Stream for T {}

/// Client SMTP d'essai, en clair puis chiffré.
struct Client {
    stream: BufReader<Box<dyn Stream>>,
}

impl Client {
    /// Connexion en clair (port 587) : accueil lu.
    async fn plain(address: SocketAddr) -> Self {
        let stream = TcpStream::connect(address).await.expect("connexion");
        let mut client = Self {
            stream: BufReader::new(Box::new(stream)),
        };
        assert!(client.reply().await.starts_with("220 mx.lyxal.test"));
        client
    }

    /// Connexion en TLS implicite (port 465) : accueil lu.
    async fn implicit(address: SocketAddr) -> Self {
        let stream = TcpStream::connect(address).await.expect("connexion");
        let mut client = Self {
            stream: BufReader::new(Box::new(tls(stream).await)),
        };
        assert!(client.reply().await.starts_with("220 mx.lyxal.test"));
        client
    }

    /// `STARTTLS` puis poignée de main.
    async fn start_tls(self) -> Self {
        let mut client = self;
        assert!(client.command("STARTTLS").await.starts_with("220 2.0.0"));
        let inner = client.stream.into_inner();
        Self {
            stream: BufReader::new(Box::new(tls(inner).await)),
        }
    }

    async fn send(&mut self, line: &str) {
        self.stream
            .get_mut()
            .write_all(format!("{line}\r\n").as_bytes())
            .await
            .expect("écriture");
        self.stream.get_mut().flush().await.expect("écriture");
    }

    /// Réponse entière (lignes jointes par `\n`).
    async fn reply(&mut self) -> String {
        let mut lines = Vec::new();
        loop {
            let mut line = String::new();
            let read = self.stream.read_line(&mut line).await.expect("lecture");
            assert!(read > 0, "connexion fermée après {lines:?}");
            let line = line.trim_end().to_string();
            let last = line.as_bytes().get(3) != Some(&b'-');
            lines.push(line);
            if last {
                return lines.join("\n");
            }
        }
    }

    async fn command(&mut self, line: &str) -> String {
        self.send(line).await;
        self.reply().await
    }

    /// `DATA`, le message, puis la réponse finale.
    async fn data(&mut self, message: &str) -> String {
        assert!(self.command("DATA").await.starts_with("354"));
        self.stream
            .get_mut()
            .write_all(format!("{message}.\r\n").as_bytes())
            .await
            .expect("données");
        self.reply().await
    }

    /// `AUTH PLAIN` avec réponse initiale.
    async fn auth_plain(&mut self, login: &str, password: &str) -> String {
        let initial =
            base64::engine::general_purpose::STANDARD.encode(format!("\0{login}\0{password}"));
        self.command(&format!("AUTH PLAIN {initial}")).await
    }

    /// `AUTH LOGIN` en trois échanges.
    async fn auth_login(&mut self, login: &str, password: &str) -> String {
        let encode = |text: &str| base64::engine::general_purpose::STANDARD.encode(text);
        assert_eq!(self.command("AUTH LOGIN").await, "334 VXNlcm5hbWU6");
        assert_eq!(self.command(&encode(login)).await, "334 UGFzc3dvcmQ6");
        self.command(&encode(password)).await
    }
}

/// Poignée de main TLS du client (configuration de `lyxal_crypto`, certificat d'essai accepté).
async fn tls(stream: impl Stream + 'static) -> impl Stream {
    let config = tls_client_config(&TlsClientOptions {
        verification: TlsServerVerification::Opportunistic,
        ..TlsClientOptions::default()
    })
    .expect("configuration TLS du client");
    let name =
        tokio_rustls::rustls::pki_types::ServerName::try_from("mail.example.test").expect("nom");
    tokio_rustls::TlsConnector::from(config)
        .connect(name, stream)
        .await
        .expect("poignée de main")
}

/// Configuration : support disque, clé maîtresse, clé applicative si `with_application_key`,
/// écoutes `submission` (587 en STARTTLS) et `submissions` (465 en TLS implicite).
fn config(
    database: &str,
    root: &std::path::Path,
    certificates: &TestCertificates,
    with_application_key: bool,
) -> GroupwareConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    let key = test_master_key();
    std::env::set_var(MASTER_KEY_VAR, &key);
    let mut variables = config::Map::new();
    variables.insert(MASTER_KEY_VAR.to_string(), key.clone());
    let mut extra = format!(
        "[storage.disk]\nroot = \"{}\"\n[secrets]\nmaster_key_id = \"vault-1\"\n",
        root.display().to_string().replace('\\', "/")
    );
    if with_application_key {
        // Clé d'essai : même valeur que la clé maîtresse d'essai (deux usages distincts ici)
        std::env::set_var(APPLICATION_KEY_VAR, &key);
        variables.insert(APPLICATION_KEY_VAR.to_string(), key);
        extra.push_str("[crypto]\napplication_key_id = \"app-1\"\n");
    }
    extra.push_str(&certificates.tls_section());
    extra.push_str(
        "\n[[listeners]]\nid = \"submission\"\nprotocol = \"submission\"\nbind = [\"127.0.0.1:0\"]\ntls = \"starttls\"\n\
         \n[[listeners]]\nid = \"submissions\"\nprotocol = \"submission\"\nbind = [\"127.0.0.1:0\"]\ntls = \"implicit\"\n",
    );
    fs::write(
        directory.path().join("default.toml"),
        toml(database, &extra),
    )
    .expect("default.toml");
    GroupwareConfig::load_with_environment(directory.path(), Some(variables))
        .expect("configuration valide")
}

async fn start(config: &GroupwareConfig, client: &Surreal<Any>) -> Started {
    let certificates =
        lyxal_groupware::net::certificates::Certificates::load(&config.tls).expect("certificats");
    lyxal_groupware::runtime::start(
        config,
        &client.clone().into(),
        lyxal_groupware::net::bind::bind_listeners(config).expect("liaison"),
        certificates,
    )
    .await
    .expect("démarrage")
}

async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .unwrap_or_else(|error| panic!("{query} : {error}"));
}

async fn value<T: lyxal_surreal::SurrealValue>(client: &Surreal<Any>, query: &str) -> T {
    let mut response = client.query(query).await.expect("requête");
    let value: Option<T> = response.take(0).expect("résultat");
    value.expect("valeur")
}

/// Mots de passe d'application de jean : avec et sans `mail.send`.
struct Passwords {
    send: String,
    read_only: String,
}

/// Organisation, domaine de courrier, identités jean et paul (membres : `mail.send` par le rôle
/// par défaut) avec leurs comptes ; clés de `lyxal_auth` créées et mots de passe d'application
/// de jean émis, comme par `lyxal-server` sur la même base.
async fn people(client: &Surreal<Any>, started: &Started, config: &GroupwareConfig) -> Passwords {
    run(
        client,
        "CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };
         CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: 'alpha.test', state: 'verified', challenge_hash: 'af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262' };
         fn::auth_identity_create({ traits: { email: 'jean@exemple.fr' }, organization: 'auth_organization:alpha' });
         fn::auth_identity_create({ traits: { email: 'paul@exemple.fr' }, organization: 'auth_organization:alpha' });
         LET $jean = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'jean@exemple.fr' LIMIT 1);
         CREATE auth_session:jean CONTENT { identity: $jean, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };",
    )
    .await;
    let system = &started.services.system;
    let domain = system
        .domain_create(DomainCreateParams {
            auth_domain: "auth_organization_domain:alpha".to_string(),
            subaddress_separator: None,
        })
        .await
        .expect("domaine")
        .id
        .to_sql();
    for name in ["jean", "paul"] {
        let identity: RecordId = value(
            client,
            &format!("SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = '{name}@exemple.fr' LIMIT 1"),
        )
        .await;
        system
            .account_create(AccountCreateParams {
                identity: identity.to_sql(),
                domain: domain.clone(),
                local_part: name.to_string(),
                quota_bytes: None,
            })
            .await
            .expect("compte");
    }
    let crypto = lyxal_host::services::application_crypto(&config.crypto, "LYXAL_GROUPWARE")
        .expect("clé applicative")
        .expect("clé applicative fournie");
    let store = AuthStore::new(client.clone());
    let keys = Arc::new(SigningKeyService::new(store.clone(), crypto));
    keys.ensure().await.expect("clés de lyxal_auth");
    let service = AppPasswordService::new(
        store,
        keys,
        config.database.namespace.clone(),
        config.database.database.clone(),
    );
    let identity: RecordId =
        value(client, "SELECT VALUE identity FROM ONLY auth_session:jean").await;
    let caller = SessionCaller {
        session: RecordId::parse_simple("auth_session:jean").expect("session"),
        identity: Some(identity),
        application: None,
        organization: Some(
            RecordId::parse_simple("auth_organization:alpha").expect("organisation"),
        ),
        kind: "interactive".into(),
    };
    let issue = |name: &'static str, permissions: Vec<String>| {
        let service = &service;
        let caller = &caller;
        async move {
            let issued = service
                .create(caller, name, permissions, None)
                .await
                .expect("mot de passe d'application");
            assert_eq!(issued.username, JEAN_LOGIN);
            issued.password.expose_secret().to_string()
        }
    };
    Passwords {
        send: issue(
            "Thunderbird",
            vec!["mail.send".into(), "mail.mailbox.access".into()],
        )
        .await,
        read_only: issue("Liseuse", vec!["mail.mailbox.access".into()]).await,
    }
}

/// Octets déchiffrés d'un fichier du stockage (support disque et clé maîtresse de l'hôte).
async fn stored(client: &Surreal<Any>, config: &GroupwareConfig, object: &str) -> String {
    let master = lyxal_host::services::master_keys(&config.secrets, "LYXAL_GROUPWARE")
        .expect("clé maîtresse")
        .expect("clé maîtresse fournie");
    let store = StorageStore::new(client.clone());
    let backends =
        Arc::new(lyxal_host::services::storage_backends(&config.storage).expect("supports"));
    let storage = StorageService::new(store.clone(), backends).with_file_keys(
        FileKeys::new(SecretsStore::new(client.clone()), Some(master)),
        store,
    );
    let mut opened = storage
        .open(ObjectGetParams::by_id(object), None)
        .await
        .expect("fichier");
    let mut bytes = Vec::new();
    while let Some(chunk) = opened.content.next().await {
        bytes.extend_from_slice(&chunk.expect("segment"));
    }
    String::from_utf8(bytes).expect("texte")
}

const MESSAGE: &str = "From: Jean <jean@alpha.test>\r\n\
To: Paul <x@ailleurs.test>\r\n\
Bcc: secret@ailleurs.test\r\n\
Subject: Devis du chantier\r\n\
\r\n\
Bonjour, voici le devis.\r\n";

#[tokio::test]
async fn people_submit_mail_on_ports_587_and_465() {
    let certificates = TestCertificates::new();
    let root = tempfile::tempdir().expect("support");
    let config = config("submission", root.path(), &certificates, true);
    let client = crate::support::database("submission").await;
    let started = start(&config, &client).await;
    let passwords = people(&client, &started, &config).await;
    let starttls = started.mail.local_addrs("submission")[0];
    let implicit = started.mail.local_addrs("submissions")[0];

    // Port 587 en clair : ni AUTH annoncé, ni AUTH ni MAIL acceptés avant STARTTLS
    let mut session = Client::plain(starttls).await;
    let ehlo = session.command("EHLO poste.alpha.test").await;
    assert!(
        ehlo.contains("STARTTLS") && !ehlo.contains("AUTH"),
        "{ehlo}"
    );
    assert!(session
        .auth_plain(JEAN_LOGIN, &passwords.send)
        .await
        .starts_with("530 5.7.0"));
    assert!(session
        .command("MAIL FROM:<jean@alpha.test>")
        .await
        .starts_with("530 5.7.0"));

    // STARTTLS : AUTH annoncé ; mauvais mot de passe, puis mot de passe sans mail.send : 535
    let mut session = session.start_tls().await;
    let ehlo = session.command("EHLO poste.alpha.test").await;
    assert!(
        ehlo.contains("AUTH PLAIN LOGIN") && ehlo.contains("DSN"),
        "{ehlo}"
    );
    assert!(!ehlo.contains("STARTTLS"), "{ehlo}");
    assert!(session
        .command("MAIL FROM:<jean@alpha.test>")
        .await
        .starts_with("530 5.7.0 Authentication required"));
    assert!(session
        .auth_plain(JEAN_LOGIN, "abcde-fghjk-mnpqr-stvwx")
        .await
        .starts_with("535 5.7.8"));
    assert!(session
        .auth_plain(JEAN_LOGIN, &passwords.read_only)
        .await
        .starts_with("535 5.7.8"));
    assert!(session
        .auth_login(JEAN_LOGIN, &passwords.send)
        .await
        .starts_with("235 2.7.0"));
    assert!(session
        .auth_plain(JEAN_LOGIN, &passwords.send)
        .await
        .starts_with("503 5.5.1"));

    // Usurpation de l'enveloppe : l'adresse d'un autre compte
    assert!(session
        .command("MAIL FROM:<paul@alpha.test>")
        .await
        .starts_with("550 5.7.1"));
    // Usurpation de l'en-tête : From d'un autre compte, puis Sender d'un autre domaine
    assert!(session
        .command("MAIL FROM:<jean@alpha.test>")
        .await
        .starts_with("250 2.1.0"));
    assert!(session
        .command("RCPT TO:<inconnu@alpha.test>")
        .await
        .starts_with("550 5.1.1"));
    assert!(session
        .command("RCPT TO:<x@ailleurs.test>")
        .await
        .starts_with("250 2.1.5"));
    let spoofed = MESSAGE.replace(
        "From: Jean <jean@alpha.test>",
        "From: Paul <paul@alpha.test>",
    );
    assert!(session.data(&spoofed).await.starts_with("550 5.7.1"));
    assert!(session
        .command("MAIL FROM:<jean@alpha.test>")
        .await
        .starts_with("250"));
    assert!(session
        .command("RCPT TO:<x@ailleurs.test>")
        .await
        .starts_with("250"));
    let spoofed = MESSAGE.replace("To: ", "Sender: chef@ailleurs.test\r\nTo: ");
    assert!(session.data(&spoofed).await.starts_with("550 5.7.1"));

    // Envoi accepté : 250 après l'inscription dans la file
    assert!(session
        .command("MAIL FROM:<jean@alpha.test> RET=HDRS ENVID=devis-1")
        .await
        .starts_with("250"));
    assert!(session
        .command("RCPT TO:<x@ailleurs.test> NOTIFY=SUCCESS,FAILURE")
        .await
        .starts_with("250"));
    assert!(session
        .command("RCPT TO:<paul@alpha.test>")
        .await
        .starts_with("250"));
    // Partie locale entre guillemets : gardée sous sa forme d'enveloppe jusqu'à la file
    assert!(session
        .command("RCPT TO:<\"john doe\"@ailleurs.test>")
        .await
        .starts_with("250"));
    let accepted = session.data(MESSAGE).await;
    assert!(
        accepted.starts_with("250 2.0.0 Ok queued as s"),
        "{accepted}"
    );
    let key = accepted
        .rsplit(' ')
        .next()
        .expect("identifiant")
        .to_string();
    assert!(session.command("QUIT").await.starts_with("221"));

    let state: String = value(
        &client,
        &format!("SELECT VALUE state FROM ONLY mail_submission:{key}"),
    )
    .await;
    assert_eq!(state, "queued");
    let recipients: Vec<String> = client
        .query(format!(
            "SELECT VALUE state FROM mail_queue_recipient WHERE submission = mail_submission:{key}"
        ))
        .await
        .expect("destinataires")
        .take(0)
        .expect("états");
    assert_eq!(recipients, ["scheduled", "scheduled", "scheduled"]);
    let local: Vec<bool> = client
        .query(format!("SELECT VALUE local FROM mail_queue_recipient WHERE submission = mail_submission:{key} ORDER BY rank"))
        .await
        .expect("destinataires")
        .take(0)
        .expect("routes");
    assert_eq!(local, [false, true, false]);
    let quoted: Vec<String> = client
        .query(format!("SELECT VALUE address FROM mail_queue_recipient WHERE submission = mail_submission:{key} AND local = false ORDER BY rank"))
        .await
        .expect("destinataires")
        .take(0)
        .expect("adresses");
    assert_eq!(quoted, ["x@ailleurs.test", "\"john doe\"@ailleurs.test"]);
    let object: RecordId = value(
        &client,
        &format!("SELECT VALUE content.object FROM ONLY mail_submission:{key}"),
    )
    .await;
    let text = stored(&client, &config, &object.to_sql()).await;
    assert!(
        text.starts_with("Received: from poste.alpha.test\r\n\tby mx.lyxal.test with ESMTPSA id "),
        "{text}"
    );
    assert!(!text.contains("127.0.0.1"), "{text}");
    assert!(text.contains("\r\nDate: "), "{text}");
    assert!(text.contains("@mx.lyxal.test>\r\n"), "{text}");
    assert!(
        text.contains("Subject: Devis du chantier\r\n\r\nBonjour"),
        "{text}"
    );
    assert!(!text.contains("Bcc") && !text.contains("secret@"), "{text}");

    // Port 465 : TLS implicite, AUTH annoncé d'emblée ; limite de destinataires de
    // l'organisation (1 par message)
    run(
        &client,
        "fn::mail_settings_set({ tenant: 'auth_organization:alpha', send_recipients_per_message: 1 });",
    )
    .await;
    let mut session = Client::implicit(implicit).await;
    let ehlo = session.command("EHLO poste.alpha.test").await;
    assert!(
        ehlo.contains("AUTH PLAIN LOGIN") && !ehlo.contains("STARTTLS"),
        "{ehlo}"
    );
    assert!(session
        .auth_plain(JEAN_LOGIN, &passwords.send)
        .await
        .starts_with("235"));
    for line in [
        "MAIL FROM:<jean@alpha.test>",
        "RCPT TO:<x@ailleurs.test>",
        "RCPT TO:<y@ailleurs.test>",
    ] {
        assert!(session.command(line).await.starts_with("250"), "{line}");
    }
    assert!(session.data(MESSAGE).await.starts_with("550 5.5.3"));
    assert!(session.command("QUIT").await.starts_with("221"));

    // Trois échecs d'authentification : fermeture, sans bannissement réseau
    let mut session = Client::implicit(implicit).await;
    session.command("EHLO poste.alpha.test").await;
    for _ in 0..2 {
        assert!(session
            .auth_plain(JEAN_LOGIN, "abcde-fghjk-mnpqr-stvwx")
            .await
            .starts_with("535"));
    }
    assert!(session
        .auth_plain(JEAN_LOGIN, "abcde-fghjk-mnpqr-stvwx")
        .await
        .starts_with("421 4.7.0"));
    let mut session = Client::implicit(implicit).await;
    assert!(session.command("NOOP").await.starts_with("250"));
    assert!(session.command("QUIT").await.starts_with("221"));

    // Panne de la base pendant l'inscription : 451, rien en file
    run(&client, "fn::mail_settings_set({ tenant: 'auth_organization:alpha', send_recipients_per_message: 100 });").await;
    run(&client, "REMOVE FUNCTION fn::mail_submission_commit;").await;
    let before: i64 = value(&client, "RETURN count(SELECT id FROM mail_queue_recipient)").await;
    let mut session = Client::implicit(implicit).await;
    session.command("EHLO poste.alpha.test").await;
    assert!(session
        .auth_plain(JEAN_LOGIN, &passwords.send)
        .await
        .starts_with("235"));
    assert!(session
        .command("MAIL FROM:<jean@alpha.test>")
        .await
        .starts_with("250"));
    assert!(session
        .command("RCPT TO:<x@ailleurs.test>")
        .await
        .starts_with("250"));
    assert!(session.data(MESSAGE).await.starts_with("451 4.3.0"));
    let after: i64 = value(&client, "RETURN count(SELECT id FROM mail_queue_recipient)").await;
    assert_eq!(before, after);

    let snapshot = started.mail.snapshot();
    let metrics = snapshot.submission.expect("mesures du dépôt");
    assert_eq!(metrics["submissions_queued"], 1);
    assert_eq!(metrics["submission_recipients_queued"], 2);
    assert_eq!(metrics["submission_spoofing"], 3);
    assert_eq!(metrics["auth_refused.forbidden"], 1);
    assert_eq!(metrics["auth_refused.invalid"], 4);
    assert_eq!(metrics["tls_required"], 2);
    assert!(metrics.keys().all(|name| !name.contains('@')));
    started.runtime.stop_all().await.expect("arrêt");
}

#[tokio::test]
async fn a_submission_listener_requires_the_application_key() {
    let certificates = TestCertificates::new();
    let root = tempfile::tempdir().expect("support");
    let config = config("submission_no_key", root.path(), &certificates, false);
    let client = crate::support::database("submission_no_key").await;
    let certificates_loaded =
        lyxal_groupware::net::certificates::Certificates::load(&config.tls).expect("certificats");
    let error = lyxal_groupware::runtime::start(
        &config,
        &client.clone().into(),
        lyxal_groupware::net::bind::bind_listeners(&config).expect("liaison"),
        certificates_loaded,
    )
    .await
    .err()
    .expect("démarrage refusé");
    assert_eq!(error.code(), "GROUPWARE_APPLICATION_KEY_MISSING");
}
