-- =============================================================================
-- FONCTION: fn::activate_deactivate_account_chart
-- =============================================================================
-- DESCRIPTION: Active ou désactive un compte comptable
-- PARAMETRES:
--   $account_id: ID du compte à modifier (obligatoire)
--   $is_active: Nouveau statut actif (obligatoire)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Activer un compte:
--   RETURN fn::activate_deactivate_account_chart(account_chart:411000, true, "admin");
--   
--   -- Désactiver un compte:
--   RETURN fn::activate_deactivate_account_chart(account_chart:411000, false, "admin");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::activate_deactivate_account_chart(
    $account_id: record,
    $is_active: bool,
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
    
    -- Vérifier si le statut change réellement
    IF $existing_account.is_active = $is_active {
        LET $status_text = IF $is_active { "actif" } ELSE { "inactif" };
        RETURN {
            success: true,
            data: $existing_account,
            message: string::concat("Le compte est déjà ", $status_text)
        };
    };
    
    -- Si on désactive un compte, vérifier les comptes enfants
    IF $is_active = false {
        LET $active_children = (SELECT * FROM account_chart WHERE parent_account = $account_id AND is_active = true);
        IF count($active_children) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: string::concat("Impossible de désactiver le compte car il a ", <string>count($active_children), " compte(s) enfant(s) actif(s)")
            };
        };
    };
    
    -- Mettre à jour le statut
    LET $updated_account = (UPDATE ONLY $account_id SET
        is_active = $is_active,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    LET $action_text = IF $is_active { "activé" } ELSE { "désactivé" };
    
    RETURN {
        success: true,
        data: $updated_account,
        message: string::concat("Compte comptable ", $action_text, " avec succès")
    };
} COMMENT "Active ou désactive un compte comptable avec vérifications sur les comptes enfants."; 