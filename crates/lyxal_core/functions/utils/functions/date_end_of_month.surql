-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_end_of_month
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_end_of_month(
    $value: datetime
) -> datetime {
    LET $start = time::group($value, "month");
    LET $year = time::year($start);
    LET $month = time::month($start);

    LET $next_year = IF $month = 12 { $year + 1 } ELSE { $year };
    LET $next_month = IF $month = 12 { 1 } ELSE { $month + 1 };

    LET $y_str = IF $next_year < 1000 {
        string::slice(string::concat("0000", <string>$next_year), string::len(<string>$next_year), string::len(<string>$next_year) + 4)
    } ELSE {
        <string>$next_year
    };
    LET $m_str = IF $next_month < 10 {
        string::concat("0", <string>$next_month)
    } ELSE {
        <string>$next_month
    };

    LET $next = <datetime>string::concat(
        $y_str, "-", $m_str, "-01T00:00:00Z"
    );

    RETURN $next - 1ns;
}
COMMENT "Retourne la fin du mois UTC."
PERMISSIONS FULL;
