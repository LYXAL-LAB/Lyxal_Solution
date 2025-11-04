-- =============================================================================================
-- |
-- | Fichier : fn_get_transmission_method_for_ai.surql
-- | Module : integrations > resource > credentials > transmission_method
-- | Description : Récupère la documentation complète d'une transmission_method pour contexte IA.
-- |
-- | Cette fonction retourne toutes les informations nécessaires pour que l'IA puisse
-- | comprendre, recommander et comparer les méthodes de transmission.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_transmission_method_for_ai(
    $transmission_method_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID en record transmission_method
    LET $transmission_method_record = type::thing('transmission_method', $transmission_method_id);
    
    -- 3. Récupérer la transmission_method avec toute sa documentation
    LET $transmission_method = (
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
        FROM $transmission_method_record
    )[0];
    
    -- 4. Vérifier si la transmission_method existe
    IF $transmission_method == NONE THEN
        RETURN { success: false, error: 'transmission_method_not_found', transmission_method_id: $transmission_method_id };
    END;
    
    -- 5. Traduire les security_concerns si disponibles
    LET $security_concerns_translated = IF $transmission_method.quality.security_concerns_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $transmission_method.quality.security_concerns_i18n)
    ELSE
        []
    END;
    
    -- 6. Traduire les best_use_cases si disponibles
    LET $best_use_cases_translated = IF $transmission_method.quality.best_use_cases_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $transmission_method.quality.best_use_cases_i18n)
    ELSE
        []
    END;
    
    -- 7. Traduire les avoid_use_cases si disponibles
    LET $avoid_use_cases_translated = IF $transmission_method.quality.avoid_use_cases_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $transmission_method.quality.avoid_use_cases_i18n)
    ELSE
        []
    END;
    
    -- 8. Construire la réponse pour l'IA
    RETURN {
        success: true,
        transmission_method: {
            id: $transmission_method.id,
            name: $transmission_method.name,
            slug: $transmission_method.slug,
            identity: {
                display_name: $transmission_method.display_name_translated,
                description: $transmission_method.description_translated
            },
            presentation: $transmission_method.presentation,
            quality: {
                security_level: $transmission_method.quality.security_level,
                security_concerns: $security_concerns_translated,
                best_use_cases: $best_use_cases_translated,
                avoid_use_cases: $avoid_use_cases_translated
            },
            config: $transmission_method.config
        }
    };
}
COMMENT 'Récupère la documentation complète d\'une transmission_method pour contexte IA avec traductions i18n.'
PERMISSIONS FULL;

