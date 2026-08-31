-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_object_normalize
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_normalize(
    $value: object,
    $allowed_keys: option<array<string>>,
    $defaults: option<object>,
    $remove_empty: bool
) -> object {
    LET $v = IF $allowed_keys IS NONE {
        $value
    } ELSE {
        fn::sanitize_remove_unknown_keys($value,$allowed_keys)
    };
    LET $v = IF $defaults IS NONE {
        $v
    } ELSE {
        fn::sanitize_default_values($v,$defaults)
    };
    RETURN IF $remove_empty {
        fn::sanitize_remove_empty($v,true,true,true,true)
    } ELSE {
        $v
    };
}
COMMENT "Normalise un objet avec whitelist, valeurs par défaut et suppression du vide."
PERMISSIONS FULL;
