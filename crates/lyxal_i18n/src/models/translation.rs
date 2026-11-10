//! Espaces de noms, clés, traductions et résolution du texte d'une clé.

use lyxal_surreal::SurrealValue;

use super::types::{I18nDatetime, I18nRecordId};

/// Paramètres de pagination des listes (`limit` de 1 à 1000, 100 par défaut).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PageParams {
    /// Nombre maximal d'éléments.
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Espace de noms des clés d'un module.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Namespace {
    /// Identifiant (`i18n_namespace:base`).
    pub id: I18nRecordId,
    /// Clé, premier segment des clés complètes.
    pub key: String,
    /// Module propriétaire.
    pub module: String,
    /// Description.
    pub description: Option<String>,
    /// Langue des textes sources.
    pub source_locale: I18nRecordId,
    /// Création.
    pub created_at: I18nDatetime,
    /// Dernière modification.
    pub updated_at: I18nDatetime,
}

/// Paramètres de `fn::i18n_namespace_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct NamespaceCreateParams {
    /// Clé (snake_case).
    pub key: String,
    /// Module propriétaire (`lyxal_base`).
    pub module: String,
    /// Description.
    pub description: Option<String>,
    /// Langue source (étiquette active) ; celle des réglages si absente.
    pub source_locale: Option<String>,
}

/// Résultat de `fn::i18n_namespace_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct NamespaceList {
    /// Espaces de noms de la page.
    pub items: Vec<Namespace>,
    /// Nombre total.
    pub total: i64,
}

/// Paramètre attendu dans les textes d'une clé.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct KeyParam {
    /// Nom de l'argument dans les messages.
    pub name: String,
    /// Type : `string`, `number` ou `datetime`.
    #[surreal(rename = "type")]
    pub kind: String,
}

/// Clé de traduction.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TranslationKey {
    /// Identifiant (`i18n_key:⟨base.unite.metre⟩`).
    pub id: I18nRecordId,
    /// Espace de noms.
    pub namespace: I18nRecordId,
    /// Nom dans l'espace de noms.
    pub name: String,
    /// Clé complète (`base.unite.metre`).
    pub full_key: String,
    /// Contexte pour le traducteur.
    pub description: Option<String>,
    /// Paramètres attendus.
    pub params: Vec<KeyParam>,
    /// Longueur maximale d'un texte.
    pub max_length: Option<i64>,
    /// Création.
    pub created_at: I18nDatetime,
    /// Dernière modification.
    pub updated_at: I18nDatetime,
}

/// Problème ou avertissement du contrôle d'un texte.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct MessageIssue {
    /// Code (`missing_category`, `unused_parameter`…).
    pub code: String,
    /// Argument concerné.
    pub argument: Option<String>,
    /// Catégorie de pluriel concernée.
    pub category: Option<String>,
}

/// Paramètres de `fn::i18n_key_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct KeyCreateParams {
    /// Espace de noms (clé).
    pub namespace: String,
    /// Nom : segments en minuscules séparés par des points.
    pub name: String,
    /// Texte source, dans la langue source de l'espace de noms.
    pub source_text: String,
    /// Syntaxe : `icu_mf1` (défaut) ou `plain`.
    pub syntax: Option<String>,
    /// Contexte pour le traducteur.
    pub description: Option<String>,
    /// Paramètres attendus.
    pub params: Vec<KeyParam>,
    /// Longueur maximale d'un texte.
    pub max_length: Option<i64>,
}

/// Résultat de `fn::i18n_key_create`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct KeyCreated {
    /// Clé créée.
    pub key: TranslationKey,
    /// Avertissements du contrôle du texte source.
    pub warnings: Vec<MessageIssue>,
}

/// Paramètres de `fn::i18n_key_update` : un champ absent est conservé, `clear` efface.
#[derive(Debug, Clone, SurrealValue)]
pub struct KeyUpdateParams {
    /// Clé complète.
    pub key: String,
    /// Contexte pour le traducteur.
    pub description: Option<String>,
    /// Paramètres attendus (remplacent les précédents).
    pub params: Option<Vec<KeyParam>>,
    /// Longueur maximale d'un texte.
    pub max_length: Option<i64>,
    /// Champs à effacer : `description`, `max_length`.
    pub clear: Vec<String>,
}

/// Paramètres de `fn::i18n_key_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct KeyDeleteParams {
    /// Clé complète.
    pub key: String,
}

/// Résultat de `fn::i18n_key_delete`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct KeyDeleted {
    /// Clé supprimée.
    pub deleted: bool,
    /// Nombre de textes supprimés avec elle.
    pub translations: i64,
}

/// Paramètres de `fn::i18n_key_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct KeyListParams {
    /// Espace de noms (clé).
    pub namespace: Option<String>,
    /// Partie de la clé complète.
    pub search: Option<String>,
    /// Nombre maximal de clés.
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Résultat de `fn::i18n_key_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct KeyList {
    /// Clés de la page.
    pub items: Vec<TranslationKey>,
    /// Nombre total.
    pub total: i64,
}

/// Texte d'une clé dans une langue (installation ou surcharge d'une organisation).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Translation {
    /// Identifiant (`i18n_translation:[clé, langue, portée]`).
    pub id: I18nRecordId,
    /// Clé.
    pub key: I18nRecordId,
    /// Langue.
    pub locale: I18nRecordId,
    /// Organisation de la surcharge.
    pub tenant: Option<I18nRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Texte source de la clé.
    pub is_source: bool,
    /// Texte.
    pub text: String,
    /// Syntaxe : `icu_mf1` ou `plain`.
    pub syntax: String,
    /// État : `translated` ou `reviewed`.
    pub state: String,
    /// Numéro d'écriture.
    pub revision: i64,
    /// Texte source modifié depuis l'écriture.
    pub outdated: bool,
    /// Empreinte du texte source au moment de l'écriture.
    pub source_hash: Option<String>,
    /// Identité de la dernière écriture.
    pub updated_by: Option<I18nRecordId>,
    /// Création.
    pub created_at: I18nDatetime,
    /// Dernière modification.
    pub updated_at: I18nDatetime,
}

/// Paramètres de `fn::i18n_translation_set`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TranslationSetParams {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Texte.
    pub text: String,
    /// Syntaxe ; par défaut celle du texte existant, sinon du texte source.
    pub syntax: Option<String>,
    /// Organisation surchargée (texte `auth_organization:<clé>`), installation si absente.
    pub tenant: Option<String>,
}

/// Résultat de `fn::i18n_translation_set`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TranslationSet {
    /// Texte écrit.
    pub translation: Translation,
    /// Avertissements du contrôle.
    pub warnings: Vec<MessageIssue>,
}

/// Paramètres de `fn::i18n_translation_review`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TranslationReviewParams {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Relu (`true`) ou à traduire de nouveau (`false`).
    pub reviewed: bool,
    /// Organisation de la surcharge (texte).
    pub tenant: Option<String>,
}

/// Paramètres de `fn::i18n_translation_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TranslationDeleteParams {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation de la surcharge (texte).
    pub tenant: Option<String>,
}

/// Résultat de `fn::i18n_translation_delete`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TranslationDeleted {
    /// Texte supprimé.
    pub deleted: bool,
}

/// Paramètres de `fn::i18n_translation_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TranslationListParams {
    /// Étiquette de la langue.
    pub locale: String,
    /// Espace de noms (clé).
    pub namespace: Option<String>,
    /// Organisation dont la surcharge remplace le texte de l'installation (texte).
    pub tenant: Option<String>,
    /// État : `untranslated`, `translated` ou `reviewed`.
    pub state: Option<String>,
    /// Filtre sur l'obsolescence.
    pub outdated: Option<bool>,
    /// Partie de la clé complète.
    pub search: Option<String>,
    /// Nombre maximal de lignes.
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// État de la traduction d'une clé dans une langue.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TranslationRow {
    /// Clé complète.
    pub key: String,
    /// Texte source.
    pub source_text: Option<String>,
    /// Texte dans la langue demandée.
    pub text: Option<String>,
    /// État : `untranslated`, `translated` ou `reviewed`.
    pub state: String,
    /// Texte source modifié depuis l'écriture.
    pub outdated: bool,
    /// Texte surchargé par l'organisation demandée.
    pub overridden: bool,
}

/// Résultat de `fn::i18n_translation_list`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TranslationList {
    /// Lignes de la page.
    pub items: Vec<TranslationRow>,
    /// Nombre total.
    pub total: i64,
}

/// Paramètres de `fn::i18n_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ResolveParams {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation dont les surcharges s'appliquent (texte) ; par défaut celle de l'appelant.
    pub tenant: Option<String>,
}

/// Paramètres de `fn::i18n_resolve_many`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ResolveManyParams {
    /// Clés complètes (500 au plus).
    pub keys: Vec<String>,
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation dont les surcharges s'appliquent (texte).
    pub tenant: Option<String>,
}

/// Texte résolu d'une clé.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ResolvedText {
    /// Clé complète.
    pub key: String,
    /// Texte ; la clé elle-même si elle n'est pas déclarée.
    pub text: String,
    /// Syntaxe du texte.
    pub syntax: String,
    /// Langue du texte retenu ; absente pour une clé non déclarée.
    pub locale: Option<String>,
    /// Texte surchargé par l'organisation.
    pub overridden: bool,
    /// Clé non déclarée.
    pub missing: bool,
}

/// Clé demandée mais non déclarée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MissingKey {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue demandée.
    pub locale: String,
    /// Première demande.
    pub first_seen_at: I18nDatetime,
    /// Dernière demande.
    pub last_seen_at: I18nDatetime,
}

/// Résultat de `fn::i18n_missing_key_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MissingKeyList {
    /// Clés de la page.
    pub items: Vec<MissingKey>,
    /// Nombre total.
    pub total: i64,
}
