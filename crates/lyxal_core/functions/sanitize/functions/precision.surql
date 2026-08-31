-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_precision
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_precision($value:number,$precision:int)->decimal{
 IF $precision<0{THROW "SANITIZE_INVALID_PRECISION";};
 RETURN <decimal>fn::sanitize_round($value,$precision);
}
COMMENT "Normalise un nombre vers une précision décimale donnée."
PERMISSIONS FULL;
