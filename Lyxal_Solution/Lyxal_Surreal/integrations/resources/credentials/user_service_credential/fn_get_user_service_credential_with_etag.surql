-- =============================================================================================
-- |
-- | Fichier : fn_get_user_service_credential_with_etag.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Récupère une credential utilisateur avec gestion ETag pour optimistic locking et cache.
-- |
-- | Cette fonction permet de :
-- | - Détecter si les données ont changé depuis la dernière requête
-- | - Optimiser le cache côté client
-- | - Éviter les conflits de mise à jour (optimistic locking)
-- |
-- | NOTE: Cette fonction ne retourne PAS les données sensibles (credentials) pour des raisons de sécurité.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_user_service_credential_with_etag(
    $credential_id: string,
    $client_etag: option<uuid>
) {
    -- 1. Convertir l'ID en record user_service_credential
    LET $credential_record = type::thing('user_service_credential', $credential_id);
    
    -- 2. Récupérer l'ETag actuel
    LET $current_etag = (
        SELECT VALUE etag
        FROM $credential_record
    )[0];
    
    -- 3. Vérifier si la credential existe
    IF $current_etag == NONE {
        RETURN { success: false, error: 'credential_not_found', credential_id: $credential_id };
    };
    
    -- 4. Comparer avec l'ETag client
    IF $client_etag != NONE AND $current_etag == $client_etag {
        -- Pas de changement, on peut utiliser le cache
        RETURN {
            success: true,
            cached: true,
            etag: $current_etag,
            message: 'No changes detected, use cached data'
        };
    };
    
    -- 5. Changement détecté, renvoyer les nouvelles données (sans credentials sensibles)
    LET $credential = (
        SELECT 
            id,
            user_id,
            service_id,
            credential_type_id,
            is_active,
            identity.name,
            identity.description_i18n,
            -- Ne pas retourner credentials.* (données sensibles)
            metadata.created_at,
            metadata.updated_at,
            metadata.last_used_at,
            metadata.usage_count,
            metadata.last_refreshed_at,
            expires_at,
            etag
        FROM $credential_record
    )[0];
    
    IF $credential == NONE {
        RETURN { success: false, error: 'credential_not_found', credential_id: $credential_id };
    };
    
    RETURN {
        success: true,
        cached: false,
        etag: $current_etag,
        credential: $credential,
        message: 'Data has changed, returning updated data'
    };
}
COMMENT 'Récupère une credential utilisateur avec gestion ETag pour optimistic locking et cache (sans données sensibles).'
PERMISSIONS FULL;

