-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_merge($left:array<object>,$right:array<object>)->array<object>{
 RETURN fn::sanitize_optimizer_remove_duplicates(array::concat($left,$right));
}
COMMENT "Fusionne deux pipelines et retire les doublons."
PERMISSIONS FULL;
