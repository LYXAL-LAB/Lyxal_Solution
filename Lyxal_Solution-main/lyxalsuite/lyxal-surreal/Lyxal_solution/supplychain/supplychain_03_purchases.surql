-- ================================================
-- MODULE AXELOR SUPPLYCHAIN - ACHATS AVANCÉS
-- ================================================

-- Table purchase_order (étendue pour supplychain)
DEFINE TABLE purchase_order SCHEMAFULL;
DEFINE FIELD id ON purchase_order TYPE record<purchase_order>;
DEFINE FIELD purchase_order_seq ON purchase_order TYPE string;
DEFINE FIELD company ON purchase_order TYPE string;
DEFINE FIELD trading_name ON purchase_order TYPE string;
DEFINE FIELD supplier_partner ON purchase_order TYPE string;
DEFINE FIELD contact_partner ON purchase_order TYPE string;
DEFINE FIELD supplier_invoicing_address ON purchase_order TYPE string;
DEFINE FIELD delivery_address ON purchase_order TYPE string;
DEFINE FIELD order_date ON purchase_order TYPE date;
DEFINE FIELD creation_date ON purchase_order TYPE datetime;
DEFINE FIELD validation_date ON purchase_order TYPE datetime;
DEFINE FIELD receipt_date ON purchase_order TYPE date;
DEFINE FIELD desired_receipt_date ON purchase_order TYPE date;
DEFINE FIELD status_select ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD version_number ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD external_reference ON purchase_order TYPE string;
DEFINE FIELD internal_reference ON purchase_order TYPE string;
DEFINE FIELD price_list ON purchase_order TYPE string;
DEFINE FIELD currency ON purchase_order TYPE string;
DEFINE FIELD ex_tax_total ON purchase_order TYPE float;
DEFINE FIELD tax_total ON purchase_order TYPE float;
DEFINE FIELD in_tax_total ON purchase_order TYPE float;
DEFINE FIELD advance_total ON purchase_order TYPE float;
DEFINE FIELD description ON purchase_order TYPE string;
DEFINE FIELD notes ON purchase_order TYPE string;
DEFINE FIELD stock_location ON purchase_order TYPE string;
DEFINE FIELD shipment_mode ON purchase_order TYPE string;
DEFINE FIELD freight_carrier_mode ON purchase_order TYPE string;
DEFINE FIELD interco ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD created_by_interco ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD receipt_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD invoicing_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD advance_payment_needed ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD advance_payment_state ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD template ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD validity_date ON purchase_order TYPE date;
DEFINE FIELD created_on ON purchase_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order TYPE datetime DEFAULT time::now();

-- Table purchase_order_line (lignes commande achat)
DEFINE TABLE purchase_order_line SCHEMAFULL;
DEFINE FIELD id ON purchase_order_line TYPE record<purchase_order_line>;
DEFINE FIELD purchase_order ON purchase_order_line TYPE string;
DEFINE FIELD sequence ON purchase_order_line TYPE int;
DEFINE FIELD product ON purchase_order_line TYPE string;
DEFINE FIELD product_name ON purchase_order_line TYPE string;
DEFINE FIELD product_code ON purchase_order_line TYPE string;
DEFINE FIELD qty ON purchase_order_line TYPE float;
DEFINE FIELD unit ON purchase_order_line TYPE string;
DEFINE FIELD price ON purchase_order_line TYPE float;
DEFINE FIELD discount_amount ON purchase_order_line TYPE float;
DEFINE FIELD discount_type_select ON purchase_order_line TYPE int;
DEFINE FIELD ex_tax_total ON purchase_order_line TYPE float;
DEFINE FIELD in_tax_total ON purchase_order_line TYPE float;
DEFINE FIELD tax_line ON purchase_order_line TYPE string;
DEFINE FIELD description ON purchase_order_line TYPE string;
DEFINE FIELD is_title_line ON purchase_order_line TYPE bool DEFAULT false;
DEFINE FIELD type_select ON purchase_order_line TYPE int DEFAULT 1;
DEFINE FIELD receipt_state ON purchase_order_line TYPE int DEFAULT 1;
DEFINE FIELD invoicing_state ON purchase_order_line TYPE int DEFAULT 1;
DEFINE FIELD received_qty ON purchase_order_line TYPE float;
DEFINE FIELD invoiced_qty ON purchase_order_line TYPE float;
DEFINE FIELD desired_receipt_date ON purchase_order_line TYPE date;
DEFINE FIELD estimated_receipt_date ON purchase_order_line TYPE date;
DEFINE FIELD sale_order_line ON purchase_order_line TYPE string;
DEFINE FIELD supplier_partner ON purchase_order_line TYPE string;
DEFINE FIELD analytic_move_line_list ON purchase_order_line TYPE string;
DEFINE FIELD budget_distribution_sum_amount ON purchase_order_line TYPE float;
DEFINE FIELD fixed_asset_category ON purchase_order_line TYPE string;
DEFINE FIELD asset ON purchase_order_line TYPE string;
DEFINE FIELD created_on ON purchase_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_line TYPE datetime DEFAULT time::now();

-- Table purchase_order_line_tax (taxes lignes achat)
DEFINE TABLE purchase_order_line_tax SCHEMAFULL;
DEFINE FIELD id ON purchase_order_line_tax TYPE record<purchase_order_line_tax>;
DEFINE FIELD purchase_order_line ON purchase_order_line_tax TYPE string;
DEFINE FIELD tax_line ON purchase_order_line_tax TYPE string;
DEFINE FIELD reverse_charged ON purchase_order_line_tax TYPE bool DEFAULT false;
DEFINE FIELD created_on ON purchase_order_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_line_tax TYPE datetime DEFAULT time::now();

-- Table purchase_request (demandes d'achat)
DEFINE TABLE purchase_request SCHEMAFULL;
DEFINE FIELD id ON purchase_request TYPE record<purchase_request>;
DEFINE FIELD purchase_request_seq ON purchase_request TYPE string;
DEFINE FIELD company ON purchase_request TYPE string;
DEFINE FIELD requester_user ON purchase_request TYPE string;
DEFINE FIELD requested_by ON purchase_request TYPE string;
DEFINE FIELD request_date ON purchase_request TYPE date;
DEFINE FIELD desired_date ON purchase_request TYPE date;
DEFINE FIELD status_select ON purchase_request TYPE int DEFAULT 1;
DEFINE FIELD supplier_user ON purchase_request TYPE string;
DEFINE FIELD supplier_partner ON purchase_request TYPE string;
DEFINE FIELD budget ON purchase_request TYPE float;
DEFINE FIELD description ON purchase_request TYPE string;
DEFINE FIELD notes ON purchase_request TYPE string;
DEFINE FIELD delivery_address ON purchase_request TYPE string;
DEFINE FIELD total_amount ON purchase_request TYPE float;
DEFINE FIELD currency ON purchase_request TYPE string;
DEFINE FIELD created_on ON purchase_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_request TYPE datetime DEFAULT time::now();

-- Table purchase_request_line (lignes demande achat)
DEFINE TABLE purchase_request_line SCHEMAFULL;
DEFINE FIELD id ON purchase_request_line TYPE record<purchase_request_line>;
DEFINE FIELD purchase_request ON purchase_request_line TYPE string;
DEFINE FIELD sequence ON purchase_request_line TYPE int;
DEFINE FIELD product ON purchase_request_line TYPE string;
DEFINE FIELD product_name ON purchase_request_line TYPE string;
DEFINE FIELD qty ON purchase_request_line TYPE float;
DEFINE FIELD unit ON purchase_request_line TYPE string;
DEFINE FIELD estimated_price ON purchase_request_line TYPE float;
DEFINE FIELD budget_amount ON purchase_request_line TYPE float;
DEFINE FIELD description ON purchase_request_line TYPE string;
DEFINE FIELD is_title_line ON purchase_request_line TYPE bool DEFAULT false;
DEFINE FIELD supplier_partner ON purchase_request_line TYPE string;
DEFINE FIELD purchase_order_line ON purchase_request_line TYPE string;
DEFINE FIELD created_on ON purchase_request_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_request_line TYPE datetime DEFAULT time::now();

-- Table supplier_catalog (catalogue fournisseur)
DEFINE TABLE supplier_catalog SCHEMAFULL;
DEFINE FIELD id ON supplier_catalog TYPE record<supplier_catalog>;
DEFINE FIELD supplier_partner ON supplier_catalog TYPE string;
DEFINE FIELD product ON supplier_catalog TYPE string;
DEFINE FIELD product_supplier_name ON supplier_catalog TYPE string;
DEFINE FIELD product_supplier_code ON supplier_catalog TYPE string;
DEFINE FIELD price ON supplier_catalog TYPE float;
DEFINE FIELD currency ON supplier_catalog TYPE string;
DEFINE FIELD min_qty ON supplier_catalog TYPE float;
DEFINE FIELD unit ON supplier_catalog TYPE string;
DEFINE FIELD delivery_time ON supplier_catalog TYPE int;
DEFINE FIELD created_on ON supplier_catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON supplier_catalog TYPE datetime DEFAULT time::now();

-- Table purchase_quotation (devis achat)
DEFINE TABLE purchase_quotation SCHEMAFULL;
DEFINE FIELD id ON purchase_quotation TYPE record<purchase_quotation>;
DEFINE FIELD purchase_quotation_seq ON purchase_quotation TYPE string;
DEFINE FIELD company ON purchase_quotation TYPE string;
DEFINE FIELD supplier_partner ON purchase_quotation TYPE string;
DEFINE FIELD purchase_request ON purchase_quotation TYPE string;
DEFINE FIELD quotation_date ON purchase_quotation TYPE date;
DEFINE FIELD validity_date ON purchase_quotation TYPE date;
DEFINE FIELD status_select ON purchase_quotation TYPE int DEFAULT 1;
DEFINE FIELD currency ON purchase_quotation TYPE string;
DEFINE FIELD ex_tax_total ON purchase_quotation TYPE float;
DEFINE FIELD tax_total ON purchase_quotation TYPE float;
DEFINE FIELD in_tax_total ON purchase_quotation TYPE float;
DEFINE FIELD description ON purchase_quotation TYPE string;
DEFINE FIELD notes ON purchase_quotation TYPE string;
DEFINE FIELD delivery_time ON purchase_quotation TYPE int;
DEFINE FIELD payment_condition ON purchase_quotation TYPE string;
DEFINE FIELD created_on ON purchase_quotation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_quotation TYPE datetime DEFAULT time::now();

-- Table purchase_quotation_line (lignes devis achat)
DEFINE TABLE purchase_quotation_line SCHEMAFULL;
DEFINE FIELD id ON purchase_quotation_line TYPE record<purchase_quotation_line>;
DEFINE FIELD purchase_quotation ON purchase_quotation_line TYPE string;
DEFINE FIELD sequence ON purchase_quotation_line TYPE int;
DEFINE FIELD product ON purchase_quotation_line TYPE string;
DEFINE FIELD product_name ON purchase_quotation_line TYPE string;
DEFINE FIELD qty ON purchase_quotation_line TYPE float;
DEFINE FIELD unit ON purchase_quotation_line TYPE string;
DEFINE FIELD price ON purchase_quotation_line TYPE float;
DEFINE FIELD ex_tax_total ON purchase_quotation_line TYPE float;
DEFINE FIELD in_tax_total ON purchase_quotation_line TYPE float;
DEFINE FIELD description ON purchase_quotation_line TYPE string;
DEFINE FIELD delivery_time ON purchase_quotation_line TYPE int;
DEFINE FIELD purchase_request_line ON purchase_quotation_line TYPE string;
DEFINE FIELD created_on ON purchase_quotation_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_quotation_line TYPE datetime DEFAULT time::now();

-- Table supplier_arrival (réception fournisseur)
DEFINE TABLE supplier_arrival SCHEMAFULL;
DEFINE FIELD id ON supplier_arrival TYPE record<supplier_arrival>;
DEFINE FIELD supplier_arrival_seq ON supplier_arrival TYPE string;
DEFINE FIELD company ON supplier_arrival TYPE string;
DEFINE FIELD supplier_partner ON supplier_arrival TYPE string;
DEFINE FIELD purchase_order ON supplier_arrival TYPE string;
DEFINE FIELD arrival_date ON supplier_arrival TYPE date;
DEFINE FIELD status_select ON supplier_arrival TYPE int DEFAULT 1;
DEFINE FIELD stock_location ON supplier_arrival TYPE string;
DEFINE FIELD description ON supplier_arrival TYPE string;
DEFINE FIELD notes ON supplier_arrival TYPE string;
DEFINE FIELD created_on ON supplier_arrival TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON supplier_arrival TYPE datetime DEFAULT time::now(); 