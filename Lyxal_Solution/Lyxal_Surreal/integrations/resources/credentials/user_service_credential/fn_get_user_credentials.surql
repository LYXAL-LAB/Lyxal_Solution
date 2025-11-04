-- =============================================================================================
-- |
-- | Fichier : fn_get_user_credentials.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Récupère toutes les credentials d'un utilisateur.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_user_credentials(
    $user_id: string,
    $langue_id: string,
    $include_inactive: option<bool>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID utilisateur en record
    LET $user_record = type::thing('user', $user_id);
    
    -- 3. Définir si on inclut les credentials inactives
    LET $show_inactive = $include_inactive OR false;
    
    -- 4. Récupérer toutes les credentials de l'utilisateur
    LET $credentials = (
        SELECT 
            id,
            user_id,
            service_id,
            credential_type_id,
            is_active,
            identity.name,
            identity.description_i18n,
            -- Informations du credential_type
            credential_type.* AS credential_type_full,
            -- Informations du service
            service.* AS service_full,
            -- Traductions
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.description_i18n AND out = $langue_record
            )[0] AS description_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS credential_type_name_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = service.identity.display_name_i18n AND out = $langue_record
            )[0] AS service_name_translated,
            -- Métadonnées (sans credentials sensibles)
            metadata.created_at,
            metadata.updated_at,
            metadata.last_used_at,
            metadata.usage_count,
            metadata.last_refreshed_at,
            expires_at,
            etag
        FROM user_service_credential
        WHERE user_id = $user_record 
            AND ($show_inactive = true OR is_active = true)
        ORDER BY is_active DESC, metadata.last_used_at DESC, metadata.created_at DESC
    );
    
    -- 5. Retourner la liste
    RETURN $credentials;
}
COMMENT 'Récupère toutes les credentials d\'un utilisateur avec traductions i18n (sans données sensibles).'
PERMISSIONS FULL;

