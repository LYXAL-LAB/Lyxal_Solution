-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_add_months
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_add_months(
    $value: datetime,
    $months: int
) -> datetime {
    LET $year = time::year($value);
    LET $month = time::month($value);
    LET $day = time::day($value);

    LET $absolute = ($year*12)+($month-1)+$months;
    LET $target_year = math::floor($absolute/12);
    LET $target_month = ($absolute % 12)+1;

    RETURN time::from::parts(
        type::int($target_year),
        type::int($target_month),
        $day,
        time::hour($value),
        time::minute($value),
        time::second($value),
        0
    );
}
COMMENT "Ajoute un nombre de mois à une date."
PERMISSIONS FULL;
