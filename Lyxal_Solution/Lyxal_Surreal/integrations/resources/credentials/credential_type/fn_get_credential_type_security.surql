-- =============================================================================================
-- |
-- | Fichier : fn_get_credential_type_security.surql
-- | Module : integrations > resource > credentials > credential_type
-- | Description : Récupère les credential_type les plus sécurisés.
-- |
-- | Cette fonction retourne les credentials filtrés par niveau de sécurité minimum
-- | en se basant sur le security_level de l'auth_type associé.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_credential_type_security(
    $langue_id: string,
    $security_level_min: option<int>
) {
    -- 1. Convertir la langue en record
    LET $langue_record = type::thing('language', $langue_id);
    
    -- 2. Définir le niveau de sécurité minimum par défaut
    LET $min_level = $security_level_min OR 4;
    
    -- 3. Récupérer les credential_type sécurisés
    LET $credential_types = (
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
            -- Sécurité de l'auth_type
            auth_type.quality.security_level AS auth_security_level,
            -- Nom de l'auth_type traduit
            (
                SELECT VALUE text 
                FROM translation 
                WHERE in = auth_type.identity.display_name_i18n AND out = $langue_record
            )[0] AS auth_type_name_translated
        FROM credential_type
        WHERE is_active = true 
            AND auth_type.quality.security_level >= $min_level
        ORDER BY auth_type.quality.security_level DESC, presentation.display_order ASC
    );
    
    -- 4. Retourner la liste
    RETURN $credential_types;
}
COMMENT 'Récupère les credential_type les plus sécurisés avec traductions i18n, filtrés par niveau de sécurité minimum.'
PERMISSIONS FULL;

