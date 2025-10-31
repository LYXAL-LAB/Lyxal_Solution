-- =============================================================================
-- FONCTION: fn::get_account_charts_hierarchy
-- =============================================================================
-- DESCRIPTION: Récupère la hiérarchie des comptes comptables d'une norme
-- PARAMETRES:
--   $accounting_standard: ID de la norme comptable (obligatoire)
--   $root_account: Compte racine pour limiter la hiérarchie (optionnel)
--   $max_depth: Profondeur maximale (optionnel)
--   $active_only: Filtre les comptes actifs seulement (défaut: false)
-- RETOUR: array<record> - Hiérarchie des comptes avec enfants
-- USAGE:
--   -- Hiérarchie complète d'une norme:
--   RETURN fn::get_account_charts_hierarchy(accounting_standard:pcg2014);
--   
--   -- Hiérarchie à partir d'un compte racine:
--   RETURN fn::get_account_charts_hierarchy(
--     accounting_standard:pcg2014,
--     root_account: account_chart:411000
--   );
--   
--   -- Hiérarchie limitée à 2 niveaux:
--   RETURN fn::get_account_charts_hierarchy(
--     accounting_standard:pcg2014,
--     max_depth: 2
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_account_charts_hierarchy(
    $accounting_standard: record,
    $root_account: option<record>,
    $max_depth: option<int>,
    $active_only: option<bool>
) {
    LET $filter_active = IF $active_only IS NONE { false } ELSE { $active_only };
    LET $depth_limit = IF $max_depth IS NONE { 6 } ELSE { $max_depth };
    
    -- Récupérer les comptes selon les filtres
    LET $accounts = IF $root_account IS NOT NONE AND $filter_active = true {
        SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND (id = $root_account OR parent_account = $root_account) ORDER BY level, account_number
    } ELSE IF $root_account IS NOT NONE {
        SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND (id = $root_account OR parent_account = $root_account) ORDER BY level, account_number
    } ELSE IF $filter_active = true {
        SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND is_active = true AND level <= $depth_limit ORDER BY level, account_number
    } ELSE {
        SELECT * FROM account_chart WHERE accounting_standard = $accounting_standard AND level <= $depth_limit ORDER BY level, account_number
    };
    
    -- Retourner la structure hiérarchique simple
    LET $result = [];
    FOR $account IN $accounts {
        LET $children = IF $filter_active = true {
            SELECT * FROM account_chart WHERE parent_account = $account.id AND is_active = true ORDER BY account_number
        } ELSE {
            SELECT * FROM account_chart WHERE parent_account = $account.id ORDER BY account_number
        };
        
        LET $account_with_children = {
            id: $account.id,
            account_number: $account.account_number,
            account_name: $account.account_name,
            account_type: $account.account_type,
            account_class: $account.account_class,
            level: $account.level,
            parent_account: $account.parent_account,
            accounting_standard: $account.accounting_standard,
            description: $account.description,
            debit_credit_nature: $account.debit_credit_nature,
            is_analytical: $account.is_analytical,
            is_auxiliary: $account.is_auxiliary,
            is_reconciliation: $account.is_reconciliation,
            is_active: $account.is_active,
            usage_rules: $account.usage_rules,
            validation_rules: $account.validation_rules,
            reporting_category: $account.reporting_category,
            tax_category: $account.tax_category,
            created_on: $account.created_on,
            updated_on: $account.updated_on,
            created_by: $account.created_by,
            updated_by: $account.updated_by,
            children: $children
        };
        
        LET $result = array::append($result, $account_with_children);
    };
    
    RETURN $result;
} COMMENT "Récupère la hiérarchie des comptes comptables d'une norme avec leurs enfants directs."; 