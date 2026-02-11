-- =============================================================================
-- FONCTION: fn::get_accounts_by_class
-- =============================================================================
-- DESCRIPTION: Récupère tous les comptes d'une classe spécifique pour une norme
-- PARAMETRES:
--   $standard_id: ID de la norme comptable (obligatoire)
--   $class: Numéro de classe comptable (obligatoire)
--   $is_active: Filtrer par statut actif (optionnel, défaut: true)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Tous les comptes actifs de classe 4 (clients/fournisseurs):
--   RETURN fn::get_accounts_by_class(accounting_standard:pcg_france, 4);
--   -- Tous les comptes de classe 1 (y compris inactifs):
--   RETURN fn::get_accounts_by_class(accounting_standard:pcg_france, 1, false);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_accounts_by_class(
    $standard_id: record,
    $class: int,
    $is_active: option<bool>
) {
    -- Vérifier que la norme comptable existe
    LET $standard_exists = (SELECT * FROM ONLY $standard_id);
    IF $standard_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "La norme comptable spécifiée n'existe pas"
        };
    };
    
    -- Valeur par défaut pour is_active
    LET $active_filter = IF $is_active IS NONE { true } ELSE { $is_active };
    
    -- Récupérer les comptes de la classe
    LET $accounts = IF $active_filter = true {
        (SELECT * FROM account_chart 
         WHERE accounting_standard = $standard_id 
         AND account_class = $class 
         AND is_active = true 
         ORDER BY account_number)
    } ELSE {
        (SELECT * FROM account_chart 
         WHERE accounting_standard = $standard_id 
         AND account_class = $class 
         ORDER BY account_number)
    };
    
    -- Enrichir avec les données de la norme
    LET $enriched_accounts = (SELECT *,
        accounting_standard.* AS standard_data
    FROM $accounts
    FETCH accounting_standard);
    
    RETURN {
        success: true,
        data: $enriched_accounts,
        message: "Comptes de classe " + <string>$class + " récupérés avec succès"
    };
} COMMENT "Récupère tous les comptes d'une classe spécifique pour une norme comptable."; 