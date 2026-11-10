-- ============================================================================
-- TABLE  : i18n_translation
-- MODULE : lyxal_i18n
-- RÔLE   : Textes d'une clé par langue : installation et surcharges par organisation
-- ============================================================================
-- Modèle : traductions et états de Tolgee. Identifiant = [clé complète, étiquette de langue,
-- portée] (portée : « installation » ou clé de l'organisation), unique par construction.
-- `source_hash` et `outdated` sont posés par la base (events/i18n_events.surql).

DEFINE TABLE OVERWRITE i18n_translation
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE OR fn::i18n_can_read({ tenant: tenant })
        FOR create, update, delete WHERE fn::i18n_can_translate({ tenant: tenant })
    COMMENT "Traductions : textes de l'installation et surcharges par organisation";

DEFINE FIELD OVERWRITE key ON TABLE i18n_translation
    TYPE record<i18n_key>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Clé traduite";

DEFINE FIELD OVERWRITE locale ON TABLE i18n_translation
    TYPE record<i18n_locale>
    READONLY
    COMMENT "Langue du texte";

DEFINE FIELD OVERWRITE tenant ON TABLE i18n_translation
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation de la surcharge (NONE : texte de l'installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE i18n_translation
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE is_source ON TABLE i18n_translation
    TYPE bool
    VALUE $this.tenant IS NONE AND $this.locale = $this.key.namespace.source_locale
    COMMENT "Vrai pour le texte source de la clé (installation, langue source de l'espace de noms)";

DEFINE FIELD OVERWRITE text ON TABLE i18n_translation
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 10000
    COMMENT "Texte";

DEFINE FIELD OVERWRITE syntax ON TABLE i18n_translation
    TYPE string
    DEFAULT "icu_mf1"
    ASSERT $value IN ["icu_mf1", "plain"]
    COMMENT "Syntaxe : icu_mf1 (ICU MessageFormat 1) ou plain (rendu tel quel)";

DEFINE FIELD OVERWRITE state ON TABLE i18n_translation
    TYPE string
    DEFAULT "translated"
    ASSERT $value IN ["translated", "reviewed"]
    COMMENT "État : traduit ou relu (non traduit : aucune ligne)";

DEFINE FIELD OVERWRITE revision ON TABLE i18n_translation
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Numéro d'écriture du texte, augmenté par fn::i18n_translation_set (une écriture du même texte lève l'obsolescence)";

DEFINE FIELD OVERWRITE outdated ON TABLE i18n_translation
    TYPE bool
    DEFAULT false
    PERMISSIONS FOR create, update NONE
    COMMENT "Vrai quand le texte source a changé depuis l'écriture de ce texte";

DEFINE FIELD OVERWRITE source_hash ON TABLE i18n_translation
    TYPE option<string>
    PERMISSIONS FOR create, update NONE
    COMMENT "Empreinte BLAKE3 du texte source au moment de l'écriture";

DEFINE FIELD OVERWRITE updated_by ON TABLE i18n_translation
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité de la dernière écriture";

DEFINE FIELD OVERWRITE created_at ON TABLE i18n_translation
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE i18n_translation
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE i18n_translation_key ON TABLE i18n_translation FIELDS key;
DEFINE INDEX OVERWRITE i18n_translation_locale ON TABLE i18n_translation FIELDS locale, scope_key;
