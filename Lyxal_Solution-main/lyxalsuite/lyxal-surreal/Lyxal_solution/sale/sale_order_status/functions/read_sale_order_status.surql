-- =====================================================================
-- FONCTION READ - Sale Order Status
-- =====================================================================

-- Fonction pour lire un statut par ID
DEFINE FUNCTION fn::read_sale_order_status($id: record<sale_order_status>) {
    LET $status = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    
    IF !$status {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    RETURN {
        success: true,
        data: $status
    };
};

-- Fonction pour lire un statut par code
DEFINE FUNCTION fn::read_sale_order_status_by_code($code: string) {
    LET $status = SELECT * FROM sale_order_status WHERE code = $code LIMIT 1;
    
    IF !$status {
        THROW "Statut non trouvé avec le code: " + $code;
    };
    
    RETURN {
        success: true,
        data: $status
    };
};

-- Fonction pour lire avec détails d'utilisation
DEFINE FUNCTION fn::read_sale_order_status_with_usage($id: record<sale_order_status>) {
    LET $status = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    
    IF !$status {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    -- Compter les commandes utilisant ce statut
    LET $usage_count = SELECT count() FROM sale_order WHERE status_id = $id;
    
    RETURN {
        success: true,
        data: {
            status: $status,
            usage_count: $usage_count,
            can_delete: $usage_count == 0
        }
    };
}; 