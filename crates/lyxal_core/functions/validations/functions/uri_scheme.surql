-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/uri_scheme.surql
-- Fonction     : fn::validation_uri_scheme
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un schéma URI selon la syntaxe RFC générale et peut le limiter à une liste autorisée.
--
-- Règles appliquées
-- -----------------
--   1. Le premier caractère doit être une lettre.
--   2. Les suivants peuvent être lettres, chiffres, '+', '-' ou '.'.
--   3. La valeur est normalisée en minuscules.
--   4. Une liste facultative peut limiter les schémas autorisés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_schemes: option<array<string>>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_URI_SCHEME
-- <FIELD>_URI_SCHEME_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_URI_SCHEMES
-- VALIDATION_INVALID_ALLOWED_URI_SCHEME
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
--   - string::lowercase()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--   - array::map()
--   - array::any()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_uri_scheme(
    $value: option<any>,
    $field: string,
    $allowed_schemes: option<array<string>>
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

    LET $scheme = string::lowercase($clean_value);

    IF !string::matches(
        $scheme,
        "^[a-z][a-z0-9+.-]*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_URI_SCHEME"
        );
    };

    IF $allowed_schemes IS NOT NONE {
        IF array::len($allowed_schemes) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_URI_SCHEMES";
        };

        LET $normalized_allowed = array::map(
            $allowed_schemes,
            |$item| string::lowercase(string::trim($item))
        );

        IF array::any(
            $normalized_allowed,
            |$item| !string::matches($item, "^[a-z][a-z0-9+.-]*$")
        ) {
            THROW "VALIDATION_INVALID_ALLOWED_URI_SCHEME";
        };

        IF !array::contains($normalized_allowed, $scheme) {
            THROW string::concat(
                $clean_field,
                "_URI_SCHEME_NOT_ALLOWED"
            );
        };
    };

    RETURN $scheme;
}
COMMENT "
Valide et normalise un schéma URI, avec liste autorisée facultative.
"
PERMISSIONS FULL;
