-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/iban.surql
-- Fonction     : fn::validation_iban
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un IBAN, supprime les espaces, normalise en majuscules et contrôle plusieurs longueurs nationales.
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
--
-- Limite
-- ------
-- Le checksum IBAN modulo 97 n'est pas calculé dans cette primitive.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_iban(
    $value: option<any>,
    $field: string,
    $allowed_countries: option<array<string>>
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $iban = string::uppercase(string::replace(string::trim($value), " ", ""));
    IF !string::matches($iban, "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$") {
        THROW string::concat($clean_field, "_INVALID_IBAN");
    };

    LET $country = string::slice($iban, 0, 2);
    LET $length = string::len($iban);
    LET $expected =
        IF $country = "FR" { 27 }
        ELSE IF $country = "BE" { 16 }
        ELSE IF $country = "DE" { 22 }
        ELSE IF $country = "ES" { 24 }
        ELSE IF $country = "IT" { 27 }
        ELSE IF $country = "LU" { 20 }
        ELSE IF $country = "NL" { 18 }
        ELSE IF $country = "PT" { 25 }
        ELSE IF $country = "GB" { 22 }
        ELSE IF $country = "CH" { 21 }
        ELSE { NONE };

    IF $expected IS NOT NONE AND $length != $expected {
        THROW string::concat($clean_field, "_INVALID_IBAN_LENGTH");
    };

    IF $allowed_countries IS NOT NONE {
        IF array::len($allowed_countries) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_IBAN_COUNTRIES";
        };
        LET $allowed = array::map(
            $allowed_countries,
            |$code| string::uppercase(string::trim($code))
        );
        IF array::any($allowed, |$code| !string::matches($code, "^[A-Z]{2}$")) {
            THROW "VALIDATION_INVALID_ALLOWED_IBAN_COUNTRY";
        };
        IF !array::contains($allowed, $country) {
            THROW string::concat($clean_field, "_IBAN_COUNTRY_NOT_ALLOWED");
        };
    };

    RETURN $iban;
}
COMMENT "
Valide lexicalement un IBAN et contrôle plusieurs longueurs nationales.
Ne calcule pas encore le modulo 97 international.
"
PERMISSIONS FULL;
