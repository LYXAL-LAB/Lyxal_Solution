-- =============================================================================================
-- |
-- | Fichier : fn_encrypt_credential_value.surql
-- | Module : integrations > resource > credentials
-- | Description : Chiffre une valeur sensible pour les credentials
-- |
-- | Cette fonction utilise les fonctions crypto intégrées de SurrealDB pour chiffrer
-- | une valeur sensible. Similaire à n8n, tout le chiffrement est géré dans SurrealDB.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::encrypt_credential_value($plaintext: string) {
    -- 1. Récupérer la configuration de chiffrement active
    LET $config = (
        SELECT * FROM credential_encryption_config
        WHERE is_active = true
        ORDER BY key_version DESC
        LIMIT 1
    )[0];
    
    -- 2. Vérifier que la configuration existe
    IF $config == NONE THEN
        RETURN { 
            success: false, 
            error: 'encryption_config_not_found',
            message: 'No active encryption configuration found'
        };
    END;
    
    -- 3. Chiffrer la valeur avec crypto::aes256::encrypt
    -- Note: Si crypto::aes256::encrypt n'existe pas dans votre version de SurrealDB,
    -- vous devrez utiliser une extension ou une fonction personnalisée
    LET $encrypted = crypto::aes256::encrypt($plaintext, $config.encryption_key);
    
    -- 4. Retourner le résultat chiffré avec le préfixe de version
    RETURN {
        success: true,
        encrypted_value: $encrypted,
        key_version: $config.key_version,
        algorithm: $config.algorithm
    };
}
COMMENT 'Chiffre une valeur sensible pour les credentials. Utilise la configuration de chiffrement active.'
PERMISSIONS FULL;

-- =============================================================================================
-- |
-- | Fichier : fn_decrypt_credential_value.surql
-- | Module : integrations > resource > credentials
-- | Description : Déchiffre une valeur chiffrée pour les credentials
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::decrypt_credential_value($encrypted_data: string, $key_version: option<int>) {
    -- 1. Déterminer la version de la clé à utiliser
    LET $version = IF $key_version != NONE THEN $key_version ELSE (
        SELECT VALUE key_version FROM credential_encryption_config
        WHERE is_active = true
        ORDER BY key_version DESC
        LIMIT 1
    )[0];
    
    -- 2. Récupérer la configuration de chiffrement pour cette version
    LET $config = (
        SELECT * FROM credential_encryption_config
        WHERE key_version = $version
        LIMIT 1
    )[0];
    
    -- 3. Vérifier que la configuration existe
    IF $config == NONE THEN
        RETURN { 
            success: false, 
            error: 'encryption_config_not_found',
            message: 'No encryption configuration found for the specified version'
        };
    END;
    
    -- 4. Déchiffrer la valeur avec crypto::aes256::decrypt
    LET $decrypted = crypto::aes256::decrypt($encrypted_data, $config.encryption_key);
    
    -- 5. Retourner le résultat déchiffré
    RETURN {
        success: true,
        decrypted_value: $decrypted
    };
}
COMMENT 'Déchiffre une valeur chiffrée pour les credentials. Utilise la configuration de chiffrement spécifiée.'
PERMISSIONS FULL;

-- =============================================================================================
-- |
-- | Fichier : fn_encrypt_credentials_object.surql
-- | Module : integrations > resource > credentials
-- | Description : Chiffre un objet credentials complet (comme n8n)
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::encrypt_credentials_object($credentials: object) {
    -- 1. Récupérer la configuration de chiffrement active
    LET $config = (
        SELECT * FROM credential_encryption_config
        WHERE is_active = true
        ORDER BY key_version DESC
        LIMIT 1
    )[0];
    
    -- 2. Vérifier que la configuration existe
    IF $config == NONE THEN
        RETURN { 
            success: false, 
            error: 'encryption_config_not_found',
            message: 'No active encryption configuration found'
        };
    END;
    
    -- 3. Cloner l'objet credentials
    LET $encrypted = $credentials;
    
    -- 4. Chiffrer les champs sensibles OAuth2
    IF $credentials.oauth2 != NONE THEN
        IF $credentials.oauth2.access_token != NONE THEN
            LET $encrypted.oauth2.access_token = crypto::aes256::encrypt($credentials.oauth2.access_token, $config.encryption_key);
        END;
        IF $credentials.oauth2.refresh_token != NONE THEN
            LET $encrypted.oauth2.refresh_token = crypto::aes256::encrypt($credentials.oauth2.refresh_token, $config.encryption_key);
        END;
    END;
    
    -- 5. Chiffrer les champs sensibles API Key
    IF $credentials.api_key != NONE AND $credentials.api_key.key != NONE THEN
        LET $encrypted.api_key.key = crypto::aes256::encrypt($credentials.api_key.key, $config.encryption_key);
    END;
    
    -- 6. Chiffrer les champs sensibles Basic Auth
    IF $credentials.basic_auth != NONE THEN
        IF $credentials.basic_auth.username != NONE THEN
            LET $encrypted.basic_auth.username = crypto::aes256::encrypt($credentials.basic_auth.username, $config.encryption_key);
        END;
        IF $credentials.basic_auth.password != NONE THEN
            LET $encrypted.basic_auth.password = crypto::aes256::encrypt($credentials.basic_auth.password, $config.encryption_key);
        END;
    END;
    
    -- 7. Ajouter les métadonnées de chiffrement
    LET $encrypted._encryption = {
        key_version: $config.key_version,
        algorithm: $config.algorithm,
        encrypted_at: time::now()
    };
    
    -- 8. Retourner l'objet chiffré
    RETURN {
        success: true,
        encrypted_credentials: $encrypted
    };
}
COMMENT 'Chiffre un objet credentials complet. Chiffre automatiquement tous les champs sensibles.'
PERMISSIONS FULL;

-- =============================================================================================
-- |
-- | Fichier : fn_decrypt_credentials_object.surql
-- | Module : integrations > resource > credentials
-- | Description : Déchiffre un objet credentials complet (comme n8n)
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::decrypt_credentials_object($encrypted_credentials: object) {
    -- 1. Récupérer la version de la clé depuis les métadonnées
    LET $key_version = IF $encrypted_credentials._encryption != NONE THEN
        $encrypted_credentials._encryption.key_version
    ELSE
        NONE
    END;
    
    -- 2. Récupérer la configuration de chiffrement
    LET $config = IF $key_version != NONE THEN
        (SELECT * FROM credential_encryption_config WHERE key_version = $key_version LIMIT 1)[0]
    ELSE
        (SELECT * FROM credential_encryption_config WHERE is_active = true ORDER BY key_version DESC LIMIT 1)[0]
    END;
    
    -- 3. Vérifier que la configuration existe
    IF $config == NONE THEN
        RETURN { 
            success: false, 
            error: 'encryption_config_not_found',
            message: 'No encryption configuration found'
        };
    END;
    
    -- 4. Cloner l'objet credentials
    LET $decrypted = $encrypted_credentials;
    
    -- 5. Déchiffrer les champs sensibles OAuth2
    IF $encrypted_credentials.oauth2 != NONE THEN
        IF $encrypted_credentials.oauth2.access_token != NONE THEN
            LET $decrypted.oauth2.access_token = crypto::aes256::decrypt($encrypted_credentials.oauth2.access_token, $config.encryption_key);
        END;
        IF $encrypted_credentials.oauth2.refresh_token != NONE THEN
            LET $decrypted.oauth2.refresh_token = crypto::aes256::decrypt($encrypted_credentials.oauth2.refresh_token, $config.encryption_key);
        END;
    END;
    
    -- 6. Déchiffrer les champs sensibles API Key
    IF $encrypted_credentials.api_key != NONE AND $encrypted_credentials.api_key.key != NONE THEN
        LET $decrypted.api_key.key = crypto::aes256::decrypt($encrypted_credentials.api_key.key, $config.encryption_key);
    END;
    
    -- 7. Déchiffrer les champs sensibles Basic Auth
    IF $encrypted_credentials.basic_auth != NONE THEN
        IF $encrypted_credentials.basic_auth.username != NONE THEN
            LET $decrypted.basic_auth.username = crypto::aes256::decrypt($encrypted_credentials.basic_auth.username, $config.encryption_key);
        END;
        IF $encrypted_credentials.basic_auth.password != NONE THEN
            LET $decrypted.basic_auth.password = crypto::aes256::decrypt($encrypted_credentials.basic_auth.password, $config.encryption_key);
        END;
    END;
    
    -- 8. Supprimer les métadonnées de chiffrement
    LET $decrypted._encryption = NONE;
    
    -- 9. Retourner l'objet déchiffré
    RETURN {
        success: true,
        decrypted_credentials: $decrypted
    };
}
COMMENT 'Déchiffre un objet credentials complet. Déchiffre automatiquement tous les champs sensibles.'
PERMISSIONS FULL;

