-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_generic.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère les credential_type génériques (sans provider spécifique).
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_generic(
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Récupérer les credential_type génériques (sans provider)
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
            auth_type.name AS auth_type_name
        FROM credential_type
        WHERE is_active = true AND provider IS NONE
        ORDER BY presentation.display_order ASC
    );
    
    -- 3. Retourner la liste
    RETURN $credential_types;
}
COMMENT 'Récupère les credential_type génériques (sans provider spécifique) avec traductions i18n.'
PERMISSIONS FULL;

