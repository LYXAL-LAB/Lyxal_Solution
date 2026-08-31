-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_scope
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_scope(
    $value: string
) -> string {
    LET $scope = string::lowercase(string::trim($value));

    IF !string::matches(
        $scope,
        "^[a-z][a-z0-9_]*(?::[a-z][a-z0-9_]*)+$"
    ) {
        THROW "SECURITY_INVALID_SCOPE";
    };

    RETURN $scope;
}
COMMENT "Valide et normalise un scope de forme domaine:action."
PERMISSIONS FULL;
