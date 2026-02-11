-- =============================================================================
-- FONCTION: fn::activate_deactivate_accounting_mapping
-- =============================================================================
-- DESCRIPTION: Active ou désactive un mapping comptable
-- PARAMETRES:
--   $mapping_id: ID du mapping (obligatoire)
--   $is_active: Nouveau statut actif (obligatoire)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Désactiver un mapping:
--   RETURN fn::activate_deactivate_accounting_mapping(
--     accounting_mapping:xyz123,
--     false,
--     "admin"
--   );
--   -- Activer un mapping:
--   RETURN fn::activate_deactivate_accounting_mapping(
--     accounting_mapping:xyz123,
--     true,
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::activate_deactivate_accounting_mapping(
    $mapping_id: record,
    $is_active: bool,
    $updated_by: option<string>
) {
    -- Vérifier que le mapping existe
    LET $existing_mapping = (SELECT * FROM ONLY $mapping_id);
    IF $existing_mapping IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Le mapping comptable spécifié n'existe pas"
        };
    };
    
    -- Vérifier si le statut change vraiment
    IF $existing_mapping.is_active = $is_active {
        LET $status_text = IF $is_active { "actif" } ELSE { "inactif" };
        RETURN {
            success: false,
            data: $existing_mapping,
            message: "Le mapping est déjà " + $status_text
        };
    };
    
    -- Mettre à jour le statut
    LET $updated_mapping = (UPDATE ONLY $mapping_id SET
        is_active = $is_active,
        updated_on = time::now(),
        updated_by = $updated_by
    );
    
    LET $action_text = IF $is_active { "activé" } ELSE { "désactivé" };
    
    RETURN {
        success: true,
        data: $updated_mapping,
        message: "Mapping comptable " + $action_text + " avec succès"
    };
} COMMENT "Active ou désactive un mapping comptable avec validation."; 