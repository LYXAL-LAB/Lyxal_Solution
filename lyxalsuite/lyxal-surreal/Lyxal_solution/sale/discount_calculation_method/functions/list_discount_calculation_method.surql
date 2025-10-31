-- =====================================================
-- FONCTIONS DE LISTAGE: discount_calculation_method
-- Description: Fonctions pour lister les méthodes de calcul
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: list_discount_calculation_methods
-- Description: Liste paginée des méthodes de calcul
-- =====================================================

DEFINE FUNCTION fn::list_discount_calculation_methods(
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
    
    -- Requête principale avec filtres
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE ($filters.is_active IS NONE OR is_active = $filters.is_active)
        AND ($filters.calculation_type IS NONE OR calculation_type = $filters.calculation_type)
        AND ($filters.display_category IS NONE OR display_category = $filters.display_category)
        AND ($filters.supports_fixed_amount IS NONE OR supports_fixed_amount = $filters.supports_fixed_amount)
        AND ($filters.supports_percentage IS NONE OR supports_percentage = $filters.supports_percentage)
        AND ($filters.supports_formula IS NONE OR supports_formula = $filters.supports_formula)
        AND ($filters.supports_currency IS NONE OR supports_currency = $filters.supports_currency)
        AND ($filters.requires_approval IS NONE OR requires_approval = $filters.requires_approval)
        AND ($filters.restricted_usage IS NONE OR restricted_usage = $filters.restricted_usage)
        AND ($filters.search IS NONE OR 
             string::lowercase(code) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(name) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(description) CONTAINS string::lowercase($filters.search))
        ORDER BY sequence ASC
        LIMIT $page_size START $offset;
    
    -- Comptage total
    LET $total_count = SELECT VALUE count() FROM discount_calculation_method 
        WHERE ($filters.is_active IS NONE OR is_active = $filters.is_active)
        AND ($filters.calculation_type IS NONE OR calculation_type = $filters.calculation_type)
        AND ($filters.display_category IS NONE OR display_category = $filters.display_category)
        AND ($filters.supports_fixed_amount IS NONE OR supports_fixed_amount = $filters.supports_fixed_amount)
        AND ($filters.supports_percentage IS NONE OR supports_percentage = $filters.supports_percentage)
        AND ($filters.supports_formula IS NONE OR supports_formula = $filters.supports_formula)
        AND ($filters.supports_currency IS NONE OR supports_currency = $filters.supports_currency)
        AND ($filters.requires_approval IS NONE OR requires_approval = $filters.requires_approval)
        AND ($filters.restricted_usage IS NONE OR restricted_usage = $filters.restricted_usage)
        AND ($filters.search IS NONE OR 
             string::lowercase(code) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(name) CONTAINS string::lowercase($filters.search) OR 
             string::lowercase(description) CONTAINS string::lowercase($filters.search));
    
    -- Calcul des métadonnées de pagination
    LET $total = $total_count[0] OR 0;
    LET $total_pages = math::ceil($total / $page_size);
    LET $has_next = $current_page < $total_pages;
    LET $has_previous = $current_page > 1;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Liste des méthodes de calcul récupérée",
        data: $methods,
        pagination: {
            current_page: $current_page,
            page_size: $page_size,
            total_items: $total,
            total_pages: $total_pages,
            has_next: $has_next,
            has_previous: $has_previous,
            offset: $offset
        },
        filters: $filters
    };
};

-- =====================================================
-- FONCTION: list_active_discount_calculation_methods
-- Description: Liste des méthodes actives seulement
-- =====================================================

DEFINE FUNCTION fn::list_active_discount_calculation_methods() {
    -- Récupération des méthodes actives
    LET $active_methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true 
        ORDER BY sequence ASC;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul actives récupérées",
        count: array::len($active_methods),
        data: $active_methods
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_methods_dropdown
-- Description: Liste formatée pour dropdown/select
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_methods_dropdown($active_only: bool, $user_roles: array<string>) {
    -- Paramètres
    LET $roles = $user_roles OR [];
    
    -- Récupération des méthodes
    LET $methods = IF $active_only THEN
        SELECT id, code, name, sequence, color, icon, calculation_type, display_category FROM discount_calculation_method 
        WHERE is_active = true 
        AND (
            restricted_usage = false OR 
            array::len(array::intersect($roles, allowed_roles)) > 0
        )
        ORDER BY sequence ASC
    ELSE
        SELECT id, code, name, sequence, color, icon, calculation_type, display_category, is_active FROM discount_calculation_method 
        WHERE (
            restricted_usage = false OR 
            array::len(array::intersect($roles, allowed_roles)) > 0
        )
        ORDER BY sequence ASC
    END;
    
    -- Formatage pour dropdown
    LET $dropdown_items = [];
    FOR $method IN $methods {
        $dropdown_items = array::push($dropdown_items, {
            value: $method.id,
            label: $method.name,
            code: $method.code,
            sequence: $method.sequence,
            color: $method.color,
            icon: $method.icon,
            calculation_type: $method.calculation_type,
            display_category: $method.display_category,
            is_active: $method.is_active OR true
        });
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Options dropdown des méthodes de calcul récupérées",
        active_only: $active_only OR false,
        user_roles: $roles,
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
   SELECT fn::list_discount_calculation_methods(1, 20, "sequence", "ASC", {
       is_active: true,
       calculation_type: "PERCENT",
       supports_currency: true
   });

2. Méthodes actives:
   SELECT fn::list_active_discount_calculation_methods();

3. Options dropdown:
   SELECT fn::get_discount_calculation_methods_dropdown(true, ["MANAGER", "SALES"]);

FILTRES DISPONIBLES:
- is_active: Statut actif/inactif
- calculation_type: Type de calcul
- display_category: Catégorie d'affichage
- supports_*: Types de support
- requires_approval: Nécessite approbation
- restricted_usage: Usage restreint
- search: Recherche textuelle

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: array (résultats),
    pagination: object (si applicable),
    error: string (si erreur)
}
*/ 