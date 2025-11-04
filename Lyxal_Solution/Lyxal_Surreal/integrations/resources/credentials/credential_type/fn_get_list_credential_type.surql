-- =============================================================================================
-- |
-- | Fichier : fn_get_list_credential_type.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère la liste des credential_type avec traductions i18n pour l'UI.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_list_credential_type(
    $langue_id: string,
    $user_id: option<string>,
    $parent_run_id: option<string>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);

    -- 2. Récupérer la liste des credential_type avec traductions i18n
    LET $list_credential_type = (
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
            -- Nom du provider (si présent)
            provider.name AS provider_name,
            -- Nom de l'auth_type traduit
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = auth_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS auth_type_name_translated
        FROM credential_type
        WHERE is_active = true
        ORDER BY presentation.display_order ASC
    );

    -- 3. Retourner la liste des credential_type
    RETURN $list_credential_type;
}
COMMENT 'Récupère la liste des credential_type avec leurs traductions i18n pour l\'interface utilisateur.'
PERMISSIONS FULL;

