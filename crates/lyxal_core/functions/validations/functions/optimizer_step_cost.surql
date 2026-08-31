-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_optimizer_step_cost
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_optimizer_step_cost($step:object)->int{
 RETURN IF $step.rule IN ["required","default","trim","lowercase","uppercase"]{1}ELSE IF $step.rule IN ["min_length","max_length","enum"]{2}ELSE IF $step.rule="pattern"{5}ELSE{10};
}
COMMENT "Attribue un coût relatif à une étape."
PERMISSIONS FULL;
