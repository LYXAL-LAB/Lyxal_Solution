-- =============================================================================
-- FONCTION: fn::get_accounting_standards_for_select
-- =============================================================================
-- DESCRIPTION: Récupère les normes comptables formatées pour un select/dropdown
-- PARAMETRES:
--   $active_only: Ne récupérer que les normes actives (défaut: true)
--   $scope_filter: Filtrer par portée (optionnel)
--   $country_filter: Filtrer par pays (optionnel)
-- RETOUR: Array contenant les normes comptables avec id, label et metadata
-- USAGE:
--   -- Récupérer toutes les normes actives pour un select:
--   RETURN fn::get_accounting_standards_for_select();
--   
--   -- Récupérer les normes nationales actives:
--   RETURN fn::get_accounting_standards_for_select(true, "national");
--   
--   -- Récupérer les normes françaises:
--   RETURN fn::get_accounting_standards_for_select(true, NONE, country:france);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_accounting_standards_for_select(
    $active_only: option<bool>,
    $scope_filter: option<string>,
    $country_filter: option<record>
) {
    LET $final_active_only = IF $active_only IS NONE { true } ELSE { $active_only };
    
    -- Cas 1: Tous les filtres
    IF $final_active_only = true AND $scope_filter IS NOT NONE AND $country_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE status = 'active' AND scope = $scope_filter AND country = $country_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 2: Active + scope
    IF $final_active_only = true AND $scope_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE status = 'active' AND scope = $scope_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 3: Active + country
    IF $final_active_only = true AND $country_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE status = 'active' AND country = $country_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 4: Scope + country
    IF $scope_filter IS NOT NONE AND $country_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE scope = $scope_filter AND country = $country_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 5: Active seulement
    IF $final_active_only = true {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE status = 'active'
            ORDER BY scope, name
        );
    };
    
    -- Cas 6: Scope seulement
    IF $scope_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE scope = $scope_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 7: Country seulement
    IF $country_filter IS NOT NONE {
        RETURN (
            SELECT 
                id,
                code + " - " + name AS label,
                code,
                name,
                scope,
                category,
                is_mandatory,
                country.name AS country_name,
                country.code AS country_code,
                status
            FROM accounting_standard
            WHERE country = $country_filter
            ORDER BY scope, name
        );
    };
    
    -- Cas 8: Aucun filtre
    RETURN (
        SELECT 
            id,
            code + " - " + name AS label,
            code,
            name,
            scope,
            category,
            is_mandatory,
            country.name AS country_name,
            country.code AS country_code,
            status
        FROM accounting_standard
        ORDER BY scope, name
    );
} COMMENT "Récupère les normes comptables formatées pour un select/dropdown avec filtres optionnels. Retourne id, label et tous les champs utiles."; 