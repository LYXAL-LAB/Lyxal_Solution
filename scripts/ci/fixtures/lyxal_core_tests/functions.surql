-- Fonctions jouets utilisées par l'auto-test de scripts/ci/test_lyxal_core.py.
DEFINE FUNCTION OVERWRITE fn::selftest_add($a: int, $b: int) -> int {
    RETURN $a + $b;
} COMMENT "Addition, pour l'auto-test du banc." PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::selftest_check($value: int) -> object {
    IF $value < 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };
    RETURN { valid: $value > 10, value: $value, code: IF $value > 10 { NONE } ELSE { "CORE_VALIDATION_TOO_SMALL" }, details: {} };
} COMMENT "Résultat de validation, pour l'auto-test du banc." PERMISSIONS FULL;
