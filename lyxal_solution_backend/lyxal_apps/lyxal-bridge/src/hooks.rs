//! Système de hooks (middlewares) pour la logique complexe.
//!
//! Les hooks permettent d'injecter de la logique spécifique à certains
//! providers **sans modifier le moteur générique**. Ils sont référencés
//! dans `bridge_operations.configuration.hooks[]`.
//!
//! ## Exemple
//! ```sql
//! -- Dans bridge_operations, un champ hooks: ["hmac_sign"]
//! -- Le moteur Rust cherche le hook "hmac_sign" dans le registre
//! -- et l'exécute avant d'envoyer la requête
//! ```

use std::collections::HashMap;
use std::fmt;

use crate::error::BridgeError;
use crate::request::BridgeRequest;
use crate::response::BridgeResponse;

// =========================================================================
// Trait BridgeHook
// =========================================================================

/// Trait pour les hooks de logique complexe.
///
/// Chaque hook est enregistré par nom dans le `HookRegistry` et peut être
/// référencé dans `bridge_operations.configuration.hooks[]`.
///
/// Les hooks sont appelés dans l'ordre de leur déclaration dans le tableau.
pub trait BridgeHook: Send + Sync {
    /// Nom unique du hook (ex: "hmac_sign", "auto_paginate_cursor").
    fn name(&self) -> &str;

    /// Transformation pré-requête.
    /// Appelé juste avant l'envoi de la requête HTTP.
    /// Peut modifier headers, body, URL, etc.
    fn pre_request(&self, _request: &mut BridgeRequest) -> Result<(), BridgeError> {
        Ok(()) // par défaut : no-op
    }

    /// Transformation post-réponse.
    /// Appelé après réception de la réponse HTTP.
    /// Peut modifier le body, déclencher de la pagination, etc.
    fn post_response(&self, _response: &mut BridgeResponse) -> Result<(), BridgeError> {
        Ok(()) // par défaut : no-op
    }
}

// =========================================================================
// HookRegistry
// =========================================================================

/// Registre des hooks disponibles.
///
/// Tous les hooks sont enregistrés au démarrage du serveur.
/// Quand une opération référence un hook par nom, le registre le retrouve ici.
pub struct HookRegistry {
    hooks: HashMap<String, Box<dyn BridgeHook>>,
}

impl HookRegistry {
    /// Crée un registre vide.
    pub fn new() -> Self {
        let mut registry = Self {
            hooks: HashMap::new(),
        };
        // Enregistrer les hooks built-in
        registry.register(Box::new(ContentTypeJsonHook));
        registry.register(Box::new(UserAgentHook));
        registry
    }

    /// Enregistre un hook dans le registre.
    pub fn register(&mut self, hook: Box<dyn BridgeHook>) {
        let name = hook.name().to_string();
        tracing::debug!(hook = name, "Hook enregistré");
        self.hooks.insert(name, hook);
    }

    /// Récupère un hook par son nom.
    pub fn get(&self, name: &str) -> Option<&dyn BridgeHook> {
        self.hooks.get(name).map(|h| h.as_ref())
    }

    /// Applique tous les hooks pré-requête pour une opération.
    pub fn apply_pre_hooks(
        &self,
        hook_names: &[String],
        request: &mut BridgeRequest,
    ) -> Result<(), BridgeError> {
        for name in hook_names {
            if let Some(hook) = self.get(name) {
                tracing::debug!(hook = name, "Applying pre-request hook");
                hook.pre_request(request)?;
            } else {
                tracing::warn!(hook = name, "Hook introuvable dans le registre, ignoré");
            }
        }
        Ok(())
    }

    /// Applique tous les hooks post-réponse pour une opération.
    pub fn apply_post_hooks(
        &self,
        hook_names: &[String],
        response: &mut BridgeResponse,
    ) -> Result<(), BridgeError> {
        for name in hook_names {
            if let Some(hook) = self.get(name) {
                tracing::debug!(hook = name, "Applying post-response hook");
                hook.post_response(response)?;
            }
        }
        Ok(())
    }

    /// Liste les noms de tous les hooks enregistrés.
    pub fn list_hooks(&self) -> Vec<&str> {
        self.hooks.keys().map(|k| k.as_str()).collect()
    }
}

impl fmt::Debug for HookRegistry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("HookRegistry")
            .field("hooks", &self.hooks.keys().collect::<Vec<_>>())
            .finish()
    }
}

// =========================================================================
// Hooks Built-in
// =========================================================================

/// Hook qui ajoute `Content-Type: application/json` si un body est présent.
struct ContentTypeJsonHook;

impl BridgeHook for ContentTypeJsonHook {
    fn name(&self) -> &str {
        "content_type_json"
    }

    fn pre_request(&self, request: &mut BridgeRequest) -> Result<(), BridgeError> {
        if request.body.is_some() {
            request
                .headers
                .entry("Content-Type".to_string())
                .or_insert_with(|| "application/json".to_string());
        }
        Ok(())
    }
}

/// Hook qui ajoute un User-Agent Lyxal.
struct UserAgentHook;

impl BridgeHook for UserAgentHook {
    fn name(&self) -> &str {
        "user_agent"
    }

    fn pre_request(&self, request: &mut BridgeRequest) -> Result<(), BridgeError> {
        request
            .headers
            .entry("User-Agent".to_string())
            .or_insert_with(|| "LyxalBridge/1.0".to_string());
        Ok(())
    }
}

// =========================================================================
// Hooks à implémenter dans le futur
// =========================================================================

// TODO: HmacSignHook — Signature HMAC pour Binance, Stripe, AWS SigV4
// TODO: AutoPaginateCursorHook — Pagination automatique cursor-based
// TODO: AutoPaginateOffsetHook — Pagination automatique offset-based
// TODO: OAuth2RefreshHook — Rafraîchissement automatique des tokens OAuth2
// TODO: MultipartUploadHook — Upload de fichiers multipart/form-data
// TODO: XmlConversionHook — Conversion JSON → XML pour APIs legacy
