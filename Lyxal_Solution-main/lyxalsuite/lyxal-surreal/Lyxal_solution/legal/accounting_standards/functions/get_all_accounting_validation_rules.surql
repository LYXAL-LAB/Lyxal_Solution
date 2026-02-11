-- =============================================================================
-- FONCTION: fn::get_all_accounting_validation_rules
-- =============================================================================
-- DESCRIPTION: Récupère toutes les règles de validation comptable
-- PARAMETRES:
--   $accounting_standard: Filtrer par norme comptable (optionnel)
--   $rule_type: Filtrer par type de règle (optionnel)
--   $is_active: Filtrer par statut actif (optionnel)
--   $severity: Filtrer par sévérité (optionnel)
--   $is_blocking: Filtrer par règles bloquantes (optionnel)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Toutes les règles:
--   RETURN fn::get_all_accounting_validation_rules();
--   -- Règles actives d'une norme:
--   RETURN fn::get_all_accounting_validation_rules(accounting_standard:pcg2014, NONE, true);
--   -- Règles bloquantes de type balance:
--   RETURN fn::get_all_accounting_validation_rules(NONE, "balance", NONE, NONE, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_all_accounting_validation_rules(
    $accounting_standard: option<record>,
    $rule_type: option<string>,
    $is_active: option<bool>,
    $severity: option<string>,
    $is_blocking: option<bool>
) {
    -- Construire la requête avec filtres
    LET $base_query = (SELECT * FROM accounting_validation_rule);
    
    LET $filtered_rules = (
        SELECT * FROM $base_query
        WHERE (
            ($accounting_standard IS NONE OR accounting_standard = $accounting_standard)
            AND ($rule_type IS NONE OR rule_type = $rule_type)
            AND ($is_active IS NONE OR is_active = $is_active)
            AND ($severity IS NONE OR severity = $severity)
            AND ($is_blocking IS NONE OR is_blocking = $is_blocking)
        )
        ORDER BY accounting_standard, rule_type, rule_name
    );
    
    -- Enrichir avec les données des normes et comptes
    LET $enriched_rules = (
        SELECT *,
            accounting_standard.* AS standard_data,
            applicable_accounts.* AS accounts_data
        FROM $filtered_rules
        FETCH accounting_standard, applicable_accounts
    );
    
    RETURN {
        success: true,
        data: $enriched_rules,
        message: "Règles de validation comptable récupérées avec succès"
    };
} COMMENT "Récupère toutes les règles de validation comptable avec filtres optionnels."; 