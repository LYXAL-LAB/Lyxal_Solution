-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/money.surql
-- Fonction     : fn::validation_money
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un montant strictement de type decimal, avec limites facultatives et nombre maximal de décimales.
--
-- Principes
-- ----------
--   - validation stricte sans conversion implicite ;
--   - distinction entre NONE, NULL et type invalide ;
--   - codes d'erreur stables ;
--   - aucune lecture ou écriture persistante ;
--   - retour de la valeur d'origine lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_value: option<decimal>
-- $max_value: option<decimal>
-- $max_scale: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SMALL
-- <FIELD>_TOO_LARGE
-- <FIELD>_TOO_MANY_DECIMALS
-- VALIDATION_INVALID_MONEY_RANGE
-- VALIDATION_INVALID_MONEY_SCALE
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
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - string::split()
--   - string::len()
--   - type::is_null()
--   - type::is_decimal()
--   - type::string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_money(
    $value: option<any>,
    $field: string,
    $min_value: option<decimal>,
    $max_value: option<decimal>,
    $max_scale: int
) -> decimal {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $max_scale < 0 {
        THROW "VALIDATION_INVALID_MONEY_SCALE";
    };

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_MONEY_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_decimal($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $min_value IS NOT NONE AND $value < $min_value {
        THROW string::concat($clean_field, "_TOO_SMALL");
    };

    IF $max_value IS NOT NONE AND $value > $max_value {
        THROW string::concat($clean_field, "_TOO_LARGE");
    };

    LET $parts = string::split(type::string($value), ".");
    LET $scale = IF array::len($parts) = 2 {
        string::len($parts[1])
    } ELSE {
        0
    };

    IF $scale > $max_scale {
        THROW string::concat($clean_field, "_TOO_MANY_DECIMALS");
    };

    RETURN $value;
}
COMMENT "
Valide un montant decimal avec limites facultatives et nombre maximal de
chiffres après la virgule.
"
PERMISSIONS FULL;
