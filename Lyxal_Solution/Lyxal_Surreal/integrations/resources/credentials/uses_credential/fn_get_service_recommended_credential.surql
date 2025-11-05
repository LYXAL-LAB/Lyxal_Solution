-- =============================================================================================
-- |
-- | Fichier : fn_get_service_recommended_credential.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère le credential recommandé d'un service.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_service_recommended_credential(
    $service_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID du service en record
    LET $service_record = type::thing('service', $service_id);
    
    -- 3. Récupérer le credential recommandé
    LET $credential = (
        SELECT 
            id,
            in AS service_id,
            out AS credential_type_id,
            credential_type.* AS credential_type_full,
            is_required,
            presentation.is_recommended,
            presentation.display_order,
            presentation.badge_color_type,
            config.scopes_required,
            config.permissions_needed,
            config.setup_complexity,
            config.estimated_setup_time,
            config.use_case,
            config.custom_description_i18n,
            documentation.setup_instructions_i18n,
            documentation.video_tutorial_url,
            -- Traductions
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS credential_type_name_translated,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.description_i18n AND out = $langue_record
            )[0] AS credential_type_description_translated
        FROM uses_credential
        WHERE in = $service_record 
            AND presentation.is_recommended = true
        ORDER BY presentation.display_order ASC
        LIMIT 1
    )[0];
    
    -- 4. Vérifier si un credential recommandé existe
    IF $credential == NONE {
        RETURN { success: false, error: 'no_recommended_credential', service_id: $service_id };
    };
    
    -- 5. Retourner le credential
    RETURN {
        success: true,
        credential: $credential
    };
}
COMMENT 'Récupère le credential recommandé d\'un service avec traductions i18n.'
PERMISSIONS FULL;

