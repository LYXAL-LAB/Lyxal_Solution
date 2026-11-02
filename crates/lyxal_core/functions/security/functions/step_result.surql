-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/step_result.surql
-- Fonction : fn::security_step_result
--
-- Résultat d'exécution security à partir d'un état du moteur : valeur,
-- constats (détections, avec chemin), score de risque
-- (fn::security_detect_score, plafonné à 100), décisions de permission,
-- allowed (vrai si aucune décision ne refuse) et erreurs de schéma.
--
-- Paramètres
--   $state : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_step_result(
    $state: object
) -> object {
    LET $findings = array::map(array::filter($state.records, |$record| $record.kind = "finding"), |$record| { path: $record.path, rule: $record.rule, result: $record.data });
    LET $decisions = array::map(array::filter($state.records, |$record| $record.kind = "decision"), |$record| { path: $record.path, decision: $record.data });
    RETURN {
        value: $state.value,
        findings: $findings,
        score: fn::security_detect_score(array::map($findings, |$finding| $finding.result)),
        decisions: $decisions,
        allowed: array::all($decisions, |$decision| $decision.decision.allowed),
        errors: $state.issues
    };
}
COMMENT "Résultat d'exécution security à partir d'un état du moteur : valeur, constats (détections, avec chemin), score de risque (fn::security_detect_score, plafonné à 100), décisions de permission, allowed (vrai si aucune décision ne refuse) et erreurs de schéma."
PERMISSIONS FULL;
