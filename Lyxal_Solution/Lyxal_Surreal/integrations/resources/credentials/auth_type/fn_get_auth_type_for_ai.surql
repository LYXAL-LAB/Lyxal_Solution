-- =============================================================================================
-- |
-- | Fichier : fn_get_auth_type_for_ai.surql
-- | Module : integrations > resource > credentials > auth_type
-- | Description : Récupère la documentation complète d'un auth_type pour contexte IA.
-- |
-- | Cette fonction retourne toutes les informations nécessaires pour que l'IA puisse
-- | comprendre, recommander et utiliser un type d'authentification.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_auth_type_for_ai(
    $auth_type_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID en record auth_type
    LET $auth_type_record = type::thing('auth_type', $auth_type_id);
    
    -- 3. Récupérer l'auth_type avec toute sa documentation
    LET $auth_type = (
        SELECT 
            *,
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
            )[0] AS description_translated
        FROM $auth_type_record
    )[0];
    
    -- 4. Vérifier si l'auth_type existe
    IF $auth_type == NONE THEN
        RETURN { success: false, error: 'auth_type_not_found', auth_type_id: $auth_type_id };
    END;
    
    -- 5. Traduire les tableaux i18n (use_cases, advantages, disadvantages)
    LET $use_cases_translated = IF $auth_type.documentation.use_cases_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $auth_type.documentation.use_cases_i18n)
    ELSE
        []
    END;
    
    LET $advantages_translated = IF $auth_type.documentation.advantages_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $auth_type.documentation.advantages_i18n)
    ELSE
        []
    END;
    
    LET $disadvantages_translated = IF $auth_type.documentation.disadvantages_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $auth_type.documentation.disadvantages_i18n)
    ELSE
        []
    END;
    
    -- 6. Récupérer les noms des providers exemples
    LET $provider_names = IF $auth_type.documentation.example_providers != NONE THEN
        (SELECT VALUE name FROM $auth_type.documentation.example_providers)
    ELSE
        []
    END;
    
    -- 7. Construire la réponse pour l'IA
    RETURN {
        success: true,
        auth_type: {
            id: $auth_type.id,
            name: $auth_type.name,
            slug: $auth_type.slug,
            identity: {
                display_name: $auth_type.display_name_translated,
                description: $auth_type.description_translated
            },
            presentation: $auth_type.presentation,
            quality: $auth_type.quality,
            behavior: $auth_type.behavior,
            documentation: {
                url: $auth_type.documentation.url,
                provider_names: $provider_names,
                use_cases: $use_cases_translated,
                advantages: $advantages_translated,
                disadvantages: $disadvantages_translated
            }
        }
    };
}
COMMENT 'Récupère la documentation complète d\'un auth_type pour contexte IA avec traductions i18n.'
PERMISSIONS FULL;

