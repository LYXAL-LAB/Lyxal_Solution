-- =============================================================================================
-- |
-- | Fichier : fn_update_user_service_credential.surql
-- | Module : integrations > resource > credentials > user_service_credential
-- | Description : Met à jour une credential existante.
-- |
-- | IMPORTANT: Le chiffrement est AUTOMATIQUE dans SurrealDB (comme n8n).
-- | Les credentials en clair sont automatiquement chiffrés avant stockage.
-- |
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::update_user_service_credential(
    $credential_id: string,
    $client_etag: option<uuid>,
    $identity_name: option<string>,
    $identity_description_i18n: option<string>,
    $credentials: option<object>,
    $is_active: option<bool>,
    $expires_at: option<datetime>,
    $metadata_last_used_at: option<datetime>,
    $metadata_usage_count: option<int>,
    $metadata_last_refreshed_at: option<datetime>
) {
    -- 1. Convertir l'ID en record
    LET $credential_record = type::thing('user_service_credential', $credential_id);
    
    -- 2. Vérifier l'ETag pour optimistic locking (si fourni)

    IF $current_etag != NONE AND $current_etag != $client_etag {
        RETURN {
            success: false,
            error: 'etag_mismatch',
            message: 'Credential has been modified by another user. Please refresh and try again.',
            current_etag: $current_etag
        };
    };
    
    IF $client_etag != NONE {
        LET $current_etag = (
            SELECT VALUE etag
            FROM $credential_record
        )[0];
    };
    
    -- 3. Vérifier si la credential existe
    LET $exists = (
        SELECT id
        FROM $credential_record
    )[0];
    
    IF $exists == NONE {
        RETURN {
            success: false,
            error: 'credential_not_found',
            credential_id: $credential_id
        };
    };
    
    -- 4. Chiffrer automatiquement les credentials si fournis (comme n8n)
    LET $encrypted_credentials = NONE;
    IF $credentials != NONE {
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
    };
    
    -- 6. Mettre à jour la credential
    LET $updated = (
        UPDATE $credential_record SET
            identity.name = IF $identity_name != NONE THEN $identity_name ELSE identity.name END,
            identity.description_i18n = IF $identity_description_i18n != NONE THEN 
                type::thing('i18n_key', $identity_description_i18n) 
            ELSE 
                identity.description_i18n 
            END,
            credentials = IF $encrypted_credentials != NONE THEN $encrypted_credentials ELSE credentials END,
            is_active = IF $is_active != NONE THEN $is_active ELSE is_active END,
            expires_at = IF $expires_at != NONE THEN $expires_at ELSE expires_at END,
            metadata.last_used_at = IF $metadata_last_used_at != NONE THEN $metadata_last_used_at ELSE metadata.last_used_at END,
            metadata.usage_count = IF $metadata_usage_count != NONE THEN $metadata_usage_count ELSE metadata.usage_count END,
            metadata.last_refreshed_at = IF $metadata_last_refreshed_at != NONE THEN $metadata_last_refreshed_at ELSE metadata.last_refreshed_at END
        RETURN AFTER
    )[0];
    
    IF $updated == NONE {
        RETURN {
            success: false,
            error: 'update_failed',
            message: 'Failed to update credential'
        };
    };
    
    -- 7. Retourner le résultat (sans données sensibles pour sécurité)
    RETURN {
        success: true,
        credential: {
            id: $updated.id,
            user_id: $updated.user_id,
            service_id: $updated.service_id,
            credential_type_id: $updated.credential_type_id,
            is_active: $updated.is_active,
            identity: $updated.identity,
            expires_at: $updated.expires_at,
            metadata: $updated.metadata,
            etag: $updated.etag
        }
    };
}
COMMENT 'Met à jour une credential existante avec optimistic locking via ETag. Le chiffrement est automatique dans SurrealDB (comme n8n).'
PERMISSIONS FULL;

