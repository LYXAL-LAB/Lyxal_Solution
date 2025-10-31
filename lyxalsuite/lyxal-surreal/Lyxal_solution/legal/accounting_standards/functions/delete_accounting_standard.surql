-- =============================================================================
-- FONCTION: fn::delete_accounting_standard
-- =============================================================================
-- DESCRIPTION: Supprime une norme comptable avec vérifications de sécurité
-- PARAMETRES:
--   $id: ID de la norme comptable à supprimer (obligatoire)
--   $force: Force la suppression même si des références existent (défaut: false)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Suppression normale:
--   RETURN fn::delete_accounting_standard(accounting_standard:pcg2014);
--   
--   -- Suppression forcée:
--   RETURN fn::delete_accounting_standard(accounting_standard:pcg2014, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_accounting_standard(
    $id: record,
    $force: option<bool>
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
    
    LET $final_force = IF $force IS NONE { false } ELSE { $force };
    
    -- Vérifier les références si suppression non forcée
    IF $final_force = false {
        -- Vérifier si cette norme est utilisée comme parent
        LET $child_standards = (SELECT * FROM accounting_standard WHERE parent_standard = $id);
        IF count($child_standards) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Impossible de supprimer : cette norme est utilisée comme parent par d'autres normes"
            };
        };
        
        -- Vérifier si cette norme est référencée dans related_standards
        LET $related_references = (SELECT * FROM accounting_standard WHERE $id IN related_standards);
        IF count($related_references) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Impossible de supprimer : cette norme est référencée par d'autres normes"
            };
        };
    };
    
    -- Effectuer la suppression
    LET $deleted_standard = $existing_standard;
    DELETE $id;
    
    RETURN {
        success: true,
        data: $deleted_standard,
        message: "Norme comptable supprimée avec succès"
    };
} COMMENT "Supprime une norme comptable avec vérifications de sécurité pour éviter les références orphelines. Option force pour contourner les vérifications."; 