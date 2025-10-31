-- ================================================================================
-- Fonction d'ajout d'action d'audit
-- ================================================================================
-- DESCRIPTION: Ajoute une nouvelle action d'audit dans audit_actions
-- USAGE: Permet d'étendre les actions sans modifier le code en dur
-- ================================================================================

DEFINE FUNCTION fn::add_audit_action($params: object) {
    -- Validation des paramètres obligatoires
    IF !$params.code OR !$params.name OR !$params.category OR !$params.criticality {
        RETURN {
            success: false,
            error: "MISSING_REQUIRED_PARAMS",
            message: "Paramètres obligatoires manquants: code, name, category, criticality"
        };
    };
    
    -- Vérifier que l'action n'existe pas déjà
    LET $existing = (SELECT count() FROM audit_actions WHERE code = $params.code)[0];
    
    IF $existing.count > 0 {
        RETURN {
            success: false,
            error: "ACTION_ALREADY_EXISTS",
            message: "L'action '" + $params.code + "' existe déjà"
        };
    };
    
    -- Valider la catégorie
    IF !($params.category INSIDE ['DATA', 'STATUS', 'BULK', 'MAINTENANCE']) {
        RETURN {
            success: false,
            error: "INVALID_CATEGORY",
            message: "Catégorie invalide. Doit être: DATA, STATUS, BULK, MAINTENANCE"
        };
    };
    
    -- Valider la criticité
    IF !($params.criticality INSIDE ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']) {
        RETURN {
            success: false,
            error: "INVALID_CRITICALITY", 
            message: "Criticité invalide. Doit être: LOW, MEDIUM, HIGH, CRITICAL"
        };
    };
    
    -- Préparer les données
    LET $action_data = {
        code: $params.code,
        name: $params.name,
        description: $params.description OR "",
        category: $params.category,
        criticality: $params.criticality,
        color: $params.color OR "#6c757d", -- Gris par défaut
        icon: $params.icon OR "circle",
        is_active: $params.is_active IF $params.is_active != NONE ELSE true
    };
    
    -- Insérer la nouvelle action
    LET $inserted = INSERT INTO audit_actions $action_data RETURN AFTER;
    
    IF array::len($inserted) > 0 {
        -- Enregistrer l'audit de cette création
        LET $audit_result = fn::create_audit_entry({
            action: "CREATE",
            table_name: "audit_actions",
            record_id: $inserted[0].id,
            function_name: "fn::add_audit_action",
            new_values: $action_data,
            change_reason: "Ajout d'une nouvelle action d'audit"
        });
        
        RETURN {
            success: true,
            data: $inserted[0],
            audit_id: $audit_result.audit_id,
            message: "Action d'audit '" + $params.code + "' ajoutée avec succès"
        };
    } ELSE {
        RETURN {
            success: false,
            error: "INSERT_FAILED",
            message: "Échec de l'ajout de l'action d'audit"
        };
    };
}
PERMISSIONS 
    FOR select, create WHERE $auth.role CONTAINS 'super_admin'; 