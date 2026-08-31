-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_random
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_random(
    $minimum: int,
    $maximum: int
) -> int {
    IF $minimum > $maximum {
        THROW "UTILS_INVALID_RANDOM_RANGE";
    };

    RETURN rand::int($minimum,$maximum);
}
COMMENT "Génère un entier aléatoire dans un intervalle."
PERMISSIONS FULL;
