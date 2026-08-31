-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compile_field_rule
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compile_field_rule(
    $field: string,
    $schema: object
) -> array<object> {
    LET $steps = [];
    LET $steps = IF $schema.required = true { array::append($steps,{rule:"required"}) } ELSE { $steps };
    LET $steps = IF $schema.default IS NOT NONE { array::append($steps,{rule:"default",value:$schema.default}) } ELSE { $steps };
    LET $steps = IF $schema.trim = true { array::append($steps,{rule:"trim"}) } ELSE { $steps };
    LET $steps = IF $schema.lowercase = true { array::append($steps,{rule:"lowercase"}) } ELSE { $steps };
    LET $steps = IF $schema.uppercase = true { array::append($steps,{rule:"uppercase"}) } ELSE { $steps };
    LET $steps = IF $schema.min_length IS NOT NONE { array::append($steps,{rule:"min_length",value:$schema.min_length}) } ELSE { $steps };
    LET $steps = IF $schema.max_length IS NOT NONE { array::append($steps,{rule:"max_length",value:$schema.max_length}) } ELSE { $steps };
    LET $steps = IF $schema.pattern IS NOT NONE { array::append($steps,{rule:"pattern",value:$schema.pattern}) } ELSE { $steps };
    LET $steps = IF $schema.enum IS NOT NONE { array::append($steps,{rule:"enum",value:$schema.enum}) } ELSE { $steps };
    RETURN $steps;
}
COMMENT "Compile un schéma de champ en étapes de pipeline."
PERMISSIONS FULL;
