-- ================================================================================
-- LYXAL SURREAL - AXELOR HUMAN RESOURCE - MODULE 2 : TIMESHEET & EXPENSES
-- ================================================================================
-- Entités : Timesheet, TimesheetLine, Expense, ExpenseLine, TSTimer
-- Basé sur Timesheet.xml (2726 bytes), TimesheetLine.xml (3088 bytes)
-- Expense.xml (4806 bytes), ExpenseLine.xml (3687 bytes), TSTimer.xml (1747 bytes)
-- ================================================================================

-- Feuille de temps (Timesheet.xml - 2726 bytes)
DEFINE TABLE timesheet SCHEMAFULL;
DEFINE FIELD timesheet_seq ON timesheet TYPE string READONLY;
DEFINE FIELD employee ON timesheet TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON timesheet TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD from_date ON timesheet TYPE date ASSERT $value != NONE;
DEFINE FIELD to_date ON timesheet TYPE date ASSERT $value != NONE;
DEFINE FIELD status_select ON timesheet TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed, 3:Validated, 4:Refused
DEFINE FIELD period ON timesheet TYPE record<period>;
DEFINE FIELD timesheet_line_list ON timesheet TYPE array<record<timesheet_line>>;
DEFINE FIELD total_hours ON timesheet TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_duration ON timesheet TYPE decimal DEFAULT 0.0;
DEFINE FIELD user ON timesheet TYPE record<user>;
DEFINE FIELD validation_date ON timesheet TYPE datetime;
DEFINE FIELD validated_by ON timesheet TYPE record<user>;
DEFINE FIELD refusal_date ON timesheet TYPE datetime;
DEFINE FIELD refusal_reason ON timesheet TYPE string;
DEFINE FIELD refused_by ON timesheet TYPE record<user>;
DEFINE FIELD comments ON timesheet TYPE string;
DEFINE FIELD timesheet_report ON timesheet TYPE record<timesheet_report>;
DEFINE FIELD sent_date ON timesheet TYPE datetime;
DEFINE FIELD show_editor ON timesheet TYPE bool DEFAULT false;
DEFINE FIELD show_activity ON timesheet TYPE bool DEFAULT true;
DEFINE FIELD timesheet_timer_list ON timesheet TYPE array<record<ts_timer>>;
DEFINE FIELD created_at ON timesheet TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON timesheet TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON timesheet TYPE int DEFAULT 0;

-- Ligne de feuille de temps (TimesheetLine.xml - 3088 bytes)
DEFINE TABLE timesheet_line SCHEMAFULL;
DEFINE FIELD timesheet ON timesheet_line TYPE record<timesheet> ASSERT $value != NONE;
DEFINE FIELD employee ON timesheet_line TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD project ON timesheet_line TYPE record<project>;
DEFINE FIELD project_task ON timesheet_line TYPE record<project_task>;
DEFINE FIELD product ON timesheet_line TYPE record<product>;
DEFINE FIELD date ON timesheet_line TYPE date ASSERT $value != NONE;
DEFINE FIELD hours ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD duration ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD hourly_rate ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD comments ON timesheet_line TYPE string;
DEFINE FIELD activity_type_select ON timesheet_line TYPE int DEFAULT 1; -- 1:Normal, 2:Overtime, 3:Night, 4:Sunday, 5:Holiday
DEFINE FIELD invoice_line ON timesheet_line TYPE record<invoice_line>;
DEFINE FIELD invoiced ON timesheet_line TYPE bool DEFAULT false;
DEFINE FIELD to_invoice ON timesheet_line TYPE bool DEFAULT true;
DEFINE FIELD billable ON timesheet_line TYPE bool DEFAULT true;
DEFINE FIELD analytical_move_line ON timesheet_line TYPE record<analytic_move_line>;
DEFINE FIELD attendance_log ON timesheet_line TYPE record<attendance_log>;
DEFINE FIELD extra_hours ON timesheet_line TYPE record<extra_hours>;
DEFINE FIELD timer_start ON timesheet_line TYPE datetime;
DEFINE FIELD timer_stop ON timesheet_line TYPE datetime;
DEFINE FIELD timer_duration ON timesheet_line TO decimal DEFAULT 0.0;
DEFINE FIELD is_timer_on ON timesheet_line TYPE bool DEFAULT false;
DEFINE FIELD break_duration ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD overtime_hours ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD night_hours ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD sunday_hours ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD holiday_hours ON timesheet_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON timesheet_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON timesheet_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON timesheet_line TYPE int DEFAULT 0;

-- Note de frais (Expense.xml - 4806 bytes)
DEFINE TABLE expense SCHEMAFULL;
DEFINE FIELD expense_seq ON expense TYPE string READONLY;
DEFINE FIELD employee ON expense TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD company ON expense TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD user ON expense TYPE record<user>;
DEFINE FIELD period ON expense TYPE record<period>;
DEFINE FIELD expense_date ON expense TYPE date ASSERT $value != NONE;
DEFINE FIELD status_select ON expense TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed, 3:Validated, 4:Reimbursed, 5:Refused
DEFINE FIELD expense_line_list ON expense TYPE array<record<expense_line>>;
DEFINE FIELD total_amount ON expense TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_tax ON expense TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount_with_tax ON expense TYPE decimal DEFAULT 0.0;
DEFINE FIELD advance_amount ON expense TYPE decimal DEFAULT 0.0;
DEFINE FIELD reimbursement_amount ON expense TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON expense TYPE record<currency>;
DEFINE FIELD validation_date ON expense TYPE datetime;
DEFINE FIELD validated_by ON expense TYPE record<user>;
DEFINE FIELD payment_date ON expense TYPE datetime;
DEFINE FIELD paid_by ON expense TYPE record<user>;
DEFINE FIELD refusal_date ON expense TYPE datetime;
DEFINE FIELD refusal_reason ON expense TYPE string;
DEFINE FIELD refused_by ON expense TYPE record<user>;
DEFINE FIELD comments ON expense TYPE string;
DEFINE FIELD move ON expense TYPE record<move>;
DEFINE FIELD payment_move ON expense TYPE record<move>;
DEFINE FIELD bank_details ON expense TYPE record<bank_details>;
DEFINE FIELD expense_type_select ON expense TYPE int DEFAULT 1; -- 1:Professional, 2:Personal, 3:Mixed
DEFINE FIELD attachment_list ON expense TYPE array<record<meta_file>>;
DEFINE FIELD expense_advance_usage_list ON expense TYPE array<record<employee_advance_usage>>;
DEFINE FIELD sent_date ON expense TYPE datetime;
DEFINE FIELD multiple_users ON expense TYPE bool DEFAULT false;
DEFINE FIELD kilometric_expense_line_list ON expense TYPE array<record<kilometric_log>>;
DEFINE FIELD created_at ON expense TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON expense TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON expense TYPE int DEFAULT 0;

-- Ligne de note de frais (ExpenseLine.xml - 3687 bytes)
DEFINE TABLE expense_line SCHEMAFULL;
DEFINE FIELD expense ON expense_line TYPE record<expense> ASSERT $value != NONE;
DEFINE FIELD expense_date ON expense_line TYPE date ASSERT $value != NONE;
DEFINE FIELD expense_type ON expense_line TYPE record<expense_type>;
DEFINE FIELD description ON expense_line TYPE string ASSERT $value != NONE;
DEFINE FIELD total_amount ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD untaxed_amount ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_tax ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON expense_line TYPE record<currency>;
DEFINE FIELD project ON expense_line TYPE record<project>;
DEFINE FIELD analytical_move_line_list ON expense_line TYPE array<record<analytic_move_line>>;
DEFINE FIELD invoice_line ON expense_line TYPE record<invoice_line>;
DEFINE FIELD to_invoice ON expense_line TYPE bool DEFAULT false;
DEFINE FIELD invoiced ON expense_line TYPE bool DEFAULT false;
DEFINE FIELD justification_meta_file ON expense_line TYPE record<meta_file>;
DEFINE FIELD expense_product ON expense_line TYPE record<product>;
DEFINE FIELD tax_line_set ON expense_line TYPE array<record<tax_line>>;
DEFINE FIELD company_cb_select ON expense_line TYPE int DEFAULT 1; -- 1:No, 2:Yes
DEFINE FIELD personal_expense_amount ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_alcoolic_beverage ON expense_line TYPE bool DEFAULT false;
DEFINE FIELD expense_category ON expense_line TYPE string;
DEFINE FIELD supplier_partner ON expense_line TYPE record<partner>;
DEFINE FIELD attachment_required ON expense_line TYPE bool DEFAULT true;
DEFINE FIELD limit_exceeded ON expense_line TYPE bool DEFAULT false;
DEFINE FIELD limit_amount ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD exchange_rate ON expense_line TYPE decimal DEFAULT 1.0;
DEFINE FIELD converted_amount ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD mileage_distance ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD vehicle_category ON expense_line TYPE string;
DEFINE FIELD mileage_rate ON expense_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD from_city ON expense_line TYPE string;
DEFINE FIELD to_city ON expense_line TYPE string;
DEFINE FIELD comments ON expense_line TYPE string;
DEFINE FIELD created_at ON expense_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON expense_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON expense_line TYPE int DEFAULT 0;

-- Minuteur de temps (TSTimer.xml - 1747 bytes)
DEFINE TABLE ts_timer SCHEMAFULL;
DEFINE FIELD name ON ts_timer TYPE string;
DEFINE FIELD employee ON ts_timer TYPE record<employee> ASSERT $value != NONE;
DEFINE FIELD timesheet ON ts_timer TYPE record<timesheet>;
DEFINE FIELD timesheet_line ON ts_timer TYPE record<timesheet_line>;
DEFINE FIELD project ON ts_timer TYPE record<project>;
DEFINE FIELD project_task ON ts_timer TYPE record<project_task>;
DEFINE FIELD product ON ts_timer TYPE record<product>;
DEFINE FIELD timer_start_datetime ON ts_timer TYPE datetime;
DEFINE FIELD timer_end_datetime ON ts_timer TYPE datetime;
DEFINE FIELD duration ON ts_timer TYPE decimal DEFAULT 0.0;
DEFINE FIELD comments ON ts_timer TYPE string;
DEFINE FIELD status_select ON ts_timer TYPE int DEFAULT 1; -- 1:Started, 2:Paused, 3:Stopped
DEFINE FIELD pause_duration ON ts_timer TYPE decimal DEFAULT 0.0;
DEFINE FIELD pause_start_datetime ON ts_timer TYPE datetime;
DEFINE FIELD pause_reason ON ts_timer TYPE string;
DEFINE FIELD break_duration_list ON ts_timer TYPE array<record<timer_break>>;
DEFINE FIELD is_running ON ts_timer TYPE bool DEFAULT false;
DEFINE FIELD auto_save ON ts_timer TYPE bool DEFAULT true;
DEFINE FIELD reminder_frequency ON ts_timer TYPE int DEFAULT 60; -- En minutes
DEFINE FIELD last_reminder ON ts_timer TYPE datetime;
DEFINE FIELD total_productive_time ON ts_timer TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_break_time ON ts_timer TYPE decimal DEFAULT 0.0;
DEFINE FIELD efficiency_rate ON ts_timer TYPE decimal DEFAULT 100.0;
DEFINE FIELD created_at ON ts_timer TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ts_timer TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON ts_timer TYPE int DEFAULT 0;

-- Tables de support
DEFINE TABLE timer_break SCHEMAFULL;
DEFINE FIELD ts_timer ON timer_break TYPE record<ts_timer> ASSERT $value != NONE;
DEFINE FIELD break_start ON timer_break TYPE datetime ASSERT $value != NONE;
DEFINE FIELD break_end ON timer_break TYPE datetime;
DEFINE FIELD break_duration ON timer_break TYPE decimal DEFAULT 0.0;
DEFINE FIELD break_reason ON timer_break TYPE string;
DEFINE FIELD break_type ON timer_break TYPE int DEFAULT 1; -- 1:Lunch, 2:Coffee, 3:Meeting, 4:Personal, 5:Other
DEFINE FIELD created_at ON timer_break TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON timer_break TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON timer_break TYPE int DEFAULT 0;

DEFINE TABLE expense_type SCHEMAFULL;
DEFINE FIELD name ON expense_type TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON expense_type TYPE string UNIQUE;
DEFINE FIELD description ON expense_type TYPE string;
DEFINE FIELD expense_category ON expense_type TYPE string;
DEFINE FIELD default_product ON expense_type TYPE record<product>;
DEFINE FIELD requires_justification ON expense_type TYPE bool DEFAULT true;
DEFINE FIELD max_amount_per_expense ON expense_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_amount_per_month ON expense_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_mileage ON expense_type TYPE bool DEFAULT false;
DEFINE FIELD mileage_rate ON expense_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD tax_rate ON expense_type TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_active ON expense_type TYPE bool DEFAULT true;
DEFINE FIELD company_list ON expense_type TYPE array<record<company>>;
DEFINE FIELD created_at ON expense_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON expense_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON expense_type TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_timesheet_seq ON timesheet FIELDS timesheet_seq;
DEFINE INDEX idx_timesheet_employee ON timesheet FIELDS employee;
DEFINE INDEX idx_timesheet_company ON timesheet FIELDS company;
DEFINE INDEX idx_timesheet_period ON timesheet FIELDS from_date, to_date;
DEFINE INDEX idx_timesheet_status ON timesheet FIELDS status_select;
DEFINE INDEX idx_timesheet_validation ON timesheet FIELDS validation_date;
DEFINE INDEX idx_timesheet_user ON timesheet FIELDS user;

DEFINE INDEX idx_timesheet_line_timesheet ON timesheet_line FIELDS timesheet;
DEFINE INDEX idx_timesheet_line_employee ON timesheet_line FIELDS employee;
DEFINE INDEX idx_timesheet_line_date ON timesheet_line FIELDS date;
DEFINE INDEX idx_timesheet_line_project ON timesheet_line FIELDS project;
DEFINE INDEX idx_timesheet_line_task ON timesheet_line FIELDS project_task;
DEFINE INDEX idx_timesheet_line_product ON timesheet_line FIELDS product;
DEFINE INDEX idx_timesheet_line_invoiced ON timesheet_line FIELDS invoiced;
DEFINE INDEX idx_timesheet_line_billable ON timesheet_line FIELDS billable;

DEFINE INDEX idx_expense_seq ON expense FIELDS expense_seq;
DEFINE INDEX idx_expense_employee ON expense FIELDS employee;
DEFINE INDEX idx_expense_company ON expense FIELDS company;
DEFINE INDEX idx_expense_date ON expense FIELDS expense_date;
DEFINE INDEX idx_expense_status ON expense FIELDS status_select;
DEFINE INDEX idx_expense_validation ON expense FIELDS validation_date;
DEFINE INDEX idx_expense_payment ON expense FIELDS payment_date;
DEFINE INDEX idx_expense_user ON expense FIELDS user;

DEFINE INDEX idx_expense_line_expense ON expense_line FIELDS expense;
DEFINE INDEX idx_expense_line_date ON expense_line FIELDS expense_date;
DEFINE INDEX idx_expense_line_type ON expense_line FIELDS expense_type;
DEFINE INDEX idx_expense_line_project ON expense_line FIELDS project;
DEFINE INDEX idx_expense_line_invoiced ON expense_line FIELDS invoiced;
DEFINE INDEX idx_expense_line_amount ON expense_line FIELDS total_amount;

DEFINE INDEX idx_ts_timer_employee ON ts_timer FIELDS employee;
DEFINE INDEX idx_ts_timer_timesheet ON ts_timer FIELDS timesheet;
DEFINE INDEX idx_ts_timer_project ON ts_timer FIELDS project;
DEFINE INDEX idx_ts_timer_status ON ts_timer FIELDS status_select;
DEFINE INDEX idx_ts_timer_start ON ts_timer FIELDS timer_start_datetime;
DEFINE INDEX idx_ts_timer_running ON ts_timer FIELDS is_running;

DEFINE INDEX idx_timer_break_timer ON timer_break FIELDS ts_timer;
DEFINE INDEX idx_timer_break_start ON timer_break FIELDS break_start;
DEFINE INDEX idx_timer_break_type ON timer_break FIELDS break_type;

DEFINE INDEX idx_expense_type_name ON expense_type FIELDS name;
DEFINE INDEX idx_expense_type_code ON expense_type FIELDS code;
DEFINE INDEX idx_expense_type_active ON expense_type FIELDS is_active;
DEFINE INDEX idx_expense_type_mileage ON expense_type FIELDS is_mileage; 