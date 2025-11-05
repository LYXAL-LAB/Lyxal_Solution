-- =============================================================================================
-- |
-- | Fichier : fn_get_list_transmission_method.surql
-- | Module : integrations > resource > credentials > transmission_method
-- | Description : Récupère la liste des transmission_method avec traductions i18n pour l'UI.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_list_transmission_method(
    $langue_id: string,
    $user_id: option<string>,
    $parent_run_id: option<string>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);

    -- 2. Récupérer la liste des transmission_method avec traductions i18n
    LET $list_transmission_method = (
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
            -- Traduction de la description (si présente)
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.description_i18n AND out = $langue_record
            )[0] AS description_translated,
            -- Traduction du tooltip (si présent)
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = presentation.tooltip_i18n AND out = $langue_record
            )[0] AS tooltip_translated,
            presentation,
            presentation.display_order,
            quality.security_level,
            config.is_recommended,
            config.requires_https
        FROM transmission_method
        WHERE is_active = true
        ORDER BY presentation.display_order ASC
    );

    -- 3. Retourner la liste des transmission_method
    RETURN $list_transmission_method;
}
COMMENT 'Récupère la liste des transmission_method avec leurs traductions i18n pour l\'interface utilisateur.'
PERMISSIONS FULL;

