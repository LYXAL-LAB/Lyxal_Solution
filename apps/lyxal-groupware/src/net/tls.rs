/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * Porté de Stalwart, `crates/common/src/network/mod.rs` (`TcpAcceptor::Tls`, poignée de main
 * sous délai, mise à niveau `SessionResult::UpgradeTls`), commit 3adead9, licence
 * `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL-3.0-only retenue. Modifié pour Lyxal OS :
 * configuration `rustls` construite par `lyxal_crypto::tls_server_config` seulement (règle 10 du
 * §11.3), une par écoute sur le magasin de certificats partagé ; ALPN du protocole de l'écoute ;
 * mise à niveau STARTTLS offerte aux sessions par le trait `lyxal_mail::net::TlsUpgrade`.
 */

//! TLS des écoutes : poignée de main implicite (RFC 8314) et mise à niveau STARTTLS (RFC 3207 et
//! équivalents), sous délai.

use crate::config::TlsMinVersion;
use crate::error::GroupwareError;
use async_trait::async_trait;
use lyxal_crypto::rustls::ServerConnection;
use lyxal_crypto::{tls_server_config, TlsCertificateStore, TlsServerOptions};
use lyxal_mail::net::{BoxedStream, MailProtocol, NetError, TlsInfo};
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncRead, AsyncWrite};
use tokio_rustls::server::TlsStream;
use tokio_rustls::TlsAcceptor;

/// Nom ALPN du protocole (registre de l'IANA « TLS Application-Layer Protocol Negotiation
/// Protocol IDs ») : un client qui annonce d'autres noms est refusé par une alerte TLS, ce qui
/// empêche de faire passer une connexion d'un protocole vers un autre (attaques « ALPACA »).
/// SMTP et la soumission n'ont pas de nom enregistré : aucun ALPN annoncé.
pub fn alpn(protocol: MailProtocol) -> Option<&'static [u8]> {
    match protocol {
        MailProtocol::Imap => Some(b"imap"),
        MailProtocol::Pop3 => Some(b"pop3"),
        MailProtocol::ManageSieve => Some(b"managesieve"),
        MailProtocol::Smtp | MailProtocol::Submission => None,
    }
}

/// TLS d'une écoute : accepteur sur la configuration de l'écoute, délai de la poignée de main.
#[derive(Clone)]
pub struct ListenerTls {
    acceptor: TlsAcceptor,
    handshake_timeout: Duration,
}

impl ListenerTls {
    /// Configuration `rustls` de l'écoute `label` (par `lyxal_crypto`), sur le magasin partagé
    /// `store`, avec les noms ALPN `alpn`.
    pub fn new(
        store: Arc<TlsCertificateStore>,
        label: &str,
        alpn: &[&[u8]],
        min_version: TlsMinVersion,
        handshake_timeout: Duration,
    ) -> Result<Self, GroupwareError> {
        let options = TlsServerOptions {
            min_version: match min_version {
                TlsMinVersion::Tls12 => lyxal_crypto::TlsMinVersion::Tls12,
                TlsMinVersion::Tls13 => lyxal_crypto::TlsMinVersion::Tls13,
            },
            alpn_protocols: alpn.iter().map(|name| name.to_vec()).collect(),
            ..TlsServerOptions::default()
        };
        let config =
            tls_server_config(store, &options).map_err(|error| GroupwareError::Configuration {
                message: format!("configuration TLS de l'écoute {label} : {error}"),
            })?;
        Ok(Self {
            acceptor: TlsAcceptor::from(config),
            handshake_timeout,
        })
    }

    /// Poignée de main côté serveur sur `stream`, sous délai.
    pub async fn accept<S>(&self, stream: S) -> Result<(TlsStream<S>, TlsInfo), NetError>
    where
        S: AsyncRead + AsyncWrite + Unpin,
    {
        let tls = tokio::time::timeout(self.handshake_timeout, self.acceptor.accept(stream))
            .await
            .map_err(|_| NetError::Timeout)?
            .map_err(|error| NetError::TlsHandshake(error.to_string()))?;
        let info = tls_info(tls.get_ref().1);
        Ok((tls, info))
    }
}

/// Paramètres négociés d'une connexion.
fn tls_info(connection: &ServerConnection) -> TlsInfo {
    TlsInfo {
        version: connection
            .protocol_version()
            .and_then(|version| version.as_str())
            .unwrap_or("unknown"),
        cipher: connection
            .negotiated_cipher_suite()
            .and_then(|suite| suite.suite().as_str())
            .unwrap_or("unknown"),
        server_name: connection.server_name().map(str::to_owned),
        alpn: connection.alpn_protocol().map(<[u8]>::to_vec),
    }
}

/// Mise à niveau STARTTLS offerte aux sessions d'une écoute `starttls` : même accepteur et même
/// délai que la poignée de main implicite. La garde contre l'injection de commandes en clair est
/// dans `Session::start_tls` (toute entrée déjà lue refusée avant d'arriver ici).
pub struct HostTlsUpgrade {
    tls: ListenerTls,
    on_failure: Box<dyn Fn(&NetError) + Send + Sync>,
}

impl HostTlsUpgrade {
    /// Mise à niveau par `tls` ; `on_failure` compte et journalise une poignée de main en échec.
    pub fn new(tls: ListenerTls, on_failure: Box<dyn Fn(&NetError) + Send + Sync>) -> Self {
        Self { tls, on_failure }
    }
}

#[async_trait]
impl lyxal_mail::net::TlsUpgrade for HostTlsUpgrade {
    async fn upgrade(&self, stream: BoxedStream) -> Result<(BoxedStream, TlsInfo), NetError> {
        match self.tls.accept(stream).await {
            Ok((tls, info)) => Ok((Box::new(tls), info)),
            Err(error) => {
                (self.on_failure)(&error);
                Err(error)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::alpn;
    use lyxal_mail::net::MailProtocol;

    #[test]
    fn alpn_names_are_the_registered_ones() {
        assert_eq!(alpn(MailProtocol::Imap), Some(&b"imap"[..]));
        assert_eq!(alpn(MailProtocol::Pop3), Some(&b"pop3"[..]));
        assert_eq!(alpn(MailProtocol::ManageSieve), Some(&b"managesieve"[..]));
        assert_eq!(alpn(MailProtocol::Smtp), None);
        assert_eq!(alpn(MailProtocol::Submission), None);
    }
}
