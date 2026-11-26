// SPDX-License-Identifier: AGPL-3.0-only

//! Liste de blocage partagée et bannissement automatique (plan du lot 5, §7.6, décision S18).
//!
//! La table `mail_network_block` est à l'échelle de l'installation : chaque nœud la lit
//! (`fn::mail_block_active`) au démarrage puis toutes les 30 s ([`BlockRefreshWorker`]) et
//! l'hôte refuse à l'acceptation tout client d'un réseau bloqué (`421 4.7.0`, sans dialogue).
//! Une adresse qui finit trois sessions en 10 minutes pour trop d'erreurs, recherche d'adresses
//! ou contrebande SMTP est bannie (`/32` ou `/64`) : l'entrée est écrite en base (durée
//! calculée par `fn::mail_block_create` : 1 h doublée à chaque récidive, 24 h au plus) et
//! ajoutée aussitôt à la liste du nœud. Les compteurs de récidive sont propres au nœud ; seuls
//! les bannissements sont partagés, par la base.
//!
//! Écrit pour Lyxal OS.

use async_trait::async_trait;
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerRestartBackoff,
};
use lyxal_runtime::{ModuleId, RuntimeError};
use std::collections::{HashMap, VecDeque};
use std::fmt;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::str::FromStr;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex, PoisonError, RwLock};
use std::time::{Duration, Instant};

use crate::models::{BlockActiveParams, BlockCreateParams, BlockReason};
use crate::store::MailStore;
use crate::MODULE_ID;

/// Intervalle de relecture de la liste de blocage par chaque nœud.
pub const BLOCK_REFRESH_INTERVAL: Duration = Duration::from_secs(30);
/// Sessions fautives d'une adresse au-delà desquelles elle est bannie.
pub const BAN_OFFENCES: usize = 3;
/// Fenêtre où les sessions fautives d'une adresse sont comptées.
pub const BAN_WINDOW: Duration = Duration::from_secs(600);
/// Adresses suivies au plus par le compteur de récidive (au-delà : les plus anciennes oubliées).
const MAX_TRACKED_OFFENDERS: usize = 100_000;

/// Plage d'adresses (`adresse/longueur`), ramenée à son réseau.
#[derive(Clone, Copy, PartialEq, Eq, Hash)]
pub struct Network {
    address: IpAddr,
    prefix: u8,
}

/// Plage illisible.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
#[error("plage d'adresses illisible")]
pub struct NetworkParseError;

impl Network {
    /// Réseau de longueur `prefix` qui contient `ip` (adresse IPv4 dans IPv6 ramenée à IPv4).
    pub fn of(ip: IpAddr, prefix: u8) -> Self {
        let ip = canonical(ip);
        let prefix = prefix.min(max_prefix(ip));
        Self {
            address: mask(ip, prefix),
            prefix,
        }
    }

    /// Réseau banni pour une adresse : `/32` (IPv4) ou `/64` (IPv6).
    pub fn ban_of(ip: IpAddr) -> Self {
        match canonical(ip) {
            ip @ IpAddr::V4(_) => Self::of(ip, 32),
            ip @ IpAddr::V6(_) => Self::of(ip, 64),
        }
    }

    /// Réseau masqué d'une adresse pour le journal (`/24`, `/48`) : aucune adresse complète.
    pub fn masked(ip: IpAddr) -> Self {
        match canonical(ip) {
            ip @ IpAddr::V4(_) => Self::of(ip, 24),
            ip @ IpAddr::V6(_) => Self::of(ip, 48),
        }
    }

    /// Vrai si `ip` appartient au réseau.
    pub fn contains(&self, ip: IpAddr) -> bool {
        let ip = canonical(ip);
        match (self.address, ip) {
            (IpAddr::V4(_), IpAddr::V4(_)) | (IpAddr::V6(_), IpAddr::V6(_)) => {
                mask(ip, self.prefix) == self.address
            }
            _ => false,
        }
    }
}

impl fmt::Display for Network {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}/{}", self.address, self.prefix)
    }
}

impl fmt::Debug for Network {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Display::fmt(self, f)
    }
}

impl FromStr for Network {
    type Err = NetworkParseError;

    /// `adresse/longueur`, ou une adresse seule (réseau d'une adresse).
    fn from_str(text: &str) -> Result<Self, Self::Err> {
        let (address, prefix) = match text.split_once('/') {
            Some((address, prefix)) => (address, Some(prefix)),
            None => (text, None),
        };
        let address: IpAddr = address.trim().parse().map_err(|_| NetworkParseError)?;
        let address = canonical(address);
        let max = max_prefix(address);
        let prefix = match prefix {
            Some(prefix) => prefix
                .trim()
                .parse::<u8>()
                .ok()
                .filter(|prefix| *prefix <= max)
                .ok_or(NetworkParseError)?,
            None => max,
        };
        Ok(Self::of(address, prefix))
    }
}

fn canonical(ip: IpAddr) -> IpAddr {
    match ip {
        IpAddr::V6(v6) => v6.to_ipv4_mapped().map_or(IpAddr::V6(v6), IpAddr::V4),
        other => other,
    }
}

fn max_prefix(ip: IpAddr) -> u8 {
    match ip {
        IpAddr::V4(_) => 32,
        IpAddr::V6(_) => 128,
    }
}

fn mask(ip: IpAddr, prefix: u8) -> IpAddr {
    match ip {
        IpAddr::V4(v4) => {
            let bits = u32::from(v4);
            let kept = u32::MAX.checked_shl(32 - u32::from(prefix)).unwrap_or(0);
            IpAddr::V4(Ipv4Addr::from(bits & kept))
        }
        IpAddr::V6(v6) => {
            let bits = u128::from(v6);
            let kept = u128::MAX.checked_shl(128 - u32::from(prefix)).unwrap_or(0);
            IpAddr::V6(Ipv6Addr::from(bits & kept))
        }
    }
}

/// Motif d'une session fautive, compté pour le bannissement.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Offence {
    /// Session fermée pour trop d'erreurs (`max_errors`).
    Errors,
    /// Recherche d'adresses (20 destinataires refusés).
    Harvest,
    /// Contrebande SMTP (fins de ligne isolées).
    Smuggling,
}

impl Offence {
    fn reason(self) -> BlockReason {
        match self {
            Self::Errors => BlockReason::Errors,
            Self::Harvest => BlockReason::Harvest,
            Self::Smuggling => BlockReason::Smuggling,
        }
    }

    /// Nom du motif (journal, mesures).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Errors => "errors",
            Self::Harvest => "harvest",
            Self::Smuggling => "smuggling",
        }
    }
}

#[derive(Default)]
struct Offenders {
    by_ip: HashMap<IpAddr, VecDeque<Instant>>,
}

/// Liste de blocage du nœud : réseaux en vigueur (relus en base) et compteurs de récidive.
/// Clonable : les clones partagent la liste.
#[derive(Clone, Default)]
pub struct BlockList {
    inner: Arc<BlockInner>,
}

#[derive(Default)]
struct BlockInner {
    networks: RwLock<Vec<Network>>,
    offenders: Mutex<Offenders>,
    bans: AtomicU64,
    refresh_failures: AtomicU64,
}

impl BlockList {
    /// Liste vide.
    pub fn new() -> Self {
        Self::default()
    }

    /// Vrai si `ip` appartient à un réseau bloqué.
    pub fn contains(&self, ip: IpAddr) -> bool {
        self.inner
            .networks
            .read()
            .unwrap_or_else(PoisonError::into_inner)
            .iter()
            .any(|network| network.contains(ip))
    }

    /// Réseaux bloqués en vigueur sur ce nœud.
    pub fn len(&self) -> usize {
        self.inner
            .networks
            .read()
            .unwrap_or_else(PoisonError::into_inner)
            .len()
    }

    /// Vrai si aucun réseau n'est bloqué.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Bannissements écrits par ce nœud depuis son démarrage.
    pub fn bans(&self) -> u64 {
        self.inner.bans.load(Ordering::Relaxed)
    }

    /// Relectures de la liste en échec depuis le démarrage.
    pub fn refresh_failures(&self) -> u64 {
        self.inner.refresh_failures.load(Ordering::Relaxed)
    }

    /// Remplace la liste par les réseaux lus en base ; une entrée illisible est ignorée et
    /// journalisée (la base valide déjà chaque plage).
    pub fn replace<I: IntoIterator<Item = S>, S: AsRef<str>>(&self, networks: I) {
        let parsed: Vec<Network> = networks
            .into_iter()
            .filter_map(|text| match text.as_ref().parse::<Network>() {
                Ok(network) => Some(network),
                Err(_) => {
                    tracing::warn!("liste de blocage : plage illisible ignorée");
                    None
                }
            })
            .collect();
        *self
            .inner
            .networks
            .write()
            .unwrap_or_else(PoisonError::into_inner) = parsed;
    }

    fn insert(&self, network: Network) {
        let mut networks = self
            .inner
            .networks
            .write()
            .unwrap_or_else(PoisonError::into_inner);
        if !networks.contains(&network) {
            networks.push(network);
        }
    }

    /// Compte une session fautive de `ip` à l'instant `now` ; rend le réseau à bannir quand
    /// l'adresse atteint [`BAN_OFFENCES`] sessions fautives en [`BAN_WINDOW`] (ses compteurs
    /// sont alors remis à zéro).
    pub fn offence_at(&self, ip: IpAddr, now: Instant) -> Option<Network> {
        let ip = canonical(ip);
        let mut offenders = self
            .inner
            .offenders
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if offenders.by_ip.len() >= MAX_TRACKED_OFFENDERS && !offenders.by_ip.contains_key(&ip) {
            offenders.by_ip.retain(|_, times| {
                times
                    .back()
                    .is_some_and(|last| now.duration_since(*last) < BAN_WINDOW)
            });
            if offenders.by_ip.len() >= MAX_TRACKED_OFFENDERS {
                offenders.by_ip.clear();
            }
        }
        let times = offenders.by_ip.entry(ip).or_default();
        while times
            .front()
            .is_some_and(|first| now.duration_since(*first) >= BAN_WINDOW)
        {
            times.pop_front();
        }
        times.push_back(now);
        if times.len() >= BAN_OFFENCES {
            offenders.by_ip.remove(&ip);
            return Some(Network::ban_of(ip));
        }
        None
    }

    /// Compte une session fautive et, à la troisième en 10 minutes, bannit l'adresse : entrée
    /// écrite en base par `store` (session système ou compte de service, `mail.worker`) puis
    /// ajoutée à la liste du nœud. Un refus de la base est journalisé ; le réseau est tout de
    /// même bloqué sur ce nœud jusqu'à la prochaine relecture.
    pub async fn record_offence(&self, store: &MailStore, ip: IpAddr, offence: Offence) {
        let Some(network) = self.offence_at(ip, Instant::now()) else {
            return;
        };
        self.insert(network);
        self.inner.bans.fetch_add(1, Ordering::Relaxed);
        let params = BlockCreateParams {
            network: network.to_string(),
            reason: Some(offence.reason()),
            expires_at: None,
        };
        match store.block_create(params).await {
            Ok(_) => tracing::info!(
                network = %Network::masked(ip),
                reason = offence.as_str(),
                "adresse bannie (liste de blocage de l'installation)"
            ),
            Err(error) => tracing::warn!(
                network = %Network::masked(ip),
                reason = offence.as_str(),
                %error,
                "bannissement non écrit en base : bloqué sur ce nœud seulement"
            ),
        }
    }

    /// Relit les réseaux en vigueur (`fn::mail_block_active`) ; en cas d'échec la liste du nœud
    /// est gardée, l'échec est compté et rendu.
    pub async fn refresh(&self, store: &MailStore) -> Result<usize, crate::MailError> {
        match store.block_active(BlockActiveParams::default()).await {
            Ok(active) => {
                let count = active.networks.len();
                self.replace(active.networks);
                Ok(count)
            }
            Err(error) => {
                self.inner.refresh_failures.fetch_add(1, Ordering::Relaxed);
                Err(error.into())
            }
        }
    }
}

/// Worker `lyxal_mail:mail.block_refresh` : relit la liste de blocage toutes les 30 s
/// (criticité `Optional` : un échec de lecture garde la dernière liste lue).
pub struct BlockRefreshWorker {
    descriptor: WorkerDescriptor,
    blocks: BlockList,
    store: MailStore,
    interval: Duration,
}

impl BlockRefreshWorker {
    /// Worker sur la session système de l'hôte (`store`).
    pub fn new(blocks: BlockList, store: MailStore) -> Result<Self, RuntimeError> {
        Self::with_interval(blocks, store, BLOCK_REFRESH_INTERVAL)
    }

    /// Worker à intervalle choisi (essais).
    pub fn with_interval(
        blocks: BlockList,
        store: MailStore,
        interval: Duration,
    ) -> Result<Self, RuntimeError> {
        let module = ModuleId::new(MODULE_ID);
        let name = "mail.block_refresh";
        let descriptor = WorkerDescriptor::new(WorkerId::new(&module, name)?, module, name)
            .with_description("Relecture de la liste de blocage du courrier (toutes les 30 s)")
            .with_criticality(WorkerCriticality::Optional)
            .with_restart_policy(RestartPolicy::OnFailure {
                max_retries: 5,
                backoff: WorkerRestartBackoff::default(),
            });
        Ok(Self {
            descriptor,
            blocks,
            store,
            interval,
        })
    }
}

#[async_trait]
impl LyxalWorker for BlockRefreshWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            match self.blocks.refresh(&self.store).await {
                Ok(count) => tracing::debug!(networks = count, "liste de blocage relue"),
                Err(error) => tracing::warn!(
                    code = %error.code(),
                    "liste de blocage illisible : dernière liste gardée"
                ),
            }
            tokio::select! {
                () = ctx.cancellation.cancelled() => break,
                () = tokio::time::sleep(self.interval) => {}
            }
        }
        Ok(())
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;

    fn ip(text: &str) -> IpAddr {
        text.parse().unwrap()
    }

    #[test]
    fn networks_are_parsed_masked_and_matched() {
        let network: Network = "192.0.2.7/24".parse().unwrap();
        assert_eq!(network.to_string(), "192.0.2.0/24");
        assert!(network.contains(ip("192.0.2.200")));
        assert!(network.contains(ip("::ffff:192.0.2.9")));
        assert!(!network.contains(ip("192.0.3.1")));
        assert!(!network.contains(ip("2001:db8::1")));
        let v6: Network = "2001:db8:1:2::5/48".parse().unwrap();
        assert_eq!(v6.to_string(), "2001:db8:1::/48");
        assert!(v6.contains(ip("2001:db8:1:ffff::1")));
        assert_eq!(
            "10.0.0.1".parse::<Network>().unwrap().to_string(),
            "10.0.0.1/32"
        );
        assert_eq!(
            "0.0.0.0/0".parse::<Network>().unwrap().to_string(),
            "0.0.0.0/0"
        );
        assert!("0.0.0.0/0"
            .parse::<Network>()
            .unwrap()
            .contains(ip("8.8.8.8")));
        for invalid in [
            "",
            "x",
            "10.0.0.1/33",
            "2001:db8::/129",
            "10.0.0.1/-1",
            "10.0.0/8",
        ] {
            assert!(invalid.parse::<Network>().is_err(), "{invalid}");
        }
        assert_eq!(Network::ban_of(ip("192.0.2.7")).to_string(), "192.0.2.7/32");
        assert_eq!(
            Network::ban_of(ip("2001:db8:1:2:3:4:5:6")).to_string(),
            "2001:db8:1:2::/64"
        );
        assert_eq!(Network::masked(ip("192.0.2.7")).to_string(), "192.0.2.0/24");
    }

    #[test]
    fn the_list_blocks_its_networks() {
        let blocks = BlockList::new();
        assert!(blocks.is_empty());
        blocks.replace(["198.51.100.0/24", "illisible", "2001:db8::/32"]);
        assert_eq!(blocks.len(), 2);
        assert!(blocks.contains(ip("198.51.100.9")));
        assert!(blocks.contains(ip("2001:db8:5::1")));
        assert!(!blocks.contains(ip("203.0.113.1")));
        blocks.replace(Vec::<String>::new());
        assert!(!blocks.contains(ip("198.51.100.9")));
    }

    #[test]
    fn three_offences_in_ten_minutes_ban_the_address() {
        let blocks = BlockList::new();
        let start = Instant::now();
        let client = ip("203.0.113.5");
        assert_eq!(blocks.offence_at(client, start), None);
        // Une récidive hors de la fenêtre ne compte plus la première
        assert_eq!(blocks.offence_at(client, start + BAN_WINDOW), None);
        let later = |seconds| start + BAN_WINDOW + Duration::from_secs(seconds);
        assert_eq!(blocks.offence_at(client, later(1)), None);
        assert_eq!(
            blocks.offence_at(client, later(2)),
            Some("203.0.113.5/32".parse().unwrap())
        );
        // Compteurs remis à zéro après le bannissement
        assert_eq!(blocks.offence_at(client, later(3)), None);
        // Une autre adresse a ses propres compteurs
        assert_eq!(blocks.offence_at(ip("203.0.113.6"), start), None);
    }
}
