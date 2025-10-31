-- =====================================================================
-- FONCTION DELETE - Sale Order Status (Hard Delete - Usage restreint)
-- =====================================================================

DEFINE FUNCTION fn::delete_sale_order_status($id: record<sale_order_status>, $force: bool) {
    -- Vérifier que le statut existe
    LET $status = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    -- Vérifier si le statut est utilisé dans des commandes
    LET $usage_count = SELECT count() FROM sale_order WHERE status_id = $id;
    IF $usage_count > 0 AND !$force {
        THROW "Impossible de supprimer: " + string($usage_count) + " commande(s) utilisent ce statut. Utilisez force=true pour forcer la suppression.";
    };
    
    -- Vérifier si c'est un statut système
    IF $status.code IN ["DRAFT", "CONFIRMED", "COMPLETED", "CANCELLED"] AND !$force {
        THROW "Impossible de supprimer un statut système: " + $status.code + ". Utilisez force=true pour forcer la suppression.";
    };
    
    -- Si force=true et que le statut est utilisé, mettre à jour les commandes
    IF $usage_count > 0 AND $force {
        -- Trouver un statut de remplacement (DRAFT par défaut)
        LET $replacement_status = SELECT id FROM sale_order_status 
                                 WHERE code = "DRAFT" AND is_active = true LIMIT 1;
        
        IF !$replacement_status {
            THROW "Impossible de trouver un statut de remplacement actif";
        };
        
        -- Mettre à jour toutes les commandes utilisant ce statut
        UPDATE sale_order SET 
            status_id = $replacement_status.id,
            updated_on = time::now()
        WHERE status_id = $id;
    };
    
    -- Supprimer définitivement le statut
    DELETE sale_order_status WHERE id = $id;
    
    RETURN {
        success: true,
        message: "Statut supprimé définitivement",
        affected_orders: $usage_count,
        forced: $force
    };
};

-- Fonction pour supprimer par code
DEFINE FUNCTION fn::delete_sale_order_status_by_code($code: string, $force: bool) {
    LET $status = SELECT id FROM sale_order_status WHERE code = $code LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec le code: " + $code;
    };
    
    RETURN fn::delete_sale_order_status($status.id, $force);
};

-- Fonction pour nettoyer les statuts inactifs et non utilisés
DEFINE FUNCTION fn::cleanup_unused_sale_order_status() {
    -- Trouver les statuts inactifs et non utilisés
    LET $unused_statuses = SELECT id, code, name FROM sale_order_status 
                          WHERE is_active = false 
                          AND id NOT IN (SELECT status_id FROM sale_order WHERE status_id IS NOT NULL);
    
    LET $deleted_count = 0;
    FOR $status IN $unused_statuses {
        DELETE sale_order_status WHERE id = $status.id;
        $deleted_count = $deleted_count + 1;
    };
    
    RETURN {
        success: true,
        message: "Nettoyage terminé",
        deleted_count: $deleted_count,
        deleted_statuses: $unused_statuses
    };
}; 