-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_pascal_case.surql
-- Fonction : fn::utils_string_pascal_case
--
-- Transforme une chaîne en PascalCase.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
