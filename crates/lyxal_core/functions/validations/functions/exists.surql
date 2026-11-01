-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/exists.surql
-- Fonction : fn::validation_exists
--
-- Valide qu'au moins un enregistrement d'une table a la valeur donnée dans
-- un champ (lecture en base).
--
-- Paramètres
--   $value        : any — valeur recherchée
--   $target_table : string — table interrogée (nom de table valide ; si elle n'existe pas, SurrealDB lève son erreur)
--   $target_field : string — champ comparé à la valeur (non vide)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_NOT_FOUND
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom de table invalide ou champ vide
--
-- Exemple (dans une fonction de module)
--   LET $category = fn::validation_exists($params.category_code, "catalogue_category", "code");
--   IF !$category.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $category.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_exists(
    $value: any,
    $target_table: string,
    $target_field: string
) -> object {
    LET $table = string::trim($target_table);
    LET $target = string::trim($target_field);
    IF !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $target = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    LET $matches = SELECT VALUE id FROM type::table($table) WHERE type::field($target) = $value LIMIT 1;
    IF array::len($matches) = 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur existe dans un champ d'une table. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
