-- =============================================================================
-- FONCTION: fn::get_active_legal_forms
-- =============================================================================
-- DESCRIPTION: Récupère seulement les formes juridiques actives
-- PARAMETRES: Aucun
-- RETOUR: Array contenant les formes juridiques actives avec pays et catégorie
-- USAGE:
--   -- Récupérer les formes juridiques actives:
--   RETURN fn::get_active_legal_forms();
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_active_legal_forms() {
    RETURN (
        SELECT 
            *,
            country.name AS country_name,
            country.code AS country_code,
            category.name AS category_name,
            category.code AS category_code,
            category.level AS category_level
        FROM legal_form 
        WHERE active = true
        ORDER BY country.name, category.level, name
    );
} COMMENT "Récupère seulement les formes juridiques actives avec leurs informations de pays et catégorie."; 