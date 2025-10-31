-- =============================================================================
-- FONCTION: fn::deactivate_legal_form
-- =============================================================================
-- DESCRIPTION: Désactive une forme juridique
-- PARAMETRES:
--   $id: ID de la forme juridique à désactiver (obligatoire)
--   $updated_by: Utilisateur effectuant la désactivation (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Désactiver une forme juridique:
--   RETURN fn::deactivate_legal_form(legal_form:abc123, "admin");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::deactivate_legal_form(
    $id: record,
    $updated_by: option<string>
) {
    -- Vérifier que la forme juridique existe
    LET $existing_form = (SELECT * FROM ONLY $id);
    IF $existing_form IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Forme juridique non trouvée"
        };
    };
    
    -- Vérifier si déjà désactivée
    IF $existing_form.active = false {
        RETURN {
            success: false,
            data: $existing_form,
            message: "Cette forme juridique est déjà désactivée"
        };
    };
    
    -- Désactiver la forme juridique
    LET $updated_form = (UPDATE $id SET 
        active = false,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    RETURN {
        success: true,
        data: $updated_form[0],
        message: "Forme juridique désactivée avec succès"
    };
} COMMENT "Désactive une forme juridique existante. Vérifie l'existence et le statut actuel."; 