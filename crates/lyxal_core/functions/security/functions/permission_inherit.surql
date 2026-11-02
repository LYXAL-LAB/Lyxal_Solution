-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/permission_inherit.surql
-- Fonction : fn::security_permission_inherit
--
-- Construit les permissions héritées d'un parent et d'un enfant.
--
-- Paramètres
--   $parent_permissions : array<object>
--   $child_permissions  : array<object>
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_permission_inherit(
    $parent_permissions: array<object>,
    $child_permissions: array<object>
) -> array<object> {
    RETURN fn::security_permission_merge(
        $parent_permissions,
        $child_permissions
    );
}
COMMENT "Construit les permissions héritées d'un parent et d'un enfant."
PERMISSIONS FULL;
