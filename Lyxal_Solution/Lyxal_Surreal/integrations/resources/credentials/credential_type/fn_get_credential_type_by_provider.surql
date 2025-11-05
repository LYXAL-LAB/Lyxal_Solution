-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_by_provider.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère les credential_type d'un provider spécifique.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_by_provider(
    $provider_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID du provider en record
    LET $provider_record = type::thing('provider', $provider_id);
    
    -- 3. Récupérer les credential_type du provider
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
            -- Traduction de la description
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.description_i18n AND out = $langue_record
            )[0] AS description_translated,
            presentation,
            presentation.display_order,
            auth_type.* AS auth_type_full,
            config,
            documentation.url.* AS documentation_url
        FROM credential_type
        WHERE is_active = true AND provider = $provider_record
        ORDER BY presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $credential_types;
}
COMMENT 'Récupère les credential_type d\'un provider spécifique avec traductions i18n.'
PERMISSIONS FULL;

