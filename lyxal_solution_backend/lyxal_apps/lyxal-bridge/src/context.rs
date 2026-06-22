//! Contexte partagé du Bridge.
//!
//! Le `BridgeContext` est créé **une seule fois** au démarrage du serveur
//! et partagé entre tous les appels `bridge::call()`. Il contient :
//! - Le client HTTP réutilisable (pool de connexions TCP)
//! - Le cache des métadonnées (providers, opérations)
//! - Les rate limiters par provider
//! - Le registre des hooks

use std::sync::Arc;
use std::time::{Duration, Instant};

use dashmap::DashMap;
use reqwest::Client;

use crate::hooks::HookRegistry;
use crate::models::{BridgeErrorRule, BridgeOperation, BridgeProvider};

// =========================================================================
// Cache
// =========================================================================

/// Métadonnées cachées pour un provider + opération.
#[derive(Debug, Clone)]
pub struct CachedMetadata {
    pub provider: BridgeProvider,
    pub operation: BridgeOperation,
    pub error_rules: Vec<BridgeErrorRule>,
    cached_at: Instant,
    ttl: Duration,
}

impl CachedMetadata {
    /// Crée une nouvelle entrée de cache.
    pub fn new(
        provider: BridgeProvider,
        operation: BridgeOperation,
        error_rules: Vec<BridgeErrorRule>,
        ttl: Duration,
    ) -> Self {
        Self {
            provider,
            operation,
            error_rules,
            cached_at: Instant::now(),
            ttl,
        }
    }

    /// Vérifie si l'entrée est expirée.
    pub fn is_expired(&self) -> bool {
        self.cached_at.elapsed() > self.ttl
    }
}

// =========================================================================
// Circuit Breaker
// =========================================================================

/// État du circuit breaker pour un provider.
#[derive(Debug, Clone)]
pub enum CircuitState {
    /// Circuit fermé — le provider fonctionne normalement.
    Closed,
    /// Circuit ouvert — le provider est temporairement bloqué.
    /// Contient l'instant où le circuit a été ouvert.
    Open(Instant),
    /// Circuit semi-ouvert — on autorise un essai pour vérifier si le provider est revenu.
    HalfOpen,
}

impl CircuitState {
    /// Durée par défaut avant qu'un circuit ouvert passe en semi-ouvert.
    const DEFAULT_RECOVERY_TIMEOUT: Duration = Duration::from_secs(60);

    /// Vérifie si le circuit autorise les requêtes.
    pub fn allows_request(&self) -> bool {
        match self {
            CircuitState::Closed => true,
            CircuitState::HalfOpen => true,
            CircuitState::Open(opened_at) => {
                // Si le timeout de recovery est passé, on autorise un essai
                opened_at.elapsed() > Self::DEFAULT_RECOVERY_TIMEOUT
            }
        }
    }
}

// =========================================================================
// Configuration
// =========================================================================

/// Configuration du Bridge.
#[derive(Debug, Clone)]
pub struct BridgeConfig {
    /// TTL du cache des métadonnées (défaut: 5 minutes)
    pub cache_ttl: Duration,

    /// Timeout par défaut pour les requêtes HTTP (défaut: 30s)
    pub default_timeout: Duration,

    /// Nombre max de connexions idle par host dans le pool HTTP
    pub pool_max_idle_per_host: usize,

    /// Timeout pour les connexions idle dans le pool
    pub pool_idle_timeout: Duration,
}

impl Default for BridgeConfig {
    fn default() -> Self {
        Self {
            cache_ttl: Duration::from_secs(300),       // 5 minutes
            default_timeout: Duration::from_secs(30),   // 30 secondes
            pool_max_idle_per_host: 10,
            pool_idle_timeout: Duration::from_secs(90),
        }
    }
}

// =========================================================================
// BridgeContext
// =========================================================================

/// Contexte partagé du Bridge, créé une fois au démarrage.
///
/// Contient tout ce dont le moteur a besoin pour exécuter des appels :
/// - Client HTTP réutilisable (pool de connexions)
/// - Cache LRU des métadonnées
/// - Circuit breakers par provider
/// - Registre des hooks
#[derive(Debug, Clone)]
pub struct BridgeContext {
    /// Client HTTP réutilisable avec pool de connexions TCP.
    http_client: Client,

    /// Cache des métadonnées (clé: "provider_name:operation_name").
    cache: Arc<DashMap<String, CachedMetadata>>,

    /// Circuit breakers par provider.
    pub(crate) circuit_breakers: Arc<DashMap<String, CircuitState>>,

    /// Registre des hooks disponibles.
    pub(crate) hooks: Arc<HookRegistry>,

    /// Configuration.
    config: BridgeConfig,
}

impl BridgeContext {
    /// Crée un nouveau BridgeContext avec la configuration par défaut.
    pub fn new() -> Result<Self, reqwest::Error> {
        Self::with_config(BridgeConfig::default())
    }

    /// Crée un nouveau BridgeContext avec une configuration personnalisée.
    pub fn with_config(config: BridgeConfig) -> Result<Self, reqwest::Error> {
        let http_client = Client::builder()
            .pool_max_idle_per_host(config.pool_max_idle_per_host)
            .pool_idle_timeout(config.pool_idle_timeout)
            .timeout(config.default_timeout)
            .build()?;

        Ok(Self {
            http_client,
            cache: Arc::new(DashMap::new()),
            circuit_breakers: Arc::new(DashMap::new()),
            hooks: Arc::new(HookRegistry::new()),
            config,
        })
    }

    /// Retourne une référence au client HTTP.
    pub fn http_client(&self) -> &Client {
        &self.http_client
    }

    /// Retourne la configuration.
    pub fn config(&self) -> &BridgeConfig {
        &self.config
    }

    // ── Cache ──

    /// Récupère une entrée du cache si elle existe et n'est pas expirée.
    pub fn cache_get(&self, provider: &str, operation: &str) -> Option<CachedMetadata> {
        let key = format!("{}:{}", provider, operation);
        self.cache.get(&key).and_then(|entry| {
            if entry.is_expired() {
                None
            } else {
                Some(entry.clone())
            }
        })
    }

    /// Insère une entrée dans le cache.
    pub fn cache_set(
        &self,
        provider: &str,
        operation: &str,
        data: CachedMetadata,
    ) {
        let key = format!("{}:{}", provider, operation);
        self.cache.insert(key, data);
    }

    /// Invalide le cache pour un provider spécifique.
    pub fn cache_invalidate(&self, provider: &str) {
        self.cache.retain(|key, _| !key.starts_with(&format!("{}:", provider)));
    }

    /// Vide tout le cache.
    pub fn cache_clear(&self) {
        self.cache.clear();
    }

    // ── Circuit Breaker ──

    /// Vérifie si un provider est autorisé (circuit breaker).
    pub fn is_provider_allowed(&self, provider: &str) -> bool {
        match self.circuit_breakers.get(provider) {
            Some(state) => state.allows_request(),
            None => true, // Pas de circuit breaker = autorisé
        }
    }

    /// Ouvre le circuit breaker pour un provider.
    pub fn open_circuit(&self, provider: &str) {
        self.circuit_breakers
            .insert(provider.to_string(), CircuitState::Open(Instant::now()));
    }

    /// Ferme le circuit breaker (le provider fonctionne à nouveau).
    pub fn close_circuit(&self, provider: &str) {
        self.circuit_breakers
            .insert(provider.to_string(), CircuitState::Closed);
    }
}

impl Default for BridgeContext {
    fn default() -> Self {
        Self::new().expect("Failed to create default BridgeContext")
    }
}
