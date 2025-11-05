-- =============================================================================================
-- |
-- | Fichier : fn_get_credentials_by_complexity.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère les credentials filtrés par complexité de configuration.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credentials_by_complexity(
    $langue_id: string,
    $complexity: string,
    $service_id: option<string>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Valider la complexité
    IF $complexity NOT IN ['easy', 'medium', 'hard'] {
        RETURN { success: false, error: 'invalid_complexity', complexity: $complexity };
    };
    
    -- 3. Récupérer les credentials filtrés par complexité
    LET $credentials = (
        SELECT 
            id,
            in AS service_id,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = service.identity.display_name_i18n AND out = $langue_record
            )[0] AS service_name_translated,
            out AS credential_type_id,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS credential_type_name_translated,
            config.setup_complexity,
            config.estimated_setup_time,
            config.use_case,
            is_required,
            presentation.is_recommended
        FROM uses_credential
        WHERE config.setup_complexity = $complexity
            AND ($service_id == NONE OR in = type::thing('service', $service_id))
        ORDER BY config.estimated_setup_time ASC, presentation.is_recommended DESC
    );
    
    -- 4. Retourner la liste
    RETURN $credentials;
}
COMMENT 'Récupère les credentials filtrés par complexité de configuration avec traductions i18n.'
PERMISSIONS FULL;

