-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/scope.surql
-- Fonction : fn::security_scope
--
-- Valide et normalise un scope de forme domaine:action.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : !string::matches( $scope, "^[a-z][a-z0-9_]*(?::[a-z][a-z0-9_]*)+$" )
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_scope(
    $value: string
) -> string {
    LET $scope = string::lowercase(string::trim($value));

    IF !string::matches(
        $scope,
        "^[a-z][a-z0-9_]*(?::[a-z][a-z0-9_]*)+$"
    ) {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN $scope;
}
COMMENT "Valide et normalise un scope de forme domaine:action."
PERMISSIONS FULL;
