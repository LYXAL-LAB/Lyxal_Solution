-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/recovery_code.surql
-- Fonction     : fn::validation_recovery_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un code de récupération à groupes alphanumériques séparés par des tirets.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $group_count: int
-- $group_length: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_RECOVERY_CODE
-- VALIDATION_INVALID_RECOVERY_CODE_SHAPE
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
-- Primitive pure : aucune lecture ou écriture persistante, aucun appel réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::uppercase()
--   - string::split()
--   - string::len()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--   - array::all()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_recovery_code(
    $value: option<any>,
    $field: string,
    $group_count: int,
    $group_length: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

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

    IF $group_count < 1 OR $group_length < 1 {
        THROW "VALIDATION_INVALID_RECOVERY_CODE_SHAPE";
    };

    LET $code = string::uppercase($clean_value);
    LET $groups = string::split($code, "-");

    IF array::len($groups) != $group_count
        OR !array::all(
            $groups,
            |$group|
                string::len($group) = $group_length
                AND string::matches($group, "^[A-Z0-9]+$")
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_RECOVERY_CODE"
        );
    };

    RETURN $code;
}
COMMENT "
Valide un code de récupération structuré en groupes alphanumériques séparés
par des tirets.
"
PERMISSIONS FULL;
