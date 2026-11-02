-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/default_value.surql
-- Fonction : fn::utils_default_value
--
-- Applique une valeur par défaut à NONE et facultativement NULL.
--
-- Paramètres
--   $value         : any
--   $default_value : any
--   $replace_null  : bool
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_default_value(
    $value: any,
    $default_value: any,
    $replace_null: bool
) -> any {
    RETURN IF $value IS NONE
        OR ($replace_null AND type::is_null($value))
    {
        $default_value
    } ELSE {
        $value
    };
}
COMMENT "Applique une valeur par défaut à NONE et facultativement NULL."
PERMISSIONS FULL;
