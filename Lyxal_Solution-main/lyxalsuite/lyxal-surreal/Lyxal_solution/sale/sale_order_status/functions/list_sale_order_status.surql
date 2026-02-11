-- =====================================================================
-- FONCTION LIST - Sale Order Status
-- =====================================================================

-- Fonction pour lister tous les statuts actifs
DEFINE FUNCTION fn::list_sale_order_status() {
    LET $statuses = SELECT * FROM sale_order_status 
                   WHERE is_active = true 
                   ORDER BY sequence, name;
    
    RETURN {
        success: true,
        data: $statuses,
        count: count($statuses)
    };
};

-- Fonction pour lister tous les statuts (actifs et inactifs)
DEFINE FUNCTION fn::list_all_sale_order_status() {
    LET $statuses = SELECT * FROM sale_order_status 
                   ORDER BY is_active DESC, sequence, name;
    
    RETURN {
        success: true,
        data: $statuses,
        count: count($statuses)
    };
};

-- Fonction pour lister avec pagination
DEFINE FUNCTION fn::list_sale_order_status_paginated($page: int, $limit: int, $include_inactive: bool) {
    LET $offset = ($page - 1) * $limit;
    
    LET $query = IF $include_inactive {
        SELECT * FROM sale_order_status 
        ORDER BY is_active DESC, sequence, name
        LIMIT $limit START $offset
    } ELSE {
        SELECT * FROM sale_order_status 
        WHERE is_active = true 
        ORDER BY sequence, name
        LIMIT $limit START $offset
    };
    
    LET $total_query = IF $include_inactive {
        SELECT count() FROM sale_order_status
    } ELSE {
        SELECT count() FROM sale_order_status WHERE is_active = true
    };
    
    RETURN {
        success: true,
        data: $query,
        pagination: {
            page: $page,
            limit: $limit,
            total: $total_query,
            has_next: ($offset + $limit) < $total_query
        }
    };
};

-- Fonction pour lister avec statistiques d'utilisation
DEFINE FUNCTION fn::list_sale_order_status_with_stats() {
    LET $statuses = SELECT 
        *,
        (SELECT count() FROM sale_order WHERE status_id = $parent.id) AS usage_count
    FROM sale_order_status 
    WHERE is_active = true 
    ORDER BY sequence, name;
    
    RETURN {
        success: true,
        data: $statuses,
        count: count($statuses)
    };
};

-- Fonction pour rechercher par nom ou code
DEFINE FUNCTION fn::search_sale_order_status($search: string, $include_inactive: bool) {
    LET $search_pattern = "%" + $search + "%";
    
    LET $query = IF $include_inactive {
        SELECT * FROM sale_order_status 
        WHERE (name LIKE $search_pattern OR code LIKE $search_pattern)
        ORDER BY is_active DESC, sequence, name
    } ELSE {
        SELECT * FROM sale_order_status 
        WHERE (name LIKE $search_pattern OR code LIKE $search_pattern)
        AND is_active = true 
        ORDER BY sequence, name
    };
    
    RETURN {
        success: true,
        data: $query,
        count: count($query),
        search_term: $search
    };
};

-- Fonction pour obtenir les statuts suivants possibles
DEFINE FUNCTION fn::get_next_possible_statuses($current_status_id: record<sale_order_status>) {
    LET $current = SELECT sequence FROM sale_order_status WHERE id = $current_status_id LIMIT 1;
    
    IF !$current {
        THROW "Statut actuel non trouvé";
    };
    
    -- Règle métier : on peut avancer ou revenir au brouillon
    LET $next_statuses = SELECT * FROM sale_order_status 
                        WHERE is_active = true 
                        AND (sequence > $current.sequence OR code = "DRAFT")
                        AND id != $current_status_id
                        ORDER BY sequence;
    
    RETURN {
        success: true,
        data: $next_statuses,
        count: count($next_statuses)
    };
}; 