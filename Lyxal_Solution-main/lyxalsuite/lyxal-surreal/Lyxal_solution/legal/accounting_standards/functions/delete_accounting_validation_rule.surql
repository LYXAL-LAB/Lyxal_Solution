-- =============================================================================
-- FONCTION: fn::delete_accounting_validation_rule
-- =============================================================================
-- DESCRIPTION: Supprime une règle de validation comptable
-- PARAMETRES:
--   $rule_id: ID de la règle à supprimer (obligatoire)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::delete_accounting_validation_rule(accounting_validation_rule:xyz123);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_accounting_validation_rule(
    $rule_id: record
) {
    -- Vérifier que la règle existe
    LET $existing_rule = (SELECT * FROM ONLY $rule_id);
    IF $existing_rule IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La règle de validation spécifiée n'existe pas"
        };
    };
    
    -- Supprimer la règle
    LET $deleted_rule = (DELETE ONLY $rule_id RETURN BEFORE);
    
    RETURN {
        success: true,
        data: $deleted_rule,
        message: "Règle de validation comptable supprimée avec succès"
    };
} COMMENT "Supprime une règle de validation comptable."; 