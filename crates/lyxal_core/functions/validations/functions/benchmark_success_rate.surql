-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_benchmark_success_rate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_benchmark_success_rate(
    $samples: array<object>
) -> decimal {
    IF array::len($samples) = 0 {
        RETURN 0dec;
    };

    LET $successes = array::len(
        array::filter(
            $samples,
            |$sample| $sample.success = true
        )
    );

    RETURN type::decimal($successes)
        / type::decimal(array::len($samples));
}
COMMENT "
Calcule le taux de succès d'un ensemble d'échantillons.
"
PERMISSIONS FULL;
