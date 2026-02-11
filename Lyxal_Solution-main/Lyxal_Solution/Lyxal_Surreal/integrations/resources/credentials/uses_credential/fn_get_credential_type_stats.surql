-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_stats.surql
-- | Module : integrations > resource > credentials > uses_credential
-- | Description : Récupère les statistiques sur l'utilisation des credential_type.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_stats(
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Statistiques par credential_type
    LET $stats_by_credential_type = (
        SELECT 
            out AS credential_type_id,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = credential_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS credential_type_name_translated,
            count() AS service_count,
            array::group({
                service_id: in,
                is_required: is_required,
                is_recommended: presentation.is_recommended
            }) AS services_details
        FROM uses_credential
        GROUP BY out
        ORDER BY service_count DESC
    );
    
    -- 3. Services avec plusieurs options de credentials
    LET $all_services = (
        SELECT 
            in AS service_id,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = service.identity.display_name_i18n AND out = $langue_record
            )[0] AS service_name_translated,
            count() AS credential_count,
            array::group({
                credential_type_id: out,
                is_recommended: presentation.is_recommended,
                complexity: config.setup_complexity,
                estimated_time: config.estimated_setup_time
            }) AS credentials_details
        FROM uses_credential
        GROUP BY in
    );
    
    LET $services_with_multiple_credentials = (
        SELECT * FROM $all_services
        WHERE credential_count > 1
        ORDER BY credential_count DESC
    );
    
    -- 4. Retourner les statistiques
    RETURN {
        by_credential_type: $stats_by_credential_type,
        services_with_multiple_options: $services_with_multiple_credentials
    };
}
COMMENT 'Récupère les statistiques sur l\'utilisation des credential_type par les services.'
PERMISSIONS FULL;

