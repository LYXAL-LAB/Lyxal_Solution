-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_end_of_month
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_end_of_month(
    $value: datetime
) -> datetime {
    LET $start = time::group($value,"month");
    LET $year = time::year($start);
    LET $month = time::month($start);

    LET $next = IF $month = 12 {
        time::from::parts($year+1,1,1,0,0,0,0)
    } ELSE {
        time::from::parts($year,$month+1,1,0,0,0,0)
    };

    RETURN $next-1ns;
}
COMMENT "Retourne la fin du mois UTC."
PERMISSIONS FULL;
