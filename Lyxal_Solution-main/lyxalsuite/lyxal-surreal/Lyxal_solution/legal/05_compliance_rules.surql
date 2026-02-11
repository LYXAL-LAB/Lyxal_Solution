-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : RÈGLES DE CONFORMITÉ
-- ==============================================================================
-- Fichier : 05_compliance_rules.surql
-- Description : Réglementations, contrôles, audits et évaluations de conformité
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : RÉGLEMENTATIONS
-- ==============================================================================

DEFINE TABLE regulation SCHEMAFULL;
DEFINE FIELD code ON regulation TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON regulation TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON regulation TYPE string;
DEFINE FIELD regulation_type ON regulation TYPE string 
    ASSERT $value IN ['privacy', 'financial', 'security', 'environmental', 'healthcare', 'industry_specific', 'general'];
DEFINE FIELD scope ON regulation TYPE string 
    ASSERT $value IN ['international', 'european', 'national', 'regional', 'sectoral'];
DEFINE FIELD country ON regulation TYPE option<record<country>>;
DEFINE FIELD region ON regulation TYPE option<string>;
DEFINE FIELD applicable_sectors ON regulation TYPE array<string>;
DEFINE FIELD company_size_criteria ON regulation TYPE object;
DEFINE FIELD revenue_threshold ON regulation TYPE option<decimal>;
DEFINE FIELD employee_threshold ON regulation TYPE option<int>;
DEFINE FIELD effective_date ON regulation TYPE datetime;
DEFINE FIELD last_update ON regulation TYPE option<datetime>;
DEFINE FIELD enforcement_authority ON regulation TYPE string;
DEFINE FIELD penalty_structure ON regulation TYPE object;
DEFINE FIELD certification_available ON regulation TYPE bool DEFAULT false;
DEFINE FIELD mandatory_reporting ON regulation TYPE bool DEFAULT false;
DEFINE FIELD reporting_frequency ON regulation TYPE option<string>;
DEFINE FIELD grace_period_days ON regulation TYPE option<int>;
DEFINE FIELD is_active ON regulation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON regulation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON regulation TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON regulation TYPE option<record<user>>;
DEFINE FIELD updated_by ON regulation TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_regulation_code ON regulation COLUMNS code UNIQUE;
DEFINE INDEX idx_regulation_type ON regulation COLUMNS regulation_type;
DEFINE INDEX idx_regulation_scope ON regulation COLUMNS scope;
DEFINE INDEX idx_regulation_country ON regulation COLUMNS country;
DEFINE INDEX idx_regulation_active ON regulation COLUMNS is_active;

-- ==============================================================================
-- TABLE : EXIGENCES DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_requirement SCHEMAFULL;
DEFINE FIELD regulation ON compliance_requirement TYPE record<regulation>;
DEFINE FIELD requirement_id ON compliance_requirement TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON compliance_requirement TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_requirement TYPE string;
DEFINE FIELD category ON compliance_requirement TYPE string 
    ASSERT $value IN ['governance', 'data_protection', 'security', 'reporting', 'documentation', 'training', 'monitoring', 'incident_response'];
DEFINE FIELD priority ON compliance_requirement TYPE string 
    ASSERT $value IN ['critical', 'high', 'medium', 'low'];
DEFINE FIELD requirement_type ON compliance_requirement TYPE string 
    ASSERT $value IN ['mandatory', 'recommended', 'optional'];
DEFINE FIELD control_objectives ON compliance_requirement TYPE array<string>;
DEFINE FIELD implementation_guidance ON compliance_requirement TYPE string;
DEFINE FIELD evidence_required ON compliance_requirement TYPE array<string>;
DEFINE FIELD frequency ON compliance_requirement TYPE string 
    ASSERT $value IN ['continuous', 'annual', 'quarterly', 'monthly', 'on_event'];
DEFINE FIELD automated_check ON compliance_requirement TYPE bool DEFAULT false;
DEFINE FIELD manual_review ON compliance_requirement TYPE bool DEFAULT true;
DEFINE FIELD related_requirements ON compliance_requirement TYPE array<record<compliance_requirement>>;
DEFINE FIELD applicability_conditions ON compliance_requirement TYPE object;
DEFINE FIELD sanctions ON compliance_requirement TYPE object;
DEFINE FIELD is_active ON compliance_requirement TYPE bool DEFAULT true;
DEFINE FIELD created_on ON compliance_requirement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_requirement TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON regulation TYPE option<record<user>>;
DEFINE FIELD updated_by ON regulation TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_compliance_requirement_regulation ON compliance_requirement COLUMNS regulation;
DEFINE INDEX idx_compliance_requirement_id ON compliance_requirement COLUMNS requirement_id UNIQUE;
DEFINE INDEX idx_compliance_requirement_category ON compliance_requirement COLUMNS category;
DEFINE INDEX idx_compliance_requirement_priority ON compliance_requirement COLUMNS priority;
DEFINE INDEX idx_compliance_requirement_type ON compliance_requirement COLUMNS requirement_type;
DEFINE INDEX idx_compliance_requirement_active ON compliance_requirement COLUMNS is_active;

-- ==============================================================================
-- TABLE : CONTRÔLES DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_control SCHEMAFULL;
DEFINE FIELD control_id ON compliance_control TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON compliance_control TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_control TYPE string;
DEFINE FIELD requirements ON compliance_control TYPE array<record<compliance_requirement>>;
DEFINE FIELD control_type ON compliance_control TYPE string 
    ASSERT $value IN ['preventive', 'detective', 'corrective', 'compensating'];
DEFINE FIELD control_nature ON compliance_control TYPE string 
    ASSERT $value IN ['automated', 'manual', 'hybrid'];
DEFINE FIELD control_frequency ON compliance_control TYPE string 
    ASSERT $value IN ['real_time', 'daily', 'weekly', 'monthly', 'quarterly', 'annual'];
DEFINE FIELD owner_role ON compliance_control TYPE string;
DEFINE FIELD reviewer_role ON compliance_control TYPE option<string>;
DEFINE FIELD implementation_status ON compliance_control TYPE string 
    ASSERT $value IN ['not_implemented', 'in_progress', 'implemented', 'needs_improvement'];
DEFINE FIELD effectiveness ON compliance_control TYPE string 
    ASSERT $value IN ['not_tested', 'effective', 'partially_effective', 'ineffective'];
DEFINE FIELD test_procedures ON compliance_control TYPE array<object>;
DEFINE FIELD monitoring_metrics ON compliance_control TYPE array<object>;
DEFINE FIELD remediation_actions ON compliance_control TYPE array<object>;
DEFINE FIELD cost_estimate ON compliance_control TYPE option<decimal>;
DEFINE FIELD implementation_deadline ON compliance_control TYPE option<datetime>;
DEFINE FIELD last_review_date ON compliance_control TYPE option<datetime>;
DEFINE FIELD next_review_date ON compliance_control TYPE option<datetime>;
DEFINE FIELD is_key_control ON compliance_control TYPE bool DEFAULT false;
DEFINE FIELD is_active ON compliance_control TYPE bool DEFAULT true;
DEFINE FIELD created_on ON compliance_control TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_control TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON compliance_control TYPE option<record<user>>;
DEFINE FIELD updated_by ON compliance_control TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_compliance_control_id ON compliance_control COLUMNS control_id UNIQUE;
DEFINE INDEX idx_compliance_control_type ON compliance_control COLUMNS control_type;
DEFINE INDEX idx_compliance_control_status ON compliance_control COLUMNS implementation_status;
DEFINE INDEX idx_compliance_control_effectiveness ON compliance_control COLUMNS effectiveness;
DEFINE INDEX idx_compliance_control_review ON compliance_control COLUMNS next_review_date;
DEFINE INDEX idx_compliance_control_key ON compliance_control COLUMNS is_key_control;
DEFINE INDEX idx_compliance_control_active ON compliance_control COLUMNS is_active;

-- ==============================================================================
-- TABLE : ÉVALUATIONS DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_assessment SCHEMAFULL;
DEFINE FIELD assessment_id ON compliance_assessment TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON compliance_assessment TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_assessment TYPE string;
DEFINE FIELD company ON compliance_assessment TYPE record<company>;
DEFINE FIELD regulations ON compliance_assessment TYPE array<record<regulation>>;
DEFINE FIELD assessment_type ON compliance_assessment TYPE string 
    ASSERT $value IN ['initial', 'periodic', 'incident_triggered', 'pre_audit', 'post_incident'];
DEFINE FIELD scope ON compliance_assessment TYPE string;
DEFINE FIELD assessor ON compliance_assessment TYPE option<record<user>>;
DEFINE FIELD external_assessor ON compliance_assessment TYPE option<string>;
DEFINE FIELD start_date ON compliance_assessment TYPE datetime;
DEFINE FIELD target_completion_date ON compliance_assessment TYPE datetime;
DEFINE FIELD actual_completion_date ON compliance_assessment TYPE option<datetime>;
DEFINE FIELD status ON compliance_assessment TYPE string 
    ASSERT $value IN ['planned', 'in_progress', 'completed', 'cancelled', 'on_hold'];
DEFINE FIELD overall_score ON compliance_assessment TYPE option<decimal>;
DEFINE FIELD compliance_level ON compliance_assessment TYPE option<string> 
    ASSERT $value IN ['fully_compliant', 'largely_compliant', 'partially_compliant', 'non_compliant'];
DEFINE FIELD findings ON compliance_assessment TYPE array<object>;
DEFINE FIELD recommendations ON compliance_assessment TYPE array<object>;
DEFINE FIELD action_plan ON compliance_assessment TYPE array<object>;
DEFINE FIELD risk_areas ON compliance_assessment TYPE array<string>;
DEFINE FIELD next_assessment_date ON compliance_assessment TYPE option<datetime>;
DEFINE FIELD certification_eligible ON compliance_assessment TYPE option<bool>;
DEFINE FIELD report_path ON compliance_assessment TYPE option<string>;
DEFINE FIELD is_active ON compliance_assessment TYPE bool DEFAULT true;
DEFINE FIELD created_on ON compliance_assessment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_assessment TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON compliance_assessment TYPE option<record<user>>;
DEFINE FIELD updated_by ON compliance_assessment TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_compliance_assessment_id ON compliance_assessment COLUMNS assessment_id UNIQUE;
DEFINE INDEX idx_compliance_assessment_company ON compliance_assessment COLUMNS company;
DEFINE INDEX idx_compliance_assessment_type ON compliance_assessment COLUMNS assessment_type;
DEFINE INDEX idx_compliance_assessment_status ON compliance_assessment COLUMNS status;
DEFINE INDEX idx_compliance_assessment_dates ON compliance_assessment COLUMNS start_date, target_completion_date;
DEFINE INDEX idx_compliance_assessment_level ON compliance_assessment COLUMNS compliance_level;
DEFINE INDEX idx_compliance_assessment_next ON compliance_assessment COLUMNS next_assessment_date;

-- ==============================================================================
-- TABLE : INCIDENTS DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_incident SCHEMAFULL;
DEFINE FIELD incident_id ON compliance_incident TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON compliance_incident TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_incident TYPE string;
DEFINE FIELD company ON compliance_incident TYPE record<company>;
DEFINE FIELD regulation ON compliance_incident TYPE record<regulation>;
DEFINE FIELD requirements_violated ON compliance_incident TYPE array<record<compliance_requirement>>;
DEFINE FIELD incident_type ON compliance_incident TYPE string 
    ASSERT $value IN ['data_breach', 'regulatory_violation', 'control_failure', 'reporting_failure', 'policy_violation'];
DEFINE FIELD severity ON compliance_incident TYPE string 
    ASSERT $value IN ['critical', 'high', 'medium', 'low'];
DEFINE FIELD impact ON compliance_incident TYPE object;
DEFINE FIELD detection_date ON compliance_incident TYPE datetime;
DEFINE FIELD occurrence_date ON compliance_incident TYPE option<datetime>;
DEFINE FIELD reported_by ON compliance_incident TYPE option<record<user>>;
DEFINE FIELD assigned_to ON compliance_incident TYPE option<record<user>>;
DEFINE FIELD status ON compliance_incident TYPE string 
    ASSERT $value IN ['open', 'investigating', 'resolved', 'closed', 'escalated'];
DEFINE FIELD root_cause ON compliance_incident TYPE option<string>;
DEFINE FIELD corrective_actions ON compliance_incident TYPE array<object>;
DEFINE FIELD preventive_actions ON compliance_incident TYPE array<object>;
DEFINE FIELD regulatory_notification ON compliance_incident TYPE object;
DEFINE FIELD notification_required ON compliance_incident TYPE bool DEFAULT false;
DEFINE FIELD notification_deadline ON compliance_incident TYPE option<datetime>;
DEFINE FIELD notification_sent ON compliance_incident TYPE option<datetime>;
DEFINE FIELD external_reporting ON compliance_incident TYPE array<object>;
DEFINE FIELD financial_impact ON compliance_incident TYPE option<decimal>;
DEFINE FIELD resolution_date ON compliance_incident TYPE option<datetime>;
DEFINE FIELD lessons_learned ON compliance_incident TYPE option<string>;
DEFINE FIELD is_recurring ON compliance_incident TYPE bool DEFAULT false;
DEFINE FIELD created_on ON compliance_incident TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_incident TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON compliance_incident TYPE option<record<user>>;
DEFINE FIELD updated_by ON compliance_incident TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_compliance_incident_id ON compliance_incident COLUMNS incident_id UNIQUE;
DEFINE INDEX idx_compliance_incident_company ON compliance_incident COLUMNS company;
DEFINE INDEX idx_compliance_incident_regulation ON compliance_incident COLUMNS regulation;
DEFINE INDEX idx_compliance_incident_type ON compliance_incident COLUMNS incident_type;
DEFINE INDEX idx_compliance_incident_severity ON compliance_incident COLUMNS severity;
DEFINE INDEX idx_compliance_incident_status ON compliance_incident COLUMNS status;
DEFINE INDEX idx_compliance_incident_dates ON compliance_incident COLUMNS detection_date, resolution_date;
DEFINE INDEX idx_compliance_incident_notification ON compliance_incident COLUMNS notification_required, notification_deadline;

-- ==============================================================================
-- TABLE : CERTIFICATIONS DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_certification SCHEMAFULL;
DEFINE FIELD certification_id ON compliance_certification TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON compliance_certification TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_certification TYPE string;
DEFINE FIELD company ON compliance_certification TYPE record<company>;
DEFINE FIELD regulation ON compliance_certification TYPE record<regulation>;
DEFINE FIELD certification_body ON compliance_certification TYPE string;
DEFINE FIELD certificate_number ON compliance_certification TYPE option<string>;
DEFINE FIELD certification_type ON compliance_certification TYPE string 
    ASSERT $value IN ['self_declaration', 'third_party_audit', 'government_issued', 'industry_standard'];
DEFINE FIELD scope ON compliance_certification TYPE string;
DEFINE FIELD assessment_basis ON compliance_certification TYPE record<compliance_assessment>;
DEFINE FIELD issue_date ON compliance_certification TYPE datetime;
DEFINE FIELD expiry_date ON compliance_certification TYPE datetime;
DEFINE FIELD renewal_date ON compliance_certification TYPE option<datetime>;
DEFINE FIELD status ON compliance_certification TYPE string 
    ASSERT $value IN ['active', 'expired', 'suspended', 'revoked', 'under_review'];
DEFINE FIELD maintenance_requirements ON compliance_certification TYPE array<object>;
DEFINE FIELD surveillance_audits ON compliance_certification TYPE array<object>;
DEFINE FIELD annual_review_required ON compliance_certification TYPE bool DEFAULT false;
DEFINE FIELD certificate_file_path ON compliance_certification TYPE option<string>;
DEFINE FIELD public_register_url ON compliance_certification TYPE option<string>;
DEFINE FIELD renewal_notification_days ON compliance_certification TYPE int DEFAULT 90;
DEFINE FIELD cost ON compliance_certification TYPE option<decimal>;
DEFINE FIELD business_value ON compliance_certification TYPE object;
DEFINE FIELD is_active ON compliance_certification TYPE bool DEFAULT true;
DEFINE FIELD created_on ON compliance_certification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_certification TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON compliance_certification TYPE option<record<user>>;
DEFINE FIELD updated_by ON compliance_certification TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_compliance_certification_id ON compliance_certification COLUMNS certification_id UNIQUE;
DEFINE INDEX idx_compliance_certification_company ON compliance_certification COLUMNS company;
DEFINE INDEX idx_compliance_certification_regulation ON compliance_certification COLUMNS regulation;
DEFINE INDEX idx_compliance_certification_status ON compliance_certification COLUMNS status;
DEFINE INDEX idx_compliance_certification_expiry ON compliance_certification COLUMNS expiry_date;
DEFINE INDEX idx_compliance_certification_renewal ON compliance_certification COLUMNS renewal_date;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour évaluer la conformité d'une entreprise
DEFINE FUNCTION assess_company_compliance($company_id: record<company>, $regulation_id: record<regulation>) {
    LET $applicable_requirements = SELECT * FROM compliance_requirement 
        WHERE regulation = $regulation_id 
        AND is_active = true;
    
    LET $total_requirements = array::len($applicable_requirements);
    LET $met_requirements = 0;
    
    FOR $req IN $applicable_requirements {
        // Logique d'évaluation simplifiée
        LET $controls = SELECT * FROM compliance_control 
            WHERE $req IN requirements 
            AND implementation_status = 'implemented' 
            AND effectiveness IN ['effective', 'partially_effective'];
        
        IF array::len($controls) > 0 THEN
            $met_requirements = $met_requirements + 1;
        END;
    }
    
    LET $compliance_percentage = ($met_requirements / $total_requirements) * 100;
    
    LET $compliance_level = IF $compliance_percentage >= 95 THEN
        'fully_compliant'
    ELSE IF $compliance_percentage >= 80 THEN
        'largely_compliant'
    ELSE IF $compliance_percentage >= 50 THEN
        'partially_compliant'
    ELSE
        'non_compliant'
    END;
    
    RETURN {
        total_requirements: $total_requirements,
        met_requirements: $met_requirements,
        compliance_percentage: $compliance_percentage,
        compliance_level: $compliance_level
    };
};

-- Fonction pour identifier les exigences applicables
DEFINE FUNCTION get_applicable_requirements($company_id: record<company>) {
    LET $company = SELECT * FROM company WHERE id = $company_id;
    
    RETURN SELECT compliance_requirement.* FROM compliance_requirement 
    INNER JOIN regulation ON compliance_requirement.regulation = regulation.id
    WHERE regulation.is_active = true
    AND (
        regulation.country IS NULL OR 
        regulation.country = $company.country OR
        regulation.scope IN ['international', 'european']
    )
    AND (
        regulation.revenue_threshold IS NULL OR 
        $company.revenue >= regulation.revenue_threshold
    )
    AND (
        regulation.employee_threshold IS NULL OR 
        $company.employeeCount >= regulation.employee_threshold
    )
    AND (
        array::len(regulation.applicable_sectors) = 0 OR 
        $company.sector IN regulation.applicable_sectors
    );
};

-- Fonction pour calculer le risque de conformité
DEFINE FUNCTION calculate_compliance_risk($company_id: record<company>) {
    LET $recent_incidents = SELECT COUNT() FROM compliance_incident 
        WHERE company = $company_id 
        AND detection_date > (time::now() - duration::from_days(365))
        AND severity IN ['critical', 'high'];
    
    LET $overdue_controls = SELECT COUNT() FROM compliance_control 
        WHERE next_review_date < time::now() 
        AND is_active = true;
    
    LET $pending_certifications = SELECT COUNT() FROM compliance_certification 
        WHERE company = $company_id 
        AND expiry_date < (time::now() + duration::from_days(90))
        AND status = 'active';
    
    LET $risk_score = ($recent_incidents * 20) + ($overdue_controls * 10) + ($pending_certifications * 15);
    
    LET $risk_level = IF $risk_score >= 70 THEN
        'high'
    ELSE IF $risk_score >= 40 THEN
        'medium'
    ELSE
        'low'
    END;
    
    RETURN {
        risk_score: $risk_score,
        risk_level: $risk_level,
        factors: {
            recent_incidents: $recent_incidents,
            overdue_controls: $overdue_controls,
            pending_certifications: $pending_certifications
        }
    };
};

-- Fonction pour générer un rapport de conformité
DEFINE FUNCTION generate_compliance_report($company_id: record<company>, $regulation_ids: array<record<regulation>>) {
    LET $company = SELECT * FROM company WHERE id = $company_id;
    LET $assessments = [];
    
    FOR $regulation_id IN $regulation_ids {
        LET $assessment = assess_company_compliance($company_id, $regulation_id);
        LET $regulation = SELECT * FROM regulation WHERE id = $regulation_id;
        
        $assessments = array::push($assessments, {
            regulation: $regulation,
            assessment: $assessment
        });
    }
    
    LET $overall_compliance = math::mean(array::map($assessments, |$a| $a.assessment.compliance_percentage));
    LET $risk_analysis = calculate_compliance_risk($company_id);
    
    RETURN {
        company: $company,
        report_date: time::now(),
        overall_compliance_percentage: $overall_compliance,
        risk_analysis: $risk_analysis,
        regulatory_assessments: $assessments,
        recommendations: []
    };
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des exigences critiques
DEFINE TABLE critical_compliance_requirements AS SELECT 
    compliance_requirement.*,
    regulation.name AS regulation_name,
    regulation.scope AS regulation_scope
FROM compliance_requirement 
INNER JOIN regulation ON compliance_requirement.regulation = regulation.id
WHERE compliance_requirement.priority = 'critical' 
AND compliance_requirement.is_active = true 
AND regulation.is_active = true;

-- Vue des contrôles inefficaces
DEFINE TABLE ineffective_controls AS SELECT 
    compliance_control.*,
    array::len(compliance_control.requirements) AS requirement_count
FROM compliance_control 
WHERE compliance_control.effectiveness IN ['ineffective', 'partially_effective'] 
AND compliance_control.is_active = true;

-- Vue des incidents ouverts
DEFINE TABLE open_compliance_incidents AS SELECT 
    compliance_incident.*,
    regulation.name AS regulation_name,
    company.name AS company_name
FROM compliance_incident 
INNER JOIN regulation ON compliance_incident.regulation = regulation.id
INNER JOIN company ON compliance_incident.company = company.id
WHERE compliance_incident.status IN ['open', 'investigating', 'escalated']
ORDER BY compliance_incident.severity DESC, compliance_incident.detection_date DESC;

-- Vue des certifications expirant bientôt
DEFINE TABLE expiring_certifications AS SELECT 
    compliance_certification.*,
    regulation.name AS regulation_name,
    company.name AS company_name,
    (compliance_certification.expiry_date - time::now()) AS days_until_expiry
FROM compliance_certification 
INNER JOIN regulation ON compliance_certification.regulation = regulation.id
INNER JOIN company ON compliance_certification.company = company.id
WHERE compliance_certification.expiry_date < (time::now() + duration::from_days(90))
AND compliance_certification.status = 'active'
ORDER BY compliance_certification.expiry_date ASC;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : RÉGLEMENTATIONS PRINCIPALES
-- ==============================================================================

-- RGPD
CREATE regulation:gdpr CONTENT {
    code: "GDPR",
    name: "Règlement Général sur la Protection des Données",
    description: "Réglementation européenne sur la protection des données personnelles",
    regulation_type: "privacy",
    scope: "european",
    region: "EU",
    applicable_sectors: [],
    company_size_criteria: {
        all_sizes: true
    },
    effective_date: "2018-05-25T00:00:00Z",
    enforcement_authority: "Autorités de protection des données nationales",
    penalty_structure: {
        max_fine_percentage: 4,
        max_fine_amount: 20000000,
        warning_possible: true
    },
    certification_available: true,
    mandatory_reporting: true,
    reporting_frequency: "within_72_hours",
    is_active: true,
    created_on: time::now()
};

-- SOX (Sarbanes-Oxley)
CREATE regulation:sox CONTENT {
    code: "SOX",
    name: "Sarbanes-Oxley Act",
    description: "Loi américaine sur la transparence financière des entreprises cotées",
    regulation_type: "financial",
    scope: "national",
    country: country:us,
    applicable_sectors: ["finance", "public_companies"],
    company_size_criteria: {
        public_companies_only: true,
        market_cap_threshold: 75000000
    },
    effective_date: "2002-07-30T00:00:00Z",
    enforcement_authority: "SEC (Securities and Exchange Commission)",
    penalty_structure: {
        criminal_penalties: true,
        civil_penalties: true,
        imprisonment_possible: true
    },
    certification_available: false,
    mandatory_reporting: true,
    reporting_frequency: "annual",
    is_active: true,
    created_on: time::now()
};

-- ISO 27001
CREATE regulation:iso27001 CONTENT {
    code: "ISO27001",
    name: "ISO 27001 - Sécurité de l'Information",
    description: "Norme internationale pour les systèmes de management de la sécurité de l'information",
    regulation_type: "security",
    scope: "international",
    applicable_sectors: [],
    company_size_criteria: {
        all_sizes: true
    },
    effective_date: "2013-10-01T00:00:00Z",
    enforcement_authority: "Organismes de certification accrédités",
    penalty_structure: {
        certification_withdrawal: true,
        reputation_impact: true
    },
    certification_available: true,
    mandatory_reporting: false,
    is_active: true,
    created_on: time::now()
};

-- HIPAA
CREATE regulation:hipaa CONTENT {
    code: "HIPAA",
    name: "Health Insurance Portability and Accountability Act",
    description: "Loi américaine sur la protection des données de santé",
    regulation_type: "healthcare",
    scope: "national",
    country: country:us,
    applicable_sectors: ["healthcare", "insurance"],
    company_size_criteria: {
        healthcare_entities: true
    },
    effective_date: "1996-08-21T00:00:00Z",
    enforcement_authority: "HHS Office for Civil Rights",
    penalty_structure: {
        tier1_max: 50000,
        tier2_max: 100000,
        tier3_max: 250000,
        tier4_max: 1500000
    },
    certification_available: false,
    mandatory_reporting: true,
    reporting_frequency: "within_60_days",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : EXIGENCES RGPD
-- ==============================================================================

-- Principe de licéité
CREATE compliance_requirement:gdpr_lawfulness CONTENT {
    regulation: regulation:gdpr,
    requirement_id: "GDPR-6.1",
    title: "Licéité du traitement",
    description: "Le traitement de données personnelles doit reposer sur une base légale",
    category: "data_protection",
    priority: "critical",
    requirement_type: "mandatory",
    control_objectives: ["legal_basis", "consent_management", "documentation"],
    implementation_guidance: "Identifier et documenter la base légale pour chaque traitement",
    evidence_required: ["register_of_processing", "legal_basis_assessment"],
    frequency: "continuous",
    automated_check: true,
    manual_review: true,
    is_active: true,
    created_on: time::now()
};

-- Droits des personnes concernées
CREATE compliance_requirement:gdpr_rights CONTENT {
    regulation: regulation:gdpr,
    requirement_id: "GDPR-12-22",
    title: "Droits des personnes concernées",
    description: "Faciliter l'exercice des droits des personnes concernées",
    category: "data_protection",
    priority: "high",
    requirement_type: "mandatory",
    control_objectives: ["rights_management", "response_procedures", "transparency"],
    implementation_guidance: "Mettre en place des procédures pour traiter les demandes d'exercice de droits",
    evidence_required: ["procedures", "response_tracking", "training_records"],
    frequency: "on_event",
    automated_check: false,
    manual_review: true,
    is_active: true,
    created_on: time::now()
};

-- Notification de violation
CREATE compliance_requirement:gdpr_breach_notification CONTENT {
    regulation: regulation:gdpr,
    requirement_id: "GDPR-33-34",
    title: "Notification de violation de données",
    description: "Notifier les violations de données dans les délais requis",
    category: "incident_response",
    priority: "critical",
    requirement_type: "mandatory",
    control_objectives: ["breach_detection", "notification_procedures", "timeline_compliance"],
    implementation_guidance: "Établir des procédures de détection et notification des violations",
    evidence_required: ["incident_procedures", "notification_records", "timeline_tracking"],
    frequency: "on_event",
    automated_check: true,
    manual_review: true,
    sanctions: {
        max_fine: 10000000,
        fine_percentage: 2
    },
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CONTRÔLES EXEMPLE
-- ==============================================================================

-- Contrôle d'accès aux données
CREATE compliance_control:access_control CONTENT {
    control_id: "AC-001",
    name: "Contrôle d'accès aux données personnelles",
    description: "S'assurer que seules les personnes autorisées accèdent aux données personnelles",
    requirements: [compliance_requirement:gdpr_lawfulness],
    control_type: "preventive",
    control_nature: "automated",
    control_frequency: "real_time",
    owner_role: "data_protection_officer",
    reviewer_role: "security_manager",
    implementation_status: "implemented",
    effectiveness: "effective",
    test_procedures: [
        {
            name: "Test d'accès non autorisé",
            frequency: "quarterly",
            methodology: "penetration_testing"
        }
    ],
    monitoring_metrics: [
        {
            name: "Tentatives d'accès non autorisées",
            threshold: 0,
            alert_level: "critical"
        }
    ],
    last_review_date: "2024-01-15T00:00:00Z",
    next_review_date: "2024-04-15T00:00:00Z",
    is_key_control: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES RÈGLES DE CONFORMITÉ :

1. RÉGLEMENTATIONS (regulation)
   - Classification des réglementations
   - Critères d'applicabilité
   - Autorités de contrôle et sanctions

2. EXIGENCES (compliance_requirement)
   - Détail des obligations
   - Objectifs de contrôle
   - Preuves requises

3. CONTRÔLES (compliance_control)
   - Mesures préventives/détectives
   - Tests et surveillance
   - Efficacité et amélioration

4. ÉVALUATIONS (compliance_assessment)
   - Audits de conformité
   - Scores et niveaux
   - Plans d'action

5. INCIDENTS (compliance_incident)
   - Violations et manquements
   - Actions correctives
   - Notifications réglementaires

6. CERTIFICATIONS (compliance_certification)
   - Certifications obtenues
   - Renouvellements
   - Maintenance

UTILISATION :
- Évaluation automatique de conformité
- Gestion des incidents et violations
- Suivi des certifications
- Reporting réglementaire
- Tableau de bord de conformité
*/ 