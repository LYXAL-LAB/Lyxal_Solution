-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compile_object_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compile_object_schema(
    $schema: object
) -> object {
    RETURN object::from_entries(
        array::map(
            object::entries($schema),
            |$entry| [
                $entry[0],
                fn::validation_compile_field_rule($entry[0],$entry[1])
            ]
        )
    );
}
COMMENT "Compile tous les champs d'un schéma d'objet en pipelines."
PERMISSIONS FULL;
