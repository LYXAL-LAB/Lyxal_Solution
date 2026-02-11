-- ================================================================================
-- Fonction d'ajout de table d'audit
-- ================================================================================
-- DESCRIPTION: Ajoute une nouvelle table à auditer dans audit_tables
-- USAGE: Permet d'étendre les tables auditées sans modifier le code en dur
-- ================================================================================

DEFINE FUNCTION fn::add_audit_table($params: object) {
    -- Validation des paramètres obligatoires
    IF !$params.table_name OR !$params.module_name OR !$params.display_name {
        RETURN {
            success: false,
            error: "MISSING_REQUIRED_PARAMS",
            message: "Paramètres obligatoires manquants: table_name, module_name, display_name"
        };
    };
    
    -- Vérifier que la table n'existe pas déjà
    LET $existing = (SELECT count() FROM audit_tables WHERE table_name = $params.table_name)[0];
    
    IF $existing.count > 0 {
        RETURN {
            success: false,
            error: "TABLE_ALREADY_EXISTS",
            message: "La table '" + $params.table_name + "' est déjà configurée pour l'audit"
        };
    };
    
    -- Valider le niveau de sensibilité (si fourni)
    IF $params.sensitivity {
        LET $sensitivity_exists = (SELECT count() FROM sensitivity_level WHERE id = $params.sensitivity AND is_active = true)[0];
        
        IF $sensitivity_exists.count = 0 {
            RETURN {
                success: false,
                error: "INVALID_SENSITIVITY_LEVEL",
                message: "Niveau de sensibilité invalide ou inactif: '" + $params.sensitivity + "'"
            };
        };
    };
    
    -- Valider les actions auditées (si fournies)
    IF $params.audited_actions {
        LET $valid_actions = (SELECT VALUE code FROM audit_actions WHERE is_active = true);
        
        FOR $action IN $params.audited_actions {
            IF !array::includes($valid_actions, $action) {
                RETURN {
                    success: false,
                    error: "INVALID_AUDITED_ACTION",
                    message: "Action d'audit invalide: '" + $action + "'. Actions disponibles: " + string::join($valid_actions, ", ")
                };
            };
        };
    };
    
    -- Préparer les données avec valeurs par défaut
    LET $table_data = {
        table_name: $params.table_name,
        module_name: $params.module_name,
        display_name: $params.display_name,
        description: $params.description OR "",
        sensitivity: $params.sensitivity OR sensitivity_level:internal,
        audit_retention_days: $params.audit_retention_days OR 365,
        audit_enabled: $params.audit_enabled IF $params.audit_enabled != NONE ELSE true,
        audited_actions: $params.audited_actions OR ["CREATE", "UPDATE", "DELETE"],
        is_active: $params.is_active IF $params.is_active != NONE ELSE true
    };
    
    -- Insérer la nouvelle table
    LET $inserted = INSERT INTO audit_tables $table_data RETURN AFTER;
    
    IF array::len($inserted) > 0 {
        -- Enregistrer l'audit de cette création
        LET $audit_result = fn::create_audit_entry({
            action: "CREATE",
            table_name: "audit_tables",
            record_id: $inserted[0].id,
            function_name: "fn::add_audit_table",
            new_values: $table_data,
            change_reason: "Ajout d'une nouvelle table à auditer"
        });
        
        RETURN {
            success: true,
            data: $inserted[0],
            audit_id: $audit_result.audit_id,
            message: "Table '" + $params.table_name + "' ajoutée à l'audit avec succès"
        };
    } ELSE {
        RETURN {
            success: false,
            error: "INSERT_FAILED",
            message: "Échec de l'ajout de la table à l'audit"
        };
    };
}
PERMISSIONS 
    FOR select, create WHERE $auth.role CONTAINS 'super_admin'; 