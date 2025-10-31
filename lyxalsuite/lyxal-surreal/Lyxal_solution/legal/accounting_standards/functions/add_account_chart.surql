-- =============================================================================
-- FONCTION: fn::add_account_chart
-- =============================================================================
-- DESCRIPTION: Ajoute un nouveau compte comptable avec toutes ses caractéristiques
-- PARAMETRES:
--   $account_number: Numéro du compte (obligatoire)
--   $account_name: Nom du compte (obligatoire)
--   $accounting_standard: ID de la norme comptable (obligatoire)
--   $account_type: Type de compte (asset/liability/equity/revenue/expense/other) (obligatoire)
--   $account_class: Classe comptable (1-8) (obligatoire)
--   $level: Niveau hiérarchique (1-6) (optionnel, calculé automatiquement)
--   $parent_account: Compte parent (optionnel)
--   $description: Description du compte (optionnel)
--   $debit_credit_nature: Nature débit/crédit (debit/credit/both) (défaut: both)
--   $is_analytical: Compte analytique (défaut: false)
--   $is_auxiliary: Compte auxiliaire (défaut: false)
--   $is_reconciliation: Compte de rapprochement (défaut: false)
--   $is_active: Compte actif (défaut: true)
--   $usage_rules: Règles d'utilisation (optionnel)
--   $validation_rules: Règles de validation (optionnel)
--   $reporting_category: Catégorie de reporting (optionnel)
--   $tax_category: Catégorie fiscale (optionnel)
--   $created_by: Créé par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Exemple minimal:
--   RETURN fn::add_account_chart(
--     "411000", 
--     "Clients", 
--     accounting_standard:pcg2014,
--     "asset",
--     4
--   );
--   
--   -- Exemple complet:
--   RETURN fn::add_account_chart(
--     "411100",
--     "Clients - Ventes de biens",
--     accounting_standard:pcg2014,
--     "asset",
--     4,
--     2,
--     account_chart:411000,
--     "Créances clients pour ventes de biens",
--     "debit",
--     false,
--     false,
--     true,
--     true,
--     { mandatory_fields: ["customer_id"] },
--     { min_amount: 0 },
--     "balance_sheet_assets",
--     "vat_standard",
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::add_account_chart(
    $account_number: string,
    $account_name: string,
    $accounting_standard: record,
    $account_type: string,
    $account_class: int,
    $level: option<int>,
    $parent_account: option<record>,
    $description: option<string>,
    $debit_credit_nature: option<string>,
    $is_analytical: option<bool>,
    $is_auxiliary: option<bool>,
    $is_reconciliation: option<bool>,
    $is_active: option<bool>,
    $usage_rules: option<object>,
    $validation_rules: option<object>,
    $reporting_category: option<string>,
    $tax_category: option<string>,
    $created_by: option<string>
) {
    -- Vérifier l'unicité du numéro de compte dans la norme comptable
    LET $existing_account = (SELECT * FROM account_chart WHERE account_number = $account_number AND accounting_standard = $accounting_standard);
    IF count($existing_account) > 0 {
        RETURN {
            success: false,
            data: NONE,
            message: "Un compte avec ce numéro existe déjà dans cette norme comptable"
        };
    };
    
    -- Vérifier que la norme comptable existe
    LET $standard_exists = (SELECT * FROM ONLY $accounting_standard);
    IF $standard_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La norme comptable spécifiée n'existe pas"
        };
    };
    
    -- Vérifier que le compte parent existe si fourni
    IF $parent_account IS NOT NONE {
        LET $parent_exists = (SELECT * FROM ONLY $parent_account);
        IF $parent_exists IS NONE {
            RETURN {
                success: false,
                data: NONE,
                message: "Le compte parent spécifié n'existe pas"
            };
        };
        
        -- Vérifier que le parent appartient à la même norme comptable
        IF $parent_exists.accounting_standard != $accounting_standard {
            RETURN {
                success: false,
                data: NONE,
                message: "Le compte parent doit appartenir à la même norme comptable"
            };
        };
    };
    
    -- Calculer le niveau automatiquement si non fourni
    LET $final_level = IF $level IS NONE {
        IF $parent_account IS NONE {
            1
        } ELSE {
            LET $parent_data = (SELECT * FROM ONLY $parent_account);
            $parent_data.level + 1
        }
    } ELSE {
        $level
    };
    
    -- Valeurs par défaut
    LET $final_debit_credit_nature = IF $debit_credit_nature IS NONE { "both" } ELSE { $debit_credit_nature };
    LET $final_is_analytical = IF $is_analytical IS NONE { false } ELSE { $is_analytical };
    LET $final_is_auxiliary = IF $is_auxiliary IS NONE { false } ELSE { $is_auxiliary };
    LET $final_is_reconciliation = IF $is_reconciliation IS NONE { false } ELSE { $is_reconciliation };
    LET $final_is_active = IF $is_active IS NONE { true } ELSE { $is_active };
    LET $final_usage_rules = IF $usage_rules IS NONE { {} } ELSE { $usage_rules };
    LET $final_validation_rules = IF $validation_rules IS NONE { {} } ELSE { $validation_rules };
    
    -- Créer le compte comptable
    LET $new_account = (CREATE account_chart CONTENT {
        account_number: $account_number,
        account_name: $account_name,
        accounting_standard: $accounting_standard,
        account_type: $account_type,
        account_class: $account_class,
        level: $final_level,
        parent_account: $parent_account,
        description: $description,
        debit_credit_nature: $final_debit_credit_nature,
        is_analytical: $final_is_analytical,
        is_auxiliary: $final_is_auxiliary,
        is_reconciliation: $final_is_reconciliation,
        is_active: $final_is_active,
        usage_rules: $final_usage_rules,
        validation_rules: $final_validation_rules,
        reporting_category: $reporting_category,
        tax_category: $tax_category,
        created_on: time::now(),
        updated_on: time::now(),
        created_by: $created_by,
        updated_by: $created_by
    });
    
    RETURN {
        success: true,
        data: $new_account[0],
        message: "Compte comptable créé avec succès"
    };
} COMMENT "Ajoute un nouveau compte comptable avec toutes ses caractéristiques. Vérifie l'unicité du numéro par norme comptable et calcule automatiquement le niveau hiérarchique."; 