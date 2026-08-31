-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/luhn.surql
-- Fonction     : fn::validation_luhn
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne numérique avec l'algorithme de Luhn.
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

DEFINE FUNCTION OVERWRITE fn::validation_luhn(
    $value: option<any>,
    $field: string,
    $min_length: int,
    $max_length: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_LUHN_LENGTH_RANGE";
    };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $digits = string::replace(
        string::replace(string::trim($value), " ", ""),
        "-",
        ""
    );
    IF !string::matches($digits, "^[0-9]+$") {
        THROW string::concat($clean_field, "_INVALID_NUMERIC_VALUE");
    };

    LET $length = string::len($digits);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };

    LET $indexes = <array>0..$length;
    LET $sum = array::reduce(
        $indexes,
        |$acc, $index| {
            LET $digit = type::int(string::slice($digits, $index, $index + 1));
            LET $double = ($length - $index) % 2 = 0;
            LET $processed = IF $double {
                LET $doubled = $digit * 2;
                IF $doubled > 9 { $doubled - 9 } ELSE { $doubled }
            } ELSE {
                $digit
            };
            $acc + $processed
        },
        0
    );

    IF $sum % 10 != 0 {
        THROW string::concat($clean_field, "_INVALID_LUHN_CHECKSUM");
    };
    RETURN $digits;
}
COMMENT "Valide une chaîne numérique avec l'algorithme de Luhn."
PERMISSIONS FULL;
