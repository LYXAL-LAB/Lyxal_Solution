-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/country_code_iso3.surql
-- Fonction     : fn::validation_country_code_iso3
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un code pays ISO 3166-1 alpha-3 composé de trois lettres.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en majuscules.
--   2. Elle doit contenir exactement trois lettres ASCII.
--   3. Une liste facultative peut limiter les codes autorisés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_codes: option<array<string>>
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et, lorsque cela est indiqué, normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_COUNTRY_CODE
-- <FIELD>_COUNTRY_CODE_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_COUNTRY_CODES
-- VALIDATION_INVALID_ALLOWED_COUNTRY_CODE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur ne possède pas le type attendu.
--
-- <FIELD>_BLANK_NOT_ALLOWED
--   La chaîne est vide après string::trim().
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune résolution géographique externe ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::uppercase()
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

DEFINE FUNCTION OVERWRITE fn::validation_country_code_iso3(
    $value: option<any>,
    $field: string,
    $allowed_codes: option<array<string>>
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

    LET $country_code = string::uppercase($clean_value);

    IF !string::matches($country_code, "^[A-Z]{3}$") {
        THROW string::concat(
            $clean_field,
            "_INVALID_COUNTRY_CODE"
        );
    };

    IF $allowed_codes IS NOT NONE {
        IF array::len($allowed_codes) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_COUNTRY_CODES";
        };

        LET $clean_allowed = array::map(
            $allowed_codes,
            |$code| string::uppercase(string::trim($code))
        );

        IF array::any(
            $clean_allowed,
            |$code| !string::matches($code, "^[A-Z]{3}$")
        ) {
            THROW "VALIDATION_INVALID_ALLOWED_COUNTRY_CODE";
        };

        IF !array::contains($clean_allowed, $country_code) {
            THROW string::concat(
                $clean_field,
                "_COUNTRY_CODE_NOT_ALLOWED"
            );
        };
    };

    RETURN $country_code;
}
COMMENT "
Valide lexicalement et normalise un code pays ISO 3166-1 alpha-3.
"
PERMISSIONS FULL;
