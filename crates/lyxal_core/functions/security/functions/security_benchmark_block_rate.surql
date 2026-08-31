-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_benchmark_block_rate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_benchmark_block_rate(
    $samples: array<object>
) -> decimal {
    IF array::len($samples)=0 {
        RETURN 0dec;
    };

    RETURN type::decimal(
        array::len(
            array::filter($samples,|$sample|$sample.blocked=true)
        )
    ) / type::decimal(array::len($samples));
}
COMMENT "Calcule le taux de blocage observé."
PERMISSIONS FULL;
