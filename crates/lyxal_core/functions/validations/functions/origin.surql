-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/origin.surql
-- Fonction     : fn::validation_origin
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une origine web composée d'un schéma HTTP(S), d'un hôte et d'un port facultatif, sans chemin.
--
-- Règles appliquées
-- -----------------
--   1. Seuls http:// et https:// sont acceptés.
--   2. Aucun chemin, query ou fragment n'est autorisé après l'autorité.
--   3. Un port explicite peut être autorisé ou interdit.
--   4. La fonction ne contacte pas l'origine.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_http: bool
-- $allow_https: bool
-- $allow_port: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_ORIGIN
-- <FIELD>_ORIGIN_SCHEME_NOT_ALLOWED
-- <FIELD>_ORIGIN_PORT_NOT_ALLOWED
-- VALIDATION_NO_ORIGIN_SCHEME_ALLOWED
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure : aucune lecture ou écriture
-- persistante, aucun accès réseau et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::lowercase()
--   - string::starts_with()
--   - string::matches()
--   - string::contains()
--   - string::is_url()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_origin(
    $value: option<any>,
    $field: string,
    $allow_http: bool,
    $allow_https: bool,
    $allow_port: bool
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF !$allow_http AND !$allow_https {
        THROW "VALIDATION_NO_ORIGIN_SCHEME_ALLOWED";
    };

    LET $origin = string::lowercase($clean_value);
    LET $is_http = string::starts_with($origin, "http://");
    LET $is_https = string::starts_with($origin, "https://");

    IF !$is_http AND !$is_https {
        THROW string::concat(
            $clean_field,
            "_INVALID_ORIGIN"
        );
    };

    IF ($is_http AND !$allow_http)
        OR ($is_https AND !$allow_https)
    {
        THROW string::concat(
            $clean_field,
            "_ORIGIN_SCHEME_NOT_ALLOWED"
        );
    };

    IF !string::is_url($origin)
        OR string::matches(
            $origin,
            "^https?://[^/?#]+[/?#].*$"
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_ORIGIN"
        );
    };

    LET $authority = IF $is_https {
        string::slice($origin, 8)
    } ELSE {
        string::slice($origin, 7)
    };

    LET $has_explicit_port =
        string::matches($authority, "^\[[^\]]+\]:[0-9]+$")
        OR string::matches($authority, "^[^:]+:[0-9]+$");

    IF !$allow_port AND $has_explicit_port {
        THROW string::concat(
            $clean_field,
            "_ORIGIN_PORT_NOT_ALLOWED"
        );
    };

    RETURN $origin;
}
COMMENT "
Valide une origine web HTTP(S) sans chemin, query ni fragment.
"
PERMISSIONS FULL;
