-- =============================================================================
-- FONCTION: fn::activate_deactivate_validation_rule
-- =============================================================================
-- DESCRIPTION: Active ou désactive une règle de validation comptable
-- PARAMETRES:
--   $rule_id: ID de la règle (obligatoire)
--   $is_active: Nouveau statut actif (obligatoire)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Activer une règle:
--   RETURN fn::activate_deactivate_validation_rule(accounting_validation_rule:xyz123, true, "admin");
--   -- Désactiver une règle:
--   RETURN fn::activate_deactivate_validation_rule(accounting_validation_rule:xyz123, false, "admin");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::activate_deactivate_validation_rule(
    $rule_id: record,
    $is_active: bool,
    $updated_by: option<string>
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
    
    -- Vérifier si le statut change réellement
    IF $existing_rule.is_active = $is_active {
        RETURN {
            success: true,
            data: $existing_rule,
            message: "La règle a déjà le statut demandé"
        };
    };
    
    -- Mettre à jour le statut
    LET $updated_rule = (UPDATE ONLY $rule_id SET
        is_active = $is_active,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    LET $action = IF $is_active { "activée" } ELSE { "désactivée" };
    
    RETURN {
        success: true,
        data: $updated_rule,
        message: "Règle de validation comptable " + $action + " avec succès"
    };
} COMMENT "Active ou désactive une règle de validation comptable."; 