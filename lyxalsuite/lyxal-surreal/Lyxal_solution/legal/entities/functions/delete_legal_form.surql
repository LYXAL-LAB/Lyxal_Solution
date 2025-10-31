-- =============================================================================
-- FONCTION: fn::delete_legal_form
-- =============================================================================
-- DESCRIPTION: Supprime définitivement une forme juridique
-- PARAMETRES:
--   $id: ID de la forme juridique à supprimer (obligatoire)
--   $confirm: Confirmation de suppression (obligatoire, doit être "CONFIRM_DELETE")
--   $deleted_by: Utilisateur effectuant la suppression (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Supprimer une forme juridique:
--   RETURN fn::delete_legal_form(legal_form:abc123, "CONFIRM_DELETE", "admin");
-- AVERTISSEMENT: Cette opération est irréversible !
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_legal_form(
    $id: record,
    $confirm: string,
    $deleted_by: option<string>
) {
    -- Vérifier la confirmation
    IF $confirm != "CONFIRM_DELETE" {
        RETURN {
            success: false,
            data: NONE,
            message: "Suppression annulée. Vous devez confirmer avec 'CONFIRM_DELETE'"
        };
    };
    
    -- Vérifier que la forme juridique existe
    LET $existing_form = (SELECT * FROM ONLY $id);
    IF $existing_form IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Forme juridique non trouvée"
        };
    };
    
    -- Vérifier s'il y a des entités juridiques qui utilisent cette forme
    LET $entities_using_form = (SELECT * FROM legal_entity WHERE legal_form = $id LIMIT 1);
    IF count($entities_using_form) > 0 {
        RETURN {
            success: false,
            data: $existing_form,
            message: "Impossible de supprimer cette forme juridique car elle est utilisée par des entités juridiques"
        };
    };
    
    -- Sauvegarder les données avant suppression
    LET $deleted_data = {
        id: $existing_form.id,
        name: $existing_form.name,
        code: $existing_form.code,
        country: $existing_form.country,
        category: $existing_form.category,
        deleted_on: time::now(),
        deleted_by: $deleted_by
    };
    
    -- Supprimer la forme juridique
    DELETE $id;
    
    RETURN {
        success: true,
        data: $deleted_data,
        message: "Forme juridique supprimée définitivement"
    };
} COMMENT "Supprime définitivement une forme juridique après vérification des contraintes d'intégrité. Nécessite une confirmation explicite."; 