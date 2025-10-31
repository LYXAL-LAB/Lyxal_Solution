-- ================================================
-- MODULE AXELOR SUPPLIER PORTAL - PORTAIL FOURNISSEUR
-- ================================================

-- Table product_supplier
DEFINE TABLE product_supplier SCHEMAFULL;
DEFINE FIELD id ON product_supplier TYPE record<product_supplier>;
DEFINE FIELD product_code ON product_supplier TYPE string;
DEFINE FIELD product_name ON product_supplier TYPE string;
DEFINE FIELD img_product ON product_supplier TYPE string;
DEFINE FIELD purchase_unit ON product_supplier TYPE string;
DEFINE FIELD purchase_price ON product_supplier TYPE float;
DEFINE FIELD purchase_currency ON product_supplier TYPE string;
DEFINE FIELD description ON product_supplier TYPE string;
DEFINE FIELD product_created ON product_supplier TYPE string;
DEFINE FIELD supplier_partner ON product_supplier TYPE string;
DEFINE FIELD status_select ON product_supplier TYPE int DEFAULT 1;
DEFINE FIELD approved_by ON product_supplier TYPE string;
DEFINE FIELD approved_on ON product_supplier TYPE datetime;
DEFINE FIELD rejection_reason ON product_supplier TYPE string;
DEFINE FIELD created_on ON product_supplier TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON product_supplier TYPE datetime DEFAULT time::now();

-- Table invoice_supplier
DEFINE TABLE invoice_supplier SCHEMAFULL;
DEFINE FIELD id ON invoice_supplier TYPE record<invoice_supplier>;
DEFINE FIELD partner ON invoice_supplier TYPE string;
DEFINE FIELD invoice_date ON invoice_supplier TYPE date;
DEFINE FIELD due_date ON invoice_supplier TYPE date;
DEFINE FIELD invoice_file ON invoice_supplier TYPE string;
DEFINE FIELD invoice_number ON invoice_supplier TYPE string;
DEFINE FIELD total_amount ON invoice_supplier TYPE float;
DEFINE FIELD currency ON invoice_supplier TYPE string;
DEFINE FIELD status_select ON invoice_supplier TYPE int DEFAULT 1;
DEFINE FIELD purchase_order ON invoice_supplier TYPE string;
DEFINE FIELD comments ON invoice_supplier TYPE string;
DEFINE FIELD validated_by ON invoice_supplier TYPE string;
DEFINE FIELD validated_on ON invoice_supplier TYPE datetime;
DEFINE FIELD created_on ON invoice_supplier TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON invoice_supplier TYPE datetime DEFAULT time::now();

-- Table app_supplier_portal
DEFINE TABLE app_supplier_portal SCHEMAFULL;
DEFINE FIELD id ON app_supplier_portal TYPE record<app_supplier_portal>;
DEFINE FIELD app ON app_supplier_portal TYPE string;
DEFINE FIELD manage_purchase_orders ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD manage_invoices ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD manage_delivery ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD show_catalog ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD allow_supplier_to_create_products ON app_supplier_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_url ON app_supplier_portal TYPE string;
DEFINE FIELD max_file_size ON app_supplier_portal TYPE int DEFAULT 10;
DEFINE FIELD allowed_file_types ON app_supplier_portal TYPE string;
DEFINE FIELD auto_approve_products ON app_supplier_portal TYPE bool DEFAULT false;
DEFINE FIELD notification_email ON app_supplier_portal TYPE string;
DEFINE FIELD portal_theme ON app_supplier_portal TYPE string;
DEFINE FIELD terms_and_conditions ON app_supplier_portal TYPE string;
DEFINE FIELD created_on ON app_supplier_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_supplier_portal TYPE datetime DEFAULT time::now();

-- Table app (extension pour supplier portal)
DEFINE TABLE app SCHEMAFULL;
DEFINE FIELD id ON app TYPE record<app>;
DEFINE FIELD name ON app TYPE string;
DEFINE FIELD code ON app TYPE string;
DEFINE FIELD description ON app TYPE string;
DEFINE FIELD active ON app TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app TYPE int;
DEFINE FIELD version ON app TYPE string;
DEFINE FIELD depends_on ON app TYPE string;
DEFINE FIELD app_supplier_portal ON app TYPE string;
DEFINE FIELD created_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app TYPE datetime DEFAULT time::now();

-- Table partner (référence étendue pour le portail fournisseur)
DEFINE TABLE partner SCHEMAFULL;
DEFINE FIELD id ON partner TYPE record<partner>;
DEFINE FIELD name ON partner TYPE string;
DEFINE FIELD code ON partner TYPE string;
DEFINE FIELD partner_type_select ON partner TYPE int;
DEFINE FIELD is_customer ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_supplier ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_prospect ON partner TYPE bool DEFAULT false;
DEFINE FIELD email ON partner TYPE string;
DEFINE FIELD phone ON partner TYPE string;
DEFINE FIELD mobile ON partner TYPE string;
DEFINE FIELD website ON partner TYPE string;
DEFINE FIELD main_address ON partner TYPE string;
DEFINE FIELD invoicing_address ON partner TYPE string;
DEFINE FIELD delivery_address ON partner TYPE string;
DEFINE FIELD currency ON partner TYPE string;
DEFINE FIELD language ON partner TYPE string;
DEFINE FIELD price_list ON partner TYPE string;
DEFINE FIELD payment_condition ON partner TYPE string;
DEFINE FIELD payment_mode ON partner TYPE string;
DEFINE FIELD fiscal_position ON partner TYPE string;
DEFINE FIELD has_portal_access ON partner TYPE bool DEFAULT false;
DEFINE FIELD portal_login ON partner TYPE string;
DEFINE FIELD portal_password ON partner TYPE string;
DEFINE FIELD last_portal_login ON partner TYPE datetime;
DEFINE FIELD portal_access_active ON partner TYPE bool DEFAULT false;
DEFINE FIELD portal_user_group ON partner TYPE string;
DEFINE FIELD blocked_account ON partner TYPE bool DEFAULT false;
DEFINE FIELD active ON partner TYPE bool DEFAULT true;
DEFINE FIELD created_on ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON partner TYPE datetime DEFAULT time::now();

-- Table product (référence étendue pour le catalogue fournisseur)
DEFINE TABLE product SCHEMAFULL;
DEFINE FIELD id ON product TYPE record<product>;
DEFINE FIELD name ON product TYPE string;
DEFINE FIELD code ON product TYPE string;
DEFINE FIELD product_type_select ON product TYPE int;
DEFINE FIELD product_sub_type_select ON product TYPE int;
DEFINE FIELD unit ON product TYPE string;
DEFINE FIELD purchase_unit ON product TYPE string;
DEFINE FIELD sale_unit ON product TYPE string;
DEFINE FIELD sale_price ON product TYPE float;
DEFINE FIELD purchase_price ON product TYPE float;
DEFINE FIELD cost_price ON product TYPE float;
DEFINE FIELD description ON product TYPE string;
DEFINE FIELD internal_description ON product TYPE string;
DEFINE FIELD picture ON product TYPE string;
DEFINE FIELD product_family ON product TYPE string;
DEFINE FIELD product_category ON product TYPE string;
DEFINE FIELD active ON product TYPE bool DEFAULT true;
DEFINE FIELD sellable ON product TYPE bool DEFAULT true;
DEFINE FIELD purchasable ON product TYPE bool DEFAULT true;
DEFINE FIELD stock_managed ON product TYPE bool DEFAULT false;
DEFINE FIELD weight ON product TYPE float;
DEFINE FIELD length ON product TYPE float;
DEFINE FIELD width ON product TYPE float;
DEFINE FIELD height ON product TYPE float;
DEFINE FIELD visible_in_portal ON product TYPE bool DEFAULT true;
DEFINE FIELD supplier_partner ON product TYPE string;
DEFINE FIELD minimum_order_qty ON product TYPE float DEFAULT 1;
DEFINE FIELD maximum_order_qty ON product TYPE float;
DEFINE FIELD lead_time_days ON product TYPE int DEFAULT 0;
DEFINE FIELD created_on ON product TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON product TYPE datetime DEFAULT time::now();

-- Table purchase_order (référence étendue pour le portail)
DEFINE TABLE purchase_order SCHEMAFULL;
DEFINE FIELD id ON purchase_order TYPE record<purchase_order>;
DEFINE FIELD purchase_order_seq ON purchase_order TYPE string;
DEFINE FIELD order_date ON purchase_order TYPE date;
DEFINE FIELD delivery_date ON purchase_order TYPE date;
DEFINE FIELD status_select ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD supplier_partner ON purchase_order TYPE string;
DEFINE FIELD company ON purchase_order TYPE string;
DEFINE FIELD currency ON purchase_order TYPE string;
DEFINE FIELD price_list ON purchase_order TYPE string;
DEFINE FIELD ex_tax_total ON purchase_order TYPE float;
DEFINE FIELD tax_total ON purchase_order TYPE float;
DEFINE FIELD in_tax_total ON purchase_order TYPE float;
DEFINE FIELD validation_date ON purchase_order TYPE date;
DEFINE FIELD validated_by ON purchase_order TYPE string;
DEFINE FIELD notes ON purchase_order TYPE string;
DEFINE FIELD internal_reference ON purchase_order TYPE string;
DEFINE FIELD external_reference ON purchase_order TYPE string;
DEFINE FIELD receipt_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD invoice_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD stock_location ON purchase_order TYPE string;
DEFINE FIELD contact_partner ON purchase_order TYPE string;
DEFINE FIELD delivery_address ON purchase_order TYPE string;
DEFINE FIELD project ON purchase_order TYPE string;
DEFINE FIELD visible_in_portal ON purchase_order TYPE bool DEFAULT true;
DEFINE FIELD supplier_acknowledgment_date ON purchase_order TYPE datetime;
DEFINE FIELD estimated_delivery_date ON purchase_order TYPE date;
DEFINE FIELD portal_comments ON purchase_order TYPE string;
DEFINE FIELD created_on ON purchase_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order TYPE datetime DEFAULT time::now();

-- Table unit (référence étendue)
DEFINE TABLE unit SCHEMAFULL;
DEFINE FIELD id ON unit TYPE record<unit>;
DEFINE FIELD name ON unit TYPE string;
DEFINE FIELD label_tn ON unit TYPE string;
DEFINE FIELD symbol ON unit TYPE string;
DEFINE FIELD unit_type_select ON unit TYPE int;
DEFINE FIELD conversion_factor ON unit TYPE float DEFAULT 1;
DEFINE FIELD scale ON unit TYPE int DEFAULT 0;
DEFINE FIELD active ON unit TYPE bool DEFAULT true;
DEFINE FIELD created_on ON unit TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON unit TYPE datetime DEFAULT time::now();

-- Table currency (référence étendue)
DEFINE TABLE currency SCHEMAFULL;
DEFINE FIELD id ON currency TYPE record<currency>;
DEFINE FIELD name ON currency TYPE string;
DEFINE FIELD code ON currency TYPE string;
DEFINE FIELD symbol ON currency TYPE string;
DEFINE FIELD number_of_decimals ON currency TYPE int DEFAULT 2;
DEFINE FIELD active ON currency TYPE bool DEFAULT true;
DEFINE FIELD created_on ON currency TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON currency TYPE datetime DEFAULT time::now();