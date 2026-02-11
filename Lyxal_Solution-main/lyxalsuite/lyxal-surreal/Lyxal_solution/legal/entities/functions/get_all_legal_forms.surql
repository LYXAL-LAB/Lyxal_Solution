-- =============================================================================
-- FONCTION: fn::get_all_legal_forms
-- =============================================================================
-- DESCRIPTION: Récupère toutes les formes juridiques avec leurs informations complètes
-- PARAMETRES: Aucun
-- RETOUR: Array contenant toutes les formes juridiques avec pays et catégorie
-- USAGE:
--   -- Récupérer toutes les formes juridiques:
--   RETURN fn::get_all_legal_forms();
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_all_legal_forms() {
    RETURN (
        SELECT 
            *,
            country.name AS country_name,
            country.code AS country_code,
            category.name AS category_name,
            category.code AS category_code,
            category.level AS category_level
        FROM legal_form 
        ORDER BY country.name, category.level, name
    );
} COMMENT "Récupère toutes les formes juridiques avec leurs informations de pays et catégorie. Triées par pays, niveau de catégorie et nom."; 