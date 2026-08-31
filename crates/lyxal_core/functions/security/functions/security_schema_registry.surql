-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_schema_registry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_schema_registry(
    $entries:array<object>
)->object{
 RETURN {
  entries:$entries,
  total:array::len($entries),
  active:array::len(array::filter($entries,|$e|$e.status="active"))
 };
}
COMMENT "Construit un registre de schémas Security."
PERMISSIONS FULL;
