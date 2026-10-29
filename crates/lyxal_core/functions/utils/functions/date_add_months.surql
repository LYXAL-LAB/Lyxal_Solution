-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_add_months
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_add_months(
    $value: datetime,
    $months: int
) -> datetime {
    LET $year = time::year($value);
    LET $month = time::month($value);
    LET $day = time::day($value);
    LET $hour = time::hour($value);
    LET $minute = time::minute($value);
    LET $second = time::second($value);

    LET $absolute = ($year * 12) + ($month - 1) + $months;
    LET $target_year = type::int(math::floor(type::float($absolute) / 12f));
    LET $target_month = (($absolute % 12) + 12) % 12 + 1;

    LET $is_leap = ($target_year % 4 = 0 AND $target_year % 100 != 0)
        OR ($target_year % 400 = 0);

    LET $max_day = IF $target_month = 2 {
        IF $is_leap { 29 } ELSE { 28 }
    } ELSE IF [4, 6, 9, 11] CONTAINS $target_month {
        30
    } ELSE {
        31
    };

    LET $clamped_day = IF $day > $max_day { $max_day } ELSE { $day };

    LET $y_str = IF $target_year < 1000 {
        string::slice(string::concat("0000", <string>$target_year), string::len(<string>$target_year), string::len(<string>$target_year) + 4)
    } ELSE {
        <string>$target_year
    };
    LET $m_str = IF $target_month < 10 { string::concat("0", <string>$target_month) } ELSE { <string>$target_month };
    LET $d_str = IF $clamped_day < 10 { string::concat("0", <string>$clamped_day) } ELSE { <string>$clamped_day };
    LET $hh_str = IF $hour < 10 { string::concat("0", <string>$hour) } ELSE { <string>$hour };
    LET $mm_str = IF $minute < 10 { string::concat("0", <string>$minute) } ELSE { <string>$minute };
    LET $ss_str = IF $second < 10 { string::concat("0", <string>$second) } ELSE { <string>$second };

    RETURN <datetime>string::concat(
        $y_str, "-", $m_str, "-", $d_str,
        "T",
        $hh_str, ":", $mm_str, ":", $ss_str,
        "Z"
    );
}
COMMENT "Ajoute un nombre de mois à une date."
PERMISSIONS FULL;
