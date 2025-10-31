-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 6 : VEHICLES & COSTS  
-- ================================================================================
-- Entités : EmployeeVehicle, KilometricLog, PayGrid, CollectiveAgreement, OtherCostsEmployee
-- Basé sur EmployeeVehicle.xml (1043 bytes), KilometricLog.xml (820 bytes), PayGrid.xml (1014 bytes)
-- CollectiveAgreement.xml (812 bytes), OtherCostsEmployee.xml (644 bytes)
-- ================================================================================

-- Véhicule employé (EmployeeVehicle.xml - 1043 bytes)
DEFINE TABLE employee_vehicle SCHEMAFULL;
DEFINE FIELD employee ON employee_vehicle TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD vehicle ON employee_vehicle TYPE record<vehicle>;
DEFINE FIELD vehicle_registration_number ON employee_vehicle TYPE string;
DEFINE FIELD vehicle_make ON employee_vehicle TYPE string;
DEFINE FIELD vehicle_model ON employee_vehicle TYPE string;
DEFINE FIELD vehicle_year ON employee_vehicle TYPE int;
DEFINE FIELD vehicle_color ON employee_vehicle TYPE string;
DEFINE FIELD vehicle_type ON employee_vehicle TYPE int DEFAULT 1; -- 1:Company Car, 2:Personal Car, 3:Pool Car, 4:Rental
DEFINE FIELD ownership_type ON employee_vehicle TYPE int DEFAULT 1; -- 1:Company Owned, 2:Employee Owned, 3:Leased, 4:Rental
DEFINE FIELD start_date ON employee_vehicle TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON employee_vehicle TYPE date;
DEFINE FIELD is_active ON employee_vehicle TYPE bool DEFAULT true;
DEFINE FIELD fuel_type ON employee_vehicle TYPE int DEFAULT 1; -- 1:Petrol, 2:Diesel, 3:Electric, 4:Hybrid, 5:LPG
DEFINE FIELD engine_capacity ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD co2_emission ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD fiscal_power ON employee_vehicle TYPE int DEFAULT 0;
DEFINE FIELD purchase_date ON employee_vehicle TYPE date;
DEFINE FIELD purchase_price ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD current_value ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD mileage_start ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD mileage_current ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD insurance_company ON employee_vehicle TYPE string;
DEFINE FIELD insurance_policy_number ON employee_vehicle TYPE string;
DEFINE FIELD insurance_expiry_date ON employee_vehicle TYPE date;
DEFINE FIELD maintenance_schedule ON employee_vehicle TYPE string;
DEFINE FIELD last_maintenance_date ON employee_vehicle TYPE date;
DEFINE FIELD next_maintenance_date ON employee_vehicle TYPE date;
DEFINE FIELD maintenance_cost_yearly ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD fuel_cost_monthly ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD insurance_cost_yearly ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD depreciation_rate ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD benefit_in_kind_value ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_personal_use_allowed ON employee_vehicle TYPE bool DEFAULT false;
DEFINE FIELD personal_use_percentage ON employee_vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD fuel_card_number ON employee_vehicle TYPE string;
DEFINE FIELD toll_tag_number ON employee_vehicle TYPE string;
DEFINE FIELD parking_space_number ON employee_vehicle TYPE string;
DEFINE FIELD comments ON employee_vehicle TYPE string;
DEFINE FIELD documents_list ON employee_vehicle TYPE array<record<meta_file>>;
DEFINE FIELD kilometric_log_list ON employee_vehicle TYPE array<record<kilometric_log>>;
DEFINE FIELD created_at ON employee_vehicle TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_vehicle TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_vehicle TYPE int DEFAULT 0;

-- Journal kilométrique (KilometricLog.xml - 820 bytes)
DEFINE TABLE kilometric_log SCHEMAFULL;
DEFINE FIELD employee ON kilometric_log TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD employee_vehicle ON kilometric_log TYPE record<employee_vehicle>;
DEFINE FIELD expense ON kilometric_log TYPE record<expense>;
DEFINE FIELD expense_line ON kilometric_log TYPE record<expense_line>;
DEFINE FIELD date ON kilometric_log TYPE date ASSERT $value != NONE;
DEFINE FIELD from_city ON kilometric_log TYPE string ASSERT $value != NONE;
DEFINE FIELD to_city ON kilometric_log TYPE string ASSERT $value != NONE;
DEFINE FIELD distance_km ON kilometric_log TYPE decimal ASSERT $value != NONE;
DEFINE FIELD purpose ON kilometric_log TYPE string ASSERT $value != NONE;
DEFINE FIELD trip_type ON kilometric_log TYPE int DEFAULT 1; -- 1:Business, 2:Commute, 3:Personal
DEFINE FIELD route_description ON kilometric_log TYPE string;
DEFINE FIELD kilometric_allowance_rate ON kilometric_log TYPE record<kilometric_allowance_rate>;
DEFINE FIELD rate_per_km ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON kilometric_log TYPE record<currency>;
DEFINE FIELD odometer_start ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD odometer_end ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD fuel_cost ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD toll_cost ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD parking_cost ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD other_costs ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_expenses ON kilometric_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD client_project ON kilometric_log TYPE record<project>;
DEFINE FIELD is_billable ON kilometric_log TYPE bool DEFAULT false;
DEFINE FIELD invoiced ON kilometric_log TYPE bool DEFAULT false;
DEFINE FIELD invoice_line ON kilometric_log TYPE record<invoice_line>;
DEFINE FIELD gps_start_location ON kilometric_log TYPE string;
DEFINE FIELD gps_end_location ON kilometric_log TYPE string;
DEFINE FIELD route_map_file ON kilometric_log TYPE record<meta_file>;
DEFINE FIELD justification_documents ON kilometric_log TYPE array<record<meta_file>>;
DEFINE FIELD validated ON kilometric_log TYPE bool DEFAULT false;
DEFINE FIELD validated_by ON kilometric_log TYPE record<user>;
DEFINE FIELD validation_date ON kilometric_log TYPE datetime;
DEFINE FIELD comments ON kilometric_log TYPE string;
DEFINE FIELD created_at ON kilometric_log TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON kilometric_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON kilometric_log TYPE int DEFAULT 0;

-- Grille de salaires (PayGrid.xml - 1014 bytes)  
DEFINE TABLE pay_grid SCHEMAFULL;
DEFINE FIELD name ON pay_grid TYPE string ASSERT $value != NONE;
DEFINE FIELD company ON pay_grid TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD description ON pay_grid TYPE string;
DEFINE FIELD pay_scale_type ON pay_grid TYPE int DEFAULT 1; -- 1:Experience Based, 2:Qualification Based, 3:Performance Based, 4:Position Based
DEFINE FIELD currency ON pay_grid TYPE record<currency>;
DEFINE FIELD effective_date ON pay_grid TYPE date ASSERT $value != NONE;
DEFINE FIELD expiry_date ON pay_grid TYPE date;
DEFINE FIELD is_active ON pay_grid TYPE bool DEFAULT true;
DEFINE FIELD pay_grid_line_list ON pay_grid TYPE array<record<pay_grid_line>>;
DEFINE FIELD qualification_level_mapping ON pay_grid TYPE array<record<qualification_level>>;
DEFINE FIELD experience_min_years ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD experience_max_years ON pay_grid TYPE decimal DEFAULT 50.0;
DEFINE FIELD salary_min ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_max ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD salary_median ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD annual_increase_percentage ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD performance_bonus_percentage ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD overtime_rate_multiplier ON pay_grid TYPE decimal DEFAULT 1.25;
DEFINE FIELD night_shift_bonus ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD weekend_bonus ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD holiday_bonus ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD location_adjustment_factor ON pay_grid TYPE decimal DEFAULT 1.0;
DEFINE FIELD cost_of_living_adjustment ON pay_grid TYPE decimal DEFAULT 0.0;
DEFINE FIELD market_adjustment_factor ON pay_grid TYPE decimal DEFAULT 1.0;
DEFINE FIELD review_frequency_months ON pay_grid TYPE int DEFAULT 12;
DEFINE FIELD last_review_date ON pay_grid TYPE date;
DEFINE FIELD next_review_date ON pay_grid TYPE date;
DEFINE FIELD approval_required ON pay_grid TYPE bool DEFAULT true;
DEFINE FIELD approved_by ON pay_grid TYPE record<user>;
DEFINE FIELD approval_date ON pay_grid TYPE datetime;
DEFINE FIELD comments ON pay_grid TYPE string;
DEFINE FIELD created_at ON pay_grid TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON pay_grid TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pay_grid TYPE int DEFAULT 0;

-- Convention collective (CollectiveAgreement.xml - 812 bytes)
DEFINE TABLE collective_agreement SCHEMAFULL;
DEFINE FIELD name ON collective_agreement TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON collective_agreement TYPE string UNIQUE;
DEFINE FIELD description ON collective_agreement TYPE string;
DEFINE FIELD sector ON collective_agreement TYPE string;
DEFINE FIELD industry_type ON collective_agreement TYPE string;
DEFINE FIELD effective_date ON collective_agreement TYPE date ASSERT $value != NONE;
DEFINE FIELD expiry_date ON collective_agreement TYPE date;
DEFINE FIELD is_active ON collective_agreement TYPE bool DEFAULT true;
DEFINE FIELD signatory_organizations ON collective_agreement TYPE array<string>;
DEFINE FIELD applicable_regions ON collective_agreement TYPE array<string>;
DEFINE FIELD minimum_wage ON collective_agreement TYPE decimal DEFAULT 0.0;
DEFINE FIELD working_hours_per_week ON collective_agreement TYPE decimal DEFAULT 35.0;
DEFINE FIELD overtime_compensation_type ON collective_agreement TYPE int DEFAULT 1; -- 1:Pay, 2:Time Off, 3:Choice
DEFINE FIELD overtime_rate_multiplier ON collective_agreement TYPE decimal DEFAULT 1.25;
DEFINE FIELD night_work_bonus_percentage ON collective_agreement TYPE decimal DEFAULT 10.0;
DEFINE FIELD sunday_work_bonus_percentage ON collective_agreement TYPE decimal DEFAULT 30.0;
DEFINE FIELD holiday_work_bonus_percentage ON collective_agreement TYPE decimal DEFAULT 50.0;
DEFINE FIELD annual_leave_days ON collective_agreement TYPE decimal DEFAULT 25.0;
DEFINE FIELD sick_leave_days_per_year ON collective_agreement TYPE decimal DEFAULT 12.0;
DEFINE FIELD maternity_leave_weeks ON collective_agreement TYPE decimal DEFAULT 16.0;
DEFINE FIELD paternity_leave_weeks ON collective_agreement TYPE decimal DEFAULT 2.0;
DEFINE FIELD notice_period_days ON collective_agreement TYPE int DEFAULT 30;
DEFINE FIELD probation_period_days ON collective_agreement TYPE int DEFAULT 90;
DEFINE FIELD severance_pay_formula ON collective_agreement TYPE string;
DEFINE FIELD retirement_age ON collective_agreement TYPE int DEFAULT 62;
DEFINE FIELD pension_contribution_employee ON collective_agreement TYPE decimal DEFAULT 7.5;
DEFINE FIELD pension_contribution_employer ON collective_agreement TYPE decimal DEFAULT 15.0;
DEFINE FIELD health_insurance_contribution ON collective_agreement TYPE decimal DEFAULT 8.0;
DEFINE FIELD training_budget_percentage ON collective_agreement TYPE decimal DEFAULT 1.0;
DEFINE FIELD safety_equipment_provided ON collective_agreement TYPE bool DEFAULT true;
DEFINE FIELD workplace_safety_standards ON collective_agreement TYPE string;
DEFINE FIELD dispute_resolution_process ON collective_agreement TYPE string;
DEFINE FIELD modification_procedure ON collective_agreement TYPE string;
DEFINE FIELD renewal_terms ON collective_agreement TYPE string;
DEFINE FIELD document_file ON collective_agreement TYPE record<meta_file>;
DEFINE FIELD created_at ON collective_agreement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON collective_agreement TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON collective_agreement TYPE int DEFAULT 0;

-- Autres coûts employé (OtherCostsEmployee.xml - 644 bytes)
DEFINE TABLE other_costs_employee SCHEMAFULL;
DEFINE FIELD employee ON other_costs_employee TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON other_costs_employee TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD cost_type ON other_costs_employee TYPE string ASSERT $value != NONE;
DEFINE FIELD cost_category ON other_costs_employee TYPE int DEFAULT 1; -- 1:Training, 2:Equipment, 3:Certification, 4:Travel, 5:Relocation, 6:Other
DEFINE FIELD description ON other_costs_employee TYPE string ASSERT $value != NONE;
DEFINE FIELD cost_date ON other_costs_employee TYPE date ASSERT $value != NONE;
DEFINE FIELD amount ON other_costs_employee TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON other_costs_employee TYPE record<currency>;
DEFINE FIELD supplier_partner ON other_costs_employee TYPE record<partner>;
DEFINE FIELD invoice_reference ON other_costs_employee TYPE string;
DEFINE FIELD payment_method ON other_costs_employee TYPE int DEFAULT 1; -- 1:Company Direct, 2:Reimbursement, 3:Advance Deduction
DEFINE FIELD payment_status ON other_costs_employee TYPE int DEFAULT 1; -- 1:Pending, 2:Paid, 3:Reimbursed, 4:Cancelled
DEFINE FIELD payment_date ON other_costs_employee TYPE date;
DEFINE FIELD project ON other_costs_employee TYPE record<project>;
DEFINE FIELD analytical_account ON other_costs_employee TYPE record<analytic_account>;
DEFINE FIELD analytical_move_line ON other_costs_employee TYPE record<analytic_move_line>;
DEFINE FIELD is_billable_to_client ON other_costs_employee TYPE bool DEFAULT false;
DEFINE FIELD client_billing_rate ON other_costs_employee TYPE decimal DEFAULT 0.0;
DEFINE FIELD invoice_line ON other_costs_employee TYPE record<invoice_line>;
DEFINE FIELD invoiced ON other_costs_employee TYPE bool DEFAULT false;
DEFINE FIELD amortization_period_months ON other_costs_employee TYPE int DEFAULT 0;
DEFINE FIELD amortization_start_date ON other_costs_employee TYPE date;
DEFINE FIELD amortized_amount_monthly ON other_costs_employee TYPE decimal DEFAULT 0.0;
DEFINE FIELD remaining_amortization ON other_costs_employee TYPE decimal DEFAULT 0.0;
DEFINE FIELD asset_created ON other_costs_employee TYPE bool DEFAULT false;
DEFINE FIELD asset_reference ON other_costs_employee TYPE string;
DEFINE FIELD tax_deductible ON other_costs_employee TYPE bool DEFAULT true;
DEFINE FIELD tax_deduction_percentage ON other_costs_employee TYPE decimal DEFAULT 100.0;
DEFINE FIELD approval_required ON other_costs_employee TYPE bool DEFAULT false;
DEFINE FIELD approved_by ON other_costs_employee TYPE record<user>;
DEFINE FIELD approval_date ON other_costs_employee TYPE datetime;
DEFINE FIELD supporting_documents ON other_costs_employee TYPE array<record<meta_file>>;
DEFINE FIELD comments ON other_costs_employee TYPE string;
DEFINE FIELD created_at ON other_costs_employee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON other_costs_employee TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON other_costs_employee TYPE int DEFAULT 0;

-- Tables de support
DEFINE TABLE pay_grid_line SCHEMAFULL;
DEFINE FIELD pay_grid ON pay_grid_line TYPE record<pay_grid> ASSERT $value != NONE;
DEFINE FIELD level ON pay_grid_line TYPE int ASSERT $value != NONE;
DEFINE FIELD level_name ON pay_grid_line TYPE string;
DEFINE FIELD min_experience_years ON pay_grid_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_experience_years ON pay_grid_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD min_salary ON pay_grid_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_salary ON pay_grid_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD mid_point_salary ON pay_grid_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD qualification_requirements ON pay_grid_line TYPE string;
DEFINE FIELD skills_requirements ON pay_grid_line TYPE string;
DEFINE FIELD responsibilities ON pay_grid_line TYPE string;
DEFINE FIELD progression_criteria ON pay_grid_line TYPE string;
DEFINE FIELD created_at ON pay_grid_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON pay_grid_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pay_grid_line TYPE int DEFAULT 0;

DEFINE TABLE kilometric_allowance_rate SCHEMAFULL;
DEFINE FIELD name ON kilometric_allowance_rate TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle_category ON kilometric_allowance_rate TYPE string ASSERT $value != NONE;
DEFINE FIELD engine_power_range ON kilometric_allowance_rate TYPE string;
DEFINE FIELD distance_range_km ON kilometric_allowance_rate TYPE string;
DEFINE FIELD rate_per_km ON kilometric_allowance_rate TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON kilometric_allowance_rate TYPE record<currency>;
DEFINE FIELD effective_date ON kilometric_allowance_rate TYPE date ASSERT $value != NONE;
DEFINE FIELD expiry_date ON kilometric_allowance_rate TYPE date;
DEFINE FIELD is_active ON kilometric_allowance_rate TYPE bool DEFAULT true;
DEFINE FIELD tax_deductible_percentage ON kilometric_allowance_rate TYPE decimal DEFAULT 100.0;
DEFINE FIELD max_annual_distance ON kilometric_allowance_rate TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON kilometric_allowance_rate TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON kilometric_allowance_rate TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON kilometric_allowance_rate TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_employee_vehicle_employee ON employee_vehicle FIELDS employee;
DEFINE INDEX idx_employee_vehicle_active ON employee_vehicle FIELDS is_active;
DEFINE INDEX idx_employee_vehicle_type ON employee_vehicle FIELDS vehicle_type;
DEFINE INDEX idx_employee_vehicle_dates ON employee_vehicle FIELDS start_date, end_date;
DEFINE INDEX idx_employee_vehicle_registration ON employee_vehicle FIELDS vehicle_registration_number;

DEFINE INDEX idx_kilometric_log_employee ON kilometric_log FIELDS employee;
DEFINE INDEX idx_kilometric_log_vehicle ON kilometric_log FIELDS employee_vehicle;
DEFINE INDEX idx_kilometric_log_date ON kilometric_log FIELDS date;
DEFINE INDEX idx_kilometric_log_expense ON kilometric_log FIELDS expense;
DEFINE INDEX idx_kilometric_log_type ON kilometric_log FIELDS trip_type;
DEFINE INDEX idx_kilometric_log_billable ON kilometric_log FIELDS is_billable;
DEFINE INDEX idx_kilometric_log_validated ON kilometric_log FIELDS validated;

DEFINE INDEX idx_pay_grid_name ON pay_grid FIELDS name;
DEFINE INDEX idx_pay_grid_company ON pay_grid FIELDS company;
DEFINE INDEX idx_pay_grid_active ON pay_grid FIELDS is_active;
DEFINE INDEX idx_pay_grid_type ON pay_grid FIELDS pay_scale_type;
DEFINE INDEX idx_pay_grid_effective ON pay_grid FIELDS effective_date;

DEFINE INDEX idx_collective_agreement_name ON collective_agreement FIELDS name;
DEFINE INDEX idx_collective_agreement_code ON collective_agreement FIELDS code;
DEFINE INDEX idx_collective_agreement_active ON collective_agreement FIELDS is_active;
DEFINE INDEX idx_collective_agreement_sector ON collective_agreement FIELDS sector;
DEFINE INDEX idx_collective_agreement_effective ON collective_agreement FIELDS effective_date;

DEFINE INDEX idx_other_costs_employee ON other_costs_employee FIELDS employee;
DEFINE INDEX idx_other_costs_company ON other_costs_employee FIELDS company;
DEFINE INDEX idx_other_costs_date ON other_costs_employee FIELDS cost_date;
DEFINE INDEX idx_other_costs_category ON other_costs_employee FIELDS cost_category;
DEFINE INDEX idx_other_costs_status ON other_costs_employee FIELDS payment_status;
DEFINE INDEX idx_other_costs_billable ON other_costs_employee FIELDS is_billable_to_client;

DEFINE INDEX idx_pay_grid_line_grid ON pay_grid_line FIELDS pay_grid;
DEFINE INDEX idx_pay_grid_line_level ON pay_grid_line FIELDS level;

DEFINE INDEX idx_kilometric_rate_name ON kilometric_allowance_rate FIELDS name;
DEFINE INDEX idx_kilometric_rate_category ON kilometric_allowance_rate FIELDS vehicle_category;
DEFINE INDEX idx_kilometric_rate_active ON kilometric_allowance_rate FIELDS is_active;
DEFINE INDEX idx_kilometric_rate_effective ON kilometric_allowance_rate FIELDS effective_date; 