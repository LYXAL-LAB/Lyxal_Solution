-- =============================================================================================
-- |
-- | Fichier : fn_delete_user_service_credential.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Supprime une credential utilisateur.
-- |
-- | Cette fonction effectue une suppression logique (is_active = false) plutôt qu'une
-- | suppression physique pour préserver l'historique et permettre la récupération.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::delete_user_service_credential(
    $credential_id: string,
    $hard_delete: option<bool>
) {
    -- 1. Convertir l'ID en record
    LET $credential_record = type::thing('user_service_credential', $credential_id);
    
    -- 2. Vérifier si la credential existe
    LET $credential = (
        SELECT id, user_id, service_id, is_active
        FROM $credential_record
    )[0];
    
    IF $credential == NONE {
        RETURN {
            success: false,
            error: 'credential_not_found',
            credential_id: $credential_id
        };
    };
    
    -- 3. Vérifier si hard_delete est demandé
    LET $should_hard_delete = $hard_delete OR false;
    
    -- 4. Suppression logique ou physique
    IF $should_hard_delete {
        -- Suppression physique (irréversible)
        LET $deleted = (
            DELETE $credential_record
            RETURN BEFORE
        )[0];
        
        IF $deleted == NONE {
            RETURN {
                success: false,
                error: 'delete_failed',
                message: 'Failed to delete credential'
            };
        };
        
        RETURN {
            success: true,
            deleted: true,
            hard_delete: true,
            credential_id: $credential_id
        };
    } ELSE {
        -- Suppression logique (is_active = false)
        LET $updated = (
            UPDATE $credential_record SET is_active = false
            RETURN AFTER
        )[0];
        
        IF $updated == NONE {
            RETURN {
                success: false,
                error: 'delete_failed',
                message: 'Failed to deactivate credential'
            };
        };
        
        RETURN {
            success: true,
            deleted: true,
            hard_delete: false,
            credential: {
                id: $updated.id,
                is_active: $updated.is_active,
                etag: $updated.etag
            }
        };
    };
}
COMMENT 'Supprime une credential (suppression logique par défaut, suppression physique si hard_delete=true).'
PERMISSIONS FULL;

