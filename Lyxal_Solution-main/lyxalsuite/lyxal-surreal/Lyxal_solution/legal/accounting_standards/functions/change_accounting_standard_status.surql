-- =============================================================================
-- FONCTION: fn::change_accounting_standard_status
-- =============================================================================
-- DESCRIPTION: Change le statut d'une norme comptable
-- PARAMETRES:
--   $id: ID de la norme comptable à modifier (obligatoire)
--   $status: Nouveau statut (active/draft/obsolete/transitional) (obligatoire)
--   $updated_by: Utilisateur effectuant la modification (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Passer en brouillon:
--   RETURN fn::change_accounting_standard_status(accounting_standard:pcg2014, "draft");
--   
--   -- Marquer comme obsolète:
--   RETURN fn::change_accounting_standard_status(accounting_standard:pcg2014, "obsolete", "admin");
--   
--   -- Marquer comme transitional:
--   RETURN fn::change_accounting_standard_status(accounting_standard:pcg2014, "transitional", "admin");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::change_accounting_standard_status(
    $id: record,
    $status: string,
    $updated_by: option<string>
) {
    -- Vérifier que la norme comptable existe
    LET $existing_standard = (SELECT * FROM ONLY $id);
    IF $existing_standard IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Norme comptable non trouvée"
        };
    };
    
    -- Vérifier que le statut est valide
    IF $status NOT IN ['active', 'draft', 'obsolete', 'transitional'] {
        RETURN {
            success: false,
            data: NONE,
            message: "Statut invalide. Valeurs autorisées: active, draft, obsolete, transitional"
        };
    };
    
    -- Vérifier si le statut est déjà celui demandé
    IF $existing_standard.status = $status {
        RETURN {
            success: false,
            data: $existing_standard,
            message: "Cette norme comptable a déjà le statut '" + $status + "'"
        };
    };
    
    -- Changer le statut
    LET $updated_standard = (UPDATE $id SET 
        status = $status,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    LET $status_messages = {
        active: "Norme comptable activée avec succès",
        draft: "Norme comptable mise en brouillon avec succès", 
        obsolete: "Norme comptable marquée comme obsolète avec succès",
        transitional: "Norme comptable marquée comme transitionnelle avec succès"
    };
    
    RETURN {
        success: true,
        data: $updated_standard[0],
        message: $status_messages[$status]
    };
} COMMENT "Change le statut d'une norme comptable. Vérifie la validité du statut et l'existence de la norme."; 