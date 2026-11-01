-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/siret.surql
-- Fonction : fn::validation_siret
--
-- Valide un numéro SIRET : 14 chiffres (espaces et tirets retirés) avec clé
-- de Luhn exacte ; renvoie aussi le SIREN et le NIC.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { siret, siren, nic }, code = NONE
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
--   LET $siret = fn::validation_siret($params.siret);
--   IF !$siret.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $siret.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_siret(
    $value: any
) -> object {
    LET $check = fn::validation_luhn($value, 14, 14);
    IF !$check.valid { RETURN $check; };
    RETURN { valid: true, value: { siret: $check.value, siren: string::slice($check.value, 0, 9), nic: string::slice($check.value, 9, 14) }, code: NONE, details: {} };
}
COMMENT "Valide un SIRET et le décompose. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
