-- =============================================================================
-- FONCTION: fn::get_active_categories_with_hierarchy  
-- =============================================================================
-- DESCRIPTION: Récupère seulement les catégories juridiques actives avec leur hiérarchie
-- PARAMETRES: Aucun
-- RETOUR: Array contenant les catégories actives avec leur hiérarchie
-- USAGE:
--   -- Récupérer les catégories actives:
--   RETURN fn::get_active_categories_with_hierarchy();
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_active_categories_with_hierarchy() {
    RETURN (
        SELECT 
            *,
            fn::get_category_hierarchy(id) AS hierarchy
        FROM legal_category 
        WHERE active = true
        ORDER BY level, name
    );
} COMMENT "Récupère seulement les catégories juridiques actives avec leur hiérarchie complète.";
