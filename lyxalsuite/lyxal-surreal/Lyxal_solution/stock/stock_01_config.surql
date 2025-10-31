-- ================================================
-- MODULE AXELOR STOCK - CONFIGURATION ET EMPLACEMENTS
-- ================================================

-- Table app_stock
DEFINE TABLE app_stock SCHEMAFULL;
DEFINE FIELD id ON app_stock TYPE record<app_stock>;
DEFINE FIELD app ON app_stock TYPE string;
DEFINE FIELD is_enabled_product_description_copy ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD require_to_fill_conformity_on_receipt ON app_stock TYPE bool DEFAULT true;
DEFINE FIELD is_separate_shipment_operations ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD is_required_shipment_supplier_details ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD economic_area ON app_stock TYPE string;
DEFINE FIELD stock_unit ON app_stock TYPE string;
DEFINE FIELD activate_tracking_number_bar_code_generation ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD edit_tracking_number_barcode_type ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD tracking_number_barcode_type_config ON app_stock TYPE string;
DEFINE FIELD activate_stock_location_bar_code_generation ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD edit_stock_location_barcode_type ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD stock_location_barcode_type_config ON app_stock TYPE string;
DEFINE FIELD is_manage_stock_location_on_stock_move_line ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD is_incoterm_enabled ON app_stock TYPE bool DEFAULT true;
DEFINE FIELD is_mass_stock_move_managed ON app_stock TYPE bool DEFAULT false;
DEFINE FIELD created_on ON app_stock TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_stock TYPE datetime DEFAULT time::now();

-- Table stock_config
DEFINE TABLE stock_config SCHEMAFULL;
DEFINE FIELD id ON stock_config TYPE record<stock_config>;
DEFINE FIELD company ON stock_config TYPE string;
DEFINE FIELD receipt_default_stock_location ON stock_config TYPE string;
DEFINE FIELD pickup_default_stock_location ON stock_config TYPE string;
DEFINE FIELD quality_control_default_stock_location ON stock_config TYPE string;
DEFINE FIELD customer_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD supplier_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD inventory_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD virtual_outsourcing_stock_location ON stock_config TYPE string;
DEFINE FIELD outsourcing_receipt_stock_location ON stock_config TYPE string;
DEFINE FIELD customs_mass_unit ON stock_config TYPE string;
DEFINE FIELD realize_stock_moves_upon_parcel_pallet_collection ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD planned_stock_move_automatic_mail ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD real_stock_move_automatic_mail ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD planned_stock_move_message_template ON stock_config TYPE string;
DEFINE FIELD real_stock_move_message_template ON stock_config TYPE string;
DEFINE FIELD supplier_arrival_cancellation_automatic_mail ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD supplier_arrival_cancellation_message_template ON stock_config TYPE string;
DEFINE FIELD logistical_form_automatic_email ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD logistical_form_message_template ON stock_config TYPE string;
DEFINE FIELD conformity_certificate_title ON stock_config TYPE string;
DEFINE FIELD conformity_certificate_description ON stock_config TYPE string;
DEFINE FIELD signatory_user ON stock_config TYPE string;
DEFINE FIELD display_track_nbr_on_picking_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_barcode_on_picking_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_customer_code_on_picking_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_partner_seq_on_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_line_details_on_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD is_with_return_surplus ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_with_backorder ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD picking_order_printing_detailed ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD is_display_sale_value_in_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_accounting_value_in_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_ag_price_in_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD is_display_purchase_value_in_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD stock_valuation_type_select ON stock_config TYPE int DEFAULT 5;
DEFINE FIELD inventory_valuation_type_select ON stock_config TYPE int;
DEFINE FIELD display_track_nbr_on_certificate_of_conformity_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_ext_ref_on_certificate_of_conformity_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD stock_rule_message_template ON stock_config TYPE string;
DEFINE FIELD display_product_code_on_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_price_on_printing ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD display_order_reference_and_order_date ON stock_config TYPE bool DEFAULT true;
DEFINE FIELD percent_tolerance_for_wap_change ON stock_config TYPE int;
DEFINE FIELD picking_stock_move_print_template ON stock_config TYPE string;
DEFINE FIELD conformity_certificate_print_template ON stock_config TYPE string;
DEFINE FIELD inventory_print_template ON stock_config TYPE string;
DEFINE FIELD stock_location_print_template ON stock_config TYPE string;
DEFINE FIELD cart_stock_location ON stock_config TYPE string;
DEFINE FIELD created_on ON stock_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_config TYPE datetime DEFAULT time::now();

-- Table stock_location
DEFINE TABLE stock_location SCHEMAFULL;
DEFINE FIELD id ON stock_location TYPE record<stock_location>;
DEFINE FIELD name ON stock_location TYPE string;
DEFINE FIELD parent_stock_location ON stock_location TYPE string;
DEFINE FIELD company ON stock_location TYPE string;
DEFINE FIELD partner ON stock_location TYPE string;
DEFINE FIELD type_select ON stock_location TYPE int;
DEFINE FIELD address ON stock_location TYPE string;
DEFINE FIELD include_out_of_stock ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD stock_location_value ON stock_location TYPE float;
DEFINE FIELD trading_name ON stock_location TYPE string;
DEFINE FIELD include_virtual_sub_location ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD is_valued ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD bar_code ON stock_location TYPE string;
DEFINE FIELD serial_number ON stock_location TYPE string;
DEFINE FIELD barcode_type_config ON stock_location TYPE string;
DEFINE FIELD site ON stock_location TYPE string;
DEFINE FIELD created_on ON stock_location TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_location TYPE datetime DEFAULT time::now();

-- Table stock_location_line
DEFINE TABLE stock_location_line SCHEMAFULL;
DEFINE FIELD id ON stock_location_line TYPE record<stock_location_line>;
DEFINE FIELD stock_location ON stock_location_line TYPE string;
DEFINE FIELD product ON stock_location_line TYPE string;
DEFINE FIELD unit ON stock_location_line TYPE string;
DEFINE FIELD current_qty ON stock_location_line TYPE float;
DEFINE FIELD future_qty ON stock_location_line TYPE float;
DEFINE FIELD avg_price ON stock_location_line TYPE float;
DEFINE FIELD is_avg_price_changed ON stock_location_line TYPE bool DEFAULT false;
DEFINE FIELD last_future_stock_move_date ON stock_location_line TYPE date;
DEFINE FIELD rack ON stock_location_line TYPE string;
DEFINE FIELD tracking_number ON stock_location_line TYPE string;
DEFINE FIELD details_stock_location ON stock_location_line TYPE string;
DEFINE FIELD last_inventory_real_qty ON stock_location_line TYPE float;
DEFINE FIELD last_inventory_date_t ON stock_location_line TYPE datetime;
DEFINE FIELD created_on ON stock_location_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_location_line TYPE datetime DEFAULT time::now();

-- Table stock_location_line_history
DEFINE TABLE stock_location_line_history SCHEMAFULL;
DEFINE FIELD id ON stock_location_line_history TYPE record<stock_location_line_history>;
DEFINE FIELD stock_location_line ON stock_location_line_history TYPE string;
DEFINE FIELD date_t ON stock_location_line_history TYPE datetime;
DEFINE FIELD current_qty ON stock_location_line_history TYPE float;
DEFINE FIELD future_qty ON stock_location_line_history TYPE float;
DEFINE FIELD avg_price ON stock_location_line_history TYPE float;
DEFINE FIELD operation_type_select ON stock_location_line_history TYPE int;
DEFINE FIELD origin_type_select ON stock_location_line_history TYPE int;
DEFINE FIELD origin ON stock_location_line_history TYPE string;
DEFINE FIELD created_on ON stock_location_line_history TYPE datetime DEFAULT time::now();

-- Table stored_product
DEFINE TABLE stored_product SCHEMAFULL;
DEFINE FIELD id ON stored_product TYPE record<stored_product>;
DEFINE FIELD stock_location ON stored_product TYPE string;
DEFINE FIELD product ON stored_product TYPE string;
DEFINE FIELD unit ON stored_product TYPE string;
DEFINE FIELD current_qty ON stored_product TYPE float;
DEFINE FIELD future_qty ON stored_product TYPE float;
DEFINE FIELD avg_price ON stored_product TYPE float;
DEFINE FIELD last_stock_move_date ON stored_product TYPE date;
DEFINE FIELD reserved_qty ON stored_product TYPE float;
DEFINE FIELD allocated_qty ON stored_product TYPE float;
DEFINE FIELD requested_qty ON stored_product TYPE float;
DEFINE FIELD created_on ON stored_product TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stored_product TYPE datetime DEFAULT time::now();

-- Table company_stock (extension entreprises pour stock)
DEFINE TABLE company_stock SCHEMAFULL;
DEFINE FIELD id ON company_stock TYPE record<company_stock>;
DEFINE FIELD company_id ON company_stock TYPE record<company>;
-- Tous les champs communs sont maintenant dans la table company de base
DEFINE FIELD created_on ON company_stock TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_stock TYPE datetime DEFAULT time::now();

-- Table country (référence étendue)
DEFINE TABLE country SCHEMAFULL;
DEFINE FIELD id ON country TYPE record<country>;
DEFINE FIELD name ON country TYPE string;
DEFINE FIELD code ON country TYPE string;
DEFINE FIELD alpha_2_code ON country TYPE string;
DEFINE FIELD alpha_3_code ON country TYPE string;
DEFINE FIELD numeric_code ON country TYPE string;
DEFINE FIELD active ON country TYPE bool DEFAULT true;
DEFINE FIELD created_on ON country TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON country TYPE datetime DEFAULT time::now();

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

-- Table batch (référence étendue)
DEFINE TABLE batch SCHEMAFULL;
DEFINE FIELD id ON batch TYPE record<batch>;
DEFINE FIELD name ON batch TYPE string;
DEFINE FIELD code ON batch TYPE string;
DEFINE FIELD batch_type_select ON batch TYPE int;
DEFINE FIELD description ON batch TYPE string;
DEFINE FIELD status_select ON batch TYPE int;
DEFINE FIELD start_date ON batch TYPE datetime;
DEFINE FIELD end_date ON batch TYPE datetime;
DEFINE FIELD created_on ON batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON batch TYPE datetime DEFAULT time::now();

-- Table stock_batch
DEFINE TABLE stock_batch SCHEMAFULL;
DEFINE FIELD id ON stock_batch TYPE record<stock_batch>;
DEFINE FIELD name ON stock_batch TYPE string;
DEFINE FIELD code ON stock_batch TYPE string;
DEFINE FIELD batch_type_select ON stock_batch TYPE int;
DEFINE FIELD description ON stock_batch TYPE string;
DEFINE FIELD company ON stock_batch TYPE string;
DEFINE FIELD status_select ON stock_batch TYPE int DEFAULT 0;
DEFINE FIELD start_date ON stock_batch TYPE datetime;
DEFINE FIELD end_date ON stock_batch TYPE datetime;
DEFINE FIELD created_on ON stock_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_batch TYPE datetime DEFAULT time::now();

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

-- Table app_base (référence étendue)
DEFINE TABLE app_base SCHEMAFULL;
DEFINE FIELD id ON app_base TYPE record<app_base>;
DEFINE FIELD app ON app_base TYPE string;
DEFINE FIELD default_partner_locale ON app_base TYPE string;
DEFINE FIELD created_on ON app_base TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_base TYPE datetime DEFAULT time::now();

-- Table app (référence étendue)
DEFINE TABLE app SCHEMAFULL;
DEFINE FIELD id ON app TYPE record<app>;
DEFINE FIELD name ON app TYPE string;
DEFINE FIELD code ON app TYPE string;
DEFINE FIELD description ON app TYPE string;
DEFINE FIELD active ON app TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app TYPE int;
DEFINE FIELD version ON app TYPE string;
DEFINE FIELD created_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app TYPE datetime DEFAULT time::now();