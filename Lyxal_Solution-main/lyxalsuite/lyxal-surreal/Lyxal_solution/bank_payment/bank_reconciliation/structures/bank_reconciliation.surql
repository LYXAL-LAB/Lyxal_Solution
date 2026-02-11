-- Réconciliation bancaire principale
DEFINE TABLE bank_reconciliation SCHEMAFULL;
DEFINE FIELD name ON bank_reconciliation TYPE string;
DEFINE FIELD company ON bank_reconciliation TYPE record<company>;
DEFINE FIELD cash_account ON bank_reconciliation TYPE record<account>;
DEFINE FIELD journal ON bank_reconciliation TYPE record<journal>;
DEFINE FIELD from_date ON bank_reconciliation TYPE date;
DEFINE FIELD to_date ON bank_reconciliation TYPE date;
DEFINE FIELD including_other_bank_statements ON bank_reconciliation TYPE bool DEFAULT false;
DEFINE FIELD currency ON bank_reconciliation TYPE record<currency>;
DEFINE FIELD starting_balance ON bank_reconciliation TYPE decimal;
DEFINE FIELD ending_balance ON bank_reconciliation TYPE decimal;
DEFINE FIELD statement_balance ON bank_reconciliation TYPE decimal;
DEFINE FIELD computed_balance ON bank_reconciliation TYPE decimal;
DEFINE FIELD balance_difference ON bank_reconciliation TYPE decimal;
DEFINE FIELD total_unreconciled ON bank_reconciliation TYPE decimal;
DEFINE FIELD reconciliation_amount ON bank_reconciliation TYPE decimal;
DEFINE FIELD statement_reconciliation_amount ON bank_reconciliation TYPE decimal;
DEFINE FIELD unreconciled_amount ON bank_reconciliation TYPE decimal;
DEFINE FIELD status_select ON bank_reconciliation TYPE int DEFAULT 1;
DEFINE FIELD validated_date ON bank_reconciliation TYPE datetime;
DEFINE FIELD validated_by_user ON bank_reconciliation TYPE record<user>;
DEFINE FIELD include_other_bank_statements ON bank_reconciliation TYPE bool DEFAULT false;
DEFINE FIELD bank_reconciliation_line_list ON bank_reconciliation TYPE array<record<bank_reconciliation_line>>;
DEFINE FIELD move_line_set ON bank_reconciliation TYPE array<record<move_line>>;
DEFINE FIELD bank_statement_line_set ON bank_reconciliation TYPE array<record<bank_statement_line>>;
DEFINE FIELD bank_statement_query ON bank_reconciliation TYPE record<bank_statement_query>;
DEFINE FIELD load_bank_statement_line_set ON bank_reconciliation TYPE array<record<bank_statement_line>>;
DEFINE FIELD load_move_line_set ON bank_reconciliation TYPE array<record<move_line>>;
DEFINE FIELD automatic_reconcile_ok ON bank_reconciliation TYPE bool DEFAULT false;
DEFINE FIELD automatic_reconcile_threshold ON bank_reconciliation TYPE decimal DEFAULT 0.0;
DEFINE FIELD reconcile_unlettered_move_lines ON bank_reconciliation TYPE bool DEFAULT false;
DEFINE FIELD created_at ON bank_reconciliation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_reconciliation TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_reconciliation TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_reconciliation_company ON bank_reconciliation FIELDS company;
DEFINE INDEX idx_bank_reconciliation_account ON bank_reconciliation FIELDS cash_account;
DEFINE INDEX idx_bank_reconciliation_date ON bank_reconciliation FIELDS from_date, to_date;
DEFINE INDEX idx_bank_reconciliation_status ON bank_reconciliation FIELDS status_select;
DEFINE INDEX idx_bank_reconciliation_journal ON bank_reconciliation FIELDS journal;