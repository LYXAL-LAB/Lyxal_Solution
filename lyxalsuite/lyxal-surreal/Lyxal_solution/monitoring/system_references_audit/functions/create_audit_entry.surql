-- ================================================================================
-- Fonction de création d'entrée d'audit
-- ================================================================================
-- DESCRIPTION: Crée une entrée d'audit avec validation automatique
-- USAGE: Simplification pour les fonctions de modification
-- ================================================================================

DEFINE FUNCTION fn::create_audit_entry($params: object) {
    -- Validation des paramètres obligatoires
    IF !$params.action OR !$params.table_name OR !$params.record_id {
        RETURN {
            success: false,
            error: "MISSING_REQUIRED_PARAMS",
            message: "Paramètres obligatoires manquants: action, table_name, record_id"
        };
    };
    
    -- Valider que l'action et la table sont autorisées
    LET $validation = fn::validate_audit_entry($params.action, $params.table_name);
    
    IF !$validation.is_valid {
        RETURN {
            success: false,
            error: $validation.error,
            message: $validation.message,
            details: $validation.details
        };
    };
    
    -- Préparer l'entrée d'audit
    LET $audit_entry = {
        action: $params.action,
        table_name: $params.table_name,
        record_id: $params.record_id,
        
        -- Informations utilisateur (avec valeurs par défaut)
        user_id: $params.user_id OR $auth.id OR "system",
        user_role: $params.user_role OR $auth.role OR "unknown", 
        user_name: $params.user_name OR $auth.name,
        
        -- Informations techniques
        function_name: $params.function_name OR "unknown",
        operation_type: $params.operation_type OR "SINGLE",
        
        -- Données modifiées
        old_values: $params.old_values OR {},
        new_values: $params.new_values OR {},
        changed_fields: $params.changed_fields OR [],
        
        -- Contexte
        change_reason: $params.change_reason,
        business_context: $params.business_context,
        
        -- Session
        ip_address: $params.ip_address OR $session.ip,
        session_id: $params.session_id OR $session.id,
        user_agent: $params.user_agent OR $session.user_agent,
        
        -- Métadonnées
        execution_time_ms: $params.execution_time_ms,
        success: $params.success IF $params.success != NONE ELSE true,
        error_message: $params.error_message,
        
        -- Corrélation
        correlation_id: $params.correlation_id,
        parent_operation_id: $params.parent_operation_id
    };
    
    -- Insérer l'entrée d'audit
    LET $inserted = INSERT INTO system_references_audit $audit_entry RETURN id;
    
    IF array::len($inserted) > 0 {
        RETURN {
            success: true,
            audit_id: $inserted[0].id,
            message: "Entrée d'audit créée avec succès"
        };
    } ELSE {
        RETURN {
            success: false,
            error: "INSERT_FAILED",
            message: "Échec de la création de l'entrée d'audit"
        };
    };
}
PERMISSIONS 
    FOR select, create WHERE $auth.role CONTAINS 'system' 
        OR $auth.permissions CONTAINS 'audit:write'; 