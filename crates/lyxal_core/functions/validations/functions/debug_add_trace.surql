-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_add_trace
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_add_trace($session:object,$trace:object)->object{
 RETURN IF $session.enabled!=true{$session}ELSE{object::extend($session,{traces:array::append($session.traces,$trace)})};
}
COMMENT "Ajoute une trace à une session."
PERMISSIONS FULL;
