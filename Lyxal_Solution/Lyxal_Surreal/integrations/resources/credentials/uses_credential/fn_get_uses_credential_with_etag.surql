-- =============================================================================================
-- |
-- | Fichier : fn_get_uses_credential_with_etag.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère une relation uses_credential avec gestion ETag pour optimistic locking et cache.
-- |
-- | Cette fonction permet de :
-- | - Détecter si les données ont changé depuis la dernière requête
-- | - Optimiser le cache côté client
-- | - Éviter les conflits de mise à jour (optimistic locking)
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_uses_credential_with_etag(
    $uses_credential_id: string,
    $client_etag: option<uuid>
) {
    -- 1. Convertir l'ID en record uses_credential
    LET $uses_credential_record = type::thing('uses_credential', $uses_credential_id);
    
    -- 2. Récupérer l'ETag actuel
    LET $current_etag = (
        SELECT VALUE etag
        FROM $uses_credential_record
    )[0];
    
    -- 3. Vérifier si la relation existe
    IF $current_etag == NONE {
        RETURN { success: false, error: 'uses_credential_not_found', uses_credential_id: $uses_credential_id };
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
    
    -- 5. Changement détecté, renvoyer les nouvelles données
    LET $uses_credential = (
        SELECT *
        FROM $uses_credential_record
    )[0];
    
    IF $uses_credential == NONE {
        RETURN { success: false, error: 'uses_credential_not_found', uses_credential_id: $uses_credential_id };
    };
    
    RETURN {
        success: true,
        cached: false,
        etag: $current_etag,
        uses_credential: $uses_credential,
        message: 'Data has changed, returning updated data'
    };
}
COMMENT 'Récupère une relation uses_credential avec gestion ETag pour optimistic locking et cache côté client.'
PERMISSIONS FULL;

