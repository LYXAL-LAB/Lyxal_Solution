-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_pipeline(
    $value: array<any>,
    $unique: bool,
    $compact: bool,
    $limit: option<int>
) -> array<any> {
    LET $v = IF $compact {
        fn::sanitize_array_compact($value, true, true)
    } ELSE {
        $value
    };
    LET $v = IF $unique {
        fn::sanitize_array_unique($v)
    } ELSE {
        $v
    };
    RETURN IF $limit IS NONE {
        $v
    } ELSE {
        fn::sanitize_array_limit($v, $limit)
    };
}
COMMENT "Applique un pipeline simple compact, unique et limit."
PERMISSIONS FULL;
