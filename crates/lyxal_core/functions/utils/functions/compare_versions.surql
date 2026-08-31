-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_versions
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_versions(
    $left: string,
    $right: string
) -> int {
    LET $a = array::map(
        string::split(
            string::replace(string::lowercase(string::trim($left)),<regex>"^v",""),
            "."
        ),
        |$part| <int>$part
    );

    LET $b = array::map(
        string::split(
            string::replace(string::lowercase(string::trim($right)),<regex>"^v",""),
            "."
        ),
        |$part| <int>$part
    );

    LET $length = math::max([array::len($a),array::len($b)]);

    LET $result = array::fold(
        array::range(0,$length),
        0,
        |$current,$index| IF $current != 0 {
            $current
        } ELSE {
            LET $av = IF $a[$index] IS NONE { 0 } ELSE { $a[$index] };
            LET $bv = IF $b[$index] IS NONE { 0 } ELSE { $b[$index] };

            IF $av < $bv { -1 } ELSE IF $av > $bv { 1 } ELSE { 0 }
        }
    );

    RETURN $result;
}
COMMENT "Compare deux versions numériques de type v1.2.3."
PERMISSIONS FULL;
