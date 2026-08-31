-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/ipv6.surql
-- Fonction     : fn::validation_ipv6
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide strictement une adresse IPv6 textuelle avec le validateur natif SurrealDB.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être une chaîne non vide.
--   2. string::is_ipv6() doit retourner true.
--   3. Les formes compressées IPv6 sont acceptées par le validateur natif.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_IPV6
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
--   - string::is_ipv6()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ipv6(
    $value: option<any>,
    $field: string
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

    IF !string::is_ipv6($clean_value) {
        THROW string::concat($clean_field, "_INVALID_IPV6");
    };

    RETURN string::lowercase($clean_value);
}
COMMENT "
Valide strictement une adresse IPv6 textuelle et la retourne en minuscules.
"
PERMISSIONS FULL;
