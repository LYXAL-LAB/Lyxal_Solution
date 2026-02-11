-- =====================================================================
-- FONCTION DEACTIVATE - Sale Order Status (Soft Delete)
-- =====================================================================

DEFINE FUNCTION fn::deactivate_sale_order_status($id: record<sale_order_status>) {
    -- Vérifier que le statut existe
    LET $status = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    -- Vérifier que le statut est actif
    IF !$status.is_active {
        RETURN {
            success: true,
            message: "Le statut est déjà désactivé"
        };
    };
    
    -- Vérifier si le statut est utilisé dans des commandes
    LET $usage_count = SELECT count() FROM sale_order WHERE status_id = $id;
    IF $usage_count > 0 {
        THROW "Impossible de désactiver: " + string($usage_count) + " commande(s) utilisent ce statut";
    };
    
    -- Vérifier si c'est un statut système (optionnel)
    IF $status.code IN ["DRAFT", "CONFIRMED", "COMPLETED", "CANCELLED"] {
        THROW "Impossible de désactiver un statut système: " + $status.code;
    };
    
    -- Désactiver le statut (soft delete)
    LET $deactivated_status = UPDATE sale_order_status SET
        is_active = false,
        updated_on = time::now()
    WHERE id = $id;
    
    RETURN {
        success: true,
        message: "Statut désactivé avec succès",
        data: $deactivated_status
    };
};

-- Fonction pour désactiver par code
DEFINE FUNCTION fn::deactivate_sale_order_status_by_code($code: string) {
    LET $status = SELECT id FROM sale_order_status WHERE code = $code LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec le code: " + $code;
    };
    
    RETURN fn::deactivate_sale_order_status($status.id);
}; 