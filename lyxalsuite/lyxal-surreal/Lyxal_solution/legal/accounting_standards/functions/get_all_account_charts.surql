-- =============================================================================
-- FONCTION: fn::get_all_account_charts
-- =============================================================================
-- DESCRIPTION: Récupère tous les comptes comptables avec leurs relations
-- PARAMETRES:
--   $accounting_standard: Filtre par norme comptable (optionnel)
--   $active_only: Filtre les comptes actifs seulement (défaut: false)
--   $include_relations: Inclure les relations (parent, norme) (défaut: true)
-- RETOUR: array<record> - Liste des comptes comptables
-- USAGE:
--   -- Tous les comptes:
--   RETURN fn::get_all_account_charts();
--   
--   -- Comptes d'une norme spécifique:
--   RETURN fn::get_all_account_charts(accounting_standard:pcg2014);
--   
--   -- Comptes actifs seulement:
--   RETURN fn::get_all_account_charts(active_only: true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_all_account_charts(
    $accounting_standard: option<record>,
    $active_only: option<bool>,
    $include_relations: option<bool>
) {
    LET $filter_active = IF $active_only IS NONE { false } ELSE { $active_only };
    LET $with_relations = IF $include_relations IS NONE { true } ELSE { $include_relations };
    
    -- Construire la requête base
    LET $base_where = IF $accounting_standard IS NOT NONE AND $filter_active = true {
        "WHERE accounting_standard = $accounting_standard AND is_active = true"
    } ELSE IF $accounting_standard IS NOT NONE {
        "WHERE accounting_standard = $accounting_standard"
    } ELSE IF $filter_active = true {
        "WHERE is_active = true"
    } ELSE {
        ""
    };
    
    -- Exécuter selon les options
    IF $with_relations = true {
        IF $accounting_standard IS NOT NONE AND $filter_active = true {
            RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true FETCH parent_account, accounting_standard);
        } ELSE IF $accounting_standard IS NOT NONE {
            RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard FETCH parent_account, accounting_standard);
        } ELSE IF $filter_active = true {
            RETURN (SELECT * FROM account_chart WHERE is_active = true FETCH parent_account, accounting_standard);
        } ELSE {
            RETURN (SELECT * FROM account_chart FETCH parent_account, accounting_standard);
        };
    } ELSE {
        IF $accounting_standard IS NOT NONE AND $filter_active = true {
            RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true);
        } ELSE IF $accounting_standard IS NOT NONE {
            RETURN (SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard);
        } ELSE IF $filter_active = true {
            RETURN (SELECT * FROM account_chart WHERE is_active = true);
        } ELSE {
            RETURN (SELECT * FROM account_chart);
        };
    };
} COMMENT "Récupère tous les comptes comptables avec possibilité de filtrage par norme comptable et statut actif."; 