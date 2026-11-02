-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_score.surql
-- Fonction : fn::security_detect_score
--
-- Agrège les scores de détection sur une échelle de 0 à 100.
--
-- Paramètres
--   $results : array<object>
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_detect_score(
    $results: array<object>
) -> int {
    LET $total = array::fold(
        $results,
        0,
        |$score,$result| $score + $result.score
    );

    RETURN IF $total > 100 { 100 } ELSE { $total };
}
COMMENT "Agrège les scores de détection sur une échelle de 0 à 100."
PERMISSIONS FULL;
