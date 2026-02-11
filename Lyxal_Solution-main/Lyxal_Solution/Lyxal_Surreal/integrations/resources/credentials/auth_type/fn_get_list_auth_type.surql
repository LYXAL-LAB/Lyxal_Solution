DEFINE FUNCTION IF NOT EXISTS fn::get_list_auth_type(
    $langue_id: string,
    $user_id: option<string>,
    $parent_run_id: option<string>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);

    -- 2. Récupérer la liste des auth_type avec traductions i18n et quality
    LET $list_auth_type = (
        SELECT 
            *,
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
                WHERE in = presentation.tooltip AND out = $langue_record
            )[0] AS tooltip_translated
        FROM auth_type
        WHERE is_active = true
        ORDER BY presentation.display_order ASC, quality.popularity_score DESC
    );

    -- 3. Retourner la liste des auth_type
    RETURN $list_auth_type;
}
COMMENT 'Récupère la liste des types d\'authentification avec leurs traductions i18n.'
PERMISSIONS FULL;