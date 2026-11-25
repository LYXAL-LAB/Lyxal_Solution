// SPDX-License-Identifier: AGPL-3.0-only

//! Nom inverse confirmé (`iprev`, RFC 8601 §3), écrit depuis la RFC ; résultat informatif
//! seulement, jamais un motif de refus (décision S6). Cas d'essai inspirés de Mox
//! (`iprev/iprev_test.go`, MIT).

use crate::dns::{DnsError, MailResolver};
use std::net::IpAddr;

/// Nombre maximal de noms inverses confirmés par une requête A ou AAAA.
const MAX_PTR_NAMES: usize = 10;

/// Résultat `iprev` (RFC 8601 §2.7.3).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum IprevResult {
    /// Un nom inverse résout vers l'adresse.
    Pass,
    /// Aucun nom inverse ne résout vers l'adresse.
    Fail,
    /// Panne du DNS.
    TempError,
    /// Aucun nom inverse publié.
    PermError,
}

impl IprevResult {
    /// Mot du résultat.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Pass => "pass",
            Self::Fail => "fail",
            Self::TempError => "temperror",
            Self::PermError => "permerror",
        }
    }
}

/// Résultat du contrôle du nom inverse.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IprevOutput {
    /// Résultat.
    pub result: IprevResult,
    /// Adresse contrôlée (`policy.iprev`).
    pub ip: IpAddr,
    /// Nom confirmé (pour le champ `Received`), si `pass`.
    pub name: Option<String>,
}

/// Contrôle du nom inverse.
pub struct Iprev<'a> {
    resolver: &'a dyn MailResolver,
}

impl<'a> Iprev<'a> {
    /// Contrôle sur un résolveur.
    pub fn new(resolver: &'a dyn MailResolver) -> Self {
        Self { resolver }
    }

    /// PTR de l'adresse, puis A ou AAAA de chaque nom (10 au plus).
    pub async fn check(&self, ip: IpAddr) -> IprevOutput {
        let ip = ip.to_canonical();
        let output = |result, name| IprevOutput { result, ip, name };
        let names = match self.resolver.ptr(ip).await {
            Ok(answer) => answer.records,
            Err(DnsError::NotFound | DnsError::NoRecords | DnsError::InvalidName) => {
                return output(IprevResult::PermError, None)
            }
            Err(DnsError::Temporary | DnsError::Refused) => {
                return output(IprevResult::TempError, None)
            }
        };
        let mut temporary = false;
        for name in names.iter().take(MAX_PTR_NAMES) {
            match self.resolver.ips_like(name, ip).await {
                Ok(answer) if answer.records.contains(&ip) => {
                    return output(IprevResult::Pass, Some(name.clone()))
                }
                Ok(_) => {}
                Err(error) if error.is_temporary() => temporary = true,
                Err(_) => {}
            }
        }
        if temporary {
            output(IprevResult::TempError, None)
        } else {
            output(IprevResult::Fail, None)
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;
    use crate::dns::{StaticRecordType, StaticResolver};

    fn ip(text: &str) -> IpAddr {
        text.parse().unwrap()
    }

    #[tokio::test]
    async fn resultats() {
        let mut resolver = StaticResolver::new();
        resolver
            .set_ptr(ip("10.0.0.1"), &["basic.example"])
            .set_ips("basic.example", &[ip("10.0.0.1")])
            .set_ptr(ip("10.0.0.2"), &["other.example", "second.example"])
            .set_ips("second.example", &[ip("10.0.0.2")])
            .set_ptr(ip("10.0.0.3"), &["mismatch.example"])
            .set_ips("mismatch.example", &[ip("10.9.9.9")])
            .set_ptr(ip("10.0.0.5"), &["panne.example"])
            .fail(StaticRecordType::A, "panne.example")
            .fail(StaticRecordType::Ptr, "10.0.0.6")
            .set_ptr(ip("2001:db8::1"), &["v6.example"])
            .set_ips("v6.example", &[ip("2001:db8::1")]);
        let iprev = Iprev::new(&resolver);
        let check = |text: &'static str| {
            let iprev = &iprev;
            async move { iprev.check(ip(text)).await }
        };
        let pass = check("10.0.0.1").await;
        assert_eq!(pass.result, IprevResult::Pass);
        assert_eq!(pass.name.as_deref(), Some("basic.example"));
        assert_eq!(
            check("10.0.0.2").await.name.as_deref(),
            Some("second.example")
        );
        assert_eq!(check("10.0.0.3").await.result, IprevResult::Fail);
        assert_eq!(check("10.0.0.4").await.result, IprevResult::PermError);
        assert_eq!(check("10.0.0.5").await.result, IprevResult::TempError);
        assert_eq!(check("10.0.0.6").await.result, IprevResult::TempError);
        assert_eq!(check("2001:db8::1").await.result, IprevResult::Pass);
        assert_eq!(check("::ffff:10.0.0.1").await.result, IprevResult::Pass);
    }
}
