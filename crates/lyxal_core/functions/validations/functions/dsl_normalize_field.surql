-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_normalize_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_normalize_field(
    $definition: object
) -> object {
    RETURN {
        required: IF $definition.required IS NONE {
            false
        } ELSE {
            $definition.required
        },
        nullable: IF $definition.nullable IS NONE {
            false
        } ELSE {
            $definition.nullable
        },
        type: $definition.type,
        default: $definition.default,
        trim: IF $definition.trim IS NONE {
            false
        } ELSE {
            $definition.trim
        },
        lowercase: IF $definition.lowercase IS NONE {
            false
        } ELSE {
            $definition.lowercase
        },
        uppercase: IF $definition.uppercase IS NONE {
            false
        } ELSE {
            $definition.uppercase
        },
        min_length: $definition.min_length,
        max_length: $definition.max_length,
        min: $definition.min,
        max: $definition.max,
        pattern: $definition.pattern,
        enum: $definition.enum
    };
}
COMMENT "
Normalise une définition de champ DSL avec ses valeurs par défaut.
"
PERMISSIONS FULL;
