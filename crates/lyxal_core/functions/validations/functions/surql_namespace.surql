-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_namespace.surql
-- Fonction     : fn::validation_surql_namespace
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom simple de namespace SurrealDB.
--
-- Règles appliquées
-- -----------------
--   1. L'identifiant doit être simple et portable.
--   2. La casse est conservée.
--   3. Les identifiants échappés ne sont pas couverts.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée, éventuellement normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_NAMESPACE_NAME
-- <FIELD>_TOO_LONG
-- VALIDATION_INVALID_SURQL_NAMESPACE_MAX_LENGTH
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

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_namespace(
    $value: option<any>,
    $field: string,
    $max_length: int
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

    IF $max_length < 1 {
        THROW "VALIDATION_INVALID_SURQL_NAMESPACE_MAX_LENGTH";
    };

    IF string::len($clean_value) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $clean_value,
        "^[A-Za-z_][A-Za-z0-9_]*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_NAMESPACE_NAME"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide un nom simple et portable de namespace SurrealDB.
"
PERMISSIONS FULL;
