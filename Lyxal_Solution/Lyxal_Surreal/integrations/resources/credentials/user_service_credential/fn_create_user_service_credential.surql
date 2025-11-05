-- =============================================================================================
-- |
-- | Fichier : fn_create_user_service_credential.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Crée une nouvelle credential pour un utilisateur et un service.
-- |
-- | IMPORTANT: Le chiffrement est AUTOMATIQUE dans SurrealDB (comme n8n).
-- | Les credentials en clair sont automatiquement chiffrés avant stockage.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::create_user_service_credential(
    $user_id: string,
    $service_id: string,
    $credential_type_id: string,
    $identity_name: string,
    $identity_description_i18n: option<string>,
    $credentials: object,
    $is_active: option<bool>,
    $expires_at: option<datetime>
) {
    -- 1. Convertir les IDs en records
    LET $user_record = type::thing('user', $user_id);
    LET $service_record = type::thing('service', $service_id);
    LET $credential_type_record = type::thing('credential_type', $credential_type_id);
    
    -- 2. Chiffrer automatiquement les credentials (comme n8n)
    LET $encryption_result = fn::encrypt_credentials_object($credentials);
    
    IF $encryption_result.success != true {
        RETURN {
            success: false,
            error: 'encryption_failed',
            message: $encryption_result.error,
            details: $encryption_result
        };
    };
    
    LET $encrypted_credentials = $encryption_result.encrypted_credentials;
    
    -- 3. Créer la credential avec les credentials chiffrés
    LET $credential = (
        CREATE user_service_credential SET
            user_id = $user_record,
            service_id = $service_record,
            credential_type_id = $credential_type_record,
            is_active = $is_active OR true,
            identity = {
                name: $identity_name,
                description_i18n: IF $identity_description_i18n != NONE     { 
                    type::thing('i18n_key', $identity_description_i18n) 
                } ELSE {
                    NONE 
                }
            },
            credentials = $encrypted_credentials,
            expires_at = $expires_at,
            metadata = {
                created_at: time::now(),
                updated_at: time::now(),
                last_used_at: NONE,
                usage_count: 0,
                last_refreshed_at: NONE
            }
        RETURN AFTER
    )[0];
    
    -- 4. Vérifier si la création a réussi
    IF $credential == NONE {
        RETURN { 
            success: false, 
            error: 'creation_failed', 
            message: 'Failed to create credential' 
        };
    };
    
    -- 5. Retourner le résultat (sans données sensibles pour sécurité)
    RETURN {
        success: true,
        credential: {
            id: $credential.id,
            user_id: $credential.user_id,
            service_id: $credential.service_id,
            credential_type_id: $credential.credential_type_id,
            is_active: $credential.is_active,
            identity: $credential.identity,
            expires_at: $credential.expires_at,
            metadata: $credential.metadata,
            etag: $credential.etag
        }
    };
}
COMMENT 'Crée une nouvelle credential pour un utilisateur et un service. Le chiffrement est automatique dans SurrealDB (comme n8n).'
PERMISSIONS FULL;

