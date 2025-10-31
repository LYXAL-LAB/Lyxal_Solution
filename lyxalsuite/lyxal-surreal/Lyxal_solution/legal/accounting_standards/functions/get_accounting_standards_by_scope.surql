-- =============================================================================
-- FONCTION: fn::get_accounting_standards_by_scope
-- =============================================================================
-- DESCRIPTION: Récupère toutes les normes comptables d'une portée spécifique
-- PARAMETRES:
--   $scope: Portée (national/international/regional) (obligatoire)
--   $active_only: Ne récupérer que les normes actives (défaut: false)
-- RETOUR: Array contenant les normes comptables de la portée avec informations complètes
-- USAGE:
--   -- Récupérer toutes les normes internationales:
--   RETURN fn::get_accounting_standards_by_scope("international");
--   
--   -- Récupérer seulement les normes nationales actives:
--   RETURN fn::get_accounting_standards_by_scope("national", true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_accounting_standards_by_scope(
    $scope: string,
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
            WHERE scope = $scope AND status = 'active'
            ORDER BY country.name, name
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
            WHERE scope = $scope
            ORDER BY country.name, name
        );
    };
} COMMENT "Récupère toutes les normes comptables d'une portée spécifique avec option pour filtrer les normes actives. Triées par pays et nom."; 