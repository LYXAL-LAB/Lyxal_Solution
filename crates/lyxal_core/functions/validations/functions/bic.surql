-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/bic.surql
-- Fonction     : fn::validation_bic
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un code BIC/SWIFT de huit ou onze caractères.
--
-- Principes
-- ----------
--   - distinction stricte entre NONE, NULL et type invalide ;
--   - aucune conversion implicite de la valeur métier ;
--   - codes d'erreur stables construits depuis le nom technique du champ ;
--   - aucune lecture ou écriture persistante ;
--   - aucune vérification auprès d'un service bancaire ou administratif.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bic(
    $value: option<any>,
    $field: string,
    $allowed_countries: option<array<string>>
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $bic = string::uppercase(string::trim($value));
    IF !string::matches($bic, "^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}(?:[A-Z0-9]{3})?$") {
        THROW string::concat($clean_field, "_INVALID_BIC");
    };

    LET $country = string::slice($bic, 4, 6);
    IF $allowed_countries IS NOT NONE {
        IF array::len($allowed_countries) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_BIC_COUNTRIES";
        };
        LET $allowed = array::map(
            $allowed_countries,
            |$code| string::uppercase(string::trim($code))
        );
        IF !array::contains($allowed, $country) {
            THROW string::concat($clean_field, "_BIC_COUNTRY_NOT_ALLOWED");
        };
    };
    RETURN $bic;
}
COMMENT "Valide lexicalement et normalise un code BIC ou SWIFT."
PERMISSIONS FULL;
