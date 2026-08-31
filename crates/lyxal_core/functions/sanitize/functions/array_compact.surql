-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_compact
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_compact(
    $value: array<any>,
    $remove_null: bool,
    $remove_blank_strings: bool
) -> array<any> {
    RETURN array::filter(
        $value,
        |$item|
            $item IS NOT NONE
            AND (!$remove_null OR !type::is_null($item))
            AND (
                !$remove_blank_strings
                OR !type::is_string($item)
                OR string::trim($item) != ""
            )
    );
}
COMMENT "Retire NONE et facultativement NULL et les chaînes blanches."
PERMISSIONS FULL;
