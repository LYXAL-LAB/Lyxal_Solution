-- ================================================================================
-- LYXAL SURREAL - AXELOR HELPDESK - MODULE 1 : CORE HELPDESK
-- ================================================================================
-- Entités : Ticket, TicketStatus, TicketType, Sla
-- ================================================================================

-- Ticket principal (Ticket.xml - 2844 bytes)
DEFINE TABLE ticket SCHEMAFULL;
DEFINE FIELD ticket_seq ON ticket TYPE string READONLY;
DEFINE FIELD subject ON ticket TYPE string ASSERT $value != NONE;
DEFINE FIELD full_name ON ticket TYPE string;
DEFINE FIELD project ON ticket TYPE record<project>;
DEFINE FIELD ticket_type ON ticket TYPE record<ticket_type>;
DEFINE FIELD ticket_status ON ticket TYPE record<ticket_status>;
DEFINE FIELD priority_select ON ticket TYPE int DEFAULT 2; -- 1:Low, 2:Normal, 3:High, 4:Urgent, 5:Critical
DEFINE FIELD assigned_to_user ON ticket TYPE record<user>;
DEFINE FIELD reporter_user ON ticket TYPE record<user>;
DEFINE FIELD customer ON ticket TYPE record<partner>;
DEFINE FIELD customer_partner ON ticket TYPE record<partner>;
DEFINE FIELD start_date_t ON ticket TYPE datetime;
DEFINE FIELD end_date_t ON ticket TYPE datetime;
DEFINE FIELD deadline_date ON ticket TYPE datetime;
DEFINE FIELD description ON ticket TYPE string;
DEFINE FIELD solution ON ticket TYPE string;
DEFINE FIELD company ON ticket TYPE record<company>;
DEFINE FIELD team ON ticket TYPE record<team>;
DEFINE FIELD sla ON ticket TYPE record<sla>;
DEFINE FIELD progress_select ON ticket TYPE int DEFAULT 0; -- 0:New, 25:In Progress, 50:Waiting, 75:Resolved, 100:Closed
DEFINE FIELD duration ON ticket TYPE decimal DEFAULT 0.0;
DEFINE FIELD real_duration ON ticket TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_timer_on ON ticket TYPE bool DEFAULT false;
DEFINE FIELD timer_start_time ON ticket TYPE datetime;
DEFINE FIELD total_timer_duration ON ticket TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_task_template ON ticket TYPE bool DEFAULT false;
DEFINE FIELD parent_ticket ON ticket TYPE record<ticket>;
DEFINE FIELD sub_ticket_list ON ticket TYPE array<record<ticket>>;
DEFINE FIELD mail_thread ON ticket TYPE record<mail_thread>;
DEFINE FIELD followers_caller_list ON ticket TYPE array<record<mail_followers>>;
DEFINE FIELD message_template ON ticket TYPE record<message_template>;
DEFINE FIELD attrs ON ticket TYPE string;
DEFINE FIELD is_resolved ON ticket TYPE bool DEFAULT false;
DEFINE FIELD is_closed ON ticket TYPE bool DEFAULT false;
DEFINE FIELD resolution_date ON ticket TYPE datetime;
DEFINE FIELD closed_date ON ticket TYPE datetime;
DEFINE FIELD impact_select ON ticket TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High
DEFINE FIELD urgency_select ON ticket TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High
DEFINE FIELD category ON ticket TYPE string;
DEFINE FIELD sub_category ON ticket TYPE string;
DEFINE FIELD escalation_level ON ticket TYPE int DEFAULT 0;
DEFINE FIELD escalated_date ON ticket TYPE datetime;
DEFINE FIELD estimated_effort_hours ON ticket TYPE decimal DEFAULT 0.0;
DEFINE FIELD actual_effort_hours ON ticket TYPE decimal DEFAULT 0.0;
DEFINE FIELD related_tickets ON ticket TYPE array<record<ticket>>;
DEFINE FIELD attachments ON ticket TYPE array<record<meta_file>>;
DEFINE FIELD tags ON ticket TYPE array<string>;
DEFINE FIELD satisfaction_rating ON ticket TYPE int; -- 1:Very Unsatisfied, 2:Unsatisfied, 3:Neutral, 4:Satisfied, 5:Very Satisfied
DEFINE FIELD satisfaction_comment ON ticket TYPE string;
DEFINE FIELD resolution_category ON ticket TYPE string;
DEFINE FIELD first_response_date ON ticket TYPE datetime;
DEFINE FIELD last_activity_date ON ticket TYPE datetime;
DEFINE FIELD reopened_count ON ticket TYPE int DEFAULT 0;
DEFINE FIELD last_reopened_date ON ticket TYPE datetime;
DEFINE FIELD is_urgent ON ticket TYPE bool DEFAULT false;
DEFINE FIELD is_escalated ON ticket TYPE bool DEFAULT false;
DEFINE FIELD knowledge_base_articles ON ticket TYPE array<record<knowledge_article>>;
DEFINE FIELD time_entries ON ticket TYPE array<record<time_entry>>;
DEFINE FIELD created_at ON ticket TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ticket TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ticket TYPE int DEFAULT 0;

-- Statut de ticket (TicketStatus.xml - 700 bytes)
DEFINE TABLE ticket_status SCHEMAFULL;
DEFINE FIELD name ON ticket_status TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON ticket_status TYPE string;
DEFINE FIELD sequence ON ticket_status TYPE int DEFAULT 0;
DEFINE FIELD is_default ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD is_closed ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD is_resolved ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD color ON ticket_status TYPE string;
DEFINE FIELD progress_percentage ON ticket_status TYPE int DEFAULT 0;
DEFINE FIELD status_type_select ON ticket_status TYPE int DEFAULT 1; -- 1:Open, 2:In Progress, 3:Waiting, 4:Resolved, 5:Closed
DEFINE FIELD next_status_list ON ticket_status TYPE array<record<ticket_status>>;
DEFINE FIELD auto_assign_rule ON ticket_status TYPE string;
DEFINE FIELD notification_template ON ticket_status TYPE record<message_template>;
DEFINE FIELD requires_approval ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD approval_user ON ticket_status TYPE record<user>;
DEFINE FIELD sla_applicable ON ticket_status TYPE bool DEFAULT true;
DEFINE FIELD stop_timer ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD is_final_status ON ticket_status TYPE bool DEFAULT false;
DEFINE FIELD allowed_user_types ON ticket_status TYPE array<string>;
DEFINE FIELD created_at ON ticket_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ticket_status TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ticket_status TYPE int DEFAULT 0;

-- Type de ticket (TicketType.xml - 448 bytes)
DEFINE TABLE ticket_type SCHEMAFULL;
DEFINE FIELD name ON ticket_type TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON ticket_type TYPE string;
DEFINE FIELD sequence ON ticket_type TYPE int DEFAULT 0;
DEFINE FIELD is_default ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD color ON ticket_type TYPE string;
DEFINE FIELD icon ON ticket_type TYPE string;
DEFINE FIELD default_priority ON ticket_type TYPE int DEFAULT 2; -- 1:Low, 2:Normal, 3:High, 4:Urgent, 5:Critical
DEFINE FIELD default_assigned_user ON ticket_type TYPE record<user>;
DEFINE FIELD default_team ON ticket_type TYPE record<team>;
DEFINE FIELD default_sla ON ticket_type TYPE record<sla>;
DEFINE FIELD category_list ON ticket_type TYPE array<string>;
DEFINE FIELD sub_category_list ON ticket_type TYPE array<string>;
DEFINE FIELD default_status ON ticket_type TYPE record<ticket_status>;
DEFINE FIELD workflow_enabled ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD workflow_template ON ticket_type TYPE record<workflow_template>;
DEFINE FIELD requires_customer ON ticket_type TYPE bool DEFAULT true;
DEFINE FIELD requires_description ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD auto_assignment_enabled ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD auto_assignment_rule ON ticket_type TYPE string;
DEFINE FIELD notification_enabled ON ticket_type TYPE bool DEFAULT true;
DEFINE FIELD notification_template ON ticket_type TYPE record<message_template>;
DEFINE FIELD escalation_enabled ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD escalation_rule ON ticket_type TYPE string;
DEFINE FIELD time_tracking_enabled ON ticket_type TYPE bool DEFAULT true;
DEFINE FIELD knowledge_base_enabled ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD satisfaction_survey_enabled ON ticket_type TYPE bool DEFAULT false;
DEFINE FIELD created_at ON ticket_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ticket_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ticket_type TYPE int DEFAULT 0;

-- Service Level Agreement (Sla.xml - 1120 bytes)
DEFINE TABLE sla SCHEMAFULL;
DEFINE FIELD name ON sla TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON sla TYPE string;
DEFINE FIELD is_active ON sla TYPE bool DEFAULT true;
DEFINE FIELD priority_select ON sla TYPE int DEFAULT 2; -- 1:Low, 2:Normal, 3:High, 4:Urgent, 5:Critical
DEFINE FIELD ticket_type ON sla TYPE record<ticket_type>;
DEFINE FIELD customer ON sla TYPE record<partner>;
DEFINE FIELD customer_category ON sla TYPE string;
DEFINE FIELD team ON sla TYPE record<team>;
DEFINE FIELD response_time_hours ON sla TYPE decimal DEFAULT 24.0;
DEFINE FIELD resolution_time_hours ON sla TYPE decimal DEFAULT 72.0;
DEFINE FIELD escalation_time_hours ON sla TYPE decimal DEFAULT 48.0;
DEFINE FIELD is_business_hours_only ON sla TYPE bool DEFAULT true;
DEFINE FIELD business_hours_start ON sla TYPE time DEFAULT '09:00:00';
DEFINE FIELD business_hours_end ON sla TYPE time DEFAULT '17:00:00';
DEFINE FIELD working_days ON sla TYPE array<int> DEFAULT [1,2,3,4,5]; -- 1:Monday, 2:Tuesday, etc.
DEFINE FIELD holiday_calendar ON sla TYPE record<holiday_calendar>;
DEFINE FIELD breach_notification_enabled ON sla TYPE bool DEFAULT true;
DEFINE FIELD breach_notification_template ON sla TYPE record<message_template>;
DEFINE FIELD breach_notification_users ON sla TYPE array<record<user>>;
DEFINE FIELD warning_notification_enabled ON sla TYPE bool DEFAULT true;
DEFINE FIELD warning_notification_percentage ON sla TYPE int DEFAULT 80; -- % of SLA time
DEFINE FIELD warning_notification_template ON sla TYPE record<message_template>;
DEFINE FIELD auto_escalation_enabled ON sla TYPE bool DEFAULT false;
DEFINE FIELD escalation_user ON sla TYPE record<user>;
DEFINE FIELD escalation_team ON sla TYPE record<team>;
DEFINE FIELD escalation_template ON sla TYPE record<message_template>;
DEFINE FIELD metrics_tracking_enabled ON sla TYPE bool DEFAULT true;
DEFINE FIELD compliance_target_percentage ON sla TYPE decimal DEFAULT 95.0;
DEFINE FIELD current_compliance_percentage ON sla TYPE decimal DEFAULT 0.0;
DEFINE FIELD breach_count ON sla TYPE int DEFAULT 0;
DEFINE FIELD warning_count ON sla TYPE int DEFAULT 0;
DEFINE FIELD total_tickets ON sla TYPE int DEFAULT 0;
DEFINE FIELD average_response_time ON sla TYPE decimal DEFAULT 0.0;
DEFINE FIELD average_resolution_time ON sla TYPE decimal DEFAULT 0.0;
DEFINE FIELD last_metrics_update ON sla TYPE datetime;
DEFINE FIELD conditions ON sla TYPE string;
DEFINE FIELD exclusions ON sla TYPE string;
DEFINE FIELD created_at ON sla TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sla TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sla TYPE int DEFAULT 0;

-- Tables de support pour les métriques et logs
DEFINE TABLE ticket_sla_log SCHEMAFULL;
DEFINE FIELD ticket ON ticket_sla_log TYPE record<ticket> ASSERT $value != NONE;
DEFINE FIELD sla ON ticket_sla_log TYPE record<sla> ASSERT $value != NONE;
DEFINE FIELD event_type ON ticket_sla_log TYPE int; -- 1:Started, 2:Response, 3:Resolution, 4:Breach, 5:Warning
DEFINE FIELD event_date ON ticket_sla_log TYPE datetime DEFAULT time::now();
DEFINE FIELD target_date ON ticket_sla_log TYPE datetime;
DEFINE FIELD actual_date ON ticket_sla_log TYPE datetime;
DEFINE FIELD time_remaining_hours ON ticket_sla_log TYPE decimal;
DEFINE FIELD is_breach ON ticket_sla_log TYPE bool DEFAULT false;
DEFINE FIELD breach_reason ON ticket_sla_log TYPE string;
DEFINE FIELD notification_sent ON ticket_sla_log TYPE bool DEFAULT false;
DEFINE FIELD escalation_triggered ON ticket_sla_log TYPE bool DEFAULT false;
DEFINE FIELD created_at ON ticket_sla_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ticket_sla_log TYPE int DEFAULT 0;

DEFINE TABLE ticket_time_entry SCHEMAFULL;
DEFINE FIELD ticket ON ticket_time_entry TYPE record<ticket> ASSERT $value != NONE;
DEFINE FIELD user ON ticket_time_entry TYPE record<user> ASSERT $value != NONE;
DEFINE FIELD start_time ON ticket_time_entry TYPE datetime ASSERT $value != NONE;
DEFINE FIELD end_time ON ticket_time_entry TYPE datetime;
DEFINE FIELD duration_hours ON ticket_time_entry TYPE decimal DEFAULT 0.0;
DEFINE FIELD description ON ticket_time_entry TYPE string;
DEFINE FIELD activity_type ON ticket_time_entry TYPE string;
DEFINE FIELD is_billable ON ticket_time_entry TYPE bool DEFAULT false;
DEFINE FIELD billing_rate ON ticket_time_entry TYPE decimal;
DEFINE FIELD cost ON ticket_time_entry TYPE decimal DEFAULT 0.0;
DEFINE FIELD date ON ticket_time_entry TYPE date DEFAULT date::now();
DEFINE FIELD project ON ticket_time_entry TYPE record<project>;
DEFINE FIELD task ON ticket_time_entry TYPE record<project_task>;
DEFINE FIELD timer_session_id ON ticket_time_entry TYPE string;
DEFINE FIELD is_auto_generated ON ticket_time_entry TYPE bool DEFAULT false;
DEFINE FIELD approved_by ON ticket_time_entry TYPE record<user>;
DEFINE FIELD approval_date ON ticket_time_entry TYPE datetime;
DEFINE FIELD status_select ON ticket_time_entry TYPE int DEFAULT 1; -- 1:Draft, 2:Submitted, 3:Approved, 4:Rejected
DEFINE FIELD created_at ON ticket_time_entry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ticket_time_entry TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ticket_time_entry TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_ticket_seq ON ticket FIELDS ticket_seq;
DEFINE INDEX idx_ticket_subject ON ticket FIELDS subject;
DEFINE INDEX idx_ticket_type ON ticket FIELDS ticket_type;
DEFINE INDEX idx_ticket_status ON ticket FIELDS ticket_status;
DEFINE INDEX idx_ticket_priority ON ticket FIELDS priority_select;
DEFINE INDEX idx_ticket_assigned ON ticket FIELDS assigned_to_user;
DEFINE INDEX idx_ticket_reporter ON ticket FIELDS reporter_user;
DEFINE INDEX idx_ticket_customer ON ticket FIELDS customer;
DEFINE INDEX idx_ticket_company ON ticket FIELDS company;
DEFINE INDEX idx_ticket_team ON ticket FIELDS team;
DEFINE INDEX idx_ticket_project ON ticket FIELDS project;
DEFINE INDEX idx_ticket_sla ON ticket FIELDS sla;
DEFINE INDEX idx_ticket_start_date ON ticket FIELDS start_date_t;
DEFINE INDEX idx_ticket_end_date ON ticket FIELDS end_date_t;
DEFINE INDEX idx_ticket_deadline ON ticket FIELDS deadline_date;
DEFINE INDEX idx_ticket_progress ON ticket FIELDS progress_select;
DEFINE INDEX idx_ticket_resolved ON ticket FIELDS is_resolved;
DEFINE INDEX idx_ticket_closed ON ticket FIELDS is_closed;
DEFINE INDEX idx_ticket_resolution_date ON ticket FIELDS resolution_date;
DEFINE INDEX idx_ticket_closed_date ON ticket FIELDS closed_date;
DEFINE INDEX idx_ticket_impact ON ticket FIELDS impact_select;
DEFINE INDEX idx_ticket_urgency ON ticket FIELDS urgency_select;
DEFINE INDEX idx_ticket_escalated ON ticket FIELDS is_escalated;
DEFINE INDEX idx_ticket_urgent ON ticket FIELDS is_urgent;
DEFINE INDEX idx_ticket_created_at ON ticket FIELDS created_at;
DEFINE INDEX idx_ticket_updated_at ON ticket FIELDS updated_at;

DEFINE INDEX idx_ticket_status_name ON ticket_status FIELDS name;
DEFINE INDEX idx_ticket_status_sequence ON ticket_status FIELDS sequence;
DEFINE INDEX idx_ticket_status_default ON ticket_status FIELDS is_default;
DEFINE INDEX idx_ticket_status_closed ON ticket_status FIELDS is_closed;
DEFINE INDEX idx_ticket_status_resolved ON ticket_status FIELDS is_resolved;
DEFINE INDEX idx_ticket_status_type ON ticket_status FIELDS status_type_select;
DEFINE INDEX idx_ticket_status_final ON ticket_status FIELDS is_final_status;

DEFINE INDEX idx_ticket_type_name ON ticket_type FIELDS name;
DEFINE INDEX idx_ticket_type_sequence ON ticket_type FIELDS sequence;
DEFINE INDEX idx_ticket_type_default ON ticket_type FIELDS is_default;
DEFINE INDEX idx_ticket_type_priority ON ticket_type FIELDS default_priority;

DEFINE INDEX idx_sla_name ON sla FIELDS name;
DEFINE INDEX idx_sla_active ON sla FIELDS is_active;
DEFINE INDEX idx_sla_priority ON sla FIELDS priority_select;
DEFINE INDEX idx_sla_ticket_type ON sla FIELDS ticket_type;
DEFINE INDEX idx_sla_customer ON sla FIELDS customer;
DEFINE INDEX idx_sla_team ON sla FIELDS team;
DEFINE INDEX idx_sla_response_time ON sla FIELDS response_time_hours;
DEFINE INDEX idx_sla_resolution_time ON sla FIELDS resolution_time_hours;
DEFINE INDEX idx_sla_compliance ON sla FIELDS current_compliance_percentage;

DEFINE INDEX idx_sla_log_ticket ON ticket_sla_log FIELDS ticket;
DEFINE INDEX idx_sla_log_sla ON ticket_sla_log FIELDS sla;
DEFINE INDEX idx_sla_log_event_type ON ticket_sla_log FIELDS event_type;
DEFINE INDEX idx_sla_log_event_date ON ticket_sla_log FIELDS event_date;
DEFINE INDEX idx_sla_log_target_date ON ticket_sla_log FIELDS target_date;
DEFINE INDEX idx_sla_log_breach ON ticket_sla_log FIELDS is_breach;

DEFINE INDEX idx_time_entry_ticket ON ticket_time_entry FIELDS ticket;
DEFINE INDEX idx_time_entry_user ON ticket_time_entry FIELDS user;
DEFINE INDEX idx_time_entry_start_time ON ticket_time_entry FIELDS start_time;
DEFINE INDEX idx_time_entry_date ON ticket_time_entry FIELDS date;
DEFINE INDEX idx_time_entry_billable ON ticket_time_entry FIELDS is_billable;
DEFINE INDEX idx_time_entry_status ON ticket_time_entry FIELDS status_select;
DEFINE INDEX idx_time_entry_project ON ticket_time_entry FIELDS project; 