-- ================================================
-- MODULE AXELOR SUPPLYCHAIN - CONFIGURATION ET APPLICATIONS
-- ================================================

-- Table app_supplychain
DEFINE TABLE app_supplychain SCHEMAFULL;
DEFINE FIELD id ON app_supplychain TYPE record<app_supplychain>;
DEFINE FIELD app ON app_supplychain TYPE string;
DEFINE FIELD cust_stock_move_mgt_on_so ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD customer_stock_move_generation_auto ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD suppl_stock_move_mgt_on_po ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD supplier_stock_move_generation_auto ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD allow_susbcription_sale_order ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD check_sale_stocks ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD generate_invoice_from_stock_move ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD valid_step_for_inv_out_sm ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD terminate_sale_order_on_delivery ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD complete_sale_order_on_invoicing ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD terminate_purchase_order_on_receipt ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD allow_complete_manually_sale_order ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD purchase_order_generation_auto ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD allow_finish_manually_purchase_order ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD generate_invoice_from_sale_order ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD generate_invoice_from_purchase_order ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD allow_timetable_invoicing ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_from_purchase ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_from_sale ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_from_invoice ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_purchase_creating_status_select ON app_supplychain TYPE int;
DEFINE FIELD interco_sale_creating_status_select ON app_supplychain TYPE int;
DEFINE FIELD manage_stock_reservation ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD cancel_reason_on_changing_sale_order ON app_supplychain TYPE string;
DEFINE FIELD interco_sale_order_create_finalized ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_purchase_order_create_requested ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_invoice_create_validated ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD block_deallocation_on_availability_request ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD so_filter_on_stock_detail_status_select ON app_supplychain TYPE string DEFAULT "3";
DEFINE FIELD po_filter_on_stock_detail_status_select ON app_supplychain TYPE string DEFAULT "3";
DEFINE FIELD is_verify_product_stock ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD is_sale_order_without_outgoing_stock_move ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD is_purchase_order_without_incoming_stock_move ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD manage_advance_payments_from_payment_conditions ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD auto_fill_delivery_real_qty ON app_supplychain TYPE bool DEFAULT true;
DEFINE FIELD auto_fill_receipt_real_qty ON app_supplychain TYPE bool DEFAULT true;
DEFINE FIELD created_on ON app_supplychain TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_supplychain TYPE datetime DEFAULT time::now();

-- Table supply_chain_config
DEFINE TABLE supply_chain_config SCHEMAFULL;
DEFINE FIELD id ON supply_chain_config TYPE record<supply_chain_config>;
DEFINE FIELD company ON supply_chain_config TYPE string;
DEFINE FIELD has_out_sm_for_storable_product ON supply_chain_config TYPE bool DEFAULT true;
DEFINE FIELD has_out_sm_for_non_storable_product ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD has_in_sm_for_storable_product ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD has_in_sm_for_non_storable_product ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_allocate_on_receipt ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_allocate_on_allocation ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_request_reserved_qty ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_allocate_on_availability_request ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD sale_order_reservation_date_select ON supply_chain_config TYPE int DEFAULT 0;
DEFINE FIELD default_estimated_date ON supply_chain_config TYPE int DEFAULT 1;
DEFINE FIELD number_of_days ON supply_chain_config TYPE float DEFAULT 0;
DEFINE FIELD default_estimated_date_for_purchase_order ON supply_chain_config TYPE int DEFAULT 1;
DEFINE FIELD number_of_days_for_purchase_order ON supply_chain_config TYPE float DEFAULT 0;
DEFINE FIELD activate_inc_stock_move_partial_invoicing ON supply_chain_config TYPE bool DEFAULT true;
DEFINE FIELD activate_out_stock_move_partial_invoicing ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD declaration_of_exch_goods_print_template ON supply_chain_config TYPE string;
DEFINE FIELD declaration_of_exch_services_print_template ON supply_chain_config TYPE string;
DEFINE FIELD created_on ON supply_chain_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON supply_chain_config TYPE datetime DEFAULT time::now();

-- Table app (référence étendue)
DEFINE TABLE app SCHEMAFULL;
DEFINE FIELD id ON app TYPE record<app>;
DEFINE FIELD name ON app TYPE string;
DEFINE FIELD code ON app TYPE string;
DEFINE FIELD description ON app TYPE string;
DEFINE FIELD active ON app TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app TYPE int;
DEFINE FIELD version ON app TYPE string;
DEFINE FIELD depends_on ON app TYPE string;
DEFINE FIELD created_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app TYPE datetime DEFAULT time::now();

-- Table company_supplychain (extension entreprises pour supplychain)
DEFINE TABLE company_supplychain SCHEMAFULL;
DEFINE FIELD id ON company_supplychain TYPE record<company_supplychain>;
DEFINE FIELD company_id ON company_supplychain TYPE record<company>;
DEFINE FIELD created_on ON company_supplychain TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_supplychain TYPE datetime DEFAULT time::now();

-- Table user (référence étendue)
DEFINE TABLE user SCHEMAFULL;
DEFINE FIELD id ON user TYPE record<user>;
DEFINE FIELD name ON user TYPE string;
DEFINE FIELD code ON user TYPE string;
DEFINE FIELD email ON user TYPE string;
DEFINE FIELD login ON user TYPE string;
DEFINE FIELD password ON user TYPE string;
DEFINE FIELD active ON user TYPE bool DEFAULT true;
DEFINE FIELD language ON user TYPE string;
DEFINE FIELD group_user ON user TYPE string;
DEFINE FIELD home_action ON user TYPE string;
DEFINE FIELD single_tab ON user TYPE bool DEFAULT false;
DEFINE FIELD created_on ON user TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON user TYPE datetime DEFAULT time::now();

-- Table partner_link_type
DEFINE TABLE partner_link_type SCHEMAFULL;
DEFINE FIELD id ON partner_link_type TYPE record<partner_link_type>;
DEFINE FIELD name ON partner_link_type TYPE string;
DEFINE FIELD code ON partner_link_type TYPE string;
DEFINE FIELD description ON partner_link_type TYPE string;
DEFINE FIELD is_interco ON partner_link_type TYPE bool DEFAULT false;
DEFINE FIELD is_customer ON partner_link_type TYPE bool DEFAULT false;
DEFINE FIELD is_supplier ON partner_link_type TYPE bool DEFAULT false;
DEFINE FIELD active ON partner_link_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON partner_link_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON partner_link_type TYPE datetime DEFAULT time::now();

-- Table cancel_reason
DEFINE TABLE cancel_reason SCHEMAFULL;
DEFINE FIELD id ON cancel_reason TYPE record<cancel_reason>;
DEFINE FIELD name ON cancel_reason TYPE string;
DEFINE FIELD code ON cancel_reason TYPE string;
DEFINE FIELD description ON cancel_reason TYPE string;
DEFINE FIELD reason_type_select ON cancel_reason TYPE int;
DEFINE FIELD application_scope ON cancel_reason TYPE string;
DEFINE FIELD active ON cancel_reason TYPE bool DEFAULT true;
DEFINE FIELD created_on ON cancel_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON cancel_reason TYPE datetime DEFAULT time::now();

-- Table sequence (référence étendue)
DEFINE TABLE sequence SCHEMAFULL;
DEFINE FIELD id ON sequence TYPE record<sequence>;
DEFINE FIELD name ON sequence TYPE string;
DEFINE FIELD code ON sequence TYPE string;
DEFINE FIELD prefix ON sequence TYPE string;
DEFINE FIELD suffix ON sequence TYPE string;
DEFINE FIELD padding ON sequence TYPE int DEFAULT 1;
DEFINE FIELD next_num ON sequence TYPE int DEFAULT 1;
DEFINE FIELD increment ON sequence TYPE int DEFAULT 1;
DEFINE FIELD active ON sequence TYPE bool DEFAULT true;
DEFINE FIELD company ON sequence TYPE string;
DEFINE FIELD created_on ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sequence TYPE datetime DEFAULT time::now();

-- Table meta_schedule
DEFINE TABLE meta_schedule SCHEMAFULL;
DEFINE FIELD id ON meta_schedule TYPE record<meta_schedule>;
DEFINE FIELD name ON meta_schedule TYPE string;
DEFINE FIELD code ON meta_schedule TYPE string;
DEFINE FIELD description ON meta_schedule TYPE string;
DEFINE FIELD cron_expression ON meta_schedule TYPE string;
DEFINE FIELD active ON meta_schedule TYPE bool DEFAULT true;
DEFINE FIELD created_on ON meta_schedule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON meta_schedule TYPE datetime DEFAULT time::now();

-- Table exception_origin
DEFINE TABLE exception_origin SCHEMAFULL;
DEFINE FIELD id ON exception_origin TYPE record<exception_origin>;
DEFINE FIELD name ON exception_origin TYPE string;
DEFINE FIELD code ON exception_origin TYPE string;
DEFINE FIELD description ON exception_origin TYPE string;
DEFINE FIELD exception_type_select ON exception_origin TYPE int;
DEFINE FIELD active ON exception_origin TYPE bool DEFAULT true;
DEFINE FIELD created_on ON exception_origin TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON exception_origin TYPE datetime DEFAULT time::now();

-- Table tax_number
DEFINE TABLE tax_number SCHEMAFULL;
DEFINE FIELD id ON tax_number TYPE record<tax_number>;
DEFINE FIELD name ON tax_number TYPE string;
DEFINE FIELD code ON tax_number TYPE string;
DEFINE FIELD tax_type_select ON tax_number TYPE int;
DEFINE FIELD value ON tax_number TYPE float;
DEFINE FIELD active ON tax_number TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_number TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_number TYPE datetime DEFAULT time::now();

-- Table purchase_request
DEFINE TABLE purchase_request SCHEMAFULL;
DEFINE FIELD id ON purchase_request TYPE record<purchase_request>;
DEFINE FIELD purchase_request_seq ON purchase_request TYPE string;
DEFINE FIELD request_date ON purchase_request TYPE date;
DEFINE FIELD requester ON purchase_request TYPE string;
DEFINE FIELD department ON purchase_request TYPE string;
DEFINE FIELD company ON purchase_request TYPE string;
DEFINE FIELD status_select ON purchase_request TYPE int DEFAULT 1;
DEFINE FIELD description ON purchase_request TYPE string;
DEFINE FIELD total_amount ON purchase_request TYPE float;
DEFINE FIELD currency ON purchase_request TYPE string;
DEFINE FIELD approved_by ON purchase_request TYPE string;
DEFINE FIELD approved_on ON purchase_request TYPE datetime;
DEFINE FIELD created_on ON purchase_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_request TYPE datetime DEFAULT time::now();

-- Table declaration_of_exchanges
DEFINE TABLE declaration_of_exchanges SCHEMAFULL;
DEFINE FIELD id ON declaration_of_exchanges TYPE record<declaration_of_exchanges>;
DEFINE FIELD name ON declaration_of_exchanges TYPE string;
DEFINE FIELD code ON declaration_of_exchanges TYPE string;
DEFINE FIELD period_start_date ON declaration_of_exchanges TYPE date;
DEFINE FIELD period_end_date ON declaration_of_exchanges TYPE date;
DEFINE FIELD company ON declaration_of_exchanges TYPE string;
DEFINE FIELD status_select ON declaration_of_exchanges TYPE int DEFAULT 1;
DEFINE FIELD total_goods_amount ON declaration_of_exchanges TYPE float;
DEFINE FIELD total_services_amount ON declaration_of_exchanges TYPE float;
DEFINE FIELD created_on ON declaration_of_exchanges TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON declaration_of_exchanges TYPE datetime DEFAULT time::now();