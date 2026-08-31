-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_remove_empty
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_empty(
    $value: object,
    $remove_null: bool,
    $remove_blank_strings: bool,
    $remove_empty_arrays: bool,
    $remove_empty_objects: bool
) -> object {
    RETURN object::from_entries(
        array::filter(
            object::entries($value),
            |$entry|
                $entry[1] IS NOT NONE
                AND (!$remove_null OR !type::is_null($entry[1]))
                AND (
                    !$remove_blank_strings
                    OR !type::is_string($entry[1])
                    OR string::trim($entry[1]) != ""
                )
                AND (
                    !$remove_empty_arrays
                    OR !type::is_array($entry[1])
                    OR array::len($entry[1]) > 0
                )
                AND (
                    !$remove_empty_objects
                    OR !type::is_object($entry[1])
                    OR object::len($entry[1]) > 0
                )
        )
    );
}
COMMENT "Supprime les propriétés vides selon une politique configurable."
PERMISSIONS FULL;
