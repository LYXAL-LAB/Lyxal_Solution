-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_function_name.surql
-- Fonction     : fn::validation_lyxal_function_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom complet de fonction Lyxal ou SurrealQL de forme namespace::fonction.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Les segments utilisent lettres, chiffres et tirets bas.
--   3. Le séparateur entre segments est ::.
--   4. Le namespace peut être obligatoire ou facultatif.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $require_namespace: bool
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_FUNCTION_NAME
-- <FIELD>_FUNCTION_NAMESPACE_REQUIRED
-- VALIDATION_INVALID_FUNCTION_MAX_LENGTH
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
--   - aucune dépendance à l'authentification ;
--   - aucune création de ressource Lyxal ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_function_name(
    $value: option<any>,
    $field: string,
    $require_namespace: bool,
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
        THROW "VALIDATION_INVALID_FUNCTION_MAX_LENGTH";
    };

    LET $function_name = string::lowercase($clean_value);

    IF string::len($function_name) > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    LET $has_namespace = string::contains($function_name, "::");

    IF $require_namespace AND !$has_namespace {
        THROW string::concat(
            $clean_field,
            "_FUNCTION_NAMESPACE_REQUIRED"
        );
    };

    LET $pattern = IF $require_namespace {
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)+$"
    } ELSE {
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"
    };

    IF !string::matches($function_name, $pattern) {
        THROW string::concat(
            $clean_field,
            "_INVALID_FUNCTION_NAME"
        );
    };

    RETURN $function_name;
}
COMMENT "
Valide un nom de fonction Lyxal ou SurrealQL avec segments séparés par ::.
"
PERMISSIONS FULL;
