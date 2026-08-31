-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_clamp
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_clamp($value:number,$min:number,$max:number)->number{
 IF $min>$max{THROW "SANITIZE_INVALID_CLAMP_RANGE";};
 RETURN IF $value<$min{$min}ELSE IF $value>$max{$max}ELSE{$value};
}
COMMENT "Borne une valeur numérique entre un minimum et un maximum."
PERMISSIONS FULL;
