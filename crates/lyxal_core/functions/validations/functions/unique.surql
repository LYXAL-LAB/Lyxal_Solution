-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/unique.surql
-- Fonction : fn::validation_unique
--
-- Valide qu'aucun enregistrement d'une table n'a déjà la valeur donnée dans
-- un champ, en excluant facultativement l'enregistrement en cours de
-- modification (lecture en base ; ne remplace pas un index UNIQUE).
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $target_table   : string — table interrogée (nom de table valide ; si elle n'existe pas, SurrealDB lève son erreur)
--   $target_field   : string — champ comparé à la valeur (non vide)
--   $exclude_record : option<record> — enregistrement à ignorer (même table), NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_ALREADY_EXISTS
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom de table invalide, champ vide ou $exclude_record d'une autre table
--
-- Exemple (dans une fonction de module)
--   LET $email = fn::validation_unique($params.email, "identity_user", "email", NONE);
--   IF !$email.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $email.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_unique(
    $value: any,
    $target_table: string,
    $target_field: string,
    $exclude_record: option<record>
) -> object {
    LET $table = string::trim($target_table);
    LET $target = string::trim($target_field);
    IF !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $target = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $exclude_record IS NOT NONE AND record::tb($exclude_record) != $table { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    LET $matches = SELECT VALUE id FROM type::table($table)
        WHERE type::field($target) = $value AND ($exclude_record IS NONE OR id != $exclude_record) LIMIT 1;
    IF array::len($matches) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_ALREADY_EXISTS", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur n'existe pas déjà dans un champ d'une table. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
