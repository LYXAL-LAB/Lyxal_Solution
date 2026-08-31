-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/record_id.surql
-- Fonction     : fn::validation_record_id
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est un Record ID SurrealDB et peut limiter les tables autorisées.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_tables: option<array<string>>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_RECORD_TABLE_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_TABLES
-- VALIDATION_INVALID_ALLOWED_TABLE
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
-- Primitive pure : aucune lecture ou écriture persistante, aucun accès réseau
-- et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_record()
--   - record::tb()
--   - array::len()
--   - array::map()
--   - array::any()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record_id(
    $value: option<any>,
    $field: string,
    $allowed_tables: option<array<string>>
) -> record {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    LET $clean_tables = IF $allowed_tables IS NONE {
        NONE
    } ELSE {
        array::map(
            $allowed_tables,
            |$table| string::trim($table)
        )
    };

    IF $clean_tables IS NOT NONE AND array::len($clean_tables) = 0 {
        THROW "VALIDATION_EMPTY_ALLOWED_TABLES";
    };

    IF $clean_tables IS NOT NONE
        AND array::any(
            $clean_tables,
            |$table|
                $table = ""
                OR !string::matches(
                    $table,
                    "^[A-Za-z_][A-Za-z0-9_]*$"
                )
        )
    {
        THROW "VALIDATION_INVALID_ALLOWED_TABLE";
    };

    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };
    IF !type::is_record($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $clean_tables IS NOT NONE
        AND !array::contains($clean_tables, record::tb($value))
    {
        THROW string::concat(
            $clean_field,
            "_RECORD_TABLE_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Valide un Record ID SurrealDB et limite facultativement sa table.
"
PERMISSIONS FULL;
