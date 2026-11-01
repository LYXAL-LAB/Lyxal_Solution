-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/date_range.surql
-- Fonction : fn::sanitize_date_range
--
-- Ordonne un intervalle de datetimes : renvoie { start, end } tel quel s'il
-- est dans l'ordre, inversé si demandé ; sinon l'intervalle inversé est une
-- erreur de l'appelant (le valider avant avec fn::validation_date_range ou
-- fn::validation_time_range).
--
-- Paramètres
--   $start            : any — début (datetime, ou NONE)
--   $end              : any — fin (datetime, ou NONE)
--   $swap_if_reversed : bool — true pour inverser un intervalle à l'envers
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : { start, end } (NONE si une borne est NONE)
--   Entrée          : NONE si une borne est NONE ; CORE_SANITIZE_INVALID_TYPE si une borne n'est ni NONE ni un datetime
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : intervalle à l'envers sans $swap_if_reversed
--
-- Exemple
--   LET $range = fn::sanitize_date_range($params.start_at, $params.end_at, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_date_range(
    $start: any,
    $end: any,
    $swap_if_reversed: bool
) -> option<object> {
    IF $start IS NONE OR $end IS NONE { RETURN NONE; };
    IF !type::is_datetime($start) OR !type::is_datetime($end) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    IF $start <= $end { RETURN { start: $start, end: $end }; };
    IF !$swap_if_reversed { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN { start: $end, end: $start };
}
COMMENT "Ordonne un intervalle de datetimes : renvoie { start, end } tel quel s'il est dans l'ordre, inversé si demandé."
PERMISSIONS FULL;
