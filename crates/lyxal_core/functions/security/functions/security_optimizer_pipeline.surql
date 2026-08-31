-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_pipeline(
    $pipeline: array<object>
) -> object {
    LET $validated = fn::security_optimizer_validate($pipeline);
    LET $deduplicated = fn::security_optimizer_remove_duplicates($validated);
    LET $ordered = fn::security_optimizer_order($deduplicated);
    LET $clean = array::map(
        $ordered,
        |$step| object::from_entries(
            array::filter(
                object::entries($step),
                |$entry| !string::starts_with($entry[0],"_")
            )
        )
    );

    RETURN {
        original:$pipeline,
        optimized:$clean,
        original_count:array::len($pipeline),
        optimized_count:array::len($clean),
        original_cost:fn::security_optimizer_cost($pipeline),
        optimized_cost:fn::security_optimizer_cost($clean)
    };
}
COMMENT "Optimise un pipeline Security complet."
PERMISSIONS FULL;
