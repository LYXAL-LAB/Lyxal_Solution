//! Accès aux fonctions SurrealQL de `lyxal_i18n` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). La session SurrealDB du client détermine l'appelant.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::*;

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

    /// `fn::i18n_namespace_create` : nouvel espace de noms.
    pub async fn namespace_create(
        &self,
        params: NamespaceCreateParams,
    ) -> Result<Namespace, LyxalSurrealError> {
        self.call_fn("i18n_namespace_create", params).await
    }

    /// `fn::i18n_namespace_list` : espaces de noms.
    pub async fn namespace_list(
        &self,
        params: PageParams,
    ) -> Result<NamespaceList, LyxalSurrealError> {
        self.call_fn("i18n_namespace_list", params).await
    }

    /// `fn::i18n_key_create` : clé et texte source.
    pub async fn key_create(
        &self,
        params: KeyCreateParams,
    ) -> Result<KeyCreated, LyxalSurrealError> {
        self.call_fn("i18n_key_create", params).await
    }

    /// `fn::i18n_key_update` : contexte, paramètres et longueur d'une clé.
    pub async fn key_update(
        &self,
        params: KeyUpdateParams,
    ) -> Result<TranslationKey, LyxalSurrealError> {
        self.call_fn("i18n_key_update", params).await
    }

    /// `fn::i18n_key_delete` : clé et tous ses textes.
    pub async fn key_delete(
        &self,
        params: KeyDeleteParams,
    ) -> Result<KeyDeleted, LyxalSurrealError> {
        self.call_fn("i18n_key_delete", params).await
    }

    /// `fn::i18n_key_list` : clés.
    pub async fn key_list(&self, params: KeyListParams) -> Result<KeyList, LyxalSurrealError> {
        self.call_fn("i18n_key_list", params).await
    }

    /// `fn::i18n_translation_set` : texte de l'installation ou surcharge d'une organisation.
    pub async fn translation_set(
        &self,
        params: TranslationSetParams,
    ) -> Result<TranslationSet, LyxalSurrealError> {
        self.call_fn("i18n_translation_set", params).await
    }

    /// `fn::i18n_translation_review` : texte relu ou non.
    pub async fn translation_review(
        &self,
        params: TranslationReviewParams,
    ) -> Result<Translation, LyxalSurrealError> {
        self.call_fn("i18n_translation_review", params).await
    }

    /// `fn::i18n_translation_delete` : suppression d'un texte.
    pub async fn translation_delete(
        &self,
        params: TranslationDeleteParams,
    ) -> Result<TranslationDeleted, LyxalSurrealError> {
        self.call_fn("i18n_translation_delete", params).await
    }

    /// `fn::i18n_translation_list` : état des traductions d'une langue.
    pub async fn translation_list(
        &self,
        params: TranslationListParams,
    ) -> Result<TranslationList, LyxalSurrealError> {
        self.call_fn("i18n_translation_list", params).await
    }

    /// `fn::i18n_resolve` : texte d'une clé, avec repli.
    pub async fn resolve(&self, params: ResolveParams) -> Result<ResolvedText, LyxalSurrealError> {
        self.call_fn("i18n_resolve", params).await
    }

    /// `fn::i18n_resolve_many` : textes de plusieurs clés, dans l'ordre demandé.
    pub async fn resolve_many(
        &self,
        params: ResolveManyParams,
    ) -> Result<Vec<ResolvedText>, LyxalSurrealError> {
        self.call_fn("i18n_resolve_many", params).await
    }

    /// `fn::i18n_missing_key_list` : clés demandées mais non déclarées.
    pub async fn missing_key_list(
        &self,
        params: PageParams,
    ) -> Result<MissingKeyList, LyxalSurrealError> {
        self.call_fn("i18n_missing_key_list", params).await
    }
}
