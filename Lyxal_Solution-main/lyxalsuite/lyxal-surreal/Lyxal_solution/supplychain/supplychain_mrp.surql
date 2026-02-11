-- ================================================
-- MODULE AXELOR SUPPLYCHAIN - MRP (MATERIAL REQUIREMENTS PLANNING)
-- ================================================

-- Table mrp
DEFINE TABLE mrp SCHEMAFULL;
DEFINE FIELD id ON mrp TYPE record<mrp>;
DEFINE FIELD name ON mrp TYPE string;
DEFINE FIELD full_name ON mrp TYPE string;
DEFINE FIELD stock_location ON mrp TYPE string;
DEFINE FIELD end_date ON mrp TYPE date;
DEFINE FIELD status_select ON mrp TYPE int DEFAULT 0;
DEFINE FIELD start_date_time ON mrp TYPE datetime;
DEFINE FIELD end_date_time ON mrp TYPE datetime;
DEFINE FIELD mrp_seq ON mrp TYPE string;
DEFINE FIELD display_product_without_proposal ON mrp TYPE bool DEFAULT false;
DEFINE FIELD mrp_type_select ON mrp TYPE int;
DEFINE FIELD error_log ON mrp TYPE string;
DEFINE FIELD compute_with_sub_stock_location ON mrp TYPE bool DEFAULT false;
DEFINE FIELD take_in_account_sub_categories ON mrp TYPE bool DEFAULT false;
DEFINE FIELD validate_scenario ON mrp TYPE bool DEFAULT false;
DEFINE FIELD created_on ON mrp TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp TYPE datetime DEFAULT time::now();

-- Table mrp_line
DEFINE TABLE mrp_line SCHEMAFULL;
DEFINE FIELD id ON mrp_line TYPE record<mrp_line>;
DEFINE FIELD mrp ON mrp_line TYPE string;
DEFINE FIELD stock_location ON mrp_line TYPE string;
DEFINE FIELD product ON mrp_line TYPE string;
DEFINE FIELD qty ON mrp_line TYPE float;
DEFINE FIELD cumulative_qty ON mrp_line TYPE float;
DEFINE FIELD mrp_line_type ON mrp_line TYPE string;
DEFINE FIELD maturity_date ON mrp_line TYPE date;
DEFINE FIELD max_level ON mrp_line TYPE int;
DEFINE FIELD min_qty ON mrp_line TYPE float;
DEFINE FIELD ideal_qty ON mrp_line TYPE float;
DEFINE FIELD re_order_qty ON mrp_line TYPE float;
DEFINE FIELD related_to_select_name ON mrp_line TYPE string;
DEFINE FIELD estimated_delivery_mrp_line ON mrp_line TYPE string;
DEFINE FIELD delivery_delay_date ON mrp_line TYPE date;
DEFINE FIELD estimated_delivery_date ON mrp_line TYPE date;
DEFINE FIELD proposal_generated ON mrp_line TYPE bool DEFAULT false;
DEFINE FIELD proposal_to_process ON mrp_line TYPE bool DEFAULT false;
DEFINE FIELD proposal_select ON mrp_line TYPE string;
DEFINE FIELD proposal_select_id ON mrp_line TYPE int;
DEFINE FIELD partner ON mrp_line TYPE string;
DEFINE FIELD supplier_partner ON mrp_line TYPE string;
DEFINE FIELD warn_delay_from_supplier ON mrp_line TYPE bool DEFAULT false;
DEFINE FIELD company ON mrp_line TYPE string;
DEFINE FIELD unit ON mrp_line TYPE string;
DEFINE FIELD is_edited_by_user ON mrp_line TYPE bool DEFAULT false;
DEFINE FIELD created_on ON mrp_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp_line TYPE datetime DEFAULT time::now();

-- Table mrp_line_type
DEFINE TABLE mrp_line_type SCHEMAFULL;
DEFINE FIELD id ON mrp_line_type TYPE record<mrp_line_type>;
DEFINE FIELD name ON mrp_line_type TYPE string;
DEFINE FIELD code ON mrp_line_type TYPE string;
DEFINE FIELD type_select ON mrp_line_type TYPE int;
DEFINE FIELD application_field_select ON mrp_line_type TYPE int;
DEFINE FIELD color ON mrp_line_type TYPE string;
DEFINE FIELD element_select ON mrp_line_type TYPE int;
DEFINE FIELD status_select ON mrp_line_type TYPE int;
DEFINE FIELD ignore_status ON mrp_line_type TYPE bool DEFAULT false;
DEFINE FIELD include_element ON mrp_line_type TYPE bool DEFAULT true;
DEFINE FIELD active ON mrp_line_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON mrp_line_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp_line_type TYPE datetime DEFAULT time::now();

-- Table mrp_line_origin
DEFINE TABLE mrp_line_origin SCHEMAFULL;
DEFINE FIELD id ON mrp_line_origin TYPE record<mrp_line_origin>;
DEFINE FIELD mrp_line ON mrp_line_origin TYPE string;
DEFINE FIELD related_to_select ON mrp_line_origin TYPE string;
DEFINE FIELD related_to_select_id ON mrp_line_origin TYPE int;
DEFINE FIELD qty ON mrp_line_origin TYPE float;
DEFINE FIELD forecast_date ON mrp_line_origin TYPE date;
DEFINE FIELD created_on ON mrp_line_origin TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp_line_origin TYPE datetime DEFAULT time::now();

-- Table mrp_forecast
DEFINE TABLE mrp_forecast SCHEMAFULL;
DEFINE FIELD id ON mrp_forecast TYPE record<mrp_forecast>;
DEFINE FIELD forecast_date ON mrp_forecast TYPE date;
DEFINE FIELD qty ON mrp_forecast TYPE float;
DEFINE FIELD unit ON mrp_forecast TYPE string;
DEFINE FIELD product ON mrp_forecast TYPE string;
DEFINE FIELD stock_location ON mrp_forecast TYPE string;
DEFINE FIELD note ON mrp_forecast TYPE string;
DEFINE FIELD partner ON mrp_forecast TYPE string;
DEFINE FIELD status_select ON mrp_forecast TYPE int DEFAULT 1;
DEFINE FIELD technical_origin ON mrp_forecast TYPE int;
DEFINE FIELD created_on ON mrp_forecast TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp_forecast TYPE datetime DEFAULT time::now();

-- Table mrp_family
DEFINE TABLE mrp_family SCHEMAFULL;
DEFINE FIELD id ON mrp_family TYPE record<mrp_family>;
DEFINE FIELD name ON mrp_family TYPE string;
DEFINE FIELD code ON mrp_family TYPE string;
DEFINE FIELD description ON mrp_family TYPE string;
DEFINE FIELD sequence ON mrp_family TYPE int;
DEFINE FIELD active ON mrp_family TYPE bool DEFAULT true;
DEFINE FIELD created_on ON mrp_family TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mrp_family TYPE datetime DEFAULT time::now();

-- Table timetable_template
DEFINE TABLE timetable_template SCHEMAFULL;
DEFINE FIELD id ON timetable_template TYPE record<timetable_template>;
DEFINE FIELD name ON timetable_template TYPE string;
DEFINE FIELD code ON timetable_template TYPE string;
DEFINE FIELD description ON timetable_template TYPE string;
DEFINE FIELD company ON timetable_template TYPE string;
DEFINE FIELD active ON timetable_template TYPE bool DEFAULT true;
DEFINE FIELD created_on ON timetable_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON timetable_template TYPE datetime DEFAULT time::now();

-- Table timetable_template_line
DEFINE TABLE timetable_template_line SCHEMAFULL;
DEFINE FIELD id ON timetable_template_line TYPE record<timetable_template_line>;
DEFINE FIELD timetable_template ON timetable_template_line TYPE string;
DEFINE FIELD sequence ON timetable_template_line TYPE int;
DEFINE FIELD percentage ON timetable_template_line TYPE float;
DEFINE FIELD number_of_days ON timetable_template_line TYPE int;
DEFINE FIELD description ON timetable_template_line TYPE string;
DEFINE FIELD created_on ON timetable_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON timetable_template_line TYPE datetime DEFAULT time::now();

-- Table timetable
DEFINE TABLE timetable SCHEMAFULL;
DEFINE FIELD id ON timetable TYPE record<timetable>;
DEFINE FIELD sale_order ON timetable TYPE string;
DEFINE FIELD estimated_date ON timetable TYPE date;
DEFINE FIELD amount ON timetable TYPE float;
DEFINE FIELD percentage ON timetable TYPE float;
DEFINE FIELD invoice_id ON timetable TYPE string;
DEFINE FIELD invoice_date ON timetable TYPE date;
DEFINE FIELD status_select ON timetable TYPE int DEFAULT 1;
DEFINE FIELD created_on ON timetable TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON timetable TYPE datetime DEFAULT time::now();

-- Table supplychain_batch
DEFINE TABLE supplychain_batch SCHEMAFULL;
DEFINE FIELD id ON supplychain_batch TYPE record<supplychain_batch>;
DEFINE FIELD name ON supplychain_batch TYPE string;
DEFINE FIELD code ON supplychain_batch TYPE string;
DEFINE FIELD batch_type_select ON supplychain_batch TYPE int;
DEFINE FIELD description ON supplychain_batch TYPE string;
DEFINE FIELD company ON supplychain_batch TYPE string;
DEFINE FIELD start_date ON supplychain_batch TYPE datetime;
DEFINE FIELD end_date ON supplychain_batch TYPE datetime;
DEFINE FIELD status_select ON supplychain_batch TYPE int DEFAULT 0;
DEFINE FIELD stock_location ON supplychain_batch TYPE string;
DEFINE FIELD supplier_partner ON supplychain_batch TYPE string;
DEFINE FIELD update_customer_stock ON supplychain_batch TYPE bool DEFAULT false;
DEFINE FIELD update_supplier_stock ON supplychain_batch TYPE bool DEFAULT false;
DEFINE FIELD include_out_stock_move ON supplychain_batch TYPE bool DEFAULT true;
DEFINE FIELD include_in_stock_move ON supplychain_batch TYPE bool DEFAULT true;
DEFINE FIELD include_internal_stock_move ON supplychain_batch TYPE bool DEFAULT false;
DEFINE FIELD validate_stock_move ON supplychain_batch TYPE bool DEFAULT false;
DEFINE FIELD created_on ON supplychain_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON supplychain_batch TYPE datetime DEFAULT time::now();

-- Table batch (référence étendue)
DEFINE TABLE batch SCHEMAFULL;
DEFINE FIELD id ON batch TYPE record<batch>;
DEFINE FIELD name ON batch TYPE string;
DEFINE FIELD code ON batch TYPE string;
DEFINE FIELD batch_type_select ON batch TYPE int;
DEFINE FIELD description ON batch TYPE string;
DEFINE FIELD company ON batch TYPE string;
DEFINE FIELD start_date ON batch TYPE datetime;
DEFINE FIELD end_date ON batch TYPE datetime;
DEFINE FIELD status_select ON batch TYPE int DEFAULT 0;
DEFINE FIELD created_on ON batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON batch TYPE datetime DEFAULT time::now(); 