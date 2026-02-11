-- =============================================================================
-- FONCTION: fn::get_validation_rules_by_type
-- =============================================================================
-- DESCRIPTION: Récupère toutes les règles de validation par type
-- PARAMETRES:
--   $rule_type: Type de règle (balance/debit_credit/mandatory_field/format/range/custom) (obligatoire)
--   $accounting_standard: Filtrer par norme comptable (optionnel)
--   $is_active: Filtrer par statut actif (optionnel, défaut: true)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Toutes les règles de balance actives:
--   RETURN fn::get_validation_rules_by_type("balance");
--   -- Règles de format pour une norme spécifique:
--   RETURN fn::get_validation_rules_by_type("format", accounting_standard:pcg2014);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_validation_rules_by_type(
    $rule_type: string,
    $accounting_standard: option<record>,
    $is_active: option<bool>
) {
    -- Vérifier que la norme comptable existe si fournie
    IF $accounting_standard IS NOT NONE {
        LET $standard_exists = (SELECT * FROM ONLY $accounting_standard);
        IF $standard_exists IS NONE {
            RETURN {
                success: false,
                data: [],
                message: "La norme comptable spécifiée n'existe pas"
            };
        };
    };
    
    -- Valeur par défaut pour is_active
    LET $active_filter = IF $is_active IS NONE { true } ELSE { $is_active };
    
    -- Récupérer les règles selon les filtres
    LET $rules = (
        SELECT * FROM accounting_validation_rule
        WHERE rule_type = $rule_type
        AND ($accounting_standard IS NONE OR accounting_standard = $accounting_standard)
        AND ($active_filter = false OR is_active = true)
        ORDER BY accounting_standard, severity DESC, rule_name
    );
    
    -- Enrichir avec les données des normes et comptes
    LET $enriched_rules = (
        SELECT *,
            accounting_standard.* AS standard_data,
            applicable_accounts.* AS accounts_data
        FROM $rules
        FETCH accounting_standard, applicable_accounts
    );
    
    RETURN {
        success: true,
        data: $enriched_rules,
        message: "Règles de validation de type '" + $rule_type + "' récupérées avec succès"
    };
} COMMENT "Récupère toutes les règles de validation par type avec filtres optionnels."; 