-- =============================================================================================
-- |
-- | Fichier : fn_get_transmission_method_security.surql
-- | Module : integrations > resource > credentials > transmission_method
-- | Description : Récupère les transmission_method sécurisées selon le niveau de sécurité.
-- |
-- | Cette fonction permet à l'IA de recommander des méthodes selon le contexte de sécurité.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_transmission_method_security(
    $langue_id: string,
    $security_level_min: option<int>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Définir le niveau de sécurité minimum par défaut
    LET $min_level = $security_level_min OR 4;
    
    -- 3. Récupérer les transmission_method sécurisées
    LET $transmission_methods = (
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
            quality.security_level,
            quality.security_concerns_i18n,
            quality.best_use_cases_i18n,
            quality.avoid_use_cases_i18n,
            config.is_recommended,
            config.requires_https,
            config.technical_details
        FROM transmission_method
        WHERE is_active = true AND quality.security_level >= $min_level
        ORDER BY config.is_recommended DESC, quality.security_level DESC, presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $transmission_methods;
}
COMMENT 'Récupère les transmission_method sécurisées avec traductions i18n, filtrées par niveau de sécurité minimum.'
PERMISSIONS FULL;

