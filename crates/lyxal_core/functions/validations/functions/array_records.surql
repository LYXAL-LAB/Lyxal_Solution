-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_records.surql
-- Fonction     : fn::validation_array_records
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que tous les éléments d'un tableau sont des Record IDs et appartiennent facultativement à une table précise.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être un tableau.
--   2. Chaque élément doit être un Record ID SurrealDB.
--   3. Une table précise peut être imposée.
--   4. L'existence des enregistrements n'est pas vérifiée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_table: option<string>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_RECORD_ITEM
-- <FIELD>_RECORD_TABLE_NOT_ALLOWED
-- VALIDATION_INVALID_EXPECTED_RECORD_TABLE
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune dépendance à l'authentification ;
--   - aucun appel réseau ;
--   - aucun effet secondaire ;
--   - aucune conversion implicite de la valeur validée.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::is_record()
--   - record::tb()
--   - array::all()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_records(
    $value: option<any>,
    $field: string,
    $expected_table: option<string>
) -> array<record> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $clean_table = IF $expected_table IS NONE {
        NONE
    } ELSE {
        string::trim($expected_table)
    };

    IF $clean_table IS NOT NONE
        AND (
            $clean_table = ""
            OR !string::matches(
                $clean_table,
                "^[A-Za-z_][A-Za-z0-9_]*$"
            )
        )
    {
        THROW "VALIDATION_INVALID_EXPECTED_RECORD_TABLE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_array($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF !array::all($value, |$item| type::is_record($item)) {
        THROW string::concat(
            $clean_field,
            "_INVALID_RECORD_ITEM"
        );
    };

    IF $clean_table IS NOT NONE
        AND !array::all(
            $value,
            |$item| record::tb($item) = $clean_table
        )
    {
        THROW string::concat(
            $clean_field,
            "_RECORD_TABLE_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Valide un tableau de Record IDs et impose facultativement leur table.
"
PERMISSIONS FULL;
