-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 4 : ADVANCES & BONUS
-- ================================================================================
-- Entités : EmployeeAdvance, EmployeeBonusMgt, LunchVoucherMgt, ExtraHours, PayrollPreparation
-- Basé sur EmployeeAdvance.xml (1564 bytes), EmployeeBonusMgt.xml (1423 bytes)
-- LunchVoucherMgt.xml (2203 bytes), ExtraHours.xml (2229 bytes), PayrollPreparation.xml (3410 bytes)
-- ================================================================================

-- Avance employé (EmployeeAdvance.xml - 1564 bytes)
DEFINE TABLE employee_advance SCHEMAFULL;
DEFINE FIELD employee ON employee_advance TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON employee_advance TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD advance_seq ON employee_advance TYPE string READONLY;
DEFINE FIELD advance_date ON employee_advance TYPE date ASSERT $value != NONE;
DEFINE FIELD amount ON employee_advance TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON employee_advance TYPE record<currency>;
DEFINE FIELD reason ON employee_advance TYPE string ASSERT $value != NONE;
DEFINE FIELD advance_type ON employee_advance TYPE int DEFAULT 1; -- 1:Salary Advance, 2:Travel Advance, 3:Emergency Advance, 4:Equipment Advance
DEFINE FIELD status_select ON employee_advance TYPE int DEFAULT 1; -- 1:Draft, 2:Requested, 3:Approved, 4:Paid, 5:Recovered, 6:Cancelled
DEFINE FIELD request_date ON employee_advance TYPE date DEFAULT time::now()::date;
DEFINE FIELD approval_date ON employee_advance TYPE datetime;
DEFINE FIELD approved_by ON employee_advance TYPE record<user>;
DEFINE FIELD payment_date ON employee_advance TYPE datetime;
DEFINE FIELD paid_by ON employee_advance TYPE record<user>;
DEFINE FIELD recovery_start_date ON employee_advance TYPE date;
DEFINE FIELD recovery_installments ON employee_advance TYPE int DEFAULT 1;
DEFINE FIELD recovery_amount_per_installment ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD recovered_amount ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD remaining_amount ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD interest_rate ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD interest_amount ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD bank_details ON employee_advance TYPE record<bank_details>;
DEFINE FIELD payment_method ON employee_advance TYPE int DEFAULT 1; -- 1:Bank Transfer, 2:Cash, 3:Cheque, 4:Deduction from salary
DEFINE FIELD advance_usage_list ON employee_advance TYPE array<record<employee_advance_usage>>;
DEFINE FIELD justification_document ON employee_advance TYPE record<meta_file>;
DEFINE FIELD manager_comment ON employee_advance TYPE string;
DEFINE FIELD hr_comment ON employee_advance TYPE string;
DEFINE FIELD accounting_move ON employee_advance TYPE record<move>;
DEFINE FIELD payment_move ON employee_advance TYPE record<move>;
DEFINE FIELD recovery_move_list ON employee_advance TYPE array<record<move>>;
DEFINE FIELD is_emergency ON employee_advance TYPE bool DEFAULT false;
DEFINE FIELD emergency_justification ON employee_advance TYPE string;
DEFINE FIELD max_advance_limit ON employee_advance TYPE decimal DEFAULT 0.0;
DEFINE FIELD advance_eligibility_check ON employee_advance TYPE bool DEFAULT true;
DEFINE FIELD created_at ON employee_advance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_advance TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_advance TYPE int DEFAULT 0;

-- Gestion des bonus employés (EmployeeBonusMgt.xml - 1423 bytes)
DEFINE TABLE employee_bonus_mgt SCHEMAFULL;
DEFINE FIELD employee ON employee_bonus_mgt TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON employee_bonus_mgt TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD bonus_seq ON employee_bonus_mgt TYPE string READONLY;
DEFINE FIELD bonus_date ON employee_bonus_mgt TYPE date ASSERT $value != NONE;
DEFINE FIELD employee_bonus_type ON employee_bonus_mgt TYPE record<employee_bonus_type> ASSERT $value != NONE;
DEFINE FIELD amount ON employee_bonus_mgt TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON employee_bonus_mgt TYPE record<currency>;
DEFINE FIELD status_select ON employee_bonus_mgt TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed, 3:Validated, 4:Paid, 5:Cancelled
DEFINE FIELD bonus_period_from ON employee_bonus_mgt TYPE date;
DEFINE FIELD bonus_period_to ON employee_bonus_mgt TYPE date;
DEFINE FIELD performance_rating ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD kpi_achievement_percentage ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD target_amount ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD calculation_formula ON employee_bonus_mgt TYPE string;
DEFINE FIELD calculation_base ON employee_bonus_mgt TYPE int DEFAULT 1; -- 1:Salary, 2:Revenue, 3:Targets, 4:Fixed Amount, 5:Custom Formula
DEFINE FIELD calculation_result ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD bonus_line_list ON employee_bonus_mgt TYPE array<record<employee_bonus_mgt_line>>;
DEFINE FIELD reason ON employee_bonus_mgt TYPE string;
DEFINE FIELD comments ON employee_bonus_mgt TYPE string;
DEFINE FIELD manager_approval_required ON employee_bonus_mgt TYPE bool DEFAULT true;
DEFINE FIELD manager_approved_by ON employee_bonus_mgt TYPE record<user>;
DEFINE FIELD manager_approval_date ON employee_bonus_mgt TYPE datetime;
DEFINE FIELD hr_approval_required ON employee_bonus_mgt TYPE bool DEFAULT true;
DEFINE FIELD hr_approved_by ON employee_bonus_mgt TYPE record<user>;
DEFINE FIELD hr_approval_date ON employee_bonus_mgt TYPE datetime;
DEFINE FIELD payment_date ON employee_bonus_mgt TYPE datetime;
DEFINE FIELD payment_method ON employee_bonus_mgt TYPE int DEFAULT 1; -- 1:Next Payroll, 2:Separate Payment, 3:Bank Transfer
DEFINE FIELD tax_applicable ON employee_bonus_mgt TYPE bool DEFAULT true;
DEFINE FIELD tax_rate ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD net_amount ON employee_bonus_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD accounting_move ON employee_bonus_mgt TYPE record<move>;
DEFINE FIELD created_at ON employee_bonus_mgt TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_bonus_mgt TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_bonus_mgt TYPE int DEFAULT 0;

-- Gestion des tickets restaurant (LunchVoucherMgt.xml - 2203 bytes)
DEFINE TABLE lunch_voucher_mgt SCHEMAFULL;
DEFINE FIELD employee ON lunch_voucher_mgt TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON lunch_voucher_mgt TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD lunch_voucher_seq ON lunch_voucher_mgt TYPE string READONLY;
DEFINE FIELD distribution_date ON lunch_voucher_mgt TYPE date ASSERT $value != NONE;
DEFINE FIELD lunch_voucher_number ON lunch_voucher_mgt TYPE int DEFAULT 0;
DEFINE FIELD unit_price ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD employee_contribution ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD company_contribution ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON lunch_voucher_mgt TYPE record<currency>;
DEFINE FIELD lunch_voucher_format_select ON lunch_voucher_mgt TYPE int DEFAULT 1; -- 1:Paper, 2:Card, 3:Digital
DEFINE FIELD status_select ON lunch_voucher_mgt TYPE int DEFAULT 1; -- 1:Draft, 2:Distributed, 3:Used, 4:Expired, 5:Lost
DEFINE FIELD period_from ON lunch_voucher_mgt TYPE date;
DEFINE FIELD period_to ON lunch_voucher_mgt TYPE date;
DEFINE FIELD working_days ON lunch_voucher_mgt TYPE int DEFAULT 0;
DEFINE FIELD absence_days ON lunch_voucher_mgt TYPE int DEFAULT 0;
DEFINE FIELD eligible_days ON lunch_voucher_mgt TYPE int DEFAULT 0;
DEFINE FIELD lunch_voucher_line_list ON lunch_voucher_mgt TYPE array<record<lunch_voucher_mgt_line>>;
DEFINE FIELD distribution_method ON lunch_voucher_mgt TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic, 3:On-demand
DEFINE FIELD card_number ON lunch_voucher_mgt TYPE string;
DEFINE FIELD card_balance ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD card_expiry_date ON lunch_voucher_mgt TYPE date;
DEFINE FIELD voucher_provider ON lunch_voucher_mgt TYPE string;
DEFINE FIELD provider_reference ON lunch_voucher_mgt TYPE string;
DEFINE FIELD delivery_address ON lunch_voucher_mgt TYPE string;
DEFINE FIELD delivery_date ON lunch_voucher_mgt TYPE date;
DEFINE FIELD delivery_status ON lunch_voucher_mgt TYPE int DEFAULT 1; -- 1:Pending, 2:Delivered, 3:Returned
DEFINE FIELD tracking_number ON lunch_voucher_mgt TYPE string;
DEFINE FIELD usage_restrictions ON lunch_voucher_mgt TYPE string;
DEFINE FIELD merchant_category ON lunch_voucher_mgt TYPE string;
DEFINE FIELD daily_limit ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD monthly_limit ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD tax_exemption_applicable ON lunch_voucher_mgt TYPE bool DEFAULT true;
DEFINE FIELD tax_exemption_amount ON lunch_voucher_mgt TYPE decimal DEFAULT 0.0;
DEFINE FIELD comments ON lunch_voucher_mgt TYPE string;
DEFINE FIELD created_at ON lunch_voucher_mgt TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON lunch_voucher_mgt TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON lunch_voucher_mgt TYPE int DEFAULT 0;

-- Heures supplémentaires (ExtraHours.xml - 2229 bytes)
DEFINE TABLE extra_hours SCHEMAFULL;
DEFINE FIELD employee ON extra_hours TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON extra_hours TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD extra_hours_seq ON extra_hours TYPE string READONLY;
DEFINE FIELD date ON extra_hours TYPE date ASSERT $value != NONE;
DEFINE FIELD extra_hours_type ON extra_hours TYPE record<extra_hours_type> ASSERT $value != NONE;
DEFINE FIELD quantity ON extra_hours TYPE decimal ASSERT $value != NONE;
DEFINE FIELD hourly_rate ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON extra_hours TYPE record<currency>;
DEFINE FIELD status_select ON extra_hours TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed, 3:Validated, 4:Paid, 5:Refused
DEFINE FIELD period_from ON extra_hours TYPE date;
DEFINE FIELD period_to ON extra_hours TYPE date;
DEFINE FIELD extra_hours_line_list ON extra_hours TYPE array<record<extra_hours_line>>;
DEFINE FIELD reason ON extra_hours TYPE string;
DEFINE FIELD comments ON extra_hours TYPE string;
DEFINE FIELD authorized_by ON extra_hours TYPE record<user>;
DEFINE FIELD authorization_date ON extra_hours TYPE datetime;
DEFINE FIELD validation_date ON extra_hours TYPE datetime;
DEFINE FIELD validated_by ON extra_hours TYPE record<user>;
DEFINE FIELD refusal_reason ON extra_hours TYPE string;
DEFINE FIELD refused_by ON extra_hours TYPE record<user>;
DEFINE FIELD refusal_date ON extra_hours TYPE datetime;
DEFINE FIELD payment_method ON extra_hours TYPE int DEFAULT 1; -- 1:Next Payroll, 2:Compensatory Time Off, 3:Separate Payment
DEFINE FIELD overtime_calculation_rule ON extra_hours TYPE string;
DEFINE FIELD multiplier_rate ON extra_hours TYPE decimal DEFAULT 1.25;
DEFINE FIELD night_shift_bonus ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD weekend_bonus ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD holiday_bonus ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD project ON extra_hours TYPE record<project>;
DEFINE FIELD task ON extra_hours TYPE record<project_task>;
DEFINE FIELD timesheet ON extra_hours TYPE record<timesheet>;
DEFINE FIELD timesheet_line ON extra_hours TYPE record<timesheet_line>;
DEFINE FIELD accounting_move ON extra_hours TYPE record<move>;
DEFINE FIELD is_billable ON extra_hours TYPE bool DEFAULT false;
DEFINE FIELD client_billable_rate ON extra_hours TYPE decimal DEFAULT 0.0;
DEFINE FIELD invoice_line ON extra_hours TYPE record<invoice_line>;
DEFINE FIELD created_at ON extra_hours TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON extra_hours TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON extra_hours TYPE int DEFAULT 0;

-- Préparation de paie (PayrollPreparation.xml - 3410 bytes)
DEFINE TABLE payroll_preparation SCHEMAFULL;
DEFINE FIELD employee ON payroll_preparation TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON payroll_preparation TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD payroll_seq ON payroll_preparation TYPE string READONLY;
DEFINE FIELD period ON payroll_preparation TYPE record<period> ASSERT $value != NONE;
DEFINE FIELD period_from ON payroll_preparation TYPE date ASSERT $value != NONE;
DEFINE FIELD period_to ON payroll_preparation TYPE date ASSERT $value != NONE;
DEFINE FIELD status_select ON payroll_preparation TYPE int DEFAULT 1; -- 1:Draft, 2:Calculated, 3:Validated, 4:Paid, 5:Archived
DEFINE FIELD calculation_date ON payroll_preparation TYPE datetime;
DEFINE FIELD validation_date ON payroll_preparation TYPE datetime;
DEFINE FIELD validated_by ON payroll_preparation TYPE record<user>;
DEFINE FIELD payment_date ON payroll_preparation TYPE datetime;
DEFINE FIELD basic_salary ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD worked_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD normal_worked_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD overtime_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD night_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD weekend_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD holiday_hours ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD gross_salary ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD net_salary ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_deductions ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_contributions ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_allowances ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_bonuses ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_advances ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD income_tax ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD social_security_employee ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD social_security_employer ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD unemployment_insurance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD health_insurance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD retirement_contribution ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD leave_balance_opening ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD leave_taken ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD leave_accrued ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD leave_balance_closing ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD lunch_voucher_amount ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD transport_allowance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD mobile_allowance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD meal_allowance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD housing_allowance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD family_allowance ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD payroll_leave_list ON payroll_preparation TYPE array<record<payroll_leave>>;
DEFINE FIELD expense_reimbursement ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD advance_recovery ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD loan_recovery ON payroll_preparation TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON payroll_preparation TYPE record<currency>;
DEFINE FIELD exchange_rate ON payroll_preparation TYPE decimal DEFAULT 1.0;
DEFINE FIELD payslip_generated ON payroll_preparation TYPE bool DEFAULT false;
DEFINE FIELD payslip_file ON payroll_preparation TYPE record<meta_file>;
DEFINE FIELD payment_method ON payroll_preparation TYPE int DEFAULT 1; -- 1:Bank Transfer, 2:Cash, 3:Cheque
DEFINE FIELD bank_details ON payroll_preparation TYPE record<bank_details>;
DEFINE FIELD accounting_move ON payroll_preparation TYPE record<move>;
DEFINE FIELD comments ON payroll_preparation TYPE string;
DEFINE FIELD created_at ON payroll_preparation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payroll_preparation TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payroll_preparation TYPE int DEFAULT 0;

-- Tables de support
DEFINE TABLE employee_advance_usage SCHEMAFULL;
DEFINE FIELD employee_advance ON employee_advance_usage TYPE record<employee_advance> ASSERT $value != NONE;
DEFINE FIELD usage_date ON employee_advance_usage TYPE date ASSERT $value != NONE;
DEFINE FIELD amount_used ON employee_advance_usage TYPE decimal ASSERT $value != NONE;
DEFINE FIELD description ON employee_advance_usage TYPE string;
DEFINE FIELD justification_document ON employee_advance_usage TYPE record<meta_file>;
DEFINE FIELD expense ON employee_advance_usage TYPE record<expense>;
DEFINE FIELD remaining_balance ON employee_advance_usage TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON employee_advance_usage TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_advance_usage TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_advance_usage TYPE int DEFAULT 0;

DEFINE TABLE employee_bonus_mgt_line SCHEMAFULL;
DEFINE FIELD employee_bonus_mgt ON employee_bonus_mgt_line TYPE record<employee_bonus_mgt> ASSERT $value != NONE;
DEFINE FIELD employee_bonus_type ON employee_bonus_mgt_line TYPE record<employee_bonus_type> ASSERT $value != NONE;
DEFINE FIELD quantity ON employee_bonus_mgt_line TYPE decimal DEFAULT 1.0;
DEFINE FIELD unit_amount ON employee_bonus_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON employee_bonus_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD percentage ON employee_bonus_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD base_amount ON employee_bonus_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD description ON employee_bonus_mgt_line TYPE string;
DEFINE FIELD created_at ON employee_bonus_mgt_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_bonus_mgt_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_bonus_mgt_line TYPE int DEFAULT 0;

DEFINE TABLE lunch_voucher_mgt_line SCHEMAFULL;
DEFINE FIELD lunch_voucher_mgt ON lunch_voucher_mgt_line TYPE record<lunch_voucher_mgt> ASSERT $value != NONE;
DEFINE FIELD date ON lunch_voucher_mgt_line TYPE date ASSERT $value != NONE;
DEFINE FIELD quantity ON lunch_voucher_mgt_line TYPE int DEFAULT 1;
DEFINE FIELD unit_price ON lunch_voucher_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON lunch_voucher_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD employee_contribution ON lunch_voucher_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD company_contribution ON lunch_voucher_mgt_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD voucher_numbers ON lunch_voucher_mgt_line TYPE string;
DEFINE FIELD status_select ON lunch_voucher_mgt_line TYPE int DEFAULT 1; -- 1:Available, 2:Used, 3:Expired, 4:Lost
DEFINE FIELD usage_date ON lunch_voucher_mgt_line TYPE date;
DEFINE FIELD merchant_name ON lunch_voucher_mgt_line TYPE string;
DEFINE FIELD created_at ON lunch_voucher_mgt_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON lunch_voucher_mgt_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON lunch_voucher_mgt_line TYPE int DEFAULT 0;

DEFINE TABLE extra_hours_line SCHEMAFULL;
DEFINE FIELD extra_hours ON extra_hours_line TYPE record<extra_hours> ASSERT $value != NONE;
DEFINE FIELD date ON extra_hours_line TYPE date ASSERT $value != NONE;
DEFINE FIELD start_time ON extra_hours_line TYPE time;
DEFINE FIELD end_time ON extra_hours_line TYPE time;
DEFINE FIELD quantity ON extra_hours_line TYPE decimal ASSERT $value != NONE;
DEFINE FIELD hourly_rate ON extra_hours_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON extra_hours_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD description ON extra_hours_line TYPE string;
DEFINE FIELD project ON extra_hours_line TYPE record<project>;
DEFINE FIELD task ON extra_hours_line TYPE record<project_task>;
DEFINE FIELD is_billable ON extra_hours_line TYPE bool DEFAULT false;
DEFINE FIELD created_at ON extra_hours_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON extra_hours_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON extra_hours_line TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_employee_advance_employee ON employee_advance FIELDS employee;
DEFINE INDEX idx_employee_advance_company ON employee_advance FIELDS company;
DEFINE INDEX idx_employee_advance_date ON employee_advance FIELDS advance_date;
DEFINE INDEX idx_employee_advance_status ON employee_advance FIELDS status_select;
DEFINE INDEX idx_employee_advance_type ON employee_advance FIELDS advance_type;
DEFINE INDEX idx_employee_advance_emergency ON employee_advance FIELDS is_emergency;

DEFINE INDEX idx_employee_bonus_employee ON employee_bonus_mgt FIELDS employee;
DEFINE INDEX idx_employee_bonus_company ON employee_bonus_mgt FIELDS company;
DEFINE INDEX idx_employee_bonus_date ON employee_bonus_mgt FIELDS bonus_date;
DEFINE INDEX idx_employee_bonus_status ON employee_bonus_mgt FIELDS status_select;
DEFINE INDEX idx_employee_bonus_type ON employee_bonus_mgt FIELDS employee_bonus_type;

DEFINE INDEX idx_lunch_voucher_employee ON lunch_voucher_mgt FIELDS employee;
DEFINE INDEX idx_lunch_voucher_company ON lunch_voucher_mgt FIELDS company;
DEFINE INDEX idx_lunch_voucher_date ON lunch_voucher_mgt FIELDS distribution_date;
DEFINE INDEX idx_lunch_voucher_status ON lunch_voucher_mgt FIELDS status_select;
DEFINE INDEX idx_lunch_voucher_format ON lunch_voucher_mgt FIELDS lunch_voucher_format_select;

DEFINE INDEX idx_extra_hours_employee ON extra_hours FIELDS employee;
DEFINE INDEX idx_extra_hours_company ON extra_hours FIELDS company;
DEFINE INDEX idx_extra_hours_date ON extra_hours FIELDS date;
DEFINE INDEX idx_extra_hours_status ON extra_hours FIELDS status_select;
DEFINE INDEX idx_extra_hours_type ON extra_hours FIELDS extra_hours_type;

DEFINE INDEX idx_payroll_prep_employee ON payroll_preparation FIELDS employee;
DEFINE INDEX idx_payroll_prep_company ON payroll_preparation FIELDS company;
DEFINE INDEX idx_payroll_prep_period ON payroll_preparation FIELDS period;
DEFINE INDEX idx_payroll_prep_status ON payroll_preparation FIELDS status_select;
DEFINE INDEX idx_payroll_prep_dates ON payroll_preparation FIELDS period_from, period_to; 