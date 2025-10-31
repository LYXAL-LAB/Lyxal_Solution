-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 3 : PAIEMENTS
-- ================================================================================
-- Entités de paiements : PaymentSchedule, PaymentSession, PaymentVoucher, etc.
-- ================================================================================

-- ================================================================================  
-- ÉCHÉANCIERS DE PAIEMENT
-- ================================================================================

-- Échéanciers de paiement
DEFINE TABLE payment_schedule SCHEMAFULL;
DEFINE FIELD schedule_id ON payment_schedule TYPE string;
DEFINE FIELD company ON payment_schedule TYPE record<company>;
DEFINE FIELD partner ON payment_schedule TYPE record<partner>;
DEFINE FIELD payment_mode ON payment_schedule TYPE record<payment_mode>;
DEFINE FIELD bank_details ON payment_schedule TYPE record<bank_details>;
DEFINE FIELD start_date ON payment_schedule TYPE date;
DEFINE FIELD in_tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD ex_tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD company_in_tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD company_ex_tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD company_tax_amount ON payment_schedule TYPE decimal;
DEFINE FIELD nb_term ON payment_schedule TYPE int;
DEFINE FIELD payment_schedule_line_list ON payment_schedule TYPE array<record<payment_schedule_line>>;
DEFINE FIELD invoice_set ON payment_schedule TYPE array<record<invoice>>;
DEFINE FIELD type_select ON payment_schedule TYPE string;
DEFINE FIELD status_select ON payment_schedule TYPE int DEFAULT 1;
DEFINE FIELD irrecoverable_status_select ON payment_schedule TYPE int DEFAULT 0;
DEFINE FIELD management_object ON payment_schedule TYPE record<management_object>;
DEFINE FIELD creation_date ON payment_schedule TYPE date;
DEFINE FIELD created_by_user ON payment_schedule TYPE record<user>;
DEFINE FIELD validated_by_user ON payment_schedule TYPE record<user>;
DEFINE FIELD validated_date ON payment_schedule TYPE date;
DEFINE FIELD canceled_by_user ON payment_schedule TYPE record<user>;
DEFINE FIELD canceled_date ON payment_schedule TYPE date;
DEFINE FIELD closed_by_user ON payment_schedule TYPE record<user>;
DEFINE FIELD closed_date ON payment_schedule TYPE date;
DEFINE FIELD currency ON payment_schedule TYPE record<currency>;
DEFINE FIELD payment_condition ON payment_schedule TYPE record<payment_condition>;
DEFINE FIELD nbre_term ON payment_schedule TYPE int;
DEFINE FIELD created_at ON payment_schedule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_schedule TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_schedule TYPE int DEFAULT 0;

-- Lignes d'échéancier de paiement
DEFINE TABLE payment_schedule_line SCHEMAFULL;
DEFINE FIELD payment_schedule ON payment_schedule_line TYPE record<payment_schedule>;
DEFINE FIELD schedule_line_seq ON payment_schedule_line TYPE string;
DEFINE FIELD schedule_date ON payment_schedule_line TYPE date;
DEFINE FIELD estimated_payment_date ON payment_schedule_line TYPE date;
DEFINE FIELD in_tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD ex_tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_in_tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_ex_tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_tax_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD in_tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD ex_tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_in_tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_ex_tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_tax_amount_paid ON payment_schedule_line TYPE decimal;
DEFINE FIELD in_tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD ex_tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_in_tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_ex_tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD company_tax_amount_remaining ON payment_schedule_line TYPE decimal;
DEFINE FIELD status_select ON payment_schedule_line TYPE int DEFAULT 1;
DEFINE FIELD irrecoverable_status_select ON payment_schedule_line TYPE int DEFAULT 0;
DEFINE FIELD management_object ON payment_schedule_line TYPE record<management_object>;
DEFINE FIELD invoice_term_list ON payment_schedule_line TYPE array<record<invoice_term>>;
DEFINE FIELD direct_debit_amount ON payment_schedule_line TYPE decimal;
DEFINE FIELD bank_details ON payment_schedule_line TYPE record<bank_details>;
DEFINE FIELD reject_ok ON payment_schedule_line TYPE bool DEFAULT false;
DEFINE FIELD amount_rejected ON payment_schedule_line TYPE decimal;
DEFINE FIELD reject_date_time ON payment_schedule_line TYPE datetime;
DEFINE FIELD interbank_code_line ON payment_schedule_line TYPE record<interbank_code_line>;
DEFINE FIELD debit_number ON payment_schedule_line TYPE string;
DEFINE FIELD usher_passage_ok ON payment_schedule_line TYPE bool;
DEFINE FIELD from_reject ON payment_schedule_line TYPE bool DEFAULT false;
DEFINE FIELD name ON payment_schedule_line TYPE string;
DEFINE FIELD created_at ON payment_schedule_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_schedule_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_schedule_line TYPE int DEFAULT 0;

-- ================================================================================
-- SESSIONS DE PAIEMENT
-- ================================================================================

-- Sessions de paiement
DEFINE TABLE payment_session SCHEMAFULL;
DEFINE FIELD name ON payment_session TYPE string;
DEFINE FIELD payment_mode ON payment_session TYPE record<payment_mode>;
DEFINE FIELD bank_details ON payment_session TYPE record<bank_details>;
DEFINE FIELD company ON payment_session TYPE record<company>;
DEFINE FIELD partner_type_select ON payment_session TYPE int;
DEFINE FIELD sequence ON payment_session TYPE record<sequence>;
DEFINE FIELD currency ON payment_session TYPE record<currency>;
DEFINE FIELD session_date ON payment_session TYPE date;
DEFINE FIELD accounting_date ON payment_session TYPE date;
DEFINE FIELD journal ON payment_session TYPE record<journal>;
DEFINE FIELD account_management_ok ON payment_session TYPE bool DEFAULT false;
DEFINE FIELD validate_payment_move_line_list ON payment_session TYPE bool DEFAULT false;
DEFINE FIELD due_date_from ON payment_session TYPE date;
DEFINE FIELD due_date_to ON payment_session TYPE date;
DEFINE FIELD next_session_date ON payment_session TYPE date;
DEFINE FIELD status_select ON payment_session TYPE int DEFAULT 1;
DEFINE FIELD assignment_date ON payment_session TYPE date;
DEFINE FIELD generated_move_list ON payment_session TYPE array<record<move>>;
DEFINE FIELD invoice_term_list ON payment_session TYPE array<record<invoice_term>>;
DEFINE FIELD payment_move_line_distribution_list ON payment_session TYPE array<record<payment_move_line_distribution>>;
DEFINE FIELD email_sent_date_time ON payment_session TYPE datetime;
DEFINE FIELD sb_identifier ON payment_session TYPE string;
DEFINE FIELD has_error_anomaly ON payment_session TYPE bool DEFAULT false;
DEFINE FIELD has_warning_anomaly ON payment_session TYPE bool DEFAULT false;
DEFINE FIELD total_payment_session_amount ON payment_session TYPE decimal;
DEFINE FIELD session_total_amount ON payment_session TYPE decimal;
DEFINE FIELD partner_set ON payment_session TYPE array<record<partner>>;
DEFINE FIELD bank_order ON payment_session TYPE record<bank_order>;
DEFINE FIELD created_at ON payment_session TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_session TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_session TYPE int DEFAULT 0;

-- ================================================================================
-- BONS DE PAIEMENT
-- ================================================================================

-- Bons de paiement (Payment Voucher)
DEFINE TABLE payment_voucher SCHEMAFULL;
DEFINE FIELD ref ON payment_voucher TYPE string;
DEFINE FIELD company ON payment_voucher TYPE record<company>;
DEFINE FIELD partner ON payment_voucher TYPE record<partner>;
DEFINE FIELD payment_date ON payment_voucher TYPE date;
DEFINE FIELD payment_mode ON payment_voucher TYPE record<payment_mode>;
DEFINE FIELD currency ON payment_voucher TYPE record<currency>;
DEFINE FIELD currency_rate ON payment_voucher TYPE decimal;
DEFINE FIELD paid_amount ON payment_voucher TYPE decimal;
DEFINE FIELD company_currency ON payment_voucher TYPE record<currency>;
DEFINE FIELD company_paid_amount ON payment_voucher TYPE decimal;
DEFINE FIELD to_save_email_ok ON payment_voucher TYPE bool DEFAULT false;
DEFINE FIELD default_email_address ON payment_voucher TYPE record<email_address>;
DEFINE FIELD has_auto_input_ok ON payment_voucher TYPE bool DEFAULT false;
DEFINE FIELD receipt_ok ON payment_voucher TYPE bool DEFAULT false;
DEFINE FIELD move_line_to_pay_list ON payment_voucher TYPE array<record<pay_voucher_element_to_pay>>;
DEFINE FIELD pay_voucher_due_element_list ON payment_voucher TYPE array<record<pay_voucher_due_element>>;
DEFINE FIELD move_line_list ON payment_voucher TYPE array<record<move_line>>;
DEFINE FIELD generated_move ON payment_voucher TYPE record<move>;
DEFINE FIELD remaining_amount ON payment_voucher TYPE decimal;
DEFINE FIELD remaining_alarm_ok ON payment_voucher TYPE bool DEFAULT false;
DEFINE FIELD user ON payment_voucher TYPE record<user>;
DEFINE FIELD status_select ON payment_voucher TYPE int DEFAULT 1;
DEFINE FIELD trading_name ON payment_voucher TYPE record<trading_name>;
DEFINE FIELD bank_details ON payment_voucher TYPE record<bank_details>;
DEFINE FIELD cheque_date ON payment_voucher TYPE date;
DEFINE FIELD cheque_number ON payment_voucher TYPE string;
DEFINE FIELD cheque_owner ON payment_voucher TYPE string;
DEFINE FIELD cheque_bank ON payment_voucher TYPE record<bank>;
DEFINE FIELD deposit_slip ON payment_voucher TYPE record<deposit_slip>;
DEFINE FIELD created_at ON payment_voucher TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_voucher TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_voucher TYPE int DEFAULT 0;

-- Éléments dus du bon de paiement
DEFINE TABLE pay_voucher_due_element SCHEMAFULL;
DEFINE FIELD payment_voucher ON pay_voucher_due_element TYPE record<payment_voucher>;
DEFINE FIELD move_line ON pay_voucher_due_element TYPE record<move_line>;
DEFINE FIELD due_amount ON pay_voucher_due_element TYPE decimal;
DEFINE FIELD currency ON pay_voucher_due_element TYPE record<currency>;
DEFINE FIELD remaining_amount ON pay_voucher_due_element TYPE decimal;
DEFINE FIELD remaining_amount_after_finance_discount ON pay_voucher_due_element TYPE decimal;
DEFINE FIELD finance_amount ON pay_voucher_due_element TYPE decimal;
DEFINE FIELD total_amount ON pay_voucher_due_element TYPE decimal;
DEFINE FIELD applyFinanceDiscount ON pay_voucher_due_element TYPE bool;
DEFINE FIELD created_at ON pay_voucher_due_element TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON pay_voucher_due_element TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pay_voucher_due_element TYPE int DEFAULT 0;

-- Éléments à payer du bon de paiement
DEFINE TABLE pay_voucher_element_to_pay SCHEMAFULL;
DEFINE FIELD payment_voucher ON pay_voucher_element_to_pay TYPE record<payment_voucher>;
DEFINE FIELD move_line ON pay_voucher_element_to_pay TYPE record<move_line>;
DEFINE FIELD paid_amount ON pay_voucher_element_to_pay TYPE decimal;
DEFINE FIELD remaining_amount ON pay_voucher_element_to_pay TYPE decimal;
DEFINE FIELD total_amount ON pay_voucher_element_to_pay TYPE decimal;
DEFINE FIELD currency ON pay_voucher_element_to_pay TYPE record<currency>;
DEFINE FIELD to_pay_ok ON pay_voucher_element_to_pay TYPE bool DEFAULT false;
DEFINE FIELD created_at ON pay_voucher_element_to_pay TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON pay_voucher_element_to_pay TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pay_voucher_element_to_pay TYPE int DEFAULT 0;

-- ================================================================================
-- DISTRIBUTION DE PAIEMENT
-- ================================================================================

-- Distribution des lignes d'écriture de paiement
DEFINE TABLE payment_move_line_distribution SCHEMAFULL;
DEFINE FIELD payment_session ON payment_move_line_distribution TYPE record<payment_session>;
DEFINE FIELD move_line ON payment_move_line_distribution TYPE record<move_line>;
DEFINE FIELD invoice_term ON payment_move_line_distribution TYPE record<invoice_term>;
DEFINE FIELD amount_to_pay ON payment_move_line_distribution TYPE decimal;
DEFINE FIELD amount_to_pay_currency ON payment_move_line_distribution TYPE decimal;
DEFINE FIELD finance_discount_amount ON payment_move_line_distribution TYPE decimal;
DEFINE FIELD finance_discount_tax_amount ON payment_move_line_distribution TYPE decimal;
DEFINE FIELD finance_discount_total_amount ON payment_move_line_distribution TYPE decimal;
DEFINE FIELD to_pay_ok ON payment_move_line_distribution TYPE bool DEFAULT false;
DEFINE FIELD warning_ok ON payment_move_line_distribution TYPE bool DEFAULT false;
DEFINE FIELD created_at ON payment_move_line_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_move_line_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_move_line_distribution TYPE int DEFAULT 0;

-- ================================================================================
-- REMBOURSEMENTS
-- ================================================================================

-- Remboursements
DEFINE TABLE reimbursement SCHEMAFULL;
DEFINE FIELD ref ON reimbursement TYPE string;
DEFINE FIELD company ON reimbursement TYPE record<company>;
DEFINE FIELD partner ON reimbursement TYPE record<partner>;
DEFINE FIELD bank_details ON reimbursement TYPE record<bank_details>;
DEFINE FIELD amount_to_reimburse ON reimbursement TYPE decimal;
DEFINE FIELD amount_reimbursed ON reimbursement TYPE decimal;
DEFINE FIELD remaining_amount_to_reimburse ON reimbursement TYPE decimal;
DEFINE FIELD reimbursement_date ON reimbursement TYPE date;
DEFINE FIELD description ON reimbursement TYPE string;
DEFINE FIELD status_select ON reimbursement TYPE int DEFAULT 1;
DEFINE FIELD reimbursement_move_line_list ON reimbursement TYPE array<record<move_line>>;
DEFINE FIELD generated_move ON reimbursement TYPE record<move>;
DEFINE FIELD currency ON reimbursement TYPE record<currency>;
DEFINE FIELD company_currency ON reimbursement TYPE record<currency>;
DEFINE FIELD created_at ON reimbursement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON reimbursement TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON reimbursement TYPE int DEFAULT 0;

-- ================================================================================
-- BORDEREAUX DE REMISE
-- ================================================================================

-- Bordereaux de remise de chèques
DEFINE TABLE deposit_slip SCHEMAFULL;
DEFINE FIELD deposit_slip_number ON deposit_slip TYPE string;
DEFINE FIELD deposit_date ON deposit_slip TYPE date;
DEFINE FIELD bank_details ON deposit_slip TYPE record<bank_details>;
DEFINE FIELD company ON deposit_slip TYPE record<company>;
DEFINE FIELD currency ON deposit_slip TYPE record<currency>;
DEFINE FIELD total_amount ON deposit_slip TYPE decimal;
DEFINE FIELD invoice_payment_list ON deposit_slip TYPE array<record<invoice_payment>>;
DEFINE FIELD payment_voucher_list ON deposit_slip TYPE array<record<payment_voucher>>;
DEFINE FIELD cheque_rejection_list ON deposit_slip TYPE array<record<cheque_rejection>>;
DEFINE FIELD publication_date ON deposit_slip TYPE date;
DEFINE FIELD status_select ON deposit_slip TYPE int DEFAULT 1;
DEFINE FIELD created_at ON deposit_slip TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON deposit_slip TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON deposit_slip TYPE int DEFAULT 0;

-- ================================================================================
-- REJETS DE CHÈQUES
-- ================================================================================

-- Rejets de chèques
DEFINE TABLE cheque_rejection SCHEMAFULL;
DEFINE FIELD sequence ON cheque_rejection TYPE string;
DEFINE FIELD reject_date ON cheque_rejection TYPE date;
DEFINE FIELD name ON cheque_rejection TYPE string;
DEFINE FIELD amount ON cheque_rejection TYPE decimal;
DEFINE FIELD payment_voucher ON cheque_rejection TYPE record<payment_voucher>;
DEFINE FIELD invoice_payment ON cheque_rejection TYPE record<invoice_payment>;
DEFINE FIELD deposit_slip ON cheque_rejection TYPE record<deposit_slip>;
DEFINE FIELD interbank_code_line ON cheque_rejection TYPE record<interbank_code_line>;
DEFINE FIELD company ON cheque_rejection TYPE record<company>;
DEFINE FIELD created_at ON cheque_rejection TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON cheque_rejection TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON cheque_rejection TYPE int DEFAULT 0;

-- ================================================================================
-- CODES INTERBANCAIRES
-- ================================================================================

-- Codes interbancaires
DEFINE TABLE interbank_code SCHEMAFULL;
DEFINE FIELD code ON interbank_code TYPE string;
DEFINE FIELD label ON interbank_code TYPE string;
DEFINE FIELD interbank_code_line_list ON interbank_code TYPE array<record<interbank_code_line>>;
DEFINE FIELD created_at ON interbank_code TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON interbank_code TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON interbank_code TYPE int DEFAULT 0;

-- Lignes de codes interbancaires
DEFINE TABLE interbank_code_line SCHEMAFULL;
DEFINE FIELD interbank_code ON interbank_code_line TYPE record<interbank_code>;
DEFINE FIELD code ON interbank_code_line TYPE string;
DEFINE FIELD label ON interbank_code_line TYPE string;
DEFINE FIELD created_at ON interbank_code_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON interbank_code_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON interbank_code_line TYPE int DEFAULT 0;

-- ================================================================================
-- BILLETTERIE
-- ================================================================================

-- Billets à ordre
DEFINE TABLE note_bills SCHEMAFULL;
DEFINE FIELD company ON note_bills TYPE record<company>;
DEFINE FIELD partner ON note_bills TYPE record<partner>;
DEFINE FIELD bill_of_exchange_type_select ON note_bills TYPE int;
DEFINE FIELD status_select ON note_bills TYPE int DEFAULT 1;
DEFINE FIELD created_at ON note_bills TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON note_bills TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON note_bills TYPE int DEFAULT 0;

-- ================================================================================
-- UMR (UNIQUE MANDATE REFERENCE)
-- ================================================================================

-- Références de mandat unique
DEFINE TABLE umr SCHEMAFULL;
DEFINE FIELD partner ON umr TYPE record<partner>;
DEFINE FIELD bank_details ON umr TYPE record<bank_details>;
DEFINE FIELD umr_number ON umr TYPE string;
DEFINE FIELD mandate_signature_date ON umr TYPE date;
DEFINE FIELD status_select ON umr TYPE int DEFAULT 1;
DEFINE FIELD created_at ON umr TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON umr TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON umr TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION  
-- ================================================================================

-- Index pour PaymentSchedule
DEFINE INDEX idx_payment_schedule_id ON payment_schedule FIELDS schedule_id;
DEFINE INDEX idx_payment_schedule_company ON payment_schedule FIELDS company;
DEFINE INDEX idx_payment_schedule_partner ON payment_schedule FIELDS partner;
DEFINE INDEX idx_payment_schedule_status ON payment_schedule FIELDS status_select;

-- Index pour PaymentScheduleLine
DEFINE INDEX idx_payment_schedule_line_schedule ON payment_schedule_line FIELDS payment_schedule;
DEFINE INDEX idx_payment_schedule_line_date ON payment_schedule_line FIELDS schedule_date;
DEFINE INDEX idx_payment_schedule_line_status ON payment_schedule_line FIELDS status_select;

-- Index pour PaymentSession
DEFINE INDEX idx_payment_session_name ON payment_session FIELDS name;
DEFINE INDEX idx_payment_session_company ON payment_session FIELDS company;
DEFINE INDEX idx_payment_session_date ON payment_session FIELDS session_date;
DEFINE INDEX idx_payment_session_status ON payment_session FIELDS status_select;

-- Index pour PaymentVoucher
DEFINE INDEX idx_payment_voucher_ref ON payment_voucher FIELDS ref;
DEFINE INDEX idx_payment_voucher_company ON payment_voucher FIELDS company;
DEFINE INDEX idx_payment_voucher_partner ON payment_voucher FIELDS partner;
DEFINE INDEX idx_payment_voucher_date ON payment_voucher FIELDS payment_date;

-- Index pour DepositSlip
DEFINE INDEX idx_deposit_slip_number ON deposit_slip FIELDS deposit_slip_number;
DEFINE INDEX idx_deposit_slip_company ON deposit_slip FIELDS company;
DEFINE INDEX idx_deposit_slip_date ON deposit_slip FIELDS deposit_date;

-- ================================================================================
-- FIN DU MODULE 3 - PAIEMENTS
-- ================================================================================ 