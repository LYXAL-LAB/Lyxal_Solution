-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/rib_fr.surql
-- Fonction     : fn::validation_rib_fr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement les composantes d'un RIB français.
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

DEFINE FUNCTION OVERWRITE fn::validation_rib_fr(
    $bank_code: option<any>,
    $branch_code: option<any>,
    $account_number: option<any>,
    $rib_key: option<any>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $bank_code IS NONE { THROW string::concat($clean_field, "_BANK_CODE_REQUIRED"); };
    IF !type::is_string($bank_code)
        OR !string::matches(string::replace(string::trim($bank_code), " ", ""), "^[0-9]{5}$") {
        THROW string::concat($clean_field, "_BANK_CODE_INVALID");
    };

    IF $branch_code IS NONE { THROW string::concat($clean_field, "_BRANCH_CODE_REQUIRED"); };
    IF !type::is_string($branch_code)
        OR !string::matches(string::replace(string::trim($branch_code), " ", ""), "^[0-9]{5}$") {
        THROW string::concat($clean_field, "_BRANCH_CODE_INVALID");
    };

    IF $account_number IS NONE { THROW string::concat($clean_field, "_ACCOUNT_NUMBER_REQUIRED"); };
    IF !type::is_string($account_number) {
        THROW string::concat($clean_field, "_ACCOUNT_NUMBER_INVALID");
    };
    LET $account = string::uppercase(
        string::replace(string::trim($account_number), " ", "")
    );
    IF !string::matches($account, "^[A-Z0-9]{11}$") {
        THROW string::concat($clean_field, "_ACCOUNT_NUMBER_INVALID");
    };

    IF $rib_key IS NONE { THROW string::concat($clean_field, "_RIB_KEY_REQUIRED"); };
    IF !type::is_string($rib_key)
        OR !string::matches(string::replace(string::trim($rib_key), " ", ""), "^[0-9]{2}$") {
        THROW string::concat($clean_field, "_RIB_KEY_INVALID");
    };

    RETURN {
        bank_code: string::replace(string::trim($bank_code), " ", ""),
        branch_code: string::replace(string::trim($branch_code), " ", ""),
        account_number: $account,
        rib_key: string::replace(string::trim($rib_key), " ", "")
    };
}
COMMENT "
Valide lexicalement les composantes d'un RIB français. Ne recalcule pas la clé.
"
PERMISSIONS FULL;
