//! Client-side TLS: configuration and real handshakes without network against the server of
//! `tls_server_config` (`rustls` connections in memory, then `tokio-rustls` over a duplex
//! pipe). The `WebPki` path with a trusted chain, a wrong name and an expired certificate is
//! checked by the unit tests of `src/tls.rs` (no test certificate chains to `webpki-roots`).
//! Test certificates: `tests/fixtures/tls_test_only/` (commands in `tests/fixtures/README.md`).
use lyxal_crypto::rustls::client::ClientConnection;
use lyxal_crypto::rustls::crypto::aws_lc_rs;
use lyxal_crypto::rustls::pki_types::pem::PemObject;
use lyxal_crypto::rustls::pki_types::{CertificateDer, PrivateKeyDer, ServerName};
use lyxal_crypto::rustls::server::{ClientHello, ResolvesServerCert, ServerConnection};
use lyxal_crypto::rustls::sign::CertifiedKey;
use lyxal_crypto::rustls::{
    self, CertificateError, ClientConfig, Error, HandshakeKind, ServerConfig,
};
use lyxal_crypto::{
    tls_client_config, tls_peer_info, tls_server_config, CryptoError, SecretBytes,
    TlsCertificateStore, TlsCertifiedKey, TlsClientOptions, TlsMinVersion, TlsServerOptions,
    TlsServerVerification,
};
use std::sync::Arc;

macro_rules! fixture {
    ($name:literal) => {
        include_bytes!(concat!("../fixtures/tls_test_only/", $name)).as_slice()
    };
}

fn key(chain: &[u8], private_key: &[u8]) -> TlsCertifiedKey {
    TlsCertifiedKey::from_pem(chain, SecretBytes::new(private_key.to_vec()).unwrap()).unwrap()
}

fn p256() -> TlsCertifiedKey {
    key(fixture!("p256.chain.pem"), fixture!("p256.key.pem"))
}

fn self_signed() -> TlsCertifiedKey {
    key(
        fixture!("selfsigned.chain.pem"),
        fixture!("selfsigned.key.pem"),
    )
}

fn leaf(chain: &[u8]) -> CertificateDer<'static> {
    CertificateDer::pem_slice_iter(chain)
        .next()
        .unwrap()
        .unwrap()
}

fn chain(pem: &[u8]) -> Vec<CertificateDer<'static>> {
    CertificateDer::pem_slice_iter(pem)
        .map(|certificate| certificate.unwrap())
        .collect()
}

fn options(verification: TlsServerVerification) -> TlsClientOptions {
    TlsClientOptions {
        verification,
        ..TlsClientOptions::default()
    }
}

fn opportunistic() -> Arc<ClientConfig> {
    tls_client_config(&options(TlsServerVerification::Opportunistic)).unwrap()
}

fn lyxal_server(default: TlsCertifiedKey) -> Arc<ServerConfig> {
    tls_server_config(
        TlsCertificateStore::new(Some(default)),
        &TlsServerOptions::default(),
    )
    .unwrap()
}

/// Server built here only to misbehave (or to restrict versions): rustls with the same
/// provider, certificates chosen by `resolver`.
fn raw_server(
    versions: &[&'static rustls::SupportedProtocolVersion],
    resolver: Arc<dyn ResolvesServerCert>,
) -> Arc<ServerConfig> {
    Arc::new(
        ServerConfig::builder_with_provider(Arc::new(aws_lc_rs::default_provider()))
            .with_protocol_versions(versions)
            .unwrap()
            .with_no_client_auth()
            .with_cert_resolver(resolver),
    )
}

/// Serves the P-256 chain of `mail.example.test` but signs the handshake with another P-256
/// key: the handshake signature does not match the certificate presented.
#[derive(Debug)]
struct ForgedSignature;
impl ResolvesServerCert for ForgedSignature {
    fn resolve(&self, _client_hello: ClientHello<'_>) -> Option<Arc<CertifiedKey>> {
        let other_key = PrivateKeyDer::from_pem_slice(fixture!("p256_next.key.pem")).unwrap();
        let signer = aws_lc_rs::sign::any_supported_type(&other_key).unwrap();
        Some(Arc::new(CertifiedKey::new(
            chain(fixture!("p256.chain.pem")),
            signer,
        )))
    }
}

fn server_name(name: &str) -> ServerName<'static> {
    ServerName::try_from(name.to_owned()).unwrap()
}

/// In-memory handshake, flights in both directions until both sides are done.
fn handshake(
    client_config: Arc<ClientConfig>,
    server_config: &Arc<ServerConfig>,
    name: ServerName<'static>,
) -> Result<(ClientConnection, ServerConnection), Error> {
    let mut client = ClientConnection::new(client_config, name)?;
    let mut server = ServerConnection::new(Arc::clone(server_config))?;
    assert_eq!(
        tls_peer_info(&client, TlsServerVerification::Opportunistic),
        None
    );
    for _ in 0..16 {
        let mut flight = Vec::new();
        while client.wants_write() {
            client.write_tls(&mut flight).unwrap();
        }
        let mut reader = flight.as_slice();
        while !reader.is_empty() {
            server.read_tls(&mut reader).unwrap();
            server.process_new_packets()?;
        }
        let mut flight = Vec::new();
        while server.wants_write() {
            server.write_tls(&mut flight).unwrap();
        }
        let mut reader = flight.as_slice();
        while !reader.is_empty() {
            client.read_tls(&mut reader).unwrap();
            client.process_new_packets()?;
        }
    }
    assert!(!client.is_handshaking() && !server.is_handshaking());
    Ok((client, server))
}

fn served(client: &ClientConnection) -> CertificateDer<'static> {
    client.peer_certificates().unwrap()[0].clone()
}

#[test]
fn configuration_is_fixed_and_built_without_a_process_provider() {
    for verification in [
        TlsServerVerification::Opportunistic,
        TlsServerVerification::WebPki,
    ] {
        let config = tls_client_config(&options(verification)).unwrap();
        // Both rustls providers are compiled in: no process default exists, and
        // tls_client_config never relies on one (ClientConfig::builder() would panic).
        assert!(rustls::crypto::CryptoProvider::get_default().is_none());
        assert!(!config.enable_early_data);
        assert!(config.enable_sni);
        assert!(!config.client_auth_cert_resolver.has_certs());
        assert!(!config.key_log.will_log("CLIENT_RANDOM"));
        assert!(!config.enable_secret_extraction);
        assert!(config.alpn_protocols.is_empty());
    }
    assert!(std::panic::catch_unwind(ClientConfig::builder).is_err());
}

#[test]
fn alpn_and_cache_bounds() {
    for alpn in [
        vec![Vec::new()],
        vec![vec![b'a'; 256]],
        vec![b"x".to_vec(); 9],
    ] {
        let options = TlsClientOptions {
            alpn_protocols: alpn,
            ..TlsClientOptions::default()
        };
        assert_eq!(
            tls_client_config(&options).unwrap_err(),
            CryptoError::InputTooLarge
        );
    }
    let options = TlsClientOptions {
        session_cache_entries: 65_537,
        ..TlsClientOptions::default()
    };
    assert_eq!(
        tls_client_config(&options).unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn opportunistic_accepts_a_self_signed_certificate_and_a_wrong_name() {
    let server = lyxal_server(self_signed());
    for (version, expected) in [
        (TlsMinVersion::Tls12, "TLSv1.3"),
        (TlsMinVersion::Tls13, "TLSv1.3"),
    ] {
        let options = TlsClientOptions {
            verification: TlsServerVerification::Opportunistic,
            min_version: version,
            ..TlsClientOptions::default()
        };
        let (client, _) = handshake(
            tls_client_config(&options).unwrap(),
            &server,
            server_name("mail.example.test"),
        )
        .unwrap();
        assert_eq!(served(&client), leaf(fixture!("selfsigned.chain.pem")));
        let info = tls_peer_info(&client, TlsServerVerification::Opportunistic).unwrap();
        assert_eq!(info.version, expected);
        assert!(!info.verified);
        assert!(info.cipher_suite.starts_with("TLS13_"), "{info:?}");
    }
    // A chain of an unknown authority, presented for another name.
    let (client, _) = handshake(
        opportunistic(),
        &lyxal_server(p256()),
        server_name("not-the-mx.example.org"),
    )
    .unwrap();
    assert_eq!(served(&client), leaf(fixture!("p256.chain.pem")));
}

#[test]
fn webpki_refuses_self_signed_and_unknown_authorities() {
    let webpki = tls_client_config(&options(TlsServerVerification::WebPki)).unwrap();
    for certified in [self_signed(), p256()] {
        let error = handshake(
            Arc::clone(&webpki),
            &lyxal_server(certified),
            server_name("mail.example.test"),
        )
        .unwrap_err();
        assert_eq!(
            error,
            Error::InvalidCertificate(CertificateError::UnknownIssuer),
            "{error:?}"
        );
    }
}

#[test]
fn opportunistic_refuses_a_forged_handshake_signature() {
    for version in [&rustls::version::TLS13, &rustls::version::TLS12] {
        let server = raw_server(&[version], Arc::new(ForgedSignature));
        let error =
            handshake(opportunistic(), &server, server_name("mail.example.test")).unwrap_err();
        assert_eq!(
            error,
            Error::InvalidCertificate(CertificateError::BadSignature),
            "{version:?}: {error:?}"
        );
    }
    // The same chain with its own key goes through (control).
    let store = TlsCertificateStore::new(Some(p256()));
    for version in [&rustls::version::TLS13, &rustls::version::TLS12] {
        let server = raw_server(
            &[version],
            Arc::clone(&store) as Arc<dyn ResolvesServerCert>,
        );
        handshake(opportunistic(), &server, server_name("mail.example.test")).unwrap();
    }
}

#[test]
fn versions_tls12_tls13_and_minimum() {
    let store = TlsCertificateStore::new(Some(p256()));
    let tls12_only = raw_server(
        &[&rustls::version::TLS12],
        Arc::clone(&store) as Arc<dyn ResolvesServerCert>,
    );
    let (client, _) = handshake(
        opportunistic(),
        &tls12_only,
        server_name("mail.example.test"),
    )
    .unwrap();
    let info = tls_peer_info(&client, TlsServerVerification::Opportunistic).unwrap();
    assert_eq!(info.version, "TLSv1.2");
    assert!(
        info.cipher_suite.starts_with("TLS_ECDHE_ECDSA_"),
        "{info:?}"
    );
    // A TLS 1.3 minimum refuses a TLS 1.2 server.
    let tls13 = tls_client_config(&TlsClientOptions {
        verification: TlsServerVerification::Opportunistic,
        min_version: TlsMinVersion::Tls13,
        ..TlsClientOptions::default()
    })
    .unwrap();
    assert!(handshake(tls13, &tls12_only, server_name("mail.example.test")).is_err());
    // The Lyxal server prefers TLS 1.3.
    let (client, _) = handshake(
        opportunistic(),
        &lyxal_server(p256()),
        server_name("mail.example.test"),
    )
    .unwrap();
    assert_eq!(
        tls_peer_info(&client, TlsServerVerification::Opportunistic)
            .unwrap()
            .version,
        "TLSv1.3"
    );
}

#[test]
fn sni_is_the_dns_name_and_never_an_ip_address() {
    let store = TlsCertificateStore::new(Some(key(
        fixture!("default.chain.pem"),
        fixture!("default.key.pem"),
    )));
    store.insert("mail.example.test", p256()).unwrap();
    let server = tls_server_config(Arc::clone(&store), &TlsServerOptions::default()).unwrap();
    let (client, server_side) =
        handshake(opportunistic(), &server, server_name("MAIL.example.test")).unwrap();
    assert_eq!(server_side.server_name(), Some("mail.example.test"));
    assert_eq!(served(&client), leaf(fixture!("p256.chain.pem")));
    // An IP address is never sent as SNI (RFC 6066 §3): the server serves its default.
    let (client, server_side) =
        handshake(opportunistic(), &server, server_name("192.0.2.25")).unwrap();
    assert_eq!(server_side.server_name(), None);
    assert_eq!(served(&client), leaf(fixture!("default.chain.pem")));
}

#[test]
fn session_resumption_follows_the_cache_setting() {
    let server = lyxal_server(p256());
    for (entries, resumed) in [(256, true), (0, false)] {
        let client = tls_client_config(&TlsClientOptions {
            verification: TlsServerVerification::Opportunistic,
            session_cache_entries: entries,
            ..TlsClientOptions::default()
        })
        .unwrap();
        handshake(
            Arc::clone(&client),
            &server,
            server_name("mail.example.test"),
        )
        .unwrap();
        let (second, _) = handshake(client, &server, server_name("mail.example.test")).unwrap();
        let kind = second.handshake_kind().unwrap();
        assert_eq!(
            kind == HandshakeKind::Resumed,
            resumed,
            "{entries}: {kind:?}"
        );
    }
}

#[test]
fn tokio_rustls_connector_end_to_end() {
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    let runtime = tokio::runtime::Builder::new_current_thread()
        .build()
        .unwrap();
    runtime.block_on(async {
        let server = tls_server_config(
            TlsCertificateStore::new(Some(self_signed())),
            &TlsServerOptions {
                alpn_protocols: vec![b"smtp".to_vec()],
                ..TlsServerOptions::default()
            },
        )
        .unwrap();
        let acceptor = tokio_rustls::TlsAcceptor::from(server);
        let client = tls_client_config(&TlsClientOptions {
            verification: TlsServerVerification::Opportunistic,
            alpn_protocols: vec![b"smtp".to_vec()],
            ..TlsClientOptions::default()
        })
        .unwrap();
        let connector = tokio_rustls::TlsConnector::from(client);
        let (client_io, server_io) = tokio::io::duplex(64 * 1024);
        let server_task = async move {
            let mut stream = acceptor.accept(server_io).await.unwrap();
            let mut request = [0u8; 4];
            stream.read_exact(&mut request).await.unwrap();
            stream.write_all(b"250 ").await.unwrap();
            stream.write_all(&request).await.unwrap();
            stream.shutdown().await.unwrap();
        };
        let client_task = async move {
            let mut stream = connector
                .connect(server_name("mail.example.test"), client_io)
                .await
                .unwrap();
            let connection = stream.get_ref().1;
            assert_eq!(connection.alpn_protocol(), Some(b"smtp".as_slice()));
            let info = tls_peer_info(connection, TlsServerVerification::Opportunistic).unwrap();
            assert!(!info.verified);
            stream.write_all(b"NOOP").await.unwrap();
            let mut answer = Vec::new();
            stream.read_to_end(&mut answer).await.unwrap();
            answer
        };
        let ((), answer) = tokio::join!(server_task, client_task);
        assert_eq!(answer, b"250 NOOP");
    });
}
