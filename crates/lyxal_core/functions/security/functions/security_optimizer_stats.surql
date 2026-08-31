-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_stats(
    $compiled_schema: object
) -> object {
    LET $fields = object::entries($compiled_schema.compiled_fields);

    RETURN {
        field_count:array::len($fields),
        step_count:array::fold(
            $fields,
            0,
            |$count,$entry| $count + array::len($entry[1].steps)
        ),
        total_cost:array::fold(
            $fields,
            0,
            |$cost,$entry| $cost + fn::security_optimizer_cost($entry[1].steps)
        )
    };
}
COMMENT "Calcule les statistiques d'un schéma Security optimisé."
PERMISSIONS FULL;
