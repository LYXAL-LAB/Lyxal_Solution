-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_for_ai.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère la documentation complète d'un credential_type pour contexte IA.
-- |
-- | Cette fonction retourne toutes les informations nécessaires pour que l'IA puisse
-- | comprendre, recommander et utiliser un type de credential.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_for_ai(
    $credential_type_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID en record credential_type
    LET $credential_type_record = type::thing('credential_type', $credential_type_id);
    
    -- 3. Récupérer le credential_type avec toute sa documentation
    LET $credential_type = (
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
        FROM $credential_type_record
    )[0];
    
    -- 4. Vérifier si le credential_type existe
    IF $credential_type == NONE {
        RETURN { success: false, error: 'credential_type_not_found', credential_type_id: $credential_type_id };
    };
    
    -- 5. Récupérer les métriques de qualité de l'auth_type
    LET $auth_type_quality = (
        SELECT 
            quality.security_level,
            quality.popularity_score,
            quality.implementation_complexity
        FROM $credential_type.auth_type
    )[0];
    
    -- 6. Traduire les use_cases si disponibles
    LET $use_cases_translated = IF $credential_type.documentation.use_cases_i18n != NONE {
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $credential_type.documentation.use_cases_i18n)
    } ELSE {
        []
    };
    
    -- 7. Construire la réponse pour l'IA
    RETURN {
        success: true,
        credential_type: {
            id: $credential_type.id,
            name: $credential_type.name,
            slug: $credential_type.slug,
            identity: {
                display_name: $credential_type.display_name_translated,
                description: $credential_type.description_translated
            },
            presentation: $credential_type.presentation,
            auth_type: {
                id: $credential_type.auth_type,
                quality: $auth_type_quality
            },
            provider: $credential_type.provider,
            config: $credential_type.config,
            documentation: {
                url: $credential_type.documentation.url,
                use_cases: $use_cases_translated
            }
        }
    };
}
COMMENT 'Récupère la documentation complète d\'un credential_type pour contexte IA avec traductions i18n.'
PERMISSIONS FULL;

