-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_record_string.surql
-- Fonction     : fn::validation_surql_record_string
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une représentation textuelle de Record ID SurrealDB.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être une chaîne reconnue comme Record ID.
--   2. Une table précise peut être imposée.
--   3. La chaîne n'est pas convertie en type record.
--   4. L'existence du record n'est pas vérifiée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $expected_table: option<string>
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée, éventuellement normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_RECORD_STRING
-- <FIELD>_RECORD_TABLE_NOT_ALLOWED
-- VALIDATION_INVALID_EXPECTED_RECORD_TABLE
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
-- Primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune création de schéma SurrealDB ;
--   - aucune exécution de requête dynamique ;
--   - aucune vérification d'existence des objets validés.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

--
-- Remarque
-- --------
-- SurrealDB ne convertit pas implicitement une chaîne en Record ID. Utiliser
-- ensuite type::record() ou un cast explicite lorsque la conversion est voulue.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_record_string(
    $value: option<any>,
    $field: string,
    $expected_table: option<string>
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

    LET $table = IF $expected_table IS NONE {
        NONE
    } ELSE {
        string::trim($expected_table)
    };

    IF $table IS NOT NONE
        AND (
            $table = ""
            OR !string::matches(
                $table,
                "^[A-Za-z_][A-Za-z0-9_]*$"
            )
        )
    {
        THROW "VALIDATION_INVALID_EXPECTED_RECORD_TABLE";
    };

    LET $valid = IF $table IS NONE {
        string::is_record($clean_value)
    } ELSE {
        string::is_record($clean_value, $table)
    };

    IF !$valid {
        IF string::is_record($clean_value) {
            THROW string::concat(
                $clean_field,
                "_RECORD_TABLE_NOT_ALLOWED"
            );
        };

        THROW string::concat(
            $clean_field,
            "_INVALID_RECORD_STRING"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide une chaîne représentant un Record ID SurrealDB, avec table facultative.
"
PERMISSIONS FULL;
