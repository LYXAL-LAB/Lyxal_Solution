-- =============================================================================================
-- |
-- | Fichier : fn_get_auth_type_config.surql
-- | Module : integrations > resource > credentials > auth_type
-- | Description : Récupère la configuration technique des auth_type pour développeurs.
-- |
-- | Cette fonction retourne les informations de configuration (schema, template, http)
-- | filtrées par complexité d'implémentation si fournie.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_auth_type_config(
    $langue_id: string,
    $complexity_max: option<int>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Construire la condition WHERE
    LET $where_condition = IF $complexity_max != NONE THEN
        "WHERE is_active = true AND quality.implementation_complexity <= " + string::from($complexity_max)
    ELSE
        "WHERE is_active = true"
    END;
    
    -- 3. Récupérer les auth_type avec configuration technique
    LET $auth_types = (
        SELECT 
            name,
            slug,
            config,
            http.typical_headers,
            http.transmission_method.* AS transmission_method,
            behavior,
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
            -- Métriques de complexité
            quality.implementation_complexity,
            quality.security_level
        FROM auth_type
        WHERE is_active = true AND ($complexity_max == NONE OR quality.implementation_complexity <= $complexity_max)
        ORDER BY quality.implementation_complexity ASC, quality.security_level DESC
    );
    
    -- 4. Retourner la liste
    RETURN $auth_types;
}
COMMENT 'Récupère la configuration technique des auth_type pour développeurs, optionnellement filtrée par complexité d\'implémentation.'
PERMISSIONS FULL;

