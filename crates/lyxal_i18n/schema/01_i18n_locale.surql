-- ============================================================================
-- TABLE  : i18n_locale
-- MODULE : lyxal_i18n
-- RÔLE   : Référentiel des langues (Unicode CLDR), langues actives de l'installation
-- ============================================================================
-- Identifiant = étiquette BCP 47 canonique (i18n_locale:⟨fr-CA⟩). Les données viennent de CLDR
-- par le seed généré (scripts/i18n/generate_locales.py) ; seule l'activation se modifie.

DEFINE TABLE OVERWRITE i18n_locale
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, delete NONE
        FOR update WHERE fn::auth_has_permission({ permission: "i18n.locale.manage" })
    COMMENT "Référentiel des langues (CLDR) et langues actives";

DEFINE FIELD OVERWRITE tag ON TABLE i18n_locale
    TYPE string
    READONLY
    ASSERT fn::validation_locale($value, false).value == $value
    COMMENT "Étiquette BCP 47 canonique (langue[-Script][-RÉGION])";

DEFINE FIELD OVERWRITE language ON TABLE i18n_locale
    TYPE string
    READONLY
    ASSERT fn::validation_language_code($value, true, NONE).value == $value
    COMMENT "Langue seule (ISO 639)";

DEFINE FIELD OVERWRITE script ON TABLE i18n_locale
    TYPE option<string>
    READONLY
    COMMENT "Script (ISO 15924), s'il fait partie de l'étiquette";

DEFINE FIELD OVERWRITE region ON TABLE i18n_locale
    TYPE option<string>
    READONLY
    COMMENT "Région (ISO 3166 ou UN M.49), si elle fait partie de l'étiquette";

DEFINE FIELD OVERWRITE name_en ON TABLE i18n_locale
    TYPE string
    PERMISSIONS FOR update NONE
    COMMENT "Nom en anglais (CLDR)";

DEFINE FIELD OVERWRITE name_native ON TABLE i18n_locale
    TYPE string
    PERMISSIONS FOR update NONE
    COMMENT "Nom dans la langue elle-même (CLDR)";

DEFINE FIELD OVERWRITE direction ON TABLE i18n_locale
    TYPE string
    ASSERT $value IN ["ltr", "rtl"]
    PERMISSIONS FOR update NONE
    COMMENT "Sens d'écriture";

DEFINE FIELD OVERWRITE plural_cardinal ON TABLE i18n_locale
    TYPE array<string>
    PERMISSIONS FOR update NONE
    COMMENT "Catégories de pluriel cardinal (zero, one, two, few, many, other)";

DEFINE FIELD OVERWRITE plural_cardinal.* ON TABLE i18n_locale
    TYPE string
    ASSERT $value IN ["zero", "one", "two", "few", "many", "other"];

DEFINE FIELD OVERWRITE plural_ordinal ON TABLE i18n_locale
    TYPE array<string>
    PERMISSIONS FOR update NONE
    COMMENT "Catégories de pluriel ordinal";

DEFINE FIELD OVERWRITE plural_ordinal.* ON TABLE i18n_locale
    TYPE string
    ASSERT $value IN ["zero", "one", "two", "few", "many", "other"];

DEFINE FIELD OVERWRITE fallback ON TABLE i18n_locale
    TYPE array<string>
    PERMISSIONS FOR update NONE
    COMMENT "Chaîne de repli CLDR (langues parentes), sans l'étiquette elle-même";

DEFINE FIELD OVERWRITE fallback.* ON TABLE i18n_locale
    TYPE string;

DEFINE FIELD OVERWRITE active ON TABLE i18n_locale
    TYPE bool
    DEFAULT false
    COMMENT "Langue proposée par l'installation";

DEFINE FIELD OVERWRITE cldr_version ON TABLE i18n_locale
    TYPE string
    PERMISSIONS FOR update NONE
    COMMENT "Version de CLDR des données";

DEFINE FIELD OVERWRITE updated_at ON TABLE i18n_locale
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE i18n_locale_active ON TABLE i18n_locale FIELDS active;
