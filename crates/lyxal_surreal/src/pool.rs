//! Pool de connexions SurrealDB : plusieurs clients `Surreal<Any>` ouverts sous la même session,
//! distribués à tour de rôle.
//!
//! Un serveur SurrealDB ne répartit pas sur ses cœurs les requêtes d'une même connexion : le
//! débit d'un store qui n'a qu'un client reste celui d'une connexion, quel que soit le nombre
//! d'appels simultanés. Un store posé sur un pool rend à `call_fn` le client du tour suivant
//! (`LyxalSurrealCall::surreal_client`) ; ses appels simultanés passent alors par plusieurs
//! connexions, chacun dans sa transaction.
//!
//! Une connexion ne garantit aucun ordre entre des appels simultanés : ses requêtes
//! s'entrelacent, et deux transactions simultanées s'y heurtent déjà (conflit rejouable). Le
//! pool ne change donc pas ce que les appelants doivent supporter ; seuls deux appels dont le
//! premier est attendu avant de lancer le second se suivent, sur une connexion comme sur
//! plusieurs.
//!
//! Le pool ne porte aucune logique métier et ne rejoue rien : un appel en échec rend son erreur.

use std::num::NonZeroUsize;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;

use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;
use tokio::task::JoinSet;

use crate::client::{create_surreal_client, is_embedded_endpoint, SurrealConnectOptions};
use crate::error::LyxalSurrealError;

/// Clients `Surreal<Any>` d'une même session (mêmes identifiants, même espace de noms, même
/// base), distribués à tour de rôle.
///
/// Une copie du pool (`Clone`) partage les mêmes clients et le même tour. Un client rendu par
/// le pool ne doit recevoir aucun changement d'état de session (`authenticate`, `invalidate`,
/// `signin`, `use_ns`, `use_db`, `set`) : tous les clients doivent rester dans le même état.
/// Pour une session d'utilisateur, cloner le client fixe (`fixed().clone()` ouvre une session
/// à part sur la même connexion) et authentifier la copie.
#[derive(Clone)]
pub struct SurrealPool {
    shared: Arc<Shared>,
}

/// Clients et tour partagés par les copies d'un pool.
struct Shared {
    /// Premier client : la connexion fixe du pool.
    first: Surreal<Any>,
    /// Clients suivants ; vide pour un pool d'un seul client.
    others: Vec<Surreal<Any>>,
    /// Appels déjà distribués.
    turn: AtomicUsize,
}

/// Résultat de la sonde des clients d'un pool (`SurrealPool::probe`).
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PoolProbe {
    /// Clients du pool.
    pub clients: usize,
    /// Clients qui ont répondu dans le délai.
    pub responding: usize,
    /// Première erreur relevée (diagnostic pour le journal, jamais rendu à un client).
    pub error: Option<String>,
}

impl PoolProbe {
    /// Vrai si un client au moins répond : la base est joignable.
    pub fn reachable(&self) -> bool {
        self.responding > 0
    }

    /// Vrai si tous les clients répondent.
    pub fn complete(&self) -> bool {
        self.responding == self.clients
    }
}

/// Réponse attendue de la requête de sonde.
#[derive(SurrealValue)]
struct ProbeAnswer {
    ok: bool,
}

impl SurrealPool {
    /// Ouvre `connections` clients par `create_surreal_client` (schéma d'URL, identifiants
    /// Root, délai, espace de noms et base), l'un après l'autre. La première ouverture en échec
    /// arrête tout : les clients déjà ouverts sont fermés et l'erreur est rendue.
    ///
    /// Base embarquée (`mem://`, `memory`) : un seul client, quel que soit `connections`. Le
    /// moteur embarqué n'a pas de connexion, et chaque ouverture y créerait une base distincte.
    pub async fn connect(
        options: &SurrealConnectOptions,
        connections: NonZeroUsize,
    ) -> Result<Self, LyxalSurrealError> {
        let first = create_surreal_client(options).await?;
        let extra = if is_embedded_endpoint(&options.endpoint) {
            0
        } else {
            connections.get() - 1
        };
        let mut others = Vec::with_capacity(extra);
        for _ in 0..extra {
            others.push(create_surreal_client(options).await?);
        }
        Ok(Self::of(first, others))
    }

    fn of(first: Surreal<Any>, others: Vec<Surreal<Any>>) -> Self {
        Self {
            shared: Arc::new(Shared {
                first,
                others,
                turn: AtomicUsize::new(0),
            }),
        }
    }

    /// Client du tour suivant. Deux appels successifs rendent deux clients différents dès que
    /// le pool en a plusieurs : ne jamais enchaîner sur ce client deux requêtes qui doivent
    /// passer par la même connexion (requête `LIVE`, puis sa vérification) ; prendre `fixed`.
    pub fn client(&self) -> &Surreal<Any> {
        let index = self.shared.turn.fetch_add(1, Ordering::Relaxed) % self.size();
        match index
            .checked_sub(1)
            .and_then(|other| self.shared.others.get(other))
        {
            Some(client) => client,
            None => &self.shared.first,
        }
    }

    /// Connexion fixe du pool : toujours le même client. Pour ce qui tient à une connexion
    /// (requête `LIVE`, session d'utilisateur clonée puis authentifiée) ou n'a pas à être
    /// réparti (installation, moteur du runtime).
    pub fn fixed(&self) -> &Surreal<Any> {
        &self.shared.first
    }

    /// Tous les clients du pool, la connexion fixe en premier.
    pub fn clients(&self) -> impl Iterator<Item = &Surreal<Any>> {
        std::iter::once(self.fixed()).chain(self.shared.others.iter())
    }

    /// Sonde : chaque client doit répondre `{ ok: true }` à une requête triviale en moins de
    /// `within`. Les clients sont sondés en même temps : la sonde dure `within` au plus, quel
    /// que soit leur nombre. Aucune erreur n'est perdue : le compte des clients muets et la
    /// première erreur sont rendus.
    pub async fn probe(&self, within: Duration) -> PoolProbe {
        let mut probes = JoinSet::new();
        for index in 0..self.size() {
            let pool = self.clone();
            probes.spawn(async move { pool.probe_client(index, within).await });
        }
        let mut report = PoolProbe {
            clients: self.size(),
            responding: 0,
            error: None,
        };
        while let Some(joined) = probes.join_next().await {
            match joined {
                Ok(Ok(())) => report.responding += 1,
                Ok(Err(error)) => report.error = report.error.or(Some(error)),
                Err(error) => report.error = report.error.or(Some(error.to_string())),
            }
        }
        report
    }

    async fn probe_client(&self, index: usize, within: Duration) -> Result<(), String> {
        let Some(client) = self.clients().nth(index) else {
            return Err(format!("client {index} absent du pool"));
        };
        let attempt = async {
            let mut response = client.query("RETURN { ok: true };").await?;
            response.take::<Option<ProbeAnswer>>(0)
        };
        match tokio::time::timeout(within, attempt).await {
            Ok(Ok(Some(ProbeAnswer { ok: true }))) => Ok(()),
            Ok(Ok(_)) => Err("la sonde SurrealDB n'a pas retourné le résultat attendu".into()),
            Ok(Err(error)) => Err(error.to_string()),
            Err(_) => Err(format!(
                "la sonde SurrealDB n'a pas répondu en {} ms",
                within.as_millis()
            )),
        }
    }

    /// Nombre de clients du pool (1 au moins).
    pub fn size(&self) -> usize {
        self.shared.others.len() + 1
    }
}

/// Pool d'un seul client : tous les appels passent par lui, dans l'ordre où le serveur les
/// reçoit. C'est la forme d'un store posé sur un client unique (session d'utilisateur, tests).
impl From<Surreal<Any>> for SurrealPool {
    fn from(client: Surreal<Any>) -> Self {
        Self::of(client, Vec::new())
    }
}

impl std::fmt::Debug for SurrealPool {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SurrealPool")
            .field("clients", &self.size())
            .finish()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn options(endpoint: &str) -> SurrealConnectOptions {
        SurrealConnectOptions {
            endpoint: endpoint.to_owned(),
            credentials: None,
            namespace: "test_ns".to_owned(),
            database: "test_db".to_owned(),
            connect_timeout: Duration::from_secs(5),
        }
    }

    fn connections(count: usize) -> NonZeroUsize {
        NonZeroUsize::new(count).expect("nombre non nul")
    }

    /// Numéro posé sur chaque client (variable de session), lu par une requête.
    async fn slot(client: &Surreal<Any>) -> i64 {
        let mut response = client.query("RETURN $slot;").await.expect("requête");
        let slot: Option<i64> = response.take(0).expect("lecture");
        slot.expect("numéro")
    }

    /// Pool de `count` bases embarquées distinctes, numérotées : sert seulement à observer le
    /// tour, un pool réel ne mêle jamais des bases différentes.
    async fn numbered_pool(count: usize) -> SurrealPool {
        let mut clients = Vec::new();
        for number in 0..count {
            let client = create_surreal_client(&options("mem://"))
                .await
                .expect("base embarquée");
            client
                .set("slot", i64::try_from(number).expect("numéro"))
                .await
                .expect("variable");
            clients.push(client);
        }
        let first = clients.remove(0);
        SurrealPool::of(first, clients)
    }

    #[tokio::test]
    async fn embedded_endpoint_opens_a_single_client() {
        for endpoint in ["mem://", "memory"] {
            let pool = SurrealPool::connect(&options(endpoint), connections(8))
                .await
                .expect("pool");
            assert_eq!(pool.size(), 1, "{endpoint}");
            assert_eq!(pool.clients().count(), 1, "{endpoint}");
        }
    }

    #[tokio::test]
    async fn clients_are_handed_out_in_turn() {
        let pool = numbered_pool(3).await;
        assert_eq!(pool.size(), 3);
        let mut seen = Vec::new();
        for _ in 0..7 {
            seen.push(slot(pool.client()).await);
        }
        assert_eq!(seen, [0, 1, 2, 0, 1, 2, 0]);
        // La connexion fixe ne suit pas le tour
        assert_eq!(slot(pool.fixed()).await, 0);
        assert_eq!(slot(pool.fixed()).await, 0);
        let mut all = Vec::new();
        for client in pool.clients() {
            all.push(slot(client).await);
        }
        assert_eq!(all, [0, 1, 2]);
    }

    #[tokio::test]
    async fn copies_share_the_turn() {
        let pool = numbered_pool(2).await;
        let copy = pool.clone();
        assert_eq!(slot(pool.client()).await, 0);
        assert_eq!(slot(copy.client()).await, 1);
        assert_eq!(slot(pool.client()).await, 0);
    }

    #[tokio::test]
    async fn a_single_client_serves_every_call() {
        let client = create_surreal_client(&options("mem://"))
            .await
            .expect("base embarquée");
        client.set("slot", 7_i64).await.expect("variable");
        let pool = SurrealPool::from(client);
        assert_eq!(pool.size(), 1);
        for _ in 0..3 {
            assert_eq!(slot(pool.client()).await, 7);
        }
        assert_eq!(slot(pool.fixed()).await, 7);
    }

    #[tokio::test]
    async fn a_failed_opening_is_returned() {
        let error = SurrealPool::connect(&options("ws://127.0.0.1:9"), connections(2))
            .await
            .expect_err("identifiants absents");
        assert!(
            matches!(error, LyxalSurrealError::MissingCredentials { .. }),
            "{error:?}"
        );
    }

    #[tokio::test]
    async fn probe_counts_the_responding_clients() {
        let pool = numbered_pool(3).await;
        let report = pool.probe(Duration::from_secs(5)).await;
        assert_eq!(
            report,
            PoolProbe {
                clients: 3,
                responding: 3,
                error: None
            }
        );
        assert!(report.reachable());
        assert!(report.complete());

        let silent = PoolProbe {
            clients: 2,
            responding: 0,
            error: Some("coupée".into()),
        };
        assert!(!silent.reachable());
        assert!(!silent.complete());
        let partial = PoolProbe {
            clients: 2,
            responding: 1,
            error: Some("coupée".into()),
        };
        assert!(partial.reachable());
        assert!(!partial.complete());
    }

    #[tokio::test]
    async fn debug_shows_the_size_only() {
        let pool = numbered_pool(2).await;
        assert_eq!(format!("{pool:?}"), "SurrealPool { clients: 2 }");
    }
}
