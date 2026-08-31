-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/ape_naf_code.surql
-- Fonction     : fn::validation_ape_naf_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement un code APE/NAF français de quatre chiffres et une lettre.
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

DEFINE FUNCTION OVERWRITE fn::validation_ape_naf_code(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };

    LET $code = string::uppercase(
        string::replace(string::trim($value), " ", "")
    );
    IF !string::matches($code, "^[0-9]{4}[A-Z]$") {
        THROW string::concat($clean_field, "_INVALID_APE_NAF_CODE");
    };
    RETURN $code;
}
COMMENT "Valide lexicalement et normalise un code APE ou NAF français."
PERMISSIONS FULL;
