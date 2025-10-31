-- =====================================================================
-- TABLE : app_sale - Configuration globale du module Lyxal Suite - Sale
-- =====================================================================

DEFINE TABLE app_sale SCHEMAFULL;
    COMMENT "Configuration globale du module Lyxal Suite - Sale";
    
DEFINE FIELD app ON app_sale TYPE string;
DEFINE FIELD manage_sale_order_version ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD printing_on_so_finalization ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_past_version_recovery ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD manage_sales_units ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD enable_configurator ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD allow_pending_order_modification ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD manage_multiple_sale_quantity ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD printing_config_per_sale_order ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD close_opportunity_upon_sale_order_confirmation ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_enabled_product_description_copy ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD salesperson_select ON app_sale TYPE int DEFAULT 1;
DEFINE FIELD enable_customer_catalog_mgt ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD enable_pack_management ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_display_sale_order_line_number ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD enable_sales_product_by_trad_name ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD sale_unit ON app_sale TYPE string;
DEFINE FIELD manage_partner_complementary_product ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_enable_calculation_entire_quotation ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD consider_zero_cost ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_discount_enabled_on_editable_grid ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD is_cart_management_enabled ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD list_display_type_select ON app_sale TYPE int DEFAULT 0;
DEFINE FIELD is_sol_price_total_of_sub_lines ON app_sale TYPE bool DEFAULT true;
DEFINE FIELD is_global_discount_enabled_on_sale_order ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD enable_configurator_edition ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD enable_line_duplication ON app_sale TYPE bool DEFAULT false;
DEFINE FIELD created_on ON app_sale TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_sale TYPE datetime DEFAULT time::now();



