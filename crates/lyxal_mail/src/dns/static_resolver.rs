// SPDX-License-Identifier: AGPL-3.0-only

//! [`StaticResolver`] : résolveur des essais (table de réponses, pannes et délais simulés).
//! Sur le modèle du `MockResolver` de Mox (`dns/mock.go`, MIT : tables de réponses par type et
//! pannes par type et nom). Ajouts de Lyxal : un nom présent dans une table pour un autre type
//! répond « aucun enregistrement », un nom absent de toutes les tables « n'existe pas » ; délais
//! simulés ; compte des requêtes.

use super::{normalize_name, Answer, DnsError, DnsResult, MailResolver, MxRecord};
use async_trait::async_trait;
use std::collections::{HashMap, HashSet};
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;

/// Type d'enregistrement d'une panne simulée.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum StaticRecordType {
    /// TXT.
    Txt,
    /// MX.
    Mx,
    /// A.
    A,
    /// AAAA.
    Aaaa,
    /// PTR (nom : l'adresse écrite en texte).
    Ptr,
}

/// Résolveur à réponses fixées, pour les essais : aucune requête réseau.
#[derive(Debug, Default)]
pub struct StaticResolver {
    txt: HashMap<String, Vec<String>>,
    mx: HashMap<String, Vec<MxRecord>>,
    a: HashMap<String, Vec<Ipv4Addr>>,
    aaaa: HashMap<String, Vec<Ipv6Addr>>,
    ptr: HashMap<IpAddr, Vec<String>>,
    failures: HashSet<(StaticRecordType, String)>,
    delay: Option<Duration>,
    queries: AtomicUsize,
}

fn key(name: &str) -> String {
    normalize_name(name).unwrap_or_default()
}

impl StaticResolver {
    /// Résolveur vide : tout nom « n'existe pas ».
    pub fn new() -> Self {
        Self::default()
    }

    /// Enregistrements TXT d'un nom (remplace les précédents).
    pub fn set_txt(&mut self, name: &str, records: &[&str]) -> &mut Self {
        self.txt.insert(
            key(name),
            records.iter().map(|record| (*record).to_string()).collect(),
        );
        self
    }

    /// Enregistrements MX d'un nom : `(préférence, échangeur)`.
    pub fn set_mx(&mut self, name: &str, records: &[(u16, &str)]) -> &mut Self {
        self.mx.insert(
            key(name),
            records
                .iter()
                .map(|(preference, exchange)| MxRecord {
                    preference: *preference,
                    exchange: key(exchange),
                })
                .collect(),
        );
        self
    }

    /// Adresses d'un nom (A ou AAAA selon la famille de chaque adresse).
    pub fn set_ips(&mut self, name: &str, ips: &[IpAddr]) -> &mut Self {
        let name = key(name);
        let v4: Vec<Ipv4Addr> = ips
            .iter()
            .filter_map(|ip| match ip {
                IpAddr::V4(v4) => Some(*v4),
                IpAddr::V6(_) => None,
            })
            .collect();
        let v6: Vec<Ipv6Addr> = ips
            .iter()
            .filter_map(|ip| match ip {
                IpAddr::V6(v6) => Some(*v6),
                IpAddr::V4(_) => None,
            })
            .collect();
        if !v4.is_empty() {
            self.a.insert(name.clone(), v4);
        }
        if !v6.is_empty() {
            self.aaaa.insert(name, v6);
        }
        self
    }

    /// Noms inverses d'une adresse.
    pub fn set_ptr(&mut self, ip: IpAddr, names: &[&str]) -> &mut Self {
        self.ptr.insert(
            ip.to_canonical(),
            names.iter().map(|name| key(name)).collect(),
        );
        self
    }

    /// Panne simulée (`Temporary`) pour ce type et ce nom (pour `Ptr`, l'adresse en texte).
    pub fn fail(&mut self, record_type: StaticRecordType, name: &str) -> &mut Self {
        self.failures.insert((record_type, key(name)));
        self
    }

    /// Délai ajouté à chaque requête.
    pub fn set_delay(&mut self, delay: Duration) -> &mut Self {
        self.delay = Some(delay);
        self
    }

    /// Nombre de requêtes reçues depuis la création.
    pub fn queries(&self) -> usize {
        self.queries.load(Ordering::Relaxed)
    }

    fn known(&self, name: &str) -> bool {
        self.txt.contains_key(name)
            || self.mx.contains_key(name)
            || self.a.contains_key(name)
            || self.aaaa.contains_key(name)
    }

    async fn answer<T: Clone>(
        &self,
        record_type: StaticRecordType,
        name: &str,
        table: &HashMap<String, Vec<T>>,
    ) -> DnsResult<T> {
        self.queries.fetch_add(1, Ordering::Relaxed);
        if let Some(delay) = self.delay {
            tokio::time::sleep(delay).await;
        }
        let name = normalize_name(name).ok_or(DnsError::InvalidName)?;
        if self.failures.contains(&(record_type, name.clone())) {
            return Err(DnsError::Temporary);
        }
        match table.get(&name) {
            Some(records) if !records.is_empty() => Ok(Answer {
                records: records.clone(),
            }),
            _ if self.known(&name) => Err(DnsError::NoRecords),
            _ => Err(DnsError::NotFound),
        }
    }
}

#[async_trait]
impl MailResolver for StaticResolver {
    async fn txt(&self, name: &str) -> DnsResult<String> {
        self.answer(StaticRecordType::Txt, name, &self.txt).await
    }

    async fn mx(&self, name: &str) -> DnsResult<MxRecord> {
        self.answer(StaticRecordType::Mx, name, &self.mx).await
    }

    async fn ipv4(&self, name: &str) -> DnsResult<Ipv4Addr> {
        self.answer(StaticRecordType::A, name, &self.a).await
    }

    async fn ipv6(&self, name: &str) -> DnsResult<Ipv6Addr> {
        self.answer(StaticRecordType::Aaaa, name, &self.aaaa).await
    }

    async fn ptr(&self, ip: IpAddr) -> DnsResult<String> {
        self.queries.fetch_add(1, Ordering::Relaxed);
        if let Some(delay) = self.delay {
            tokio::time::sleep(delay).await;
        }
        let ip = ip.to_canonical();
        if self
            .failures
            .contains(&(StaticRecordType::Ptr, ip.to_string()))
        {
            return Err(DnsError::Temporary);
        }
        match self.ptr.get(&ip) {
            Some(names) if !names.is_empty() => Ok(Answer {
                records: names.clone(),
            }),
            _ => Err(DnsError::NotFound),
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn absence_et_panne() {
        let mut resolver = StaticResolver::new();
        resolver
            .set_txt("Example.com.", &["v=spf1 -all"])
            .set_ips("example.com", &["192.0.2.1".parse().unwrap()])
            .fail(StaticRecordType::Txt, "panne.example");
        assert_eq!(
            resolver.txt("example.com").await.unwrap().records,
            vec!["v=spf1 -all".to_string()]
        );
        assert_eq!(resolver.mx("example.com").await, Err(DnsError::NoRecords));
        assert_eq!(resolver.ipv6("example.com").await, Err(DnsError::NoRecords));
        assert_eq!(
            resolver.txt("absent.example").await,
            Err(DnsError::NotFound)
        );
        assert_eq!(
            resolver.txt("panne.example").await,
            Err(DnsError::Temporary)
        );
        assert_eq!(
            resolver
                .ips_like("example.com", "10.0.0.1".parse().unwrap())
                .await
                .unwrap()
                .records,
            vec!["192.0.2.1".parse::<IpAddr>().unwrap()]
        );
        assert_eq!(resolver.queries(), 6);
    }
}
