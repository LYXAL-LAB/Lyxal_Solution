-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 7 : FINAL ENTITIES
-- ================================================================================
-- Entités finales : DPAE, TimesheetReport, BankCard, SmicValue, HealthMutualRejectionReason,
-- AllocationLine, LunchVoucherAdvance, EmploymentAmendmentType, Site, ExportCode, etc.
-- ================================================================================

-- DPAE - Déclaration Préalable à l'Embauche (DPAE.xml - 1933 bytes)
DEFINE TABLE dpae SCHEMAFULL;
DEFINE FIELD employee ON dpae TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON dpae TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD dpae_seq ON dpae TYPE string READONLY;
DEFINE FIELD declaration_date ON dpae TYPE date ASSERT $value != NONE;
DEFINE FIELD employment_start_date ON dpae TYPE date ASSERT $value != NONE;
DEFINE FIELD employment_contract ON dpae TYPE record<employment_contract>;
DEFINE FIELD contract_type ON dpae TYPE int DEFAULT 1; -- 1:CDI, 2:CDD, 3:Interim, 4:Stage, 5:Apprentissage
DEFINE FIELD work_place ON dpae TYPE string;
DEFINE FIELD work_schedule ON dpae TYPE string;
DEFINE FIELD declared_salary ON dpae TYPE decimal DEFAULT 0.0;
DEFINE FIELD position_held ON dpae TYPE string;
DEFINE FIELD social_security_regime ON dpae TYPE int DEFAULT 1; -- 1:General, 2:Agricultural, 3:Special
DEFINE FIELD establishment_siret ON dpae TYPE string;
DEFINE FIELD declaration_method ON dpae TYPE int DEFAULT 1; -- 1:Online, 2:Paper, 3:Electronic
DEFINE FIELD declaration_reference ON dpae TYPE string;
DEFINE FIELD status_select ON dpae TYPE int DEFAULT 1; -- 1:Draft, 2:Declared, 3:Accepted, 4:Rejected
DEFINE FIELD declaration_response ON dpae TYPE string;
DEFINE FIELD rejection_reason ON dpae TYPE string;
DEFINE FIELD urssaf_response_date ON dpae TYPE datetime;
DEFINE FIELD urssaf_reference ON dpae TYPE string;
DEFINE FIELD modification_date ON dpae TYPE datetime;
DEFINE FIELD modification_reason ON dpae TYPE string;
DEFINE FIELD cancellation_date ON dpae TYPE datetime;
DEFINE FIELD cancellation_reason ON dpae TYPE string;
DEFINE FIELD supporting_documents ON dpae TYPE array<record<meta_file>>;
DEFINE FIELD comments ON dpae TYPE string;
DEFINE FIELD created_at ON dpae TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dpae TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON dpae TYPE int DEFAULT 0;

-- Rapport de feuille de temps (TimesheetReport.xml - 801 bytes)
DEFINE TABLE timesheet_report SCHEMAFULL;
DEFINE FIELD name ON timesheet_report TYPE string ASSERT $value != NONE;
DEFINE FIELD company ON timesheet_report TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD from_date ON timesheet_report TYPE date ASSERT $value != NONE;
DEFINE FIELD to_date ON timesheet_report TYPE date ASSERT $value != NONE;
DEFINE FIELD employee_filter ON timesheet_report TYPE record<employee>;
DEFINE FIELD department_filter ON timesheet_report TYPE record<department>;
DEFINE FIELD project_filter ON timesheet_report TYPE record<project>;
DEFINE FIELD report_type ON timesheet_report TYPE int DEFAULT 1; -- 1:Summary, 2:Detailed, 3:Analytical
DEFINE FIELD include_draft_timesheets ON timesheet_report TYPE bool DEFAULT false;
DEFINE FIELD include_validated_timesheets ON timesheet_report TYPE bool DEFAULT true;
DEFINE FIELD group_by_employee ON timesheet_report TYPE bool DEFAULT true;
DEFINE FIELD group_by_project ON timesheet_report TYPE bool DEFAULT false;
DEFINE FIELD group_by_task ON timesheet_report TYPE bool DEFAULT false;
DEFINE FIELD show_billable_hours ON timesheet_report TYPE bool DEFAULT true;
DEFINE FIELD show_non_billable_hours ON timesheet_report TYPE bool DEFAULT true;
DEFINE FIELD show_overtime_hours ON timesheet_report TYPE bool DEFAULT true;
DEFINE FIELD generated_date ON timesheet_report TYPE datetime;
DEFINE FIELD generated_by ON timesheet_report TYPE record<user>;
DEFINE FIELD report_file ON timesheet_report TYPE record<meta_file>;
DEFINE FIELD status_select ON timesheet_report TYPE int DEFAULT 1; -- 1:Draft, 2:Generated, 3:Exported
DEFINE FIELD created_at ON timesheet_report TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON timesheet_report TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON timesheet_report TYPE int DEFAULT 0;

-- Carte bancaire (BankCard.xml - 654 bytes)
DEFINE TABLE bank_card SCHEMAFULL;
DEFINE FIELD employee ON bank_card TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD card_number ON bank_card TYPE string;
DEFINE FIELD masked_card_number ON bank_card TYPE string;
DEFINE FIELD card_holder_name ON bank_card TYPE string ASSERT $value != NONE;
DEFINE FIELD bank_name ON bank_card TYPE string;
DEFINE FIELD card_type ON bank_card TYPE int DEFAULT 1; -- 1:Corporate, 2:Expense, 3:Fuel, 4:Meal
DEFINE FIELD card_brand ON bank_card TYPE string; -- Visa, Mastercard, Amex, etc.
DEFINE FIELD issue_date ON bank_card TYPE date;
DEFINE FIELD expiry_date ON bank_card TYPE date ASSERT $value != NONE;
DEFINE FIELD monthly_limit ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD daily_limit ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD transaction_limit ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD current_balance ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD available_balance ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_active ON bank_card TYPE bool DEFAULT true;
DEFINE FIELD is_blocked ON bank_card TYPE bool DEFAULT false;
DEFINE FIELD block_reason ON bank_card TYPE string;
DEFINE FIELD block_date ON bank_card TYPE datetime;
DEFINE FIELD pin_set ON bank_card TYPE bool DEFAULT false;
DEFINE FIELD last_pin_change_date ON bank_card TYPE datetime;
DEFINE FIELD contactless_enabled ON bank_card TYPE bool DEFAULT true;
DEFINE FIELD online_purchases_enabled ON bank_card TYPE bool DEFAULT true;
DEFINE FIELD international_usage_enabled ON bank_card TYPE bool DEFAULT false;
DEFINE FIELD usage_restrictions ON bank_card TYPE string;
DEFINE FIELD merchant_categories_allowed ON bank_card TYPE array<string>;
DEFINE FIELD last_transaction_date ON bank_card TYPE datetime;
DEFINE FIELD total_transactions_month ON bank_card TYPE int DEFAULT 0;
DEFINE FIELD total_amount_month ON bank_card TYPE decimal DEFAULT 0.0;
DEFINE FIELD replacement_card ON bank_card TYPE record<bank_card>;
DEFINE FIELD comments ON bank_card TYPE string;
DEFINE FIELD created_at ON bank_card TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_card TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_card TYPE int DEFAULT 0;

-- Valeur SMIC (SmicValue.xml - 743 bytes)
DEFINE TABLE smic_value SCHEMAFULL;
DEFINE FIELD name ON smic_value TYPE string ASSERT $value != NONE;
DEFINE FIELD hourly_rate ON smic_value TYPE decimal ASSERT $value != NONE;
DEFINE FIELD monthly_rate ON smic_value TYPE decimal ASSERT $value != NONE;
DEFINE FIELD annual_rate ON smic_value TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON smic_value TYPE record<currency>;
DEFINE FIELD effective_date ON smic_value TYPE date ASSERT $value != NONE;
DEFINE FIELD expiry_date ON smic_value TYPE date;
DEFINE FIELD is_active ON smic_value TYPE bool DEFAULT true;
DEFINE FIELD region ON smic_value TYPE string;
DEFINE FIELD country ON smic_value TYPE record<country>;
DEFINE FIELD age_category ON smic_value TYPE int DEFAULT 1; -- 1:Adult, 2:Young 16-17, 3:Young 18-20, 4:Apprentice
DEFINE FIELD experience_months_required ON smic_value TYPE int DEFAULT 0;
DEFINE FIELD percentage_of_full_smic ON smic_value TYPE decimal DEFAULT 100.0;
DEFINE FIELD legal_reference ON smic_value TYPE string;
DEFINE FIELD decree_number ON smic_value TYPE string;
DEFINE FIELD publication_date ON smic_value TYPE date;
DEFINE FIELD application_sectors ON smic_value TYPE array<string>;
DEFINE FIELD exclusions ON smic_value TYPE string;
DEFINE FIELD special_conditions ON smic_value TYPE string;
DEFINE FIELD indexation_method ON smic_value TYPE string;
DEFINE FIELD next_review_date ON smic_value TYPE date;
DEFINE FIELD historical_evolution_percentage ON smic_value TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON smic_value TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON smic_value TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON smic_value TYPE int DEFAULT 0;

-- Motif de rejet mutuelle santé (HealthMutualRejectionReason.xml - 665 bytes)
DEFINE TABLE health_mutual_rejection_reason SCHEMAFULL;
DEFINE FIELD name ON health_mutual_rejection_reason TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON health_mutual_rejection_reason TYPE string UNIQUE;
DEFINE FIELD description ON health_mutual_rejection_reason TYPE string;
DEFINE FIELD category ON health_mutual_rejection_reason TYPE int DEFAULT 1; -- 1:Administrative, 2:Medical, 3:Financial, 4:Technical
DEFINE FIELD severity_level ON health_mutual_rejection_reason TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD resolution_time_days ON health_mutual_rejection_reason TYPE int DEFAULT 7;
DEFINE FIELD required_documents ON health_mutual_rejection_reason TYPE array<string>;
DEFINE FIELD action_required ON health_mutual_rejection_reason TYPE string;
DEFINE FIELD responsible_department ON health_mutual_rejection_reason TYPE string;
DEFINE FIELD escalation_procedure ON health_mutual_rejection_reason TYPE string;
DEFINE FIELD prevention_measures ON health_mutual_rejection_reason TYPE string;
DEFINE FIELD employee_communication_template ON health_mutual_rejection_reason TYPE record<template>;
DEFINE FIELD is_active ON health_mutual_rejection_reason TYPE bool DEFAULT true;
DEFINE FIELD frequency_occurrence ON health_mutual_rejection_reason TYPE int DEFAULT 0;
DEFINE FIELD last_occurrence_date ON health_mutual_rejection_reason TYPE date;
DEFINE FIELD resolution_success_rate ON health_mutual_rejection_reason TYPE decimal DEFAULT 0.0;
DEFINE FIELD average_resolution_days ON health_mutual_rejection_reason TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON health_mutual_rejection_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON health_mutual_rejection_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON health_mutual_rejection_reason TYPE int DEFAULT 0;

-- Ligne d'allocation (AllocationLine.xml - 2373 bytes)
DEFINE TABLE allocation_line SCHEMAFULL;
DEFINE FIELD employee ON allocation_line TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD leave_reason ON allocation_line TYPE record<leave_reason> ASSERT $value != NONE;
DEFINE FIELD allocation_date ON allocation_line TYPE date ASSERT $value != NONE;
DEFINE FIELD allocation_period ON allocation_line TYPE record<period>;
DEFINE FIELD allocated_quantity ON allocation_line TYPE decimal ASSERT $value != NONE;
DEFINE FIELD unit ON allocation_line TYPE int DEFAULT 1; -- 1:Days, 2:Hours
DEFINE FIELD allocation_type ON allocation_line TYPE int DEFAULT 1; -- 1:Annual, 2:Monthly, 3:Bonus, 4:Carryover, 5:Adjustment
DEFINE FIELD source_type ON allocation_line TYPE int DEFAULT 1; -- 1:Automatic, 2:Manual, 3:Import, 4:Calculation
DEFINE FIELD calculation_basis ON allocation_line TYPE string;
DEFINE FIELD prorate_percentage ON allocation_line TYPE decimal DEFAULT 100.0;
DEFINE FIELD working_days_in_period ON allocation_line TYPE int DEFAULT 0;
DEFINE FIELD absence_days_in_period ON allocation_line TYPE int DEFAULT 0;
DEFINE FIELD effective_working_days ON allocation_line TYPE int DEFAULT 0;
DEFINE FIELD accrual_rate_per_month ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD previous_balance ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD current_allocation ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_balance ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD used_quantity ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD remaining_balance ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD carryover_from_previous_year ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD carryover_limit ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD carryover_expiry_date ON allocation_line TYPE date;
DEFINE FIELD forfeited_quantity ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD adjustment_quantity ON allocation_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD adjustment_reason ON allocation_line TYPE string;
DEFINE FIELD validated ON allocation_line TYPE bool DEFAULT false;
DEFINE FIELD validated_by ON allocation_line TYPE record<user>;
DEFINE FIELD validation_date ON allocation_line TYPE datetime;
DEFINE FIELD comments ON allocation_line TYPE string;
DEFINE FIELD year ON allocation_line TYPE record<year>;
DEFINE FIELD company ON allocation_line TYPE record<company>;
DEFINE FIELD leave_line_list ON allocation_line TYPE array<record<leave_line>>;
DEFINE FIELD created_at ON allocation_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON allocation_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON allocation_line TYPE int DEFAULT 0;

-- Avance tickets restaurant (LunchVoucherAdvance.xml - 1078 bytes)
DEFINE TABLE lunch_voucher_advance SCHEMAFULL;
DEFINE FIELD employee ON lunch_voucher_advance TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON lunch_voucher_advance TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD advance_seq ON lunch_voucher_advance TYPE string READONLY;
DEFINE FIELD advance_date ON lunch_voucher_advance TYPE date ASSERT $value != NONE;
DEFINE FIELD requested_amount ON lunch_voucher_advance TYPE decimal ASSERT $value != NONE;
DEFINE FIELD approved_amount ON lunch_voucher_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON lunch_voucher_advance TYPE record<currency>;
DEFINE FIELD reason ON lunch_voucher_advance TYPE string ASSERT $value != NONE;
DEFINE FIELD status_select ON lunch_voucher_advance TYPE int DEFAULT 1; -- 1:Draft, 2:Requested, 3:Approved, 4:Paid, 5:Recovered, 6:Cancelled
DEFINE FIELD request_date ON lunch_voucher_advance TYPE date DEFAULT time::now()::date;
DEFINE FIELD approval_date ON lunch_voucher_advance TYPE datetime;
DEFINE FIELD approved_by ON lunch_voucher_advance TYPE record<user>;
DEFINE FIELD payment_date ON lunch_voucher_advance TYPE datetime;
DEFINE FIELD paid_by ON lunch_voucher_advance TYPE record<user>;
DEFINE FIELD recovery_method ON lunch_voucher_advance TYPE int DEFAULT 1; -- 1:Payroll Deduction, 2:Future Vouchers, 3:Cash Repayment
DEFINE FIELD recovery_start_date ON lunch_voucher_advance TYPE date;
DEFINE FIELD recovery_installments ON lunch_voucher_advance TYPE int DEFAULT 1;
DEFINE FIELD recovery_amount_per_installment ON lunch_voucher_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD recovered_amount ON lunch_voucher_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD remaining_amount ON lunch_voucher_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD voucher_unit_price ON lunch_voucher_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD voucher_quantity_equivalent ON lunch_voucher_advance TYPE int DEFAULT 0;
DEFINE FIELD usage_period_from ON lunch_voucher_advance TYPE date;
DEFINE FIELD usage_period_to ON lunch_voucher_advance TYPE date;
DEFINE FIELD justification_document ON lunch_voucher_advance TYPE record<meta_file>;
DEFINE FIELD manager_comment ON lunch_voucher_advance TYPE string;
DEFINE FIELD hr_comment ON lunch_voucher_advance TYPE string;
DEFINE FIELD accounting_move ON lunch_voucher_advance TYPE record<move>;
DEFINE FIELD payment_move ON lunch_voucher_advance TYPE record<move>;
DEFINE FIELD recovery_move_list ON lunch_voucher_advance TYPE array<record<move>>;
DEFINE FIELD created_at ON lunch_voucher_advance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON lunch_voucher_advance TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON lunch_voucher_advance TYPE int DEFAULT 0;

-- Type d'amendement contrat (EmploymentAmendmentType.xml - 1474 bytes)
DEFINE TABLE employment_amendment_type SCHEMAFULL;
DEFINE FIELD name ON employment_amendment_type TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON employment_amendment_type TYPE string UNIQUE;
DEFINE FIELD description ON employment_amendment_type TYPE string;
DEFINE FIELD amendment_category ON employment_amendment_type TYPE int DEFAULT 1; -- 1:Salary, 2:Position, 3:Schedule, 4:Benefits, 5:Terms, 6:Other
DEFINE FIELD requires_new_contract ON employment_amendment_type TYPE bool DEFAULT false;
DEFINE FIELD requires_employee_consent ON employment_amendment_type TYPE bool DEFAULT true;
DEFINE FIELD requires_union_notification ON employment_amendment_type TYPE bool DEFAULT false;
DEFINE FIELD requires_labor_authority_approval ON employment_amendment_type TYPE bool DEFAULT false;
DEFINE FIELD notice_period_days ON employment_amendment_type TYPE int DEFAULT 30;
DEFINE FIELD legal_basis ON employment_amendment_type TYPE string;
DEFINE FIELD documentation_required ON employment_amendment_type TYPE array<string>;
DEFINE FIELD approval_workflow ON employment_amendment_type TYPE string;
DEFINE FIELD template_document ON employment_amendment_type TYPE record<meta_file>;
DEFINE FIELD impact_on_benefits ON employment_amendment_type TYPE string;
DEFINE FIELD impact_on_leave_entitlement ON employment_amendment_type TYPE string;
DEFINE FIELD impact_on_pension_rights ON employment_amendment_type TYPE string;
DEFINE FIELD retroactive_application_allowed ON employment_amendment_type TYPE bool DEFAULT false;
DEFINE FIELD max_retroactive_months ON employment_amendment_type TYPE int DEFAULT 0;
DEFINE FIELD communication_template ON employment_amendment_type TYPE record<template>;
DEFINE FIELD is_active ON employment_amendment_type TYPE bool DEFAULT true;
DEFINE FIELD frequency_usage ON employment_amendment_type TYPE int DEFAULT 0;
DEFINE FIELD last_used_date ON employment_amendment_type TYPE date;
DEFINE FIELD success_rate ON employment_amendment_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD average_processing_days ON employment_amendment_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON employment_amendment_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employment_amendment_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employment_amendment_type TYPE int DEFAULT 0;

-- Site/Établissement (Site.xml - 529 bytes)
DEFINE TABLE site SCHEMAFULL;
DEFINE FIELD name ON site TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON site TYPE string UNIQUE;
DEFINE FIELD company ON site TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD address ON site TYPE record<address>;
DEFINE FIELD contact_partner ON site TYPE record<partner>;
DEFINE FIELD site_type ON site TYPE int DEFAULT 1; -- 1:Headquarters, 2:Branch, 3:Warehouse, 4:Factory, 5:Office, 6:Store
DEFINE FIELD is_main_site ON site TYPE bool DEFAULT false;
DEFINE FIELD opening_date ON site TYPE date;
DEFINE FIELD closing_date ON site TYPE date;
DEFINE FIELD is_active ON site TYPE bool DEFAULT true;
DEFINE FIELD employee_capacity ON site TYPE int DEFAULT 0;
DEFINE FIELD current_employee_count ON site TYPE int DEFAULT 0;
DEFINE FIELD surface_area_sqm ON site TYPE decimal DEFAULT 0.0;
DEFINE FIELD parking_spaces ON site TYPE int DEFAULT 0;
DEFINE FIELD accessibility_features ON site TYPE string;
DEFINE FIELD safety_certifications ON site TYPE array<string>;
DEFINE FIELD emergency_procedures ON site TYPE string;
DEFINE FIELD working_hours ON site TYPE string;
DEFINE FIELD time_zone ON site TYPE string;
DEFINE FIELD cost_center ON site TYPE string;
DEFINE FIELD budget_allocation ON site TYPE decimal DEFAULT 0.0;
DEFINE FIELD manager ON site TYPE record<employee>;
DEFINE FIELD hr_representative ON site TYPE record<employee>;
DEFINE FIELD facility_manager ON site TYPE record<employee>;
DEFINE FIELD equipment_list ON site TYPE array<string>;
DEFINE FIELD amenities ON site TYPE array<string>;
DEFINE FIELD comments ON site TYPE string;
DEFINE FIELD created_at ON site TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON site TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON site TYPE int DEFAULT 0;

-- Code d'export (ExportCode.xml - 498 bytes)
DEFINE TABLE export_code SCHEMAFULL;
DEFINE FIELD name ON export_code TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON export_code TYPE string UNIQUE;
DEFINE FIELD description ON export_code TYPE string;
DEFINE FIELD export_type ON export_code TYPE int DEFAULT 1; -- 1:Payroll, 2:Accounting, 3:Social Security, 4:Tax, 5:Statistics
DEFINE FIELD target_system ON export_code TYPE string;
DEFINE FIELD mapping_rules ON export_code TYPE string;
DEFINE FIELD data_format ON export_code TYPE string; -- CSV, XML, JSON, EDI, etc.
DEFINE FIELD is_active ON export_code TYPE bool DEFAULT true;
DEFINE FIELD company_list ON export_code TYPE array<record<company>>;
DEFINE FIELD frequency ON export_code TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly, 4:Quarterly, 5:Annually, 6:On-demand
DEFINE FIELD last_export_date ON export_code TYPE datetime;
DEFINE FIELD next_export_date ON export_code TYPE datetime;
DEFINE FIELD export_template ON export_code TYPE record<meta_file>;
DEFINE FIELD validation_rules ON export_code TYPE string;
DEFINE FIELD error_handling_procedure ON export_code TYPE string;
DEFINE FIELD created_at ON export_code TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON export_code TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON export_code TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_dpae_employee ON dpae FIELDS employee;
DEFINE INDEX idx_dpae_company ON dpae FIELDS company;
DEFINE INDEX idx_dpae_declaration_date ON dpae FIELDS declaration_date;
DEFINE INDEX idx_dpae_employment_start ON dpae FIELDS employment_start_date;
DEFINE INDEX idx_dpae_status ON dpae FIELDS status_select;
DEFINE INDEX idx_dpae_contract ON dpae FIELDS employment_contract;

DEFINE INDEX idx_timesheet_report_name ON timesheet_report FIELDS name;
DEFINE INDEX idx_timesheet_report_company ON timesheet_report FIELDS company;
DEFINE INDEX idx_timesheet_report_dates ON timesheet_report FIELDS from_date, to_date;
DEFINE INDEX idx_timesheet_report_status ON timesheet_report FIELDS status_select;

DEFINE INDEX idx_bank_card_employee ON bank_card FIELDS employee;
DEFINE INDEX idx_bank_card_type ON bank_card FIELDS card_type;
DEFINE INDEX idx_bank_card_active ON bank_card FIELDS is_active;
DEFINE INDEX idx_bank_card_expiry ON bank_card FIELDS expiry_date;

DEFINE INDEX idx_smic_value_effective ON smic_value FIELDS effective_date;
DEFINE INDEX idx_smic_value_active ON smic_value FIELDS is_active;
DEFINE INDEX idx_smic_value_country ON smic_value FIELDS country;
DEFINE INDEX idx_smic_value_age_category ON smic_value FIELDS age_category;

DEFINE INDEX idx_health_mutual_rejection_code ON health_mutual_rejection_reason FIELDS code;
DEFINE INDEX idx_health_mutual_rejection_category ON health_mutual_rejection_reason FIELDS category;
DEFINE INDEX idx_health_mutual_rejection_active ON health_mutual_rejection_reason FIELDS is_active;

DEFINE INDEX idx_allocation_line_employee ON allocation_line FIELDS employee;
DEFINE INDEX idx_allocation_line_leave_reason ON allocation_line FIELDS leave_reason;
DEFINE INDEX idx_allocation_line_date ON allocation_line FIELDS allocation_date;
DEFINE INDEX idx_allocation_line_type ON allocation_line FIELDS allocation_type;
DEFINE INDEX idx_allocation_line_validated ON allocation_line FIELDS validated;

DEFINE INDEX idx_lunch_voucher_advance_employee ON lunch_voucher_advance FIELDS employee;
DEFINE INDEX idx_lunch_voucher_advance_company ON lunch_voucher_advance FIELDS company;
DEFINE INDEX idx_lunch_voucher_advance_date ON lunch_voucher_advance FIELDS advance_date;
DEFINE INDEX idx_lunch_voucher_advance_status ON lunch_voucher_advance FIELDS status_select;

DEFINE INDEX idx_employment_amendment_type_name ON employment_amendment_type FIELDS name;
DEFINE INDEX idx_employment_amendment_type_code ON employment_amendment_type FIELDS code;
DEFINE INDEX idx_employment_amendment_type_category ON employment_amendment_type FIELDS amendment_category;
DEFINE INDEX idx_employment_amendment_type_active ON employment_amendment_type FIELDS is_active;

DEFINE INDEX idx_site_name ON site FIELDS name;
DEFINE INDEX idx_site_code ON site FIELDS code;
DEFINE INDEX idx_site_company ON site FIELDS company;
DEFINE INDEX idx_site_type ON site FIELDS site_type;
DEFINE INDEX idx_site_active ON site FIELDS is_active;
DEFINE INDEX idx_site_main ON site FIELDS is_main_site;

DEFINE INDEX idx_export_code_name ON export_code FIELDS name;
DEFINE INDEX idx_export_code_code ON export_code FIELDS code;
DEFINE INDEX idx_export_code_type ON export_code FIELDS export_type;
DEFINE INDEX idx_export_code_active ON export_code FIELDS is_active; 