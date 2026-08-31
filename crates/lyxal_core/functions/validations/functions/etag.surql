-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/etag.surql
-- Fonction     : fn::validation_etag
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un ETag HTTP fort ou faible.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_weak: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_ETAG
-- <FIELD>_WEAK_ETAG_NOT_ALLOWED
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune inspection binaire réelle du fichier ;
--   - aucune conversion implicite de la valeur validée.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::starts_with()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_etag(
    $value: option<any>,
    $field: string,
    $allow_weak: bool
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

    LET $is_weak = string::starts_with($clean_value, "W/");

    IF $is_weak AND !$allow_weak {
        THROW string::concat(
            $clean_field,
            "_WEAK_ETAG_NOT_ALLOWED"
        );
    };

    IF !string::matches(
        $clean_value,
        "^(W/)?\"[\x21\x23-\x7E\x80-\xFF]*\"$"
    ) {
        THROW string::concat($clean_field, "_INVALID_ETAG");
    };

    RETURN $clean_value;
}
COMMENT "
Valide lexicalement un ETag HTTP fort ou faible.
"
PERMISSIONS FULL;
