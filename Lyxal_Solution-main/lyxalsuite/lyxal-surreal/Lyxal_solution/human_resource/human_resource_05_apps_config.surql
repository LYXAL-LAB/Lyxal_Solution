-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 5 : APPS & CONFIGURATION
-- ================================================================================
-- Entités : AppTimesheet, AppLeave, AppEmployee, AppExpense, AppProject, ProjectConfig
-- Basé sur AppTimesheet.xml (2130 bytes), AppLeave.xml (1647 bytes), AppEmployee.xml (1458 bytes)
-- AppExpense.xml (864 bytes), AppProject.xml (1076 bytes), ProjectConfig.xml (1219 bytes)
-- ================================================================================

-- Application Timesheet (AppTimesheet.xml - 2130 bytes)
DEFINE TABLE app_timesheet SCHEMAFULL;
DEFINE FIELD app ON app_timesheet TYPE record<app> UNIQUE;
DEFINE FIELD is_automatic_mails ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_timesheet_submission ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_timesheet_validation ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_timesheet_refusal ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD timesheet_mail_notification ON app_timesheet TYPE record<template>;
DEFINE FIELD timesheet_validation_mail_notification ON app_timesheet TYPE record<template>;
DEFINE FIELD timesheet_refusal_mail_notification ON app_timesheet TYPE record<template>;
DEFINE FIELD timesheet_completion_mail_notification ON app_timesheet TYPE record<template>;
DEFINE FIELD is_timesheet_editor ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_multiple_timesheet_editor ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD timesheet_editor_user_list ON app_timesheet TYPE array<record<user>>;
DEFINE FIELD is_show_activity ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD is_show_duration ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD is_show_start_end_time ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_timesheet_line_create_invoice_line ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD default_invoicing_type_select ON app_timesheet TYPE int DEFAULT 1; -- 1:Normal, 2:Package, 3:Milestone
DEFINE FIELD is_timesheet_daily_limit ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD daily_working_hours_limit ON app_timesheet TYPE decimal DEFAULT 8.0;
DEFINE FIELD weekly_working_hours_limit ON app_timesheet TYPE decimal DEFAULT 35.0;
DEFINE FIELD is_weekend_working_allowed ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD is_holiday_working_allowed ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD overtime_calculation_rule ON app_timesheet TYPE string;
DEFINE FIELD is_timesheet_reminder_enabled ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD timesheet_reminder_frequency ON app_timesheet TYPE int DEFAULT 7; -- En jours
DEFINE FIELD timesheet_reminder_template ON app_timesheet TYPE record<template>;
DEFINE FIELD is_automatic_timesheet_generation ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD auto_timesheet_generation_rule ON app_timesheet TYPE string;
DEFINE FIELD is_project_timesheet_required ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD is_task_timesheet_required ON app_timesheet TYPE bool DEFAULT false;
DEFINE FIELD default_timesheet_status ON app_timesheet TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed
DEFINE FIELD is_billable_by_default ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD is_invoiceable_by_default ON app_timesheet TYPE bool DEFAULT true;
DEFINE FIELD timesheet_validation_workflow ON app_timesheet TYPE string;
DEFINE FIELD created_at ON app_timesheet TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_timesheet TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_timesheet TYPE int DEFAULT 0;

-- Application Congés (AppLeave.xml - 1647 bytes)
DEFINE TABLE app_leave SCHEMAFULL;
DEFINE FIELD app ON app_leave TYPE record<app> UNIQUE;
DEFINE FIELD company ON app_leave TYPE record<company>;
DEFINE FIELD leave_mail_notification ON app_leave TYPE record<template>;
DEFINE FIELD leave_validation_mail_notification ON app_leave TYPE record<template>;
DEFINE FIELD leave_refusal_mail_notification ON app_leave TYPE record<template>;
DEFINE FIELD leave_cancellation_mail_notification ON app_leave TYPE record<template>;
DEFINE FIELD is_automatic_mail_on_leave_request ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_leave_validation ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_leave_refusal ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_leave_cancellation ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD is_leave_request_validation_required ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_manager_approval_required ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_hr_approval_required ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD leave_validation_workflow ON app_leave TYPE string;
DEFINE FIELD automatic_leave_calculation ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD leave_year_start_month ON app_leave TYPE int DEFAULT 1; -- 1:January
DEFINE FIELD leave_accrual_calculation_method ON app_leave TYPE int DEFAULT 1; -- 1:Monthly, 2:Daily, 3:Annual
DEFINE FIELD default_annual_leave_days ON app_leave TYPE decimal DEFAULT 25.0;
DEFINE FIELD leave_carryover_policy ON app_leave TYPE int DEFAULT 1; -- 1:None, 2:Partial, 3:Full, 4:Expire
DEFINE FIELD max_carryover_days ON app_leave TYPE decimal DEFAULT 5.0;
DEFINE FIELD carryover_expiry_months ON app_leave TYPE int DEFAULT 3;
DEFINE FIELD is_negative_leave_allowed ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD max_negative_leave_days ON app_leave TYPE decimal DEFAULT 5.0;
DEFINE FIELD is_leave_balance_visible_to_employee ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_team_leave_calendar_enabled ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_leave_request_future_date_only ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD max_future_leave_request_days ON app_leave TYPE int DEFAULT 365;
DEFINE FIELD is_leave_overlap_check_enabled ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_public_holiday_excluded ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD is_weekend_excluded ON app_leave TYPE bool DEFAULT true;
DEFINE FIELD leave_request_reminder_days ON app_leave TYPE int DEFAULT 3;
DEFINE FIELD is_leave_planning_integration ON app_leave TYPE bool DEFAULT false;
DEFINE FIELD leave_planning_sync_frequency ON app_leave TYPE int DEFAULT 24; -- En heures
DEFINE FIELD created_at ON app_leave TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_leave TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_leave TYPE int DEFAULT 0;

-- Application Employé (AppEmployee.xml - 1458 bytes)
DEFINE TABLE app_employee SCHEMAFULL;
DEFINE FIELD app ON app_employee TYPE record<app> UNIQUE;
DEFINE FIELD company ON app_employee TYPE record<company>;
DEFINE FIELD employee_mail_notification ON app_employee TYPE record<template>;
DEFINE FIELD employee_welcome_mail_notification ON app_employee TYPE record<template>;
DEFINE FIELD employee_termination_mail_notification ON app_employee TYPE record<template>;
DEFINE FIELD is_automatic_mail_on_employee_creation ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_employee_termination ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD is_employee_self_service_enabled ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD is_employee_profile_editable ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD employee_editable_fields ON app_employee TYPE array<string>;
DEFINE FIELD is_employee_document_upload_enabled ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD max_document_size_mb ON app_employee TYPE int DEFAULT 10;
DEFINE FIELD allowed_document_types ON app_employee TYPE array<string>;
DEFINE FIELD is_employee_photo_mandatory ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD is_employee_id_card_mandatory ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD is_background_verification_required ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD background_verification_provider ON app_employee TYPE string;
DEFINE FIELD is_probation_period_tracking ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD probation_reminder_days ON app_employee TYPE int DEFAULT 7;
DEFINE FIELD is_contract_expiry_tracking ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD contract_expiry_reminder_days ON app_employee TYPE int DEFAULT 30;
DEFINE FIELD is_performance_review_enabled ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD performance_review_frequency_months ON app_employee TYPE int DEFAULT 12;
DEFINE FIELD is_employee_birthday_reminder ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD birthday_reminder_template ON app_employee TYPE record<template>;
DEFINE FIELD is_work_anniversary_reminder ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD work_anniversary_template ON app_employee TYPE record<template>;
DEFINE FIELD employee_onboarding_checklist ON app_employee TYPE array<string>;
DEFINE FIELD employee_offboarding_checklist ON app_employee TYPE array<string>;
DEFINE FIELD is_employee_hierarchy_enabled ON app_employee TYPE bool DEFAULT true;
DEFINE FIELD max_hierarchy_levels ON app_employee TYPE int DEFAULT 5;
DEFINE FIELD is_employee_skill_tracking ON app_employee TYPE bool DEFAULT false;
DEFINE FIELD skill_assessment_frequency_months ON app_employee TYPE int DEFAULT 6;
DEFINE FIELD created_at ON app_employee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_employee TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_employee TYPE int DEFAULT 0;

-- Application Frais (AppExpense.xml - 864 bytes)
DEFINE TABLE app_expense SCHEMAFULL;
DEFINE FIELD app ON app_expense TYPE record<app> UNIQUE;
DEFINE FIELD company ON app_expense TYPE record<company>;
DEFINE FIELD expense_mail_notification ON app_expense TYPE record<template>;
DEFINE FIELD expense_validation_mail_notification ON app_expense TYPE record<template>;
DEFINE FIELD expense_refusal_mail_notification ON app_expense TYPE record<template>;
DEFINE FIELD expense_reimbursement_mail_notification ON app_expense TYPE record<template>;
DEFINE FIELD is_automatic_mail_on_expense_submission ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_expense_validation ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_expense_refusal ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD is_automatic_mail_on_expense_reimbursement ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD is_expense_validation_required ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD expense_validation_workflow ON app_expense TYPE string;
DEFINE FIELD is_manager_approval_required ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD is_finance_approval_required ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD expense_approval_limit_manager ON app_expense TYPE decimal DEFAULT 1000.0;
DEFINE FIELD expense_approval_limit_finance ON app_expense TYPE decimal DEFAULT 5000.0;
DEFINE FIELD is_receipt_mandatory ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD receipt_mandatory_above_amount ON app_expense TYPE decimal DEFAULT 50.0;
DEFINE FIELD is_mileage_expense_enabled ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD default_mileage_rate ON app_expense TYPE decimal DEFAULT 0.35;
DEFINE FIELD mileage_calculation_method ON app_expense TYPE int DEFAULT 1; -- 1:Distance * Rate, 2:GPS Tracking
DEFINE FIELD is_advance_expense_tracking ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD expense_currency_conversion ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD default_expense_currency ON app_expense TYPE record<currency>;
DEFINE FIELD expense_reimbursement_method ON app_expense TYPE int DEFAULT 1; -- 1:Next Payroll, 2:Direct Transfer, 3:Petty Cash
DEFINE FIELD expense_reporting_deadline_days ON app_expense TYPE int DEFAULT 30;
DEFINE FIELD is_expense_analytics_enabled ON app_expense TYPE bool DEFAULT true;
DEFINE FIELD expense_budget_tracking ON app_expense TYPE bool DEFAULT false;
DEFINE FIELD created_at ON app_expense TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_expense TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_expense TYPE int DEFAULT 0;

-- Application Projet (AppProject.xml - 1076 bytes)
DEFINE TABLE app_project SCHEMAFULL;
DEFINE FIELD app ON app_project TYPE record<app> UNIQUE;
DEFINE FIELD company ON app_project TYPE record<company>;
DEFINE FIELD is_project_timesheet_enabled ON app_project TYPE bool DEFAULT true;
DEFINE FIELD is_project_expense_enabled ON app_project TYPE bool DEFAULT true;
DEFINE FIELD is_project_invoice_enabled ON app_project TYPE bool DEFAULT false;
DEFINE FIELD is_project_planning_enabled ON app_project TYPE bool DEFAULT false;
DEFINE FIELD project_planning_view_type ON app_project TYPE int DEFAULT 1; -- 1:Gantt, 2:Kanban, 3:Calendar, 4:List
DEFINE FIELD is_project_budget_tracking ON app_project TYPE bool DEFAULT false;
DEFINE FIELD budget_variance_threshold ON app_project TYPE decimal DEFAULT 10.0; -- En pourcentage
DEFINE FIELD is_project_milestone_tracking ON app_project TYPE bool DEFAULT false;
DEFINE FIELD is_project_resource_allocation ON app_project TYPE bool DEFAULT false;
DEFINE FIELD resource_allocation_method ON app_project TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic, 3:AI-based
DEFINE FIELD is_project_collaboration_enabled ON app_project TYPE bool DEFAULT true;
DEFINE FIELD project_collaboration_tools ON app_project TYPE array<string>;
DEFINE FIELD is_project_document_management ON app_project TYPE bool DEFAULT true;
DEFINE FIELD max_project_document_size_mb ON app_project TYPE int DEFAULT 100;
DEFINE FIELD project_document_versioning ON app_project TYPE bool DEFAULT true;
DEFINE FIELD is_project_risk_management ON app_project TYPE bool DEFAULT false;
DEFINE FIELD risk_assessment_frequency_days ON app_project TYPE int DEFAULT 30;
DEFINE FIELD is_project_quality_assurance ON app_project TYPE bool DEFAULT false;
DEFINE FIELD qa_checkpoint_frequency ON app_project TYPE int DEFAULT 7; -- En jours
DEFINE FIELD is_project_reporting_enabled ON app_project TYPE bool DEFAULT true;
DEFINE FIELD project_report_frequency ON app_project TYPE int DEFAULT 7; -- En jours
DEFINE FIELD project_status_update_reminder ON app_project TYPE int DEFAULT 3; -- En jours
DEFINE FIELD is_agile_methodology_enabled ON app_project TYPE bool DEFAULT false;
DEFINE FIELD sprint_duration_weeks ON app_project TYPE int DEFAULT 2;
DEFINE FIELD is_scrum_ceremonies_enabled ON app_project TYPE bool DEFAULT false;
DEFINE FIELD daily_standup_time ON app_project TYPE time;
DEFINE FIELD sprint_review_duration_hours ON app_project TYPE decimal DEFAULT 2.0;
DEFINE FIELD retrospective_duration_hours ON app_project TYPE decimal DEFAULT 1.5;
DEFINE FIELD created_at ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_project TYPE int DEFAULT 0;

-- Configuration Projet (ProjectConfig.xml - 1219 bytes)
DEFINE TABLE project_config SCHEMAFULL;
DEFINE FIELD company ON project_config TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD project_sequence ON project_config TYPE record<sequence>;
DEFINE FIELD task_sequence ON project_config TYPE record<sequence>;
DEFINE FIELD milestone_sequence ON project_config TYPE record<sequence>;
DEFINE FIELD is_project_code_auto_generation ON project_config TYPE bool DEFAULT true;
DEFINE FIELD project_code_prefix ON project_config TYPE string DEFAULT "PRJ";
DEFINE FIELD is_task_code_auto_generation ON project_config TYPE bool DEFAULT true;
DEFINE FIELD task_code_prefix ON project_config TYPE string DEFAULT "TSK";
DEFINE FIELD default_project_status ON project_config TYPE int DEFAULT 1; -- 1:Draft, 2:In Progress, 3:Completed, 4:Cancelled
DEFINE FIELD default_task_status ON project_config TYPE int DEFAULT 1; -- 1:New, 2:In Progress, 3:Completed, 4:Cancelled
DEFINE FIELD default_project_priority ON project_config TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD default_task_priority ON project_config TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD project_template_list ON project_config TYPE array<record<project_template>>;
DEFINE FIELD task_template_list ON project_config TYPE array<record<task_template>>;
DEFINE FIELD is_project_approval_required ON project_config TYPE bool DEFAULT false;
DEFINE FIELD project_approval_workflow ON project_config TYPE string;
DEFINE FIELD project_manager_role ON project_config TYPE record<role>;
DEFINE FIELD team_member_role ON project_config TYPE record<role>;
DEFINE FIELD stakeholder_role ON project_config TYPE record<role>;
DEFINE FIELD is_time_tracking_mandatory ON project_config TYPE bool DEFAULT true;
DEFINE FIELD is_expense_tracking_enabled ON project_config TYPE bool DEFAULT true;
DEFINE FIELD is_invoice_generation_enabled ON project_config TYPE bool DEFAULT false;
DEFINE FIELD invoice_generation_frequency ON project_config TYPE int DEFAULT 1; -- 1:Weekly, 2:Monthly, 3:Milestone-based
DEFINE FIELD project_closure_checklist ON project_config TYPE array<string>;
DEFINE FIELD project_archival_after_months ON project_config TYPE int DEFAULT 12;
DEFINE FIELD is_project_analytics_enabled ON project_config TYPE bool DEFAULT true;
DEFINE FIELD project_kpi_dashboard ON project_config TYPE bool DEFAULT true;
DEFINE FIELD project_performance_metrics ON project_config TYPE array<string>;
DEFINE FIELD is_client_portal_enabled ON project_config TYPE bool DEFAULT false;
DEFINE FIELD client_portal_features ON project_config TYPE array<string>;
DEFINE FIELD is_resource_conflict_detection ON project_config TYPE bool DEFAULT true;
DEFINE FIELD resource_allocation_algorithm ON project_config TYPE string;
DEFINE FIELD created_at ON project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_config TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_app_timesheet_app ON app_timesheet FIELDS app;
DEFINE INDEX idx_app_timesheet_editor ON app_timesheet FIELDS is_timesheet_editor;
DEFINE INDEX idx_app_timesheet_multiple_editor ON app_timesheet FIELDS is_multiple_timesheet_editor;
DEFINE INDEX idx_app_timesheet_daily_limit ON app_timesheet FIELDS is_timesheet_daily_limit;
DEFINE INDEX idx_app_timesheet_reminder ON app_timesheet FIELDS is_timesheet_reminder_enabled;

DEFINE INDEX idx_app_leave_app ON app_leave FIELDS app;
DEFINE INDEX idx_app_leave_company ON app_leave FIELDS company;
DEFINE INDEX idx_app_leave_validation ON app_leave FIELDS is_leave_request_validation_required;
DEFINE INDEX idx_app_leave_manager_approval ON app_leave FIELDS is_manager_approval_required;
DEFINE INDEX idx_app_leave_hr_approval ON app_leave FIELDS is_hr_approval_required;
DEFINE INDEX idx_app_leave_negative ON app_leave FIELDS is_negative_leave_allowed;

DEFINE INDEX idx_app_employee_app ON app_employee FIELDS app;
DEFINE INDEX idx_app_employee_company ON app_employee FIELDS company;
DEFINE INDEX idx_app_employee_self_service ON app_employee FIELDS is_employee_self_service_enabled;
DEFINE INDEX idx_app_employee_profile_editable ON app_employee FIELDS is_employee_profile_editable;
DEFINE INDEX idx_app_employee_probation_tracking ON app_employee FIELDS is_probation_period_tracking;
DEFINE INDEX idx_app_employee_contract_tracking ON app_employee FIELDS is_contract_expiry_tracking;

DEFINE INDEX idx_app_expense_app ON app_expense FIELDS app;
DEFINE INDEX idx_app_expense_company ON app_expense FIELDS company;
DEFINE INDEX idx_app_expense_validation ON app_expense FIELDS is_expense_validation_required;
DEFINE INDEX idx_app_expense_manager_approval ON app_expense FIELDS is_manager_approval_required;
DEFINE INDEX idx_app_expense_finance_approval ON app_expense FIELDS is_finance_approval_required;
DEFINE INDEX idx_app_expense_receipt_mandatory ON app_expense FIELDS is_receipt_mandatory;

DEFINE INDEX idx_app_project_app ON app_project FIELDS app;
DEFINE INDEX idx_app_project_company ON app_project FIELDS company;
DEFINE INDEX idx_app_project_timesheet ON app_project FIELDS is_project_timesheet_enabled;
DEFINE INDEX idx_app_project_expense ON app_project FIELDS is_project_expense_enabled;
DEFINE INDEX idx_app_project_planning ON app_project FIELDS is_project_planning_enabled;
DEFINE INDEX idx_app_project_budget ON app_project FIELDS is_project_budget_tracking;

DEFINE INDEX idx_project_config_company ON project_config FIELDS company;
DEFINE INDEX idx_project_config_approval ON project_config FIELDS is_project_approval_required;
DEFINE INDEX idx_project_config_time_tracking ON project_config FIELDS is_time_tracking_mandatory;
DEFINE INDEX idx_project_config_analytics ON project_config FIELDS is_project_analytics_enabled; 