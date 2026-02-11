-- =============================================================================
-- FONCTION: fn::get_legal_forms_by_country
-- =============================================================================
-- DESCRIPTION: Récupère les formes juridiques d'un pays spécifique
-- PARAMETRES:
--   $country_id: ID du pays (obligatoire)
--   $active_only: Filtrer seulement les actives (optionnel, défaut: false)
-- RETOUR: Array contenant les formes juridiques du pays avec catégorie
-- USAGE:
--   -- Toutes les formes d'un pays:
--   RETURN fn::get_legal_forms_by_country(country:france);
--   
--   -- Seulement les formes actives d'un pays:
--   RETURN fn::get_legal_forms_by_country(country:france, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_legal_forms_by_country(
    $country_id: record,
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
            WHERE country = $country_id AND active = true
            ORDER BY category.level, name
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
            WHERE country = $country_id
            ORDER BY category.level, name
        );
    };
} COMMENT "Récupère les formes juridiques d'un pays spécifique avec option de filtrage par statut actif."; 