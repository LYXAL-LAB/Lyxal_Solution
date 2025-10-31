-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : PROTECTION DES DONNÉES - COUCHE JURIDIQUE
-- ==============================================================================
-- Fichier : 08_data_protection_legal.surql
-- Description : Obligations légales, sanctions et conformité réglementaire
-- Complément au module technique GDPR (lyxal-surreal/axelor/gdpr/)
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : RÉGLEMENTATIONS DE PROTECTION DES DONNÉES
-- ==============================================================================

DEFINE TABLE data_protection_regulation SCHEMAFULL;
DEFINE FIELD regulation_id ON data_protection_regulation TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON data_protection_regulation TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON data_protection_regulation TYPE string;
DEFINE FIELD regulation_type ON data_protection_regulation TYPE string ASSERT $value IN ['gdpr', 'ccpa', 'lgpd', 'pipeda', 'pdpa_singapore', 'pdpa_thailand', 'popia'];
DEFINE FIELD jurisdiction ON data_protection_regulation TYPE string;
DEFINE FIELD applicable_countries ON data_protection_regulation TYPE array<string>;
DEFINE FIELD effective_date ON data_protection_regulation TYPE datetime;
DEFINE FIELD last_amendment_date ON data_protection_regulation TYPE option<datetime>;
DEFINE FIELD applicability_threshold ON data_protection_regulation TYPE object;
DEFINE FIELD territorial_scope ON data_protection_regulation TYPE string;
DEFINE FIELD material_scope ON data_protection_regulation TYPE string;
DEFINE FIELD extraterritorial_reach ON data_protection_regulation TYPE bool DEFAULT false;
DEFINE FIELD legal_basis_required ON data_protection_regulation TYPE array<string>;
DEFINE FIELD consent_requirements ON data_protection_regulation TYPE object;
DEFINE FIELD data_subject_rights ON data_protection_regulation TYPE array<string>;
DEFINE FIELD mandatory_disclosures ON data_protection_regulation TYPE array<string>;
DEFINE FIELD data_localization_rules ON data_protection_regulation TYPE object;
DEFINE FIELD cross_border_transfer_rules ON data_protection_regulation TYPE object;
DEFINE FIELD breach_notification_timeline ON data_protection_regulation TYPE int; -- heures
DEFINE FIELD authority_notification_required ON data_protection_regulation TYPE bool DEFAULT true;
DEFINE FIELD subject_notification_required ON data_protection_regulation TYPE bool DEFAULT true;
DEFINE FIELD dpo_requirement_threshold ON data_protection_regulation TYPE object;
DEFINE FIELD impact_assessment_required ON data_protection_regulation TYPE array<string>;
DEFINE FIELD certification_schemes ON data_protection_regulation TYPE array<string>;
DEFINE FIELD enforcement_authority ON data_protection_regulation TYPE string;
DEFINE FIELD maximum_penalty_percentage ON data_protection_regulation TYPE decimal;
DEFINE FIELD maximum_penalty_amount ON data_protection_regulation TYPE decimal;
DEFINE FIELD currency ON data_protection_regulation TYPE string DEFAULT "EUR";
DEFINE FIELD compliance_deadlines ON data_protection_regulation TYPE array<object>;
DEFINE FIELD is_active ON data_protection_regulation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_regulation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_regulation TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_regulation_id ON data_protection_regulation COLUMNS regulation_id UNIQUE;
DEFINE INDEX idx_data_protection_regulation_type ON data_protection_regulation COLUMNS regulation_type;
DEFINE INDEX idx_data_protection_regulation_jurisdiction ON data_protection_regulation COLUMNS jurisdiction;
DEFINE INDEX idx_data_protection_regulation_active ON data_protection_regulation COLUMNS is_active;

-- ==============================================================================
-- TABLE : AUTORITÉS DE CONTRÔLE
-- ==============================================================================

DEFINE TABLE data_protection_authority SCHEMAFULL;
DEFINE FIELD authority_id ON data_protection_authority TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON data_protection_authority TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD abbreviation ON data_protection_authority TYPE string;
DEFINE FIELD country ON data_protection_authority TYPE string;
DEFINE FIELD regulation ON data_protection_authority TYPE record<data_protection_regulation>;
DEFINE FIELD official_website ON data_protection_authority TYPE string;
DEFINE FIELD notification_portal ON data_protection_authority TYPE option<string>;
DEFINE FIELD contact_email ON data_protection_authority TYPE string;
DEFINE FIELD contact_phone ON data_protection_authority TYPE option<string>;
DEFINE FIELD postal_address ON data_protection_authority TYPE object;
DEFINE FIELD notification_procedures ON data_protection_authority TYPE array<object>;
DEFINE FIELD notification_templates ON data_protection_authority TYPE array<object>;
DEFINE FIELD language_requirements ON data_protection_authority TYPE array<string>;
DEFINE FIELD notification_deadlines ON data_protection_authority TYPE object;
DEFINE FIELD investigation_powers ON data_protection_authority TYPE array<string>;
DEFINE FIELD enforcement_measures ON data_protection_authority TYPE array<string>;
DEFINE FIELD penalty_guidelines ON data_protection_authority TYPE object;
DEFINE FIELD recent_enforcement_actions ON data_protection_authority TYPE array<object>;
DEFINE FIELD guidance_documents ON data_protection_authority TYPE array<object>;
DEFINE FIELD sector_specific_guidance ON data_protection_authority TYPE array<object>;
DEFINE FIELD consultation_procedures ON data_protection_authority TYPE object;
DEFINE FIELD certification_body ON data_protection_authority TYPE bool DEFAULT false;
DEFINE FIELD adequacy_decisions ON data_protection_authority TYPE array<string>;
DEFINE FIELD international_cooperation ON data_protection_authority TYPE array<string>;
DEFINE FIELD annual_report_url ON data_protection_authority TYPE option<string>;
DEFINE FIELD is_active ON data_protection_authority TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_authority TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_authority TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_authority_id ON data_protection_authority COLUMNS authority_id UNIQUE;
DEFINE INDEX idx_data_protection_authority_country ON data_protection_authority COLUMNS country;
DEFINE INDEX idx_data_protection_authority_regulation ON data_protection_authority COLUMNS regulation;
DEFINE INDEX idx_data_protection_authority_active ON data_protection_authority COLUMNS is_active;

-- ==============================================================================
-- TABLE : SANCTIONS ET PÉNALITÉS
-- ==============================================================================

DEFINE TABLE data_protection_penalty SCHEMAFULL;
DEFINE FIELD penalty_id ON data_protection_penalty TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD regulation ON data_protection_penalty TYPE record<data_protection_regulation>;
DEFINE FIELD authority ON data_protection_penalty TYPE record<data_protection_authority>;
DEFINE FIELD violation_type ON data_protection_penalty TYPE string ASSERT $value IN ['consent', 'data_subject_rights', 'transfer', 'security', 'notification', 'dpo', 'impact_assessment', 'cooperation'];
DEFINE FIELD violation_description ON data_protection_penalty TYPE string;
DEFINE FIELD penalty_tier ON data_protection_penalty TYPE string ASSERT $value IN ['administrative', 'lower_tier', 'upper_tier', 'criminal'];
DEFINE FIELD penalty_percentage ON data_protection_penalty TYPE decimal;
DEFINE FIELD penalty_amount ON data_protection_penalty TYPE decimal;
DEFINE FIELD currency ON data_protection_penalty TYPE string DEFAULT "EUR";
DEFINE FIELD calculation_base ON data_protection_penalty TYPE string ASSERT $value IN ['global_turnover', 'annual_revenue', 'affected_subjects', 'fixed_amount'];
DEFINE FIELD aggravating_factors ON data_protection_penalty TYPE array<string>;
DEFINE FIELD mitigating_factors ON data_protection_penalty TYPE array<string>;
DEFINE FIELD repeat_offense_multiplier ON data_protection_penalty TYPE decimal DEFAULT 1.0;
DEFINE FIELD statute_of_limitations ON data_protection_penalty TYPE int; -- années
DEFINE FIELD payment_deadline ON data_protection_penalty TYPE int DEFAULT 30; -- jours
DEFINE FIELD appeal_deadline ON data_protection_penalty TYPE int DEFAULT 30; -- jours
DEFINE FIELD precedent_cases ON data_protection_penalty TYPE array<object>;
DEFINE FIELD enforcement_statistics ON data_protection_penalty TYPE object;
DEFINE FIELD risk_assessment_factors ON data_protection_penalty TYPE array<object>;
DEFINE FIELD compliance_program_credit ON data_protection_penalty TYPE decimal DEFAULT 0.0;
DEFINE FIELD cooperation_credit ON data_protection_penalty TYPE decimal DEFAULT 0.0;
DEFINE FIELD self_reporting_credit ON data_protection_penalty TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_active ON data_protection_penalty TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_penalty TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_penalty TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_penalty_id ON data_protection_penalty COLUMNS penalty_id UNIQUE;
DEFINE INDEX idx_data_protection_penalty_regulation ON data_protection_penalty COLUMNS regulation;
DEFINE INDEX idx_data_protection_penalty_violation ON data_protection_penalty COLUMNS violation_type;
DEFINE INDEX idx_data_protection_penalty_tier ON data_protection_penalty COLUMNS penalty_tier;

-- ==============================================================================
-- TABLE : AUDITS DE CONFORMITÉ JURIDIQUE
-- ==============================================================================

DEFINE TABLE data_protection_legal_audit SCHEMAFULL;
DEFINE FIELD audit_id ON data_protection_legal_audit TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON data_protection_legal_audit TYPE record<company>;
DEFINE FIELD audit_name ON data_protection_legal_audit TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD audit_type ON data_protection_legal_audit TYPE string ASSERT $value IN ['internal', 'external', 'regulatory', 'certification'];
DEFINE FIELD applicable_regulations ON data_protection_legal_audit TYPE array<record<data_protection_regulation>>;
DEFINE FIELD audit_scope ON data_protection_legal_audit TYPE array<string>;
DEFINE FIELD audit_date ON data_protection_legal_audit TYPE datetime;
DEFINE FIELD auditor_name ON data_protection_legal_audit TYPE string;
DEFINE FIELD auditor_firm ON data_protection_legal_audit TYPE option<string>;
DEFINE FIELD auditor_credentials ON data_protection_legal_audit TYPE array<string>;
DEFINE FIELD assessment_criteria ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD legal_findings ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD compliance_gaps ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD risk_assessment ON data_protection_legal_audit TYPE object;
DEFINE FIELD recommendations ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD action_plan ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD overall_compliance_score ON data_protection_legal_audit TYPE decimal;
DEFINE FIELD legal_risk_score ON data_protection_legal_audit TYPE decimal;
DEFINE FIELD certification_status ON data_protection_legal_audit TYPE string ASSERT $value IN ['pending', 'certified', 'conditional', 'rejected'];
DEFINE FIELD certification_body ON data_protection_legal_audit TYPE option<string>;
DEFINE FIELD certification_expiry ON data_protection_legal_audit TYPE option<datetime>;
DEFINE FIELD follow_up_required ON data_protection_legal_audit TYPE bool DEFAULT false;
DEFINE FIELD follow_up_deadline ON data_protection_legal_audit TYPE option<datetime>;
DEFINE FIELD regulatory_notifications ON data_protection_legal_audit TYPE array<object>;
DEFINE FIELD audit_report_path ON data_protection_legal_audit TYPE option<string>;
DEFINE FIELD status ON data_protection_legal_audit TYPE string ASSERT $value IN ['in_progress', 'completed', 'under_review', 'approved'];
DEFINE FIELD is_active ON data_protection_legal_audit TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_legal_audit TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_legal_audit TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_legal_audit_id ON data_protection_legal_audit COLUMNS audit_id UNIQUE;
DEFINE INDEX idx_data_protection_legal_audit_company ON data_protection_legal_audit COLUMNS company;
DEFINE INDEX idx_data_protection_legal_audit_type ON data_protection_legal_audit COLUMNS audit_type;
DEFINE INDEX idx_data_protection_legal_audit_date ON data_protection_legal_audit COLUMNS audit_date;
DEFINE INDEX idx_data_protection_legal_audit_status ON data_protection_legal_audit COLUMNS status;

-- ==============================================================================
-- TABLE : CLAUSES CONTRACTUELLES TYPES
-- ==============================================================================

DEFINE TABLE data_protection_contract_clause SCHEMAFULL;
DEFINE FIELD clause_id ON data_protection_contract_clause TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON data_protection_contract_clause TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON data_protection_contract_clause TYPE string;
DEFINE FIELD clause_type ON data_protection_contract_clause TYPE string ASSERT $value IN ['dpa', 'scc', 'bcr', 'adequacy', 'processor_agreement', 'joint_controller'];
DEFINE FIELD applicable_regulations ON data_protection_contract_clause TYPE array<record<data_protection_regulation>>;
DEFINE FIELD legal_text_fr ON data_protection_contract_clause TYPE string;
DEFINE FIELD legal_text_en ON data_protection_contract_clause TYPE option<string>;
DEFINE FIELD variables ON data_protection_contract_clause TYPE array<object>;
DEFINE FIELD mandatory_elements ON data_protection_contract_clause TYPE array<string>;
DEFINE FIELD optional_elements ON data_protection_contract_clause TYPE array<string>;
DEFINE FIELD transfer_mechanism ON data_protection_contract_clause TYPE option<string>;
DEFINE FIELD adequacy_requirement ON data_protection_contract_clause TYPE bool DEFAULT false;
DEFINE FIELD supervisory_authority_approval ON data_protection_contract_clause TYPE bool DEFAULT false;
DEFINE FIELD template_source ON data_protection_contract_clause TYPE string;
DEFINE FIELD last_updated_by_authority ON data_protection_contract_clause TYPE option<datetime>;
DEFINE FIELD version ON data_protection_contract_clause TYPE string DEFAULT "1.0";
DEFINE FIELD legal_precedents ON data_protection_contract_clause TYPE array<object>;
DEFINE FIELD usage_frequency ON data_protection_contract_clause TYPE int DEFAULT 0;
DEFINE FIELD effectiveness_rating ON data_protection_contract_clause TYPE decimal DEFAULT 0.0;
DEFINE FIELD approved_by_legal ON data_protection_contract_clause TYPE bool DEFAULT false;
DEFINE FIELD approval_date ON data_protection_contract_clause TYPE option<datetime>;
DEFINE FIELD is_active ON data_protection_contract_clause TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_contract_clause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_contract_clause TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_contract_clause_id ON data_protection_contract_clause COLUMNS clause_id UNIQUE;
DEFINE INDEX idx_data_protection_contract_clause_type ON data_protection_contract_clause COLUMNS clause_type;
DEFINE INDEX idx_data_protection_contract_clause_approved ON data_protection_contract_clause COLUMNS approved_by_legal;
DEFINE INDEX idx_data_protection_contract_clause_active ON data_protection_contract_clause COLUMNS is_active;

-- ==============================================================================
-- TABLE : INCIDENTS ET VIOLATIONS
-- ==============================================================================

DEFINE TABLE data_protection_incident SCHEMAFULL;
DEFINE FIELD incident_id ON data_protection_incident TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON data_protection_incident TYPE record<company>;
DEFINE FIELD incident_title ON data_protection_incident TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON data_protection_incident TYPE string;
DEFINE FIELD incident_type ON data_protection_incident TYPE string ASSERT $value IN ['breach', 'unauthorized_access', 'data_loss', 'system_compromise', 'human_error', 'malicious_attack'];
DEFINE FIELD severity_level ON data_protection_incident TYPE string ASSERT $value IN ['low', 'medium', 'high', 'critical'];
DEFINE FIELD detection_date ON data_protection_incident TYPE datetime;
DEFINE FIELD occurrence_date ON data_protection_incident TYPE option<datetime>;
DEFINE FIELD detection_method ON data_protection_incident TYPE string;
DEFINE FIELD affected_data_types ON data_protection_incident TYPE array<string>;
DEFINE FIELD affected_subjects_count ON data_protection_incident TYPE int DEFAULT 0;
DEFINE FIELD affected_jurisdictions ON data_protection_incident TYPE array<string>;
DEFINE FIELD notification_required ON data_protection_incident TYPE bool DEFAULT false;
DEFINE FIELD notification_timeline ON data_protection_incident TYPE int; -- heures
DEFINE FIELD authority_notifications ON data_protection_incident TYPE array<object>;
DEFINE FIELD subject_notifications ON data_protection_incident TYPE array<object>;
DEFINE FIELD containment_measures ON data_protection_incident TYPE array<object>;
DEFINE FIELD investigation_findings ON data_protection_incident TYPE array<object>;
DEFINE FIELD root_cause_analysis ON data_protection_incident TYPE object;
DEFINE FIELD remediation_actions ON data_protection_incident TYPE array<object>;
DEFINE FIELD preventive_measures ON data_protection_incident TYPE array<object>;
DEFINE FIELD legal_consequences ON data_protection_incident TYPE array<object>;
DEFINE FIELD regulatory_response ON data_protection_incident TYPE array<object>;
DEFINE FIELD estimated_impact ON data_protection_incident TYPE object;
DEFINE FIELD lessons_learned ON data_protection_incident TYPE array<string>;
DEFINE FIELD status ON data_protection_incident TYPE string ASSERT $value IN ['detected', 'investigating', 'contained', 'resolved', 'closed'];
DEFINE FIELD assigned_team ON data_protection_incident TYPE array<record<user>>;
DEFINE FIELD external_advisors ON data_protection_incident TYPE array<string>;
DEFINE FIELD is_active ON data_protection_incident TYPE bool DEFAULT true;
DEFINE FIELD created_on ON data_protection_incident TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON data_protection_incident TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_data_protection_incident_id ON data_protection_incident COLUMNS incident_id UNIQUE;
DEFINE INDEX idx_data_protection_incident_company ON data_protection_incident COLUMNS company;
DEFINE INDEX idx_data_protection_incident_type ON data_protection_incident COLUMNS incident_type;
DEFINE INDEX idx_data_protection_incident_severity ON data_protection_incident COLUMNS severity_level;
DEFINE INDEX idx_data_protection_incident_status ON data_protection_incident COLUMNS status;
DEFINE INDEX idx_data_protection_incident_detection ON data_protection_incident COLUMNS detection_date;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour calculer les pénalités potentielles
DEFINE FUNCTION calculate_potential_penalty($company_id: record<company>, $regulation_id: record<data_protection_regulation>, $violation_type: string, $annual_turnover: decimal) {
    LET $penalty_info = SELECT * FROM data_protection_penalty 
        WHERE regulation = $regulation_id 
        AND violation_type = $violation_type
        LIMIT 1;
    
    IF array::len($penalty_info) = 0 THEN
        RETURN { error: "Aucune information de pénalité trouvée" };
    END;
    
    LET $penalty = $penalty_info[0];
    LET $percentage_penalty = ($annual_turnover * $penalty.penalty_percentage) / 100;
    LET $fixed_penalty = $penalty.penalty_amount;
    
    LET $maximum_penalty = math::max($percentage_penalty, $fixed_penalty);
    
    RETURN {
        violation_type: $violation_type,
        regulation: $regulation_id,
        percentage_penalty: $percentage_penalty,
        fixed_penalty: $fixed_penalty,
        maximum_penalty: $maximum_penalty,
        currency: $penalty.currency,
        calculation_date: time::now()
    };
};

-- Fonction pour vérifier les obligations de notification
DEFINE FUNCTION check_notification_obligations($incident_id: record<data_protection_incident>) {
    LET $incident = SELECT * FROM data_protection_incident WHERE id = $incident_id;
    LET $notifications = [];
    
    FOR $jurisdiction IN $incident.affected_jurisdictions {
        LET $authority = SELECT * FROM data_protection_authority 
            WHERE country = $jurisdiction 
            LIMIT 1;
        
        IF array::len($authority) > 0 THEN
            LET $notification = {
                authority: $authority[0].name,
                country: $jurisdiction,
                deadline: time::now() + duration::from_hours($authority[0].notification_deadlines.breach_hours),
                portal: $authority[0].notification_portal,
                contact: $authority[0].contact_email,
                required: true
            };
            
            $notifications = array::push($notifications, $notification);
        END;
    }
    
    RETURN {
        incident_id: $incident_id,
        notifications_required: array::len($notifications),
        notifications: $notifications,
        next_deadline: math::min($notifications[*].deadline)
    };
};

-- Fonction pour évaluer la conformité réglementaire
DEFINE FUNCTION assess_regulatory_compliance($company_id: record<company>, $regulation_ids: array<record<data_protection_regulation>>) {
    LET $compliance_scores = [];
    
    FOR $regulation IN $regulation_ids {
        LET $recent_audit = SELECT * FROM data_protection_legal_audit 
            WHERE company = $company_id 
            AND $regulation IN applicable_regulations
            ORDER BY audit_date DESC
            LIMIT 1;
        
        LET $score = IF array::len($recent_audit) > 0 THEN 
            $recent_audit[0].overall_compliance_score 
        ELSE 
            50.0 
        END;
        
        LET $compliance_item = {
            regulation: $regulation,
            compliance_score: $score,
            last_audit_date: IF array::len($recent_audit) > 0 THEN $recent_audit[0].audit_date ELSE NULL END,
            audit_required: $score < 80.0
        };
        
        $compliance_scores = array::push($compliance_scores, $compliance_item);
    }
    
    LET $overall_score = math::mean($compliance_scores[*].compliance_score);
    
    RETURN {
        company_id: $company_id,
        overall_compliance_score: $overall_score,
        regulation_scores: $compliance_scores,
        high_risk_regulations: array::filter($compliance_scores, |$item| $item.compliance_score < 70.0),
        assessment_date: time::now()
    };
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE
-- ==============================================================================

-- RGPD Européen
CREATE data_protection_regulation:gdpr CONTENT {
    regulation_id: "GDPR-EU-2016",
    name: "Règlement Général sur la Protection des Données",
    description: "Réglementation européenne sur la protection des données personnelles",
    regulation_type: "gdpr",
    jurisdiction: "Union Européenne",
    applicable_countries: ["FR", "DE", "IT", "ES", "NL", "BE", "AT", "PT", "IE", "LU", "FI", "DK", "SE", "PL", "CZ", "SK", "SI", "HU", "HR", "BG", "RO", "EE", "LV", "LT", "CY", "MT"],
    effective_date: "2018-05-25T00:00:00Z",
    applicability_threshold: {
        employees: 250,
        annual_turnover: 50000000,
        data_subjects: 5000
    },
    territorial_scope: "Établissement dans l'UE ou ciblage de résidents UE",
    extraterritorial_reach: true,
    legal_basis_required: ["consent", "contract", "legal_obligation", "vital_interests", "public_task", "legitimate_interest"],
    data_subject_rights: ["access", "rectification", "erasure", "portability", "restriction", "objection"],
    breach_notification_timeline: 72,
    maximum_penalty_percentage: 4.0,
    maximum_penalty_amount: 20000000.0,
    currency: "EUR",
    is_active: true,
    created_on: time::now()
};

-- CCPA Californien
CREATE data_protection_regulation:ccpa CONTENT {
    regulation_id: "CCPA-CA-2018",
    name: "California Consumer Privacy Act",
    description: "Loi californienne sur la protection de la vie privée des consommateurs",
    regulation_type: "ccpa",
    jurisdiction: "Californie, États-Unis",
    applicable_countries: ["US"],
    effective_date: "2020-01-01T00:00:00Z",
    applicability_threshold: {
        annual_revenue: 25000000,
        personal_info_sold: 50000,
        revenue_from_selling: 50
    },
    extraterritorial_reach: true,
    data_subject_rights: ["know", "delete", "opt_out", "non_discrimination"],
    maximum_penalty_amount: 7500.0,
    currency: "USD",
    is_active: true,
    created_on: time::now()
};

-- CNIL France
CREATE data_protection_authority:cnil_france CONTENT {
    authority_id: "CNIL-FR",
    name: "Commission Nationale de l'Informatique et des Libertés",
    abbreviation: "CNIL",
    country: "FR",
    regulation: data_protection_regulation:gdpr,
    official_website: "https://www.cnil.fr",
    contact_email: "dpd@cnil.fr",
    postal_address: {
        street: "3 Place de Fontenoy",
        city: "Paris",
        postal_code: "75007",
        country: "France"
    },
    notification_deadlines: {
        breach_hours: 72,
        subject_notification_hours: 72
    },
    language_requirements: ["fr"],
    penalty_guidelines: {
        upper_tier_percentage: 4.0,
        upper_tier_amount: 20000000.0,
        lower_tier_percentage: 2.0,
        lower_tier_amount: 10000000.0
    },
    is_active: true,
    created_on: time::now()
};

-- Clause DPA Standard
CREATE data_protection_contract_clause:standard_dpa CONTENT {
    clause_id: "DPA-STANDARD-2024",
    name: "Accord de Traitement de Données Standard",
    description: "Clause DPA standard conforme RGPD",
    clause_type: "dpa",
    applicable_regulations: [data_protection_regulation:gdpr],
    legal_text_fr: "Le Sous-traitant s'engage à traiter les données personnelles uniquement sur instruction documentée du Responsable de traitement, à assurer la confidentialité des données, à mettre en place les mesures techniques et organisationnelles appropriées pour garantir un niveau de sécurité adapté au risque.",
    mandatory_elements: ["purpose_limitation", "confidentiality", "security_measures", "data_transfer_restrictions", "assistance_obligations"],
    template_source: "CNIL France",
    version: "2.0",
    approved_by_legal: true,
    approval_date: time::now(),
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DU MODULE PROTECTION DES DONNÉES - COUCHE JURIDIQUE :

1. RÉGLEMENTATIONS (data_protection_regulation)
   - RGPD, CCPA, LGPD par juridiction
   - Seuils d'applicabilité et portée territoriale
   - Droits des personnes et obligations

2. AUTORITÉS DE CONTRÔLE (data_protection_authority)
   - Contacts et procédures par pays
   - Délais de notification et templates
   - Pouvoirs d'investigation et sanctions

3. SANCTIONS ET PÉNALITÉS (data_protection_penalty)
   - Grilles de sanctions par violation
   - Calcul automatique des amendes
   - Facteurs aggravants et atténuants

4. AUDITS JURIDIQUES (data_protection_legal_audit)
   - Conformité réglementaire par juridiction
   - Certification et scoring juridique
   - Plans d'action et recommandations

5. CLAUSES CONTRACTUELLES (data_protection_contract_clause)
   - DPA, SCC, BCR par réglementation
   - Templates approuvés par les autorités
   - Intégration avec module contrats

6. INCIDENTS ET VIOLATIONS (data_protection_incident)
   - Gestion des violations de données
   - Notifications réglementaires obligatoires
   - Enquêtes et mesures correctives

INTÉGRATION AVEC MODULE GDPR TECHNIQUE :
- Complète les tables techniques existantes
- Ajoute la dimension juridique et réglementaire
- Fournit le contexte légal pour les processus techniques
- Assure la conformité multi-juridictions

FONCTIONS AVANCÉES :
- Calcul automatique des pénalités potentielles
- Vérification des obligations de notification
- Évaluation de conformité réglementaire
- Intégration avec calendrier légal

UTILISATION :
- Évaluation des risques juridiques
- Conformité multi-juridictions
- Gestion des incidents de sécurité
- Audit et certification
- Contractualisation conforme
*/ 