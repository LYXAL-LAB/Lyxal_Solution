-- =============================================================================
-- FONCTION: fn::get_validation_rules_by_standard
-- =============================================================================
-- DESCRIPTION: Récupère toutes les règles de validation pour une norme comptable
-- PARAMETRES:
--   $accounting_standard: ID de la norme comptable (obligatoire)
--   $is_active: Filtrer par statut actif (optionnel, défaut: true)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Toutes les règles actives d'une norme:
--   RETURN fn::get_validation_rules_by_standard(accounting_standard:pcg2014);
--   -- Toutes les règles (actives et inactives):
--   RETURN fn::get_validation_rules_by_standard(accounting_standard:pcg2014, false);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_validation_rules_by_standard(
    $accounting_standard: record,
    $is_active: option<bool>
) {
    -- Vérifier que la norme comptable existe
    LET $standard_exists = (SELECT * FROM ONLY $accounting_standard);
    IF $standard_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "La norme comptable spécifiée n'existe pas"
        };
    };
    
    -- Valeur par défaut pour is_active
    LET $active_filter = IF $is_active IS NONE { true } ELSE { $is_active };
    
    -- Récupérer les règles
    LET $rules = IF $active_filter = true {
        (SELECT * FROM accounting_validation_rule 
         WHERE accounting_standard = $accounting_standard 
         AND is_active = true 
         ORDER BY rule_type, severity DESC, rule_name)
    } ELSE {
        (SELECT * FROM accounting_validation_rule 
         WHERE accounting_standard = $accounting_standard 
         ORDER BY rule_type, severity DESC, rule_name)
    };
    
    -- Enrichir avec les données des comptes applicables
    LET $enriched_rules = (
        SELECT *,
            applicable_accounts.* AS accounts_data
        FROM $rules
        FETCH applicable_accounts
    );
    
    RETURN {
        success: true,
        data: $enriched_rules,
        message: "Règles de validation pour la norme " + $standard_exists.name + " récupérées avec succès"
    };
} COMMENT "Récupère toutes les règles de validation pour une norme comptable spécifique."; 