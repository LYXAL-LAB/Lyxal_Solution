-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/policy_merge.surql
-- Fonction : fn::security_policy_merge
--
-- Fusionne deux politiques de permissions.
--
-- Paramètres
--   $left    : object
--   $right   : object
--   $name    : string
--   $version : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_policy_merge(
    $left: object,
    $right: object,
    $name: string,
    $version: string
) -> object {
    RETURN fn::security_policy(
        $name,
        $version,
        fn::security_permission_merge(
            $left.permissions,
            $right.permissions
        ),
        IF $right.default_effect IS NONE {
            $left.default_effect
        } ELSE {
            $right.default_effect
        }
    );
}
COMMENT "Fusionne deux politiques de permissions."
PERMISSIONS FULL;
