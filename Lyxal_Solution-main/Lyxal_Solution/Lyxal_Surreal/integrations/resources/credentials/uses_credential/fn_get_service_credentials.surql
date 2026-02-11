-- =============================================================================================
-- |
-- | Fichier : fn_get_service_credentials.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère tous les credentials d'un service avec détails complets.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_service_credentials(
    $service_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID du service en record
    LET $service_record = type::thing('service', $service_id);
    
    -- 3. Récupérer tous les credentials du service avec détails
    LET $credentials = (
        SELECT 
            id,
            in AS service_id,
            out AS credential_type_id,
            credential_type.* AS credential_type_full,
            is_required,
            presentation.is_recommended,
            presentation.display_order,
            presentation.badge_color_type,
            presentation.custom_label_i18n,
            presentation.tooltip_i18n,
            presentation.display_conditions,
            config.scopes_required,
            config.permissions_needed,
            config.setup_complexity,
            config.estimated_setup_time,
            config.use_case,
            config.custom_description_i18n,
            documentation.setup_instructions_i18n,
            documentation.video_tutorial_url,
            documentation.troubleshooting_url,
            documentation.best_practices_i18n,
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
        ORDER BY presentation.display_order ASC, presentation.is_recommended DESC
    );
    
    -- 4. Retourner la liste
    RETURN $credentials;
}
COMMENT 'Récupère tous les credentials d\'un service avec détails complets et traductions i18n.'
PERMISSIONS FULL;

