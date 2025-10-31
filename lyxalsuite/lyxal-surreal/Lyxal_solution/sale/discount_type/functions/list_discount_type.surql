-- =====================================================
-- FONCTIONS DE LISTAGE: discount_type
-- Description: Fonctions pour lister et filtrer les types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: list_discount_types
-- Description: Liste paginée des types de remise
-- =====================================================

DEFINE FUNCTION fn::list_discount_types(
    $page: int,
    $limit: int,
    $sort_by: string,
    $sort_order: string,
    $filters: object
) {
    -- Paramètres par défaut
    LET $current_page = $page OR 1;
    LET $page_size = $limit OR 20;
    LET $sort_field = $sort_by OR "sequence";
    LET $sort_direction = $sort_order OR "ASC";
    LET $offset = ($current_page - 1) * $page_size;
    
    -- Construction de la clause WHERE
    LET $where_conditions = [];
    
    -- Filtre par statut actif
    IF $filters.is_active != NONE {
        $where_conditions = array::push($where_conditions, "is_active = " + string::concat($filters.is_active));
    };
    
    -- Filtre par méthode de calcul
    IF $filters.calculation_method {
        $where_conditions = array::push($where_conditions, "calculation_method = '" + $filters.calculation_method + "'");
    };
    
    -- Filtre par recherche textuelle
    IF $filters.search {
        $where_conditions = array::push($where_conditions, 
            "(string::lowercase(code) CONTAINS string::lowercase('" + $filters.search + "') OR " +
            "string::lowercase(name) CONTAINS string::lowercase('" + $filters.search + "') OR " +
            "string::lowercase(description) CONTAINS string::lowercase('" + $filters.search + "'))");
    };
    
    -- Filtre par validité
    IF $filters.is_valid {
        LET $now = time::now();
        $where_conditions = array::push($where_conditions, 
            "(valid_from IS NONE OR valid_from <= " + string::concat($now) + ") AND " +
            "(valid_to IS NONE OR valid_to >= " + string::concat($now) + ")");
    };
    
    -- Filtre par cumul
    IF $filters.is_cumulative != NONE {
        $where_conditions = array::push($where_conditions, "is_cumulative = " + string::concat($filters.is_cumulative));
    };
    
    -- Filtre par automatique
    IF $filters.is_automatic != NONE {
        $where_conditions = array::push($where_conditions, "is_automatic = " + string::concat($filters.is_automatic));
    };
    
    -- Filtre par approbation requise
    IF $filters.requires_approval != NONE {
        $where_conditions = array::push($where_conditions, "requires_approval = " + string::concat($filters.requires_approval));
    };
    
    -- Filtre par séquence
    IF $filters.min_sequence {
        $where_conditions = array::push($where_conditions, "sequence >= " + string::concat($filters.min_sequence));
    };
    
    IF $filters.max_sequence {
        $where_conditions = array::push($where_conditions, "sequence <= " + string::concat($filters.max_sequence));
    };
    
    -- Construction de la requête
    LET $base_query = "SELECT * FROM discount_type";
    LET $where_clause = IF array::len($where_conditions) > 0 THEN 
        " WHERE " + array::join($where_conditions, " AND ") 
    ELSE "" END;
    
    -- Tri
    LET $order_clause = " ORDER BY " + $sort_field + " " + $sort_direction;
    
    -- Pagination
    LET $limit_clause = " LIMIT " + string::concat($page_size) + " START " + string::concat($offset);
    
    -- Exécution de la requête principale
    LET $discount_types = SELECT * FROM discount_type 
        WHERE ($filters.is_active IS NONE OR is_active = $filters.is_active)
        AND ($filters.calculation_method IS NONE OR calculation_method = $filters.calculation_method)
        AND ($filters.search IS NONE OR 
             string::lowercase(code) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(name) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(description) CONTAINS string::lowercase($filters.search))
        AND ($filters.is_valid IS NONE OR (
            (valid_from IS NONE OR valid_from <= time::now()) AND 
            (valid_to IS NONE OR valid_to >= time::now())
        ))
        AND ($filters.is_cumulative IS NONE OR is_cumulative = $filters.is_cumulative)
        AND ($filters.is_automatic IS NONE OR is_automatic = $filters.is_automatic)
        AND ($filters.requires_approval IS NONE OR requires_approval = $filters.requires_approval)
        AND ($filters.min_sequence IS NONE OR sequence >= $filters.min_sequence)
        AND ($filters.max_sequence IS NONE OR sequence <= $filters.max_sequence)
        ORDER BY sequence ASC
        LIMIT $page_size START $offset;
    
    -- Comptage total
    LET $total_count = SELECT VALUE count() FROM discount_type 
        WHERE ($filters.is_active IS NONE OR is_active = $filters.is_active)
        AND ($filters.calculation_method IS NONE OR calculation_method = $filters.calculation_method)
        AND ($filters.search IS NONE OR 
             string::lowercase(code) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(name) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(description) CONTAINS string::lowercase($filters.search))
        AND ($filters.is_valid IS NONE OR (
            (valid_from IS NONE OR valid_from <= time::now()) AND 
            (valid_to IS NONE OR valid_to >= time::now())
        ))
        AND ($filters.is_cumulative IS NONE OR is_cumulative = $filters.is_cumulative)
        AND ($filters.is_automatic IS NONE OR is_automatic = $filters.is_automatic)
        AND ($filters.requires_approval IS NONE OR requires_approval = $filters.requires_approval)
        AND ($filters.min_sequence IS NONE OR sequence >= $filters.min_sequence)
        AND ($filters.max_sequence IS NONE OR sequence <= $filters.max_sequence);
    
    -- Calcul des métadonnées de pagination
    LET $total = $total_count[0] OR 0;
    LET $total_pages = math::ceil($total / $page_size);
    LET $has_next = $current_page < $total_pages;
    LET $has_previous = $current_page > 1;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Liste des types de remise récupérée avec succès",
        data: $discount_types,
        pagination: {
            current_page: $current_page,
            page_size: $page_size,
            total_items: $total,
            total_pages: $total_pages,
            has_next: $has_next,
            has_previous: $has_previous,
            offset: $offset
        },
        filters: $filters,
        sort: {
            field: $sort_field,
            direction: $sort_direction
        }
    };
};

-- =====================================================
-- FONCTION: list_active_discount_types
-- Description: Liste des types actifs seulement
-- =====================================================

DEFINE FUNCTION fn::list_active_discount_types() {
    -- Récupération des types actifs
    LET $active_types = SELECT * FROM discount_type 
        WHERE is_active = true 
        ORDER BY sequence ASC;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise actifs récupérés avec succès",
        count: array::len($active_types),
        data: $active_types
    };
};

-- =====================================================
-- FONCTION: list_discount_types_by_calculation_method
-- Description: Liste par méthode de calcul
-- =====================================================

DEFINE FUNCTION fn::list_discount_types_by_calculation_method($method: string) {
    -- Validation du paramètre
    IF !$method OR !($method IN ["FIXED", "PERCENT", "FORMULA"]) {
        RETURN {
            success: false,
            error: "La méthode de calcul doit être FIXED, PERCENT ou FORMULA",
            message: "Erreur de validation : méthode invalide"
        };
    };
    
    -- Récupération des types par méthode
    LET $types = SELECT * FROM discount_type 
        WHERE calculation_method = $method 
        ORDER BY sequence ASC;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise par méthode de calcul récupérés avec succès",
        calculation_method: $method,
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_valid_discount_types
-- Description: Liste des types valides maintenant
-- =====================================================

DEFINE FUNCTION fn::list_valid_discount_types() {
    -- Récupération des types valides
    LET $now = time::now();
    LET $valid_types = SELECT * FROM discount_type 
        WHERE is_active = true
        AND (valid_from IS NONE OR valid_from <= $now)
        AND (valid_to IS NONE OR valid_to >= $now)
        ORDER BY sequence ASC;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise valides récupérés avec succès",
        check_time: $now,
        count: array::len($valid_types),
        data: $valid_types
    };
};

-- =====================================================
-- FONCTION: list_discount_types_for_order
-- Description: Types applicables pour une commande
-- =====================================================

DEFINE FUNCTION fn::list_discount_types_for_order($order_amount: decimal, $client_id: record) {
    -- Validation du paramètre
    IF !$order_amount OR $order_amount <= 0 {
        RETURN {
            success: false,
            error: "Le montant de commande doit être positif",
            message: "Erreur de validation : montant invalide"
        };
    };
    
    -- Récupération des types applicables
    LET $now = time::now();
    LET $applicable_types = SELECT * FROM discount_type 
        WHERE is_active = true
        AND (valid_from IS NONE OR valid_from <= $now)
        AND (valid_to IS NONE OR valid_to >= $now)
        AND (min_order_amount IS NONE OR min_order_amount <= $order_amount)
        AND (max_order_amount IS NONE OR max_order_amount >= $order_amount)
        ORDER BY sequence ASC;
    
    -- Vérification des limites d'utilisation par client
    LET $filtered_types = [];
    FOR $type IN $applicable_types {
        LET $client_usage = IF $client_id AND $type.max_usage_per_client THEN
            (SELECT VALUE count() FROM sale_order 
             WHERE discount_type_id = $type.id 
             AND client_partner_id = $client_id)[0] OR 0
        ELSE 0 END;
        
        LET $can_use = IF $type.max_usage_per_client THEN
            $client_usage < $type.max_usage_per_client
        ELSE true END;
        
        IF $can_use {
            $filtered_types = array::push($filtered_types, $type);
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise applicables récupérés avec succès",
        order_amount: $order_amount,
        client_id: $client_id,
        check_time: $now,
        total_types: array::len($applicable_types),
        applicable_count: array::len($filtered_types),
        data: $filtered_types
    };
};

-- =====================================================
-- FONCTION: list_discount_types_summary
-- Description: Résumé des types avec statistiques
-- =====================================================

DEFINE FUNCTION fn::list_discount_types_summary() {
    -- Récupération de tous les types
    LET $all_types = SELECT * FROM discount_type ORDER BY sequence ASC;
    
    -- Calcul des statistiques
    LET $stats = {
        total_count: array::len($all_types),
        active_count: (SELECT VALUE count() FROM discount_type WHERE is_active = true)[0] OR 0,
        inactive_count: (SELECT VALUE count() FROM discount_type WHERE is_active = false)[0] OR 0,
        system_count: (SELECT VALUE count() FROM discount_type WHERE is_system = true)[0] OR 0,
        
        -- Par méthode de calcul
        fixed_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "FIXED")[0] OR 0,
        percent_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "PERCENT")[0] OR 0,
        formula_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "FORMULA")[0] OR 0,
        
        -- Par comportement
        cumulative_count: (SELECT VALUE count() FROM discount_type WHERE is_cumulative = true)[0] OR 0,
        automatic_count: (SELECT VALUE count() FROM discount_type WHERE is_automatic = true)[0] OR 0,
        approval_required_count: (SELECT VALUE count() FROM discount_type WHERE requires_approval = true)[0] OR 0,
        
        -- Validité
        valid_now_count: (SELECT VALUE count() FROM discount_type 
            WHERE is_active = true
            AND (valid_from IS NONE OR valid_from <= time::now())
            AND (valid_to IS NONE OR valid_to >= time::now()))[0] OR 0,
        
        expired_count: (SELECT VALUE count() FROM discount_type 
            WHERE valid_to IS NOT NONE 
            AND valid_to < time::now())[0] OR 0,
        
        future_count: (SELECT VALUE count() FROM discount_type 
            WHERE valid_from IS NOT NONE 
            AND valid_from > time::now())[0] OR 0
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Résumé des types de remise récupéré avec succès",
        statistics: $stats,
        data: $all_types
    };
};

-- =====================================================
-- FONCTION: list_discount_types_with_usage
-- Description: Liste avec statistiques d'utilisation
-- =====================================================

DEFINE FUNCTION fn::list_discount_types_with_usage() {
    -- Récupération des types avec utilisation
    LET $types_with_usage = SELECT *,
        (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $parent.id) AS order_usage,
        (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $parent.id) AS line_usage,
        (SELECT VALUE sum(discount_amount) FROM sale_order WHERE discount_type_id = $parent.id) AS total_discount_amount,
        (SELECT VALUE avg(discount_amount) FROM sale_order WHERE discount_type_id = $parent.id) AS avg_discount_amount,
        (SELECT VALUE count(DISTINCT client_partner_id) FROM sale_order WHERE discount_type_id = $parent.id) AS unique_clients
    FROM discount_type 
    ORDER BY sequence ASC;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise avec statistiques d'utilisation récupérés avec succès",
        count: array::len($types_with_usage),
        data: $types_with_usage
    };
};

-- =====================================================
-- FONCTION: search_discount_types
-- Description: Recherche textuelle dans les types
-- =====================================================

DEFINE FUNCTION fn::search_discount_types($search_term: string, $limit: int) {
    -- Validation du paramètre
    IF !$search_term OR $search_term == "" {
        RETURN {
            success: false,
            error: "Le terme de recherche est obligatoire",
            message: "Erreur de validation : terme de recherche manquant"
        };
    };
    
    -- Paramètres
    LET $search_limit = $limit OR 10;
    LET $search_lower = string::lowercase($search_term);
    
    -- Recherche
    LET $results = SELECT * FROM discount_type 
        WHERE string::lowercase(code) CONTAINS $search_lower
        OR string::lowercase(name) CONTAINS $search_lower
        OR string::lowercase(description) CONTAINS $search_lower
        ORDER BY sequence ASC
        LIMIT $search_limit;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Recherche dans les types de remise effectuée avec succès",
        search_term: $search_term,
        limit: $search_limit,
        count: array::len($results),
        data: $results
    };
};

-- =====================================================
-- FONCTION: get_discount_types_dropdown
-- Description: Liste formatée pour dropdown/select
-- =====================================================

DEFINE FUNCTION fn::get_discount_types_dropdown($active_only: bool) {
    -- Récupération des types
    LET $types = IF $active_only THEN
        SELECT id, code, name, sequence, color, icon FROM discount_type 
        WHERE is_active = true 
        ORDER BY sequence ASC
    ELSE
        SELECT id, code, name, sequence, color, icon, is_active FROM discount_type 
        ORDER BY sequence ASC
    END;
    
    -- Formatage pour dropdown
    LET $dropdown_items = [];
    FOR $type IN $types {
        $dropdown_items = array::push($dropdown_items, {
            value: $type.id,
            label: $type.name,
            code: $type.code,
            sequence: $type.sequence,
            color: $type.color,
            icon: $type.icon,
            is_active: $type.is_active OR true
        });
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Options dropdown des types de remise récupérées avec succès",
        active_only: $active_only OR false,
        count: array::len($dropdown_items),
        data: $dropdown_items
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Liste paginée avec filtres:
   SELECT fn::list_discount_types(1, 20, "sequence", "ASC", {
       is_active: true,
       calculation_method: "PERCENT",
       search: "volume",
       is_cumulative: false
   });

2. Types actifs seulement:
   SELECT fn::list_active_discount_types();

3. Types par méthode de calcul:
   SELECT fn::list_discount_types_by_calculation_method("PERCENT");

4. Types valides maintenant:
   SELECT fn::list_valid_discount_types();

5. Types pour une commande:
   SELECT fn::list_discount_types_for_order(1500.00, partner:CLIENT123);

6. Résumé avec statistiques:
   SELECT fn::list_discount_types_summary();

7. Liste avec utilisation:
   SELECT fn::list_discount_types_with_usage();

8. Recherche textuelle:
   SELECT fn::search_discount_types("volume", 5);

9. Options dropdown:
   SELECT fn::get_discount_types_dropdown(true);

FILTRES DISPONIBLES:
- is_active: Statut actif/inactif
- calculation_method: Méthode de calcul (FIXED, PERCENT, FORMULA)
- search: Recherche textuelle (code, nom, description)
- is_valid: Validité temporelle
- is_cumulative: Remise cumulable
- is_automatic: Application automatique
- requires_approval: Approbation requise
- min_sequence/max_sequence: Plage de séquences

STATISTIQUES DISPONIBLES:
- Comptages par statut et type
- Utilisation dans les commandes
- Montants de remise
- Clients uniques
- Validité temporelle

FORMATS DE RETOUR:
- Liste standard: Objets complets
- Dropdown: Format simplifié pour UI
- Avec usage: Statistiques incluses
- Résumé: Agrégations et totaux

PAGINATION:
- current_page: Page actuelle
- page_size: Taille de page
- total_items: Nombre total d'éléments
- total_pages: Nombre total de pages
- has_next/has_previous: Navigation disponible

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: array (résultats),
    pagination: object (si applicable),
    statistics: object (si applicable),
    error: string (si erreur)
}
*/ 