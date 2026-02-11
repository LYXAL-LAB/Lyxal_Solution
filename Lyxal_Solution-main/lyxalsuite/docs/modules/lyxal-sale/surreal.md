-- STRUCTURE SURREALDB : MODULE LYXALSALE (adapté d'Axelor Sale)

-- 1. TABLE PRINCIPALE : sale_order
DEFINE TABLE sale_order SCHEMAFUL;
DEFINE FIELD saleOrderSeq ON sale_order TYPE string ASSERT string::length($value) > 0;
DEFINE FIELD fullName ON sale_order TYPE string;
DEFINE FIELD company ON sale_order TYPE record(company) ASSERT $value != NONE;
DEFINE FIELD clientPartner ON sale_order TYPE record(partner);
DEFINE FIELD contactPartner ON sale_order TYPE record(partner);
DEFINE FIELD currency ON sale_order TYPE record(currency);
DEFINE FIELD creationDate ON sale_order TYPE datetime DEFAULT time::now();
DEFINE FIELD confirmationDateTime ON sale_order TYPE datetime;
DEFINE FIELD opportunity ON sale_order TYPE record(opportunity);
DEFINE FIELD saleOrderLineList ON sale_order TYPE array;
DEFINE FIELD statusSelect ON sale_order TYPE int DEFAULT 1;
DEFINE FIELD exTaxTotal ON sale_order TYPE decimal(20,3);
DEFINE FIELD inTaxTotal ON sale_order TYPE decimal(20,3);
DEFINE FIELD taxTotal ON sale_order TYPE decimal(20,3);
DEFINE FIELD versionNumber ON sale_order TYPE int DEFAULT 1;
DEFINE FIELD discountAmount ON sale_order TYPE decimal(20,10);
DEFINE FIELD discountTypeSelect ON sale_order TYPE int;
DEFINE INDEX sale_order_seq_idx ON sale_order FIELDS saleOrderSeq UNIQUE;

-- 2. TABLE sale_order_line
DEFINE TABLE sale_order_line SCHEMAFUL;
DEFINE FIELD saleOrder ON sale_order_line TYPE record(sale_order);
DEFINE FIELD product ON sale_order_line TYPE record(product);
DEFINE FIELD qty ON sale_order_line TYPE decimal(20,10) DEFAULT 1;
DEFINE FIELD price ON sale_order_line TYPE decimal(20,10);
DEFINE FIELD inTaxPrice ON sale_order_line TYPE decimal(20,10);
DEFINE FIELD priceDiscounted ON sale_order_line TYPE decimal(30,20);
DEFINE FIELD discountAmount ON sale_order_line TYPE decimal(30,20);
DEFINE FIELD discountTypeSelect ON sale_order_line TYPE int;
DEFINE FIELD description ON sale_order_line TYPE string;
DEFINE FIELD estimatedShippingDate ON sale_order_line TYPE date;
DEFINE FIELD subSaleOrderLineList ON sale_order_line TYPE array;
DEFINE FIELD parentSaleOrderLine ON sale_order_line TYPE record(sale_order_line);
DEFINE FIELD typeSelect ON sale_order_line TYPE int DEFAULT 0;
DEFINE FIELD configurator ON sale_order_line TYPE record(configurator);
DEFINE INDEX sale_order_line_order_idx ON sale_order_line FIELDS saleOrder;

-- 3. TABLE advance_payment
DEFINE TABLE advance_payment SCHEMAFUL;
DEFINE FIELD saleOrder ON advance_payment TYPE record(sale_order);
DEFINE FIELD amount ON advance_payment TYPE decimal(20,3) DEFAULT 0;
DEFINE FIELD advancePaymentDate ON advance_payment TYPE date;
DEFINE FIELD currency ON advance_payment TYPE record(currency);
DEFINE FIELD statusSelect ON advance_payment TYPE int DEFAULT 0;
DEFINE INDEX advance_payment_order_idx ON advance_payment FIELDS saleOrder;

-- 4. TABLE sale_order_line_tax
DEFINE TABLE sale_order_line_tax SCHEMAFUL;
DEFINE FIELD saleOrder ON sale_order_line_tax TYPE record(sale_order);
DEFINE FIELD taxLine ON sale_order_line_tax TYPE record(tax_line);
DEFINE FIELD exTaxBase ON sale_order_line_tax TYPE decimal(20,3);
DEFINE FIELD taxTotal ON sale_order_line_tax TYPE decimal(20,3);
DEFINE FIELD inTaxTotal ON sale_order_line_tax TYPE decimal(20,3);

-- 5. TABLE cart
DEFINE TABLE cart SCHEMAFUL;
DEFINE FIELD user ON cart TYPE record(user);
DEFINE FIELD company ON cart TYPE record(company);
DEFINE FIELD partner ON cart TYPE record(partner);

-- 6. TABLE cart_line
DEFINE TABLE cart_line SCHEMAFUL;
DEFINE FIELD cart ON cart_line TYPE record(cart);
DEFINE FIELD product ON cart_line TYPE record(product);
DEFINE FIELD qty ON cart_line TYPE decimal(20,10) DEFAULT 1;
DEFINE FIELD price ON cart_line TYPE decimal(20,10);
DEFINE FIELD unit ON cart_line TYPE record(unit);

-- 7. TABLE pack / pack_line
DEFINE TABLE pack SCHEMAFUL;
DEFINE FIELD code ON pack TYPE string ASSERT string::length($value) > 0;
DEFINE FIELD name ON pack TYPE string;
DEFINE FIELD company ON pack TYPE record(company);
DEFINE FIELD currency ON pack TYPE record(currency);
DEFINE FIELD unit ON pack TYPE record(unit);
DEFINE FIELD isShowTotal ON pack TYPE bool;
DEFINE FIELD components ON pack TYPE array;

DEFINE TABLE pack_line SCHEMAFUL;
DEFINE FIELD pack ON pack_line TYPE record(pack);
DEFINE FIELD product ON pack_line TYPE record(product);
DEFINE FIELD quantity ON pack_line TYPE decimal(20,10);
DEFINE FIELD price ON pack_line TYPE decimal(20,3);
DEFINE FIELD unit ON pack_line TYPE record(unit);
DEFINE FIELD typeSelect ON pack_line TYPE int DEFAULT 0;

-- 8. TABLE customer_catalog
DEFINE TABLE customer_catalog SCHEMAFUL;
DEFINE FIELD product ON customer_catalog TYPE record(product);
DEFINE FIELD customerPartner ON customer_catalog TYPE record(partner);
DEFINE FIELD productCustomerName ON customer_catalog TYPE string;
DEFINE FIELD productCustomerCode ON customer_catalog TYPE string;

-- 9. TABLE sale_config
DEFINE TABLE sale_config SCHEMAFUL;
DEFINE FIELD company ON sale_config TYPE record(company);
DEFINE FIELD acceptedCredit ON sale_config TYPE decimal(20,3);
DEFINE FIELD saleOrderInAtiSelect ON sale_config TYPE int DEFAULT 1;
DEFINE FIELD defaultHoldBackPercentage ON sale_config TYPE decimal(5,2);
DEFINE FIELD isAnalyticDistributionRequired ON sale_config TYPE bool;

-- 10. TABLE sale_batch
DEFINE TABLE sale_batch SCHEMAFUL;
DEFINE FIELD code ON sale_batch TYPE string UNIQUE;
DEFINE FIELD actionSelect ON sale_batch TYPE int;
DEFINE FIELD description ON sale_batch TYPE string;
DEFINE FIELD company ON sale_batch TYPE record(company);
DEFINE FIELD fetchLimit ON sale_batch TYPE int;

-- 11. TABLE configurator_creator
DEFINE TABLE configurator_creator SCHEMAFUL;
DEFINE FIELD name ON configurator_creator TYPE string;
DEFINE FIELD attributes ON configurator_creator TYPE object;
DEFINE FIELD indicators ON configurator_creator TYPE object;
DEFINE FIELD qtyFormula ON configurator_creator TYPE string;
DEFINE FIELD isActive ON configurator_creator TYPE bool DEFAULT false;
DEFINE FIELD configuratorVersion ON configurator_creator TYPE int DEFAULT 0;

-- 12. TABLE configurator
DEFINE TABLE configurator SCHEMAFUL;
DEFINE FIELD configuratorCreator ON configurator TYPE record(configurator_creator);
DEFINE FIELD attributes ON configurator TYPE object;
DEFINE FIELD indicators ON configurator TYPE object;
DEFINE FIELD product ON configurator TYPE record(product);
DEFINE FIELD configuratorVersion ON configurator TYPE int;

-- 13. TABLE configurator_formula (abstraite)
DEFINE TABLE configurator_formula SCHEMAFUL;
DEFINE FIELD metaField ON configurator_formula TYPE record(meta_field);
DEFINE FIELD formula ON configurator_formula TYPE string;
DEFINE FIELD showOnConfigurator ON configurator_formula TYPE bool;
DEFINE FIELD metaJsonField ON configurator_formula TYPE record(meta_json_field);

-- 14. TABLE configurator_product_formula
DEFINE TABLE configurator_product_formula SCHEMAFUL;
DEFINE FIELD productCreator ON configurator_product_formula TYPE record(configurator_creator);

-- 15. TABLE configurator_so_line_formula
DEFINE TABLE configurator_so_line_formula SCHEMAFUL;
DEFINE FIELD updateFromSelect ON configurator_so_line_formula TYPE int DEFAULT 0;
DEFINE FIELD soLineCreator ON configurator_so_line_formula TYPE record(configurator_creator);

-- 16. SÉQUENCES
DEFINE SEQUENCE sale_order_seq START 1 STEP 1;
DEFINE EVENT sale_order_generate_seq ON TABLE sale_order WHEN $event = "CREATE" AND $after.saleOrderSeq = NONE THEN {
  LET $seq = sequence::next("sale_order_seq");
  LET $code = "SO" + string::pad($seq, 5, "0", "left");
  UPDATE $this SET saleOrderSeq = $code;
};

-- Compléments techniques
DEFINE FIELD createdAt ON sale_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON sale_order TYPE datetime DEFAULT time::now();
DEFINE FIELD archived ON sale_order TYPE bool DEFAULT false;

-- Validation
DEFINE FIELD statusSelect ON sale_order TYPE int DEFAULT 1 ASSERT $value >= 1 AND $value <= 5;
DEFINE FIELD discountAmount ON sale_order TYPE decimal(20,10) ASSERT $value >= 0;






-- sale_order -> sale_order_line
DEFINE TABLE has_sale_line SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON has_sale_line TYPE record(sale_order);
DEFINE FIELD out ON has_sale_line TYPE record(sale_order_line);
DEFINE FIELD sequence ON has_sale_line TYPE int;

-- sale_order_line -> taxes
DEFINE TABLE line_has_tax SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON line_has_tax TYPE record(sale_order_line);
DEFINE FIELD out ON line_has_tax TYPE record(tax_line);

-- cart -> cart_line
DEFINE TABLE has_cart_line SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON has_cart_line TYPE record(cart);
DEFINE FIELD out ON has_cart_line TYPE record(cart_line);

-- pack -> pack_line
DEFINE TABLE has_pack_line SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON has_pack_line TYPE record(pack);
DEFINE FIELD out ON has_pack_line TYPE record(pack_line);

-- partner -> customer_catalog
DEFINE TABLE partner_has_catalog SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON partner_has_catalog TYPE record(partner);
DEFINE FIELD out ON partner_has_catalog TYPE record(customer_catalog);

-- sale_order.status.select
DEFINE TABLE sale_order_status_type SCHEMAFUL;
DEFINE FIELD code ON sale_order_status_type TYPE string;
DEFINE FIELD label ON sale_order_status_type TYPE string;
DEFINE INDEX status_code_idx ON sale_order_status_type FIELDS code UNIQUE;

CREATE sale_order_status_type:1 SET code = "DRAFT", label = "Draft quotation";
CREATE sale_order_status_type:2 SET code = "FINALIZED", label = "Finalized quotation";
CREATE sale_order_status_type:3 SET code = "CONFIRMED", label = "Order confirmed";
CREATE sale_order_status_type:4 SET code = "COMPLETED", label = "Order completed";
CREATE sale_order_status_type:5 SET code = "CANCELED", label = "Canceled";

-- line.type.select
DEFINE TABLE line_type_select SCHEMAFUL;
DEFINE FIELD code ON line_type_select TYPE int;
DEFINE FIELD label ON line_type_select TYPE string;
CREATE line_type_select:1 SET code = 0, label = "Normal";
CREATE line_type_select:2 SET code = 1, label = "Title";
CREATE line_type_select:3 SET code = 2, label = "Start of pack";
CREATE line_type_select:4 SET code = 3, label = "End of pack";

-- base.price.list.line.amount.type.select
DEFINE TABLE discount_type_select SCHEMAFUL;
DEFINE FIELD code ON discount_type_select TYPE int;
DEFINE FIELD label ON discount_type_select TYPE string;
CREATE discount_type_select:1 SET code = 0, label = "Percentage";
CREATE discount_type_select:2 SET code = 1, label = "Fixed amount";

-- sale.batch.action.select
DEFINE TABLE batch_action_select SCHEMAFUL;
DEFINE FIELD code ON batch_action_select TYPE int;
DEFINE FIELD label ON batch_action_select TYPE string;
CREATE batch_action_select:1 SET code = 1, label = "Invoicing";

-- cart.order.creation.mode.select
DEFINE TABLE cart_order_creation_mode_select SCHEMAFUL;
DEFINE FIELD code ON cart_order_creation_mode_select TYPE int;
DEFINE FIELD label ON cart_order_creation_mode_select TYPE string;
CREATE cart_order_creation_mode_select:1 SET code = 0, label = "Allow with missing products";
CREATE cart_order_creation_mode_select:2 SET code = 1, label = "Ignore missing products";
CREATE cart_order_creation_mode_select:3 SET code = 2, label = "Block creation";

-- Génération automatique du saleOrderSeq
DEFINE SEQUENCE sale_order_seq START 1 STEP 1;

DEFINE EVENT sale_order_generate_seq ON TABLE sale_order 
WHEN $event = "CREATE" AND $after.saleOrderSeq = NONE THEN {
  LET $seq = sequence::next("sale_order_seq");
  LET $code = "SO" + string::pad($seq, 5, "0", "left");
  UPDATE $this SET saleOrderSeq = $code;
};

-- Génération du fullName de commande
DEFINE EVENT sale_order_fullname ON TABLE sale_order 
WHEN $before.saleOrderSeq != $after.saleOrderSeq THEN {
  LET $full = $after.saleOrderSeq;
  UPDATE $this SET fullName = $full;
};

-- Mise à jour automatique des totaux dans sale_order
DEFINE EVENT sale_order_recalculate_totals ON TABLE has_sale_line 
WHEN $event = "CREATE" OR $event = "DELETE" THEN {
  LET $lines = (SELECT out.price AS price, out.qty AS qty FROM $this.in->has_sale_line->sale_order_line);
  LET $total = math::sum(array::map($lines, (v) => v.price * v.qty));
  UPDATE sale_order:$this.in SET exTaxTotal = $total;
};
