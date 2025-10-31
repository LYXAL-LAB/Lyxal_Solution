-- ================================================
-- MODULE AXELOR SUPPLYCHAIN - STOCK AVANCÉ
-- ================================================

-- Table stock_move (mouvements de stock)
DEFINE TABLE stock_move SCHEMAFULL;
DEFINE FIELD id ON stock_move TYPE record<stock_move>;
DEFINE FIELD stock_move_seq ON stock_move TYPE string;
DEFINE FIELD name ON stock_move TYPE string;
DEFINE FIELD company ON stock_move TYPE string;
DEFINE FIELD partner ON stock_move TYPE string;
DEFINE FIELD from_stock_location ON stock_move TYPE string;
DEFINE FIELD to_stock_location ON stock_move TYPE string;
DEFINE FIELD planned_date ON stock_move TYPE date;
DEFINE FIELD estimated_date ON stock_move TYPE date;
DEFINE FIELD real_date ON stock_move TYPE date;
DEFINE FIELD type_select ON stock_move TYPE int;
DEFINE FIELD status_select ON stock_move TYPE int DEFAULT 1;
DEFINE FIELD conformity_select ON stock_move TYPE int DEFAULT 1;
DEFINE FIELD availability_request ON stock_move TYPE bool DEFAULT false;
DEFINE FIELD picking_is_editable ON stock_move TYPE bool DEFAULT false;
DEFINE FIELD sale_order ON stock_move TYPE string;
DEFINE FIELD purchase_order ON stock_move TYPE string;
DEFINE FIELD manufacturing_order ON stock_move TYPE string;
DEFINE FIELD inventory ON stock_move TYPE string;
DEFINE FIELD invoice ON stock_move TYPE string;
DEFINE FIELD origin_id ON stock_move TYPE string;
DEFINE FIELD origin_type_select ON stock_move TYPE string;
DEFINE FIELD trading_name ON stock_move TYPE string;
DEFINE FIELD note ON stock_move TYPE string;
DEFINE FIELD group_product_on_printing ON stock_move TYPE bool DEFAULT false;
DEFINE FIELD full_spread_over_products ON stock_move TYPE bool DEFAULT false;
DEFINE FIELD reverse_origin_stock_move ON stock_move TYPE string;
DEFINE FIELD shipment_mode ON stock_move TYPE string;
DEFINE FIELD freight_carrier_mode ON stock_move TYPE string;
DEFINE FIELD carrier_partner ON stock_move TYPE string;
DEFINE FIELD forwarder_partner ON stock_move TYPE string;
DEFINE FIELD created_on ON stock_move TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_move TYPE datetime DEFAULT time::now();

-- Table stock_move_line (lignes mouvements stock)
DEFINE TABLE stock_move_line SCHEMAFULL;
DEFINE FIELD id ON stock_move_line TYPE record<stock_move_line>;
DEFINE FIELD stock_move ON stock_move_line TYPE string;
DEFINE FIELD product ON stock_move_line TYPE string;
DEFINE FIELD product_name ON stock_move_line TYPE string;
DEFINE FIELD product_code ON stock_move_line TYPE string;
DEFINE FIELD unit ON stock_move_line TYPE string;
DEFINE FIELD qty ON stock_move_line TYPE float;
DEFINE FIELD real_qty ON stock_move_line TYPE float;
DEFINE FIELD reserved_qty ON stock_move_line TYPE float;
DEFINE FIELD requested_reserved_qty ON stock_move_line TYPE float;
DEFINE FIELD unit_price_untaxed ON stock_move_line TYPE float;
DEFINE FIELD unit_price_taxed ON stock_move_line TYPE float;
DEFINE FIELD conformity_select ON stock_move_line TYPE int DEFAULT 1;
DEFINE FIELD sale_order_line ON stock_move_line TYPE string;
DEFINE FIELD purchase_order_line ON stock_move_line TYPE string;
DEFINE FIELD manufacturing_order_line ON stock_move_line TYPE string;
DEFINE FIELD inventory_line ON stock_move_line TYPE string;
DEFINE FIELD invoice_line ON stock_move_line TYPE string;
DEFINE FIELD description ON stock_move_line TYPE string;
DEFINE FIELD locker_rack ON stock_move_line TYPE string;
DEFINE FIELD track_number ON stock_move_line TYPE string;
DEFINE FIELD warranty_expiry_date ON stock_move_line TYPE date;
DEFINE FIELD perishable_expiry_date ON stock_move_line TYPE date;
DEFINE FIELD counter ON stock_move_line TYPE int;
DEFINE FIELD from_stock_location ON stock_move_line TYPE string;
DEFINE FIELD to_stock_location ON stock_move_line TYPE string;
DEFINE FIELD created_on ON stock_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_move_line TYPE datetime DEFAULT time::now();

-- Table stock_location (emplacements stock)
DEFINE TABLE stock_location SCHEMAFULL;
DEFINE FIELD id ON stock_location TYPE record<stock_location>;
DEFINE FIELD name ON stock_location TYPE string;
DEFINE FIELD serial_number ON stock_location TYPE string;
DEFINE FIELD parent_stock_location ON stock_location TYPE string;
DEFINE FIELD company ON stock_location TYPE string;
DEFINE FIELD partner ON stock_location TYPE string;
DEFINE FIELD address ON stock_location TYPE string;
DEFINE FIELD type_select ON stock_location TYPE int;
DEFINE FIELD is_default ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD is_valued_stock ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD usage_select ON stock_location TYPE int;
DEFINE FIELD directional_location_select ON stock_location TYPE int;
DEFINE FIELD stock_valuation_type_select ON stock_location TYPE int;
DEFINE FIELD sequence ON stock_location TYPE int;
DEFINE FIELD is_notification_for_receipt ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD is_notification_for_shipment ON stock_location TYPE bool DEFAULT false;
DEFINE FIELD receipt_default_stock_location ON stock_location TYPE string;
DEFINE FIELD shipment_default_stock_location ON stock_location TYPE string;
DEFINE FIELD created_on ON stock_location TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_location TYPE datetime DEFAULT time::now();

-- Table stock_location_line (lignes emplacements)
DEFINE TABLE stock_location_line SCHEMAFULL;
DEFINE FIELD id ON stock_location_line TYPE record<stock_location_line>;
DEFINE FIELD stock_location ON stock_location_line TYPE string;
DEFINE FIELD product ON stock_location_line TYPE string;
DEFINE FIELD unit ON stock_location_line TYPE string;
DEFINE FIELD current_qty ON stock_location_line TYPE float;
DEFINE FIELD reserved_qty ON stock_location_line TYPE float;
DEFINE FIELD requested_reserved_qty ON stock_location_line TYPE float;
DEFINE FIELD future_qty ON stock_location_line TYPE float;
DEFINE FIELD avg_price ON stock_location_line TYPE float;
DEFINE FIELD last_future_stock_move_date ON stock_location_line TYPE date;
DEFINE FIELD details_stock_location_line_list ON stock_location_line TYPE string;
DEFINE FIELD rack ON stock_location_line TYPE string;
DEFINE FIELD track_number ON stock_location_line TYPE string;
DEFINE FIELD created_on ON stock_location_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_location_line TYPE datetime DEFAULT time::now();

-- Table inventory (inventaires)
DEFINE TABLE inventory SCHEMAFULL;
DEFINE FIELD id ON inventory TYPE record<inventory>;
DEFINE FIELD inventory_seq ON inventory TYPE string;
DEFINE FIELD company ON inventory TYPE string;
DEFINE FIELD stock_location ON inventory TYPE string;
DEFINE FIELD planned_start_date_t ON inventory TYPE datetime;
DEFINE FIELD planned_end_date_t ON inventory TYPE datetime;
DEFINE FIELD date_t ON inventory TYPE datetime;
DEFINE FIELD status_select ON inventory TYPE int DEFAULT 1;
DEFINE FIELD type_select ON inventory TYPE int DEFAULT 1;
DEFINE FIELD exclude_out_of_stock ON inventory TYPE bool DEFAULT false;
DEFINE FIELD include_obsolete_product ON inventory TYPE bool DEFAULT false;
DEFINE FIELD format_select ON inventory TYPE int DEFAULT 1;
DEFINE FIELD description ON inventory TYPE string;
DEFINE FIELD comments ON inventory TYPE string;
DEFINE FIELD validated_by ON inventory TYPE string;
DEFINE FIELD validated_on ON inventory TYPE datetime;
DEFINE FIELD created_on ON inventory TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON inventory TYPE datetime DEFAULT time::now();

-- Table inventory_line (lignes inventaire)
DEFINE TABLE inventory_line SCHEMAFULL;
DEFINE FIELD id ON inventory_line TYPE record<inventory_line>;
DEFINE FIELD inventory ON inventory_line TYPE string;
DEFINE FIELD product ON inventory_line TYPE string;
DEFINE FIELD product_name ON inventory_line TYPE string;
DEFINE FIELD product_code ON inventory_line TYPE string;
DEFINE FIELD unit ON inventory_line TYPE string;
DEFINE FIELD rack ON inventory_line TYPE string;
DEFINE FIELD track_number ON inventory_line TYPE string;
DEFINE FIELD current_qty ON inventory_line TYPE float;
DEFINE FIELD real_qty ON inventory_line TYPE float;
DEFINE FIELD difference ON inventory_line TYPE float;
DEFINE FIELD gap_value ON inventory_line TYPE float;
DEFINE FIELD description ON inventory_line TYPE string;
DEFINE FIELD last_inventory_date ON inventory_line TYPE date;
DEFINE FIELD created_on ON inventory_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON inventory_line TYPE datetime DEFAULT time::now();

-- Table stock_correction (corrections stock)
DEFINE TABLE stock_correction SCHEMAFULL;
DEFINE FIELD id ON stock_correction TYPE record<stock_correction>;
DEFINE FIELD stock_correction_seq ON stock_correction TYPE string;
DEFINE FIELD company ON stock_correction TYPE string;
DEFINE FIELD stock_location ON stock_correction TYPE string;
DEFINE FIELD correction_date ON stock_correction TYPE date;
DEFINE FIELD reason_select ON stock_correction TYPE int;
DEFINE FIELD status_select ON stock_correction TYPE int DEFAULT 1;
DEFINE FIELD description ON stock_correction TYPE string;
DEFINE FIELD comments ON stock_correction TYPE string;
DEFINE FIELD validated_by ON stock_correction TYPE string;
DEFINE FIELD validated_on ON stock_correction TYPE datetime;
DEFINE FIELD created_on ON stock_correction TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_correction TYPE datetime DEFAULT time::now();

-- Table stock_correction_line (lignes corrections)
DEFINE TABLE stock_correction_line SCHEMAFULL;
DEFINE FIELD id ON stock_correction_line TYPE record<stock_correction_line>;
DEFINE FIELD stock_correction ON stock_correction_line TYPE string;
DEFINE FIELD product ON stock_correction_line TYPE string;
DEFINE FIELD product_name ON stock_correction_line TYPE string;
DEFINE FIELD unit ON stock_correction_line TYPE string;
DEFINE FIELD base_qty ON stock_correction_line TYPE float;
DEFINE FIELD real_qty ON stock_correction_line TYPE float;
DEFINE FIELD qty_difference ON stock_correction_line TYPE float;
DEFINE FIELD base_value ON stock_correction_line TYPE float;
DEFINE FIELD real_value ON stock_correction_line TYPE float;
DEFINE FIELD value_difference ON stock_correction_line TYPE float;
DEFINE FIELD reason_select ON stock_correction_line TYPE int;
DEFINE FIELD description ON stock_correction_line TYPE string;
DEFINE FIELD created_on ON stock_correction_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_correction_line TYPE datetime DEFAULT time::now();

-- Table stock_history (historique stock)
DEFINE TABLE stock_history SCHEMAFULL;
DEFINE FIELD id ON stock_history TYPE record<stock_history>;
DEFINE FIELD company ON stock_history TYPE string;
DEFINE FIELD stock_location ON stock_history TYPE string;
DEFINE FIELD product ON stock_history TYPE string;
DEFINE FIELD date_t ON stock_history TYPE datetime;
DEFINE FIELD qty ON stock_history TYPE float;
DEFINE FIELD unit ON stock_history TYPE string;
DEFINE FIELD movement_type_select ON stock_history TYPE int;
DEFINE FIELD origin_type_select ON stock_history TYPE string;
DEFINE FIELD origin_id ON stock_history TYPE string;
DEFINE FIELD origin_name ON stock_history TYPE string;
DEFINE FIELD partner ON stock_history TYPE string;
DEFINE FIELD description ON stock_history TYPE string;
DEFINE FIELD created_on ON stock_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_history TYPE datetime DEFAULT time::now();

-- Table stock_rules (règles stock)
DEFINE TABLE stock_rules SCHEMAFULL;
DEFINE FIELD id ON stock_rules TYPE record<stock_rules>;
DEFINE FIELD name ON stock_rules TYPE string;
DEFINE FIELD company ON stock_rules TYPE string;
DEFINE FIELD stock_location ON stock_rules TYPE string;
DEFINE FIELD product ON stock_rules TYPE string;
DEFINE FIELD product_category ON stock_rules TYPE string;
DEFINE FIELD product_family ON stock_rules TYPE string;
DEFINE FIELD use_case_select ON stock_rules TYPE int;
DEFINE FIELD min_qty ON stock_rules TYPE float;
DEFINE FIELD max_qty ON stock_rules TYPE float;
DEFINE FIELD reorder_qty ON stock_rules TYPE float;
DEFINE FIELD optimal_qty ON stock_rules TYPE float;
DEFINE FIELD order_alert_select ON stock_rules TYPE int;
DEFINE FIELD alert_select ON stock_rules TYPE int;
DEFINE FIELD active ON stock_rules TYPE bool DEFAULT true;
DEFINE FIELD created_on ON stock_rules TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_rules TYPE datetime DEFAULT time::now();

-- Table stock_config (configuration stock)
DEFINE TABLE stock_config SCHEMAFULL;
DEFINE FIELD id ON stock_config TYPE record<stock_config>;
DEFINE FIELD company ON stock_config TYPE string;
DEFINE FIELD receipt_default_stock_location ON stock_config TYPE string;
DEFINE FIELD pickup_default_stock_location ON stock_config TYPE string;
DEFINE FIELD quality_control_default_stock_location ON stock_config TYPE string;
DEFINE FIELD customer_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD supplier_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD inventory_virtual_stock_location ON stock_config TYPE string;
DEFINE FIELD virtual_outside_stock_location ON stock_config TYPE string;
DEFINE FIELD is_realize_stock_move_upon_partial_invoice ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_accounting_move_on_stock_move ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_line_details_on_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_track_nbr_on_picking_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD is_display_partner_seq_on_printing ON stock_config TYPE bool DEFAULT false;
DEFINE FIELD created_on ON stock_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON stock_config TYPE datetime DEFAULT time::now();

-- Table logistical_form (formulaires logistiques)
DEFINE TABLE logistical_form SCHEMAFULL;
DEFINE FIELD id ON logistical_form TYPE record<logistical_form>;
DEFINE FIELD logistical_form_seq ON logistical_form TYPE string;
DEFINE FIELD company ON logistical_form TYPE string;
DEFINE FIELD stock_move ON logistical_form TYPE string;
DEFINE FIELD carrier_partner ON logistical_form TYPE string;
DEFINE FIELD forwarder_partner ON logistical_form TYPE string;
DEFINE FIELD delivery_address ON logistical_form TYPE string;
DEFINE FIELD delivery_date ON logistical_form TYPE date;
DEFINE FIELD type_select ON logistical_form TYPE int;
DEFINE FIELD status_select ON logistical_form TYPE int DEFAULT 1;
DEFINE FIELD dimension_wt ON logistical_form TYPE float;
DEFINE FIELD gross_mass ON logistical_form TYPE float;
DEFINE FIELD total_net_mass ON logistical_form TYPE float;
DEFINE FIELD total_volume ON logistical_form TYPE float;
DEFINE FIELD total_package_weight ON logistical_form TYPE float;
DEFINE FIELD delivery_condition ON logistical_form TYPE string;
DEFINE FIELD comments ON logistical_form TYPE string;
DEFINE FIELD created_on ON logistical_form TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON logistical_form TYPE datetime DEFAULT time::now();

-- Table logistical_form_line (lignes formulaires logistiques)
DEFINE TABLE logistical_form_line SCHEMAFULL;
DEFINE FIELD id ON logistical_form_line TYPE record<logistical_form_line>;
DEFINE FIELD logistical_form ON logistical_form_line TYPE string;
DEFINE FIELD stock_move_line ON logistical_form_line TYPE string;
DEFINE FIELD product ON logistical_form_line TYPE string;
DEFINE FIELD product_name ON logistical_form_line TYPE string;
DEFINE FIELD qty ON logistical_form_line TYPE float;
DEFINE FIELD unit ON logistical_form_line TYPE string;
DEFINE FIELD unit_mass ON logistical_form_line TYPE float;
DEFINE FIELD total_mass ON logistical_form_line TYPE float;
DEFINE FIELD unit_volume ON logistical_form_line TYPE float;
DEFINE FIELD total_volume ON logistical_form_line TYPE float;
DEFINE FIELD parcel_pallet_number ON logistical_form_line TYPE string;
DEFINE FIELD type_select ON logistical_form_line TYPE int;
DEFINE FIELD created_on ON logistical_form_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON logistical_form_line TYPE datetime DEFAULT time::now(); 