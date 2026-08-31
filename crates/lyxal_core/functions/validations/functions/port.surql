-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/port.surql
-- Fonction     : fn::validation_port
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un port réseau entier dans une plage configurable.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être strictement de type int.
--   2. Les bornes doivent rester entre 0 et 65535.
--   3. La plage est inclusive.
--   4. Utiliser 1 à 65535 pour exclure le port zéro.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_port: int
-- $max_port: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_PORT_TOO_LOW
-- <FIELD>_PORT_TOO_HIGH
-- VALIDATION_INVALID_PORT_RANGE
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
--   - string::concat()
--   - type::is_null()
--   - type::is_int()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_port(
    $value: option<any>,
    $field: string,
    $min_port: int,
    $max_port: int
) -> int {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_port < 0
        OR $max_port > 65535
        OR $min_port > $max_port
    {
        THROW "VALIDATION_INVALID_PORT_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value < $min_port {
        THROW string::concat($clean_field, "_PORT_TOO_LOW");
    };

    IF $value > $max_port {
        THROW string::concat($clean_field, "_PORT_TOO_HIGH");
    };

    RETURN $value;
}
COMMENT "
Valide un port réseau entier dans une plage inclusive configurable.
"
PERMISSIONS FULL;
