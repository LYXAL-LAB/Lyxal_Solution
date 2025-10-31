-- ================================================
-- MODULE AXELOR STOCK - LOGISTIQUE ET TRAÇABILITÉ
-- ================================================

-- Table logistical_form
DEFINE TABLE logistical_form SCHEMAFULL;
DEFINE FIELD id ON logistical_form TYPE record<logistical_form>;
DEFINE FIELD delivery_number_seq ON logistical_form TYPE string;
DEFINE FIELD company ON logistical_form TYPE string;
DEFINE FIELD stock_location ON logistical_form TYPE string;
DEFINE FIELD deliver_to_customer_partner ON logistical_form TYPE string;
DEFINE FIELD collection_date ON logistical_form TYPE date;
DEFINE FIELD carrier_partner ON logistical_form TYPE string;
DEFINE FIELD forwarder_partner ON logistical_form TYPE string;
DEFINE FIELD incoterm ON logistical_form TYPE string;
DEFINE FIELD tracking ON logistical_form TYPE string;
DEFINE FIELD total_gross_mass ON logistical_form TYPE float;
DEFINE FIELD total_net_mass ON logistical_form TYPE float;
DEFINE FIELD total_volume ON logistical_form TYPE float;
DEFINE FIELD status_select ON logistical_form TYPE int DEFAULT 1;
DEFINE FIELD internal_delivery_comment ON logistical_form TYPE string;
DEFINE FIELD external_delivery_comment ON logistical_form TYPE string;
DEFINE FIELD account_selection_to_carrier_select ON logistical_form TYPE int DEFAULT 1;
DEFINE FIELD customer_account_number_to_carrier ON logistical_form TYPE string;
DEFINE FIELD is_email_sent ON logistical_form TYPE bool DEFAULT false;
DEFINE FIELD created_on ON logistical_form TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON logistical_form TYPE datetime DEFAULT time::now();

-- Table logistical_form_line
DEFINE TABLE logistical_form_line SCHEMAFULL;
DEFINE FIELD id ON logistical_form_line TYPE record<logistical_form_line>;
DEFINE FIELD logistical_form ON logistical_form_line TYPE string;
DEFINE FIELD stock_move_line ON logistical_form_line TYPE string;
DEFINE FIELD product ON logistical_form_line TYPE string;
DEFINE FIELD product_name ON logistical_form_line TYPE string;
DEFINE FIELD unit ON logistical_form_line TYPE string;
DEFINE FIELD qty ON logistical_form_line TYPE float;
DEFINE FIELD unit_price ON logistical_form_line TYPE float;
DEFINE FIELD total_price ON logistical_form_line TYPE float;
DEFINE FIELD type_select ON logistical_form_line TYPE int;
DEFINE FIELD line_weight ON logistical_form_line TYPE float;
DEFINE FIELD line_volume ON logistical_form_line TYPE float;
DEFINE FIELD comments ON logistical_form_line TYPE string;
DEFINE FIELD created_on ON logistical_form_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON logistical_form_line TYPE datetime DEFAULT time::now();

-- Table tracking_number
DEFINE TABLE tracking_number SCHEMAFULL;
DEFINE FIELD id ON tracking_number TYPE record<tracking_number>;
DEFINE FIELD product ON tracking_number TYPE string;
DEFINE FIELD has_warranty ON tracking_number TYPE bool DEFAULT false;
DEFINE FIELD warranty_expiration_date ON tracking_number TYPE date;
DEFINE FIELD is_perishable ON tracking_number TYPE bool DEFAULT false;
DEFINE FIELD perishable_expiration_date ON tracking_number TYPE date;
DEFINE FIELD check_expiration_date_at_stock_move_realization ON tracking_number TYPE bool DEFAULT false;
DEFINE FIELD tracking_number_seq ON tracking_number TYPE string;
DEFINE FIELD origin ON tracking_number TYPE string;
DEFINE FIELD supplier ON tracking_number TYPE string;
DEFINE FIELD note ON tracking_number TYPE string;
DEFINE FIELD bar_code ON tracking_number TYPE string;
DEFINE FIELD serial_number ON tracking_number TYPE string;
DEFINE FIELD barcode_type_config ON tracking_number TYPE string;
DEFINE FIELD origin_move_type_select ON tracking_number TYPE int DEFAULT 0;
DEFINE FIELD origin_stock_move_line ON tracking_number TYPE string;
DEFINE FIELD origin_inventory_line ON tracking_number TYPE string;
DEFINE FIELD dimension_0 ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD dimension_1 ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD dimension_2 ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD dimension_3 ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD mass ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD volume ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD unit_mass ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD metric_mass ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD nbr_of_pieces ON tracking_number TYPE float DEFAULT 0;
DEFINE FIELD created_on ON tracking_number TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tracking_number TYPE datetime DEFAULT time::now();

-- Table tracking_number_configuration
DEFINE TABLE tracking_number_configuration SCHEMAFULL;
DEFINE FIELD id ON tracking_number_configuration TYPE record<tracking_number_configuration>;
DEFINE FIELD name ON tracking_number_configuration TYPE string;
DEFINE FIELD sequence ON tracking_number_configuration TYPE string;
DEFINE FIELD product_family ON tracking_number_configuration TYPE string;
DEFINE FIELD product_category ON tracking_number_configuration TYPE string;
DEFINE FIELD product ON tracking_number_configuration TYPE string;
DEFINE FIELD company ON tracking_number_configuration TYPE string;
DEFINE FIELD is_percentage_creation ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD percentage_creation ON tracking_number_configuration TYPE float DEFAULT 0;
DEFINE FIELD is_generate_product_tracking_number ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD is_generate_autotracking_number_on_receipt ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD is_generate_autotracking_number_on_production ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD purchase_autotracking_number_length ON tracking_number_configuration TYPE int DEFAULT 0;
DEFINE FIELD sale_autotracking_number_length ON tracking_number_configuration TYPE int DEFAULT 0;
DEFINE FIELD production_autotracking_number_length ON tracking_number_configuration TYPE int DEFAULT 0;
DEFINE FIELD use_tracking_number_configuration_on_receipt ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD use_tracking_number_configuration_on_production ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD has_warranty ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD warranty_nbr_of_months ON tracking_number_configuration TYPE int DEFAULT 0;
DEFINE FIELD is_perishable ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD perishable_nbr_of_months ON tracking_number_configuration TYPE int DEFAULT 0;
DEFINE FIELD check_expiration_date_at_stock_move_realization ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD has_no_tracking_number ON tracking_number_configuration TYPE bool DEFAULT false;
DEFINE FIELD created_on ON tracking_number_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tracking_number_configuration TYPE datetime DEFAULT time::now();

-- Table tracking_number_configuration_profile
DEFINE TABLE tracking_number_configuration_profile SCHEMAFULL;
DEFINE FIELD id ON tracking_number_configuration_profile TYPE record<tracking_number_configuration_profile>;
DEFINE FIELD name ON tracking_number_configuration_profile TYPE string;
DEFINE FIELD formula ON tracking_number_configuration_profile TYPE string;
DEFINE FIELD has_product_tracking_number ON tracking_number_configuration_profile TYPE bool DEFAULT false;
DEFINE FIELD has_receipt_tracking_number ON tracking_number_configuration_profile TYPE bool DEFAULT false;
DEFINE FIELD has_production_tracking_number ON tracking_number_configuration_profile TYPE bool DEFAULT false;
DEFINE FIELD product_tracking_number_length ON tracking_number_configuration_profile TYPE int DEFAULT 0;
DEFINE FIELD receipt_tracking_number_length ON tracking_number_configuration_profile TYPE int DEFAULT 0;
DEFINE FIELD production_tracking_number_length ON tracking_number_configuration_profile TYPE int DEFAULT 0;
DEFINE FIELD created_on ON tracking_number_configuration_profile TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tracking_number_configuration_profile TYPE datetime DEFAULT time::now();

-- Table tracking_number_configuration_profile_field_formula
DEFINE TABLE tracking_number_configuration_profile_field_formula SCHEMAFULL;
DEFINE FIELD id ON tracking_number_configuration_profile_field_formula TYPE record<tracking_number_configuration_profile_field_formula>;
DEFINE FIELD tracking_number_configuration_profile ON tracking_number_configuration_profile_field_formula TYPE string;
DEFINE FIELD field_name ON tracking_number_configuration_profile_field_formula TYPE string;
DEFINE FIELD formula ON tracking_number_configuration_profile_field_formula TYPE string;
DEFINE FIELD sequence ON tracking_number_configuration_profile_field_formula TYPE int;
DEFINE FIELD created_on ON tracking_number_configuration_profile_field_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tracking_number_configuration_profile_field_formula TYPE datetime DEFAULT time::now();

-- Table shipment_mode
DEFINE TABLE shipment_mode SCHEMAFULL;
DEFINE FIELD id ON shipment_mode TYPE record<shipment_mode>;
DEFINE FIELD name ON shipment_mode TYPE string;
DEFINE FIELD code ON shipment_mode TYPE string;
DEFINE FIELD description ON shipment_mode TYPE string;
DEFINE FIELD active ON shipment_mode TYPE bool DEFAULT true;
DEFINE FIELD created_on ON shipment_mode TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON shipment_mode TYPE datetime DEFAULT time::now();

-- Table freight_carrier_mode
DEFINE TABLE freight_carrier_mode SCHEMAFULL;
DEFINE FIELD id ON freight_carrier_mode TYPE record<freight_carrier_mode>;
DEFINE FIELD name ON freight_carrier_mode TYPE string;
DEFINE FIELD code ON freight_carrier_mode TYPE string;
DEFINE FIELD carrier_partner ON freight_carrier_mode TYPE string;
DEFINE FIELD description ON freight_carrier_mode TYPE string;
DEFINE FIELD active ON freight_carrier_mode TYPE bool DEFAULT true;
DEFINE FIELD created_on ON freight_carrier_mode TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON freight_carrier_mode TYPE datetime DEFAULT time::now();

-- Table freight_carrier_customer_account_number
DEFINE TABLE freight_carrier_customer_account_number SCHEMAFULL;
DEFINE FIELD id ON freight_carrier_customer_account_number TYPE record<freight_carrier_customer_account_number>;
DEFINE FIELD stock_config ON freight_carrier_customer_account_number TYPE string;
DEFINE FIELD freight_carrier_mode ON freight_carrier_customer_account_number TYPE string;
DEFINE FIELD customer_account_number ON freight_carrier_customer_account_number TYPE string;
DEFINE FIELD created_on ON freight_carrier_customer_account_number TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON freight_carrier_customer_account_number TYPE datetime DEFAULT time::now();

-- Table incoterm
DEFINE TABLE incoterm SCHEMAFULL;
DEFINE FIELD id ON incoterm TYPE record<incoterm>;
DEFINE FIELD name ON incoterm TYPE string;
DEFINE FIELD code ON incoterm TYPE string;
DEFINE FIELD description ON incoterm TYPE string;
DEFINE FIELD is_risk_transfer_on_delivery ON incoterm TYPE bool DEFAULT false;
DEFINE FIELD is_cost_transfer_on_delivery ON incoterm TYPE bool DEFAULT false;
DEFINE FIELD is_location_required ON incoterm TYPE bool DEFAULT false;
DEFINE FIELD active ON incoterm TYPE bool DEFAULT true;
DEFINE FIELD created_on ON incoterm TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON incoterm TYPE datetime DEFAULT time::now();

-- Table trading_name
DEFINE TABLE trading_name SCHEMAFULL;
DEFINE FIELD id ON trading_name TYPE record<trading_name>;
DEFINE FIELD name ON trading_name TYPE string;
DEFINE FIELD code ON trading_name TYPE string;
DEFINE FIELD partner ON trading_name TYPE string;
DEFINE FIELD address ON trading_name TYPE string;
DEFINE FIELD email ON trading_name TYPE string;
DEFINE FIELD phone ON trading_name TYPE string;
DEFINE FIELD logo ON trading_name TYPE string;
DEFINE FIELD active ON trading_name TYPE bool DEFAULT true;
DEFINE FIELD created_on ON trading_name TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON trading_name TYPE datetime DEFAULT time::now();

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

-- Table customs_code_nomenclature
DEFINE TABLE customs_code_nomenclature SCHEMAFULL;
DEFINE FIELD id ON customs_code_nomenclature TYPE record<customs_code_nomenclature>;
DEFINE FIELD name ON customs_code_nomenclature TYPE string;
DEFINE FIELD code ON customs_code_nomenclature TYPE string;
DEFINE FIELD description ON customs_code_nomenclature TYPE string;
DEFINE FIELD customs_code ON customs_code_nomenclature TYPE string;
DEFINE FIELD country ON customs_code_nomenclature TYPE string;
DEFINE FIELD active ON customs_code_nomenclature TYPE bool DEFAULT true;
DEFINE FIELD created_on ON customs_code_nomenclature TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON customs_code_nomenclature TYPE datetime DEFAULT time::now();

-- Table abc_analysis
DEFINE TABLE abc_analysis SCHEMAFULL;
DEFINE FIELD id ON abc_analysis TYPE record<abc_analysis>;
DEFINE FIELD name ON abc_analysis TYPE string;
DEFINE FIELD code ON abc_analysis TYPE string;
DEFINE FIELD product ON abc_analysis TYPE string;
DEFINE FIELD company ON abc_analysis TYPE string;
DEFINE FIELD stock_location ON abc_analysis TYPE string;
DEFINE FIELD category ON abc_analysis TYPE string;
DEFINE FIELD qty_consumed ON abc_analysis TYPE float;
DEFINE FIELD value_consumed ON abc_analysis TYPE float;
DEFINE FIELD percentage_qty ON abc_analysis TYPE float;
DEFINE FIELD percentage_value ON abc_analysis TYPE float;
DEFINE FIELD analysis_period ON abc_analysis TYPE string;
DEFINE FIELD created_on ON abc_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON abc_analysis TYPE datetime DEFAULT time::now();

-- Table partner_product_quality_rating
DEFINE TABLE partner_product_quality_rating SCHEMAFULL;
DEFINE FIELD id ON partner_product_quality_rating TYPE record<partner_product_quality_rating>;
DEFINE FIELD partner ON partner_product_quality_rating TYPE string;
DEFINE FIELD product ON partner_product_quality_rating TYPE string;
DEFINE FIELD quality_rating ON partner_product_quality_rating TYPE float;
DEFINE FIELD rating_date ON partner_product_quality_rating TYPE date;
DEFINE FIELD comments ON partner_product_quality_rating TYPE string;
DEFINE FIELD created_on ON partner_product_quality_rating TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON partner_product_quality_rating TYPE datetime DEFAULT time::now();