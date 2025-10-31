-- ================================================================================
-- Fonction de validation des entrées d'audit
-- ================================================================================
-- DESCRIPTION: Valide qu'une action et une table sont autorisées pour l'audit
-- USAGE: Appelée avant d'insérer dans system_references_audit
-- ================================================================================

DEFINE FUNCTION fn::validate_audit_entry($action: string, $table_name: string) {
    -- Vérifier que l'action existe et est active
    LET $action_exists = (SELECT count() FROM audit_actions 
        WHERE code = $action AND is_active = true)[0];
    
    -- Vérifier que la table existe et l'audit est activé
    LET $table_config = (SELECT * FROM audit_tables 
        WHERE table_name = $table_name AND is_active = true AND audit_enabled = true)[0];
    
    -- Vérifier que cette action est autorisée pour cette table
    LET $action_allowed = IF $table_config {
        array::includes($table_config.audited_actions, $action)
    } ELSE {
        false
    };
    
    -- Construire la réponse
    IF $action_exists.count = 0 {
        RETURN {
            is_valid: false,
            error: "ACTION_NOT_FOUND",
            message: "L'action '" + $action + "' n'existe pas ou n'est pas active",
            details: {
                action: $action,
                table_name: $table_name
            }
        };
    };
    
    IF !$table_config {
        RETURN {
            is_valid: false,
            error: "TABLE_NOT_AUDITABLE", 
            message: "La table '" + $table_name + "' n'est pas configurée pour l'audit",
            details: {
                action: $action,
                table_name: $table_name
            }
        };
    };
    
    IF !$action_allowed {
        RETURN {
            is_valid: false,
            error: "ACTION_NOT_ALLOWED_FOR_TABLE",
            message: "L'action '" + $action + "' n'est pas autorisée pour la table '" + $table_name + "'",
            details: {
                action: $action,
                table_name: $table_name,
                allowed_actions: $table_config.audited_actions
            }
        };
    };
    
    -- Tout est valide
    RETURN {
        is_valid: true,
        message: "Entrée d'audit valide",
        action_info: (SELECT * FROM audit_actions WHERE code = $action)[0],
        table_info: $table_config
    };
}
PERMISSIONS 
    FOR select FULL; 