-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_field(
    $name:string,
    $pipeline:array<object>,
    $required:bool,
    $classification:string
)->object{
 RETURN {
  name:string::trim($name),
  pipeline:$pipeline,
  required:$required,
  classification:string::lowercase(string::trim($classification))
 };
}
COMMENT "Construit une définition de champ Security."
PERMISSIONS FULL;
