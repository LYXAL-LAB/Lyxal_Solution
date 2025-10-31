-- lyxalbank: STRUCTURE DES TABLES (FULL)

DEFINE TABLE bank_order SCHEMAFULL;
DEFINE FIELD order_date ON bank_order TYPE datetime ASSERT $value != NONE;
DEFINE FIELD status ON bank_order TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD amount ON bank_order TYPE number;
DEFINE FIELD currency ON bank_order TYPE record<currency>;
DEFINE FIELD company ON bank_order TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD partner ON bank_order TYPE record<partner>;
DEFINE FIELD payment_mode ON bank_order TYPE record<payment_mode>;
DEFINE FIELD economic_reason ON bank_order TYPE record<bank_order_economic_reason>;
DEFINE FIELD sequence_code ON bank_order TYPE string;
DEFINE FIELD is_validated ON bank_order TYPE bool DEFAULT false;

DEFINE TABLE bank_statement SCHEMAFULL;
DEFINE FIELD name ON bank_statement TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD from_date ON bank_statement TYPE datetime;
DEFINE FIELD to_date ON bank_statement TYPE datetime;
DEFINE FIELD status_select ON bank_statement TYPE int DEFAULT 1;
DEFINE FIELD file_format ON bank_statement TYPE record<bank_statement_file_format>;
DEFINE FIELD bank_file ON bank_statement TYPE record<file>;
DEFINE FIELD is_fully_reconciled ON bank_statement TYPE bool DEFAULT false;
DEFINE FIELD get_datetime ON bank_statement TYPE datetime;

DEFINE TABLE bank_statement_line SCHEMAFULL;
DEFINE FIELD operation_date ON bank_statement_line TYPE datetime;
DEFINE FIELD value_date ON bank_statement_line TYPE datetime;
DEFINE FIELD debit ON bank_statement_line TYPE number;
DEFINE FIELD credit ON bank_statement_line TYPE number;
DEFINE FIELD currency ON bank_statement_line TYPE record<currency>;
DEFINE FIELD bank_details ON bank_statement_line TYPE record<bank_details>;
DEFINE FIELD description ON bank_statement_line TYPE string;
DEFINE FIELD reference ON bank_statement_line TYPE string;
DEFINE FIELD origin ON bank_statement_line TYPE string;
DEFINE FIELD bank_statement ON bank_statement_line TYPE record<bank_statement>;
DEFINE FIELD move_line ON bank_statement_line TYPE record<move_line>;
DEFINE FIELD amount_remain_to_reconcile ON bank_statement_line TYPE number;
DEFINE FIELD payment_mode ON bank_statement_line TYPE record<payment_mode>;
DEFINE FIELD sequence ON bank_statement_line TYPE int;
DEFINE FIELD line_type_select ON bank_statement_line TYPE int;

DEFINE TABLE bank_details SCHEMAFULL;
DEFINE FIELD balance ON bank_details TYPE number;
DEFINE FIELD balance_updated_date ON bank_details TYPE datetime;

DEFINE TABLE bank_reconciliation SCHEMAFULL;
DEFINE FIELD name ON bank_reconciliation TYPE string;
DEFINE FIELD from_date ON bank_reconciliation TYPE datetime;
DEFINE FIELD to_date ON bank_reconciliation TYPE datetime;
DEFINE FIELD company ON bank_reconciliation TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD journal ON bank_reconciliation TYPE record<journal>;
DEFINE FIELD currency ON bank_reconciliation TYPE record<currency>;
DEFINE FIELD bank_details ON bank_reconciliation TYPE record<bank_details>;
DEFINE FIELD cash_account ON bank_reconciliation TYPE record<account>;
DEFINE FIELD starting_balance ON bank_reconciliation TYPE number;
DEFINE FIELD ending_balance ON bank_reconciliation TYPE number;
DEFINE FIELD account_balance ON bank_reconciliation TYPE number;
DEFINE FIELD computed_balance ON bank_reconciliation TYPE number;
DEFINE FIELD status_select ON bank_reconciliation TYPE int DEFAULT 1;
DEFINE FIELD bank_statement ON bank_reconciliation TYPE record<bank_statement>;
DEFINE FIELD include_other_bank_statements ON bank_reconciliation TYPE bool DEFAULT true;

DEFINE TABLE bank_reconciliation_line SCHEMAFULL;
DEFINE FIELD name ON bank_reconciliation_line TYPE string;
DEFINE FIELD effect_date ON bank_reconciliation_line TYPE datetime ASSERT $value != NONE;
DEFINE FIELD reference ON bank_reconciliation_line TYPE string;
DEFINE FIELD partner ON bank_reconciliation_line TYPE record<partner>;
DEFINE FIELD type_select ON bank_reconciliation_line TYPE int;
DEFINE FIELD account ON bank_reconciliation_line TYPE record<account>;
DEFINE FIELD debit ON bank_reconciliation_line TYPE number;
DEFINE FIELD credit ON bank_reconciliation_line TYPE number;
DEFINE FIELD bank_statement_line ON bank_reconciliation_line TYPE record<bank_statement_line>;
DEFINE FIELD move_line ON bank_reconciliation_line TYPE record<move_line>;
DEFINE FIELD is_posted ON bank_reconciliation_line TYPE bool DEFAULT false;
DEFINE FIELD confidence_index ON bank_reconciliation_line TYPE int;

DEFINE TABLE bank_payment_config SCHEMAFULL;
DEFINE FIELD company ON bank_payment_config TYPE record<company> ASSERT $value != NONE;
DEFINE FIELD default_signatory_user ON bank_payment_config TYPE record<user>;
DEFINE FIELD has_automatic_reconciliation ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD has_auto_move_from_statement_rule ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD bnk_stmt_auto_reconcile_amount_margin ON bank_payment_config TYPE number;
DEFINE FIELD bnk_stmt_auto_reconcile_date_margin ON bank_payment_config TYPE int;
DEFINE FIELD ics_number ON bank_payment_config TYPE string;


DEFINE TABLE bank_order_file_format SCHEMAFULL;
DEFINE FIELD code ON bank_order_file_format TYPE string;
DEFINE FIELD name ON bank_order_file_format TYPE string;
DEFINE FIELD file_extension ON bank_order_file_format TYPE string;
DEFINE FIELD file_type ON bank_order_file_format TYPE string;
DEFINE FIELD class_name ON bank_order_file_format TYPE string;
DEFINE FIELD order_type_select ON bank_order_file_format TYPE int;

DEFINE TABLE bank_order_file_format_country SCHEMAFULL;
DEFINE FIELD bank_order_file_format ON bank_order_file_format_country TYPE record<bank_order_file_format>;
DEFINE FIELD country ON bank_order_file_format_country TYPE record<country>;
DEFINE FIELD receiver_address_required ON bank_order_file_format_country TYPE bool;

DEFINE TABLE bank_statement_file_format SCHEMAFULL;
DEFINE FIELD code ON bank_statement_file_format TYPE string;
DEFINE FIELD name ON bank_statement_file_format TYPE string;
DEFINE FIELD file_extension ON bank_statement_file_format TYPE string;
DEFINE FIELD file_type ON bank_statement_file_format TYPE string;
DEFINE FIELD class_name ON bank_statement_file_format TYPE string;

DEFINE TABLE bank_statement_rule SCHEMAFULL;
DEFINE FIELD account_management ON bank_statement_rule TYPE record<account_management> ASSERT $value != NONE;
DEFINE FIELD counterpart_account ON bank_statement_rule TYPE record<account>;
DEFINE FIELD partner ON bank_statement_rule TYPE record<partner>;
DEFINE FIELD bank_statement_query ON bank_statement_rule TYPE record<bank_statement_query>;
DEFINE FIELD rule_type_select ON bank_statement_rule TYPE int DEFAULT 0;
DEFINE FIELD search_label ON bank_statement_rule TYPE string;
DEFINE FIELD partner_fetch_method_select ON bank_statement_rule TYPE int DEFAULT 1;
DEFINE FIELD partner_bank_statement_query ON bank_statement_rule TYPE record<bank_statement_query>;
DEFINE FIELD letter_to_invoice ON bank_statement_rule TYPE bool;
DEFINE FIELD move_line_bank_statement_query ON bank_statement_rule TYPE record<bank_statement_query>;
DEFINE FIELD specific_tax ON bank_statement_rule TYPE record<tax>;
DEFINE FIELD entry_origin_computation ON bank_statement_rule TYPE string;
DEFINE FIELD entry_description_computation ON bank_statement_rule TYPE string;

DEFINE TABLE bank_statement_query SCHEMAFULL;
DEFINE FIELD name ON bank_statement_query TYPE string ASSERT $value != NONE;
DEFINE FIELD query ON bank_statement_query TYPE string ASSERT $value != NONE;
DEFINE FIELD rule_type_select ON bank_statement_query TYPE int DEFAULT 0;
DEFINE FIELD confidence_index ON bank_statement_query TYPE int DEFAULT 1;
DEFINE FIELD sequence ON bank_statement_query TYPE int;

DEFINE TABLE bank_statement_line_afb120 SCHEMAFULL;
DEFINE FIELD unavailability_index_select ON bank_statement_line_afb120 TYPE int;
DEFINE FIELD commission_exemption_index_select ON bank_statement_line_afb120 TYPE int;

DEFINE TABLE invoice_payment SCHEMAFULL;
DEFINE FIELD move_line ON invoice_payment TYPE record<move_line>;
DEFINE FIELD amount ON invoice_payment TYPE number;
DEFINE FIELD payment_mode ON invoice_payment TYPE record<payment_mode>;
DEFINE FIELD payment_date ON invoice_payment TYPE datetime;
DEFINE FIELD payment_session ON invoice_payment TYPE record<payment_session>;

DEFINE TABLE payment_session SCHEMAFULL;
DEFINE FIELD name ON payment_session TYPE string;
DEFINE FIELD status_select ON payment_session TYPE int;
DEFINE FIELD payment_date ON payment_session TYPE datetime;
DEFINE FIELD currency ON payment_session TYPE record<currency>;
DEFINE FIELD company ON payment_session TYPE record<company>;

DEFINE TABLE app_bank_payment SCHEMAFULL;
DEFINE FIELD app ON app_bank_payment TYPE record<app>;
DEFINE FIELD has_payment ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD has_bank_statement ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD has_reconciliation ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD has_payment_order ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD has_payment_batch ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD has_ics ON app_bank_payment TYPE bool DEFAULT false;