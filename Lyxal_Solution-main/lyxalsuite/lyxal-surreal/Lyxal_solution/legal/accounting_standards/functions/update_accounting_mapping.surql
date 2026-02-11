-- =============================================================================
-- FONCTION: fn::update_accounting_mapping
-- =============================================================================
-- DESCRIPTION: Met à jour un mapping comptable existant
-- PARAMETRES:
--   $mapping_id: ID du mapping à mettre à jour (obligatoire)
--   $target_account: Nouveau compte cible (optionnel)
--   $mapping_type: Nouveau type de mapping (optionnel)
--   $mapping_ratio: Nouveau ratio de mapping (optionnel)
--   $conditions: Nouvelles conditions (optionnel)
--   $notes: Nouvelles notes (optionnel)
--   $is_active: Nouveau statut actif (optionnel)
--   $updated_by: Modifié par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   RETURN fn::update_accounting_mapping(
--     accounting_mapping:xyz123,
--     target_account: account_chart:new_target,
--     mapping_ratio: 0.5,
--     notes: "Mapping modifié pour split 50/50",
--     updated_by: "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_accounting_mapping(
    $mapping_id: record,
    $target_account: option<record>,
    $mapping_type: option<string>,
    $mapping_ratio: option<float>,
    $conditions: option<object>,
    $notes: option<string>,
    $is_active: option<bool>,
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
    
    -- Si nouveau compte cible fourni, vérifier qu'il existe et appartient à la bonne norme
    IF $target_account IS NOT NONE {
        LET $target_acc_exists = (SELECT * FROM ONLY $target_account);
        IF $target_acc_exists IS NONE {
            RETURN {
                success: false,
                data: NONE,
                message: "Le nouveau compte cible spécifié n'existe pas"
            };
        };
        
        -- Vérifier que le nouveau compte cible appartient à la norme cible
        IF $target_acc_exists.accounting_standard != $existing_mapping.target_standard {
            RETURN {
                success: false,
                data: NONE,
                message: "Le nouveau compte cible n'appartient pas à la norme comptable cible"
            };
        };
    };
    
    -- Mettre à jour le mapping
    LET $updated_mapping = (UPDATE ONLY $mapping_id SET
        target_account = IF $target_account IS NOT NONE { $target_account } ELSE { target_account },
        mapping_type = IF $mapping_type IS NOT NONE { $mapping_type } ELSE { mapping_type },
        mapping_ratio = IF $mapping_ratio IS NOT NONE { $mapping_ratio } ELSE { mapping_ratio },
        conditions = IF $conditions IS NOT NONE { $conditions } ELSE { conditions },
        notes = IF $notes IS NOT NONE { $notes } ELSE { notes },
        is_active = IF $is_active IS NOT NONE { $is_active } ELSE { is_active },
        updated_on = time::now(),
        updated_by = IF $updated_by IS NOT NONE { $updated_by } ELSE { updated_by }
    );
    
    RETURN {
        success: true,
        data: $updated_mapping,
        message: "Mapping comptable mis à jour avec succès"
    };
} COMMENT "Met à jour un mapping comptable existant avec validation des contraintes."; 