-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/mac_address.surql
-- Fonction     : fn::validation_mac_address
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une adresse MAC EUI-48 avec séparateur deux-points ou tiret.
--
-- Règles appliquées
-- -----------------
--   1. Six groupes de deux chiffres hexadécimaux sont obligatoires.
--   2. Les séparateurs ':' et '-' peuvent être autorisés séparément.
--   3. Le mélange de séparateurs est refusé.
--   4. La valeur retournée est normalisée en minuscules.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_hyphen: bool
-- $allow_colon: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_MAC_ADDRESS
-- VALIDATION_NO_MAC_SEPARATOR_ALLOWED
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
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_mac_address(
    $value: option<any>,
    $field: string,
    $allow_hyphen: bool,
    $allow_colon: bool
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

    IF !$allow_hyphen AND !$allow_colon {
        THROW "VALIDATION_NO_MAC_SEPARATOR_ALLOWED";
    };

    LET $is_colon = string::matches(
        $clean_value,
        "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
    );

    LET $is_hyphen = string::matches(
        $clean_value,
        "^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$"
    );

    IF ($is_colon AND !$allow_colon)
        OR ($is_hyphen AND !$allow_hyphen)
        OR (!$is_colon AND !$is_hyphen)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_MAC_ADDRESS"
        );
    };

    RETURN string::lowercase($clean_value);
}
COMMENT "
Valide une adresse MAC EUI-48 avec séparateur ':' ou '-'.
"
PERMISSIONS FULL;
