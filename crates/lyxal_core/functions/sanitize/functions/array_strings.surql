-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_strings
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_strings(
    $value: array<any>,
    $trim: bool,
    $lowercase: bool
) -> array<string> {
    RETURN array::map(
        array::filter($value, |$item| type::is_string($item)),
        |$item| {
            LET $v = IF $trim { string::trim($item) } ELSE { $item };
            IF $lowercase { string::lowercase($v) } ELSE { $v }
        }
    );
}
COMMENT "Conserve et normalise les chaînes d'un tableau."
PERMISSIONS FULL;
