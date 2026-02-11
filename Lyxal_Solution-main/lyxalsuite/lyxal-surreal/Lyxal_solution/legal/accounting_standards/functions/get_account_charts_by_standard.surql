-- =============================================================================
-- FONCTION: fn::get_account_charts_by_standard
-- =============================================================================
-- DESCRIPTION: Récupère les comptes comptables d'une norme spécifique
-- PARAMETRES:
--   $accounting_standard: ID de la norme comptable (obligatoire)
--   $active_only: Filtre les comptes actifs seulement (défaut: false)
--   $account_class: Filtre par classe comptable (optionnel)
--   $account_type: Filtre par type de compte (optionnel)
--   $level: Filtre par niveau hiérarchique (optionnel)
-- RETOUR: array<record> - Liste des comptes comptables
-- USAGE:
--   -- Tous les comptes d'une norme:
--   RETURN fn::get_account_charts_by_standard(accounting_standard:pcg2014);
--   
--   -- Comptes actifs de classe 4:
--   RETURN fn::get_account_charts_by_standard(
--     accounting_standard:pcg2014,
--     active_only: true,
--     account_class: 4
--   );
--   
--   -- Comptes de type asset niveau 1:
--   RETURN fn::get_account_charts_by_standard(
--     accounting_standard:pcg2014,
--     account_type: "asset",
--     level: 1
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_account_charts_by_standard(
    $accounting_standard: record,
    $active_only: option<bool>,
    $account_class: option<int>,
    $account_type: option<string>,
    $level: option<int>
) {
    LET $filter_active = IF $active_only IS NONE { false } ELSE { $active_only };
    
    -- Construire la requête avec toutes les conditions
    IF $filter_active = true AND $account_class IS NOT NONE AND $account_type IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND account_type = $account_type AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $account_class IS NOT NONE AND $account_type IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND account_type = $account_type FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $account_class IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $account_type IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_type = $account_type AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $account_class IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $account_type IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND account_type = $account_type FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $filter_active = true {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true FETCH parent_account, accounting_standard);
    } ELSE IF $account_class IS NOT NONE AND $account_type IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_class = $account_class AND account_type = $account_type AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $account_class IS NOT NONE AND $account_type IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_class = $account_class AND account_type = $account_type FETCH parent_account, accounting_standard);
    } ELSE IF $account_class IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_class = $account_class AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $account_type IS NOT NONE AND $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_type = $account_type AND level = $level FETCH parent_account, accounting_standard);
    } ELSE IF $account_class IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_class = $account_class FETCH parent_account, accounting_standard);
    } ELSE IF $account_type IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND account_type = $account_type FETCH parent_account, accounting_standard);
    } ELSE IF $level IS NOT NONE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND level = $level FETCH parent_account, accounting_standard);
    } ELSE {
        RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard FETCH parent_account, accounting_standard);
    };
} COMMENT "Récupère les comptes comptables d'une norme spécifique avec filtres avancés (classe, type, niveau)."; 