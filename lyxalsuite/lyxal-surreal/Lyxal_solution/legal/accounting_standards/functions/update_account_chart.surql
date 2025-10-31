-- =============================================================================
-- FONCTION: fn::update_account_chart
-- =============================================================================
-- DESCRIPTION: Met à jour un compte comptable existant
-- PARAMETRES:
--   $account_id: ID du compte à mettre à jour (obligatoire)
--   $account_number: Nouveau numéro du compte (optionnel)
--   $account_name: Nouveau nom du compte (optionnel)
--   $account_type: Nouveau type de compte (optionnel)
--   $account_class: Nouvelle classe comptable (optionnel)
--   $level: Nouveau niveau hiérarchique (optionnel)
--   $parent_account: Nouveau compte parent (optionnel)
--   $description: Nouvelle description (optionnel)
--   $debit_credit_nature: Nouvelle nature débit/crédit (optionnel)
--   $is_analytical: Statut analytique (optionnel)
--   $is_auxiliary: Statut auxiliaire (optionnel)
--   $is_reconciliation: Statut rapprochement (optionnel)
--   $is_active: Statut actif (optionnel)
--   $usage_rules: Nouvelles règles d'utilisation (optionnel)
--   $validation_rules: Nouvelles règles de validation (optionnel)
--   $reporting_category: Nouvelle catégorie de reporting (optionnel)
--   $tax_category: Nouvelle catégorie fiscale (optionnel)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::update_account_chart(
--     account_chart:411000,
--     account_name: "Clients - Nouvelle dénomination",
--     description: "Nouvelle description",
--     updated_by: "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_account_chart(
    $account_id: record,
    $account_number: option<string>,
    $account_name: option<string>,
    $account_type: option<string>,
    $account_class: option<int>,
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
    $updated_by: option<string>
) {
    -- Vérifier que le compte existe
    LET $existing_account = (SELECT * FROM ONLY $account_id);
    IF $existing_account IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Le compte comptable spécifié n'existe pas"
        };
    };
    
    -- Vérifier l'unicité du numéro si modifié
    IF $account_number IS NOT NONE {
        LET $duplicate_check = (SELECT * FROM account_chart WHERE account_number = $account_number AND accounting_standard = $existing_account.accounting_standard AND id != $account_id);
        IF count($duplicate_check) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Un autre compte avec ce numéro existe déjà dans cette norme comptable"
            };
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
        IF $parent_exists.accounting_standard != $existing_account.accounting_standard {
            RETURN {
                success: false,
                data: NONE,
                message: "Le compte parent doit appartenir à la même norme comptable"
            };
        };
        
        -- Vérifier qu'on ne crée pas de boucle (le parent ne peut pas être un descendant)
        IF $parent_account = $account_id {
            RETURN {
                success: false,
                data: NONE,
                message: "Un compte ne peut pas être son propre parent"
            };
        };
    };
    
    -- Calculer le niveau automatiquement si le parent change
    LET $final_level = IF $level IS NOT NONE {
        $level
    } ELSE IF $parent_account IS NOT NONE {
        IF $parent_account IS NONE {
            1
        } ELSE {
            LET $parent_data = (SELECT * FROM ONLY $parent_account);
            $parent_data.level + 1
        }
    } ELSE {
        $existing_account.level
    };
    
    -- Mettre à jour le compte
    LET $updated_account = (UPDATE ONLY $account_id SET
        account_number = IF $account_number IS NOT NONE { $account_number } ELSE { account_number },
        account_name = IF $account_name IS NOT NONE { $account_name } ELSE { account_name },
        account_type = IF $account_type IS NOT NONE { $account_type } ELSE { account_type },
        account_class = IF $account_class IS NOT NONE { $account_class } ELSE { account_class },
        level = $final_level,
        parent_account = IF $parent_account IS NOT NONE { $parent_account } ELSE { parent_account },
        description = IF $description IS NOT NONE { $description } ELSE { description },
        debit_credit_nature = IF $debit_credit_nature IS NOT NONE { $debit_credit_nature } ELSE { debit_credit_nature },
        is_analytical = IF $is_analytical IS NOT NONE { $is_analytical } ELSE { is_analytical },
        is_auxiliary = IF $is_auxiliary IS NOT NONE { $is_auxiliary } ELSE { is_auxiliary },
        is_reconciliation = IF $is_reconciliation IS NOT NONE { $is_reconciliation } ELSE { is_reconciliation },
        is_active = IF $is_active IS NOT NONE { $is_active } ELSE { is_active },
        usage_rules = IF $usage_rules IS NOT NONE { $usage_rules } ELSE { usage_rules },
        validation_rules = IF $validation_rules IS NOT NONE { $validation_rules } ELSE { validation_rules },
        reporting_category = IF $reporting_category IS NOT NONE { $reporting_category } ELSE { reporting_category },
        tax_category = IF $tax_category IS NOT NONE { $tax_category } ELSE { tax_category },
        updated_on = time::now(),
        updated_by = IF $updated_by IS NOT NONE { $updated_by } ELSE { updated_by }
    );
    
    RETURN {
        success: true,
        data: $updated_account,
        message: "Compte comptable mis à jour avec succès"
    };
} COMMENT "Met à jour un compte comptable existant. Vérifie l'unicité du numéro et la cohérence hiérarchique."; 