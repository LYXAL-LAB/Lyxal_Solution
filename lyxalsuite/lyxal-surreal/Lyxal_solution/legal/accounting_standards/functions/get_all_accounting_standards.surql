-- =============================================================================
-- FONCTION: fn::get_all_accounting_standards
-- =============================================================================
-- DESCRIPTION: Récupère toutes les normes comptables avec leurs informations complètes
-- PARAMETRES: Aucun
-- RETOUR: Array contenant toutes les normes comptables avec pays et norme parent
-- USAGE:
--   -- Récupérer toutes les normes comptables:
--   RETURN fn::get_all_accounting_standards();
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_all_accounting_standards() {
    RETURN (
        SELECT 
            *,
            country.name AS country_name,
            country.code AS country_code,
            parent_standard.name AS parent_standard_name,
            parent_standard.code AS parent_standard_code
        FROM accounting_standard 
        ORDER BY scope, country.name, name
    );
} COMMENT "Récupère toutes les normes comptables avec leurs informations de pays et norme parent. Triées par portée, pays et nom."; 