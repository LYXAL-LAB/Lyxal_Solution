//! Accès aux fonctions SurrealQL de `lyxal_i18n` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). La session SurrealDB du client détermine l'appelant.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    Locale, LocaleGetParams, LocaleList, LocaleListParams, LocaleResolveParams, ResolvedLocale,
    Settings, SettingsGetParams, SettingsUpdateParams,
};

/// Store de `lyxal_i18n` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct I18nStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for I18nStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

impl I18nStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// `fn::i18n_locale_list` : langues du référentiel.
    pub async fn locale_list(
        &self,
        params: LocaleListParams,
    ) -> Result<LocaleList, LyxalSurrealError> {
        self.call_fn("i18n_locale_list", params).await
    }

    /// `fn::i18n_locale_get` : une langue.
    pub async fn locale_get(&self, params: LocaleGetParams) -> Result<Locale, LyxalSurrealError> {
        self.call_fn("i18n_locale_get", params).await
    }

    /// `fn::i18n_locale_activate` : activation d'une langue.
    pub async fn locale_activate(
        &self,
        params: LocaleGetParams,
    ) -> Result<Locale, LyxalSurrealError> {
        self.call_fn("i18n_locale_activate", params).await
    }

    /// `fn::i18n_locale_deactivate` : désactivation d'une langue.
    pub async fn locale_deactivate(
        &self,
        params: LocaleGetParams,
    ) -> Result<Locale, LyxalSurrealError> {
        self.call_fn("i18n_locale_deactivate", params).await
    }

    /// `fn::i18n_settings_get` : réglages de l'installation.
    pub async fn settings_get(&self) -> Result<Settings, LyxalSurrealError> {
        self.call_fn("i18n_settings_get", SettingsGetParams {})
            .await
    }

    /// `fn::i18n_settings_update` : langue par défaut et langue source.
    pub async fn settings_update(
        &self,
        params: SettingsUpdateParams,
    ) -> Result<Settings, LyxalSurrealError> {
        self.call_fn("i18n_settings_update", params).await
    }

    /// `fn::i18n_locale_resolve` : langue d'une requête parmi des candidats.
    pub async fn locale_resolve(
        &self,
        params: LocaleResolveParams,
    ) -> Result<ResolvedLocale, LyxalSurrealError> {
        self.call_fn("i18n_locale_resolve", params).await
    }
}
