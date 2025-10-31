-- ================================================================================
-- Table d'audit pour le module System References
-- ================================================================================
-- DESCRIPTION: Enregistre toutes les modifications sur les tables system_references
-- TABLES AUDITÉES: severity_level, alert_status, ticket_priority, etc.
-- USAGE: Traçabilité complète des actions dans system_references
-- ================================================================================

DEFINE TABLE system_references_audit SCHEMAFULL;

-- Action effectuée (référence vers audit_actions.code)
DEFINE FIELD action ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

-- Table concernée (référence vers audit_tables.table_name)
DEFINE FIELD table_name ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

-- ID de l'enregistrement modifié
DEFINE FIELD record_id ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

-- Informations utilisateur
DEFINE FIELD user_id ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

DEFINE FIELD user_role ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

DEFINE FIELD user_name ON system_references_audit TYPE option<string>;

-- Informations techniques
DEFINE FIELD function_name ON system_references_audit TYPE string 
    ASSERT string::len($value) > 0;

DEFINE FIELD operation_type ON system_references_audit TYPE string 
    ASSERT $value INSIDE ['SINGLE', 'BULK', 'BATCH', 'CLEANUP'] DEFAULT 'SINGLE';

-- Données modifiées
DEFINE FIELD old_values ON system_references_audit FLEXIBLE TYPE object;
DEFINE FIELD new_values ON system_references_audit FLEXIBLE TYPE object;
DEFINE FIELD changed_fields ON system_references_audit TYPE array<string>;

-- Contexte de la modification
DEFINE FIELD change_reason ON system_references_audit TYPE option<string>;
DEFINE FIELD business_context ON system_references_audit TYPE option<string>;

-- Informations session
DEFINE FIELD ip_address ON system_references_audit TYPE option<string>;
DEFINE FIELD session_id ON system_references_audit TYPE option<string>;
DEFINE FIELD user_agent ON system_references_audit TYPE option<string>;

-- Métadonnées de suivi
DEFINE FIELD timestamp ON system_references_audit TYPE datetime DEFAULT time::now();
DEFINE FIELD execution_time_ms ON system_references_audit TYPE option<int>;
DEFINE FIELD success ON system_references_audit TYPE bool DEFAULT true;
DEFINE FIELD error_message ON system_references_audit TYPE option<string>;

-- Informations de corrélation
DEFINE FIELD correlation_id ON system_references_audit TYPE option<string> 
    COMMENT "Pour lier plusieurs actions d'une même opération";

DEFINE FIELD parent_operation_id ON system_references_audit TYPE option<string> 
    COMMENT "Pour les opérations en cascade";

-- Index pour performance et recherche
DEFINE INDEX idx_system_references_audit_table ON system_references_audit COLUMNS table_name;
DEFINE INDEX idx_system_references_audit_record ON system_references_audit COLUMNS record_id;
DEFINE INDEX idx_system_references_audit_user ON system_references_audit COLUMNS user_id;
DEFINE INDEX idx_system_references_audit_timestamp ON system_references_audit COLUMNS timestamp;
DEFINE INDEX idx_system_references_audit_action ON system_references_audit COLUMNS action;
DEFINE INDEX idx_system_references_audit_function ON system_references_audit COLUMNS function_name;
DEFINE INDEX idx_system_references_audit_success ON system_references_audit COLUMNS success;
DEFINE INDEX idx_system_references_audit_correlation ON system_references_audit COLUMNS correlation_id;

-- Index composites pour requêtes complexes
DEFINE INDEX idx_system_references_audit_table_action ON system_references_audit COLUMNS table_name, action;
DEFINE INDEX idx_system_references_audit_user_table ON system_references_audit COLUMNS user_id, table_name;
DEFINE INDEX idx_system_references_audit_timestamp_table ON system_references_audit COLUMNS timestamp, table_name;

-- Permissions pour l'audit
PERMISSIONS 
    FOR select WHERE $auth.role CONTAINS 'admin' 
        OR $auth.permissions CONTAINS 'audit:read'
        OR $auth.id = user_id
    FOR create WHERE $auth.role CONTAINS 'system' 
        OR $auth.permissions CONTAINS 'audit:write'
    FOR update NONE -- Les logs d'audit ne doivent jamais être modifiés
    FOR delete WHERE $auth.role CONTAINS 'super_admin' 
        OR $auth.permissions CONTAINS 'audit:purge'; 