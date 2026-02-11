// referenceSaleData.ts
export const SALE_REFERENCE_DATA = `
  CREATE sale_order_status_type:1 SET code = "DRAFT", label = "Draft quotation";
  CREATE sale_order_status_type:2 SET code = "FINALIZED", label = "Finalized quotation";
  CREATE sale_order_status_type:3 SET code = "CONFIRMED", label = "Order confirmed";
  CREATE sale_order_status_type:4 SET code = "COMPLETED", label = "Order completed";
  CREATE sale_order_status_type:5 SET code = "CANCELED", label = "Canceled";

  CREATE line_type_select:1 SET code = 0, label = "Normal";
  CREATE line_type_select:2 SET code = 1, label = "Title";
  CREATE line_type_select:3 SET code = 2, label = "Start of pack";
  CREATE line_type_select:4 SET code = 3, label = "End of pack";

  CREATE discount_type_select:1 SET code = 0, label = "Percentage";
  CREATE discount_type_select:2 SET code = 1, label = "Fixed amount";

  CREATE batch_action_select:1 SET code = 1, label = "Invoicing";

  CREATE cart_order_creation_mode_select:1 SET code = 0, label = "Allow with missing products";
  CREATE cart_order_creation_mode_select:2 SET code = 1, label = "Ignore missing products";
  CREATE cart_order_creation_mode_select:3 SET code = 2, label = "Block creation";

  CREATE sequence_counter:sale_order SET
  name = "sale_order",
  prefix = "SO",
  padding = 5,
  nextNumber = 1;
`;
