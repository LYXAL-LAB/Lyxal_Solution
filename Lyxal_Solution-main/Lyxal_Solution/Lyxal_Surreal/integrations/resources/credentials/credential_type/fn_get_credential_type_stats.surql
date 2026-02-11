-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_stats.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère les statistiques sur les credential_type (comptage par type/provider).
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_stats(
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Statistiques par type d'authentification
    LET $stats_by_auth_type = (
        SELECT 
            auth_type AS type_id,
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = auth_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS type_name_translated,
            count() AS total
        FROM credential_type
        WHERE is_active = true
        GROUP BY auth_type
        ORDER BY total DESC
    );
    
    -- 3. Statistiques par provider
    LET $stats_by_provider = (
        SELECT 
            provider AS provider_id,
            provider.name AS provider_name,
            count() AS total
        FROM credential_type
        WHERE is_active = true AND provider IS NOT NONE
        GROUP BY provider
        ORDER BY total DESC
    );
    
    -- 4. Retourner les statistiques
    RETURN {
        by_auth_type: $stats_by_auth_type,
        by_provider: $stats_by_provider
    };
}
COMMENT 'Récupère les statistiques sur les credential_type (comptage par type d\'authentification et par provider).'
PERMISSIONS FULL;

