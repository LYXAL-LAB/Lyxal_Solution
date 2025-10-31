-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : DOCUMENTS LÉGAUX
-- ==============================================================================
-- Fichier : 04_legal_documents.surql
-- Description : Templates, génération, signatures et archivage des documents légaux
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : TYPES DE DOCUMENTS LÉGAUX
-- ==============================================================================

DEFINE TABLE legal_document_type SCHEMAFULL;
DEFINE FIELD code ON legal_document_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON legal_document_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_document_type TYPE string;
DEFINE FIELD category ON legal_document_type TYPE string 
    ASSERT $value IN ['corporate', 'contract', 'compliance', 'tax', 'hr', 'real_estate', 'intellectual_property', 'litigation'];
DEFINE FIELD subcategory ON legal_document_type TYPE string;
DEFINE FIELD country ON legal_document_type TYPE option<record<country>>;
DEFINE FIELD legal_framework ON legal_document_type TYPE array<string>;
DEFINE FIELD required_parties ON legal_document_type TYPE array<string>;
DEFINE FIELD mandatory_clauses ON legal_document_type TYPE array<string>;
DEFINE FIELD optional_clauses ON legal_document_type TYPE array<string>;
DEFINE FIELD retention_period ON legal_document_type TYPE int;
DEFINE FIELD requires_notarization ON legal_document_type TYPE bool DEFAULT false;
DEFINE FIELD requires_registration ON legal_document_type TYPE bool DEFAULT false;
DEFINE FIELD electronic_signature_allowed ON legal_document_type TYPE bool DEFAULT true;
DEFINE FIELD template_required ON legal_document_type TYPE bool DEFAULT false;
DEFINE FIELD is_active ON legal_document_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_document_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_document_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_document_type TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_document_type TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_document_type_code ON legal_document_type COLUMNS code UNIQUE;
DEFINE INDEX idx_legal_document_type_category ON legal_document_type COLUMNS category;
DEFINE INDEX idx_legal_document_type_country ON legal_document_type COLUMNS country;
DEFINE INDEX idx_legal_document_type_active ON legal_document_type COLUMNS is_active;

-- ==============================================================================
-- TABLE : TEMPLATES DE DOCUMENTS
-- ==============================================================================

DEFINE TABLE document_template SCHEMAFULL;
DEFINE FIELD name ON document_template TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON document_template TYPE string;
DEFINE FIELD document_type ON document_template TYPE record<legal_document_type>;
DEFINE FIELD version ON document_template TYPE string DEFAULT "1.0";
DEFINE FIELD language ON document_template TYPE string DEFAULT "fr";
DEFINE FIELD template_format ON document_template TYPE string 
    ASSERT $value IN ['html', 'docx', 'pdf', 'odt', 'rtf'];
DEFINE FIELD template_content ON document_template TYPE string;
DEFINE FIELD template_variables ON document_template TYPE array<object>;
DEFINE FIELD conditional_blocks ON document_template TYPE array<object>;
DEFINE FIELD styling_options ON document_template TYPE object;
DEFINE FIELD header_template ON document_template TYPE option<string>;
DEFINE FIELD footer_template ON document_template TYPE option<string>;
DEFINE FIELD watermark_options ON document_template TYPE object;
DEFINE FIELD approval_required ON document_template TYPE bool DEFAULT false;
DEFINE FIELD approval_workflow ON document_template TYPE array<string>;
DEFINE FIELD is_default ON document_template TYPE bool DEFAULT false;
DEFINE FIELD is_active ON document_template TYPE bool DEFAULT true;
DEFINE FIELD created_on ON document_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON document_template TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON document_template TYPE option<record<user>>;
DEFINE FIELD updated_by ON document_template TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_document_template_type ON document_template COLUMNS document_type;
DEFINE INDEX idx_document_template_language ON document_template COLUMNS language;
DEFINE INDEX idx_document_template_active ON document_template COLUMNS is_active;
DEFINE INDEX idx_document_template_default ON document_template COLUMNS is_default;

-- ==============================================================================
-- TABLE : DOCUMENTS LÉGAUX
-- ==============================================================================

DEFINE TABLE legal_document SCHEMAFULL;
DEFINE FIELD reference ON legal_document TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON legal_document TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_document TYPE string;
DEFINE FIELD document_type ON legal_document TYPE record<legal_document_type>;
DEFINE FIELD template_used ON legal_document TYPE option<record<document_template>>;
DEFINE FIELD company ON legal_document TYPE option<record<company>>;
DEFINE FIELD parties ON legal_document TYPE array<object>;
DEFINE FIELD content ON legal_document TYPE string;
DEFINE FIELD variables_data ON legal_document TYPE object;
DEFINE FIELD status ON legal_document TYPE string 
    ASSERT $value IN ['draft', 'pending_review', 'approved', 'signed', 'executed', 'cancelled', 'expired'];
DEFINE FIELD priority ON legal_document TYPE string 
    ASSERT $value IN ['low', 'medium', 'high', 'urgent'];
DEFINE FIELD creation_date ON legal_document TYPE datetime DEFAULT time::now();
DEFINE FIELD effective_date ON legal_document TYPE option<datetime>;
DEFINE FIELD expiry_date ON legal_document TYPE option<datetime>;
DEFINE FIELD review_date ON legal_document TYPE option<datetime>;
DEFINE FIELD file_path ON legal_document TYPE option<string>;
DEFINE FIELD file_format ON legal_document TYPE option<string>;
DEFINE FIELD file_size ON legal_document TYPE option<int>;
DEFINE FIELD checksum ON legal_document TYPE option<string>;
DEFINE FIELD encryption_status ON legal_document TYPE string 
    ASSERT $value IN ['none', 'encrypted', 'signed', 'timestamped'];
DEFINE FIELD access_level ON legal_document TYPE string 
    ASSERT $value IN ['public', 'internal', 'confidential', 'restricted'];
DEFINE FIELD retention_until ON legal_document TYPE option<datetime>;
DEFINE FIELD tags ON legal_document TYPE array<string>;
DEFINE FIELD metadata ON legal_document TYPE object;
DEFINE FIELD is_template ON legal_document TYPE bool DEFAULT false;
DEFINE FIELD is_archived ON legal_document TYPE bool DEFAULT false;
DEFINE FIELD created_on ON legal_document TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_document TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_document TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_document TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_document_reference ON legal_document COLUMNS reference UNIQUE;
DEFINE INDEX idx_legal_document_type ON legal_document COLUMNS document_type;
DEFINE INDEX idx_legal_document_company ON legal_document COLUMNS company;
DEFINE INDEX idx_legal_document_status ON legal_document COLUMNS status;
DEFINE INDEX idx_legal_document_dates ON legal_document COLUMNS creation_date, effective_date, expiry_date;
DEFINE INDEX idx_legal_document_archived ON legal_document COLUMNS is_archived;

-- ==============================================================================
-- TABLE : SIGNATURES ÉLECTRONIQUES
-- ==============================================================================

DEFINE TABLE document_signature SCHEMAFULL;
DEFINE FIELD document ON document_signature TYPE record<legal_document>;
DEFINE FIELD signer_name ON document_signature TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD signer_email ON document_signature TYPE string 
    ASSERT string::is_email($value);
DEFINE FIELD signer_role ON document_signature TYPE string;
DEFINE FIELD signer_company ON document_signature TYPE option<record<company>>;
DEFINE FIELD signature_type ON document_signature TYPE string 
    ASSERT $value IN ['simple', 'advanced', 'qualified', 'biometric'];
DEFINE FIELD signature_method ON document_signature TYPE string 
    ASSERT $value IN ['manual', 'digital_pen', 'biometric', 'certificate', 'sms', 'email'];
DEFINE FIELD signature_data ON document_signature TYPE string;
DEFINE FIELD certificate_info ON document_signature TYPE option<object>;
DEFINE FIELD signature_timestamp ON document_signature TYPE datetime;
DEFINE FIELD ip_address ON document_signature TYPE option<string>;
DEFINE FIELD device_info ON document_signature TYPE option<object>;
DEFINE FIELD location_info ON document_signature TYPE option<object>;
DEFINE FIELD verification_status ON document_signature TYPE string 
    ASSERT $value IN ['pending', 'verified', 'invalid', 'expired'];
DEFINE FIELD verification_date ON document_signature TYPE option<datetime>;
DEFINE FIELD rejection_reason ON document_signature TYPE option<string>;
DEFINE FIELD is_witness_required ON document_signature TYPE bool DEFAULT false;
DEFINE FIELD witness_signatures ON document_signature TYPE array<object>;
DEFINE FIELD audit_trail ON document_signature TYPE array<object>;
DEFINE FIELD created_on ON document_signature TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON document_signature TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON document_signature TYPE option<record<user>>;
DEFINE FIELD updated_by ON document_signature TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_document_signature_document ON document_signature COLUMNS document;
DEFINE INDEX idx_document_signature_signer ON document_signature COLUMNS signer_email;
DEFINE INDEX idx_document_signature_timestamp ON document_signature COLUMNS signature_timestamp;
DEFINE INDEX idx_document_signature_status ON document_signature COLUMNS verification_status;

-- ==============================================================================
-- TABLE : WORKFLOW DE VALIDATION
-- ==============================================================================

DEFINE TABLE document_workflow SCHEMAFULL;
DEFINE FIELD document ON document_workflow TYPE record<legal_document>;
DEFINE FIELD workflow_name ON document_workflow TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD current_step ON document_workflow TYPE int DEFAULT 1;
DEFINE FIELD total_steps ON document_workflow TYPE int;
DEFINE FIELD workflow_status ON document_workflow TYPE string 
    ASSERT $value IN ['pending', 'in_progress', 'completed', 'rejected', 'cancelled'];
DEFINE FIELD steps ON document_workflow TYPE array<object>;
DEFINE FIELD current_assignee ON document_workflow TYPE option<record<user>>;
DEFINE FIELD due_date ON document_workflow TYPE option<datetime>;
DEFINE FIELD priority ON document_workflow TYPE string 
    ASSERT $value IN ['low', 'medium', 'high', 'urgent'];
DEFINE FIELD comments ON document_workflow TYPE array<object>;
DEFINE FIELD escalation_rules ON document_workflow TYPE array<object>;
DEFINE FIELD automation_rules ON document_workflow TYPE array<object>;
DEFINE FIELD started_date ON document_workflow TYPE datetime DEFAULT time::now();
DEFINE FIELD completed_date ON document_workflow TYPE option<datetime>;
DEFINE FIELD created_on ON document_workflow TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON document_workflow TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON document_workflow TYPE option<record<user>>;
DEFINE FIELD updated_by ON document_workflow TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_document_workflow_document ON document_workflow COLUMNS document;
DEFINE INDEX idx_document_workflow_assignee ON document_workflow COLUMNS current_assignee;
DEFINE INDEX idx_document_workflow_status ON document_workflow COLUMNS workflow_status;
DEFINE INDEX idx_document_workflow_due_date ON document_workflow COLUMNS due_date;

-- ==============================================================================
-- TABLE : HISTORIQUE DES VERSIONS
-- ==============================================================================

DEFINE TABLE document_version SCHEMAFULL;
DEFINE FIELD document ON document_version TYPE record<legal_document>;
DEFINE FIELD version_number ON document_version TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD version_name ON document_version TYPE string;
DEFINE FIELD description ON document_version TYPE string;
DEFINE FIELD content ON document_version TYPE string;
DEFINE FIELD file_path ON document_version TYPE option<string>;
DEFINE FIELD file_size ON document_version TYPE option<int>;
DEFINE FIELD checksum ON document_version TYPE option<string>;
DEFINE FIELD changes_summary ON document_version TYPE string;
DEFINE FIELD change_type ON document_version TYPE string 
    ASSERT $value IN ['major', 'minor', 'patch', 'emergency'];
DEFINE FIELD is_current ON document_version TYPE bool DEFAULT false;
DEFINE FIELD created_date ON document_version TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON document_version TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_document_version_document ON document_version COLUMNS document;
DEFINE INDEX idx_document_version_current ON document_version COLUMNS is_current;
DEFINE INDEX idx_document_version_created ON document_version COLUMNS created_date;

-- ==============================================================================
-- TABLE : ARCHIVAGE ET CONFORMITÉ
-- ==============================================================================

DEFINE TABLE document_archive SCHEMAFULL;
DEFINE FIELD document ON document_archive TYPE record<legal_document>;
DEFINE FIELD archive_date ON document_archive TYPE datetime DEFAULT time::now();
DEFINE FIELD archive_reason ON document_archive TYPE string 
    ASSERT $value IN ['retention_period', 'legal_requirement', 'business_need', 'regulatory_compliance'];
DEFINE FIELD archive_location ON document_archive TYPE string;
DEFINE FIELD archive_format ON document_archive TYPE string;
DEFINE FIELD compression_type ON document_archive TYPE option<string>;
DEFINE FIELD encryption_method ON document_archive TYPE option<string>;
DEFINE FIELD access_restrictions ON document_archive TYPE object;
DEFINE FIELD retention_period ON document_archive TYPE int;
DEFINE FIELD destruction_date ON document_archive TYPE option<datetime>;
DEFINE FIELD legal_hold ON document_archive TYPE bool DEFAULT false;
DEFINE FIELD compliance_tags ON document_archive TYPE array<string>;
DEFINE FIELD audit_trail ON document_archive TYPE array<object>;
DEFINE FIELD retrieval_count ON document_archive TYPE int DEFAULT 0;
DEFINE FIELD last_accessed ON document_archive TYPE option<datetime>;
DEFINE FIELD created_on ON document_archive TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON document_archive TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON document_archive TYPE option<record<user>>;
DEFINE FIELD updated_by ON document_archive TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_document_archive_document ON document_archive COLUMNS document;
DEFINE INDEX idx_document_archive_date ON document_archive COLUMNS archive_date;
DEFINE INDEX idx_document_archive_destruction ON document_archive COLUMNS destruction_date;
DEFINE INDEX idx_document_archive_legal_hold ON document_archive COLUMNS legal_hold;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour générer un document à partir d'un template
DEFINE FUNCTION generate_document_from_template($template_id: record<document_template>, $variables: object, $company_id: option<record<company>>) {
    LET $template = SELECT * FROM document_template WHERE id = $template_id;
    LET $content = string::replace($template.template_content, $variables);
    
    RETURN CREATE legal_document CONTENT {
        title: $variables.title OR $template.name,
        document_type: $template.document_type,
        template_used: $template_id,
        company: $company_id,
        content: $content,
        variables_data: $variables,
        status: 'draft',
        priority: 'medium',
        creation_date: time::now(),
        reference: rand::uuid::v4(),
        created_by: $auth.id,
        created_on: time::now()
    };
};

-- Fonction pour valider une signature électronique
DEFINE FUNCTION validate_signature($signature_id: record<document_signature>) {
    LET $signature = SELECT * FROM document_signature WHERE id = $signature_id;
    
    // Validation basique
    IF $signature.signature_data IS NULL OR string::len($signature.signature_data) = 0 THEN
        RETURN {valid: false, reason: "Signature data missing"};
    END;
    
    // Validation du certificat si présent
    IF $signature.certificate_info IS NOT NULL THEN
        LET $cert_valid = time::now() < $signature.certificate_info.expiry_date;
        IF NOT $cert_valid THEN
            RETURN {valid: false, reason: "Certificate expired"};
        END;
    END;
    
    RETURN {valid: true, verification_date: time::now()};
};

-- Fonction pour démarrer un workflow de validation
DEFINE FUNCTION start_document_workflow($document_id: record<legal_document>, $workflow_name: string, $steps: array<object>) {
    RETURN CREATE document_workflow CONTENT {
        document: $document_id,
        workflow_name: $workflow_name,
        current_step: 1,
        total_steps: array::len($steps),
        workflow_status: 'pending',
        steps: $steps,
        current_assignee: $steps[0].assignee,
        due_date: time::now() + duration::from_days($steps[0].duration_days OR 7),
        priority: 'medium',
        started_date: time::now(),
        created_by: $auth.id,
        created_on: time::now()
    };
};

-- Fonction pour archiver un document
DEFINE FUNCTION archive_document($document_id: record<legal_document>, $reason: string) {
    // Mettre à jour le statut du document
    UPDATE $document_id SET is_archived = true, updated_on = time::now();
    
    // Créer l'entrée d'archive
    RETURN CREATE document_archive CONTENT {
        document: $document_id,
        archive_reason: $reason,
        archive_location: "secure_storage",
        archive_format: "pdf",
        encryption_method: "aes256",
        retention_period: 10,
        destruction_date: time::now() + duration::from_days(3650),
        compliance_tags: ["archived"],
        created_by: $auth.id,
        created_on: time::now()
    };
};

-- Fonction pour calculer la date d'expiration d'un document
DEFINE FUNCTION calculate_document_expiry($document_type_id: record<legal_document_type>, $effective_date: datetime) {
    LET $doc_type = SELECT * FROM legal_document_type WHERE id = $document_type_id;
    IF $doc_type.retention_period IS NOT NULL THEN
        RETURN $effective_date + duration::from_days($doc_type.retention_period * 365);
    END;
    RETURN NULL;
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des documents actifs
DEFINE TABLE active_legal_documents AS SELECT 
    legal_document.*,
    legal_document_type.name AS document_type_name,
    legal_document_type.category AS document_category,
    company.name AS company_name
FROM legal_document 
INNER JOIN legal_document_type ON legal_document.document_type = legal_document_type.id
LEFT JOIN company ON legal_document.company = company.id
WHERE legal_document.is_archived = false 
AND legal_document.status NOT IN ['cancelled', 'expired'];

-- Vue des documents en attente de signature
DEFINE TABLE pending_signatures AS SELECT 
    legal_document.*,
    document_signature.signer_name,
    document_signature.signer_email,
    document_signature.signature_timestamp
FROM legal_document 
INNER JOIN document_signature ON legal_document.id = document_signature.document
WHERE legal_document.status = 'pending_review' 
AND document_signature.verification_status = 'pending';

-- Vue des workflows actifs
DEFINE TABLE active_workflows AS SELECT 
    document_workflow.*,
    legal_document.title AS document_title,
    legal_document.reference AS document_reference,
    legal_document_type.name AS document_type_name
FROM document_workflow 
INNER JOIN legal_document ON document_workflow.document = legal_document.id
INNER JOIN legal_document_type ON legal_document.document_type = legal_document_type.id
WHERE document_workflow.workflow_status IN ['pending', 'in_progress'];

-- Vue des documents à archiver
DEFINE TABLE documents_to_archive AS SELECT 
    legal_document.*,
    legal_document_type.retention_period
FROM legal_document 
INNER JOIN legal_document_type ON legal_document.document_type = legal_document_type.id
WHERE legal_document.is_archived = false 
AND legal_document.creation_date < (time::now() - duration::from_days(legal_document_type.retention_period * 365));

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TYPES DE DOCUMENTS FRANÇAIS
-- ==============================================================================

-- Statuts de société
CREATE legal_document_type:fr_statuts CONTENT {
    code: "FR_STATUTS",
    name: "Statuts de société",
    description: "Statuts constitutifs d'une société",
    category: "corporate",
    subcategory: "incorporation",
    country: country:fr,
    legal_framework: ["Code de commerce", "Code civil"],
    required_parties: ["associés", "gérants"],
    mandatory_clauses: ["dénomination", "objet", "siège", "capital", "durée"],
    optional_clauses: ["clause d'agrément", "clause de préemption"],
    retention_period: 30,
    requires_notarization: false,
    requires_registration: true,
    electronic_signature_allowed: true,
    template_required: true,
    is_active: true,
    created_on: time::now()
};

-- Contrat de travail
CREATE legal_document_type:fr_contrat_travail CONTENT {
    code: "FR_CDI",
    name: "Contrat de travail CDI",
    description: "Contrat de travail à durée indéterminée",
    category: "hr",
    subcategory: "employment",
    country: country:fr,
    legal_framework: ["Code du travail"],
    required_parties: ["employeur", "salarié"],
    mandatory_clauses: ["poste", "rémunération", "durée", "lieu"],
    optional_clauses: ["clause de non-concurrence", "clause de mobilité"],
    retention_period: 5,
    requires_notarization: false,
    requires_registration: false,
    electronic_signature_allowed: true,
    template_required: true,
    is_active: true,
    created_on: time::now()
};

-- Contrat commercial
CREATE legal_document_type:fr_contrat_commercial CONTENT {
    code: "FR_COMMERCIAL",
    name: "Contrat commercial",
    description: "Contrat de vente ou de prestation de services",
    category: "contract",
    subcategory: "commercial",
    country: country:fr,
    legal_framework: ["Code de commerce", "Code civil"],
    required_parties: ["vendeur", "acheteur"],
    mandatory_clauses: ["objet", "prix", "délais", "garanties"],
    optional_clauses: ["clause de révision", "clause pénale"],
    retention_period: 10,
    requires_notarization: false,
    requires_registration: false,
    electronic_signature_allowed: true,
    template_required: true,
    is_active: true,
    created_on: time::now()
};

-- Accord de confidentialité
CREATE legal_document_type:fr_nda CONTENT {
    code: "FR_NDA",
    name: "Accord de confidentialité",
    description: "Accord de non-divulgation d'informations confidentielles",
    category: "contract",
    subcategory: "confidentiality",
    country: country:fr,
    legal_framework: ["Code civil", "Code de commerce"],
    required_parties: ["divulgateur", "destinataire"],
    mandatory_clauses: ["définition des informations", "durée", "sanctions"],
    optional_clauses: ["exceptions", "juridiction"],
    retention_period: 5,
    requires_notarization: false,
    requires_registration: false,
    electronic_signature_allowed: true,
    template_required: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TEMPLATES DE DOCUMENTS
-- ==============================================================================

-- Template Statuts SARL
CREATE document_template:fr_statuts_sarl CONTENT {
    name: "Statuts SARL Standard",
    description: "Template standard pour les statuts de SARL",
    document_type: legal_document_type:fr_statuts,
    version: "1.0",
    language: "fr",
    template_format: "html",
    template_content: `
    <h1>STATUTS DE LA SOCIÉTÉ {{company_name}}</h1>
    
    <h2>ARTICLE 1 - FORME ET DÉNOMINATION</h2>
    <p>Il est formé entre les souscripteurs et tous ceux qui deviendront associés par la suite, 
    une société à responsabilité limitée régie par les lois et règlements en vigueur, 
    ainsi que par les présents statuts.</p>
    <p>La dénomination sociale est : <strong>{{company_name}}</strong></p>
    
    <h2>ARTICLE 2 - OBJET SOCIAL</h2>
    <p>La société a pour objet : {{business_object}}</p>
    
    <h2>ARTICLE 3 - SIÈGE SOCIAL</h2>
    <p>Le siège social est fixé au : {{registered_address}}</p>
    
    <h2>ARTICLE 4 - CAPITAL SOCIAL</h2>
    <p>Le capital social est fixé à {{capital_amount}} euros, 
    divisé en {{shares_count}} parts sociales de {{share_value}} euros chacune.</p>
    
    <h2>ARTICLE 5 - DURÉE</h2>
    <p>La durée de la société est fixée à {{duration}} années.</p>
    `,
    template_variables: [
        {name: "company_name", type: "string", required: true},
        {name: "business_object", type: "string", required: true},
        {name: "registered_address", type: "string", required: true},
        {name: "capital_amount", type: "number", required: true},
        {name: "shares_count", type: "number", required: true},
        {name: "share_value", type: "number", required: true},
        {name: "duration", type: "number", required: true}
    ],
    is_default: true,
    is_active: true,
    created_on: time::now()
};

-- Template Contrat de travail CDI
CREATE document_template:fr_cdi_template CONTENT {
    name: "Contrat CDI Standard",
    description: "Template standard pour contrat de travail CDI",
    document_type: legal_document_type:fr_contrat_travail,
    version: "1.0",
    language: "fr",
    template_format: "html",
    template_content: `
    <h1>CONTRAT DE TRAVAIL À DURÉE INDÉTERMINÉE</h1>
    
    <p>Entre les soussignés :</p>
    
    <p><strong>L'EMPLOYEUR :</strong><br>
    {{employer_name}}<br>
    {{employer_address}}<br>
    SIRET : {{employer_siret}}</p>
    
    <p><strong>LE SALARIÉ :</strong><br>
    {{employee_name}}<br>
    {{employee_address}}<br>
    Né(e) le {{employee_birth_date}} à {{employee_birth_place}}</p>
    
    <h2>ARTICLE 1 - ENGAGEMENT</h2>
    <p>L'employeur engage le salarié en qualité de {{job_title}} 
    à compter du {{start_date}}.</p>
    
    <h2>ARTICLE 2 - RÉMUNÉRATION</h2>
    <p>La rémunération mensuelle brute est fixée à {{monthly_salary}} euros.</p>
    
    <h2>ARTICLE 3 - DURÉE DU TRAVAIL</h2>
    <p>La durée hebdomadaire de travail est fixée à {{weekly_hours}} heures.</p>
    
    <h2>ARTICLE 4 - LIEU DE TRAVAIL</h2>
    <p>Le lieu de travail est fixé à {{work_location}}.</p>
    `,
    template_variables: [
        {name: "employer_name", type: "string", required: true},
        {name: "employer_address", type: "string", required: true},
        {name: "employer_siret", type: "string", required: true},
        {name: "employee_name", type: "string", required: true},
        {name: "employee_address", type: "string", required: true},
        {name: "employee_birth_date", type: "date", required: true},
        {name: "employee_birth_place", type: "string", required: true},
        {name: "job_title", type: "string", required: true},
        {name: "start_date", type: "date", required: true},
        {name: "monthly_salary", type: "number", required: true},
        {name: "weekly_hours", type: "number", required: true},
        {name: "work_location", type: "string", required: true}
    ],
    is_default: true,
    is_active: true,
    created_on: time::now()
};

-- Template NDA
CREATE document_template:fr_nda_template CONTENT {
    name: "Accord de Confidentialité Standard",
    description: "Template standard pour accord de confidentialité",
    document_type: legal_document_type:fr_nda,
    version: "1.0",
    language: "fr",
    template_format: "html",
    template_content: `
    <h1>ACCORD DE CONFIDENTIALITÉ</h1>
    
    <p>Entre les soussignés :</p>
    
    <p><strong>LA PARTIE DIVULGATRICE :</strong><br>
    {{discloser_name}}<br>
    {{discloser_address}}</p>
    
    <p><strong>LA PARTIE RÉCEPTRICE :</strong><br>
    {{recipient_name}}<br>
    {{recipient_address}}</p>
    
    <h2>ARTICLE 1 - OBJET</h2>
    <p>Le présent accord a pour objet de définir les conditions dans lesquelles 
    des informations confidentielles seront échangées dans le cadre de {{project_purpose}}.</p>
    
    <h2>ARTICLE 2 - DÉFINITION DES INFORMATIONS CONFIDENTIELLES</h2>
    <p>Sont considérées comme confidentielles toutes les informations, 
    données, documents, savoir-faire, techniques, commerciales, financières, 
    juridiques ou autres, communiquées par la partie divulgatrice.</p>
    
    <h2>ARTICLE 3 - ENGAGEMENTS</h2>
    <p>La partie réceptrice s'engage à :</p>
    <ul>
        <li>Garder strictement confidentielles les informations</li>
        <li>Ne pas les utiliser à d'autres fins que celles définies</li>
        <li>Ne pas les divulguer à des tiers</li>
    </ul>
    
    <h2>ARTICLE 4 - DURÉE</h2>
    <p>Le présent accord prend effet à compter de sa signature et demeure 
    en vigueur pendant {{duration}} années.</p>
    `,
    template_variables: [
        {name: "discloser_name", type: "string", required: true},
        {name: "discloser_address", type: "string", required: true},
        {name: "recipient_name", type: "string", required: true},
        {name: "recipient_address", type: "string", required: true},
        {name: "project_purpose", type: "string", required: true},
        {name: "duration", type: "number", required: true}
    ],
    is_default: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : EXEMPLES DE DOCUMENTS
-- ==============================================================================

-- Document exemple : Statuts SARL
CREATE legal_document:exemple_statuts_sarl CONTENT {
    reference: "STAT-2024-001",
    title: "Statuts LYXAL SOLUTIONS SARL",
    description: "Statuts constitutifs de LYXAL SOLUTIONS",
    document_type: legal_document_type:fr_statuts,
    template_used: document_template:fr_statuts_sarl,
    company: company:lyxal_solutions,
    parties: [
        {name: "Jean DUPONT", role: "gérant", shares: 60},
        {name: "Marie MARTIN", role: "associée", shares: 40}
    ],
    variables_data: {
        company_name: "LYXAL SOLUTIONS",
        business_object: "Conseil en systèmes et logiciels informatiques",
        registered_address: "123 rue de la Technologie, 75001 Paris",
        capital_amount: 10000,
        shares_count: 100,
        share_value: 100,
        duration: 99
    },
    status: "draft",
    priority: "high",
    effective_date: "2024-01-01T00:00:00Z",
    access_level: "confidential",
    tags: ["statuts", "sarl", "création"],
    created_on: time::now()
};

-- Workflow exemple pour validation des statuts
CREATE document_workflow:workflow_statuts CONTENT {
    document: legal_document:exemple_statuts_sarl,
    workflow_name: "Validation Statuts SARL",
    current_step: 1,
    total_steps: 3,
    workflow_status: "pending",
    steps: [
        {step: 1, name: "Rédaction", assignee: "juriste", duration_days: 5},
        {step: 2, name: "Validation client", assignee: "client", duration_days: 3},
        {step: 3, name: "Signature", assignee: "notaire", duration_days: 2}
    ],
    priority: "high",
    started_date: time::now(),
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES DOCUMENTS LÉGAUX :

1. TYPES DE DOCUMENTS (legal_document_type)
   - Classification des documents
   - Exigences légales et réglementaires
   - Conditions de validité

2. TEMPLATES (document_template)
   - Modèles réutilisables
   - Variables et blocs conditionnels
   - Versions et langues

3. DOCUMENTS (legal_document)
   - Instances des documents
   - Métadonnées et statuts
   - Gestion des versions

4. SIGNATURES (document_signature)
   - Signatures électroniques
   - Validation et vérification
   - Pistes d'audit

5. WORKFLOWS (document_workflow)
   - Processus de validation
   - Assignation et échéances
   - Automatisation

6. ARCHIVAGE (document_archive)
   - Conservation légale
   - Conformité réglementaire
   - Destruction sécurisée

UTILISATION :
- Génération automatique de documents
- Gestion des signatures électroniques
- Workflows de validation
- Archivage conforme
- Recherche et retrieval
*/ 