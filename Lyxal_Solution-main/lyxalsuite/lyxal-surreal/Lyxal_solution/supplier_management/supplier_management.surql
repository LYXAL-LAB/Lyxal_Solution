-- ================================================
-- MODULE AXELOR SUPPLIER MANAGEMENT - GESTION DES FOURNISSEURS
-- ================================================

-- Table purchase_order_supplier_line
DEFINE TABLE purchase_order_supplier_line SCHEMAFULL;
DEFINE FIELD id ON purchase_order_supplier_line TYPE record<purchase_order_supplier_line>;
DEFINE FIELD purchase_order_line ON purchase_order_supplier_line TYPE string;
DEFINE FIELD available_qty ON purchase_order_supplier_line TYPE float DEFAULT 0;
DEFINE FIELD price ON purchase_order_supplier_line TYPE float;
DEFINE FIELD comments ON purchase_order_supplier_line TYPE string;
DEFINE FIELD estimated_deliv_date ON purchase_order_supplier_line TYPE date;
DEFINE FIELD state_select ON purchase_order_supplier_line TYPE int;
DEFINE FIELD supplier_partner ON purchase_order_supplier_line TYPE string;
DEFINE FIELD created_on ON purchase_order_supplier_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_supplier_line TYPE datetime DEFAULT time::now();

-- Table purchase_order_line (extension pour supplier management)
DEFINE TABLE purchase_order_line SCHEMAFULL;
DEFINE FIELD id ON purchase_order_line TYPE record<purchase_order_line>;
DEFINE FIELD purchase_order ON purchase_order_line TYPE string;
DEFINE FIELD product ON purchase_order_line TYPE string;
DEFINE FIELD product_name ON purchase_order_line TYPE string;
DEFINE FIELD description ON purchase_order_line TYPE string;
DEFINE FIELD qty ON purchase_order_line TYPE float;
DEFINE FIELD unit ON purchase_order_line TYPE string;
DEFINE FIELD price ON purchase_order_line TYPE float;
DEFINE FIELD ex_tax_total ON purchase_order_line TYPE float;
DEFINE FIELD in_tax_total ON purchase_order_line TYPE float;
DEFINE FIELD tax_line ON purchase_order_line TYPE string;
DEFINE FIELD estimated_deliv_date ON purchase_order_line TYPE date;
DEFINE FIELD sequence ON purchase_order_line TYPE int;
DEFINE FIELD received_qty ON purchase_order_line TYPE float DEFAULT 0;
DEFINE FIELD invoiced_qty ON purchase_order_line TYPE float DEFAULT 0;
DEFINE FIELD unit_price ON purchase_order_line TYPE float;
DEFINE FIELD discount_type_select ON purchase_order_line TYPE int;
DEFINE FIELD discount_amount ON purchase_order_line TYPE float;
DEFINE FIELD price_discounted ON purchase_order_line TYPE float;
DEFINE FIELD line_type_select ON purchase_order_line TYPE int;
DEFINE FIELD budget ON purchase_order_line TYPE string;
DEFINE FIELD budget_str ON purchase_order_line TYPE string;
DEFINE FIELD enable_free_text ON purchase_order_line TYPE bool DEFAULT false;
DEFINE FIELD supplier_partner ON purchase_order_line TYPE string;
DEFINE FIELD created_on ON purchase_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_line TYPE datetime DEFAULT time::now();

-- Table purchase_order (extension pour supplier management)
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
DEFINE FIELD order_number ON purchase_order TYPE string;
DEFINE FIELD receipt_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD invoice_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD stock_location ON purchase_order TYPE string;
DEFINE FIELD trading_name ON purchase_order TYPE string;
DEFINE FIELD printing_settings ON purchase_order TYPE string;
DEFINE FIELD group_products_on_printings ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD hide_discount_on_printings ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD payment_mode ON purchase_order TYPE string;
DEFINE FIELD payment_condition ON purchase_order TYPE string;
DEFINE FIELD fiscal_position ON purchase_order TYPE string;
DEFINE FIELD contact_partner ON purchase_order TYPE string;
DEFINE FIELD delivery_address ON purchase_order TYPE string;
DEFINE FIELD delivery_address_str ON purchase_order TYPE string;
DEFINE FIELD project ON purchase_order TYPE string;
DEFINE FIELD parent_purchase_order ON purchase_order TYPE string;
DEFINE FIELD is_purchase_parent ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD created_on ON purchase_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order TYPE datetime DEFAULT time::now();

-- Table app_purchase (extension pour supplier management)
DEFINE TABLE app_purchase SCHEMAFULL;
DEFINE FIELD id ON app_purchase TYPE record<app_purchase>;
DEFINE FIELD app ON app_purchase TYPE string;
DEFINE FIELD manage_purchase_order ON app_purchase TYPE bool DEFAULT true;
DEFINE FIELD is_generate_purchase_order_on_so ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD is_generate_purchase_order_on_stock_detailed_status_select ON app_purchase TYPE int DEFAULT 1;
DEFINE FIELD purchase_order_message_template ON app_purchase TYPE string;
DEFINE FIELD purchase_order_validation_required ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD purchase_order_validation_amount ON app_purchase TYPE float DEFAULT 0;
DEFINE FIELD is_purchase_order_validation_on_total_amount ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD is_purchase_order_validation_on_receipt ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD is_purchase_order_validation_on_invoice ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD supplier_request_mgt ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD created_on ON app_purchase TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_purchase TYPE datetime DEFAULT time::now();

-- Table partner (référence étendue pour fournisseurs)
DEFINE TABLE partner SCHEMAFULL;
DEFINE FIELD id ON partner TYPE record<partner>;
DEFINE FIELD name ON partner TYPE string;
DEFINE FIELD code ON partner TYPE string;
DEFINE FIELD partner_type_select ON partner TYPE int;
DEFINE FIELD is_customer ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_supplier ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_prospect ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_employee ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_carrier ON partner TYPE bool DEFAULT false;
DEFINE FIELD is_factor ON partner TYPE bool DEFAULT false;
DEFINE FIELD email ON partner TYPE string;
DEFINE FIELD phone ON partner TYPE string;
DEFINE FIELD mobile ON partner TYPE string;
DEFINE FIELD fax ON partner TYPE string;
DEFINE FIELD website ON partner TYPE string;
DEFINE FIELD main_address ON partner TYPE string;
DEFINE FIELD invoicing_address ON partner TYPE string;
DEFINE FIELD delivery_address ON partner TYPE string;
DEFINE FIELD currency ON partner TYPE string;
DEFINE FIELD language ON partner TYPE string;
DEFINE FIELD price_list ON partner TYPE string;
DEFINE FIELD sale_price_list ON partner TYPE string;
DEFINE FIELD purchase_price_list ON partner TYPE string;
DEFINE FIELD payment_condition ON partner TYPE string;
DEFINE FIELD payment_mode ON partner TYPE string;
DEFINE FIELD in_payment_mode ON partner TYPE string;
DEFINE FIELD out_payment_mode ON partner TYPE string;
DEFINE FIELD fiscal_position ON partner TYPE string;
DEFINE FIELD supplier_type_select ON partner TYPE int;
DEFINE FIELD supplier_quality_rating ON partner TYPE float DEFAULT 0;
DEFINE FIELD supplier_delivery_delay ON partner TYPE int DEFAULT 0;
DEFINE FIELD supplier_catalog_available ON partner TYPE bool DEFAULT false;
DEFINE FIELD purchase_order_information ON partner TYPE string;
DEFINE FIELD blocked_account ON partner TYPE bool DEFAULT false;
DEFINE FIELD active ON partner TYPE bool DEFAULT true;
DEFINE FIELD created_on ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON partner TYPE datetime DEFAULT time::now();

-- Table product (référence étendue pour les achats)
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
DEFINE FIELD management_type_select ON product TYPE int;
DEFINE FIELD procurement_method_select ON product TYPE int;
DEFINE FIELD description ON product TYPE string;
DEFINE FIELD internal_description ON product TYPE string;
DEFINE FIELD picture ON product TYPE string;
DEFINE FIELD product_family ON product TYPE string;
DEFINE FIELD product_category ON product TYPE string;
DEFINE FIELD product_variant_config ON product TYPE string;
DEFINE FIELD active ON product TYPE bool DEFAULT true;
DEFINE FIELD sellable ON product TYPE bool DEFAULT true;
DEFINE FIELD purchasable ON product TYPE bool DEFAULT true;
DEFINE FIELD stock_managed ON product TYPE bool DEFAULT false;
DEFINE FIELD weight ON product TYPE float;
DEFINE FIELD length ON product TYPE float;
DEFINE FIELD width ON product TYPE float;
DEFINE FIELD height ON product TYPE float;
DEFINE FIELD gross_volume ON product TYPE float;
DEFINE FIELD net_volume ON product TYPE float;
DEFINE FIELD default_supplier_partner ON product TYPE string;
DEFINE FIELD supplier_delivery_delay ON product TYPE int DEFAULT 0;
DEFINE FIELD economic_manufacture_qty ON product TYPE float DEFAULT 0;
DEFINE FIELD created_on ON product TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON product TYPE datetime DEFAULT time::now();

-- Table company_supplier (extension entreprises pour supplier management)
DEFINE TABLE company_supplier SCHEMAFULL;
DEFINE FIELD id ON company_supplier TYPE record<company_supplier>;
DEFINE FIELD company_id ON company_supplier TYPE record<company>;
-- Tous les champs communs sont maintenant dans la table company de base
DEFINE FIELD created_on ON company_supplier TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_supplier TYPE datetime DEFAULT time::now();

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