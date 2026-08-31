-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_optimizer_step
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_optimizer_step($step:object)->object{
 LET $cost=IF $step.rule IN ["trim","lowercase","uppercase","capitalize","title_case","default"]{1}
 ELSE IF $step.rule IN ["collapse_whitespace","remove_control_chars","normalize_unicode","slug","safe_identifier"]{2}
 ELSE{5};
 RETURN object::extend($step,{_cost:$cost});
}
COMMENT "Ajoute un coût relatif à une étape."
PERMISSIONS FULL;
