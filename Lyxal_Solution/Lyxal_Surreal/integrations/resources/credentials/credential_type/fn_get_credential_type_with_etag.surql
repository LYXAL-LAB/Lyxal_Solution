-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_with_etag.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère un credential_type avec gestion ETag pour optimistic locking et cache.
-- |
-- | Cette fonction permet de :
-- | - Détecter si les données ont changé depuis la dernière requête
-- | - Optimiser le cache côté client
-- | - Éviter les conflits de mise à jour (optimistic locking)
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_with_etag(
    $credential_type_id: string,
    $client_etag: option<uuid>
) {
    -- 1. Convertir l'ID en record credential_type
    LET $credential_type_record = type::thing('credential_type', $credential_type_id);
    
    -- 2. Récupérer l'ETag actuel
    LET $current_etag = (
        SELECT VALUE etag
        FROM $credential_type_record
    )[0];
    
    -- 3. Vérifier si le credential_type existe
    IF $current_etag == NONE THEN
        RETURN { success: false, error: 'credential_type_not_found', credential_type_id: $credential_type_id };
    END;
    
    -- 4. Comparer avec l'ETag client
    IF $client_etag != NONE AND $current_etag == $client_etag THEN
        -- Pas de changement, on peut utiliser le cache
        RETURN {
            success: true,
            cached: true,
            etag: $current_etag,
            message: 'No changes detected, use cached data'
        };
    END;
    
    -- 5. Changement détecté, renvoyer les nouvelles données
    LET $credential_type = (
        SELECT *
        FROM $credential_type_record
    )[0];
    
    IF $credential_type == NONE THEN
        RETURN { success: false, error: 'credential_type_not_found', credential_type_id: $credential_type_id };
    END;
    
    RETURN {
        success: true,
        cached: false,
        etag: $current_etag,
        credential_type: $credential_type,
        message: 'Data has changed, returning updated data'
    };
}
COMMENT 'Récupère un credential_type avec gestion ETag pour optimistic locking et cache côté client.'
PERMISSIONS FULL;

