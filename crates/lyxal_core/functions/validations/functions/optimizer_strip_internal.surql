-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_strip_internal
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_strip_internal($pipeline:array<object>)->array<object>{
 RETURN array::map($pipeline,|$s|object::from_entries(array::filter(object::entries($s),|$e|!string::starts_with($e[0],"_"))));
}
COMMENT "Retire les métadonnées internes."
PERMISSIONS FULL;
