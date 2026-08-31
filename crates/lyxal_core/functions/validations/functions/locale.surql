-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/locale.surql
-- Fonction     : fn::validation_locale
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement une locale simplifiée de forme langue ou langue-PAYS.
--
-- Règles appliquées
-- -----------------
--   1. Le séparateur canonique est le tiret.
--   2. La langue est normalisée en minuscules.
--   3. La région est normalisée en majuscules.
--   4. La région peut être obligatoire ou facultative.
--   5. Les scripts BCP 47 et extensions ne sont pas couverts par cette primitive.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $require_region: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et, lorsque cela est indiqué, normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_LOCALE
-- <FIELD>_REGION_REQUIRED
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
--   - string::replace()
--   - string::split()
--   - string::lowercase()
--   - string::uppercase()
--   - string::matches()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_locale(
    $value: option<any>,
    $field: string,
    $require_region: bool
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

    LET $normalized_separator = string::replace(
        $clean_value,
        "_",
        "-"
    );

    LET $parts = string::split($normalized_separator, "-");

    IF array::len($parts) = 1 {
        LET $language = string::lowercase($parts[0]);

        IF $require_region {
            THROW string::concat($clean_field, "_REGION_REQUIRED");
        };

        IF !string::matches($language, "^[a-z]{2,3}$") {
            THROW string::concat($clean_field, "_INVALID_LOCALE");
        };

        RETURN $language;
    };

    IF array::len($parts) != 2 {
        THROW string::concat($clean_field, "_INVALID_LOCALE");
    };

    LET $language = string::lowercase($parts[0]);
    LET $region = string::uppercase($parts[1]);

    IF !string::matches($language, "^[a-z]{2,3}$")
        OR !string::matches($region, "^[A-Z]{2}$")
    {
        THROW string::concat($clean_field, "_INVALID_LOCALE");
    };

    RETURN string::concat($language, "-", $region);
}
COMMENT "
Valide et normalise une locale simplifiée de forme langue ou langue-PAYS.
"
PERMISSIONS FULL;
