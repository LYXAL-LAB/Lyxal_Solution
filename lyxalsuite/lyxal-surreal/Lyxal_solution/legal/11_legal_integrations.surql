-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : INTÉGRATIONS & APIS JURIDIQUES
-- ==============================================================================
-- Fichier : 08_legal_integrations.surql
-- Description : Connecteurs, APIs, webhooks et synchronisation juridique
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : CONNECTEURS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_connector SCHEMAFULL;
DEFINE FIELD connector_id ON legal_connector TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_connector TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_connector TYPE string;
DEFINE FIELD connector_type ON legal_connector TYPE string 
    ASSERT $value IN ['api_rest', 'api_soap', 'webhook', 'ftp', 'sftp', 'database', 'file_system', 'email'];
DEFINE FIELD category ON legal_connector TYPE string 
    ASSERT $value IN ['document_management', 'signature_platform', 'court_system', 'registry', 'compliance', 'accounting', 'crm', 'custom'];
DEFINE FIELD provider ON legal_connector TYPE string;
DEFINE FIELD version ON legal_connector TYPE string;
DEFINE FIELD endpoint_url ON legal_connector TYPE option<string>;
DEFINE FIELD authentication_type ON legal_connector TYPE string 
    ASSERT $value IN ['none', 'basic', 'bearer', 'oauth2', 'api_key', 'certificate', 'custom'];
DEFINE FIELD authentication_config ON legal_connector TYPE object;
DEFINE FIELD connection_config ON legal_connector TYPE object;
DEFINE FIELD supported_operations ON legal_connector TYPE array<string>;
DEFINE FIELD data_format ON legal_connector TYPE string 
    ASSERT $value IN ['json', 'xml', 'csv', 'pdf', 'binary', 'custom'];
DEFINE FIELD rate_limit ON legal_connector TYPE option<object>;
DEFINE FIELD timeout_ms ON legal_connector TYPE int DEFAULT 30000;
DEFINE FIELD retry_policy ON legal_connector TYPE object;
DEFINE FIELD health_check_config ON legal_connector TYPE object;
DEFINE FIELD last_health_check ON legal_connector TYPE option<datetime>;
DEFINE FIELD health_status ON legal_connector TYPE string 
    ASSERT $value IN ['healthy', 'degraded', 'unhealthy', 'unknown'];
DEFINE FIELD is_active ON legal_connector TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_connector TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_connector TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_connector TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_connector TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_connector_id ON legal_connector COLUMNS connector_id UNIQUE;
DEFINE INDEX idx_legal_connector_type ON legal_connector COLUMNS connector_type;
DEFINE INDEX idx_legal_connector_category ON legal_connector COLUMNS category;
DEFINE INDEX idx_legal_connector_provider ON legal_connector COLUMNS provider;
DEFINE INDEX idx_legal_connector_health ON legal_connector COLUMNS health_status;
DEFINE INDEX idx_legal_connector_active ON legal_connector COLUMNS is_active;

-- ==============================================================================
-- TABLE : MAPPINGS DE DONNÉES
-- ==============================================================================

DEFINE TABLE legal_data_mapping SCHEMAFULL;
DEFINE FIELD mapping_id ON legal_data_mapping TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_data_mapping TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_data_mapping TYPE string;
DEFINE FIELD connector ON legal_data_mapping TYPE record<legal_connector>;
DEFINE FIELD mapping_type ON legal_data_mapping TYPE string 
    ASSERT $value IN ['inbound', 'outbound', 'bidirectional'];
DEFINE FIELD source_schema ON legal_data_mapping TYPE object;
DEFINE FIELD target_schema ON legal_data_mapping TYPE object;
DEFINE FIELD field_mappings ON legal_data_mapping TYPE array<object>;
DEFINE FIELD transformation_rules ON legal_data_mapping TYPE array<object>;
DEFINE FIELD validation_rules ON legal_data_mapping TYPE array<object>;
DEFINE FIELD default_values ON legal_data_mapping TYPE object;
DEFINE FIELD conditional_mappings ON legal_data_mapping TYPE array<object>;
DEFINE FIELD error_handling ON legal_data_mapping TYPE object;
DEFINE FIELD version ON legal_data_mapping TYPE string DEFAULT "1.0";
DEFINE FIELD is_active ON legal_data_mapping TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_data_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_data_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_data_mapping TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_data_mapping TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_data_mapping_id ON legal_data_mapping COLUMNS mapping_id UNIQUE;
DEFINE INDEX idx_legal_data_mapping_connector ON legal_data_mapping COLUMNS connector;
DEFINE INDEX idx_legal_data_mapping_type ON legal_data_mapping COLUMNS mapping_type;
DEFINE INDEX idx_legal_data_mapping_active ON legal_data_mapping COLUMNS is_active;

-- ==============================================================================
-- TABLE : INTÉGRATIONS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_integration SCHEMAFULL;
DEFINE FIELD integration_id ON legal_integration TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_integration TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_integration TYPE string;
DEFINE FIELD integration_type ON legal_integration TYPE string 
    ASSERT $value IN ['sync', 'async', 'real_time', 'batch', 'event_driven'];
DEFINE FIELD company ON legal_integration TYPE record<company>;
DEFINE FIELD connector ON legal_integration TYPE record<legal_connector>;
DEFINE FIELD data_mapping ON legal_integration TYPE record<legal_data_mapping>;
DEFINE FIELD sync_direction ON legal_integration TYPE string 
    ASSERT $value IN ['inbound', 'outbound', 'bidirectional'];
DEFINE FIELD schedule_config ON legal_integration TYPE option<object>;
DEFINE FIELD trigger_events ON legal_integration TYPE array<string>;
DEFINE FIELD filter_criteria ON legal_integration TYPE option<object>;
DEFINE FIELD batch_size ON legal_integration TYPE int DEFAULT 100;
DEFINE FIELD parallelism ON legal_integration TYPE int DEFAULT 1;
DEFINE FIELD error_threshold ON legal_integration TYPE int DEFAULT 5;
DEFINE FIELD notification_config ON legal_integration TYPE object;
DEFINE FIELD last_sync_time ON legal_integration TYPE option<datetime>;
DEFINE FIELD next_sync_time ON legal_integration TYPE option<datetime>;
DEFINE FIELD total_records_processed ON legal_integration TYPE int DEFAULT 0;
DEFINE FIELD total_errors ON legal_integration TYPE int DEFAULT 0;
DEFINE FIELD success_rate ON legal_integration TYPE decimal DEFAULT 100.0;
DEFINE FIELD average_processing_time ON legal_integration TYPE option<decimal>;
DEFINE FIELD status ON legal_integration TYPE string 
    ASSERT $value IN ['active', 'paused', 'disabled', 'error', 'maintenance'];
DEFINE FIELD is_active ON legal_integration TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_integration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_integration TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_integration TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_integration TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_integration_id ON legal_integration COLUMNS integration_id UNIQUE;
DEFINE INDEX idx_legal_integration_company ON legal_integration COLUMNS company;
DEFINE INDEX idx_legal_integration_connector ON legal_integration COLUMNS connector;
DEFINE INDEX idx_legal_integration_type ON legal_integration COLUMNS integration_type;
DEFINE INDEX idx_legal_integration_status ON legal_integration COLUMNS status;
DEFINE INDEX idx_legal_integration_next_sync ON legal_integration COLUMNS next_sync_time;
DEFINE INDEX idx_legal_integration_active ON legal_integration COLUMNS is_active;

-- ==============================================================================
-- TABLE : LOGS D'INTÉGRATION
-- ==============================================================================

DEFINE TABLE legal_integration_log SCHEMAFULL;
DEFINE FIELD log_id ON legal_integration_log TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD integration ON legal_integration_log TYPE record<legal_integration>;
DEFINE FIELD company ON legal_integration_log TYPE record<company>;
DEFINE FIELD execution_id ON legal_integration_log TYPE string;
DEFINE FIELD log_type ON legal_integration_log TYPE string 
    ASSERT $value IN ['info', 'warning', 'error', 'debug'];
DEFINE FIELD operation ON legal_integration_log TYPE string 
    ASSERT $value IN ['sync_start', 'sync_end', 'record_processed', 'error_occurred', 'validation_failed'];
DEFINE FIELD message ON legal_integration_log TYPE string;
DEFINE FIELD details ON legal_integration_log TYPE option<object>;
DEFINE FIELD record_id ON legal_integration_log TYPE option<string>;
DEFINE FIELD record_type ON legal_integration_log TYPE option<string>;
DEFINE FIELD processing_time_ms ON legal_integration_log TYPE option<int>;
DEFINE FIELD error_code ON legal_integration_log TYPE option<string>;
DEFINE FIELD error_message ON legal_integration_log TYPE option<string>;
DEFINE FIELD stack_trace ON legal_integration_log TYPE option<string>;
DEFINE FIELD request_data ON legal_integration_log TYPE option<object>;
DEFINE FIELD response_data ON legal_integration_log TYPE option<object>;
DEFINE FIELD timestamp ON legal_integration_log TYPE datetime DEFAULT time::now();
DEFINE FIELD created_on ON legal_integration_log TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_legal_integration_log_id ON legal_integration_log COLUMNS log_id UNIQUE;
DEFINE INDEX idx_legal_integration_log_integration ON legal_integration_log COLUMNS integration;
DEFINE INDEX idx_legal_integration_log_company ON legal_integration_log COLUMNS company;
DEFINE INDEX idx_legal_integration_log_execution ON legal_integration_log COLUMNS execution_id;
DEFINE INDEX idx_legal_integration_log_type ON legal_integration_log COLUMNS log_type;
DEFINE INDEX idx_legal_integration_log_timestamp ON legal_integration_log COLUMNS timestamp;

-- ==============================================================================
-- TABLE : WEBHOOKS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_webhook SCHEMAFULL;
DEFINE FIELD webhook_id ON legal_webhook TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_webhook TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_webhook TYPE string;
DEFINE FIELD webhook_type ON legal_webhook TYPE string 
    ASSERT $value IN ['inbound', 'outbound'];
DEFINE FIELD company ON legal_webhook TYPE record<company>;
DEFINE FIELD event_types ON legal_webhook TYPE array<string>;
DEFINE FIELD endpoint_url ON legal_webhook TYPE string;
DEFINE FIELD http_method ON legal_webhook TYPE string 
    ASSERT $value IN ['POST', 'PUT', 'PATCH'];
DEFINE FIELD headers ON legal_webhook TYPE object;
DEFINE FIELD authentication ON legal_webhook TYPE option<object>;
DEFINE FIELD payload_template ON legal_webhook TYPE option<string>;
DEFINE FIELD retry_policy ON legal_webhook TYPE object;
DEFINE FIELD timeout_ms ON legal_webhook TYPE int DEFAULT 30000;
DEFINE FIELD success_codes ON legal_webhook TYPE array<int>;
DEFINE FIELD filter_conditions ON legal_webhook TYPE option<object>;
DEFINE FIELD rate_limit ON legal_webhook TYPE option<object>;
DEFINE FIELD total_calls ON legal_webhook TYPE int DEFAULT 0;
DEFINE FIELD successful_calls ON legal_webhook TYPE int DEFAULT 0;
DEFINE FIELD failed_calls ON legal_webhook TYPE int DEFAULT 0;
DEFINE FIELD last_call_time ON legal_webhook TYPE option<datetime>;
DEFINE FIELD last_success_time ON legal_webhook TYPE option<datetime>;
DEFINE FIELD last_error_time ON legal_webhook TYPE option<datetime>;
DEFINE FIELD last_error_message ON legal_webhook TYPE option<string>;
DEFINE FIELD average_response_time ON legal_webhook TYPE option<decimal>;
DEFINE FIELD status ON legal_webhook TYPE string 
    ASSERT $value IN ['active', 'paused', 'disabled', 'error'];
DEFINE FIELD is_active ON legal_webhook TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_webhook TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_webhook TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_webhook TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_webhook TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_webhook_id ON legal_webhook COLUMNS webhook_id UNIQUE;
DEFINE INDEX idx_legal_webhook_company ON legal_webhook COLUMNS company;
DEFINE INDEX idx_legal_webhook_type ON legal_webhook COLUMNS webhook_type;
DEFINE INDEX idx_legal_webhook_status ON legal_webhook COLUMNS status;
DEFINE INDEX idx_legal_webhook_active ON legal_webhook COLUMNS is_active;

-- ==============================================================================
-- TABLE : EXECUTIONS DE WEBHOOKS
-- ==============================================================================

DEFINE TABLE legal_webhook_execution SCHEMAFULL;
DEFINE FIELD execution_id ON legal_webhook_execution TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD webhook ON legal_webhook_execution TYPE record<legal_webhook>;
DEFINE FIELD company ON legal_webhook_execution TYPE record<company>;
DEFINE FIELD event_type ON legal_webhook_execution TYPE string;
DEFINE FIELD trigger_data ON legal_webhook_execution TYPE object;
DEFINE FIELD payload_sent ON legal_webhook_execution TYPE object;
DEFINE FIELD http_status_code ON legal_webhook_execution TYPE option<int>;
DEFINE FIELD response_body ON legal_webhook_execution TYPE option<string>;
DEFINE FIELD response_headers ON legal_webhook_execution TYPE option<object>;
DEFINE FIELD processing_time_ms ON legal_webhook_execution TYPE option<int>;
DEFINE FIELD attempt_number ON legal_webhook_execution TYPE int DEFAULT 1;
DEFINE FIELD max_attempts ON legal_webhook_execution TYPE int DEFAULT 3;
DEFINE FIELD next_retry_time ON legal_webhook_execution TYPE option<datetime>;
DEFINE FIELD status ON legal_webhook_execution TYPE string 
    ASSERT $value IN ['pending', 'success', 'failed', 'retrying', 'cancelled'];
DEFINE FIELD error_message ON legal_webhook_execution TYPE option<string>;
DEFINE FIELD executed_at ON legal_webhook_execution TYPE datetime DEFAULT time::now();
DEFINE FIELD completed_at ON legal_webhook_execution TYPE option<datetime>;
DEFINE FIELD created_on ON legal_webhook_execution TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_legal_webhook_execution_id ON legal_webhook_execution COLUMNS execution_id UNIQUE;
DEFINE INDEX idx_legal_webhook_execution_webhook ON legal_webhook_execution COLUMNS webhook;
DEFINE INDEX idx_legal_webhook_execution_company ON legal_webhook_execution COLUMNS company;
DEFINE INDEX idx_legal_webhook_execution_status ON legal_webhook_execution COLUMNS status;
DEFINE INDEX idx_legal_webhook_execution_executed ON legal_webhook_execution COLUMNS executed_at;
DEFINE INDEX idx_legal_webhook_execution_retry ON legal_webhook_execution COLUMNS next_retry_time;

-- ==============================================================================
-- TABLE : TOKENS D'API
-- ==============================================================================

DEFINE TABLE legal_api_token SCHEMAFULL;
DEFINE FIELD token_id ON legal_api_token TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_api_token TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_api_token TYPE string;
DEFINE FIELD company ON legal_api_token TYPE record<company>;
DEFINE FIELD user_owner ON legal_api_token TYPE option<record<user>>;
DEFINE FIELD token_hash ON legal_api_token TYPE string;
DEFINE FIELD token_type ON legal_api_token TYPE string 
    ASSERT $value IN ['api_key', 'jwt', 'oauth2', 'custom'];
DEFINE FIELD scopes ON legal_api_token TYPE array<string>;
DEFINE FIELD permissions ON legal_api_token TYPE array<string>;
DEFINE FIELD rate_limit ON legal_api_token TYPE option<object>;
DEFINE FIELD ip_whitelist ON legal_api_token TYPE array<string>;
DEFINE FIELD expires_at ON legal_api_token TYPE option<datetime>;
DEFINE FIELD last_used_at ON legal_api_token TYPE option<datetime>;
DEFINE FIELD last_used_ip ON legal_api_token TYPE option<string>;
DEFINE FIELD usage_count ON legal_api_token TYPE int DEFAULT 0;
DEFINE FIELD is_active ON legal_api_token TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_api_token TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_api_token TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_api_token TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_api_token TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_api_token_id ON legal_api_token COLUMNS token_id UNIQUE;
DEFINE INDEX idx_legal_api_token_hash ON legal_api_token COLUMNS token_hash UNIQUE;
DEFINE INDEX idx_legal_api_token_company ON legal_api_token COLUMNS company;
DEFINE INDEX idx_legal_api_token_user ON legal_api_token COLUMNS user_owner;
DEFINE INDEX idx_legal_api_token_expires ON legal_api_token COLUMNS expires_at;
DEFINE INDEX idx_legal_api_token_active ON legal_api_token COLUMNS is_active;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour tester la connectivité d'un connecteur
DEFINE FUNCTION test_connector_health($connector_id: record<legal_connector>) {
    LET $connector = SELECT * FROM legal_connector WHERE id = $connector_id;
    
    -- Simulation d'un test de connectivité
    LET $health_result = {
        connector_id: $connector_id,
        test_time: time::now(),
        response_time_ms: math::round(rand::float() * 1000),
        status: "healthy",
        details: {
            endpoint_reachable: true,
            authentication_valid: true,
            api_version_compatible: true
        }
    };
    
    -- Mise à jour du statut de santé
    UPDATE legal_connector SET 
        last_health_check = time::now(),
        health_status = $health_result.status,
        updated_on = time::now()
    WHERE id = $connector_id;
    
    RETURN $health_result;
};

-- Fonction pour exécuter une synchronisation
DEFINE FUNCTION execute_integration_sync($integration_id: record<legal_integration>) {
    LET $integration = SELECT * FROM legal_integration WHERE id = $integration_id;
    LET $execution_id = "EXEC-" + string::slice(rand::uuid(), 0, 8);
    
    -- Log de début d'exécution
    CREATE legal_integration_log CONTENT {
        log_id: "LOG-" + string::slice(rand::uuid(), 0, 8),
        integration: $integration_id,
        company: $integration.company,
        execution_id: $execution_id,
        log_type: "info",
        operation: "sync_start",
        message: "Début de synchronisation pour: " + $integration.name,
        timestamp: time::now()
    };
    
    -- Simulation du traitement
    LET $records_processed = math::round(rand::float() * 100);
    LET $errors_count = math::round(rand::float() * 5);
    LET $processing_time = math::round(rand::float() * 10000);
    
    -- Mise à jour des statistiques
    UPDATE legal_integration SET 
        last_sync_time = time::now(),
        next_sync_time = time::now() + duration::from_hours(1),
        total_records_processed = total_records_processed + $records_processed,
        total_errors = total_errors + $errors_count,
        success_rate = ((total_records_processed - total_errors) / total_records_processed) * 100,
        average_processing_time = ($processing_time / 1000),
        updated_on = time::now()
    WHERE id = $integration_id;
    
    -- Log de fin d'exécution
    CREATE legal_integration_log CONTENT {
        log_id: "LOG-" + string::slice(rand::uuid(), 0, 8),
        integration: $integration_id,
        company: $integration.company,
        execution_id: $execution_id,
        log_type: "info",
        operation: "sync_end",
        message: "Synchronisation terminée. Enregistrements traités: " + string::from($records_processed),
        details: {
            records_processed: $records_processed,
            errors_count: $errors_count,
            processing_time_ms: $processing_time
        },
        processing_time_ms: $processing_time,
        timestamp: time::now()
    };
    
    RETURN {
        execution_id: $execution_id,
        records_processed: $records_processed,
        errors_count: $errors_count,
        processing_time_ms: $processing_time,
        success: true
    };
};

-- Fonction pour envoyer un webhook
DEFINE FUNCTION send_webhook($webhook_id: record<legal_webhook>, $event_type: string, $payload: object) {
    LET $webhook = SELECT * FROM legal_webhook WHERE id = $webhook_id;
    LET $execution_id = "WH-" + string::slice(rand::uuid(), 0, 8);
    
    -- Vérification des conditions de filtre
    IF $webhook.filter_conditions IS NOT NULL THEN
        -- Logique de filtrage simplifiée
        LET $should_send = true;
        IF NOT $should_send THEN
            RETURN { success: false, reason: "Filtered out by conditions" };
        END;
    END;
    
    -- Création de l'exécution
    LET $execution = CREATE legal_webhook_execution CONTENT {
        execution_id: $execution_id,
        webhook: $webhook_id,
        company: $webhook.company,
        event_type: $event_type,
        trigger_data: $payload,
        payload_sent: $payload,
        status: "pending",
        executed_at: time::now()
    };
    
    -- Simulation de l'envoi HTTP
    LET $http_status = 200;
    LET $response_time = math::round(rand::float() * 1000);
    
    -- Mise à jour de l'exécution
    UPDATE legal_webhook_execution SET 
        http_status_code = $http_status,
        processing_time_ms = $response_time,
        status = IF $http_status >= 200 AND $http_status < 300 THEN "success" ELSE "failed" END,
        completed_at = time::now()
    WHERE id = $execution.id;
    
    -- Mise à jour des statistiques du webhook
    UPDATE legal_webhook SET 
        total_calls = total_calls + 1,
        successful_calls = IF $http_status >= 200 AND $http_status < 300 THEN successful_calls + 1 ELSE successful_calls END,
        failed_calls = IF $http_status >= 200 AND $http_status < 300 THEN failed_calls ELSE failed_calls + 1 END,
        last_call_time = time::now(),
        last_success_time = IF $http_status >= 200 AND $http_status < 300 THEN time::now() ELSE last_success_time END,
        average_response_time = $response_time,
        updated_on = time::now()
    WHERE id = $webhook_id;
    
    RETURN {
        execution_id: $execution_id,
        status: IF $http_status >= 200 AND $http_status < 300 THEN "success" ELSE "failed" END,
        http_status: $http_status,
        response_time_ms: $response_time
    };
};

-- Fonction pour valider un token API
DEFINE FUNCTION validate_api_token($token_hash: string) {
    LET $token = SELECT * FROM legal_api_token 
        WHERE token_hash = $token_hash 
        AND is_active = true 
        AND (expires_at IS NULL OR expires_at > time::now());
    
    IF array::len($token) = 0 THEN
        RETURN { valid: false, reason: "Token not found or expired" };
    END;
    
    LET $token_record = $token[0];
    
    -- Mise à jour des statistiques d'utilisation
    UPDATE legal_api_token SET 
        usage_count = usage_count + 1,
        last_used_at = time::now(),
        updated_on = time::now()
    WHERE id = $token_record.id;
    
    RETURN {
        valid: true,
        token_id: $token_record.token_id,
        company: $token_record.company,
        scopes: $token_record.scopes,
        permissions: $token_record.permissions
    };
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des intégrations actives
DEFINE TABLE active_legal_integrations AS SELECT 
    legal_integration.*,
    legal_connector.name AS connector_name,
    legal_connector.provider AS connector_provider,
    legal_connector.health_status AS connector_health,
    company.name AS company_name,
    (legal_integration.next_sync_time - time::now()) AS next_sync_in
FROM legal_integration 
INNER JOIN legal_connector ON legal_integration.connector = legal_connector.id
INNER JOIN company ON legal_integration.company = company.id
WHERE legal_integration.status = 'active' 
AND legal_integration.is_active = true
ORDER BY legal_integration.next_sync_time ASC;

-- Vue des erreurs d'intégration récentes
DEFINE TABLE recent_integration_errors AS SELECT 
    legal_integration_log.*,
    legal_integration.name AS integration_name,
    company.name AS company_name
FROM legal_integration_log 
INNER JOIN legal_integration ON legal_integration_log.integration = legal_integration.id
INNER JOIN company ON legal_integration_log.company = company.id
WHERE legal_integration_log.log_type = 'error'
AND legal_integration_log.timestamp > (time::now() - duration::from_hours(24))
ORDER BY legal_integration_log.timestamp DESC;

-- Vue des webhooks avec statistiques
DEFINE TABLE legal_webhook_stats AS SELECT 
    legal_webhook.*,
    company.name AS company_name,
    (legal_webhook.successful_calls / legal_webhook.total_calls * 100) AS success_rate,
    (legal_webhook.total_calls - legal_webhook.successful_calls - legal_webhook.failed_calls) AS pending_calls
FROM legal_webhook 
INNER JOIN company ON legal_webhook.company = company.id
WHERE legal_webhook.is_active = true
ORDER BY legal_webhook.total_calls DESC;

-- Vue des connecteurs avec santé
DEFINE TABLE legal_connector_health AS SELECT 
    legal_connector.*,
    (time::now() - legal_connector.last_health_check) AS last_check_age,
    CASE 
        WHEN legal_connector.health_status = 'healthy' THEN 'green'
        WHEN legal_connector.health_status = 'degraded' THEN 'yellow'
        WHEN legal_connector.health_status = 'unhealthy' THEN 'red'
        ELSE 'gray'
    END AS health_color
FROM legal_connector 
WHERE legal_connector.is_active = true
ORDER BY legal_connector.health_status ASC, legal_connector.last_health_check DESC;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CONNECTEURS
-- ==============================================================================

-- Connecteur DocuSign
CREATE legal_connector:docusign CONTENT {
    connector_id: "DOCUSIGN_API",
    name: "DocuSign eSignature",
    description: "Connecteur pour l'API DocuSign de signature électronique",
    connector_type: "api_rest",
    category: "signature_platform",
    provider: "DocuSign",
    version: "v2.1",
    endpoint_url: "https://demo.docusign.net/restapi/v2.1",
    authentication_type: "oauth2",
    authentication_config: {
        client_id: "your_client_id",
        client_secret: "your_client_secret",
        scope: "signature",
        token_url: "https://account-d.docusign.com/oauth/token"
    },
    supported_operations: ["create_envelope", "send_envelope", "get_status", "download_documents"],
    data_format: "json",
    timeout_ms: 30000,
    retry_policy: {
        max_retries: 3,
        backoff_strategy: "exponential",
        initial_delay_ms: 1000
    },
    health_check_config: {
        endpoint: "/accounts",
        method: "GET",
        expected_status: 200,
        interval_minutes: 15
    },
    health_status: "unknown",
    is_active: true,
    created_on: time::now()
};

-- Connecteur Greffe du Tribunal de Commerce
CREATE legal_connector:infogreffe CONTENT {
    connector_id: "INFOGREFFE_API",
    name: "Infogreffe API",
    description: "Connecteur pour l'API Infogreffe du registre du commerce",
    connector_type: "api_rest",
    category: "registry",
    provider: "Infogreffe",
    version: "v1.0",
    endpoint_url: "https://api.infogreffe.fr/v1",
    authentication_type: "api_key",
    authentication_config: {
        api_key_header: "X-API-Key",
        api_key_value: "your_api_key"
    },
    supported_operations: ["search_company", "get_company_info", "get_acts", "get_accounts"],
    data_format: "json",
    timeout_ms: 15000,
    retry_policy: {
        max_retries: 2,
        backoff_strategy: "linear",
        initial_delay_ms: 2000
    },
    health_check_config: {
        endpoint: "/ping",
        method: "GET",
        expected_status: 200,
        interval_minutes: 30
    },
    health_status: "unknown",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : MAPPINGS
-- ==============================================================================

-- Mapping pour DocuSign
CREATE legal_data_mapping:docusign_contract CONTENT {
    mapping_id: "DOCUSIGN_CONTRACT_MAPPING",
    name: "Mapping Contrat vers DocuSign",
    description: "Mapping des données de contrat LYXAL vers format DocuSign",
    connector: legal_connector:docusign,
    mapping_type: "outbound",
    source_schema: {
        type: "lyxal_contract",
        fields: ["title", "parties", "content", "signers"]
    },
    target_schema: {
        type: "docusign_envelope",
        fields: ["emailSubject", "recipients", "documents", "status"]
    },
    field_mappings: [
        {
            source_field: "title",
            target_field: "emailSubject",
            transformation: "prefix",
            transformation_params: { prefix: "Signature requise: " }
        },
        {
            source_field: "signers",
            target_field: "recipients.signers",
            transformation: "array_transform",
            transformation_params: { 
                mapping: {
                    "name": "name",
                    "email": "email",
                    "order": "routingOrder"
                }
            }
        }
    ],
    validation_rules: [
        {
            field: "emailSubject",
            rule: "required",
            message: "Le sujet de l'email est obligatoire"
        },
        {
            field: "recipients.signers",
            rule: "min_length",
            params: { min: 1 },
            message: "Au moins un signataire est requis"
        }
    ],
    default_values: {
        status: "sent",
        autoNavigation: true
    },
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : INTÉGRATIONS
-- ==============================================================================

-- Intégration DocuSign
CREATE legal_integration:docusign_sync CONTENT {
    integration_id: "DOCUSIGN_CONTRACT_SYNC",
    name: "Synchronisation Contrats DocuSign",
    description: "Synchronisation bidirectionnelle des contrats avec DocuSign",
    integration_type: "event_driven",
    company: company:sample_company,
    connector: legal_connector:docusign,
    data_mapping: legal_data_mapping:docusign_contract,
    sync_direction: "bidirectional",
    trigger_events: ["contract_created", "contract_updated", "signature_required"],
    batch_size: 10,
    parallelism: 2,
    error_threshold: 3,
    notification_config: {
        notify_on_error: true,
        notify_on_success: false,
        recipients: ["legal_admin@company.com"]
    },
    status: "active",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : WEBHOOKS
-- ==============================================================================

-- Webhook DocuSign
CREATE legal_webhook:docusign_events CONTENT {
    webhook_id: "DOCUSIGN_WEBHOOK",
    name: "Webhook DocuSign Events",
    description: "Réception des événements DocuSign (signature, complétion, etc.)",
    webhook_type: "inbound",
    company: company:sample_company,
    event_types: ["envelope_completed", "envelope_signed", "envelope_declined"],
    endpoint_url: "https://api.lyxal.com/webhooks/docusign",
    http_method: "POST",
    headers: {
        "Content-Type": "application/json",
        "X-DocuSign-Signature": "signature_verification"
    },
    retry_policy: {
        max_retries: 3,
        backoff_strategy: "exponential",
        initial_delay_ms: 1000
    },
    timeout_ms: 30000,
    success_codes: [200, 201, 202],
    status: "active",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES INTÉGRATIONS JURIDIQUES :

1. CONNECTEURS (legal_connector)
   - Définition des connecteurs externes
   - Configuration d'authentification
   - Monitoring de santé

2. MAPPINGS (legal_data_mapping)
   - Transformation des données
   - Règles de validation
   - Mappings conditionnels

3. INTÉGRATIONS (legal_integration)
   - Orchestration des synchronisations
   - Planification et déclenchement
   - Statistiques de performance

4. LOGS (legal_integration_log)
   - Traçabilité complète
   - Debugging et monitoring
   - Audit trail

5. WEBHOOKS (legal_webhook)
   - Notifications en temps réel
   - Gestion des événements
   - Retry et résilience

6. TOKENS API (legal_api_token)
   - Sécurité des API
   - Gestion des permissions
   - Monitoring d'usage

UTILISATION :
- Intégration avec plateformes de signature
- Synchronisation avec registres officiels
- Connecteurs comptables et CRM
- Webhooks temps réel
- APIs sécurisées
- Monitoring et alertes
*/ 