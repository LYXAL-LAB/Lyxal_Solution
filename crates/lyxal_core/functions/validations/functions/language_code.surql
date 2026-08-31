-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/language_code.surql
-- Fonction     : fn::validation_language_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un code de langue ISO 639 lexical à deux ou trois lettres.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Deux lettres sont toujours acceptées lexicalement.
--   3. Trois lettres peuvent être autorisées.
--   4. Une liste facultative permet une validation fermée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_alpha3: bool
-- $allowed_codes: option<array<string>>
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et, lorsque cela est indiqué, normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_LANGUAGE_CODE
-- <FIELD>_LANGUAGE_CODE_NOT_ALLOWED
-- VALIDATION_EMPTY_ALLOWED_LANGUAGE_CODES
-- VALIDATION_INVALID_ALLOWED_LANGUAGE_CODE
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

DEFINE FUNCTION OVERWRITE fn::validation_language_code(
    $value: option<any>,
    $field: string,
    $allow_alpha3: bool,
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

    LET $language_code = string::lowercase($clean_value);
    LET $pattern = IF $allow_alpha3 {
        "^[a-z]{2,3}$"
    } ELSE {
        "^[a-z]{2}$"
    };

    IF !string::matches($language_code, $pattern) {
        THROW string::concat(
            $clean_field,
            "_INVALID_LANGUAGE_CODE"
        );
    };

    IF $allowed_codes IS NOT NONE {
        IF array::len($allowed_codes) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_LANGUAGE_CODES";
        };

        LET $clean_allowed = array::map(
            $allowed_codes,
            |$code| string::lowercase(string::trim($code))
        );

        IF array::any(
            $clean_allowed,
            |$code| !string::matches($code, $pattern)
        ) {
            THROW "VALIDATION_INVALID_ALLOWED_LANGUAGE_CODE";
        };

        IF !array::contains($clean_allowed, $language_code) {
            THROW string::concat(
                $clean_field,
                "_LANGUAGE_CODE_NOT_ALLOWED"
            );
        };
    };

    RETURN $language_code;
}
COMMENT "
Valide et normalise un code de langue ISO 639 lexical à deux ou trois lettres.
"
PERMISSIONS FULL;
