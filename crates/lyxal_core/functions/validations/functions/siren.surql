-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/siren.surql
-- Fonction : fn::validation_siren
--
-- Valide un numéro SIREN : 9 chiffres (espaces et tirets retirés) avec clé
-- de Luhn exacte.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = les 9 chiffres, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Exemple (dans une fonction de module)
--   LET $siren = fn::validation_siren($params.siren);
--   IF !$siren.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $siren.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_siren(
    $value: any
) -> object {
    RETURN fn::validation_luhn($value, 9, 9);
}
COMMENT "Valide un SIREN (9 chiffres, clé de Luhn). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
