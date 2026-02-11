-- =============================================================================
-- FONCTION: fn::get_account_charts_for_select
-- =============================================================================
-- DESCRIPTION: Récupère les comptes comptables dans un format adapté aux dropdowns
-- PARAMETRES:
--   $accounting_standard: Filtre par norme comptable (optionnel)
--   $active_only: Filtre les comptes actifs seulement (défaut: true)
--   $account_class: Filtre par classe comptable (optionnel)
--   $account_type: Filtre par type de compte (optionnel)
--   $auxiliary_only: Filtre les comptes auxiliaires seulement (défaut: false)
--   $analytical_only: Filtre les comptes analytiques seulement (défaut: false)
-- RETOUR: array<{id, label, account_number, account_name, account_type, account_class}>
-- USAGE:
--   -- Tous les comptes actifs:
--   RETURN fn::get_account_charts_for_select();
--   
--   -- Comptes d'une norme spécifique:
--   RETURN fn::get_account_charts_for_select(accounting_standard:pcg2014);
--   
--   -- Comptes auxiliaires de classe 4:
--   RETURN fn::get_account_charts_for_select(
--     accounting_standard:pcg2014,
--     account_class: 4,
--     auxiliary_only: true
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_account_charts_for_select(
    $accounting_standard: option<record>,
    $active_only: option<bool>,
    $account_class: option<int>,
    $account_type: option<string>,
    $auxiliary_only: option<bool>,
    $analytical_only: option<bool>
) {
    LET $filter_active = IF $active_only IS NONE { true } ELSE { $active_only };
    LET $filter_auxiliary = IF $auxiliary_only IS NONE { false } ELSE { $auxiliary_only };
    LET $filter_analytical = IF $analytical_only IS NONE { false } ELSE { $analytical_only };
    
    -- Cas avec tous les filtres
    IF $accounting_standard IS NOT NONE AND $filter_active = true AND $account_class IS NOT NONE AND $account_type IS NOT NONE AND $filter_auxiliary = true AND $filter_analytical = true {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND account_type = $account_type AND is_auxiliary = true AND is_analytical = true
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: norme + actif + classe + type + auxiliaire
    IF $accounting_standard IS NOT NONE AND $filter_active = true AND $account_class IS NOT NONE AND $account_type IS NOT NONE AND $filter_auxiliary = true {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND account_type = $account_type AND is_auxiliary = true
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: norme + actif + classe + type
    IF $accounting_standard IS NOT NONE AND $filter_active = true AND $account_class IS NOT NONE AND $account_type IS NOT NONE {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class AND account_type = $account_type
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: norme + actif + classe
    IF $accounting_standard IS NOT NONE AND $filter_active = true AND $account_class IS NOT NONE {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard AND is_active = true AND account_class = $account_class
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: norme + actif
    IF $accounting_standard IS NOT NONE AND $filter_active = true {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard AND is_active = true
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: norme seulement
    IF $accounting_standard IS NOT NONE {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE accounting_standard = $accounting_standard
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: actif seulement
    IF $filter_active = true {
        RETURN (
            SELECT 
                id,
                account_number + " - " + account_name AS label,
                account_number,
                account_name,
                account_type,
                account_class
            FROM account_chart
            WHERE is_active = true
            ORDER BY account_class, account_number
        );
    };
    
    -- Cas: aucun filtre
    RETURN (
        SELECT 
            id,
            account_number + " - " + account_name AS label,
            account_number,
            account_name,
            account_type,
            account_class
        FROM account_chart
        ORDER BY account_class, account_number
    );
} COMMENT "Récupère les comptes comptables dans un format adapté aux dropdowns avec filtres avancés."; 