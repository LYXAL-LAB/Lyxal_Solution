//! Server-side TLS: configuration, certificate store and real handshakes without network
//! (`rustls` client and server connections in memory, then `tokio-rustls` over a duplex pipe).
//! Test certificates: `tests/fixtures/tls_test_only/` (commands in `tests/fixtures/README.md`).
use lyxal_crypto::rustls::client::ClientConnection;
use lyxal_crypto::rustls::pki_types::pem::PemObject;
use lyxal_crypto::rustls::pki_types::{CertificateDer, ServerName, UnixTime};
use lyxal_crypto::rustls::server::ServerConnection;
use lyxal_crypto::rustls::time_provider::TimeProvider;
use lyxal_crypto::rustls::{
    self, ClientConfig, HandshakeKind, ProtocolVersion, RootCertStore, ServerConfig,
};
use lyxal_crypto::{
    tls_server_config, CryptoError, SecretBytes, TlsCertificateStore, TlsCertifiedKey,
    TlsMinVersion, TlsServerOptions,
};
use std::sync::Arc;

macro_rules! fixture {
    ($name:literal) => {
        include_bytes!(concat!("../fixtures/tls_test_only/", $name)).as_slice()
    };
}

fn secret(bytes: &[u8]) -> SecretBytes {
    SecretBytes::new(bytes.to_vec()).unwrap()
}

fn key(chain: &[u8], private_key: &[u8]) -> TlsCertifiedKey {
    TlsCertifiedKey::from_pem(chain, secret(private_key)).unwrap()
}

fn p256() -> TlsCertifiedKey {
    key(fixture!("p256.chain.pem"), fixture!("p256.key.pem"))
}

fn leaf(chain: &[u8]) -> CertificateDer<'static> {
    CertificateDer::pem_slice_iter(chain)
        .next()
        .unwrap()
        .unwrap()
}

/// Fixed clock inside the validity of the test certificates (2027-01-01T00:00:00Z).
#[derive(Debug)]
struct FixedTime;
impl TimeProvider for FixedTime {
    fn current_time(&self) -> Option<UnixTime> {
        Some(UnixTime::since_unix_epoch(std::time::Duration::from_secs(
            1_798_761_600,
        )))
    }
}

fn client(versions: &[&'static rustls::SupportedProtocolVersion], alpn: &[&[u8]]) -> ClientConfig {
    let mut roots = RootCertStore::empty();
    roots.add(leaf(fixture!("ca.pem"))).unwrap();
    let mut config = ClientConfig::builder_with_details(
        Arc::new(rustls::crypto::aws_lc_rs::default_provider()),
        Arc::new(FixedTime),
    )
    .with_protocol_versions(versions)
    .unwrap()
    .with_root_certificates(roots)
    .with_no_client_auth();
    config.alpn_protocols = alpn.iter().map(|name| name.to_vec()).collect();
    config
}

fn all_versions() -> ClientConfig {
    client(rustls::ALL_VERSIONS, &[])
}

/// In-memory handshake; the client verifies the chain against the test CA and `name`.
fn handshake(
    server: &Arc<ServerConfig>,
    mut client_config: ClientConfig,
    name: &str,
    send_sni: bool,
) -> Result<(ClientConnection, ServerConnection), rustls::Error> {
    client_config.enable_sni = send_sni;
    let mut client = ClientConnection::new(
        Arc::new(client_config),
        ServerName::try_from(name.to_owned()).unwrap(),
    )?;
    let mut server = ServerConnection::new(Arc::clone(server))?;
    exchange(&mut client, &mut server)?;
    assert!(!client.is_handshaking() && !server.is_handshaking());
    Ok((client, server))
}

/// Sixteen rounds of flights in both directions (handshake, then TLS 1.3 tickets).
fn exchange(
    client: &mut ClientConnection,
    server: &mut ServerConnection,
) -> Result<(), rustls::Error> {
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
    Ok(())
}

fn served(client: &ClientConnection) -> CertificateDer<'static> {
    client.peer_certificates().unwrap()[0].clone()
}

fn config(store: &Arc<TlsCertificateStore>) -> Arc<ServerConfig> {
    tls_server_config(Arc::clone(store), &TlsServerOptions::default()).unwrap()
}

#[test]
fn builder_without_provider_panics_in_the_workspace_but_ours_does_not() {
    // Both rustls providers are compiled in (as in the workspace): no process default exists,
    // and the default constructor stops with a panic. tls_server_config never relies on it.
    assert!(rustls::crypto::CryptoProvider::get_default().is_none());
    assert!(std::panic::catch_unwind(ServerConfig::builder).is_err());
    let store = TlsCertificateStore::new(Some(p256()));
    let config = tls_server_config(store, &TlsServerOptions::default()).unwrap();
    assert!(rustls::crypto::CryptoProvider::get_default().is_none());
    assert_eq!(config.max_early_data_size, 0);
    assert!(!config.send_half_rtt_data);
    assert!(!config.key_log.will_log("CLIENT_RANDOM"));
    assert!(config.alpn_protocols.is_empty());
}

#[test]
fn tls12_and_tls13_handshakes_with_each_key_type() {
    let store = TlsCertificateStore::new(None);
    let cases = [
        ("mail.example.test", p256(), fixture!("p256.chain.pem")),
        (
            "p384.example.test",
            key(fixture!("p384.chain.pem"), fixture!("p384.key.pem")),
            fixture!("p384.chain.pem"),
        ),
        (
            "rsa.example.test",
            key(fixture!("rsa2048.chain.pem"), fixture!("rsa2048.key.pem")),
            fixture!("rsa2048.chain.pem"),
        ),
        (
            "ed.example.test",
            key(fixture!("ed25519.chain.pem"), fixture!("ed25519.key.pem")),
            fixture!("ed25519.chain.pem"),
        ),
    ];
    let mut expected = Vec::new();
    for (name, certified, chain) in cases {
        store.insert(name, certified).unwrap();
        expected.push((name, leaf(chain)));
    }
    let server = config(&store);
    for (name, certificate) in expected {
        for (version, protocol) in [
            (&rustls::version::TLS13, ProtocolVersion::TLSv1_3),
            (&rustls::version::TLS12, ProtocolVersion::TLSv1_2),
        ] {
            let (client, server_side) =
                handshake(&server, client(&[version], &[]), name, true).unwrap();
            assert_eq!(client.protocol_version(), Some(protocol), "{name}");
            assert_eq!(server_side.server_name(), Some(name));
            assert_eq!(served(&client), certificate, "{name}");
        }
    }
}

#[test]
fn tls13_minimum_refuses_a_tls12_client_and_prefers_hybrid_key_exchange() {
    let store = TlsCertificateStore::new(Some(p256()));
    let options = TlsServerOptions {
        min_version: TlsMinVersion::Tls13,
        ..TlsServerOptions::default()
    };
    let server = tls_server_config(store, &options).unwrap();
    assert!(handshake(
        &server,
        client(&[&rustls::version::TLS12], &[]),
        "mail.example.test",
        true
    )
    .is_err());
    let (client, _) = handshake(&server, all_versions(), "mail.example.test", true).unwrap();
    assert_eq!(client.protocol_version(), Some(ProtocolVersion::TLSv1_3));
    let group = client.negotiated_key_exchange_group().unwrap().name();
    assert!(
        matches!(
            group,
            rustls::NamedGroup::X25519MLKEM768 | rustls::NamedGroup::X25519
        ),
        "{group:?}"
    );
}

#[test]
fn alpn_is_negotiated_and_bounded() {
    let store = TlsCertificateStore::new(Some(p256()));
    let options = TlsServerOptions {
        alpn_protocols: vec![b"imap".to_vec(), b"h2".to_vec()],
        ..TlsServerOptions::default()
    };
    let server = tls_server_config(Arc::clone(&store), &options).unwrap();
    let (client_side, server_side) = handshake(
        &server,
        client(rustls::ALL_VERSIONS, &[b"h2", b"imap"]),
        "mail.example.test",
        true,
    )
    .unwrap();
    assert_eq!(client_side.alpn_protocol(), Some(b"imap".as_slice()));
    assert_eq!(server_side.alpn_protocol(), Some(b"imap".as_slice()));
    // A client offering only unknown protocols is refused (RFC 7301 §3.2).
    assert!(handshake(
        &server,
        client(rustls::ALL_VERSIONS, &[b"smtp"]),
        "mail.example.test",
        true
    )
    .is_err());
    for alpn in [
        vec![Vec::new()],
        vec![vec![b'a'; 256]],
        vec![b"x".to_vec(); 9],
    ] {
        let options = TlsServerOptions {
            alpn_protocols: alpn,
            ..TlsServerOptions::default()
        };
        assert_eq!(
            tls_server_config(Arc::clone(&store), &options).unwrap_err(),
            CryptoError::InputTooLarge
        );
    }
    let options = TlsServerOptions {
        session_cache_entries: 65_537,
        ..TlsServerOptions::default()
    };
    assert_eq!(
        tls_server_config(store, &options).unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn sni_selection_wildcard_and_default() {
    let store = TlsCertificateStore::new(Some(key(
        fixture!("default.chain.pem"),
        fixture!("default.key.pem"),
    )));
    store.insert("MAIL.example.test", p256()).unwrap();
    store
        .insert(
            "*.wild.example.test",
            key(fixture!("wildcard.chain.pem"), fixture!("wildcard.key.pem")),
        )
        .unwrap();
    let server = config(&store);
    let mail = leaf(fixture!("p256.chain.pem"));
    let wild = leaf(fixture!("wildcard.chain.pem"));
    let default = leaf(fixture!("default.chain.pem"));
    let (client, _) = handshake(&server, all_versions(), "mail.example.test", true).unwrap();
    assert_eq!(served(&client), mail);
    let (client, _) = handshake(&server, all_versions(), "imap.wild.example.test", true).unwrap();
    assert_eq!(served(&client), wild);
    // Without SNI (or for an unknown name) the default certificate is served.
    let (client, _) = handshake(&server, all_versions(), "default.example.test", false).unwrap();
    assert_eq!(served(&client), default);
    let (client, _) = handshake(&server, all_versions(), "default.example.test", true).unwrap();
    assert_eq!(served(&client), default);
    // The wildcard covers one level only: a deeper name gets the default certificate, which
    // the client then refuses for that name.
    assert!(handshake(&server, all_versions(), "a.b.wild.example.test", true).is_err());
    // Removal and absence of default: the handshake fails cleanly (alert, no panic).
    assert!(store.remove("mail.EXAMPLE.test"));
    assert!(!store.remove("mail.example.test"));
    store.set_default(None);
    assert!(handshake(&server, all_versions(), "mail.example.test", true).is_err());
    assert!(handshake(&server, all_versions(), "default.example.test", false).is_err());
}

#[test]
fn no_certificate_at_all_fails_the_handshake_without_panic() {
    let server = config(&TlsCertificateStore::new(None));
    assert!(handshake(&server, all_versions(), "mail.example.test", true).is_err());
}

#[test]
fn hot_replacement_is_seen_by_the_next_handshake_only() {
    let store = TlsCertificateStore::new(None);
    store.insert("mail.example.test", p256()).unwrap();
    let server = config(&store);
    let (open_client, _open_server) =
        handshake(&server, all_versions(), "mail.example.test", true).unwrap();
    store
        .insert(
            "mail.example.test",
            key(
                fixture!("p256_next.chain.pem"),
                fixture!("p256_next.key.pem"),
            ),
        )
        .unwrap();
    let (client, _) = handshake(&server, all_versions(), "mail.example.test", true).unwrap();
    assert_eq!(served(&client), leaf(fixture!("p256_next.chain.pem")));
    // The connection opened before the replacement keeps its certificate.
    assert_eq!(served(&open_client), leaf(fixture!("p256.chain.pem")));
}

#[test]
fn session_resumption_follows_the_cache_setting() {
    for (entries, resumed) in [(4096, true), (0, false)] {
        let options = TlsServerOptions {
            session_cache_entries: entries,
            ..TlsServerOptions::default()
        };
        let server = tls_server_config(TlsCertificateStore::new(Some(p256())), &options).unwrap();
        let shared = Arc::new(all_versions());
        let mut first = ClientConnection::new(
            Arc::clone(&shared),
            ServerName::try_from("mail.example.test").unwrap(),
        )
        .unwrap();
        let mut server_side = ServerConnection::new(Arc::clone(&server)).unwrap();
        exchange(&mut first, &mut server_side).unwrap();
        let mut second = ClientConnection::new(
            Arc::clone(&shared),
            ServerName::try_from("mail.example.test").unwrap(),
        )
        .unwrap();
        let mut server_side = ServerConnection::new(Arc::clone(&server)).unwrap();
        exchange(&mut second, &mut server_side).unwrap();
        let kind = second.handshake_kind().unwrap();
        assert_eq!(
            kind == HandshakeKind::Resumed,
            resumed,
            "{entries}: {kind:?}"
        );
    }
}

#[test]
fn key_encodings_accepted() {
    for (chain, private_key) in [
        (fixture!("p256.chain.pem"), fixture!("p256.sec1.key.pem")),
        (
            fixture!("rsa2048.chain.pem"),
            fixture!("rsa2048.pkcs1.key.pem"),
        ),
    ] {
        TlsCertifiedKey::from_pem(chain, secret(private_key)).unwrap();
    }
    // A key file preceded by an EC PARAMETERS block, with CRLF line ends.
    let mut with_parameters =
        b"-----BEGIN EC PARAMETERS-----\r\nBggqhkjOPQMBBw==\r\n-----END EC PARAMETERS-----\r\n"
            .to_vec();
    with_parameters.extend(fixture!("p256.sec1.key.pem").iter().flat_map(|&b| {
        if b == b'\n' {
            vec![b'\r', b'\n']
        } else {
            vec![b]
        }
    }));
    TlsCertifiedKey::from_pem(fixture!("p256.chain.pem"), secret(&with_parameters)).unwrap();
    let certified = TlsCertifiedKey::from_der(
        vec![fixture!("p256.leaf.der").to_vec()],
        secret(fixture!("p256.key.der")),
    )
    .unwrap();
    assert_eq!(format!("{certified:?}"), "TlsCertifiedKey([REDACTED])");
    let store = TlsCertificateStore::new(None);
    store.insert("mail.example.test", certified).unwrap();
    let (client, _) =
        handshake(&config(&store), all_versions(), "mail.example.test", true).unwrap();
    assert_eq!(served(&client), leaf(fixture!("p256.chain.pem")));
}

#[test]
fn invalid_certificates_and_keys_are_refused() {
    let chain = fixture!("p256.chain.pem");
    let refuse = |chain: &[u8], private_key: &[u8]| {
        TlsCertifiedKey::from_pem(chain, secret(private_key)).unwrap_err()
    };
    // Key of another certificate.
    assert_eq!(
        refuse(chain, fixture!("p256_next.key.pem")),
        CryptoError::CertificateKeyMismatch
    );
    assert_eq!(
        refuse(chain, fixture!("rsa2048.key.pem")),
        CryptoError::CertificateKeyMismatch
    );
    // Encrypted, truncated, absent, duplicated, weak or unsupported keys.
    let key = fixture!("p256.key.pem");
    let mut twice = key.to_vec();
    twice.extend_from_slice(key);
    for private_key in [
        fixture!("p256.encrypted.key.pem"),
        &key[..key.len() - 30],
        &key[..key.len() / 2],
        b"".as_slice(),
        b"not a key".as_slice(),
        twice.as_slice(),
        fixture!("p256.key.der"),
    ] {
        assert_eq!(refuse(chain, private_key), CryptoError::InvalidKeyEncoding);
    }
    let legacy_encrypted = b"-----BEGIN EC PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: AES-256-CBC,00\n\nAAAA\n-----END EC PRIVATE KEY-----\n";
    assert_eq!(
        refuse(chain, legacy_encrypted),
        CryptoError::InvalidKeyEncoding
    );
    assert_eq!(
        refuse(fixture!("rsa1024.chain.pem"), fixture!("rsa1024.key.pem")),
        CryptoError::InvalidKeyEncoding
    );
    assert_eq!(
        refuse(fixture!("p521.chain.pem"), fixture!("p521.key.pem")),
        CryptoError::InvalidKeyEncoding
    );
    // Empty, truncated, unreadable or too long chains.
    let truncated = &chain[..chain.len() / 3];
    for bad_chain in [
        b"".as_slice(),
        truncated,
        b"-----BEGIN CERTIFICATE-----\nAAAA\n-----END CERTIFICATE-----\n".as_slice(),
    ] {
        assert_eq!(refuse(bad_chain, key), CryptoError::InvalidCertificate);
    }
    let eleven = chain.repeat(6);
    assert_eq!(refuse(&eleven, key), CryptoError::InvalidCertificate);
    assert_eq!(
        refuse(&vec![b' '; 64 * 1024 + 1], key),
        CryptoError::InputTooLarge
    );
    assert_eq!(
        refuse(chain, &vec![b' '; 16 * 1024 + 1]),
        CryptoError::InputTooLarge
    );
    assert_eq!(
        TlsCertifiedKey::from_der(Vec::new(), secret(fixture!("p256.key.der"))).unwrap_err(),
        CryptoError::InvalidCertificate
    );
    assert_eq!(
        TlsCertifiedKey::from_der(
            vec![vec![0; 64 * 1024 + 1]],
            secret(fixture!("p256.key.der"))
        )
        .unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn store_refuses_names_the_certificate_does_not_cover() {
    let store = TlsCertificateStore::new(None);
    for name in [
        "other.example.test",
        "example.test",
        "*.example.test",
        "192.0.2.1",
        "",
        "mail.example.test.",
        "*.test",
        "bad name",
    ] {
        assert_eq!(
            store.insert(name, p256()).unwrap_err(),
            CryptoError::InvalidCertificate,
            "{name}"
        );
    }
    let wildcard = || key(fixture!("wildcard.chain.pem"), fixture!("wildcard.key.pem"));
    assert_eq!(
        store.insert("*.example.test", wildcard()).unwrap_err(),
        CryptoError::InvalidCertificate
    );
    store.insert("imap.wild.example.test", wildcard()).unwrap();
    store.insert("*.WILD.example.test", wildcard()).unwrap();
    assert_eq!(
        format!("{store:?}"),
        "TlsCertificateStore { names: 2, default: false }"
    );
}

#[test]
fn tokio_rustls_acceptor_end_to_end() {
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    let runtime = tokio::runtime::Builder::new_current_thread()
        .build()
        .unwrap();
    runtime.block_on(async {
        let options = TlsServerOptions {
            alpn_protocols: vec![b"imap".to_vec()],
            ..TlsServerOptions::default()
        };
        let server = tls_server_config(TlsCertificateStore::new(Some(p256())), &options).unwrap();
        let acceptor = tokio_rustls::TlsAcceptor::from(server);
        let connector =
            tokio_rustls::TlsConnector::from(Arc::new(client(rustls::ALL_VERSIONS, &[b"imap"])));
        let (client_io, server_io) = tokio::io::duplex(64 * 1024);
        let server_task = async move {
            let mut stream = acceptor.accept(server_io).await.unwrap();
            let mut request = [0u8; 4];
            stream.read_exact(&mut request).await.unwrap();
            stream.write_all(b"* OK ").await.unwrap();
            stream.write_all(&request).await.unwrap();
            stream.shutdown().await.unwrap();
        };
        let client_task = async move {
            let name = ServerName::try_from("mail.example.test").unwrap();
            let mut stream = connector.connect(name, client_io).await.unwrap();
            assert_eq!(stream.get_ref().1.alpn_protocol(), Some(b"imap".as_slice()));
            stream.write_all(b"ping").await.unwrap();
            let mut answer = Vec::new();
            stream.read_to_end(&mut answer).await.unwrap();
            answer
        };
        let ((), answer) = tokio::join!(server_task, client_task);
        assert_eq!(answer, b"* OK ping");
    });
}
