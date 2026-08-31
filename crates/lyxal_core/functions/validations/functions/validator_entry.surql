-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_entry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_entry(
    $name: string,
    $version: string,
    $capability: string,
    $function_name: string,
    $enabled: bool
) -> object {
    LET $validator_name = fn::validation_validator_name(
        $name,
        "VALIDATOR_NAME"
    );

    LET $validator_capability = fn::validation_validator_capability(
        $capability,
        "CAPABILITY"
    );

    LET $fn_name = string::lowercase(string::trim($function_name));

    IF !string::matches(
        $fn_name,
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)+$"
    ) {
        THROW "VALIDATION_INVALID_VALIDATOR_FUNCTION";
    };

    IF !string::matches(
        string::lowercase(string::trim($version)),
        "^v[1-9][0-9]*$"
    ) {
        THROW "VALIDATION_INVALID_VALIDATOR_VERSION";
    };

    RETURN {
        name: $validator_name,
        version: string::lowercase(string::trim($version)),
        capability: $validator_capability,
        function_name: $fn_name,
        enabled: $enabled
    };
}
COMMENT "
Construit une entrée normalisée du registre de validateurs.
"
PERMISSIONS FULL;
