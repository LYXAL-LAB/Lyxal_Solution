-- =============================================================================================
-- |
-- | Fichier : fn_get_expired_credentials.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Récupère les credentials expirées nécessitant un refresh.
-- |
-- | Cette fonction est utilisée pour identifier les credentials OAuth2 qui nécessitent
-- | un refresh de token avant expiration.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_expired_credentials(
    $user_id: option<string>,
    $langue_id: string,
    $refresh_buffer_minutes: option<int>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Définir le buffer de refresh (défaut: 5 minutes avant expiration)
    LET $buffer_minutes = $refresh_buffer_minutes OR 5;
    
    -- 3. Récupérer les credentials expirées ou proches de l'expiration
    LET $credentials = (
        SELECT 
            id,
            user_id,
            service_id,
            credential_type_id,
            identity.name,
            -- Informations du service
            service.name AS service_name,
            service.slug AS service_slug,
            -- Traductions
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = service.identity.display_name_i18n AND out = $langue_record
            )[0] AS service_name_translated,
            -- Métadonnées d'expiration
            expires_at,
            credentials.oauth2.expires_at AS oauth2_token_expires_at,
            metadata.last_refreshed_at
        FROM user_service_credential
        WHERE expires_at < time::now() + duration::mins($buffer_minutes)
            AND is_active = true 
            AND credentials.oauth2 IS NOT NONE
            AND ($user_id == NONE OR user_id = type::thing('user', $user_id))
        ORDER BY expires_at ASC
    );
    
    -- 4. Retourner la liste
    RETURN $credentials;
}
COMMENT 'Récupère les credentials expirées ou proches de l\'expiration nécessitant un refresh, optionnellement filtrées par utilisateur.'
PERMISSIONS FULL;
