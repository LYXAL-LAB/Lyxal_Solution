-- =============================================================================
-- FONCTION: fn::get_legal_forms_by_category
-- =============================================================================
-- DESCRIPTION: Récupère les formes juridiques d'une catégorie spécifique
-- PARAMETRES:
--   $category_id: ID de la catégorie juridique (obligatoire)
--   $active_only: Filtrer seulement les actives (optionnel, défaut: false)
-- RETOUR: Array contenant les formes juridiques de la catégorie avec pays
-- USAGE:
--   -- Toutes les formes d'une catégorie:
--   RETURN fn::get_legal_forms_by_category(legal_category:societes_capitaux);
--   
--   -- Seulement les formes actives d'une catégorie:
--   RETURN fn::get_legal_forms_by_category(legal_category:societes_capitaux, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_legal_forms_by_category(
    $category_id: record,
    $active_only: option<bool>
) {
    LET $filter_active = IF $active_only IS NONE { false } ELSE { $active_only };
    
    IF $filter_active {
        RETURN (
            SELECT 
                *,
                country.name AS country_name,
                country.code AS country_code,
                category.name AS category_name,
                category.code AS category_code,
                category.level AS category_level
            FROM legal_form 
            WHERE category = $category_id AND active = true
            ORDER BY country.name, name
        );
    } ELSE {
        RETURN (
            SELECT 
                *,
                country.name AS country_name,
                country.code AS country_code,
                category.name AS category_name,
                category.code AS category_code,
                category.level AS category_level
            FROM legal_form 
            WHERE category = $category_id
            ORDER BY country.name, name
        );
    };
} COMMENT "Récupère les formes juridiques d'une catégorie spécifique avec option de filtrage par statut actif."; 