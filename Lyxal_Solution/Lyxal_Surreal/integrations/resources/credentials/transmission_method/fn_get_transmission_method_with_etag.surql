-- =============================================================================================
-- |
-- | Fichier : fn_get_transmission_method_with_etag.surql
-- | Module : integrations > resource > credentials > transmission_method
-- | Description : Récupère une transmission_method avec gestion ETag pour optimistic locking et cache.
-- |
-- | Cette fonction permet de :
-- | - Détecter si les données ont changé depuis la dernière requête
-- | - Optimiser le cache côté client
-- | - Éviter les conflits de mise à jour (optimistic locking)
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_transmission_method_with_etag(
    $transmission_method_id: string,
    $client_etag: option<uuid>
) {
    -- 1. Convertir l'ID en record transmission_method
    LET $transmission_method_record = type::thing('transmission_method', $transmission_method_id);
    
    -- 2. Récupérer l'ETag actuel
    LET $current_etag = (
        SELECT VALUE etag
        FROM $transmission_method_record
    )[0];
    
    -- 3. Vérifier si la transmission_method existe
    IF $current_etag == NONE THEN
        RETURN { success: false, error: 'transmission_method_not_found', transmission_method_id: $transmission_method_id };
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
    LET $transmission_method = (
        SELECT *
        FROM $transmission_method_record
    )[0];
    
    IF $transmission_method == NONE THEN
        RETURN { success: false, error: 'transmission_method_not_found', transmission_method_id: $transmission_method_id };
    END;
    
    RETURN {
        success: true,
        cached: false,
        etag: $current_etag,
        transmission_method: $transmission_method,
        message: 'Data has changed, returning updated data'
    };
}
COMMENT 'Récupère une transmission_method avec gestion ETag pour optimistic locking et cache côté client.'
PERMISSIONS FULL;

