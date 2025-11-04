-- =============================================================================================
-- |
-- | Fichier : fn_get_service_credentials_full.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère la configuration complète d'un service avec tous ses credentials pour l'UI.
-- |
-- | Cette fonction retourne toutes les informations nécessaires pour générer l'interface
-- | de sélection de credentials dans l'UI, avec toutes les traductions i18n.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_service_credentials_full(
    $service_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID du service en record
    LET $service_record = type::thing('service', $service_id);
    
    -- 3. Récupérer le service avec tous ses credentials
    LET $service = (
        SELECT 
            *,
            -- Traduction du nom du service
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.display_name_i18n AND out = $langue_record
            )[0] AS display_name_translated,
            -- Traduction de la description du service
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.description_i18n AND out = $langue_record
            )[0] AS description_translated
        FROM $service_record
    )[0];
    
    -- 4. Vérifier si le service existe
    IF $service == NONE THEN
        RETURN { success: false, error: 'service_not_found', service_id: $service_id };
    END;
    
    -- 5. Récupérer tous les credentials du service avec traductions
    LET $credentials = (
        SELECT 
            id,
            out AS credential_type_id,
            credential_type.* AS credential_type_full,
            is_required,
            presentation.is_recommended,
            presentation.display_order,
            presentation.badge_color_type,
            presentation.display_conditions,
            config.scopes_required,
            config.setup_complexity,
            config.estimated_setup_time,
            config.use_case,
            -- Traductions du credential_type
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS credential_type_name_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.description_i18n AND out = $langue_record
            )[0] AS credential_type_description_translated,
            -- Traductions personnalisées
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = presentation.custom_label_i18n AND out = $langue_record
            )[0] AS custom_label_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = presentation.tooltip_i18n AND out = $langue_record
            )[0] AS tooltip_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = config.custom_description_i18n AND out = $langue_record
            )[0] AS custom_description_translated
        FROM uses_credential
        WHERE in = $service_record
        ORDER BY presentation.display_order ASC, presentation.is_recommended DESC
    );
    
    -- 6. Construire la réponse pour l'UI
    RETURN {
        success: true,
        service: {
            id: $service.id,
            name: $service.name,
            slug: $service.slug,
            display_name: $service.display_name_translated,
            description: $service.description_translated,
            presentation: $service.presentation
        },
        credentials: $credentials
    };
}
COMMENT 'Récupère la configuration complète d\'un service avec tous ses credentials pour génération UI avec traductions i18n.'
PERMISSIONS FULL;

