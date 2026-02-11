-- =====================================================
-- FONCTIONS DE LISTAGE: sale_order_line_type
-- Description: Fonctions de listage et recherche des types de ligne
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: list_sale_order_line_type
-- Description: Liste des types actifs ordonnés par séquence
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type() {
    -- Récupération des types actifs
    LET $types = SELECT * FROM sale_order_line_type 
        WHERE is_active = true 
        ORDER BY sequence ASC;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste des types de ligne actifs",
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_all_sale_order_line_type
-- Description: Liste tous les types (actifs et inactifs)
-- =====================================================

DEFINE FUNCTION fn::list_all_sale_order_line_type() {
    -- Récupération de tous les types
    LET $types = SELECT * FROM sale_order_line_type 
        ORDER BY is_active DESC, sequence ASC;
    
    -- Statistiques
    LET $stats = {
        total: array::len($types),
        active: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true)[0] OR 0,
        inactive: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = false)[0] OR 0,
        system: (SELECT VALUE count() FROM sale_order_line_type WHERE is_system = true)[0] OR 0
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste complète des types de ligne",
        stats: $stats,
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_sale_order_line_type_paginated
-- Description: Liste paginée des types
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type_paginated(
    $page: int,
    $limit: int,
    $include_inactive: bool
) {
    -- Validation des paramètres
    IF !$page OR $page <= 0 {
        RETURN {
            success: false,
            error: "Le numéro de page doit être positif",
            message: "Erreur de validation : page invalide"
        };
    };
    
    IF !$limit OR $limit <= 0 OR $limit > 100 {
        RETURN {
            success: false,
            error: "La limite doit être entre 1 et 100",
            message: "Erreur de validation : limite invalide"
        };
    };
    
    -- Calcul de l'offset
    LET $offset = ($page - 1) * $limit;
    
    -- Construction de la requête base
    LET $where_clause = IF $include_inactive THEN "" ELSE "WHERE is_active = true" END;
    
    -- Comptage total
    LET $total_count = IF $include_inactive THEN 
        (SELECT VALUE count() FROM sale_order_line_type)[0] 
    ELSE 
        (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true)[0] 
    END;
    
    -- Récupération des données paginées
    LET $types = IF $include_inactive THEN
        (SELECT * FROM sale_order_line_type ORDER BY is_active DESC, sequence ASC LIMIT $limit START $offset)
    ELSE
        (SELECT * FROM sale_order_line_type WHERE is_active = true ORDER BY sequence ASC LIMIT $limit START $offset)
    END;
    
    -- Calcul des métadonnées de pagination
    LET $pagination = {
        page: $page,
        limit: $limit,
        total_count: $total_count,
        total_pages: math::ceil($total_count / $limit),
        has_next: $page < math::ceil($total_count / $limit),
        has_previous: $page > 1,
        start_index: $offset + 1,
        end_index: math::min($offset + $limit, $total_count)
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste paginée des types de ligne",
        pagination: $pagination,
        data: $types
    };
};

-- =====================================================
-- FONCTION: search_sale_order_line_type
-- Description: Recherche textuelle dans les types
-- =====================================================

DEFINE FUNCTION fn::search_sale_order_line_type(
    $search: string,
    $include_inactive: bool
) {
    -- Validation du paramètre
    IF !$search OR $search == "" {
        RETURN {
            success: false,
            error: "Le terme de recherche est obligatoire",
            message: "Erreur de validation : terme de recherche manquant"
        };
    };
    
    -- Normalisation du terme de recherche
    LET $search_term = string::lowercase($search);
    
    -- Construction de la requête avec recherche
    LET $types = IF $include_inactive THEN
        (SELECT * FROM sale_order_line_type 
         WHERE string::lowercase(code) CONTAINS $search_term 
            OR string::lowercase(name) CONTAINS $search_term 
            OR string::lowercase(description) CONTAINS $search_term
         ORDER BY is_active DESC, sequence ASC)
    ELSE
        (SELECT * FROM sale_order_line_type 
         WHERE is_active = true 
            AND (string::lowercase(code) CONTAINS $search_term 
                OR string::lowercase(name) CONTAINS $search_term 
                OR string::lowercase(description) CONTAINS $search_term)
         ORDER BY sequence ASC)
    END;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Recherche effectuée dans les types de ligne",
        search_term: $search,
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_sale_order_line_type_by_behavior
-- Description: Liste par comportement métier
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type_by_behavior(
    $affects_stock: bool,
    $affects_pricing: bool,
    $is_printable: bool
) {
    -- Construction de la requête avec filtres
    LET $types = SELECT * FROM sale_order_line_type 
        WHERE is_active = true
            AND ($affects_stock IS NONE OR affects_stock = $affects_stock)
            AND ($affects_pricing IS NONE OR affects_pricing = $affects_pricing)
            AND ($is_printable IS NONE OR is_printable = $is_printable)
        ORDER BY sequence ASC;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste des types par comportement métier",
        filters: {
            affects_stock: $affects_stock,
            affects_pricing: $affects_pricing,
            is_printable: $is_printable
        },
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_sale_order_line_type_with_stats
-- Description: Liste avec statistiques d'utilisation
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type_with_stats() {
    -- Récupération des types avec statistiques
    LET $types_with_stats = SELECT *,
        (SELECT VALUE count() FROM sale_order_line WHERE type_id = $parent.id) AS usage_count,
        (SELECT VALUE count(DISTINCT sale_order_id) FROM sale_order_line WHERE type_id = $parent.id) AS order_count,
        (SELECT VALUE sum(qty) FROM sale_order_line WHERE type_id = $parent.id) AS total_quantity,
        (SELECT VALUE sum(in_tax_total) FROM sale_order_line WHERE type_id = $parent.id) AS total_amount,
        (SELECT VALUE max(creation_date) FROM sale_order_line WHERE type_id = $parent.id) AS last_used
    FROM sale_order_line_type 
    WHERE is_active = true 
    ORDER BY sequence ASC;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste des types avec statistiques d'utilisation",
        count: array::len($types_with_stats),
        data: $types_with_stats
    };
};

-- =====================================================
-- FONCTION: list_sale_order_line_type_for_selection
-- Description: Liste optimisée pour les sélecteurs UI
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type_for_selection() {
    -- Récupération des types pour sélection
    LET $types = SELECT 
        id,
        code,
        name,
        sequence,
        color,
        icon,
        affects_stock,
        affects_pricing,
        is_printable,
        requires_validation
    FROM sale_order_line_type 
    WHERE is_active = true 
    ORDER BY sequence ASC;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste optimisée pour sélection",
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: list_sale_order_line_type_by_category
-- Description: Liste groupée par catégorie de comportement
-- =====================================================

DEFINE FUNCTION fn::list_sale_order_line_type_by_category() {
    -- Récupération de tous les types actifs
    LET $all_types = SELECT * FROM sale_order_line_type WHERE is_active = true ORDER BY sequence ASC;
    
    -- Groupement par catégories
    LET $categories = {
        stock_affecting: array::filter($all_types, |$type| $type.affects_stock = true),
        pricing_affecting: array::filter($all_types, |$type| $type.affects_pricing = true),
        printable: array::filter($all_types, |$type| $type.is_printable = true),
        validation_required: array::filter($all_types, |$type| $type.requires_validation = true),
        modifiable: array::filter($all_types, |$type| $type.allows_modification = true),
        deletable: array::filter($all_types, |$type| $type.allows_deletion = true)
    };
    
    -- Statistiques par catégorie
    LET $category_stats = {
        stock_affecting: array::len($categories.stock_affecting),
        pricing_affecting: array::len($categories.pricing_affecting),
        printable: array::len($categories.printable),
        validation_required: array::len($categories.validation_required),
        modifiable: array::len($categories.modifiable),
        deletable: array::len($categories.deletable)
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Liste groupée par catégories de comportement",
        total_types: array::len($all_types),
        categories: $categories,
        category_stats: $category_stats
    };
};

-- =====================================================
-- FONCTION: get_sale_order_line_type_summary
-- Description: Résumé statistique des types
-- =====================================================

DEFINE FUNCTION fn::get_sale_order_line_type_summary() {
    -- Calcul des statistiques globales
    LET $summary = {
        total_types: (SELECT VALUE count() FROM sale_order_line_type)[0] OR 0,
        active_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true)[0] OR 0,
        inactive_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = false)[0] OR 0,
        system_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_system = true)[0] OR 0,
        
        -- Comportements
        stock_affecting: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND affects_stock = true)[0] OR 0,
        pricing_affecting: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND affects_pricing = true)[0] OR 0,
        printable: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND is_printable = true)[0] OR 0,
        validation_required: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND requires_validation = true)[0] OR 0,
        
        -- Utilisation
        total_usage: (SELECT VALUE count() FROM sale_order_line)[0] OR 0,
        most_used: (SELECT type_id, count() as usage_count FROM sale_order_line GROUP BY type_id ORDER BY usage_count DESC LIMIT 1)[0],
        least_used: (SELECT type_id, count() as usage_count FROM sale_order_line GROUP BY type_id ORDER BY usage_count ASC LIMIT 1)[0]
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Résumé statistique des types de ligne",
        summary: $summary
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Liste simple (types actifs):
   SELECT fn::list_sale_order_line_type();

2. Liste complète (tous types):
   SELECT fn::list_all_sale_order_line_type();

3. Liste paginée:
   SELECT fn::list_sale_order_line_type_paginated(1, 10, false);

4. Recherche textuelle:
   SELECT fn::search_sale_order_line_type("normal", false);

5. Liste par comportement:
   SELECT fn::list_sale_order_line_type_by_behavior(true, true, true);

6. Liste avec statistiques:
   SELECT fn::list_sale_order_line_type_with_stats();

7. Liste pour sélection UI:
   SELECT fn::list_sale_order_line_type_for_selection();

8. Liste par catégories:
   SELECT fn::list_sale_order_line_type_by_category();

9. Résumé statistique:
   SELECT fn::get_sale_order_line_type_summary();

FONCTIONNALITÉS DE RECHERCHE:
- Recherche dans code, nom et description
- Recherche insensible à la casse
- Inclusion/exclusion des types inactifs
- Filtrage par comportement métier

PAGINATION:
- Limite configurable (max 100)
- Métadonnées complètes
- Navigation suivant/précédent
- Calcul automatique du nombre de pages

GROUPEMENT ET CATÉGORIES:
- Groupement par comportement métier
- Statistiques par catégorie
- Types affectant le stock/prix
- Types nécessitant validation

OPTIMISATIONS:
- Sélection des champs nécessaires
- Tri par séquence par défaut
- Index utilisés pour performance
- Requêtes optimisées pour UI

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    count: int,
    data: array,
    pagination: object (si applicable),
    stats: object (si applicable)
}
*/ 