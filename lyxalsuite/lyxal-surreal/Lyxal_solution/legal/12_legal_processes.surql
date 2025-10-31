-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : PROCESSUS JURIDIQUES
-- ==============================================================================
-- Fichier : 06_legal_processes.surql
-- Description : Workflows juridiques, procédures, échéances et notifications
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : TYPES DE PROCESSUS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_process_type SCHEMAFULL;
DEFINE FIELD code ON legal_process_type TYPE string;
DEFINE FIELD name ON legal_process_type TYPE string;
DEFINE FIELD description ON legal_process_type TYPE string;
DEFINE FIELD category ON legal_process_type TYPE string;
DEFINE FIELD priority ON legal_process_type TYPE string;
DEFINE FIELD typical_duration_days ON legal_process_type TYPE option<int>;
DEFINE FIELD required_roles ON legal_process_type TYPE array<string>;
DEFINE FIELD is_active ON legal_process_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_process_type TYPE datetime DEFAULT time::now();

-- ==============================================================================
-- TABLE : PROCESSUS JURIDIQUES
-- ==============================================================================

DEFINE TABLE legal_process SCHEMAFULL;
DEFINE FIELD process_id ON legal_process TYPE string;
DEFINE FIELD name ON legal_process TYPE string;
DEFINE FIELD description ON legal_process TYPE string;
DEFINE FIELD process_type ON legal_process TYPE record<legal_process_type>;
DEFINE FIELD company ON legal_process TYPE record<company>;
DEFINE FIELD initiator ON legal_process TYPE record<user>;
DEFINE FIELD start_date ON legal_process TYPE datetime;
DEFINE FIELD target_completion_date ON legal_process TYPE datetime;
DEFINE FIELD status ON legal_process TYPE string;
DEFINE FIELD progress_percentage ON legal_process TYPE decimal DEFAULT 0.0;
DEFINE FIELD priority ON legal_process TYPE string;
DEFINE FIELD is_active ON legal_process TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_process TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_legal_process_id ON legal_process COLUMNS process_id UNIQUE;
DEFINE INDEX idx_legal_process_company ON legal_process COLUMNS company;
DEFINE INDEX idx_legal_process_status ON legal_process COLUMNS status;

-- ==============================================================================
-- TABLE : ÉTAPES DE PROCESSUS
-- ==============================================================================

DEFINE TABLE legal_process_stage SCHEMAFULL;
DEFINE FIELD stage_id ON legal_process_stage TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD process ON legal_process_stage TYPE record<legal_process>;
DEFINE FIELD name ON legal_process_stage TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_process_stage TYPE string;
DEFINE FIELD order_sequence ON legal_process_stage TYPE int;
DEFINE FIELD stage_type ON legal_process_stage TYPE string 
    ASSERT $value IN ['preparation', 'review', 'approval', 'execution', 'monitoring', 'completion'];
DEFINE FIELD required_actions ON legal_process_stage TYPE array<string>;
DEFINE FIELD required_documents ON legal_process_stage TYPE array<string>;
DEFINE FIELD required_approvals ON legal_process_stage TYPE array<object>;
DEFINE FIELD assigned_users ON legal_process_stage TYPE array<record<user>>;
DEFINE FIELD estimated_duration_days ON legal_process_stage TYPE option<int>;
DEFINE FIELD actual_duration_days ON legal_process_stage TYPE option<int>;
DEFINE FIELD start_date ON legal_process_stage TYPE option<datetime>;
DEFINE FIELD target_completion_date ON legal_process_stage TYPE option<datetime>;
DEFINE FIELD actual_completion_date ON legal_process_stage TYPE option<datetime>;
DEFINE FIELD status ON legal_process_stage TYPE string 
    ASSERT $value IN ['not_started', 'in_progress', 'pending_approval', 'completed', 'blocked', 'skipped'];
DEFINE FIELD completion_percentage ON legal_process_stage TYPE decimal DEFAULT 0.0;
DEFINE FIELD dependencies ON legal_process_stage TYPE array<record<legal_process_stage>>;
DEFINE FIELD blocking_issues ON legal_process_stage TYPE array<object>;
DEFINE FIELD deliverables ON legal_process_stage TYPE array<object>;
DEFINE FIELD quality_checks ON legal_process_stage TYPE array<object>;
DEFINE FIELD comments ON legal_process_stage TYPE option<string>;
DEFINE FIELD is_mandatory ON legal_process_stage TYPE bool DEFAULT true;
DEFINE FIELD is_active ON legal_process_stage TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_process_stage TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_process_stage TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_process_stage TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_process_stage TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_process_stage_id ON legal_process_stage COLUMNS stage_id UNIQUE;
DEFINE INDEX idx_legal_process_stage_process ON legal_process_stage COLUMNS process;
DEFINE INDEX idx_legal_process_stage_order ON legal_process_stage COLUMNS order_sequence;
DEFINE INDEX idx_legal_process_stage_status ON legal_process_stage COLUMNS status;
DEFINE INDEX idx_legal_process_stage_dates ON legal_process_stage COLUMNS start_date, target_completion_date;
DEFINE INDEX idx_legal_process_stage_active ON legal_process_stage COLUMNS is_active;

-- ==============================================================================
-- TABLE : ÉCHÉANCES LÉGALES
-- ==============================================================================

DEFINE TABLE legal_deadline SCHEMAFULL;
DEFINE FIELD deadline_id ON legal_deadline TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON legal_deadline TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_deadline TYPE string;
DEFINE FIELD deadline_type ON legal_deadline TYPE string 
    ASSERT $value IN ['regulatory', 'contractual', 'judicial', 'statutory', 'internal'];
DEFINE FIELD company ON legal_deadline TYPE record<company>;
DEFINE FIELD related_process ON legal_deadline TYPE option<record<legal_process>>;
DEFINE FIELD related_document ON legal_deadline TYPE option<record<legal_document>>;
DEFINE FIELD related_regulation ON legal_deadline TYPE option<record<regulation>>;
DEFINE FIELD due_date ON legal_deadline TYPE datetime;
DEFINE FIELD calculation_basis ON legal_deadline TYPE option<object>;
DEFINE FIELD is_recurring ON legal_deadline TYPE bool DEFAULT false;
DEFINE FIELD recurrence_pattern ON legal_deadline TYPE option<object>;
DEFINE FIELD next_occurrence ON legal_deadline TYPE option<datetime>;
DEFINE FIELD priority ON legal_deadline TYPE string 
    ASSERT $value IN ['critical', 'high', 'medium', 'low'];
DEFINE FIELD consequences ON legal_deadline TYPE array<string>;
DEFINE FIELD responsible_person ON legal_deadline TYPE record<user>;
DEFINE FIELD backup_person ON legal_deadline TYPE option<record<user>>;
DEFINE FIELD notification_schedule ON legal_deadline TYPE array<object>;
DEFINE FIELD completion_status ON legal_deadline TYPE string 
    ASSERT $value IN ['pending', 'in_progress', 'completed', 'missed', 'waived', 'extended'];
DEFINE FIELD completion_date ON legal_deadline TYPE option<datetime>;
DEFINE FIELD completion_notes ON legal_deadline TYPE option<string>;
DEFINE FIELD extension_granted ON legal_deadline TYPE option<datetime>;
DEFINE FIELD extension_reason ON legal_deadline TYPE option<string>;
DEFINE FIELD missed_action_taken ON legal_deadline TYPE option<string>;
DEFINE FIELD cost_of_delay ON legal_deadline TYPE option<decimal>;
DEFINE FIELD is_active ON legal_deadline TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_deadline TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_deadline TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_deadline TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_deadline TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_deadline_id ON legal_deadline COLUMNS deadline_id UNIQUE;
DEFINE INDEX idx_legal_deadline_company ON legal_deadline COLUMNS company;
DEFINE INDEX idx_legal_deadline_type ON legal_deadline COLUMNS deadline_type;
DEFINE INDEX idx_legal_deadline_due_date ON legal_deadline COLUMNS due_date;
DEFINE INDEX idx_legal_deadline_priority ON legal_deadline COLUMNS priority;
DEFINE INDEX idx_legal_deadline_status ON legal_deadline COLUMNS completion_status;
DEFINE INDEX idx_legal_deadline_responsible ON legal_deadline COLUMNS responsible_person;
DEFINE INDEX idx_legal_deadline_active ON legal_deadline COLUMNS is_active;

-- ==============================================================================
-- TABLE : NOTIFICATIONS LÉGALES
-- ==============================================================================

DEFINE TABLE legal_notification SCHEMAFULL;
DEFINE FIELD notification_id ON legal_notification TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON legal_notification TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD message ON legal_notification TYPE string;
DEFINE FIELD notification_type ON legal_notification TYPE string 
    ASSERT $value IN ['deadline_reminder', 'process_update', 'document_expiry', 'compliance_alert', 'escalation', 'approval_request'];
DEFINE FIELD priority ON legal_notification TYPE string 
    ASSERT $value IN ['urgent', 'high', 'normal', 'low'];
DEFINE FIELD company ON legal_notification TYPE record<company>;
DEFINE FIELD related_process ON legal_notification TYPE option<record<legal_process>>;
DEFINE FIELD related_deadline ON legal_notification TYPE option<record<legal_deadline>>;
DEFINE FIELD related_document ON legal_notification TYPE option<record<legal_document>>;
DEFINE FIELD recipients ON legal_notification TYPE array<record<user>>;
DEFINE FIELD recipient_roles ON legal_notification TYPE array<string>;
DEFINE FIELD sender ON legal_notification TYPE record<user>;
DEFINE FIELD scheduled_date ON legal_notification TYPE datetime;
DEFINE FIELD sent_date ON legal_notification TYPE option<datetime>;
DEFINE FIELD delivery_method ON legal_notification TYPE array<string> 
    ASSERT array::all($value, $item IN ['email', 'sms', 'push', 'dashboard', 'webhook']);
DEFINE FIELD read_status ON legal_notification TYPE object;
DEFINE FIELD response_required ON legal_notification TYPE bool DEFAULT false;
DEFINE FIELD response_deadline ON legal_notification TYPE option<datetime>;
DEFINE FIELD responses ON legal_notification TYPE array<object>;
DEFINE FIELD escalation_rules ON legal_notification TYPE array<object>;
DEFINE FIELD status ON legal_notification TYPE string 
    ASSERT $value IN ['scheduled', 'sent', 'delivered', 'read', 'responded', 'failed', 'cancelled'];
DEFINE FIELD retry_count ON legal_notification TYPE int DEFAULT 0;
DEFINE FIELD max_retries ON legal_notification TYPE int DEFAULT 3;
DEFINE FIELD template_used ON legal_notification TYPE option<string>;
DEFINE FIELD is_active ON legal_notification TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_notification TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_notification TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_notification_id ON legal_notification COLUMNS notification_id UNIQUE;
DEFINE INDEX idx_legal_notification_company ON legal_notification COLUMNS company;
DEFINE FIELD type_priority ON legal_notification COLUMNS notification_type, priority;
DEFINE INDEX idx_legal_notification_scheduled ON legal_notification COLUMNS scheduled_date;
DEFINE INDEX idx_legal_notification_status ON legal_notification COLUMNS status;
DEFINE INDEX idx_legal_notification_active ON legal_notification COLUMNS is_active;

-- ==============================================================================
-- TABLE : APPROBATIONS LÉGALES
-- ==============================================================================

DEFINE TABLE legal_approval SCHEMAFULL;
DEFINE FIELD approval_id ON legal_approval TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON legal_approval TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_approval TYPE string;
DEFINE FIELD approval_type ON legal_approval TYPE string 
    ASSERT $value IN ['document_approval', 'process_approval', 'budget_approval', 'strategy_approval', 'settlement_approval'];
DEFINE FIELD company ON legal_approval TYPE record<company>;
DEFINE FIELD related_process ON legal_approval TYPE option<record<legal_process>>;
DEFINE FIELD related_document ON legal_approval TYPE option<record<legal_document>>;
DEFINE FIELD requester ON legal_approval TYPE record<user>;
DEFINE FIELD approver ON legal_approval TYPE record<user>;
DEFINE FIELD approval_level ON legal_approval TYPE string 
    ASSERT $value IN ['level_1', 'level_2', 'level_3', 'board_level', 'external'];
DEFINE FIELD delegation_chain ON legal_approval TYPE array<object>;
DEFINE FIELD requested_date ON legal_approval TYPE datetime;
DEFINE FIELD due_date ON legal_approval TYPE datetime;
DEFINE FIELD approval_date ON legal_approval TYPE option<datetime>;
DEFINE FIELD status ON legal_approval TYPE string 
    ASSERT $value IN ['pending', 'approved', 'rejected', 'conditional', 'escalated', 'expired'];
DEFINE FIELD decision_notes ON legal_approval TYPE option<string>;
DEFINE FIELD conditions ON legal_approval TYPE array<string>;
DEFINE FIELD rejection_reason ON legal_approval TYPE option<string>;
DEFINE FIELD escalation_reason ON legal_approval TYPE option<string>;
DEFINE FIELD approval_authority ON legal_approval TYPE object;
DEFINE FIELD digital_signature ON legal_approval TYPE option<object>;
DEFINE FIELD audit_trail ON legal_approval TYPE array<object>;
DEFINE FIELD is_active ON legal_approval TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_approval TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_approval TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_approval TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_approval TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_approval_id ON legal_approval COLUMNS approval_id UNIQUE;
DEFINE INDEX idx_legal_approval_company ON legal_approval COLUMNS company;
DEFINE INDEX idx_legal_approval_type ON legal_approval COLUMNS approval_type;
DEFINE INDEX idx_legal_approval_status ON legal_approval COLUMNS status;
DEFINE INDEX idx_legal_approval_approver ON legal_approval COLUMNS approver;
DEFINE INDEX idx_legal_approval_dates ON legal_approval COLUMNS requested_date, due_date;
DEFINE INDEX idx_legal_approval_active ON legal_approval COLUMNS is_active;

-- ==============================================================================
-- TABLE : ACTIONS LÉGALES
-- ==============================================================================

DEFINE TABLE legal_action SCHEMAFULL;
DEFINE FIELD action_id ON legal_action TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD title ON legal_action TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON legal_action TYPE string;
DEFINE FIELD action_type ON legal_action TYPE string 
    ASSERT $value IN ['task', 'milestone', 'decision', 'filing', 'communication', 'research', 'negotiation'];
DEFINE FIELD company ON legal_action TYPE record<company>;
DEFINE FIELD related_process ON legal_action TYPE option<record<legal_process>>;
DEFINE FIELD related_stage ON legal_action TYPE option<record<legal_process_stage>>;
DEFINE FIELD assigned_to ON legal_action TYPE record<user>;
DEFINE FIELD delegated_to ON legal_action TYPE option<record<user>>;
DEFINE FIELD priority ON legal_action TYPE string 
    ASSERT $value IN ['urgent', 'high', 'normal', 'low'];
DEFINE FIELD due_date ON legal_action TYPE datetime;
DEFINE FIELD estimated_hours ON legal_action TYPE option<decimal>;
DEFINE FIELD actual_hours ON legal_action TYPE decimal DEFAULT 0.0;
DEFINE FIELD billable_hours ON legal_action TYPE decimal DEFAULT 0.0;
DEFINE FIELD hourly_rate ON legal_action TYPE option<decimal>;
DEFINE FIELD cost ON legal_action TYPE decimal DEFAULT 0.0;
DEFINE FIELD status ON legal_action TYPE string 
    ASSERT $value IN ['not_started', 'in_progress', 'pending_review', 'completed', 'cancelled', 'on_hold'];
DEFINE FIELD completion_percentage ON legal_action TYPE decimal DEFAULT 0.0;
DEFINE FIELD completion_date ON legal_action TYPE option<datetime>;
DEFINE FIELD deliverables ON legal_action TYPE array<object>;
DEFINE FIELD dependencies ON legal_action TYPE array<record<legal_action>>;
DEFINE FIELD blockers ON legal_action TYPE array<object>;
DEFINE FIELD time_entries ON legal_action TYPE array<object>;
DEFINE FIELD comments ON legal_action TYPE array<object>;
DEFINE FIELD is_billable ON legal_action TYPE bool DEFAULT false;
DEFINE FIELD is_active ON legal_action TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_action TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_action TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON legal_action TYPE option<record<user>>;
DEFINE FIELD updated_by ON legal_action TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_legal_action_id ON legal_action COLUMNS action_id UNIQUE;
DEFINE INDEX idx_legal_action_company ON legal_action COLUMNS company;
DEFINE INDEX idx_legal_action_process ON legal_action COLUMNS related_process;
DEFINE INDEX idx_legal_action_assigned ON legal_action COLUMNS assigned_to;
DEFINE INDEX idx_legal_action_priority ON legal_action COLUMNS priority;
DEFINE INDEX idx_legal_action_due_date ON legal_action COLUMNS due_date;
DEFINE INDEX idx_legal_action_status ON legal_action COLUMNS status;
DEFINE INDEX idx_legal_action_active ON legal_action COLUMNS is_active;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour démarrer un processus juridique
DEFINE FUNCTION start_legal_process($process_type_id: record<legal_process_type>, $company_id: record<company>, $initiator_id: record<user>, $parameters: object) {
    LET $process_type = SELECT * FROM legal_process_type WHERE id = $process_type_id;
    LET $process_id = "PROC-" + string::slice(rand::uuid(), 0, 8);
    
    -- Création du processus
    LET $process = CREATE legal_process CONTENT {
        process_id: $process_id,
        name: $parameters.name OR $process_type.name,
        description: $parameters.description,
        process_type: $process_type_id,
        company: $company_id,
        initiator: $initiator_id,
        start_date: time::now(),
        target_completion_date: time::now() + duration::from_days($process_type.typical_duration_days OR 30),
        status: "draft",
        priority: $parameters.priority OR $process_type.priority,
        confidentiality_level: $parameters.confidentiality_level OR "internal",
        created_on: time::now()
    };
    
    -- Génération automatique des étapes
    FOR $i IN 1..5 {
        LET $stage_name = IF $i = 1 THEN "Préparation"
                         ELSE IF $i = 2 THEN "Analyse"
                         ELSE IF $i = 3 THEN "Exécution"
                         ELSE IF $i = 4 THEN "Révision"
                         ELSE "Finalisation"
                         END;
        
        CREATE legal_process_stage CONTENT {
            stage_id: $process_id + "-S" + string::from($i),
            process: $process.id,
            name: $stage_name,
            order_sequence: $i,
            stage_type: IF $i = 1 THEN "preparation"
                       ELSE IF $i = 2 THEN "review"
                       ELSE IF $i = 3 THEN "execution"
                       ELSE IF $i = 4 THEN "review"
                       ELSE "completion"
                       END,
            status: IF $i = 1 THEN "not_started" ELSE "not_started" END,
            estimated_duration_days: math::floor(($process_type.typical_duration_days OR 30) / 5),
            created_on: time::now()
        };
    }
    
    RETURN $process;
};

-- Fonction pour calculer le statut d'un processus
DEFINE FUNCTION update_process_status($process_id: record<legal_process>) {
    LET $stages = SELECT * FROM legal_process_stage WHERE process = $process_id AND is_active = true;
    LET $total_stages = array::len($stages);
    LET $completed_stages = array::len(array::filter($stages, |$stage| $stage.status = "completed"));
    LET $in_progress_stages = array::len(array::filter($stages, |$stage| $stage.status = "in_progress"));
    
    LET $progress = ($completed_stages / $total_stages) * 100;
    
    LET $status = IF $completed_stages = $total_stages THEN "completed"
                 ELSE IF $in_progress_stages > 0 THEN "in_progress"
                 ELSE IF $completed_stages > 0 THEN "in_progress"
                 ELSE "pending_approval"
                 END;
    
    UPDATE legal_process SET 
        progress_percentage = $progress,
        status = $status,
        updated_on = time::now()
    WHERE id = $process_id;
    
    RETURN {
        progress: $progress,
        status: $status,
        completed_stages: $completed_stages,
        total_stages: $total_stages
    };
};

-- Fonction pour générer les notifications d'échéance
DEFINE FUNCTION generate_deadline_notifications($days_ahead: int) {
    LET $upcoming_deadlines = SELECT * FROM legal_deadline 
        WHERE due_date BETWEEN time::now() AND (time::now() + duration::from_days($days_ahead))
        AND completion_status = "pending"
        AND is_active = true;
    
    LET $notifications = [];
    
    FOR $deadline IN $upcoming_deadlines {
        LET $days_remaining = math::floor((time::unix($deadline.due_date) - time::unix(time::now())) / 86400);
        
        LET $notification = CREATE legal_notification CONTENT {
            notification_id: "NOTIF-" + string::slice(rand::uuid(), 0, 8),
            title: "Échéance approche: " + $deadline.title,
            message: "L'échéance '" + $deadline.title + "' est prévue dans " + string::from($days_remaining) + " jour(s).",
            notification_type: "deadline_reminder",
            priority: $deadline.priority,
            company: $deadline.company,
            related_deadline: $deadline.id,
            recipients: [$deadline.responsible_person],
            sender: user:system,
            scheduled_date: time::now(),
            delivery_method: ["email", "dashboard"],
            status: "scheduled",
            created_on: time::now()
        };
        
        $notifications = array::push($notifications, $notification);
    }
    
    RETURN $notifications;
};

-- Fonction pour calculer les coûts d'un processus
DEFINE FUNCTION calculate_process_costs($process_id: record<legal_process>) {
    LET $actions = SELECT * FROM legal_action WHERE related_process = $process_id;
    
    LET $total_hours = array::sum(array::map($actions, |$action| $action.actual_hours));
    LET $billable_hours = array::sum(array::map($actions, |$action| $action.billable_hours));
    LET $total_cost = array::sum(array::map($actions, |$action| $action.cost));
    
    LET $external_costs = 0.0; -- À implémenter selon les besoins
    
    UPDATE legal_process SET 
        actual_cost = $total_cost + $external_costs,
        updated_on = time::now()
    WHERE id = $process_id;
    
    RETURN {
        total_hours: $total_hours,
        billable_hours: $billable_hours,
        internal_cost: $total_cost,
        external_cost: $external_costs,
        total_cost: $total_cost + $external_costs
    };
};

-- Fonction pour escalader un processus
DEFINE FUNCTION escalate_process($process_id: record<legal_process>, $escalation_reason: string) {
    LET $process = SELECT * FROM legal_process WHERE id = $process_id;
    
    UPDATE legal_process SET 
        status = "escalated",
        updated_on = time::now()
    WHERE id = $process_id;
    
    -- Créer une notification d'escalade
    CREATE legal_notification CONTENT {
        notification_id: "ESC-" + string::slice(rand::uuid(), 0, 8),
        title: "Escalade de processus: " + $process.name,
        message: "Le processus '" + $process.name + "' a été escaladé. Raison: " + $escalation_reason,
        notification_type: "escalation",
        priority: "urgent",
        company: $process.company,
        related_process: $process_id,
        recipients: [], -- À définir selon les règles d'escalade
        sender: user:system,
        scheduled_date: time::now(),
        delivery_method: ["email", "dashboard"],
        status: "scheduled",
        created_on: time::now()
    };
    
    RETURN true;
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des processus actifs
DEFINE TABLE active_legal_processes AS SELECT 
    legal_process.*,
    legal_process_type.name AS process_type_name,
    legal_process_type.category AS process_category,
    company.name AS company_name
FROM legal_process 
INNER JOIN legal_process_type ON legal_process.process_type = legal_process_type.id
INNER JOIN company ON legal_process.company = company.id
WHERE legal_process.status IN ['in_progress', 'under_review', 'pending_approval'] 
AND legal_process.is_active = true
ORDER BY legal_process.priority DESC, legal_process.target_completion_date ASC;

-- Vue des échéances urgentes
DEFINE TABLE urgent_legal_deadlines AS SELECT 
    legal_deadline.*,
    company.name AS company_name,
    (legal_deadline.due_date - time::now()) AS time_remaining
FROM legal_deadline 
INNER JOIN company ON legal_deadline.company = company.id
WHERE legal_deadline.due_date < (time::now() + duration::from_days(7))
AND legal_deadline.completion_status = "pending"
AND legal_deadline.is_active = true
ORDER BY legal_deadline.due_date ASC;

-- Vue des approbations en attente
DEFINE TABLE pending_legal_approvals AS SELECT 
    legal_approval.*,
    company.name AS company_name,
    (legal_approval.due_date - time::now()) AS time_remaining
FROM legal_approval 
INNER JOIN company ON legal_approval.company = company.id
WHERE legal_approval.status = "pending"
AND legal_approval.is_active = true
ORDER BY legal_approval.priority DESC, legal_approval.due_date ASC;

-- Vue des actions en retard
DEFINE TABLE overdue_legal_actions AS SELECT 
    legal_action.*,
    company.name AS company_name,
    (time::now() - legal_action.due_date) AS days_overdue
FROM legal_action 
INNER JOIN company ON legal_action.company = company.id
WHERE legal_action.due_date < time::now()
AND legal_action.status NOT IN ['completed', 'cancelled']
AND legal_action.is_active = true
ORDER BY legal_action.due_date ASC;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TYPES DE PROCESSUS
-- ==============================================================================

-- Négociation de contrat
CREATE legal_process_type:contract_negotiation CONTENT {
    code: "CONTRACT_NEG",
    name: "Négociation de contrat",
    description: "Processus de négociation et finalisation d'un contrat commercial",
    category: "contract",
    priority: "high",
    typical_duration_days: 30,
    required_roles: ["legal_counsel", "business_manager", "finance_manager"],
    required_documents: ["draft_contract", "terms_sheet", "risk_assessment"],
    cost_estimate_range: {
        min: 5000,
        max: 25000,
        currency: "EUR"
    },
    auto_escalation_rules: [
        {
            trigger: "overdue_7_days",
            action: "notify_supervisor"
        }
    ],
    success_criteria: ["contract_signed", "terms_agreed", "risk_mitigated"],
    risk_factors: ["regulatory_compliance", "financial_exposure", "timeline_pressure"],
    is_active: true,
    created_on: time::now()
};

-- Conformité réglementaire
CREATE legal_process_type:regulatory_compliance CONTENT {
    code: "REG_COMPLIANCE",
    name: "Mise en conformité réglementaire",
    description: "Processus de mise en conformité avec nouvelles réglementations",
    category: "compliance",
    priority: "urgent",
    typical_duration_days: 45,
    required_roles: ["compliance_officer", "legal_counsel", "operations_manager"],
    required_documents: ["compliance_assessment", "action_plan", "evidence_documentation"],
    cost_estimate_range: {
        min: 10000,
        max: 50000,
        currency: "EUR"
    },
    auto_escalation_rules: [
        {
            trigger: "deadline_approaching",
            action: "escalate_to_board"
        }
    ],
    success_criteria: ["compliance_achieved", "audit_passed", "certification_obtained"],
    risk_factors: ["regulatory_penalties", "business_disruption", "reputation_risk"],
    is_active: true,
    created_on: time::now()
};

-- Résolution de litige
CREATE legal_process_type:litigation_resolution CONTENT {
    code: "LITIGATION",
    name: "Résolution de litige",
    description: "Processus de résolution d'un litige juridique",
    category: "litigation",
    priority: "urgent",
    typical_duration_days: 180,
    required_roles: ["litigation_counsel", "legal_director", "external_counsel"],
    required_documents: ["case_file", "evidence_package", "legal_strategy"],
    cost_estimate_range: {
        min: 25000,
        max: 200000,
        currency: "EUR"
    },
    auto_escalation_rules: [
        {
            trigger: "high_financial_exposure",
            action: "board_notification"
        }
    ],
    success_criteria: ["dispute_resolved", "settlement_reached", "judgment_favorable"],
    risk_factors: ["financial_liability", "reputation_damage", "precedent_setting"],
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : ÉCHÉANCES TYPES
-- ==============================================================================

-- Échéance annuelle - Assemblée générale
CREATE legal_deadline:annual_general_meeting CONTENT {
    deadline_id: "AGM-2024",
    title: "Assemblée Générale Annuelle 2024",
    description: "Tenue obligatoire de l'assemblée générale annuelle",
    deadline_type: "statutory",
    company: company:sample_company,
    due_date: "2024-06-30T23:59:59Z",
    is_recurring: true,
    recurrence_pattern: {
        frequency: "annual",
        month: 6,
        day: 30
    },
    priority: "high",
    consequences: ["Amende administrative", "Dissolution possible"],
    responsible_person: user:legal_director,
    notification_schedule: [
        {
            days_before: 30,
            method: "email"
        },
        {
            days_before: 7,
            method: "urgent_notification"
        }
    ],
    completion_status: "pending",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES PROCESSUS JURIDIQUES :

1. TYPES DE PROCESSUS (legal_process_type)
   - Définition des processus standards
   - Durées typiques et rôles requis
   - Règles d'escalade automatique

2. PROCESSUS (legal_process)
   - Instances de processus en cours
   - Suivi des coûts et délais
   - Statut et progression

3. ÉTAPES (legal_process_stage)
   - Décomposition en étapes
   - Dépendances et blocages
   - Livrables et contrôles qualité

4. ÉCHÉANCES (legal_deadline)
   - Échéances réglementaires et contractuelles
   - Récurrence et notifications
   - Conséquences de non-respect

5. NOTIFICATIONS (legal_notification)
   - Alertes et rappels automatiques
   - Multi-canal (email, SMS, push)
   - Escalade en cas de non-réponse

6. APPROBATIONS (legal_approval)
   - Workflows d'approbation
   - Niveaux hiérarchiques
   - Audit trail complet

7. ACTIONS (legal_action)
   - Tâches et jalons
   - Suivi du temps et coûts
   - Facturation et reporting

UTILISATION :
- Automatisation des workflows juridiques
- Gestion des échéances et notifications
- Suivi des coûts et performance
- Escalade automatique des problèmes
- Audit trail complet des décisions
*/ 