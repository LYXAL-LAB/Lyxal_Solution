-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_config.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère la configuration technique des credential_type pour développeurs.
-- |
-- | Cette fonction retourne les informations de configuration (oauth2, oauth1, required_fields)
-- | pour un provider spécifique ou tous les credentials actifs.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_config(
    $langue_id: string,
    $provider_id: option<string>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Récupérer les credential_type avec configuration technique
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
            auth_type.* AS auth_type_full,
            config,
            documentation.url.* AS documentation_url
        FROM credential_type
        WHERE is_active = true 
            AND ($provider_id == NONE OR provider = type::thing('provider', $provider_id))
        ORDER BY presentation.display_order ASC
    );
    
    -- 3. Retourner la liste
    RETURN $credential_types;
}
COMMENT 'Récupère la configuration technique des credential_type pour développeurs, optionnellement filtrée par provider.'
PERMISSIONS FULL;

