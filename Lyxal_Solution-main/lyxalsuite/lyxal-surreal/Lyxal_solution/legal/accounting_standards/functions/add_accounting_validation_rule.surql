-- =============================================================================
-- FONCTION: fn::add_accounting_validation_rule
-- =============================================================================
-- DESCRIPTION: Ajoute une nouvelle règle de validation comptable
-- PARAMETRES:
--   $rule_name: Nom de la règle (obligatoire)
--   $rule_type: Type de règle (balance/debit_credit/mandatory_field/format/range/custom) (obligatoire)
--   $accounting_standard: ID de la norme comptable (obligatoire)
--   $applicable_accounts: Tableau des comptes concernés (optionnel)
--   $rule_condition: Condition de la règle (obligatoire)
--   $error_message: Message d'erreur (obligatoire)
--   $severity: Sévérité (error/warning/info) (défaut: error)
--   $is_blocking: Règle bloquante (défaut: false)
--   $is_active: Règle active (défaut: true)
--   $created_by: Créé par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::add_accounting_validation_rule(
--     "Équilibre débit-crédit",
--     "balance",
--     accounting_standard:pcg2014,
--     [],
--     "debit_total = credit_total",
--     "Le total des débits doit égaler le total des crédits",
--     "error",
--     true,
--     true,
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::add_accounting_validation_rule(
    $rule_name: string,
    $rule_type: string,
    $accounting_standard: record,
    $applicable_accounts: option<array<record>>,
    $rule_condition: string,
    $error_message: string,
    $severity: option<string>,
    $is_blocking: option<bool>,
    $is_active: option<bool>,
    $created_by: option<string>
) {
    -- Vérifier que la norme comptable existe
    LET $standard_exists = (SELECT * FROM ONLY $accounting_standard);
    IF $standard_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La norme comptable spécifiée n'existe pas"
        };
    };
    
    -- Vérifier l'unicité du nom de règle pour cette norme
    LET $existing_rule = (SELECT * FROM accounting_validation_rule 
                         WHERE rule_name = $rule_name 
                         AND accounting_standard = $accounting_standard);
    IF count($existing_rule) > 0 {
        RETURN {
            success: false,
            data: NONE,
            message: "Une règle avec ce nom existe déjà pour cette norme comptable"
        };
    };
    
    -- Vérifier que les comptes applicables existent et appartiennent à la norme
    IF $applicable_accounts IS NOT NONE AND count($applicable_accounts) > 0 {
        FOR $account IN $applicable_accounts {
            LET $account_exists = (SELECT * FROM ONLY $account);
            IF $account_exists IS NONE {
                RETURN {
                    success: false,
                    data: NONE,
                    message: "Un des comptes spécifiés n'existe pas: " + <string>$account
                };
            };
            
            IF $account_exists.accounting_standard != $accounting_standard {
                RETURN {
                    success: false,
                    data: NONE,
                    message: "Le compte " + <string>$account + " n'appartient pas à la norme comptable spécifiée"
                };
            };
        };
    };
    
    -- Valeurs par défaut
    LET $final_severity = IF $severity IS NONE { "error" } ELSE { $severity };
    LET $final_is_blocking = IF $is_blocking IS NONE { false } ELSE { $is_blocking };
    LET $final_is_active = IF $is_active IS NONE { true } ELSE { $is_active };
    LET $final_applicable_accounts = IF $applicable_accounts IS NONE { [] } ELSE { $applicable_accounts };
    
    -- Créer la règle de validation
    LET $new_rule = (CREATE accounting_validation_rule CONTENT {
        rule_name: $rule_name,
        rule_type: $rule_type,
        accounting_standard: $accounting_standard,
        applicable_accounts: $final_applicable_accounts,
        rule_condition: $rule_condition,
        error_message: $error_message,
        severity: $final_severity,
        is_blocking: $final_is_blocking,
        is_active: $final_is_active,
        created_on: time::now(),
        updated_on: time::now(),
        created_by: $created_by,
        updated_by: $created_by
    });
    
    RETURN {
        success: true,
        data: $new_rule[0],
        message: "Règle de validation comptable créée avec succès"
    };
} COMMENT "Ajoute une nouvelle règle de validation comptable avec validation complète."; 