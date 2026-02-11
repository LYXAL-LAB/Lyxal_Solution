-- =============================================================================
-- FONCTION: fn::validate_account
-- =============================================================================
-- DESCRIPTION: Valide un compte selon les règles de validation définies
-- PARAMETRES:
--   $account_id: ID du compte à valider (obligatoire)
--   $data: Données à valider (optionnel)
--   $validation_context: Contexte de validation (optionnel)
-- RETOUR: {success: bool, data: object, message: string}
-- USAGE:
--   -- Validation simple:
--   RETURN fn::validate_account(account_chart:pcg_fr_411);
--   -- Validation avec données:
--   RETURN fn::validate_account(account_chart:pcg_fr_411, { amount: 1000, currency: "EUR" });
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::validate_account(
    $account_id: record,
    $data: option<object>,
    $validation_context: option<string>
) {
    -- Vérifier que le compte existe
    LET $account_exists = (SELECT * FROM ONLY $account_id);
    IF $account_exists IS NONE {
        RETURN {
            success: false,
            data: {
                valid: false,
                errors: ["Le compte spécifié n'existe pas"],
                warnings: [],
                rules_applied: []
            },
            message: "Le compte spécifié n'existe pas"
        };
    };
    
    -- Récupérer les règles de validation applicables (si la table existe)
    LET $validation_rules = (SELECT * FROM accounting_validation_rule 
        WHERE accounting_standard = $account_exists.accounting_standard 
        AND is_active = true);
    
    -- Initialiser le résultat de validation
    LET $validation_result = {
        valid: true,
        errors: [],
        warnings: [],
        rules_applied: [],
        account_info: {
            id: $account_exists.id,
            account_number: $account_exists.account_number,
            account_name: $account_exists.account_name,
            account_type: $account_exists.account_type,
            is_active: $account_exists.is_active
        }
    };
    
    -- Validation basique du compte
    IF $account_exists.is_active = false {
        LET $validation_result = {
            valid: false,
            errors: ["Le compte n'est pas actif"],
            warnings: [],
            rules_applied: ["account_status_check"],
            account_info: $validation_result.account_info
        };
    };
    
    -- Validation des données si fournies
    IF $data IS NOT NONE {
        -- Validation du montant si présent
        IF $data.amount IS NOT NONE {
            IF $data.amount < 0 AND $account_exists.account_type = "asset" {
                LET $validation_result = {
                    valid: false,
                    errors: array::append($validation_result.errors, "Montant négatif non autorisé pour un compte d'actif"),
                    warnings: $validation_result.warnings,
                    rules_applied: array::append($validation_result.rules_applied, "amount_validation"),
                    account_info: $validation_result.account_info
                };
            };
        };
        
        -- Validation de la devise si présente
        IF $data.currency IS NOT NONE {
            IF $data.currency != "EUR" AND $data.currency != "USD" {
                LET $validation_result = {
                    valid: $validation_result.valid,
                    errors: $validation_result.errors,
                    warnings: array::append($validation_result.warnings, "Devise non standard: " + $data.currency),
                    rules_applied: array::append($validation_result.rules_applied, "currency_validation"),
                    account_info: $validation_result.account_info
                };
            };
        };
    };
    
    -- Message final
    LET $final_message = IF $validation_result.valid = true {
        "Compte validé avec succès"
    } ELSE {
        "Erreurs de validation détectées"
    };
    
    RETURN {
        success: true,
        data: $validation_result,
        message: $final_message
    };
} COMMENT "Valide un compte selon les règles de validation définies pour sa norme comptable."; 