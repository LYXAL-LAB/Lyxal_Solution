-- =============================================================================================
-- |
-- | Fichier : fn_get_services_by_credential_type.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère tous les services utilisant un credential_type.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_services_by_credential_type(
    $credential_type_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID du credential_type en record
    LET $credential_type_record = type::thing('credential_type', $credential_type_id);
    
    -- 3. Récupérer tous les services utilisant ce credential_type
    LET $services = (
        SELECT 
            id,
            in AS service_id,
            service.* AS service_full,
            out AS credential_type_id,
            is_required,
            presentation.is_recommended,
            presentation.display_order,
            config.setup_complexity,
            config.use_case,
            -- Traductions du service
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = service.identity.display_name_i18n AND out = $langue_record
            )[0] AS service_name_translated
        FROM uses_credential
        WHERE out = $credential_type_record
        ORDER BY presentation.is_recommended DESC, service.presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $services;
}
COMMENT 'Récupère tous les services utilisant un credential_type avec traductions i18n.'
PERMISSIONS FULL;

