-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_namespace.surql
-- Fonction     : fn::validation_lyxal_namespace
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de namespace Lyxal ou SurrealDB stable et portable.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Le premier caractère doit être une lettre.
--   3. Lettres ASCII, chiffres, tirets et tirets bas sont autorisés.
--   4. Les séparateurs répétés et les séparateurs finaux sont interdits.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_length: int
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_NAMESPACE
-- <FIELD>_REPEATED_SEPARATOR
-- VALIDATION_INVALID_NAMESPACE_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_namespace(
    $value: option<any>,
    $field: string,
    $min_length: int,
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

    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_NAMESPACE_LENGTH_RANGE";
    };

    LET $namespace = string::lowercase($clean_value);
    LET $length = string::len($namespace);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $namespace,
        "^[a-z][a-z0-9_-]*[a-z0-9]$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_NAMESPACE"
        );
    };

    IF string::contains($namespace, "--")
        OR string::contains($namespace, "__")
        OR string::contains($namespace, "-_")
        OR string::contains($namespace, "_-")
    {
        THROW string::concat(
            $clean_field,
            "_REPEATED_SEPARATOR"
        );
    };

    RETURN $namespace;
}
COMMENT "
Valide et normalise un nom de namespace Lyxal stable et portable.
"
PERMISSIONS FULL;
