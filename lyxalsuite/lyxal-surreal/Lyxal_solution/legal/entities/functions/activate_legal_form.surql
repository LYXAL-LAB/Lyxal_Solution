-- =============================================================================
-- FONCTION: fn::activate_legal_form
-- =============================================================================
-- DESCRIPTION: Active une forme juridique
-- PARAMETRES:
--   $id: ID de la forme juridique à activer (obligatoire)
--   $updated_by: Utilisateur effectuant l'activation (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Activer une forme juridique:
--   RETURN fn::activate_legal_form(legal_form:abc123, "admin");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::activate_legal_form(
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
    
    -- Vérifier si déjà activée
    IF $existing_form.active = true {
        RETURN {
            success: false,
            data: $existing_form,
            message: "Cette forme juridique est déjà activée"
        };
    };
    
    -- Activer la forme juridique
    LET $updated_form = (UPDATE $id SET 
        active = true,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    RETURN {
        success: true,
        data: $updated_form[0],
        message: "Forme juridique activée avec succès"
    };
} COMMENT "Active une forme juridique existante. Vérifie l'existence et le statut actuel."; 