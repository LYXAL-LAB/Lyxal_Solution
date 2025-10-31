-- ================================================================
-- TABLE : sale_order_line_tax - Ligne de taxe de commande de vente
-- ================================================================

DEFINE TABLE sale_order_line_tax SCHEMAFULL;
    COMMENT "Ligne de taxe de commande de vente";

DEFINE FIELD sale_order ON sale_order_line_tax TYPE record<sale_order>;
DEFINE FIELD tax_line ON sale_order_line_tax TYPE record<tax_line>;
DEFINE FIELD ex_tax_base ON sale_order_line_tax TYPE float;
DEFINE FIELD tax_total ON sale_order_line_tax TYPE float;
DEFINE FIELD percentage_tax_total ON sale_order_line_tax TYPE float;
DEFINE FIELD in_tax_total ON sale_order_line_tax TYPE float;
DEFINE FIELD tax_type ON sale_order_line_tax TYPE string;
DEFINE FIELD created_on ON sale_order_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sale_order_line_tax TYPE datetime DEFAULT time::now();

-- Index
