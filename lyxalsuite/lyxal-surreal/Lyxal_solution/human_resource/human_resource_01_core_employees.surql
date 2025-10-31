-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 1 : CORE EMPLOYEES
-- ================================================================================
-- Entités principales : Employee, EmploymentContract, Employment, HRConfig, HRBatch
-- Basé sur Employee.xml (8678 bytes), EmploymentContract.xml (3927 bytes), Employment.xml (2499 bytes)
-- HRConfig.xml (9009 bytes), HRBatch.xml (3631 bytes)
-- ================================================================================

-- Configuration RH (HRConfig.xml - 9009 bytes)
DEFINE TABLE hr_config SCHEMAFULL;
DEFINE FIELD company ON hr_config TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD timesheet_company ON hr_config TYPE record<company>;
DEFINE FIELD expense_company ON hr_config TYPE record<company>;
DEFINE FIELD leave_company ON hr_config TYPE record<company>;
DEFINE FIELD employee_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD employment_contract_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD timesheet_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD expense_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD leave_request_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD extra_hours_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD employee_bonus_sequence ON hr_config TYPE record<sequence>;
DEFINE FIELD kilometric_allowance_rate_list ON hr_config TYPE array<record<kilometric_allowance_rate>>;
DEFINE FIELD smic_value_list ON hr_config TYPE array<record<smic_value>>;
DEFINE FIELD expense_limit_list ON hr_config TYPE array<record<expense_limit>>;
DEFINE FIELD lunch_voucher_mgt_limit ON hr_config TYPE decimal DEFAULT 0.0;
DEFINE FIELD lunch_voucher_advance_limit ON hr_config TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_leave_days_per_year ON hr_config TYPE decimal DEFAULT 25.0;
DEFINE FIELD leave_carryover_limit ON hr_config TYPE decimal DEFAULT 5.0;
DEFINE FIELD probation_period_default_days ON hr_config TYPE int DEFAULT 90;
DEFINE FIELD notice_period_default_days ON hr_config TYPE int DEFAULT 30;
DEFINE FIELD annual_working_days ON hr_config TYPE decimal DEFAULT 218.0;
DEFINE FIELD weekly_working_hours ON hr_config TYPE decimal DEFAULT 35.0;
DEFINE FIELD daily_working_hours ON hr_config TYPE decimal DEFAULT 7.0;
DEFINE FIELD overtime_rate_multiplier ON hr_config TYPE decimal DEFAULT 1.25;
DEFINE FIELD night_work_rate_multiplier ON hr_config TYPE decimal DEFAULT 1.1;
DEFINE FIELD sunday_work_rate_multiplier ON hr_config TYPE decimal DEFAULT 1.3;
DEFINE FIELD holiday_work_rate_multiplier ON hr_config TYPE decimal DEFAULT 1.5;
DEFINE FIELD enable_timesheet_validation ON hr_config TYPE bool DEFAULT true;
DEFINE FIELD enable_expense_validation ON hr_config TYPE bool DEFAULT true;
DEFINE FIELD enable_leave_validation ON hr_config TYPE bool DEFAULT true;
DEFINE FIELD timesheet_reminder_frequency ON hr_config TYPE int DEFAULT 7; -- En jours
DEFINE FIELD expense_report_deadline ON hr_config TYPE int DEFAULT 30; -- En jours
DEFINE FIELD leave_request_advance_notice ON hr_config TYPE int DEFAULT 7; -- En jours
DEFINE FIELD auto_calculate_leave_accrual ON hr_config TYPE bool DEFAULT true;
DEFINE FIELD leave_accrual_rate_per_month ON hr_config TYPE decimal DEFAULT 2.08; -- 25 jours / 12 mois
DEFINE FIELD created_at ON hr_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON hr_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON hr_config TYPE int DEFAULT 0;

-- Employé principal (Employee.xml - 8678 bytes)
DEFINE TABLE employee SCHEMAFULL;
DEFINE FIELD employee_seq ON employee TYPE string READONLY;
DEFINE FIELD contact_partner ON employee TYPE record<partner>;
DEFINE FIELD user ON employee TYPE record<user>;
DEFINE FIELD main_employment_contract ON employee TYPE record<employment_contract>;
DEFINE FIELD employment_contract_list ON employee TYPE array<record<employment_contract>>;
DEFINE FIELD hiring_date ON employee TYPE date;
DEFINE FIELD birth_date ON employee TYPE date;
DEFINE FIELD age ON employee TYPE int DEFAULT 0;
DEFINE FIELD place_of_birth ON employee TYPE string;
DEFINE FIELD country_of_birth ON employee TYPE record<country>;
DEFINE FIELD marital_status ON employee TYPE int DEFAULT 1; -- 1:Single, 2:Married, 3:Divorced, 4:Widowed
DEFINE FIELD spouse_name ON employee TYPE string;
DEFINE FIELD children_number ON employee TYPE int DEFAULT 0;
DEFINE FIELD emergency_contact ON employee TYPE string;
DEFINE FIELD emergency_number ON employee TYPE string;
DEFINE FIELD company ON employee TYPE record<company>;
DEFINE FIELD department ON employee TYPE record<department>;
DEFINE FIELD manager ON employee TYPE record<employee>;
DEFINE FIELD employee_manager_list ON employee TYPE array<record<employee>>;
DEFINE FIELD hr_manager ON employee TYPE record<employee>;
DEFINE FIELD weekly_planning ON employee TYPE record<weekly_planning>;
DEFINE FIELD public_holiday_events_planning ON employee TYPE record<events_planning>;
DEFINE FIELD timesheet_reminder ON employee TYPE record<timesheet_reminder>;
DEFINE FIELD daily_work_hours ON employee TYPE decimal DEFAULT 8.0;
DEFINE FIELD weekly_work_hours ON employee TYPE decimal DEFAULT 40.0;
DEFINE FIELD salary ON employee TYPE decimal DEFAULT 0.0;
DEFINE FIELD hourly_rate ON employee TYPE decimal DEFAULT 0.0;
DEFINE FIELD pay_grid ON employee TYPE record<pay_grid>;
DEFINE FIELD qualification_list ON employee TYPE array<record<qualification>>;
DEFINE FIELD medical_visit_list ON employee TYPE array<record<medical_visit>>;
DEFINE FIELD bank_details ON employee TYPE record<bank_details>;
DEFINE FIELD social_security_number ON employee TYPE string;
DEFINE FIELD registration_number_of_medical_insurance ON employee TYPE string;
DEFINE FIELD employee_vehicle_list ON employee TYPE array<record<employee_vehicle>>;
DEFINE FIELD lunch_voucher_format_select ON employee TYPE int DEFAULT 1; -- 1:Paper, 2:Card
DEFINE FIELD lunch_voucher_mgt_list ON employee TYPE array<record<lunch_voucher_mgt>>;
DEFINE FIELD annual_report ON employee TYPE record<meta_file>;
DEFINE FIELD employment_contract_sub_type ON employee TYPE record<employment_contract_sub_type>;
DEFINE FIELD export_code ON employee TYPE string;
DEFINE FIELD photo ON employee TYPE record<meta_file>;
DEFINE FIELD negative_value_leave ON employee TYPE bool DEFAULT false;
DEFINE FIELD time_logging_preference_select ON employee TYPE int DEFAULT 1; -- 1:Days, 2:Hours
DEFINE FIELD employee_file_list ON employee TYPE array<record<employee_file>>;
DEFINE FIELD leave_line_list ON employee TYPE array<record<leave_line>>;
DEFINE FIELD employee_bonus_mgt_list ON employee TYPE array<record<employee_bonus_mgt>>;
DEFINE FIELD employee_advance_list ON employee TYPE array<record<employee_advance>>;
DEFINE FIELD extra_hours_list ON employee TYPE array<record<extra_hours>>;
DEFINE FIELD employee_cost_list ON employee TYPE array<record<other_costs_employee>>;
DEFINE FIELD kilometric_log_list ON employee TYPE array<record<kilometric_log>>;
DEFINE FIELD lunch_voucher_advance_list ON employee TYPE array<record<lunch_voucher_advance>>;
DEFINE FIELD expense_list ON employee TYPE array<record<expense>>;
DEFINE FIELD timesheet_list ON employee TYPE array<record<timesheet>>;
DEFINE FIELD project_planning_time_list ON employee TYPE array<record<project_planning_time>>;
DEFINE FIELD dpae_list ON employee TYPE array<record<dpae>>;
DEFINE FIELD mobile_phone ON employee TYPE string;
DEFINE FIELD phone_at_customer ON employee TYPE string;
DEFINE FIELD email_address ON employee TYPE string;
DEFINE FIELD product ON employee TYPE record<product>;
DEFINE FIELD timesheet_imput_method ON employee TYPE int DEFAULT 1; -- 1:Manual, 2:Import, 3:Timer
DEFINE FIELD professional_competence ON employee TYPE string;
DEFINE FIELD comments ON employee TYPE string;
DEFINE FIELD fixed_pro_rate ON employee TYPE decimal DEFAULT 1.0;
DEFINE FIELD public_holiday_event_planing_list ON employee TYPE array<record<public_holiday_event_planning>>;
DEFINE FIELD is_freelance ON employee TYPE bool DEFAULT false;
DEFINE FIELD external_id ON employee TYPE string;
DEFINE FIELD step_by_step_select ON employee TYPE int DEFAULT 1;
DEFINE FIELD status_select ON employee TYPE int DEFAULT 1; -- 1:Active, 2:Terminated, 3:Archived
DEFINE FIELD termination_date ON employee TYPE date;
DEFINE FIELD termination_reason ON employee TYPE record<end_of_contract_reason>;
DEFINE FIELD created_at ON employee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee TYPE int DEFAULT 0;

-- Contrat d'emploi (EmploymentContract.xml - 3927 bytes)
DEFINE TABLE employment_contract SCHEMAFULL;
DEFINE FIELD contract_id ON employment_contract TYPE string UNIQUE;
DEFINE FIELD employee ON employment_contract TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON employment_contract TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD employment_contract_type ON employment_contract TYPE record<employment_contract_type>;
DEFINE FIELD employment_contract_sub_type ON employment_contract TYPE record<employment_contract_sub_type>;
DEFINE FIELD employment_contract_template ON employment_contract TYPE record<employment_contract_template>;
DEFINE FIELD start_date ON employment_contract TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON employment_contract TYPE date;
DEFINE FIELD contract_period_total_in_month ON employment_contract TYPE int;
DEFINE FIELD renewable_contract ON employment_contract TYPE bool DEFAULT false;
DEFINE FIELD renewable_times ON employment_contract TYPE int DEFAULT 0;
DEFINE FIELD trial_period_duration ON employment_contract TYPE int; -- En jours
DEFINE FIELD notice_period_duration ON employment_contract TYPE int; -- En jours
DEFINE FIELD salary ON employment_contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_type ON employment_contract TYPE int DEFAULT 1; -- 1:Monthly, 2:Annual, 3:Hourly, 4:Daily
DEFINE FIELD weekly_work_hours ON employment_contract TYPE decimal DEFAULT 35.0;
DEFINE FIELD daily_work_hours ON employment_contract TYPE decimal DEFAULT 7.0;
DEFINE FIELD pay_company ON employment_contract TYPE record<company>;
DEFINE FIELD pay_grid ON employment_contract TYPE record<pay_grid>;
DEFINE FIELD amendment_type_list ON employment_contract TYPE array<record<employment_amendment_type>>;
DEFINE FIELD amendment_date ON employment_contract TYPE date;
DEFINE FIELD collective_agreement ON employment_contract TYPE record<collective_agreement>;
DEFINE FIELD executive_status_select ON employment_contract TYPE int DEFAULT 1; -- 1:Non-executive, 2:Executive, 3:Senior Executive
DEFINE FIELD contract_file ON employment_contract TYPE record<meta_file>;
DEFINE FIELD insurance_cbss ON employment_contract TYPE string;
DEFINE FIELD lunch_voucher ON employment_contract TYPE bool DEFAULT false;
DEFINE FIELD lunch_voucher_number ON employment_contract TYPE int DEFAULT 0;
DEFINE FIELD coeff ON employment_contract TYPE decimal DEFAULT 1.0;
DEFINE FIELD is_signatured ON employment_contract TYPE bool DEFAULT false;
DEFINE FIELD signature_date ON employment_contract TYPE date;
DEFINE FIELD contract_version ON employment_contract TYPE string DEFAULT "1.0";
DEFINE FIELD notes ON employment_contract TYPE string;
DEFINE FIELD status_select ON employment_contract TYPE int DEFAULT 1; -- 1:Draft, 2:Active, 3:Terminated, 4:Suspended
DEFINE FIELD probation_period_list ON employment_contract TYPE array<record<probation_period>>;
DEFINE FIELD created_at ON employment_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employment_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employment_contract TYPE int DEFAULT 0;

-- Emploi/Poste (Employment.xml - 2499 bytes)  
DEFINE TABLE employment SCHEMAFULL;
DEFINE FIELD employee ON employment TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON employment TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD position ON employment TYPE string ASSERT $value != NONE;
DEFINE FIELD department ON employment TYPE record<department>;
DEFINE FIELD manager ON employment TYPE record<employee>;
DEFINE FIELD job_category ON employment TYPE string;
DEFINE FIELD job_level ON employment TYPE string;
DEFINE FIELD job_title ON employment TYPE string;
DEFINE FIELD start_date ON employment TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON employment TYPE date;
DEFINE FIELD is_current ON employment TYPE bool DEFAULT true;
DEFINE FIELD salary ON employment TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_currency ON employment TYPE record<currency>;
DEFINE FIELD work_location ON employment TYPE string;
DEFINE FIELD work_location_address ON employment TYPE string;
DEFINE FIELD remote_work_percentage ON employment TYPE decimal DEFAULT 0.0;
DEFINE FIELD responsibilities ON employment TYPE string;
DEFINE FIELD skills_required ON employment TYPE string;
DEFINE FIELD performance_goals ON employment TYPE string;
DEFINE FIELD reporting_structure ON employment TYPE string;
DEFINE FIELD team_members ON employment TYPE array<record<employee>>;
DEFINE FIELD employment_status ON employment TYPE int DEFAULT 1; -- 1:Full-time, 2:Part-time, 3:Contract, 4:Temporary, 5:Intern
DEFINE FIELD work_schedule ON employment TYPE string;
DEFINE FIELD overtime_eligible ON employment TYPE bool DEFAULT true;
DEFINE FIELD benefits_package ON employment TYPE string;
DEFINE FIELD created_at ON employment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employment TYPE int DEFAULT 0;

-- Batch RH (HRBatch.xml - 3631 bytes)
DEFINE TABLE hr_batch SCHEMAFULL;
DEFINE FIELD code ON hr_batch TYPE string UNIQUE;
DEFINE FIELD action_select ON hr_batch TYPE int DEFAULT 1; -- 1:Leave Management, 2:Expense Export, 3:Timesheet Processing, 4:Payroll Preparation
DEFINE FIELD hr_config ON hr_batch TYPE record<hr_config>;
DEFINE FIELD company ON hr_batch TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD description ON hr_batch TYPE string;
DEFINE FIELD scheduled_date ON hr_batch TYPE datetime;
DEFINE FIELD processing_date ON hr_batch TYPE datetime;
DEFINE FIELD status_select ON hr_batch TYPE int DEFAULT 1; -- 1:Pending, 2:Running, 3:Completed, 4:Error, 5:Cancelled
DEFINE FIELD processed_records ON hr_batch TYPE int DEFAULT 0;
DEFINE FIELD total_records ON hr_batch TYPE int DEFAULT 0;
DEFINE FIELD error_count ON hr_batch TYPE int DEFAULT 0;
DEFINE FIELD batch_log ON hr_batch TYPE string;
DEFINE FIELD error_log ON hr_batch TYPE string;
DEFINE FIELD employee_filter ON hr_batch TYPE string;
DEFINE FIELD department_filter ON hr_batch TYPE record<department>;
DEFINE FIELD date_from ON hr_batch TYPE date;
DEFINE FIELD date_to ON hr_batch TYPE date;
DEFINE FIELD auto_execute ON hr_batch TYPE bool DEFAULT false;
DEFINE FIELD notification_email ON hr_batch TYPE string;
DEFINE FIELD send_notification ON hr_batch TYPE bool DEFAULT true;
DEFINE FIELD created_by ON hr_batch TYPE record<user>;
DEFINE FIELD executed_by ON hr_batch TYPE record<user>;
DEFINE FIELD created_at ON hr_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON hr_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON hr_batch TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_hr_config_company ON hr_config FIELDS company;
DEFINE INDEX idx_employee_seq ON employee FIELDS employee_seq;
DEFINE INDEX idx_employee_contact ON employee FIELDS contact_partner;
DEFINE INDEX idx_employee_user ON employee FIELDS user;
DEFINE INDEX idx_employee_company ON employee FIELDS company;
DEFINE INDEX idx_employee_department ON employee FIELDS department;
DEFINE INDEX idx_employee_manager ON employee FIELDS manager;
DEFINE INDEX idx_employee_hr_manager ON employee FIELDS hr_manager;
DEFINE INDEX idx_employee_hiring_date ON employee FIELDS hiring_date;
DEFINE INDEX idx_employee_birth_date ON employee FIELDS birth_date;
DEFINE INDEX idx_employee_status ON employee FIELDS status_select;
DEFINE INDEX idx_employee_termination_date ON employee FIELDS termination_date;
DEFINE INDEX idx_employee_social_security ON employee FIELDS social_security_number;
DEFINE INDEX idx_employee_external_id ON employee FIELDS external_id;

DEFINE INDEX idx_employment_contract_id ON employment_contract FIELDS contract_id;
DEFINE INDEX idx_employment_contract_employee ON employment_contract FIELDS employee;
DEFINE INDEX idx_employment_contract_company ON employment_contract FIELDS company;
DEFINE INDEX idx_employment_contract_type ON employment_contract FIELDS employment_contract_type;
DEFINE INDEX idx_employment_contract_start_date ON employment_contract FIELDS start_date;
DEFINE INDEX idx_employment_contract_end_date ON employment_contract FIELDS end_date;
DEFINE INDEX idx_employment_contract_status ON employment_contract FIELDS status_select;
DEFINE INDEX idx_employment_contract_signature ON employment_contract FIELDS is_signatured;

DEFINE INDEX idx_employment_employee ON employment FIELDS employee;
DEFINE INDEX idx_employment_company ON employment FIELDS company;
DEFINE INDEX idx_employment_position ON employment FIELDS position;
DEFINE INDEX idx_employment_department ON employment FIELDS department;
DEFINE INDEX idx_employment_manager ON employment FIELDS manager;
DEFINE INDEX idx_employment_start_date ON employment FIELDS start_date;
DEFINE INDEX idx_employment_current ON employment FIELDS is_current;
DEFINE INDEX idx_employment_status ON employment FIELDS employment_status;

DEFINE INDEX idx_hr_batch_code ON hr_batch FIELDS code;
DEFINE INDEX idx_hr_batch_action ON hr_batch FIELDS action_select;
DEFINE INDEX idx_hr_batch_company ON hr_batch FIELDS company;
DEFINE INDEX idx_hr_batch_status ON hr_batch FIELDS status_select;
DEFINE INDEX idx_hr_batch_scheduled ON hr_batch FIELDS scheduled_date;
DEFINE INDEX idx_hr_batch_processed ON hr_batch FIELDS processing_date; 