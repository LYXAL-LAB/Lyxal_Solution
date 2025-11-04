-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_by_auth_type.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère les credential_type par type d'authentification avec métadonnées.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_by_auth_type(
    $auth_type_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID de l'auth_type en record
    LET $auth_type_record = type::thing('auth_type', $auth_type_id);
    
    -- 3. Récupérer les credential_type avec métadonnées de qualité
    LET $credential_types = (
        SELECT 
            id,
            name,
            slug,
            -- Traduction du nom affiché
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.display_name_i18n AND out = $langue_record
            )[0] AS display_name_translated,
            presentation,
            config,
            -- Métriques de qualité de l'auth_type
            auth_type.quality.security_level,
            auth_type.quality.popularity_score,
            auth_type.quality.implementation_complexity,
            provider.name AS provider_name
        FROM credential_type
        WHERE is_active = true AND auth_type = $auth_type_record
        ORDER BY auth_type.quality.security_level DESC, presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $credential_types;
}
COMMENT 'Récupère les credential_type par type d\'authentification avec métadonnées de qualité et traductions i18n.'
PERMISSIONS FULL;

