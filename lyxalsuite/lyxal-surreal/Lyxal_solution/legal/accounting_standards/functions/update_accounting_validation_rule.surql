-- =============================================================================
-- FONCTION: fn::update_accounting_validation_rule
-- =============================================================================
-- DESCRIPTION: Met à jour une règle de validation comptable existante
-- PARAMETRES:
--   $rule_id: ID de la règle à mettre à jour (obligatoire)
--   $rule_name: Nouveau nom de la règle (optionnel)
--   $rule_type: Nouveau type de règle (optionnel)
--   $applicable_accounts: Nouveaux comptes concernés (optionnel)
--   $rule_condition: Nouvelle condition (optionnel)
--   $error_message: Nouveau message d'erreur (optionnel)
--   $severity: Nouvelle sévérité (optionnel)
--   $is_blocking: Nouveau statut bloquant (optionnel)
--   $is_active: Nouveau statut actif (optionnel)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::update_accounting_validation_rule(
--     accounting_validation_rule:xyz123,
--     "Équilibre débit-crédit modifié",
--     NONE,
--     [],
--     "debit_total = credit_total AND amount > 0",
--     "Le total des débits doit égaler le total des crédits avec montant positif",
--     "warning",
--     false,
--     true,
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_accounting_validation_rule(
    $rule_id: record,
    $rule_name: option<string>,
    $rule_type: option<string>,
    $applicable_accounts: option<array<record>>,
    $rule_condition: option<string>,
    $error_message: option<string>,
    $severity: option<string>,
    $is_blocking: option<bool>,
    $is_active: option<bool>,
    $updated_by: option<string>
) {
    -- Vérifier que la règle existe
    LET $existing_rule = (SELECT * FROM ONLY $rule_id);
    IF $existing_rule IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La règle de validation spécifiée n'existe pas"
        };
    };
    
    -- Vérifier l'unicité du nom de règle si changé
    IF $rule_name IS NOT NONE AND $rule_name != $existing_rule.rule_name {
        LET $name_conflict = (SELECT * FROM accounting_validation_rule 
                             WHERE rule_name = $rule_name 
                             AND accounting_standard = $existing_rule.accounting_standard
                             AND id != $rule_id);
        IF count($name_conflict) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Une règle avec ce nom existe déjà pour cette norme comptable"
            };
        };
    };
    
    -- Vérifier que les nouveaux comptes applicables existent et appartiennent à la norme
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
            
            IF $account_exists.accounting_standard != $existing_rule.accounting_standard {
                RETURN {
                    success: false,
                    data: NONE,
                    message: "Le compte " + <string>$account + " n'appartient pas à la norme comptable de cette règle"
                };
            };
        };
    };
    
    -- Mettre à jour la règle
    LET $updated_rule = (UPDATE ONLY $rule_id SET
        rule_name = IF $rule_name IS NOT NONE { $rule_name } ELSE { rule_name },
        rule_type = IF $rule_type IS NOT NONE { $rule_type } ELSE { rule_type },
        applicable_accounts = IF $applicable_accounts IS NOT NONE { $applicable_accounts } ELSE { applicable_accounts },
        rule_condition = IF $rule_condition IS NOT NONE { $rule_condition } ELSE { rule_condition },
        error_message = IF $error_message IS NOT NONE { $error_message } ELSE { error_message },
        severity = IF $severity IS NOT NONE { $severity } ELSE { severity },
        is_blocking = IF $is_blocking IS NOT NONE { $is_blocking } ELSE { is_blocking },
        is_active = IF $is_active IS NOT NONE { $is_active } ELSE { is_active },
        updated_on = time::now(),
        updated_by = IF $updated_by IS NOT NONE { $updated_by } ELSE { updated_by }
    );
    
    RETURN {
        success: true,
        data: $updated_rule,
        message: "Règle de validation comptable mise à jour avec succès"
    };
} COMMENT "Met à jour une règle de validation comptable existante avec validation complète."; 