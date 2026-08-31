-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_unknown_keys_policy
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_unknown_keys_policy(
    $value: object,
    $allowed_keys: array<string>,
    $policy: string,
    $field: string
) -> object {
    LET $clean_policy = string::lowercase(string::trim($policy));
    LET $unknown = array::filter(object::keys($value), |$k| !array::contains($allowed_keys,$k));
    IF !array::contains(["allow","reject","strip"],$clean_policy) {
        THROW "VALIDATION_INVALID_UNKNOWN_KEYS_POLICY";
    };
    IF $clean_policy = "reject" AND array::len($unknown) > 0 {
        THROW string::concat(string::trim($field), "_UNKNOWN_KEY");
    };
    IF $clean_policy = "strip" {
        RETURN object::from_entries(
            array::filter(object::entries($value), |$e| array::contains($allowed_keys,$e[0]))
        );
    };
    RETURN $value;
}
COMMENT "Applique une politique allow, reject ou strip aux clés inconnues."
PERMISSIONS FULL;
