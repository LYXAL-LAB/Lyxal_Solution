-- ================================================
-- MODULE AXELOR SUPPLYCHAIN - COMPTABILITÉ INTÉGRÉE
-- ================================================

-- Table invoice (factures)
DEFINE TABLE invoice SCHEMAFULL;
DEFINE FIELD id ON invoice TYPE record<invoice>;
DEFINE FIELD invoice_id ON invoice TYPE string;
DEFINE FIELD company ON invoice TYPE string;
DEFINE FIELD partner ON invoice TYPE string;
DEFINE FIELD contact_partner ON invoice TYPE string;
DEFINE FIELD address ON invoice TYPE string;
DEFINE FIELD invoice_date ON invoice TYPE date;
DEFINE FIELD due_date ON invoice TYPE date;
DEFINE FIELD payment_condition ON invoice TYPE string;
DEFINE FIELD payment_mode ON invoice TYPE string;
DEFINE FIELD operation_type_select ON invoice TYPE int;
DEFINE FIELD operation_sub_type_select ON invoice TYPE int;
DEFINE FIELD status_select ON invoice TYPE int DEFAULT 1;
DEFINE FIELD currency ON invoice TYPE string;
DEFINE FIELD ex_tax_total ON invoice TYPE float;
DEFINE FIELD tax_total ON invoice TYPE float;
DEFINE FIELD in_tax_total ON invoice TYPE float;
DEFINE FIELD amount_paid ON invoice TYPE float;
DEFINE FIELD amount_remaining ON invoice TYPE float;
DEFINE FIELD sale_order ON invoice TYPE string;
DEFINE FIELD purchase_order ON invoice TYPE string;
DEFINE FIELD stock_move ON invoice TYPE string;
DEFINE FIELD origin_date ON invoice TYPE date;
DEFINE FIELD internal_reference ON invoice TYPE string;
DEFINE FIELD external_reference ON invoice TYPE string;
DEFINE FIELD note ON invoice TYPE string;
DEFINE FIELD specific_notes ON invoice TYPE string;
DEFINE FIELD payment_voucher ON invoice TYPE string;
DEFINE FIELD old_move ON invoice TYPE string;
DEFINE FIELD move ON invoice TYPE string;
DEFINE FIELD journal ON invoice TYPE string;
DEFINE FIELD account ON invoice TYPE string;
DEFINE FIELD partner_account ON invoice TYPE string;
DEFINE FIELD reject_move ON invoice TYPE string;
DEFINE FIELD double_up_indicator ON invoice TYPE bool DEFAULT false;
DEFINE FIELD interco ON invoice TYPE bool DEFAULT false;
DEFINE FIELD created_by_interco ON invoice TYPE bool DEFAULT false;
DEFINE FIELD validated_by_user ON invoice TYPE string;
DEFINE FIELD validated_date ON invoice TYPE datetime;
DEFINE FIELD ventilated_by_user ON invoice TYPE string;
DEFINE FIELD ventilated_date ON invoice TYPE datetime;
DEFINE FIELD created_on ON invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON invoice TYPE datetime DEFAULT time::now();

-- Table invoice_line (lignes factures)
DEFINE TABLE invoice_line SCHEMAFULL;
DEFINE FIELD id ON invoice_line TYPE record<invoice_line>;
DEFINE FIELD invoice ON invoice_line TYPE string;
DEFINE FIELD sequence ON invoice_line TYPE int;
DEFINE FIELD product ON invoice_line TYPE string;
DEFINE FIELD product_name ON invoice_line TYPE string;
DEFINE FIELD product_code ON invoice_line TYPE string;
DEFINE FIELD qty ON invoice_line TYPE float;
DEFINE FIELD unit ON invoice_line TYPE string;
DEFINE FIELD price ON invoice_line TYPE float;
DEFINE FIELD price_discounted ON invoice_line TYPE float;
DEFINE FIELD discount_amount ON invoice_line TYPE float;
DEFINE FIELD discount_type_select ON invoice_line TYPE int;
DEFINE FIELD ex_tax_total ON invoice_line TYPE float;
DEFINE FIELD in_tax_total ON invoice_line TYPE float;
DEFINE FIELD account ON invoice_line TYPE string;
DEFINE FIELD analytic_distribution_template ON invoice_line TYPE string;
DEFINE FIELD analytic_move_line_list ON invoice_line TYPE string;
DEFINE FIELD tax_line ON invoice_line TYPE string;
DEFINE FIELD tax_equiv ON invoice_line TYPE string;
DEFINE FIELD description ON invoice_line TYPE string;
DEFINE FIELD is_title_line ON invoice_line TYPE bool DEFAULT false;
DEFINE FIELD type_select ON invoice_line TYPE int DEFAULT 1;
DEFINE FIELD sale_order_line ON invoice_line TYPE string;
DEFINE FIELD purchase_order_line ON invoice_line TYPE string;
DEFINE FIELD stock_move_line ON invoice_line TYPE string;
DEFINE FIELD fixed_asset_category ON invoice_line TYPE string;
DEFINE FIELD asset ON invoice_line TYPE string;
DEFINE FIELD budget_distribution_sum_amount ON invoice_line TYPE float;
DEFINE FIELD created_on ON invoice_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON invoice_line TYPE datetime DEFAULT time::now();

-- Table invoice_line_tax (taxes lignes factures)
DEFINE TABLE invoice_line_tax SCHEMAFULL;
DEFINE FIELD id ON invoice_line_tax TYPE record<invoice_line_tax>;
DEFINE FIELD invoice_line ON invoice_line_tax TYPE string;
DEFINE FIELD tax_line ON invoice_line_tax TYPE string;
DEFINE FIELD reverse_charged ON invoice_line_tax TYPE bool DEFAULT false;
DEFINE FIELD created_on ON invoice_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON invoice_line_tax TYPE datetime DEFAULT time::now();

-- Table invoice_payment (paiements factures)
DEFINE TABLE invoice_payment SCHEMAFULL;
DEFINE FIELD id ON invoice_payment TYPE record<invoice_payment>;
DEFINE FIELD invoice ON invoice_payment TYPE string;
DEFINE FIELD move ON invoice_payment TYPE string;
DEFINE FIELD move_line ON invoice_payment TYPE string;
DEFINE FIELD payment_move ON invoice_payment TYPE string;
DEFINE FIELD payment_move_line ON invoice_payment TYPE string;
DEFINE FIELD amount ON invoice_payment TYPE float;
DEFINE FIELD type_select ON invoice_payment TYPE int;
DEFINE FIELD created_on ON invoice_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON invoice_payment TYPE datetime DEFAULT time::now();

-- Table payment_voucher (justificatifs paiement)
DEFINE TABLE payment_voucher SCHEMAFULL;
DEFINE FIELD id ON payment_voucher TYPE record<payment_voucher>;
DEFINE FIELD ref ON payment_voucher TYPE string;
DEFINE FIELD company ON payment_voucher TYPE string;
DEFINE FIELD partner ON payment_voucher TYPE string;
DEFINE FIELD payment_date ON payment_voucher TYPE date;
DEFINE FIELD payment_mode ON payment_voucher TYPE string;
DEFINE FIELD operation_type_select ON payment_voucher TYPE int;
DEFINE FIELD currency ON payment_voucher TYPE string;
DEFINE FIELD paid_amount ON payment_voucher TYPE float;
DEFINE FIELD to_pay_amount ON payment_voucher TYPE float;
DEFINE FIELD remaining_amount ON payment_voucher TYPE float;
DEFINE FIELD status_select ON payment_voucher TYPE int DEFAULT 1;
DEFINE FIELD move ON payment_voucher TYPE string;
DEFINE FIELD generated_move ON payment_voucher TYPE string;
DEFINE FIELD receipt_mode ON payment_voucher TYPE string;
DEFINE FIELD bank_details ON payment_voucher TYPE string;
DEFINE FIELD cash_register ON payment_voucher TYPE string;
DEFINE FIELD cheque_number ON payment_voucher TYPE string;
DEFINE FIELD cheque_date ON payment_voucher TYPE date;
DEFINE FIELD cheque_bank ON payment_voucher TYPE string;
DEFINE FIELD cheque_owner ON payment_voucher TYPE string;
DEFINE FIELD deposit_slip ON payment_voucher TYPE string;
DEFINE FIELD hide_to_pay_amount ON payment_voucher TYPE bool DEFAULT false;
DEFINE FIELD currency_amount ON payment_voucher TYPE float;
DEFINE FIELD currency_rate ON payment_voucher TYPE float;
DEFINE FIELD trading_name ON payment_voucher TYPE string;
DEFINE FIELD created_on ON payment_voucher TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON payment_voucher TYPE datetime DEFAULT time::now();

-- Table payment_voucher_line (lignes justificatifs)
DEFINE TABLE payment_voucher_line SCHEMAFULL;
DEFINE FIELD id ON payment_voucher_line TYPE record<payment_voucher_line>;
DEFINE FIELD payment_voucher ON payment_voucher_line TYPE string;
DEFINE FIELD move_line ON payment_voucher_line TYPE string;
DEFINE FIELD due_amount ON payment_voucher_line TYPE float;
DEFINE FIELD paid_amount ON payment_voucher_line TYPE float;
DEFINE FIELD remaining_amount ON payment_voucher_line TYPE float;
DEFINE FIELD total_amount ON payment_voucher_line TYPE float;
DEFINE FIELD rejection_ok ON payment_voucher_line TYPE bool DEFAULT false;
DEFINE FIELD created_on ON payment_voucher_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON payment_voucher_line TYPE datetime DEFAULT time::now();

-- Table interco_config (configuration inter-compagnies)
DEFINE TABLE interco_config SCHEMAFULL;
DEFINE FIELD id ON interco_config TYPE record<interco_config>;
DEFINE FIELD company ON interco_config TYPE string;
DEFINE FIELD interco_partner ON interco_config TYPE string;
DEFINE FIELD sale_journal ON interco_config TYPE string;
DEFINE FIELD purchase_journal ON interco_config TYPE string;
DEFINE FIELD sale_account ON interco_config TYPE string;
DEFINE FIELD purchase_account ON interco_config TYPE string;
DEFINE FIELD is_invoice_interco ON interco_config TYPE bool DEFAULT false;
DEFINE FIELD is_sale_order_interco ON interco_config TYPE bool DEFAULT false;
DEFINE FIELD is_purchase_order_interco ON interco_config TYPE bool DEFAULT false;
DEFINE FIELD created_on ON interco_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON interco_config TYPE datetime DEFAULT time::now();

-- Table budget_line (lignes budgétaires)
DEFINE TABLE budget_line SCHEMAFULL;
DEFINE FIELD id ON budget_line TYPE record<budget_line>;
DEFINE FIELD budget ON budget_line TYPE string;
DEFINE FIELD budget_line_seq ON budget_line TYPE string;
DEFINE FIELD analytic_account ON budget_line TYPE string;
DEFINE FIELD account ON budget_line TYPE string;
DEFINE FIELD budget_key ON budget_line TYPE string;
DEFINE FIELD company ON budget_line TYPE string;
DEFINE FIELD from_date ON budget_line TYPE date;
DEFINE FIELD to_date ON budget_line TYPE date;
DEFINE FIELD amount_expected ON budget_line TYPE float;
DEFINE FIELD amount_committed ON budget_line TYPE float;
DEFINE FIELD amount_realized ON budget_line TYPE float;
DEFINE FIELD amount_available ON budget_line TYPE float;
DEFINE FIELD comments ON budget_line TYPE string;
DEFINE FIELD created_on ON budget_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON budget_line TYPE datetime DEFAULT time::now();

-- Table budget_distribution (répartition budgétaire)
DEFINE TABLE budget_distribution SCHEMAFULL;
DEFINE FIELD id ON budget_distribution TYPE record<budget_distribution>;
DEFINE FIELD budget_line ON budget_distribution TYPE string;
DEFINE FIELD sale_order_line ON budget_distribution TYPE string;
DEFINE FIELD purchase_order_line ON budget_distribution TYPE string;
DEFINE FIELD invoice_line ON budget_distribution TYPE string;
DEFINE FIELD amount ON budget_distribution TYPE float;
DEFINE FIELD percentage ON budget_distribution TYPE float;
DEFINE FIELD created_on ON budget_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON budget_distribution TYPE datetime DEFAULT time::now();

-- Table accounting_config (configuration comptable)
DEFINE TABLE accounting_config SCHEMAFULL;
DEFINE FIELD id ON accounting_config TYPE record<accounting_config>;
DEFINE FIELD company ON accounting_config TYPE string;
DEFINE FIELD customer_sales_journal ON accounting_config TYPE string;
DEFINE FIELD customer_credit_note_journal ON accounting_config TYPE string;
DEFINE FIELD supplier_purchase_journal ON accounting_config TYPE string;
DEFINE FIELD supplier_credit_note_journal ON accounting_config TYPE string;
DEFINE FIELD customer_account ON accounting_config TYPE string;
DEFINE FIELD supplier_account ON accounting_config TYPE string;
DEFINE FIELD advance_payment_account ON accounting_config TYPE string;
DEFINE FIELD factor_debit_account ON accounting_config TYPE string;
DEFINE FIELD factor_credit_account ON accounting_config TYPE string;
DEFINE FIELD discount_account ON accounting_config TYPE string;
DEFINE FIELD doubtful_customer_account ON accounting_config TYPE string;
DEFINE FIELD cash_position_variation_account ON accounting_config TYPE string;
DEFINE FIELD reimbursement_account ON accounting_config TYPE string;
DEFINE FIELD exchange_gain_account ON accounting_config TYPE string;
DEFINE FIELD exchange_loss_account ON accounting_config TYPE string;
DEFINE FIELD automate_invoice_accounting ON accounting_config TYPE bool DEFAULT false;
DEFINE FIELD automate_payment_accounting ON accounting_config TYPE bool DEFAULT false;
DEFINE FIELD has_default_template ON accounting_config TYPE bool DEFAULT false;
DEFINE FIELD created_on ON accounting_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_config TYPE datetime DEFAULT time::now(); 