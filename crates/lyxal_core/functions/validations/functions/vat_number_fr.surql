-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/vat_number_fr.surql
-- Fonction     : fn::validation_vat_number_fr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un numéro de TVA intracommunautaire français, son SIREN et sa clé numérique facultative.
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
-- fn::validation_siren()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_vat_number_fr(
    $value: option<any>,
    $field: string,
    $validate_numeric_key: bool
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $vat = string::uppercase(
        string::replace(string::trim($value), " ", "")
    );
    IF !string::matches($vat, "^FR[A-Z0-9]{2}[0-9]{9}$") {
        THROW string::concat($clean_field, "_INVALID_VAT_NUMBER");
    };

    LET $key = string::slice($vat, 2, 4);
    LET $siren = fn::validation_siren(
        string::slice($vat, 4, 13),
        string::concat($clean_field, "_SIREN")
    );

    IF $validate_numeric_key AND string::matches($key, "^[0-9]{2}$") {
        LET $expected = (12 + 3 * (type::int($siren) % 97)) % 97;
        IF type::int($key) != $expected {
            THROW string::concat($clean_field, "_INVALID_VAT_KEY");
        };
    };

    RETURN {
        vat_number: $vat,
        country: "FR",
        key: $key,
        siren: $siren
    };
}
COMMENT "
Valide un numéro de TVA français et contrôle facultativement sa clé numérique.
"
PERMISSIONS FULL;
