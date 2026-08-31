-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_pascal_case
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_pascal_case(
    $value: string
) -> string {
    LET $camel = fn::utils_string_camel_case($value);

    RETURN IF string::len($camel) = 0 {
        ""
    } ELSE {
        string::concat(
            string::uppercase(
                string::slice($camel,0,1)
            ),
            string::slice(
                $camel,
                1,
                string::len($camel)
            )
        )
    };
}
COMMENT "Transforme une chaîne en PascalCase."
PERMISSIONS FULL;
