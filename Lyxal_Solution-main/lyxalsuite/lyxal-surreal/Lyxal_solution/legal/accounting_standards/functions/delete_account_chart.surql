-- =============================================================================
-- FONCTION: fn::delete_account_chart
-- =============================================================================
-- DESCRIPTION: Supprime un compte comptable après vérifications de sécurité
-- PARAMETRES:
--   $account_id: ID du compte à supprimer (obligatoire)
--   $force: Force la suppression même avec des comptes enfants (défaut: false)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Suppression normale (échoue si comptes enfants):
--   RETURN fn::delete_account_chart(account_chart:411000);
--   
--   -- Suppression forcée (supprime aussi les comptes enfants):
--   RETURN fn::delete_account_chart(account_chart:411000, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_account_chart(
    $account_id: record,
    $force: option<bool>
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
    
    -- Vérifier s'il y a des comptes enfants
    LET $child_accounts = (SELECT * FROM account_chart WHERE parent_account = $account_id);
    LET $force_delete = IF $force IS NONE { false } ELSE { $force };
    
    IF count($child_accounts) > 0 AND $force_delete = false {
        RETURN {
            success: false,
            data: NONE,
            message: string::concat("Impossible de supprimer le compte car il a ", <string>count($child_accounts), " compte(s) enfant(s). Utilisez force=true pour forcer la suppression.")
        };
    };
    
    -- Si suppression forcée, supprimer d'abord les comptes enfants récursivement
    IF $force_delete = true AND count($child_accounts) > 0 {
        FOR $child IN $child_accounts {
            LET $child_deletion = fn::delete_account_chart($child.id, true);
            IF $child_deletion.success = false {
                RETURN {
                    success: false,
                    data: NONE,
                    message: string::concat("Erreur lors de la suppression du compte enfant ", $child.account_number, ": ", $child_deletion.message)
                };
            };
        };
    };
    
    -- Supprimer le compte
    LET $deleted_account = (DELETE ONLY $account_id RETURN BEFORE);
    
    RETURN {
        success: true,
        data: $deleted_account,
        message: "Compte comptable supprimé avec succès"
    };
} COMMENT "Supprime un compte comptable après vérifications de sécurité. Peut supprimer récursivement les comptes enfants si force=true."; 