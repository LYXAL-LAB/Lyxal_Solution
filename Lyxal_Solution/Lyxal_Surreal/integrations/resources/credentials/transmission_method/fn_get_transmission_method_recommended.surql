-- =============================================================================================
-- |
-- | Fichier : fn_get_transmission_method_recommended.surql
-- | Module : integrations > resource > credentials > transmission_method
-- | Description : Récupère les transmission_method recommandées pour l'IA.
-- |
-- | Cette fonction retourne les méthodes recommandées par défaut, triées par sécurité.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_transmission_method_recommended(
    $langue_id: string,
    $include_all: option<bool>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Définir si on inclut toutes les méthodes ou seulement les recommandées
    LET $show_all = $include_all OR false;
    
    -- 3. Récupérer les transmission_method recommandées ou toutes
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
            -- Traduction du tooltip
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = presentation.tooltip_i18n AND out = $langue_record
            )[0] AS tooltip_translated,
            presentation,
            quality.security_level,
            quality.best_use_cases_i18n,
            quality.avoid_use_cases_i18n,
            config.is_recommended,
            config.requires_https,
            config.technical_details
        FROM transmission_method
        WHERE is_active = true AND ($show_all = true OR config.is_recommended = true)
        ORDER BY config.is_recommended DESC, quality.security_level DESC, presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $transmission_methods;
}
COMMENT 'Récupère les transmission_method recommandées avec traductions i18n, optionnellement toutes les méthodes actives.'
PERMISSIONS FULL;

