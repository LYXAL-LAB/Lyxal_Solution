-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/surql_function.surql
-- Fonction     : fn::validation_surql_function
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de fonction personnalisée SurrealQL utilisable après fn::.
--
-- Règles appliquées
-- -----------------
--   1. La valeur ne doit pas contenir le préfixe fn::.
--   2. Les segments sont séparés par ::.
--   3. Chaque segment est un identifiant simple.
--   4. Le namespace peut être obligatoire.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $require_namespace: bool
-- $max_segments: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée, éventuellement normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_FN_PREFIX_NOT_ALLOWED
-- <FIELD>_NAMESPACE_REQUIRED
-- <FIELD>_INVALID_FUNCTION_NAME
-- <FIELD>_TOO_MANY_SEGMENTS
-- VALIDATION_INVALID_SURQL_FUNCTION_SEGMENTS
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

DEFINE FUNCTION OVERWRITE fn::validation_surql_function(
    $value: option<any>,
    $field: string,
    $require_namespace: bool,
    $max_segments: int
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

    IF $max_segments < 1 {
        THROW "VALIDATION_INVALID_SURQL_FUNCTION_SEGMENTS";
    };

    IF string::starts_with($clean_value, "fn::") {
        THROW string::concat(
            $clean_field,
            "_FN_PREFIX_NOT_ALLOWED"
        );
    };

    IF $require_namespace
        AND !string::contains($clean_value, "::")
    {
        THROW string::concat(
            $clean_field,
            "_NAMESPACE_REQUIRED"
        );
    };

    IF !string::matches(
        $clean_value,
        "^[A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FUNCTION_NAME"
        );
    };

    IF array::len(string::split($clean_value, "::")) > $max_segments {
        THROW string::concat(
            $clean_field,
            "_TOO_MANY_SEGMENTS"
        );
    };

    RETURN $clean_value;
}
COMMENT "
Valide le nom d'une fonction personnalisée SurrealQL sans le préfixe fn::.
"
PERMISSIONS FULL;
