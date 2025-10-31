-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 3 : LEAVES & QUALIFICATIONS
-- ================================================================================
-- Entités : LeaveRequest, LeaveLine, LeaveReason, Qualification, QualificationLevel, MedicalVisit
-- Basé sur LeaveRequest.xml (3606 bytes), LeaveLine.xml (1148 bytes), LeaveReason.xml (2406 bytes)
-- Qualification.xml (1198 bytes), QualificationLevel.xml (1112 bytes), MedicalVisit.xml (1432 bytes)
-- ================================================================================

-- Demande de congé (LeaveRequest.xml - 3606 bytes)
DEFINE TABLE leave_request SCHEMAFULL;
DEFINE FIELD leave_request_seq ON leave_request TYPE string READONLY;
DEFINE FIELD employee ON leave_request TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON leave_request TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD user ON leave_request TYPE record<user>;
DEFINE FIELD leave_reason ON leave_request TYPE record<leave_reason> ASSERT $value != NONE;
DEFINE FIELD from_date_select ON leave_request TYPE int DEFAULT 1; -- 1:Morning, 2:Afternoon
DEFINE FIELD to_date_select ON leave_request TYPE int DEFAULT 2; -- 1:Morning, 2:Afternoon
DEFINE FIELD from_date ON leave_request TYPE date ASSERT $value != NONE;
DEFINE FIELD to_date ON leave_request TYPE date ASSERT $value != NONE;
DEFINE FIELD duration ON leave_request TYPE decimal DEFAULT 0.0;
DEFINE FIELD duration_type_select ON leave_request TYPE int DEFAULT 1; -- 1:Days, 2:Hours
DEFINE FIELD status_select ON leave_request TYPE int DEFAULT 1; -- 1:Draft, 2:Awaiting Validation, 3:Validated, 4:Refused, 5:Cancelled
DEFINE FIELD request_date ON leave_request TYPE date DEFAULT time::now()::date;
DEFINE FIELD validation_date ON leave_request TYPE datetime;
DEFINE FIELD validated_by ON leave_request TYPE record<user>;
DEFINE FIELD refusal_date ON leave_request TYPE datetime;
DEFINE FIELD refusal_reason ON leave_request TYPE string;
DEFINE FIELD refused_by ON leave_request TYPE record<user>;
DEFINE FIELD comments ON leave_request TYPE string;
DEFINE FIELD manager_comment ON leave_request TYPE string;
DEFINE FIELD hr_comment ON leave_request TYPE string;
DEFINE FIELD attachment_list ON leave_request TYPE array<record<meta_file>>;
DEFINE FIELD substitute_employee ON leave_request TYPE record<employee>;
DEFINE FIELD substitute_instructions ON leave_request TYPE string;
DEFINE FIELD medical_certificate_required ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD medical_certificate ON leave_request TYPE record<meta_file>;
DEFINE FIELD is_emergency ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD emergency_reason ON leave_request TYPE string;
DEFINE FIELD leave_balance_before ON leave_request TYPE decimal DEFAULT 0.0;
DEFINE FIELD leave_balance_after ON leave_request TYPE decimal DEFAULT 0.0;
DEFINE FIELD deduction_from_salary ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD unpaid_leave ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD half_day_morning ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD half_day_afternoon ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD return_date ON leave_request TYPE date;
DEFINE FIELD actual_return_date ON leave_request TYPE date;
DEFINE FIELD extend_request ON leave_request TYPE record<leave_request>;
DEFINE FIELD original_request ON leave_request TYPE record<leave_request>;
DEFINE FIELD notification_sent ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD reminder_sent ON leave_request TYPE bool DEFAULT false;
DEFINE FIELD created_at ON leave_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON leave_request TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON leave_request TYPE int DEFAULT 0;

-- Ligne de congé (LeaveLine.xml - 1148 bytes)
DEFINE TABLE leave_line SCHEMAFULL;
DEFINE FIELD employee ON leave_line TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD leave_reason ON leave_line TYPE record<leave_reason> ASSERT $value != NONE;
DEFINE FIELD name ON leave_line TYPE string;
DEFINE FIELD date ON leave_line TYPE date ASSERT $value != NONE;
DEFINE FIELD value ON leave_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD quantity ON leave_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD unit ON leave_line TYPE int DEFAULT 1; -- 1:Days, 2:Hours
DEFINE FIELD type_select ON leave_line TYPE int DEFAULT 1; -- 1:Accrual, 2:Taken, 3:Balance Adjustment, 4:Carryover
DEFINE FIELD description ON leave_line TYPE string;
DEFINE FIELD leave_request ON leave_line TYPE record<leave_request>;
DEFINE FIELD allocation_line ON leave_line TYPE record<allocation_line>;
DEFINE FIELD year ON leave_line TYPE record<year>;
DEFINE FIELD period ON leave_line TYPE record<period>;
DEFINE FIELD balance_before ON leave_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD balance_after ON leave_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_manual_entry ON leave_line TYPE bool DEFAULT false;
DEFINE FIELD reference ON leave_line TYPE string;
DEFINE FIELD validated ON leave_line TYPE bool DEFAULT false;
DEFINE FIELD validation_date ON leave_line TYPE datetime;
DEFINE FIELD validated_by ON leave_line TYPE record<user>;
DEFINE FIELD created_at ON leave_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON leave_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON leave_line TYPE int DEFAULT 0;

-- Motif de congé (LeaveReason.xml - 2406 bytes)
DEFINE TABLE leave_reason SCHEMAFULL;
DEFINE FIELD name ON leave_reason TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON leave_reason TYPE string UNIQUE;
DEFINE FIELD description ON leave_reason TYPE string;
DEFINE FIELD unit_select ON leave_reason TYPE int DEFAULT 1; -- 1:Days, 2:Hours
DEFINE FIELD type_select ON leave_reason TYPE int DEFAULT 1; -- 1:Paid Leave, 2:Unpaid Leave, 3:Sick Leave, 4:Maternity Leave, 5:Special Leave
DEFINE FIELD max_duration_per_year ON leave_reason TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_duration_per_request ON leave_reason TYPE decimal DEFAULT 0.0;
DEFINE FIELD min_duration_per_request ON leave_reason TYPE decimal DEFAULT 0.5;
DEFINE FIELD advance_notice_days ON leave_reason TYPE int DEFAULT 7;
DEFINE FIELD requires_medical_certificate ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD medical_certificate_mandatory_after_days ON leave_reason TYPE int DEFAULT 3;
DEFINE FIELD deductible_from_annual_leave ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD is_paid ON leave_reason TYPE bool DEFAULT true;
DEFINE FIELD salary_percentage ON leave_reason TYPE decimal DEFAULT 100.0;
DEFINE FIELD accrual_rate_per_month ON leave_reason TYPE decimal DEFAULT 0.0;
DEFINE FIELD accrual_start_date ON leave_reason TYPE date;
DEFINE FIELD allow_negative_balance ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD carryover_allowed ON leave_reason TYPE bool DEFAULT true;
DEFINE FIELD carryover_limit ON leave_reason TYPE decimal DEFAULT 5.0;
DEFINE FIELD carryover_expiry_months ON leave_reason TYPE int DEFAULT 3;
DEFINE FIELD weekend_included ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD holiday_included ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD approval_required ON leave_reason TYPE bool DEFAULT true;
DEFINE FIELD manager_approval_required ON leave_reason TYPE bool DEFAULT true;
DEFINE FIELD hr_approval_required ON leave_reason TYPE bool DEFAULT false;
DEFINE FIELD auto_approval_conditions ON leave_reason TYPE string;
DEFINE FIELD notification_template ON leave_reason TYPE record<template>;
DEFINE FIELD color_code ON leave_reason TYPE string DEFAULT "#3498db";
DEFINE FIELD icon ON leave_reason TYPE string;
DEFINE FIELD is_active ON leave_reason TYPE bool DEFAULT true;
DEFINE FIELD company_list ON leave_reason TYPE array<record<company>>;
DEFINE FIELD employee_category_list ON leave_reason TYPE array<string>;
DEFINE FIELD gender_restriction ON leave_reason TYPE int DEFAULT 0; -- 0:None, 1:Male Only, 2:Female Only
DEFINE FIELD min_service_months ON leave_reason TYPE int DEFAULT 0;
DEFINE FIELD created_at ON leave_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON leave_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON leave_reason TYPE int DEFAULT 0;

-- Qualification (Qualification.xml - 1198 bytes)
DEFINE TABLE qualification SCHEMAFULL;
DEFINE FIELD name ON qualification TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON qualification TYPE string UNIQUE;
DEFINE FIELD description ON qualification TYPE string;
DEFINE FIELD qualification_level ON qualification TYPE record<qualification_level>;
DEFINE FIELD qualification_type ON qualification TYPE string;
DEFINE FIELD domain ON qualification TYPE string;
DEFINE FIELD institution ON qualification TYPE string;
DEFINE FIELD certification_body ON qualification TYPE string;
DEFINE FIELD obtained_date ON qualification TYPE date;
DEFINE FIELD expiry_date ON qualification TYPE date;
DEFINE FIELD certificate_number ON qualification TYPE string;
DEFINE FIELD is_mandatory ON qualification TYPE bool DEFAULT false;
DEFINE FIELD is_renewable ON qualification TYPE bool DEFAULT false;
DEFINE FIELD renewal_period_months ON qualification TYPE int DEFAULT 0;
DEFINE FIELD renewal_reminder_days ON qualification TYPE int DEFAULT 30;
DEFINE FIELD skills_acquired ON qualification TYPE string;
DEFINE FIELD prerequisites ON qualification TYPE string;
DEFINE FIELD duration_hours ON qualification TYPE decimal DEFAULT 0.0;
DEFINE FIELD cost ON qualification TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON qualification TYPE record<currency>;
DEFINE FIELD certificate_file ON qualification TYPE record<meta_file>;
DEFINE FIELD is_active ON qualification TYPE bool DEFAULT true;
DEFINE FIELD validation_required ON qualification TYPE bool DEFAULT false;
DEFINE FIELD validated_by ON qualification TYPE record<user>;
DEFINE FIELD validation_date ON qualification TYPE datetime;
DEFINE FIELD employee_list ON qualification TYPE array<record<employee>>;
DEFINE FIELD created_at ON qualification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON qualification TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON qualification TYPE int DEFAULT 0;

-- Niveau de qualification (QualificationLevel.xml - 1112 bytes)
DEFINE TABLE qualification_level SCHEMAFULL;
DEFINE FIELD name ON qualification_level TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON qualification_level TYPE string UNIQUE;
DEFINE FIELD description ON qualification_level TYPE string;
DEFINE FIELD level_number ON qualification_level TYPE int ASSERT $value != NONE;
DEFINE FIELD minimum_experience_years ON qualification_level TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_range_min ON qualification_level TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_range_max ON qualification_level TYPE decimal DEFAULT 0.0;
DEFINE FIELD responsibilities ON qualification_level TYPE string;
DEFINE FIELD competencies_required ON qualification_level TYPE string;
DEFINE FIELD next_level ON qualification_level TYPE record<qualification_level>;
DEFINE FIELD previous_level ON qualification_level TYPE record<qualification_level>;
DEFINE FIELD promotion_criteria ON qualification_level TYPE string;
DEFINE FIELD training_requirements ON qualification_level TYPE string;
DEFINE FIELD performance_indicators ON qualification_level TYPE string;
DEFINE FIELD career_path ON qualification_level TYPE string;
DEFINE FIELD is_active ON qualification_level TYPE bool DEFAULT true;
DEFINE FIELD color_code ON qualification_level TYPE string DEFAULT "#2ecc71";
DEFINE FIELD created_at ON qualification_level TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON qualification_level TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON qualification_level TYPE int DEFAULT 0;

-- Visite médicale (MedicalVisit.xml - 1432 bytes)
DEFINE TABLE medical_visit SCHEMAFULL;
DEFINE FIELD employee ON medical_visit TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD visit_date ON medical_visit TYPE date ASSERT $value != NONE;
DEFINE FIELD visit_type ON medical_visit TYPE int DEFAULT 1; -- 1:Pre-employment, 2:Periodic, 3:Return to work, 4:Fitness for duty, 5:Special
DEFINE FIELD medical_visit_reason ON medical_visit TYPE record<medical_visit_reason>;
DEFINE FIELD doctor_name ON medical_visit TYPE string;
DEFINE FIELD medical_center ON medical_visit TYPE string;
DEFINE FIELD medical_center_address ON medical_visit TYPE string;
DEFINE FIELD visit_duration ON medical_visit TYPE decimal DEFAULT 0.0; -- En heures
DEFINE FIELD fitness_result ON medical_visit TYPE int DEFAULT 1; -- 1:Fit, 2:Fit with restrictions, 3:Temporarily unfit, 4:Permanently unfit
DEFINE FIELD restrictions ON medical_visit TYPE string;
DEFINE FIELD recommendations ON medical_visit TYPE string;
DEFINE FIELD next_visit_date ON medical_visit TYPE date;
DEFINE FIELD visit_frequency_months ON medical_visit TYPE int DEFAULT 12;
DEFINE FIELD medical_certificate ON medical_visit TYPE record<meta_file>;
DEFINE FIELD confidential_notes ON medical_visit TYPE string;
DEFINE FIELD vaccination_updates ON medical_visit TYPE string;
DEFINE FIELD allergies_identified ON medical_visit TYPE string;
DEFINE FIELD chronic_conditions ON medical_visit TYPE string;
DEFINE FIELD occupational_hazards_exposure ON medical_visit TYPE string;
DEFINE FIELD protective_equipment_required ON medical_visit TYPE string;
DEFINE FIELD work_environment_adaptations ON medical_visit TYPE string;
DEFINE FIELD follow_up_required ON medical_visit TYPE bool DEFAULT false;
DEFINE FIELD follow_up_instructions ON medical_visit TYPE string;
DEFINE FIELD cost ON medical_visit TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON medical_visit TYPE record<currency>;
DEFINE FIELD reimbursement_status ON medical_visit TYPE int DEFAULT 1; -- 1:Pending, 2:Approved, 3:Reimbursed, 4:Rejected
DEFINE FIELD hr_notes ON medical_visit TYPE string;
DEFINE FIELD is_confidential ON medical_visit TYPE bool DEFAULT true;
DEFINE FIELD created_at ON medical_visit TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON medical_visit TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON medical_visit TYPE int DEFAULT 0;

-- Table de support
DEFINE TABLE medical_visit_reason SCHEMAFULL;
DEFINE FIELD name ON medical_visit_reason TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON medical_visit_reason TYPE string UNIQUE;
DEFINE FIELD description ON medical_visit_reason TYPE string;
DEFINE FIELD is_mandatory ON medical_visit_reason TYPE bool DEFAULT false;
DEFINE FIELD frequency_months ON medical_visit_reason TYPE int DEFAULT 12;
DEFINE FIELD requires_follow_up ON medical_visit_reason TYPE bool DEFAULT false;
DEFINE FIELD is_active ON medical_visit_reason TYPE bool DEFAULT true;
DEFINE FIELD created_at ON medical_visit_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON medical_visit_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON medical_visit_reason TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_leave_request_seq ON leave_request FIELDS leave_request_seq;
DEFINE INDEX idx_leave_request_employee ON leave_request FIELDS employee;
DEFINE INDEX idx_leave_request_company ON leave_request FIELDS company;
DEFINE INDEX idx_leave_request_dates ON leave_request FIELDS from_date, to_date;
DEFINE INDEX idx_leave_request_status ON leave_request FIELDS status_select;
DEFINE INDEX idx_leave_request_reason ON leave_request FIELDS leave_reason;
DEFINE INDEX idx_leave_request_validation ON leave_request FIELDS validation_date;
DEFINE INDEX idx_leave_request_emergency ON leave_request FIELDS is_emergency;

DEFINE INDEX idx_leave_line_employee ON leave_line FIELDS employee;
DEFINE INDEX idx_leave_line_reason ON leave_line FIELDS leave_reason;
DEFINE INDEX idx_leave_line_date ON leave_line FIELDS date;
DEFINE INDEX idx_leave_line_type ON leave_line FIELDS type_select;
DEFINE INDEX idx_leave_line_request ON leave_line FIELDS leave_request;
DEFINE INDEX idx_leave_line_validated ON leave_line FIELDS validated;

DEFINE INDEX idx_leave_reason_name ON leave_reason FIELDS name;
DEFINE INDEX idx_leave_reason_code ON leave_reason FIELDS code;
DEFINE INDEX idx_leave_reason_type ON leave_reason FIELDS type_select;
DEFINE INDEX idx_leave_reason_active ON leave_reason FIELDS is_active;
DEFINE INDEX idx_leave_reason_paid ON leave_reason FIELDS is_paid;

DEFINE INDEX idx_qualification_name ON qualification FIELDS name;
DEFINE INDEX idx_qualification_code ON qualification FIELDS code;
DEFINE INDEX idx_qualification_level ON qualification FIELDS qualification_level;
DEFINE INDEX idx_qualification_type ON qualification FIELDS qualification_type;
DEFINE INDEX idx_qualification_expiry ON qualification FIELDS expiry_date;
DEFINE INDEX idx_qualification_active ON qualification FIELDS is_active;
DEFINE INDEX idx_qualification_mandatory ON qualification FIELDS is_mandatory;

DEFINE INDEX idx_qualification_level_name ON qualification_level FIELDS name;
DEFINE INDEX idx_qualification_level_code ON qualification_level FIELDS code;
DEFINE INDEX idx_qualification_level_number ON qualification_level FIELDS level_number;
DEFINE INDEX idx_qualification_level_active ON qualification_level FIELDS is_active;

DEFINE INDEX idx_medical_visit_employee ON medical_visit FIELDS employee;
DEFINE INDEX idx_medical_visit_date ON medical_visit FIELDS visit_date;
DEFINE INDEX idx_medical_visit_type ON medical_visit FIELDS visit_type;
DEFINE INDEX idx_medical_visit_result ON medical_visit FIELDS fitness_result;
DEFINE INDEX idx_medical_visit_next ON medical_visit FIELDS next_visit_date;
DEFINE INDEX idx_medical_visit_reason ON medical_visit FIELDS medical_visit_reason;

DEFINE INDEX idx_medical_visit_reason_name ON medical_visit_reason FIELDS name;
DEFINE INDEX idx_medical_visit_reason_code ON medical_visit_reason FIELDS code;
DEFINE INDEX idx_medical_visit_reason_active ON medical_visit_reason FIELDS is_active; 