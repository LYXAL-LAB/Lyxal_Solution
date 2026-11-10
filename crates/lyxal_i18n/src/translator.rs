//! Traduction d'une clé en une étape : `fn::i18n_resolve`, puis rendu du texte retenu.

use std::collections::HashMap;
use std::sync::{Arc, Mutex, PoisonError};

use lyxal_surreal::LyxalSurrealError;

use crate::format::{FormatError, Formatter, MessageArgs, Syntax};
use crate::models::ResolveParams;
use crate::store::I18nStore;

/// Nombre maximal de langues gardées en cache.
const MAX_FORMATTERS: usize = 64;

/// Demande de traduction.
#[derive(Debug, Clone)]
pub struct TranslateRequest {
    /// Clé complète (`base.unite.metre`).
    pub key: String,
    /// Étiquette de la langue demandée.
    pub locale: String,
    /// Organisation dont les surcharges s'appliquent (texte `auth_organization:<clé>`).
    pub tenant: Option<String>,
    /// Valeurs des paramètres de la clé.
    pub args: MessageArgs,
    /// Fuseau horaire des dates (identifiant IANA, `UTC` compris).
    pub zone: String,
}

/// Texte traduit et rendu.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Translated {
    /// Texte rendu ; la clé elle-même si elle n'est pas déclarée.
    pub text: String,
    /// Langue du texte retenu ; absente pour une clé non déclarée.
    pub locale: Option<String>,
    /// Clé non déclarée.
    pub missing: bool,
    /// Texte surchargé par l'organisation.
    pub overridden: bool,
}

/// Échec d'une traduction.
#[derive(Debug, thiserror::Error)]
pub enum TranslateError {
    /// Échec de `fn::i18n_resolve` (erreur métier ou transport).
    #[error("{0}")]
    Store(Box<LyxalSurrealError>),
    /// Échec du rendu du texte.
    #[error("{0}")]
    Format(#[from] FormatError),
}

impl From<LyxalSurrealError> for TranslateError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Store(Box::new(error))
    }
}

/// Traducteur : résolution en base et rendu, avec un `Formatter` en cache par langue.
pub struct Translator {
    store: I18nStore,
    formatters: Mutex<HashMap<String, Arc<Formatter>>>,
}

impl Translator {
    /// Traducteur sur un store ; la session SurrealDB du store détermine l'appelant.
    pub fn new(store: I18nStore) -> Self {
        Self {
            store,
            formatters: Mutex::new(HashMap::new()),
        }
    }

    /// `Formatter` d'une langue, construit une fois puis gardé en cache (64 langues au plus).
    pub fn formatter(&self, locale: &str) -> Result<Arc<Formatter>, FormatError> {
        let mut cache = self
            .formatters
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if let Some(found) = cache.get(locale) {
            return Ok(Arc::clone(found));
        }
        let formatter = Arc::new(Formatter::new(locale)?);
        if cache.len() >= MAX_FORMATTERS {
            cache.clear();
        }
        cache.insert(locale.to_string(), Arc::clone(&formatter));
        Ok(formatter)
    }

    /// Texte d'une clé, rendu avec ses arguments dans la langue du texte **retenu** : un texte
    /// de repli suit les pluriels et les formats de sa propre langue.
    pub async fn translate(&self, request: TranslateRequest) -> Result<Translated, TranslateError> {
        let resolved = self
            .store
            .resolve(ResolveParams {
                key: request.key,
                locale: request.locale,
                tenant: request.tenant,
            })
            .await?;
        let Some(locale) = resolved.locale else {
            return Ok(Translated {
                text: resolved.text,
                locale: None,
                missing: true,
                overridden: false,
            });
        };
        let syntax =
            Syntax::parse(&resolved.syntax).ok_or_else(|| FormatError::MessageInvalid {
                reason: format!("syntaxe inconnue : {}", resolved.syntax),
                offset: 0,
            })?;
        let text = self.formatter(&locale)?.format_message(
            &resolved.text,
            syntax,
            &request.args,
            &request.zone,
        )?;
        Ok(Translated {
            text,
            locale: Some(locale),
            missing: resolved.missing,
            overridden: resolved.overridden,
        })
    }
}
