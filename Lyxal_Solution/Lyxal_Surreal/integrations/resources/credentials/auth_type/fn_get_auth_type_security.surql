-- =============================================================================================
-- |
-- | Fichier : fn_get_auth_type_security.surql
-- | Module : integrations > resource > credentials > auth_type
-- | Description : Récupère les métriques de sécurité d'un auth_type pour analyse IA.
-- |
-- | Cette fonction retourne les informations de sécurité complètes incluant :
-- | - Le niveau de sécurité de l'auth_type
-- | - Le niveau de sécurité de la transmission_method
-- | - Les préoccupations de sécurité associées
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_auth_type_security(
    $auth_type_id: string,
    $langue_id: string
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Convertir l'ID en record auth_type
    LET $auth_type_record = type::thing('auth_type', $auth_type_id);
    
    -- 3. Récupérer l'auth_type avec sécurité
    LET $auth_type = (
        SELECT 
            *,
            -- Traduction du nom affiché
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.display_name_i18n AND out = $langue_record
            )[0] AS display_name_translated
        FROM $auth_type_record
    )[0];
    
    -- 4. Vérifier si l'auth_type existe
    IF $auth_type == NONE THEN
        RETURN { success: false, error: 'auth_type_not_found', auth_type_id: $auth_type_id };
    END;
    
    -- 5. Récupérer les informations de transmission_method
    LET $transmission_method = (
        SELECT 
            *,
            -- Traduction du nom
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = identity.display_name_i18n AND out = $langue_record
            )[0] AS display_name_translated
        FROM $auth_type.http.transmission_method
    )[0];
    
    -- 6. Traduire les préoccupations de sécurité si disponibles
    LET $method_security_concerns_translated = IF $transmission_method.quality.security_concerns_i18n != NONE THEN
        (SELECT VALUE (
            SELECT VALUE text 
            FROM translation 
            WHERE in = VALUE AND out = $langue_record
        )[0] FROM $transmission_method.quality.security_concerns_i18n)
    ELSE
        []
    END;
    
    -- 7. Construire la réponse pour l'IA
    RETURN {
        success: true,
        auth_type: {
            id: $auth_type.id,
            name: $auth_type.name,
            display_name: $auth_type.display_name_translated,
            security: {
                auth_security_level: $auth_type.quality.security_level,
                method_security_level: $transmission_method.quality.security_level,
                method_name: $transmission_method.display_name_translated,
                method_security_concerns: $method_security_concerns_translated
            },
            recommendation: IF $auth_type.quality.security_level >= 4 AND $transmission_method.quality.security_level >= 4 THEN
                "highly_secure"
            ELSE IF $auth_type.quality.security_level >= 3 AND $transmission_method.quality.security_level >= 3 THEN
                "secure"
            ELSE
                "moderate_security"
            END
        }
    };
}
COMMENT 'Récupère les métriques de sécurité d\'un auth_type pour analyse et recommandations IA.'
PERMISSIONS FULL;

