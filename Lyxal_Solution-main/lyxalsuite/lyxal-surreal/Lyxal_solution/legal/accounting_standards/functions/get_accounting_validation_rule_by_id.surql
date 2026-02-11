-- =============================================================================
-- FONCTION: fn::get_accounting_validation_rule_by_id
-- =============================================================================
-- DESCRIPTION: Récupère une règle de validation comptable par son ID
-- PARAMETRES:
--   $rule_id: ID de la règle (obligatoire)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::get_accounting_validation_rule_by_id(accounting_validation_rule:xyz123);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_accounting_validation_rule_by_id(
    $rule_id: record
) {
    -- Récupérer la règle avec ses relations
    LET $rule = (
        SELECT *,
            accounting_standard.* AS standard_data,
            applicable_accounts.* AS accounts_data
        FROM ONLY $rule_id
        FETCH accounting_standard, applicable_accounts
    );
    
    IF $rule IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La règle de validation spécifiée n'existe pas"
        };
    };
    
    RETURN {
        success: true,
        data: $rule,
        message: "Règle de validation comptable récupérée avec succès"
    };
} COMMENT "Récupère une règle de validation comptable par son ID avec ses relations."; 