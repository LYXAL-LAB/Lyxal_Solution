-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_sample.surql
-- Fonction : fn::utils_array_sample
--
-- Retourne un échantillon aléatoire sans remise.
--
-- Paramètres
--   $value : array<any>
--   $count : int
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $count < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_sample(
    $value: array<any>,
    $count: int
) -> array<any> {
    IF $count < 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN array::slice(
        array::shuffle($value),
        0,
        IF $count > array::len($value) {
            array::len($value)
        } ELSE {
            $count
        }
    );
}
COMMENT "Retourne un échantillon aléatoire sans remise."
PERMISSIONS FULL;
