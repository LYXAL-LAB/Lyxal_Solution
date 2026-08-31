-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_contract_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_contract_version(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);
    IF $value IS NONE { THROW string::concat($clean_field,"_REQUIRED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field,"_INVALID_TYPE"); };
    LET $version = string::lowercase(string::trim($value));
    IF !string::matches($version, "^v[1-9][0-9]*$") {
        THROW string::concat($clean_field,"_INVALID_CONTRACT_VERSION");
    };
    RETURN $version;
}
COMMENT "Valide une version de contrat de forme v1, v2, etc."
PERMISSIONS FULL;
