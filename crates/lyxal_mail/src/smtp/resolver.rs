// SPDX-License-Identifier: AGPL-3.0-only

//! Résolveur compté : enveloppe le résolveur du nœud pour mesurer les requêtes DNS de la
//! réception SMTP et leurs pannes (plan du lot 5, §11.3). Le cache est celui du résolveur
//! enveloppé ; ses succès et échecs ne sont pas exposés par `hickory-resolver`.

use async_trait::async_trait;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::sync::Arc;

use super::metrics::SmtpMetrics;
use crate::dns::{DnsResult, MailResolver, MxRecord};

/// Résolveur qui compte ses requêtes et ses pannes.
pub(crate) struct CountingResolver {
    inner: Arc<dyn MailResolver>,
    metrics: Arc<SmtpMetrics>,
}

impl CountingResolver {
    pub(crate) fn new(inner: Arc<dyn MailResolver>, metrics: Arc<SmtpMetrics>) -> Self {
        Self { inner, metrics }
    }

    fn count<T>(&self, result: DnsResult<T>) -> DnsResult<T> {
        self.metrics
            .dns(matches!(&result, Err(error) if error.is_temporary()));
        result
    }
}

#[async_trait]
impl MailResolver for CountingResolver {
    async fn txt(&self, name: &str) -> DnsResult<String> {
        self.count(self.inner.txt(name).await)
    }

    async fn mx(&self, name: &str) -> DnsResult<MxRecord> {
        self.count(self.inner.mx(name).await)
    }

    async fn ipv4(&self, name: &str) -> DnsResult<Ipv4Addr> {
        self.count(self.inner.ipv4(name).await)
    }

    async fn ipv6(&self, name: &str) -> DnsResult<Ipv6Addr> {
        self.count(self.inner.ipv6(name).await)
    }

    async fn ptr(&self, ip: IpAddr) -> DnsResult<String> {
        self.count(self.inner.ptr(ip).await)
    }
}
