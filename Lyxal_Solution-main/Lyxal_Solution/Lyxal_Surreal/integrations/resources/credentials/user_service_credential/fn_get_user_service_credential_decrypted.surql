-- =============================================================================================
-- |
-- | Fichier : fn_get_user_service_credential_decrypted.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Récupère une credential avec les données sensibles déchiffrées (comme n8n)
-- |
-- | IMPORTANT: Cette fonction déchiffre automatiquement les credentials pour utilisation.
-- | Utiliser uniquement lorsque les credentials déchiffrés sont nécessaires (ex: pour fn::execute_tool).
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::get_user_service_credential_decrypted(
    $credential_id: string
) {
    -- 1. Convertir l'ID en record
    LET $credential_record = type::thing('user_service_credential', $credential_id);
    
    -- 2. Récupérer la credential complète
    LET $credential = (
        SELECT * FROM $credential_record
    )[0];
    
    -- 3. Vérifier que la credential existe
    IF $credential == NONE {
        RETURN {
            success: false,
            error: 'credential_not_found',
            credential_id: $credential_id
        };
    };
    
    -- 4. Déchiffrer automatiquement les credentials (comme n8n)
    LET $decryption_result = fn::decrypt_credentials_object($credential.credentials);
    
    IF $decryption_result.success != true {
        RETURN {
            success: false,
            error: 'decryption_failed',
            message: $decryption_result.error,
            details: $decryption_result
        };
    };
    
    LET $decrypted_credentials = $decryption_result.decrypted_credentials;
    
    -- 5. Retourner la credential avec les credentials déchiffrés
    RETURN {
        success: true,
        credential: {
            id: $credential.id,
            user_id: $credential.user_id,
            service_id: $credential.service_id,
            credential_type_id: $credential.credential_type_id,
            is_active: $credential.is_active,
            identity: $credential.identity,
            credentials: $decrypted_credentials,
            expires_at: $credential.expires_at,
            metadata: $credential.metadata,
            etag: $credential.etag
        }
    };
}
COMMENT 'Récupère une credential avec les données sensibles déchiffrées pour utilisation. Le déchiffrement est automatique dans SurrealDB (comme n8n).'
PERMISSIONS FULL;

