-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/invoice_number.surql
-- Fonction     : fn::validation_invoice_number
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un numéro de facture technique avec longueur et préfixes configurables.
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

DEFINE FUNCTION OVERWRITE fn::validation_invoice_number(
    $value: option<any>,
    $field: string,
    $allowed_prefixes: option<array<string>>,
    $min_length: int,
    $max_length: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_INVOICE_LENGTH_RANGE";
    };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $number = string::trim($value);
    LET $length = string::len($number);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    IF !string::matches($number, "^[A-Za-z0-9][A-Za-z0-9._/-]*$") {
        THROW string::concat($clean_field, "_INVALID_INVOICE_NUMBER");
    };

    IF $allowed_prefixes IS NOT NONE {
        IF array::len($allowed_prefixes) = 0 {
            THROW "VALIDATION_EMPTY_INVOICE_PREFIXES";
        };
        LET $prefixes = array::map(
            $allowed_prefixes,
            |$prefix| string::trim($prefix)
        );
        IF !array::any(
            $prefixes,
            |$prefix| $prefix != "" AND string::starts_with($number, $prefix)
        ) {
            THROW string::concat($clean_field, "_PREFIX_NOT_ALLOWED");
        };
    };

    RETURN $number;
}
COMMENT "
Valide la forme d'un numéro de facture. L'unicité et la séquence restent
sous la responsabilité de la fonction métier.
"
PERMISSIONS FULL;
