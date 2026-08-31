-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_strings
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_strings(
    $left: string,
    $right: string,
    $case_sensitive: bool,
    $trim: bool
) -> int {
    LET $a = IF $trim { string::trim($left) } ELSE { $left };
    LET $b = IF $trim { string::trim($right) } ELSE { $right };

    LET $a = IF $case_sensitive { $a } ELSE { string::lowercase($a) };
    LET $b = IF $case_sensitive { $b } ELSE { string::lowercase($b) };

    RETURN IF $a = $b {
        0
    } ELSE IF $a < $b {
        -1
    } ELSE {
        1
    };
}
COMMENT "Compare lexicalement deux chaînes."
PERMISSIONS FULL;
