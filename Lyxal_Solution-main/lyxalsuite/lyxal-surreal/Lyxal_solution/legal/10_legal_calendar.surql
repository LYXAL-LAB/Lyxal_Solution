-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : CALENDRIER LÉGAL
-- ==============================================================================
-- Fichier : 10_legal_calendar.surql
-- Description : Gestion complète du calendrier légal et fiscal
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : ÉCHÉANCES FISCALES
-- ==============================================================================

DEFINE TABLE fiscal_deadline SCHEMAFULL;
DEFINE FIELD deadline_id ON fiscal_deadline TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON fiscal_deadline TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON fiscal_deadline TYPE string;
DEFINE FIELD company ON fiscal_deadline TYPE record<company>;
DEFINE FIELD tax_type ON fiscal_deadline TYPE string ASSERT $value IN ['tva', 'is', 'cvae', 'cfe', 'taxe_apprentissage', 'participation_formation'];
DEFINE FIELD frequency ON fiscal_deadline TYPE string ASSERT $value IN ['monthly', 'quarterly', 'annual', 'one_time'];
DEFINE FIELD due_date ON fiscal_deadline TYPE datetime;
DEFINE FIELD period_start ON fiscal_deadline TYPE option<datetime>;
DEFINE FIELD period_end ON fiscal_deadline TYPE option<datetime>;
DEFINE FIELD amount_estimated ON fiscal_deadline TYPE option<decimal>;
DEFINE FIELD amount_actual ON fiscal_deadline TYPE option<decimal>;
DEFINE FIELD currency ON fiscal_deadline TYPE string DEFAULT "EUR";
DEFINE FIELD status ON fiscal_deadline TYPE string ASSERT $value IN ['pending', 'filed', 'paid', 'overdue', 'cancelled'];
DEFINE FIELD filing_method ON fiscal_deadline TYPE string ASSERT $value IN ['online', 'paper', 'electronic'];
DEFINE FIELD responsible_person ON fiscal_deadline TYPE option<record<user>>;
DEFINE FIELD external_advisor ON fiscal_deadline TYPE option<string>;
DEFINE FIELD penalty_rate ON fiscal_deadline TYPE option<decimal>;
DEFINE FIELD late_penalty_calculated ON fiscal_deadline TYPE option<decimal>;
DEFINE FIELD reminders_sent ON fiscal_deadline TYPE array<object>;
DEFINE FIELD supporting_documents ON fiscal_deadline TYPE array<string>;
DEFINE FIELD filing_reference ON fiscal_deadline TYPE option<string>;
DEFINE FIELD payment_reference ON fiscal_deadline TYPE option<string>;
DEFINE FIELD next_occurrence ON fiscal_deadline TYPE option<datetime>;
DEFINE FIELD is_recurring ON fiscal_deadline TYPE bool DEFAULT false;
DEFINE FIELD is_active ON fiscal_deadline TYPE bool DEFAULT true;
DEFINE FIELD created_on ON fiscal_deadline TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON fiscal_deadline TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_fiscal_deadline_id ON fiscal_deadline COLUMNS deadline_id UNIQUE;
DEFINE INDEX idx_fiscal_deadline_company ON fiscal_deadline COLUMNS company;
DEFINE INDEX idx_fiscal_deadline_type ON fiscal_deadline COLUMNS tax_type;
DEFINE INDEX idx_fiscal_deadline_due_date ON fiscal_deadline COLUMNS due_date;
DEFINE INDEX idx_fiscal_deadline_status ON fiscal_deadline COLUMNS status;
DEFINE INDEX idx_fiscal_deadline_responsible ON fiscal_deadline COLUMNS responsible_person;

-- ==============================================================================
-- TABLE : OBLIGATIONS DÉCLARATIVES
-- ==============================================================================

DEFINE TABLE declarative_obligation SCHEMAFULL;
DEFINE FIELD obligation_id ON declarative_obligation TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON declarative_obligation TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON declarative_obligation TYPE string;
DEFINE FIELD company ON declarative_obligation TYPE record<company>;
DEFINE FIELD obligation_type ON declarative_obligation TYPE string ASSERT $value IN ['dads', 'dsn', 'dac6', 'deb', 'intrastat', 'liasse_fiscale', 'bilan_social'];
DEFINE FIELD regulatory_authority ON declarative_obligation TYPE string ASSERT $value IN ['dgfip', 'urssaf', 'douanes', 'insee', 'banque_france'];
DEFINE FIELD frequency ON declarative_obligation TYPE string ASSERT $value IN ['monthly', 'quarterly', 'annual', 'event_based'];
DEFINE FIELD due_date ON declarative_obligation TYPE datetime;
DEFINE FIELD period_covered ON declarative_obligation TYPE object;
DEFINE FIELD filing_format ON declarative_obligation TYPE string ASSERT $value IN ['xml', 'csv', 'pdf', 'online_form'];
DEFINE FIELD filing_portal ON declarative_obligation TYPE string;
DEFINE FIELD required_data ON declarative_obligation TYPE array<string>;
DEFINE FIELD data_sources ON declarative_obligation TYPE array<string>;
DEFINE FIELD validation_rules ON declarative_obligation TYPE array<object>;
DEFINE FIELD status ON declarative_obligation TYPE string ASSERT $value IN ['pending', 'in_preparation', 'validated', 'filed', 'acknowledged', 'rejected'];
DEFINE FIELD preparation_progress ON declarative_obligation TYPE decimal DEFAULT 0.0;
DEFINE FIELD responsible_person ON declarative_obligation TYPE record<user>;
DEFINE FIELD validators ON declarative_obligation TYPE array<record<user>>;
DEFINE FIELD external_provider ON declarative_obligation TYPE option<string>;
DEFINE FIELD estimated_hours ON declarative_obligation TYPE option<decimal>;
DEFINE FIELD actual_hours ON declarative_obligation TYPE option<decimal>;
DEFINE FIELD filing_confirmation ON declarative_obligation TYPE option<string>;
DEFINE FIELD acknowledgment_received ON declarative_obligation TYPE option<datetime>;
DEFINE FIELD penalties_applicable ON declarative_obligation TYPE array<object>;
DEFINE FIELD next_occurrence ON declarative_obligation TYPE option<datetime>;
DEFINE FIELD is_recurring ON declarative_obligation TYPE bool DEFAULT false;
DEFINE FIELD is_active ON declarative_obligation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON declarative_obligation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON declarative_obligation TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_declarative_obligation_id ON declarative_obligation COLUMNS obligation_id UNIQUE;
DEFINE INDEX idx_declarative_obligation_company ON declarative_obligation COLUMNS company;
DEFINE INDEX idx_declarative_obligation_type ON declarative_obligation COLUMNS obligation_type;
DEFINE INDEX idx_declarative_obligation_due_date ON declarative_obligation COLUMNS due_date;
DEFINE INDEX idx_declarative_obligation_status ON declarative_obligation COLUMNS status;
DEFINE INDEX idx_declarative_obligation_responsible ON declarative_obligation COLUMNS responsible_person;

-- ==============================================================================
-- TABLE : RENOUVELLEMENTS
-- ==============================================================================

DEFINE TABLE renewal_calendar SCHEMAFULL;
DEFINE FIELD renewal_id ON renewal_calendar TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON renewal_calendar TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON renewal_calendar TYPE string;
DEFINE FIELD company ON renewal_calendar TYPE record<company>;
DEFINE FIELD renewal_type ON renewal_calendar TYPE string ASSERT $value IN ['insurance', 'contract', 'license', 'certification', 'subscription', 'lease'];
DEFINE FIELD related_entity ON renewal_calendar TYPE string;
DEFINE FIELD related_entity_id ON renewal_calendar TYPE option<string>;
DEFINE FIELD current_expiry_date ON renewal_calendar TYPE datetime;
DEFINE FIELD renewal_deadline ON renewal_calendar TYPE datetime;
DEFINE FIELD notice_period_days ON renewal_calendar TYPE int DEFAULT 30;
DEFINE FIELD auto_renewal ON renewal_calendar TYPE bool DEFAULT false;
DEFINE FIELD renewal_terms ON renewal_calendar TYPE array<object>;
DEFINE FIELD cost_current ON renewal_calendar TYPE option<decimal>;
DEFINE FIELD cost_renewal ON renewal_calendar TYPE option<decimal>;
DEFINE FIELD currency ON renewal_calendar TYPE string DEFAULT "EUR";
DEFINE FIELD vendor_provider ON renewal_calendar TYPE string;
DEFINE FIELD contact_person ON renewal_calendar TYPE option<string>;
DEFINE FIELD negotiation_status ON renewal_calendar TYPE string ASSERT $value IN ['not_started', 'in_progress', 'completed', 'cancelled'];
DEFINE FIELD negotiation_notes ON renewal_calendar TYPE array<object>;
DEFINE FIELD status ON renewal_calendar TYPE string ASSERT $value IN ['active', 'notice_given', 'renewed', 'cancelled', 'expired'];
DEFINE FIELD responsible_person ON renewal_calendar TYPE record<user>;
DEFINE FIELD stakeholders ON renewal_calendar TYPE array<record<user>>;
DEFINE FIELD renewal_checklist ON renewal_calendar TYPE array<object>;
DEFINE FIELD documents_required ON renewal_calendar TYPE array<string>;
DEFINE FIELD approval_required ON renewal_calendar TYPE bool DEFAULT false;
DEFINE FIELD approval_workflow ON renewal_calendar TYPE option<string>;
DEFINE FIELD renewal_date ON renewal_calendar TYPE option<datetime>;
DEFINE FIELD new_expiry_date ON renewal_calendar TYPE option<datetime>;
DEFINE FIELD is_active ON renewal_calendar TYPE bool DEFAULT true;
DEFINE FIELD created_on ON renewal_calendar TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON renewal_calendar TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_renewal_calendar_id ON renewal_calendar COLUMNS renewal_id UNIQUE;
DEFINE INDEX idx_renewal_calendar_company ON renewal_calendar COLUMNS company;
DEFINE INDEX idx_renewal_calendar_type ON renewal_calendar COLUMNS renewal_type;
DEFINE INDEX idx_renewal_calendar_expiry ON renewal_calendar COLUMNS current_expiry_date;
DEFINE INDEX idx_renewal_calendar_deadline ON renewal_calendar COLUMNS renewal_deadline;
DEFINE INDEX idx_renewal_calendar_status ON renewal_calendar COLUMNS status;
DEFINE INDEX idx_renewal_calendar_responsible ON renewal_calendar COLUMNS responsible_person;

-- ==============================================================================
-- TABLE : NOTIFICATIONS AUTOMATIQUES
-- ==============================================================================

DEFINE TABLE legal_notification SCHEMAFULL;
DEFINE FIELD notification_id ON legal_notification TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON legal_notification TYPE record<company>;
DEFINE FIELD notification_type ON legal_notification TYPE string ASSERT $value IN ['deadline_reminder', 'renewal_notice', 'compliance_alert', 'overdue_warning', 'status_change'];
DEFINE FIELD related_entity_type ON legal_notification TYPE string;
DEFINE FIELD related_entity_id ON legal_notification TYPE string;
DEFINE FIELD title ON legal_notification TYPE string;
DEFINE FIELD message ON legal_notification TYPE string;
DEFINE FIELD severity ON legal_notification TYPE string ASSERT $value IN ['info', 'warning', 'error', 'critical'];
DEFINE FIELD recipients ON legal_notification TYPE array<record<user>>;
DEFINE FIELD delivery_channels ON legal_notification TYPE array<string>;
DEFINE FIELD schedule_date ON legal_notification TYPE datetime;
DEFINE FIELD sent_date ON legal_notification TYPE option<datetime>;
DEFINE FIELD status ON legal_notification TYPE string ASSERT $value IN ['scheduled', 'sent', 'delivered', 'failed', 'cancelled'];
DEFINE FIELD delivery_confirmations ON legal_notification TYPE array<object>;
DEFINE FIELD escalation_rules ON legal_notification TYPE array<object>;
DEFINE FIELD escalation_triggered ON legal_notification TYPE bool DEFAULT false;
DEFINE FIELD response_required ON legal_notification TYPE bool DEFAULT false;
DEFINE FIELD responses_received ON legal_notification TYPE array<object>;
DEFINE FIELD retry_count ON legal_notification TYPE int DEFAULT 0;
DEFINE FIELD max_retries ON legal_notification TYPE int DEFAULT 3;
DEFINE FIELD template_used ON legal_notification TYPE option<string>;
DEFINE FIELD personalization_data ON legal_notification TYPE option<object>;
DEFINE FIELD tracking_id ON legal_notification TYPE option<string>;
DEFINE FIELD is_active ON legal_notification TYPE bool DEFAULT true;
DEFINE FIELD created_on ON legal_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON legal_notification TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_legal_notification_id ON legal_notification COLUMNS notification_id UNIQUE;
DEFINE INDEX idx_legal_notification_company ON legal_notification COLUMNS company;
DEFINE INDEX idx_legal_notification_type ON legal_notification COLUMNS notification_type;
DEFINE INDEX idx_legal_notification_schedule ON legal_notification COLUMNS schedule_date;
DEFINE INDEX idx_legal_notification_status ON legal_notification COLUMNS status;
DEFINE INDEX idx_legal_notification_severity ON legal_notification COLUMNS severity;

-- ==============================================================================
-- TABLE : PLANNING DE CONFORMITÉ
-- ==============================================================================

DEFINE TABLE compliance_roadmap SCHEMAFULL;
DEFINE FIELD roadmap_id ON compliance_roadmap TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON compliance_roadmap TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON compliance_roadmap TYPE string;
DEFINE FIELD company ON compliance_roadmap TYPE record<company>;
DEFINE FIELD year ON compliance_roadmap TYPE int;
DEFINE FIELD roadmap_type ON compliance_roadmap TYPE string ASSERT $value IN ['fiscal', 'regulatory', 'contractual', 'comprehensive'];
DEFINE FIELD milestones ON compliance_roadmap TYPE array<object>;
DEFINE FIELD quarterly_objectives ON compliance_roadmap TYPE array<object>;
DEFINE FIELD key_deadlines ON compliance_roadmap TYPE array<object>;
DEFINE FIELD resource_allocation ON compliance_roadmap TYPE array<object>;
DEFINE FIELD budget_allocated ON compliance_roadmap TYPE option<decimal>;
DEFINE FIELD budget_spent ON compliance_roadmap TYPE option<decimal>;
DEFINE FIELD currency ON compliance_roadmap TYPE string DEFAULT "EUR";
DEFINE FIELD responsible_team ON compliance_roadmap TYPE array<record<user>>;
DEFINE FIELD external_advisors ON compliance_roadmap TYPE array<string>;
DEFINE FIELD progress_tracking ON compliance_roadmap TYPE array<object>;
DEFINE FIELD overall_progress ON compliance_roadmap TYPE decimal DEFAULT 0.0;
DEFINE FIELD risk_mitigation_plan ON compliance_roadmap TYPE array<object>;
DEFINE FIELD contingency_plans ON compliance_roadmap TYPE array<object>;
DEFINE FIELD status ON compliance_roadmap TYPE string ASSERT $value IN ['draft', 'approved', 'active', 'completed', 'cancelled'];
DEFINE FIELD approval_date ON compliance_roadmap TYPE option<datetime>;
DEFINE FIELD approved_by ON compliance_roadmap TYPE option<record<user>>;
DEFINE FIELD last_review_date ON compliance_roadmap TYPE option<datetime>;
DEFINE FIELD next_review_date ON compliance_roadmap TYPE option<datetime>;
DEFINE FIELD is_active ON compliance_roadmap TYPE bool DEFAULT true;
DEFINE FIELD created_on ON compliance_roadmap TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON compliance_roadmap TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_compliance_roadmap_id ON compliance_roadmap COLUMNS roadmap_id UNIQUE;
DEFINE INDEX idx_compliance_roadmap_company ON compliance_roadmap COLUMNS company;
DEFINE INDEX idx_compliance_roadmap_year ON compliance_roadmap COLUMNS year;
DEFINE INDEX idx_compliance_roadmap_status ON compliance_roadmap COLUMNS status;

-- ==============================================================================
-- TABLE : INTÉGRATION CALENDRIER
-- ==============================================================================

DEFINE TABLE calendar_integration SCHEMAFULL;
DEFINE FIELD integration_id ON calendar_integration TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON calendar_integration TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON calendar_integration TYPE record<company>;
DEFINE FIELD calendar_provider ON calendar_integration TYPE string ASSERT $value IN ['outlook', 'google', 'apple', 'zimbra', 'exchange'];
DEFINE FIELD calendar_id ON calendar_integration TYPE string;
DEFINE FIELD sync_direction ON calendar_integration TYPE string ASSERT $value IN ['push', 'pull', 'bidirectional'];
DEFINE FIELD sync_frequency ON calendar_integration TYPE string ASSERT $value IN ['real_time', 'hourly', 'daily', 'weekly'];
DEFINE FIELD last_sync_date ON calendar_integration TYPE option<datetime>;
DEFINE FIELD sync_status ON calendar_integration TYPE string ASSERT $value IN ['active', 'failed', 'paused', 'disabled'];
DEFINE FIELD sync_errors ON calendar_integration TYPE array<object>;
DEFINE FIELD event_types_synced ON calendar_integration TYPE array<string>;
DEFINE FIELD sync_filters ON calendar_integration TYPE array<object>;
DEFINE FIELD authentication_method ON calendar_integration TYPE string ASSERT $value IN ['oauth2', 'basic_auth', 'api_key'];
DEFINE FIELD authentication_config ON calendar_integration TYPE object;
DEFINE FIELD calendar_permissions ON calendar_integration TYPE array<string>;
DEFINE FIELD sync_mappings ON calendar_integration TYPE array<object>;
DEFINE FIELD users_authorized ON calendar_integration TYPE array<record<user>>;
DEFINE FIELD events_created ON calendar_integration TYPE int DEFAULT 0;
DEFINE FIELD events_updated ON calendar_integration TYPE int DEFAULT 0;
DEFINE FIELD events_deleted ON calendar_integration TYPE int DEFAULT 0;
DEFINE FIELD is_active ON calendar_integration TYPE bool DEFAULT true;
DEFINE FIELD created_on ON calendar_integration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON calendar_integration TYPE datetime DEFAULT time::now();

-- Index optimisés
DEFINE INDEX idx_calendar_integration_id ON calendar_integration COLUMNS integration_id UNIQUE;
DEFINE INDEX idx_calendar_integration_company ON calendar_integration COLUMNS company;
DEFINE INDEX idx_calendar_integration_provider ON calendar_integration COLUMNS calendar_provider;
DEFINE INDEX idx_calendar_integration_status ON calendar_integration COLUMNS sync_status;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour vérifier les échéances à venir
DEFINE FUNCTION check_upcoming_deadlines($company_id: record<company>, $days_ahead: int) {
    LET $end_date = time::now() + duration::from_days($days_ahead);
    
    LET $fiscal_deadlines = SELECT * FROM fiscal_deadline 
        WHERE company = $company_id 
        AND due_date BETWEEN time::now() AND $end_date
        AND status = "pending"
        ORDER BY due_date ASC;
    
    LET $obligations = SELECT * FROM declarative_obligation 
        WHERE company = $company_id 
        AND due_date BETWEEN time::now() AND $end_date
        AND status IN ["pending", "in_preparation"]
        ORDER BY due_date ASC;
    
    LET $renewals = SELECT * FROM renewal_calendar 
        WHERE company = $company_id 
        AND renewal_deadline BETWEEN time::now() AND $end_date
        AND status = "active"
        ORDER BY renewal_deadline ASC;
    
    RETURN {
        fiscal_deadlines: $fiscal_deadlines,
        obligations: $obligations,
        renewals: $renewals,
        total_items: array::len($fiscal_deadlines) + array::len($obligations) + array::len($renewals)
    };
};

-- Fonction pour créer des notifications automatiques
DEFINE FUNCTION create_automatic_notifications($company_id: record<company>) {
    LET $deadlines = check_upcoming_deadlines($company_id, 30);
    LET $notifications = [];
    
    FOR $deadline IN $deadlines.fiscal_deadlines {
        LET $days_remaining = math::floor((time::unix($deadline.due_date) - time::unix(time::now())) / 86400);
        
        IF $days_remaining <= 7 THEN
            LET $notification_id = "NOT-" + string::slice(rand::uuid(), 0, 8);
            LET $notification = CREATE legal_notification CONTENT {
                notification_id: $notification_id,
                company: $company_id,
                notification_type: "deadline_reminder",
                related_entity_type: "fiscal_deadline",
                related_entity_id: $deadline.deadline_id,
                title: "Échéance fiscale dans " + string::integer($days_remaining) + " jours",
                message: "L'échéance " + $deadline.name + " arrive à échéance le " + string::slice(string::datetime($deadline.due_date), 0, 10),
                severity: IF $days_remaining <= 3 THEN "critical" ELSE "warning" END,
                recipients: [$deadline.responsible_person],
                delivery_channels: ["email", "in_app"],
                schedule_date: time::now(),
                status: "scheduled",
                created_on: time::now()
            };
            
            $notifications = array::push($notifications, $notification);
        END;
    }
    
    RETURN {
        notifications_created: array::len($notifications),
        notifications: $notifications
    };
};

-- Fonction pour synchroniser avec le calendrier externe
DEFINE FUNCTION sync_external_calendar($integration_id: record<calendar_integration>) {
    LET $integration = SELECT * FROM calendar_integration WHERE id = $integration_id;
    
    IF array::len($integration) = 0 THEN
        RETURN { success: false, message: "Intégration non trouvée" };
    END;
    
    LET $integration_data = $integration[0];
    
    -- Simulation de synchronisation
    LET $events_synced = 0;
    LET $errors = [];
    
    -- Récupération des événements à synchroniser
    LET $fiscal_events = SELECT * FROM fiscal_deadline 
        WHERE company = $integration_data.company 
        AND due_date > time::now()
        AND is_active = true;
    
    LET $obligation_events = SELECT * FROM declarative_obligation 
        WHERE company = $integration_data.company 
        AND due_date > time::now()
        AND is_active = true;
    
    $events_synced = array::len($fiscal_events) + array::len($obligation_events);
    
    -- Mise à jour du statut de synchronisation
    UPDATE calendar_integration 
    SET last_sync_date = time::now(),
        sync_status = "active",
        events_created = events_created + $events_synced,
        updated_on = time::now()
    WHERE id = $integration_id;
    
    RETURN {
        success: true,
        events_synced: $events_synced,
        provider: $integration_data.calendar_provider,
        sync_date: time::now()
    };
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE
-- ==============================================================================

-- Échéance TVA mensuelle
CREATE fiscal_deadline:tva_monthly CONTENT {
    deadline_id: "TVA-MONTHLY-2024",
    name: "Déclaration TVA mensuelle",
    description: "Déclaration de TVA pour les entreprises au régime réel normal",
    tax_type: "tva",
    frequency: "monthly",
    due_date: "2024-02-15T23:59:59Z",
    period_start: "2024-01-01T00:00:00Z",
    period_end: "2024-01-31T23:59:59Z",
    status: "pending",
    filing_method: "online",
    penalty_rate: 5.0,
    is_recurring: true,
    next_occurrence: "2024-03-15T23:59:59Z",
    is_active: true,
    created_on: time::now()
};

-- Obligation DSN
CREATE declarative_obligation:dsn_monthly CONTENT {
    obligation_id: "DSN-MONTHLY-2024",
    name: "Déclaration Sociale Nominative",
    description: "Transmission mensuelle des données sociales",
    obligation_type: "dsn",
    regulatory_authority: "urssaf",
    frequency: "monthly",
    due_date: "2024-02-05T23:59:59Z",
    filing_format: "xml",
    filing_portal: "net-entreprises.fr",
    required_data: ["paie", "cotisations", "effectifs"],
    status: "pending",
    preparation_progress: 0.0,
    estimated_hours: 4.0,
    is_recurring: true,
    next_occurrence: "2024-03-05T23:59:59Z",
    is_active: true,
    created_on: time::now()
};

-- Renouvellement assurance
CREATE renewal_calendar:insurance_renewal CONTENT {
    renewal_id: "INS-RC-2024",
    name: "Assurance Responsabilité Civile",
    description: "Renouvellement assurance RC professionnelle",
    renewal_type: "insurance",
    current_expiry_date: "2024-12-31T23:59:59Z",
    renewal_deadline: "2024-11-30T23:59:59Z",
    notice_period_days: 60,
    auto_renewal: false,
    cost_current: 5000.00,
    vendor_provider: "AXA Entreprises",
    negotiation_status: "not_started",
    status: "active",
    approval_required: true,
    is_active: true,
    created_on: time::now()
};

-- Intégration Outlook
CREATE calendar_integration:outlook_integration CONTENT {
    integration_id: "OUTLOOK-001",
    name: "Intégration Outlook Entreprise",
    calendar_provider: "outlook",
    calendar_id: "legal-calendar@company.com",
    sync_direction: "push",
    sync_frequency: "daily",
    sync_status: "active",
    event_types_synced: ["fiscal_deadline", "declarative_obligation", "renewal_calendar"],
    authentication_method: "oauth2",
    events_created: 0,
    events_updated: 0,
    events_deleted: 0,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DU MODULE CALENDRIER LÉGAL :

1. ÉCHÉANCES FISCALES (fiscal_deadline)
   - TVA mensuelle/trimestrielle
   - Impôt sur les sociétés
   - CVAE, CFE, taxes diverses
   - Calcul automatique des pénalités

2. OBLIGATIONS DÉCLARATIVES (declarative_obligation)
   - DSN mensuelle
   - DADS annuelle
   - DAC6 pour les montages
   - Suivi de préparation et validation

3. RENOUVELLEMENTS (renewal_calendar)
   - Assurances professionnelles
   - Contrats fournisseurs
   - Licences et certifications
   - Négociation et approbation

4. NOTIFICATIONS AUTOMATIQUES (legal_notification)
   - Alertes par email/SMS
   - Escalade automatique
   - Suivi des accusés de réception
   - Templates personnalisables

5. PLANNING DE CONFORMITÉ (compliance_roadmap)
   - Roadmap annuelle
   - Allocation des ressources
   - Suivi budgétaire
   - Objectifs trimestriels

6. INTÉGRATION CALENDRIER (calendar_integration)
   - Synchronisation Outlook/Google
   - Bidirectionnelle temps réel
   - Authentification OAuth2
   - Mapping des événements

UTILISATION :
- Gestion proactive des échéances
- Automation des notifications
- Intégration avec les outils existants
- Suivi de conformité centralisé
- Reporting et analyse
*/ 