-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_schema_manifest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_schema_manifest(
    $registry:object
)->object{
 RETURN {
  generated_at:time::now(),
  schemas:array::map($registry.entries,|$e|{name:$e.name,version:$e.version,status:$e.status}),
  total:array::len($registry.entries)
 };
}
COMMENT "Produit un manifeste public des schémas Security."
PERMISSIONS FULL;
