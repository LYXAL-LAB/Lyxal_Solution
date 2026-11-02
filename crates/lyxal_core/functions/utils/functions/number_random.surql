-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_random.surql
-- Fonction : fn::utils_number_random
--
-- Génère un entier aléatoire dans un intervalle.
--
-- Paramètres
--   $minimum : int
--   $maximum : int
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $minimum > $maximum
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_number_random(
    $minimum: int,
    $maximum: int
) -> int {
    IF $minimum > $maximum {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN rand::int($minimum,$maximum);
}
COMMENT "Génère un entier aléatoire dans un intervalle."
PERMISSIONS FULL;
