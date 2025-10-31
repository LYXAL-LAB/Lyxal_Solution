-- ============================================================================
-- TABLE : sale_config - Configuration du module Lyxal Suite - Sale par company
-- ============================================================================

DEFINE TABLE sale_config SCHEMAFULL;
    COMMENT "Configuration du module Lyxal Suite - Sale par company";

DEFINE FIELD company ON sale_config TYPE record<company>;
DEFINE FIELD accepted_credit ON sale_config TYPE float;
DEFINE FIELD sale_order_in_ati_select ON sale_config TYPE int DEFAULT 1;
DEFINE FIELD sale_order_client_box ON sale_config TYPE string;
DEFINE FIELD sale_order_legal_note ON sale_config TYPE string;
DEFINE FIELD display_salesman_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_del_cond_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_product_code_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_tax_detail_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_estim_ship_date_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_customer_code_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD display_product_picture_on_printing ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD default_validity_duration ON sale_config TYPE string;
DEFINE FIELD is_analytic_distribution_required ON sale_config TYPE bool DEFAULT false;
DEFINE FIELD default_hold_back_percentage ON sale_config TYPE float;
DEFINE FIELD sale_order_print_template ON sale_config TYPE string;
DEFINE FIELD cart_order_creation_mode_select ON sale_config TYPE int DEFAULT 0;
DEFINE FIELD created_on ON sale_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sale_config TYPE datetime DEFAULT time::now();