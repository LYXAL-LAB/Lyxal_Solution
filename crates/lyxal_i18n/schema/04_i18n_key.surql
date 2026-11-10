-- ============================================================================
-- TABLE  : i18n_key
-- MODULE : lyxal_i18n
-- RÔLE   : Clés de traduction : nom, contexte et paramètres attendus
-- ============================================================================
-- Identifiant = clé complète (i18n_key:⟨base.unite.metre⟩). Le texte source est la traduction
-- de l'installation dans la langue source de l'espace de noms (i18n_translation).

DEFINE TABLE OVERWRITE i18n_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE fn::auth_has_permission({ permission: "i18n.translation.manage" })
    COMMENT "Clés de traduction";

DEFINE FIELD OVERWRITE namespace ON TABLE i18n_key
    TYPE record<i18n_namespace>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT "Espace de noms";

DEFINE FIELD OVERWRITE name ON TABLE i18n_key
    TYPE string
    READONLY
    ASSERT string::len($value) <= 128 AND fn::validation_lyxal_event_name($value, 1, 8).value == $value
    COMMENT "Nom dans l'espace de noms : segments en minuscules séparés par des points";

DEFINE FIELD OVERWRITE full_key ON TABLE i18n_key
    TYPE string
    VALUE string::concat(<string> record::id($this.namespace), ".", $this.name)
    COMMENT "Clé complète : <espace de noms>.<nom>";

DEFINE FIELD OVERWRITE description ON TABLE i18n_key
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Contexte pour le traducteur";

DEFINE FIELD OVERWRITE params ON TABLE i18n_key
    TYPE array<object>
    DEFAULT []
    ASSERT array::len($value) <= 20
    COMMENT "Paramètres attendus dans les textes : [{ name, type }]";

DEFINE FIELD OVERWRITE params.*.name ON TABLE i18n_key
    TYPE string
    ASSERT fn::validation_identifier($value, 1, 64).valid;

DEFINE FIELD OVERWRITE params.*.type ON TABLE i18n_key
    TYPE string
    ASSERT $value IN ["string", "number", "datetime"];

DEFINE FIELD OVERWRITE max_length ON TABLE i18n_key
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10000)
    COMMENT "Longueur maximale d'une traduction";

DEFINE FIELD OVERWRITE created_at ON TABLE i18n_key
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE i18n_key
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE i18n_key_namespace ON TABLE i18n_key FIELDS namespace;
