-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : INFRASTRUCTURE STOCKAGE & SIGNATURES
-- ==============================================================================
-- Fichier : 04_document_storage_infrastructure.surql
-- Description : Infrastructure de stockage et gestion signatures électroniques
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : CONFIGURATION STOCKAGE
-- ==============================================================================

DEFINE TABLE storage_config SCHEMAFULL;
DEFINE FIELD name ON storage_config TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD storage_type ON storage_config TYPE string 
    ASSERT $value IN ['local', 's3', 'azure', 'gcp', 'sftp', 'webdav'];
DEFINE FIELD primary_location ON storage_config TYPE bool DEFAULT false;
DEFINE FIELD base_path ON storage_config TYPE string;
DEFINE FIELD connection_config ON storage_config TYPE object;
DEFINE FIELD encryption_config ON storage_config TYPE object;
DEFINE FIELD compression_enabled ON storage_config TYPE bool DEFAULT true;
DEFINE FIELD backup_enabled ON storage_config TYPE bool DEFAULT true;
DEFINE FIELD backup_frequency ON storage_config TYPE string 
    ASSERT $value IN ['hourly', 'daily', 'weekly', 'monthly'];
DEFINE FIELD max_file_size ON storage_config TYPE int DEFAULT 100000000; -- 100MB
DEFINE FIELD allowed_formats ON storage_config TYPE array<string>;
DEFINE FIELD retention_rules ON storage_config TYPE object;
DEFINE FIELD is_active ON storage_config TYPE bool DEFAULT true;
DEFINE FIELD created_on ON storage_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON storage_config TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_storage_config_type ON storage_config COLUMNS storage_type;
DEFINE INDEX idx_storage_config_primary ON storage_config COLUMNS primary_location;
DEFINE INDEX idx_storage_config_active ON storage_config COLUMNS is_active;

-- ==============================================================================
-- TABLE : STOCKAGE PHYSIQUE DES DOCUMENTS
-- ==============================================================================

DEFINE TABLE document_storage SCHEMAFULL;
DEFINE FIELD document ON document_storage TYPE record<legal_document>;
DEFINE FIELD storage_config ON document_storage TYPE record<storage_config>;
DEFINE FIELD file_path ON document_storage TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD original_filename ON document_storage TYPE string;
DEFINE FIELD mime_type ON document_storage TYPE string;
DEFINE FIELD file_size ON document_storage TYPE int;
DEFINE FIELD file_hash ON document_storage TYPE string; -- SHA-256
DEFINE FIELD encryption_key_id ON document_storage TYPE option<string>;
DEFINE FIELD compression_ratio ON document_storage TYPE option<decimal>;
DEFINE FIELD upload_date ON document_storage TYPE datetime DEFAULT time::now();
DEFINE FIELD last_accessed ON document_storage TYPE option<datetime>;
DEFINE FIELD access_count ON document_storage TYPE int DEFAULT 0;
DEFINE FIELD backup_locations ON document_storage TYPE array<string>;
DEFINE FIELD sync_status ON document_storage TYPE string 
    ASSERT $value IN ['synced', 'pending', 'failed', 'partial'];
DEFINE FIELD last_sync ON document_storage TYPE option<datetime>;
DEFINE FIELD metadata ON document_storage TYPE object;
DEFINE FIELD is_deleted ON document_storage TYPE bool DEFAULT false;
DEFINE FIELD deleted_date ON document_storage TYPE option<datetime>;
DEFINE FIELD created_on ON document_storage TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON document_storage TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_document_storage_document ON document_storage COLUMNS document;
DEFINE INDEX idx_document_storage_config ON document_storage COLUMNS storage_config;
DEFINE INDEX idx_document_storage_hash ON document_storage COLUMNS file_hash;
DEFINE INDEX idx_document_storage_sync ON document_storage COLUMNS sync_status;
DEFINE INDEX idx_document_storage_deleted ON document_storage COLUMNS is_deleted;

-- ==============================================================================
-- TABLE : FOURNISSEURS DE SIGNATURE ÉLECTRONIQUE
-- ==============================================================================

DEFINE TABLE signature_provider SCHEMAFULL;
DEFINE FIELD name ON signature_provider TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD provider_type ON signature_provider TYPE string 
    ASSERT $value IN ['docusign', 'adobe_sign', 'hellosign', 'pandadoc', 'signrequest', 'internal'];
DEFINE FIELD api_endpoint ON signature_provider TYPE string;
DEFINE FIELD authentication_config ON signature_provider TYPE object;
DEFINE FIELD supported_formats ON signature_provider TYPE array<string>;
DEFINE FIELD max_document_size ON signature_provider TYPE int;
DEFINE FIELD features ON signature_provider TYPE object;
DEFINE FIELD pricing_model ON signature_provider TYPE object;
DEFINE FIELD sla_guarantees ON signature_provider TYPE object;
DEFINE FIELD compliance_certifications ON signature_provider TYPE array<string>;
DEFINE FIELD is_primary ON signature_provider TYPE bool DEFAULT false;
DEFINE FIELD is_active ON signature_provider TYPE bool DEFAULT true;
DEFINE FIELD created_on ON signature_provider TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON signature_provider TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_signature_provider_type ON signature_provider COLUMNS provider_type;
DEFINE INDEX idx_signature_provider_primary ON signature_provider COLUMNS is_primary;
DEFINE INDEX idx_signature_provider_active ON signature_provider COLUMNS is_active;

-- ==============================================================================
-- TABLE : ENVELOPPES DE SIGNATURE
-- ==============================================================================

DEFINE TABLE signature_envelope SCHEMAFULL;
DEFINE FIELD document ON signature_envelope TYPE record<legal_document>;
DEFINE FIELD envelope_id ON signature_envelope TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD provider ON signature_envelope TYPE record<signature_provider>;
DEFINE FIELD external_envelope_id ON signature_envelope TYPE option<string>;
DEFINE FIELD envelope_status ON signature_envelope TYPE string 
    ASSERT $value IN ['created', 'sent', 'delivered', 'signed', 'completed', 'declined', 'voided', 'expired'];
DEFINE FIELD signers ON signature_envelope TYPE array<object>;
DEFINE FIELD signature_sequence ON signature_envelope TYPE string 
    ASSERT $value IN ['parallel', 'sequential'];
DEFINE FIELD notification_settings ON signature_envelope TYPE object;
DEFINE FIELD expiry_date ON signature_envelope TYPE option<datetime>;
DEFINE FIELD security_settings ON signature_envelope TYPE object;
DEFINE FIELD custom_fields ON signature_envelope TYPE object;
DEFINE FIELD webhook_events ON signature_envelope TYPE array<object>;
DEFINE FIELD created_date ON signature_envelope TYPE datetime DEFAULT time::now();
DEFINE FIELD sent_date ON signature_envelope TYPE option<datetime>;
DEFINE FIELD completed_date ON signature_envelope TYPE option<datetime>;
DEFINE FIELD certificate_path ON signature_envelope TYPE option<string>;
DEFINE FIELD audit_trail_path ON signature_envelope TYPE option<string>;
DEFINE FIELD created_on ON signature_envelope TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON signature_envelope TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_signature_envelope_document ON signature_envelope COLUMNS document;
DEFINE INDEX idx_signature_envelope_id ON signature_envelope COLUMNS envelope_id UNIQUE;
DEFINE INDEX idx_signature_envelope_status ON signature_envelope COLUMNS envelope_status;
DEFINE INDEX idx_signature_envelope_provider ON signature_envelope COLUMNS provider;
DEFINE INDEX idx_signature_envelope_expiry ON signature_envelope COLUMNS expiry_date;

-- ==============================================================================
-- TABLE : CERTIFICATS DE SIGNATURE
-- ==============================================================================

DEFINE TABLE signature_certificate SCHEMAFULL;
DEFINE FIELD certificate_id ON signature_certificate TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD certificate_type ON signature_certificate TYPE string 
    ASSERT $value IN ['x509', 'pki', 'qualified', 'self_signed'];
DEFINE FIELD issuer_name ON signature_certificate TYPE string;
DEFINE FIELD subject_name ON signature_certificate TYPE string;
DEFINE FIELD subject_email ON signature_certificate TYPE option<string>;
DEFINE FIELD serial_number ON signature_certificate TYPE string;
DEFINE FIELD fingerprint ON signature_certificate TYPE string;
DEFINE FIELD public_key ON signature_certificate TYPE string;
DEFINE FIELD algorithm ON signature_certificate TYPE string;
DEFINE FIELD key_length ON signature_certificate TYPE int;
DEFINE FIELD issued_date ON signature_certificate TYPE datetime;
DEFINE FIELD expiry_date ON signature_certificate TYPE datetime;
DEFINE FIELD revocation_status ON signature_certificate TYPE string 
    ASSERT $value IN ['valid', 'revoked', 'suspended', 'expired'];
DEFINE FIELD revocation_date ON signature_certificate TYPE option<datetime>;
DEFINE FIELD ocsp_url ON signature_certificate TYPE option<string>;
DEFINE FIELD crl_url ON signature_certificate TYPE option<string>;
DEFINE FIELD trust_level ON signature_certificate TYPE string 
    ASSERT $value IN ['low', 'medium', 'high', 'qualified'];
DEFINE FIELD usage_restrictions ON signature_certificate TYPE array<string>;
DEFINE FIELD extensions ON signature_certificate TYPE object;
DEFINE FIELD is_active ON signature_certificate TYPE bool DEFAULT true;
DEFINE FIELD created_on ON signature_certificate TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON signature_certificate TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_signature_certificate_id ON signature_certificate COLUMNS certificate_id UNIQUE;
DEFINE INDEX idx_signature_certificate_email ON signature_certificate COLUMNS subject_email;
DEFINE INDEX idx_signature_certificate_expiry ON signature_certificate COLUMNS expiry_date;
DEFINE INDEX idx_signature_certificate_status ON signature_certificate COLUMNS revocation_status;
DEFINE INDEX idx_signature_certificate_fingerprint ON signature_certificate COLUMNS fingerprint;

-- ==============================================================================
-- TABLE : LOGS DE SIGNATURE
-- ==============================================================================

DEFINE TABLE signature_log SCHEMAFULL;
DEFINE FIELD envelope ON signature_log TYPE record<signature_envelope>;
DEFINE FIELD event_type ON signature_log TYPE string 
    ASSERT $value IN ['created', 'sent', 'viewed', 'signed', 'declined', 'completed', 'voided', 'reminder_sent'];
DEFINE FIELD signer_email ON signature_log TYPE option<string>;
DEFINE FIELD event_timestamp ON signature_log TYPE datetime DEFAULT time::now();
DEFINE FIELD ip_address ON signature_log TYPE option<string>;
DEFINE FIELD user_agent ON signature_log TYPE option<string>;
DEFINE FIELD geolocation ON signature_log TYPE option<object>;
DEFINE FIELD device_fingerprint ON signature_log TYPE option<string>;
DEFINE FIELD authentication_method ON signature_log TYPE option<string>;
DEFINE FIELD biometric_data ON signature_log TYPE option<object>;
DEFINE FIELD event_details ON signature_log TYPE object;
DEFINE FIELD is_suspicious ON signature_log TYPE bool DEFAULT false;
DEFINE FIELD fraud_score ON signature_log TYPE option<decimal>;
DEFINE FIELD created_on ON signature_log TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_signature_log_envelope ON signature_log COLUMNS envelope;
DEFINE INDEX idx_signature_log_event ON signature_log COLUMNS event_type;
DEFINE INDEX idx_signature_log_signer ON signature_log COLUMNS signer_email;
DEFINE INDEX idx_signature_log_timestamp ON signature_log COLUMNS event_timestamp;
DEFINE INDEX idx_signature_log_suspicious ON signature_log COLUMNS is_suspicious;

-- ==============================================================================
-- FONCTIONS UTILITAIRES STOCKAGE
-- ==============================================================================

-- Fonction pour générer un chemin de stockage sécurisé
DEFINE FUNCTION generate_secure_file_path($document_id: record<legal_document>, $file_extension: string) {
    LET $year = time::year(time::now());
    LET $month = time::month(time::now());
    LET $uuid = rand::uuid::v4();
    LET $hash = crypto::sha256(string($document_id) + string(time::now()));
    
    RETURN "/documents/" + string($year) + "/" + string($month) + "/" + $hash[0:8] + "/" + $uuid + "." + $file_extension;
};

-- Fonction pour calculer l'empreinte d'un fichier
DEFINE FUNCTION calculate_file_hash($file_content: string) {
    RETURN crypto::sha256($file_content);
};

-- Fonction pour chiffrer un document
DEFINE FUNCTION encrypt_document($content: string, $encryption_key: string) {
    RETURN crypto::aes256::encrypt($content, $encryption_key);
};

-- Fonction pour déchiffrer un document
DEFINE FUNCTION decrypt_document($encrypted_content: string, $encryption_key: string) {
    RETURN crypto::aes256::decrypt($encrypted_content, $encryption_key);
};

-- Fonction pour sauvegarder un document
DEFINE FUNCTION save_document($document_id: record<legal_document>, $content: string, $filename: string, $mime_type: string) {
    LET $storage = SELECT * FROM storage_config WHERE primary_location = true AND is_active = true LIMIT 1;
    LET $file_path = generate_secure_file_path($document_id, string::split($filename, ".")[1]);
    LET $file_hash = calculate_file_hash($content);
    
    // Chiffrer le contenu si requis
    LET $encrypted_content = IF $storage.encryption_config.enabled = true THEN
        encrypt_document($content, $storage.encryption_config.key)
    ELSE
        $content
    END;
    
    // Créer l'enregistrement de stockage
    RETURN CREATE document_storage CONTENT {
        document: $document_id,
        storage_config: $storage.id,
        file_path: $file_path,
        original_filename: $filename,
        mime_type: $mime_type,
        file_size: string::len($encrypted_content),
        file_hash: $file_hash,
        encryption_key_id: IF $storage.encryption_config.enabled = true THEN $storage.encryption_config.key_id ELSE NONE END,
        sync_status: 'synced',
        created_on: time::now()
    };
};

-- ==============================================================================
-- FONCTIONS UTILITAIRES SIGNATURE
-- ==============================================================================

-- Fonction pour créer une enveloppe de signature
DEFINE FUNCTION create_signature_envelope($document_id: record<legal_document>, $signers: array<object>, $settings: object) {
    LET $provider = SELECT * FROM signature_provider WHERE is_primary = true AND is_active = true LIMIT 1;
    LET $envelope_id = "ENV-" + rand::uuid::v4();
    
    RETURN CREATE signature_envelope CONTENT {
        document: $document_id,
        envelope_id: $envelope_id,
        provider: $provider.id,
        envelope_status: 'created',
        signers: $signers,
        signature_sequence: $settings.sequence OR 'sequential',
        notification_settings: $settings.notifications OR {},
        expiry_date: time::now() + duration::from_days($settings.expiry_days OR 30),
        security_settings: $settings.security OR {},
        created_on: time::now()
    };
};

-- Fonction pour valider un certificat de signature
DEFINE FUNCTION validate_signature_certificate($certificate_id: string) {
    LET $cert = SELECT * FROM signature_certificate WHERE certificate_id = $certificate_id;
    
    // Vérifier l'expiration
    IF $cert.expiry_date < time::now() THEN
        RETURN {valid: false, reason: "Certificate expired"};
    END;
    
    // Vérifier le statut de révocation
    IF $cert.revocation_status != 'valid' THEN
        RETURN {valid: false, reason: "Certificate revoked or suspended"};
    END;
    
    // Vérifier l'émetteur (simulation)
    IF $cert.trust_level = 'low' THEN
        RETURN {valid: true, warning: "Low trust certificate"};
    END;
    
    RETURN {valid: true, trust_level: $cert.trust_level};
};

-- Fonction pour enregistrer un événement de signature
DEFINE FUNCTION log_signature_event($envelope_id: record<signature_envelope>, $event_type: string, $signer_email: string, $details: object) {
    RETURN CREATE signature_log CONTENT {
        envelope: $envelope_id,
        event_type: $event_type,
        signer_email: $signer_email,
        event_timestamp: time::now(),
        ip_address: $details.ip_address,
        user_agent: $details.user_agent,
        geolocation: $details.geolocation,
        device_fingerprint: $details.device_fingerprint,
        authentication_method: $details.auth_method,
        event_details: $details,
        created_on: time::now()
    };
};

-- Fonction pour détecter une signature suspecte
DEFINE FUNCTION detect_suspicious_signature($envelope_id: record<signature_envelope>, $signer_email: string, $signature_data: object) {
    LET $recent_logs = SELECT * FROM signature_log 
        WHERE envelope = $envelope_id 
        AND signer_email = $signer_email 
        AND event_timestamp > (time::now() - duration::from_hours(1))
        ORDER BY event_timestamp DESC;
    
    // Vérifier la vitesse de signature (trop rapide = suspect)
    LET $view_events = array::filter($recent_logs, |$log| $log.event_type = 'viewed');
    LET $sign_events = array::filter($recent_logs, |$log| $log.event_type = 'signed');
    
    IF array::len($view_events) > 0 AND array::len($sign_events) > 0 THEN
        LET $time_diff = time::unix($sign_events[0].event_timestamp) - time::unix($view_events[0].event_timestamp);
        IF $time_diff < 30 THEN // Moins de 30 secondes
            RETURN {suspicious: true, reason: "Signature too fast", fraud_score: 0.8};
        END;
    END;
    
    // Vérifier les changements d'IP/localisation
    IF array::len($recent_logs) > 1 THEN
        LET $ip_changes = array::len(array::unique(array::map($recent_logs, |$log| $log.ip_address)));
        IF $ip_changes > 2 THEN
            RETURN {suspicious: true, reason: "Multiple IP addresses", fraud_score: 0.6};
        END;
    END;
    
    RETURN {suspicious: false, fraud_score: 0.1};
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CONFIGURATION STOCKAGE
-- ==============================================================================

-- Stockage local principal
CREATE storage_config:local_primary CONTENT {
    name: "Stockage Local Principal",
    storage_type: "local",
    primary_location: true,
    base_path: "/var/lyxal/documents",
    connection_config: {
        permissions: "750",
        owner: "lyxal",
        group: "legal"
    },
    encryption_config: {
        enabled: true,
        algorithm: "AES-256-GCM",
        key_id: "lyxal-docs-key-001"
    },
    compression_enabled: true,
    backup_enabled: true,
    backup_frequency: "daily",
    max_file_size: 100000000,
    allowed_formats: ["pdf", "docx", "html", "xml", "json"],
    retention_rules: {
        hot_storage_days: 90,
        warm_storage_days: 365,
        cold_storage_years: 10
    },
    is_active: true,
    created_on: time::now()
};

-- Stockage cloud de sauvegarde
CREATE storage_config:cloud_backup CONTENT {
    name: "Sauvegarde Cloud AWS S3",
    storage_type: "s3",
    primary_location: false,
    base_path: "s3://lyxal-legal-docs-backup",
    connection_config: {
        region: "eu-west-3",
        access_key_id: "ENCRYPTED_ACCESS_KEY",
        secret_access_key: "ENCRYPTED_SECRET_KEY",
        encryption: "AES256"
    },
    encryption_config: {
        enabled: true,
        algorithm: "AES-256-GCM",
        key_id: "lyxal-docs-backup-key-001"
    },
    compression_enabled: true,
    backup_enabled: false,
    max_file_size: 1000000000, // 1GB
    allowed_formats: ["pdf", "docx", "html", "xml", "json", "zip"],
    retention_rules: {
        standard_days: 90,
        ia_days: 365,
        glacier_years: 10,
        deep_archive_years: 30
    },
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : FOURNISSEURS DE SIGNATURE
-- ==============================================================================

-- DocuSign
CREATE signature_provider:docusign CONTENT {
    name: "DocuSign",
    provider_type: "docusign",
    api_endpoint: "https://demo.docusign.net/restapi",
    authentication_config: {
        integration_key: "ENCRYPTED_INTEGRATION_KEY",
        secret_key: "ENCRYPTED_SECRET_KEY",
        oauth_redirect_uri: "https://lyxal.com/oauth/docusign"
    },
    supported_formats: ["pdf", "docx", "html"],
    max_document_size: 25000000, // 25MB
    features: {
        bulk_send: true,
        templates: true,
        advanced_authentication: true,
        in_person_signing: true,
        mobile_signing: true,
        api_access: true
    },
    pricing_model: {
        type: "per_envelope",
        cost_per_envelope: 1.50,
        monthly_minimum: 100
    },
    sla_guarantees: {
        uptime: 99.9,
        response_time_ms: 500
    },
    compliance_certifications: ["eIDAS", "ESIGN", "UETA", "21_CFR_Part_11", "FIPS_140_2"],
    is_primary: true,
    is_active: true,
    created_on: time::now()
};

-- Signature interne LYXAL
CREATE signature_provider:lyxal_internal CONTENT {
    name: "LYXAL Signature Interne",
    provider_type: "internal",
    api_endpoint: "https://api.lyxal.com/signature/v1",
    authentication_config: {
        api_key: "INTERNAL_API_KEY",
        certificate_store: "/etc/lyxal/certs"
    },
    supported_formats: ["pdf", "xml", "json"],
    max_document_size: 50000000, // 50MB
    features: {
        pki_certificates: true,
        timestamp_authority: true,
        long_term_validation: true,
        qualified_signatures: true
    },
    compliance_certifications: ["eIDAS", "RGS", "ANSSI"],
    is_primary: false,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CERTIFICATS EXEMPLE
-- ==============================================================================

-- Certificat test utilisateur
CREATE signature_certificate:cert_test_user CONTENT {
    certificate_id: "CERT-TEST-001",
    certificate_type: "x509",
    issuer_name: "CN=LYXAL CA, O=LYXAL Solutions, C=FR",
    subject_name: "CN=Jean DUPONT, emailAddress=jean.dupont@lyxal.com, O=LYXAL Solutions, C=FR",
    subject_email: "jean.dupont@lyxal.com",
    serial_number: "1234567890ABCDEF",
    fingerprint: "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99",
    algorithm: "RSA-SHA256",
    key_length: 2048,
    issued_date: "2024-01-01T00:00:00Z",
    expiry_date: "2026-01-01T00:00:00Z",
    revocation_status: "valid",
    trust_level: "high",
    usage_restrictions: ["document_signing", "email_signing"],
    extensions: {
        key_usage: ["digital_signature", "non_repudiation"],
        extended_key_usage: ["document_signing"],
        subject_alt_name: ["email:jean.dupont@lyxal.com"]
    },
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
INFRASTRUCTURE DE STOCKAGE ET SIGNATURE :

1. STOCKAGE DES DOCUMENTS
   - Stockage multi-niveau (local + cloud)
   - Chiffrement AES-256-GCM
   - Compression automatique
   - Sauvegardes quotidiennes
   - Intégrité via SHA-256

2. ARCHITECTURE DE FICHIERS
   /documents/
   ├── 2024/
   │   ├── 01/
   │   │   ├── [hash8]/
   │   │   │   └── [uuid].pdf
   │   │   └── [hash8]/
   │   └── 02/
   └── archive/

3. SIGNATURE ÉLECTRONIQUE
   - Intégration DocuSign (principal)
   - Système interne PKI (backup)
   - Certificats X.509 qualifiés
   - Audit trail complet
   - Détection de fraude

4. CONFORMITÉ LÉGALE
   - eIDAS (Europe)
   - ESIGN/UETA (USA)
   - RGS (France)
   - 21 CFR Part 11 (FDA)

5. SÉCURITÉ
   - Chiffrement de bout en bout
   - Authentification multi-facteur
   - Géolocalisation des signatures
   - Empreintes biométriques
   - Détection d'anomalies

UTILISATION :
- Stockage automatique sécurisé
- Signatures électroniques légales
- Traçabilité complète
- Conformité réglementaire
- Archivage à long terme
*/ 