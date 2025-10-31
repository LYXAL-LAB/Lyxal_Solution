-- =============================================================================
-- FONCTION: fn::get_accounting_standards_by_country
-- =============================================================================
-- DESCRIPTION: Récupère toutes les normes comptables d'un pays spécifique
-- PARAMETRES:
--   $country: ID du pays (obligatoire)
--   $active_only: Ne récupérer que les normes actives (défaut: false)
-- RETOUR: Array contenant les normes comptables du pays avec informations complètes
-- USAGE:
--   -- Récupérer toutes les normes d'un pays:
--   RETURN fn::get_accounting_standards_by_country(country:france);
--   
--   -- Récupérer seulement les normes actives d'un pays:
--   RETURN fn::get_accounting_standards_by_country(country:france, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_accounting_standards_by_country(
    $country: record,
    $active_only: option<bool>
) {
    LET $final_active_only = IF $active_only IS NONE { false } ELSE { $active_only };
    
    IF $final_active_only = true {
        RETURN (
            SELECT 
                *,
                country.name AS country_name,
                country.code AS country_code,
                parent_standard.name AS parent_standard_name,
                parent_standard.code AS parent_standard_code
            FROM accounting_standard 
            WHERE country = $country AND status = 'active'
            ORDER BY category, name
        );
    } ELSE {
        RETURN (
            SELECT 
                *,
                country.name AS country_name,
                country.code AS country_code,
                parent_standard.name AS parent_standard_name,
                parent_standard.code AS parent_standard_code
            FROM accounting_standard 
            WHERE country = $country
            ORDER BY category, name
        );
    };
} COMMENT "Récupère toutes les normes comptables d'un pays spécifique avec option pour filtrer les normes actives. Triées par catégorie et nom."; 