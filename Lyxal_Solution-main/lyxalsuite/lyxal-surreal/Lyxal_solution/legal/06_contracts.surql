-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : CONTRATS
-- ==============================================================================
-- Fichier : 06_contracts.surql
-- Description : Gestion complète des contrats avec IA contractuelle
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : TYPES DE CONTRATS
-- ==============================================================================

DEFINE TABLE contract_type SCHEMAFULL;
DEFINE FIELD type_id ON contract_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON contract_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON contract_type TYPE string;
DEFINE FIELD category ON contract_type TYPE string 
    ASSERT $value IN ['commercial', 'employment', 'service', 'partnership', 'real_estate', 'intellectual_property', 'finance', 'government'];
DEFINE FIELD complexity_level ON contract_type TYPE string 
    ASSERT $value IN ['simple', 'medium', 'complex', 'critical'];
DEFINE FIELD typical_duration_months ON contract_type TYPE option<int>;
DEFINE FIELD renewable ON contract_type TYPE bool DEFAULT false;
DEFINE FIELD required_approvals ON contract_type TYPE array<string>;
DEFINE FIELD mandatory_clauses ON contract_type TYPE array<string>;
DEFINE FIELD risk_level ON contract_type TYPE string 
    ASSERT $value IN ['low', 'medium', 'high', 'critical'];
DEFINE FIELD template_available ON contract_type TYPE bool DEFAULT false;
DEFINE FIELD auto_renewal_possible ON contract_type TYPE bool DEFAULT false;
DEFINE FIELD notification_days_before_expiry ON contract_type TYPE int DEFAULT 30;
DEFINE FIELD regulatory_requirements ON contract_type TYPE array<string>;
DEFINE FIELD is_active ON contract_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_type TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract_type TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_type_id ON contract_type COLUMNS type_id UNIQUE;
DEFINE INDEX idx_contract_type_category ON contract_type COLUMNS category;
DEFINE INDEX idx_contract_type_complexity ON contract_type COLUMNS complexity_level;
DEFINE INDEX idx_contract_type_risk ON contract_type COLUMNS risk_level;
DEFINE INDEX idx_contract_type_active ON contract_type COLUMNS is_active;

-- ==============================================================================
-- TABLE : CLAUSES CONTRACTUELLES STANDARDS
-- ==============================================================================

DEFINE TABLE contract_clause SCHEMAFULL;
DEFINE FIELD clause_id ON contract_clause TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON contract_clause TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON contract_clause TYPE string;
DEFINE FIELD clause_type ON contract_clause TYPE string 
    ASSERT $value IN ['mandatory', 'optional', 'conditional', 'regulatory'];
DEFINE FIELD category ON contract_clause TYPE string 
    ASSERT $value IN ['payment', 'liability', 'termination', 'confidentiality', 'intellectual_property', 'force_majeure', 'dispute_resolution', 'warranties'];
DEFINE FIELD legal_text_fr ON contract_clause TYPE string;
DEFINE FIELD legal_text_en ON contract_clause TYPE option<string>;
DEFINE FIELD variables ON contract_clause TYPE array<object>;
DEFINE FIELD applicable_contract_types ON contract_clause TYPE array<record<contract_type>>;
DEFINE FIELD risk_mitigation ON contract_clause TYPE array<string>;
DEFINE FIELD legal_precedents ON contract_clause TYPE array<object>;
DEFINE FIELD negotiation_flexibility ON contract_clause TYPE string 
    ASSERT $value IN ['non_negotiable', 'limited', 'flexible', 'fully_negotiable'];
DEFINE FIELD ai_recommendations ON contract_clause TYPE array<object>;
DEFINE FIELD usage_frequency ON contract_clause TYPE int DEFAULT 0;
DEFINE FIELD success_rate ON contract_clause TYPE decimal DEFAULT 0.0;
DEFINE FIELD version ON contract_clause TYPE string DEFAULT "1.0";
DEFINE FIELD approved_by_legal ON contract_clause TYPE bool DEFAULT false;
DEFINE FIELD approval_date ON contract_clause TYPE option<datetime>;
DEFINE FIELD is_active ON contract_clause TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_clause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_clause TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_clause TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract_clause TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_clause_id ON contract_clause COLUMNS clause_id UNIQUE;
DEFINE INDEX idx_contract_clause_type ON contract_clause COLUMNS clause_type;
DEFINE INDEX idx_contract_clause_category ON contract_clause COLUMNS category;
DEFINE INDEX idx_contract_clause_flexibility ON contract_clause COLUMNS negotiation_flexibility;
DEFINE INDEX idx_contract_clause_approved ON contract_clause COLUMNS approved_by_legal;
DEFINE INDEX idx_contract_clause_active ON contract_clause COLUMNS is_active;

-- ==============================================================================
-- TABLE : CONTRATS
-- ==============================================================================

DEFINE TABLE contract SCHEMAFULL;
DEFINE FIELD contract_id ON contract TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON contract TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON contract TYPE string;
DEFINE FIELD contract_type ON contract TYPE record<contract_type>;
DEFINE FIELD company ON contract TYPE record<company>;
DEFINE FIELD counterparty ON contract TYPE string;
DEFINE FIELD counterparty_entity ON contract TYPE option<record<legal_entity>>;
DEFINE FIELD contract_value ON contract TYPE option<decimal>;
DEFINE FIELD currency ON contract TYPE string DEFAULT "EUR";
DEFINE FIELD start_date ON contract TYPE datetime;
DEFINE FIELD end_date ON contract TYPE option<datetime>;
DEFINE FIELD initial_term_months ON contract TYPE option<int>;
DEFINE FIELD auto_renewal ON contract TYPE bool DEFAULT false;
DEFINE FIELD renewal_notice_days ON contract TYPE int DEFAULT 30;
DEFINE FIELD status ON contract TYPE string 
    ASSERT $value IN ['draft', 'under_negotiation', 'pending_approval', 'approved', 'signed', 'active', 'expired', 'terminated', 'cancelled'];
DEFINE FIELD negotiation_status ON contract TYPE string 
    ASSERT $value IN ['not_started', 'in_progress', 'stalled', 'completed', 'failed'];
DEFINE FIELD approval_workflow ON contract TYPE option<record<contract_approval_workflow>>;
DEFINE FIELD selected_clauses ON contract TYPE array<record<contract_clause>>;
DEFINE FIELD custom_clauses ON contract TYPE array<object>;
DEFINE FIELD negotiation_notes ON contract TYPE array<object>;
DEFINE FIELD risk_assessment ON contract TYPE option<object>;
DEFINE FIELD ai_analysis ON contract TYPE option<object>;
DEFINE FIELD document_path ON contract TYPE option<string>;
DEFINE FIELD signed_document_path ON contract TYPE option<string>;
DEFINE FIELD digital_signatures ON contract TYPE array<object>;
DEFINE FIELD key_performance_indicators ON contract TYPE array<object>;
DEFINE FIELD renewal_conditions ON contract TYPE array<object>;
DEFINE FIELD termination_conditions ON contract TYPE array<object>;
DEFINE FIELD assigned_lawyer ON contract TYPE option<record<user>>;
DEFINE FIELD business_owner ON contract TYPE record<user>;
DEFINE FIELD stakeholders ON contract TYPE array<record<user>>;
DEFINE FIELD next_milestone_date ON contract TYPE option<datetime>;
DEFINE FIELD next_renewal_check ON contract TYPE option<datetime>;
DEFINE FIELD confidentiality_level ON contract TYPE string 
    ASSERT $value IN ['public', 'internal', 'confidential', 'restricted'];
DEFINE FIELD tags ON contract TYPE array<string>;
DEFINE FIELD is_active ON contract TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_id ON contract COLUMNS contract_id UNIQUE;
DEFINE INDEX idx_contract_company ON contract COLUMNS company;
DEFINE INDEX idx_contract_type ON contract COLUMNS contract_type;
DEFINE INDEX idx_contract_status ON contract COLUMNS status;
DEFINE INDEX idx_contract_counterparty ON contract COLUMNS counterparty;
DEFINE INDEX idx_contract_dates ON contract COLUMNS start_date, end_date;
DEFINE INDEX idx_contract_lawyer ON contract COLUMNS assigned_lawyer;
DEFINE INDEX idx_contract_renewal ON contract COLUMNS next_renewal_check;
DEFINE INDEX idx_contract_active ON contract COLUMNS is_active;

-- ==============================================================================
-- TABLE : WORKFLOWS D'APPROBATION DE CONTRATS
-- ==============================================================================

DEFINE TABLE contract_approval_workflow SCHEMAFULL;
DEFINE FIELD workflow_id ON contract_approval_workflow TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON contract_approval_workflow TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON contract_approval_workflow TYPE string;
DEFINE FIELD applicable_contract_types ON contract_approval_workflow TYPE array<record<contract_type>>;
DEFINE FIELD value_threshold_min ON contract_approval_workflow TYPE option<decimal>;
DEFINE FIELD value_threshold_max ON contract_approval_workflow TYPE option<decimal>;
DEFINE FIELD approval_steps ON contract_approval_workflow TYPE array<object>;
DEFINE FIELD parallel_approvals_allowed ON contract_approval_workflow TYPE bool DEFAULT false;
DEFINE FIELD escalation_rules ON contract_approval_workflow TYPE array<object>;
DEFINE FIELD sla_hours ON contract_approval_workflow TYPE int DEFAULT 72;
DEFINE FIELD auto_approval_conditions ON contract_approval_workflow TYPE array<object>;
DEFINE FIELD required_documents ON contract_approval_workflow TYPE array<string>;
DEFINE FIELD notification_templates ON contract_approval_workflow TYPE array<object>;
DEFINE FIELD is_active ON contract_approval_workflow TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_approval_workflow TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_approval_workflow TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_approval_workflow TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract_approval_workflow TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_approval_workflow_id ON contract_approval_workflow COLUMNS workflow_id UNIQUE;
DEFINE INDEX idx_contract_approval_workflow_active ON contract_approval_workflow COLUMNS is_active;

-- ==============================================================================
-- TABLE : INSTANCES D'APPROBATION DE CONTRATS
-- ==============================================================================

DEFINE TABLE contract_approval_instance SCHEMAFULL;
DEFINE FIELD instance_id ON contract_approval_instance TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD contract ON contract_approval_instance TYPE record<contract>;
DEFINE FIELD workflow ON contract_approval_instance TYPE record<contract_approval_workflow>;
DEFINE FIELD company ON contract_approval_instance TYPE record<company>;
DEFINE FIELD current_step ON contract_approval_instance TYPE int DEFAULT 1;
DEFINE FIELD total_steps ON contract_approval_instance TYPE int;
DEFINE FIELD status ON contract_approval_instance TYPE string 
    ASSERT $value IN ['pending', 'in_progress', 'approved', 'rejected', 'escalated', 'cancelled'];
DEFINE FIELD started_on ON contract_approval_instance TYPE datetime DEFAULT time::now();
DEFINE FIELD completed_on ON contract_approval_instance TYPE option<datetime>;
DEFINE FIELD approval_steps_log ON contract_approval_instance TYPE array<object>;
DEFINE FIELD current_approvers ON contract_approval_instance TYPE array<record<user>>;
DEFINE FIELD rejection_reason ON contract_approval_instance TYPE option<string>;
DEFINE FIELD escalation_reason ON contract_approval_instance TYPE option<string>;
DEFINE FIELD comments ON contract_approval_instance TYPE array<object>;
DEFINE FIELD deadline ON contract_approval_instance TYPE datetime;
DEFINE FIELD is_active ON contract_approval_instance TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_approval_instance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_approval_instance TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_contract_approval_instance_id ON contract_approval_instance COLUMNS instance_id UNIQUE;
DEFINE INDEX idx_contract_approval_instance_contract ON contract_approval_instance COLUMNS contract;
DEFINE INDEX idx_contract_approval_instance_status ON contract_approval_instance COLUMNS status;
DEFINE INDEX idx_contract_approval_instance_deadline ON contract_approval_instance COLUMNS deadline;

-- ==============================================================================
-- TABLE : NÉGOCIATIONS DE CONTRATS
-- ==============================================================================

DEFINE TABLE contract_negotiation SCHEMAFULL;
DEFINE FIELD negotiation_id ON contract_negotiation TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD contract ON contract_negotiation TYPE record<contract>;
DEFINE FIELD company ON contract_negotiation TYPE record<company>;
DEFINE FIELD negotiation_round ON contract_negotiation TYPE int DEFAULT 1;
DEFINE FIELD status ON contract_negotiation TYPE string 
    ASSERT $value IN ['active', 'paused', 'completed', 'failed', 'cancelled'];
DEFINE FIELD lead_negotiator ON contract_negotiation TYPE record<user>;
DEFINE FIELD negotiation_team ON contract_negotiation TYPE array<record<user>>;
DEFINE FIELD counterparty_contacts ON contract_negotiation TYPE array<object>;
DEFINE FIELD negotiation_strategy ON contract_negotiation TYPE object;
DEFINE FIELD key_terms_under_negotiation ON contract_negotiation TYPE array<object>;
DEFINE FIELD concessions_made ON contract_negotiation TYPE array<object>;
DEFINE FIELD concessions_received ON contract_negotiation TYPE array<object>;
DEFINE FIELD negotiation_log ON contract_negotiation TYPE array<object>;
DEFINE FIELD ai_recommendations ON contract_negotiation TYPE array<object>;
DEFINE FIELD risk_assessment ON contract_negotiation TYPE object;
DEFINE FIELD benchmarking_data ON contract_negotiation TYPE array<object>;
DEFINE FIELD target_outcomes ON contract_negotiation TYPE array<object>;
DEFINE FIELD minimum_acceptable_terms ON contract_negotiation TYPE array<object>;
DEFINE FIELD dealbreakers ON contract_negotiation TYPE array<object>;
DEFINE FIELD meeting_notes ON contract_negotiation TYPE array<object>;
DEFINE FIELD next_meeting_date ON contract_negotiation TYPE option<datetime>;
DEFINE FIELD deadline ON contract_negotiation TYPE option<datetime>;
DEFINE FIELD success_probability ON contract_negotiation TYPE decimal DEFAULT 50.0;
DEFINE FIELD estimated_value_impact ON contract_negotiation TYPE option<decimal>;
DEFINE FIELD is_active ON contract_negotiation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_negotiation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_negotiation TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_negotiation TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract_negotiation TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_negotiation_id ON contract_negotiation COLUMNS negotiation_id UNIQUE;
DEFINE INDEX idx_contract_negotiation_contract ON contract_negotiation COLUMNS contract;
DEFINE INDEX idx_contract_negotiation_status ON contract_negotiation COLUMNS status;
DEFINE INDEX idx_contract_negotiation_lead ON contract_negotiation COLUMNS lead_negotiator;
DEFINE INDEX idx_contract_negotiation_deadline ON contract_negotiation COLUMNS deadline;

-- ==============================================================================
-- TABLE : ÉCHÉANCES ET RENOUVELLEMENTS
-- ==============================================================================

DEFINE TABLE contract_milestone SCHEMAFULL;
DEFINE FIELD milestone_id ON contract_milestone TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD contract ON contract_milestone TYPE record<contract>;
DEFINE FIELD company ON contract_milestone TYPE record<company>;
DEFINE FIELD milestone_type ON contract_milestone TYPE string 
    ASSERT $value IN ['renewal_notice', 'renewal_deadline', 'performance_review', 'payment_due', 'deliverable_due', 'termination_notice', 'custom'];
DEFINE FIELD title ON contract_milestone TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON contract_milestone TYPE string;
DEFINE FIELD due_date ON contract_milestone TYPE datetime;
DEFINE FIELD notification_days_before ON contract_milestone TYPE int DEFAULT 30;
DEFINE FIELD responsible_party ON contract_milestone TYPE string 
    ASSERT $value IN ['internal', 'counterparty', 'both'];
DEFINE FIELD assigned_to ON contract_milestone TYPE option<record<user>>;
DEFINE FIELD status ON contract_milestone TYPE string 
    ASSERT $value IN ['upcoming', 'due', 'completed', 'overdue', 'cancelled'];
DEFINE FIELD completion_date ON contract_milestone TYPE option<datetime>;
DEFINE FIELD completion_notes ON contract_milestone TYPE option<string>;
DEFINE FIELD impact_if_missed ON contract_milestone TYPE string 
    ASSERT $value IN ['low', 'medium', 'high', 'critical'];
DEFINE FIELD auto_actions ON contract_milestone TYPE array<object>;
DEFINE FIELD notification_sent ON contract_milestone TYPE bool DEFAULT false;
DEFINE FIELD escalation_triggered ON contract_milestone TYPE bool DEFAULT false;
DEFINE FIELD is_recurring ON contract_milestone TYPE bool DEFAULT false;
DEFINE FIELD recurrence_pattern ON contract_milestone TYPE option<object>;
DEFINE FIELD next_occurrence ON contract_milestone TYPE option<datetime>;
DEFINE FIELD is_active ON contract_milestone TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_milestone TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON contract_milestone TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_milestone TYPE option<record<user>>;
DEFINE FIELD updated_by ON contract_milestone TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_contract_milestone_id ON contract_milestone COLUMNS milestone_id UNIQUE;
DEFINE INDEX idx_contract_milestone_contract ON contract_milestone COLUMNS contract;
DEFINE INDEX idx_contract_milestone_type ON contract_milestone COLUMNS milestone_type;
DEFINE INDEX idx_contract_milestone_due_date ON contract_milestone COLUMNS due_date;
DEFINE INDEX idx_contract_milestone_status ON contract_milestone COLUMNS status;
DEFINE INDEX idx_contract_milestone_assigned ON contract_milestone COLUMNS assigned_to;

-- ==============================================================================
-- TABLE : ANALYSE DE RISQUES IA
-- ==============================================================================

DEFINE TABLE contract_ai_analysis SCHEMAFULL;
DEFINE FIELD analysis_id ON contract_ai_analysis TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD contract ON contract_ai_analysis TYPE record<contract>;
DEFINE FIELD company ON contract_ai_analysis TYPE record<company>;
DEFINE FIELD analysis_type ON contract_ai_analysis TYPE string 
    ASSERT $value IN ['risk_assessment', 'clause_review', 'compliance_check', 'benchmarking', 'negotiation_guidance'];
DEFINE FIELD ai_model_version ON contract_ai_analysis TYPE string;
DEFINE FIELD confidence_score ON contract_ai_analysis TYPE decimal;
DEFINE FIELD overall_risk_score ON contract_ai_analysis TYPE decimal;
DEFINE FIELD risk_factors ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD clause_recommendations ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD compliance_gaps ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD market_benchmarks ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD negotiation_opportunities ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD red_flags ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD improvement_suggestions ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD similar_contracts ON contract_ai_analysis TYPE array<object>;
DEFINE FIELD estimated_savings_potential ON contract_ai_analysis TYPE option<decimal>;
DEFINE FIELD processing_time_ms ON contract_ai_analysis TYPE int;
DEFINE FIELD analysis_date ON contract_ai_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD reviewed_by_human ON contract_ai_analysis TYPE bool DEFAULT false;
DEFINE FIELD human_reviewer ON contract_ai_analysis TYPE option<record<user>>;
DEFINE FIELD human_feedback ON contract_ai_analysis TYPE option<object>;
DEFINE FIELD is_active ON contract_ai_analysis TYPE bool DEFAULT true;
DEFINE FIELD created_on ON contract_ai_analysis TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_contract_ai_analysis_id ON contract_ai_analysis COLUMNS analysis_id UNIQUE;
DEFINE INDEX idx_contract_ai_analysis_contract ON contract_ai_analysis COLUMNS contract;
DEFINE INDEX idx_contract_ai_analysis_type ON contract_ai_analysis COLUMNS analysis_type;
DEFINE INDEX idx_contract_ai_analysis_date ON contract_ai_analysis COLUMNS analysis_date;
DEFINE INDEX idx_contract_ai_analysis_reviewed ON contract_ai_analysis COLUMNS reviewed_by_human;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour démarrer un workflow d'approbation
DEFINE FUNCTION start_contract_approval($contract_id: record<contract>) {
    LET $contract = SELECT * FROM contract WHERE id = $contract_id;
    LET $workflow = SELECT * FROM contract_approval_workflow 
        WHERE $contract.contract_type IN applicable_contract_types 
        AND (value_threshold_min IS NULL OR $contract.contract_value >= value_threshold_min)
        AND (value_threshold_max IS NULL OR $contract.contract_value <= value_threshold_max)
        AND is_active = true
        LIMIT 1;
    
    IF array::len($workflow) = 0 THEN
        RETURN { success: false, message: "Aucun workflow d'approbation trouvé" };
    END;
    
    LET $instance_id = "APPR-" + string::slice(rand::uuid(), 0, 8);
    LET $deadline = time::now() + duration::from_hours($workflow[0].sla_hours);
    
    LET $instance = CREATE contract_approval_instance CONTENT {
        instance_id: $instance_id,
        contract: $contract_id,
        workflow: $workflow[0].id,
        company: $contract.company,
        total_steps: array::len($workflow[0].approval_steps),
        deadline: $deadline,
        approval_steps_log: [],
        current_approvers: $workflow[0].approval_steps[0].approvers,
        created_on: time::now()
    };
    
    -- Mise à jour du contrat
    UPDATE contract SET 
        status = "pending_approval",
        approval_workflow = $instance.id,
        updated_on = time::now()
    WHERE id = $contract_id;
    
    RETURN {
        success: true,
        instance_id: $instance_id,
        deadline: $deadline,
        current_approvers: $workflow[0].approval_steps[0].approvers
    };
};

-- Fonction pour analyser un contrat avec l'IA
DEFINE FUNCTION analyze_contract_with_ai($contract_id: record<contract>, $analysis_type: string) {
    LET $contract = SELECT * FROM contract WHERE id = $contract_id;
    LET $analysis_id = "AI-" + string::slice(rand::uuid(), 0, 8);
    
    -- Simulation d'analyse IA
    LET $start_time = time::now();
    
    LET $risk_score = rand::float() * 100;
    LET $confidence = 85.0 + (rand::float() * 15);
    
    LET $risk_factors = [
        {
            factor: "Clause de résiliation",
            severity: "medium",
            description: "Conditions de résiliation asymétriques",
            recommendation: "Négocier des conditions plus équilibrées"
        },
        {
            factor: "Limitation de responsabilité",
            severity: "low",
            description: "Plafond de responsabilité acceptable",
            recommendation: "Clause conforme aux standards du marché"
        }
    ];
    
    LET $processing_time = math::round((time::unix(time::now()) - time::unix($start_time)) * 1000);
    
    LET $analysis = CREATE contract_ai_analysis CONTENT {
        analysis_id: $analysis_id,
        contract: $contract_id,
        company: $contract.company,
        analysis_type: $analysis_type,
        ai_model_version: "LYXAL-Contract-AI-v2.1",
        confidence_score: $confidence,
        overall_risk_score: $risk_score,
        risk_factors: $risk_factors,
        clause_recommendations: [
            {
                clause_type: "force_majeure",
                recommendation: "Ajouter une clause de force majeure étendue",
                priority: "medium"
            }
        ],
        processing_time_ms: $processing_time,
        analysis_date: time::now(),
        created_on: time::now()
    };
    
    RETURN {
        analysis_id: $analysis_id,
        risk_score: $risk_score,
        confidence: $confidence,
        processing_time_ms: $processing_time
    };
};

-- Fonction pour générer des recommandations de négociation
DEFINE FUNCTION generate_negotiation_recommendations($contract_id: record<contract>) {
    LET $contract = SELECT * FROM contract WHERE id = $contract_id;
    
    -- Recherche de contrats similaires
    LET $similar_contracts = SELECT * FROM contract 
        WHERE contract_type = $contract.contract_type 
        AND company = $contract.company 
        AND status = "active"
        AND id != $contract_id
        LIMIT 5;
    
    LET $recommendations = [
        {
            area: "pricing",
            recommendation: "Négocier une clause d'indexation sur l'inflation",
            impact: "high",
            savings_potential: 15000,
            precedent: "Contrat similaire 2023"
        },
        {
            area: "termination",
            recommendation: "Réduire le préavis de résiliation à 3 mois",
            impact: "medium",
            flexibility_gain: "Meilleure agilité contractuelle"
        }
    ];
    
    RETURN {
        contract_id: $contract_id,
        recommendations: $recommendations,
        similar_contracts_count: array::len($similar_contracts),
        confidence: 80.0
    };
};

-- Fonction pour vérifier les échéances de renouvellement
DEFINE FUNCTION check_contract_renewals($days_ahead: int) {
    LET $upcoming_renewals = SELECT * FROM contract_milestone 
        WHERE milestone_type = "renewal_deadline"
        AND due_date BETWEEN time::now() AND (time::now() + duration::from_days($days_ahead))
        AND status = "upcoming"
        AND is_active = true;
    
    LET $notifications = [];
    
    FOR $milestone IN $upcoming_renewals {
        LET $days_remaining = math::floor((time::unix($milestone.due_date) - time::unix(time::now())) / 86400);
        
        IF $days_remaining <= $milestone.notification_days_before AND NOT $milestone.notification_sent THEN
            LET $notification = {
                milestone_id: $milestone.milestone_id,
                contract_id: $milestone.contract,
                days_remaining: $days_remaining,
                action_required: "Préparer le renouvellement",
                assigned_to: $milestone.assigned_to
            };
            
            $notifications = array::push($notifications, $notification);
            
            -- Marquer la notification comme envoyée
            UPDATE contract_milestone SET 
                notification_sent = true,
                updated_on = time::now()
            WHERE id = $milestone.id;
        END;
    }
    
    RETURN $notifications;
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des contrats actifs avec échéances
DEFINE TABLE active_contracts_with_renewals AS SELECT 
    contract.*,
    contract_type.name AS contract_type_name,
    company.name AS company_name,
    contract_milestone.due_date AS next_renewal_date,
    (contract_milestone.due_date - time::now()) AS days_until_renewal
FROM contract 
INNER JOIN contract_type ON contract.contract_type = contract_type.id
INNER JOIN company ON contract.company = company.id
LEFT JOIN contract_milestone ON contract.id = contract_milestone.contract 
    AND contract_milestone.milestone_type = "renewal_deadline" 
    AND contract_milestone.status = "upcoming"
WHERE contract.status = "active" 
AND contract.is_active = true
ORDER BY contract_milestone.due_date ASC;

-- Vue des contrats en négociation
DEFINE TABLE contracts_under_negotiation AS SELECT 
    contract.*,
    contract_type.name AS contract_type_name,
    contract_negotiation.negotiation_round,
    contract_negotiation.success_probability,
    contract_negotiation.lead_negotiator AS negotiator_id,
    contract_negotiation.next_meeting_date,
    contract_negotiation.deadline AS negotiation_deadline
FROM contract 
INNER JOIN contract_type ON contract.contract_type = contract_type.id
INNER JOIN contract_negotiation ON contract.id = contract_negotiation.contract
WHERE contract.negotiation_status = "in_progress" 
AND contract_negotiation.status = "active"
AND contract.is_active = true
ORDER BY contract_negotiation.deadline ASC;

-- Vue des approbations en attente
DEFINE TABLE pending_contract_approvals AS SELECT 
    contract.*,
    contract_type.name AS contract_type_name,
    contract_approval_instance.current_step,
    contract_approval_instance.total_steps,
    contract_approval_instance.deadline AS approval_deadline,
    contract_approval_instance.current_approvers,
    (contract_approval_instance.deadline - time::now()) AS time_remaining
FROM contract 
INNER JOIN contract_type ON contract.contract_type = contract_type.id
INNER JOIN contract_approval_instance ON contract.id = contract_approval_instance.contract
WHERE contract.status = "pending_approval" 
AND contract_approval_instance.status = "pending"
AND contract.is_active = true
ORDER BY contract_approval_instance.deadline ASC;

-- Vue des analyses IA récentes
DEFINE TABLE recent_contract_ai_analyses AS SELECT 
    contract_ai_analysis.*,
    contract.title AS contract_title,
    contract.counterparty,
    company.name AS company_name
FROM contract_ai_analysis 
INNER JOIN contract ON contract_ai_analysis.contract = contract.id
INNER JOIN company ON contract_ai_analysis.company = company.id
WHERE contract_ai_analysis.analysis_date > (time::now() - duration::from_days(30))
AND contract_ai_analysis.is_active = true
ORDER BY contract_ai_analysis.analysis_date DESC;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TYPES DE CONTRATS
-- ==============================================================================

-- Contrat commercial
CREATE contract_type:commercial_sales CONTENT {
    type_id: "COMMERCIAL_SALES",
    name: "Contrat de vente commercial",
    description: "Contrat de vente de biens ou services à des entreprises",
    category: "commercial",
    complexity_level: "medium",
    typical_duration_months: 12,
    renewable: true,
    required_approvals: ["legal_review", "commercial_director"],
    mandatory_clauses: ["payment_terms", "delivery_terms", "warranties"],
    risk_level: "medium",
    template_available: true,
    auto_renewal_possible: true,
    notification_days_before_expiry: 60,
    regulatory_requirements: ["code_commerce", "cgv_obligatoires"],
    is_active: true,
    created_on: time::now()
};

-- Contrat d'emploi
CREATE contract_type:employment_cdi CONTENT {
    type_id: "EMPLOYMENT_CDI",
    name: "Contrat de travail CDI",
    description: "Contrat de travail à durée indéterminée",
    category: "employment",
    complexity_level: "medium",
    renewable: false,
    required_approvals: ["hr_director", "legal_review"],
    mandatory_clauses: ["remuneration", "working_time", "confidentiality"],
    risk_level: "high",
    template_available: true,
    auto_renewal_possible: false,
    regulatory_requirements: ["code_travail", "convention_collective"],
    is_active: true,
    created_on: time::now()
};

-- Contrat de service
CREATE contract_type:service_agreement CONTENT {
    type_id: "SERVICE_AGREEMENT",
    name: "Contrat de prestation de services",
    description: "Contrat pour la fourniture de services professionnels",
    category: "service",
    complexity_level: "simple",
    typical_duration_months: 6,
    renewable: true,
    required_approvals: ["service_manager"],
    mandatory_clauses: ["scope_of_work", "service_levels", "payment_terms"],
    risk_level: "low",
    template_available: true,
    auto_renewal_possible: true,
    notification_days_before_expiry: 30,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CLAUSES STANDARDS
-- ==============================================================================

-- Clause de paiement
CREATE contract_clause:payment_30_days CONTENT {
    clause_id: "PAYMENT_30_DAYS",
    name: "Paiement à 30 jours",
    description: "Clause de paiement standard à 30 jours fin de mois",
    clause_type: "mandatory",
    category: "payment",
    legal_text_fr: "Le règlement des factures s'effectue à {{payment_days}} jours fin de mois suivant la date de facturation, sans escompte. Tout retard de paiement entraînera de plein droit l'application d'intérêts de retard au taux de {{late_interest_rate}}% par mois commencé.",
    legal_text_en: "Payment of invoices is due within {{payment_days}} days from the end of the month following the invoice date, without discount. Any delay in payment will automatically result in late payment interest at a rate of {{late_interest_rate}}% per month started.",
    variables: [
        {
            name: "payment_days",
            type: "integer",
            default_value: 30,
            description: "Nombre de jours pour le paiement"
        },
        {
            name: "late_interest_rate",
            type: "decimal",
            default_value: 1.5,
            description: "Taux d'intérêt de retard mensuel"
        }
    ],
    applicable_contract_types: [contract_type:commercial_sales, contract_type:service_agreement],
    risk_mitigation: ["Taux d'intérêt dissuasif", "Délai raisonnable"],
    negotiation_flexibility: "flexible",
    approved_by_legal: true,
    approval_date: time::now(),
    is_active: true,
    created_on: time::now()
};

-- Clause de confidentialité
CREATE contract_clause:confidentiality_standard CONTENT {
    clause_id: "CONFIDENTIALITY_STANDARD",
    name: "Clause de confidentialité standard",
    description: "Clause de confidentialité pour protection des informations sensibles",
    clause_type: "mandatory",
    category: "confidentiality",
    legal_text_fr: "Chaque partie s'engage à maintenir strictement confidentielles toutes les informations confidentielles communiquées par l'autre partie, pendant la durée du contrat et pendant une période de {{confidentiality_duration}} années après son expiration. Sont considérées comme confidentielles toutes informations techniques, commerciales, financières ou stratégiques.",
    variables: [
        {
            name: "confidentiality_duration",
            type: "integer",
            default_value: 5,
            description: "Durée de confidentialité en années"
        }
    ],
    applicable_contract_types: [contract_type:employment_cdi, contract_type:service_agreement],
    risk_mitigation: ["Protection propriété intellectuelle", "Prévention fuite d'informations"],
    negotiation_flexibility: "limited",
    approved_by_legal: true,
    approval_date: time::now(),
    is_active: true,
    created_on: time::now()
};

-- Clause de force majeure
CREATE contract_clause:force_majeure CONTENT {
    clause_id: "FORCE_MAJEURE",
    name: "Clause de force majeure",
    description: "Clause de suspension des obligations en cas de force majeure",
    clause_type: "optional",
    category: "force_majeure",
    legal_text_fr: "Aucune des parties ne sera tenue pour responsable de tout manquement à ses obligations contractuelles résultant d'un cas de force majeure tel que défini par la jurisprudence française, incluant notamment les catastrophes naturelles, guerres, grèves, pandémies, décisions gouvernementales imprévisibles. La partie affectée devra notifier l'autre partie dans un délai de {{notification_days}} jours.",
    variables: [
        {
            name: "notification_days",
            type: "integer",
            default_value: 15,
            description: "Délai de notification en jours"
        }
    ],
    applicable_contract_types: [contract_type:commercial_sales, contract_type:service_agreement],
    risk_mitigation: ["Protection contre événements imprévisibles", "Suspension légale des obligations"],
    negotiation_flexibility: "flexible",
    ai_recommendations: [
        {
            recommendation: "Inclure les pandémies dans la définition",
            context: "Post-COVID adaptation",
            priority: "high"
        }
    ],
    approved_by_legal: true,
    approval_date: time::now(),
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : WORKFLOWS D'APPROBATION
-- ==============================================================================

-- Workflow pour contrats de faible valeur
CREATE contract_approval_workflow:low_value_workflow CONTENT {
    workflow_id: "LOW_VALUE_WORKFLOW",
    name: "Workflow contrats faible valeur",
    description: "Processus d'approbation simplifié pour contrats < 50K€",
    applicable_contract_types: [contract_type:service_agreement],
    value_threshold_max: 50000.0,
    approval_steps: [
        {
            step_number: 1,
            step_name: "Validation métier",
            approvers: ["business_manager"],
            required_approval_count: 1,
            can_delegate: true
        },
        {
            step_number: 2,
            step_name: "Validation juridique",
            approvers: ["legal_counsel"],
            required_approval_count: 1,
            can_delegate: false
        }
    ],
    parallel_approvals_allowed: false,
    escalation_rules: [
        {
            trigger: "sla_exceeded",
            escalate_to: ["legal_director"],
            escalation_delay_hours: 72
        }
    ],
    sla_hours: 48,
    auto_approval_conditions: [
        {
            condition: "template_contract_and_value_under_10k",
            auto_approve: true
        }
    ],
    required_documents: ["contract_draft", "business_justification"],
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DU MODULE CONTRATS :

1. TYPES DE CONTRATS (contract_type)
   - Classification complète par catégorie
   - Niveaux de complexité et de risque
   - Templates et renouvellements automatiques

2. CLAUSES STANDARDS (contract_clause)
   - Bibliothèque réutilisable de clauses
   - Variables et personnalisation
   - Approbation juridique et recommandations IA

3. CONTRATS (contract)
   - Gestion complète du cycle de vie
   - Statuts et workflows d'approbation
   - Suivi des échéances et renouvellements

4. WORKFLOWS D'APPROBATION (contract_approval_workflow)
   - Circuits de validation personnalisables
   - Seuils de valeur et escalade
   - SLA et notifications automatiques

5. NÉGOCIATIONS (contract_negotiation)
   - Gestion des rounds de négociation
   - Stratégies et recommandations IA
   - Suivi des concessions et résultats

6. ÉCHÉANCES (contract_milestone)
   - Renouvellements automatiques
   - Notifications et escalades
   - Actions automatisées

7. ANALYSE IA (contract_ai_analysis)
   - Évaluation des risques
   - Recommandations de clauses
   - Benchmarking et optimisation

UTILISATION :
- Gestion end-to-end des contrats
- Automatisation des workflows
- IA contractuelle et analyse de risques
- Négociation assistée
- Suivi des échéances et renouvellements
- Conformité et optimisation
*/ 