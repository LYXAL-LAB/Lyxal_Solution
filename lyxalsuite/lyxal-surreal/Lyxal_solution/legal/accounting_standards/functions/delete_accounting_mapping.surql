-- =============================================================================
-- FONCTION: fn::delete_accounting_mapping
-- =============================================================================
-- DESCRIPTION: Supprime un mapping comptable
-- PARAMETRES:
--   $mapping_id: ID du mapping à supprimer (obligatoire)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::delete_accounting_mapping(accounting_mapping:xyz123);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_accounting_mapping(
    $mapping_id: record
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
    
    -- Supprimer le mapping
    LET $deleted_mapping = (DELETE ONLY $mapping_id RETURN BEFORE);
    
    RETURN {
        success: true,
        data: $deleted_mapping,
        message: "Mapping comptable supprimé avec succès"
    };
} COMMENT "Supprime un mapping comptable après vérifications de sécurité."; 