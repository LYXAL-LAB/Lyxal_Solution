-- ============================================================================
-- TABLE : advance_payment - Avancement de paiement
-- ============================================================================

DEFINE TABLE advance_payment SCHEMAFULL
    COMMENT "Acomptes sur commandes de vente";

DEFINE FIELD amount ON advance_payment TYPE decimal;
DEFINE FIELD advance_payment_date ON advance_payment TYPE date;
DEFINE FIELD sale_order_id ON advance_payment TYPE record<sale_order>;
DEFINE FIELD currency_id ON advance_payment TYPE record<currency>;
DEFINE FIELD status_select ON advance_payment TYPE int DEFAULT 0;
DEFINE FIELD created_on ON advance_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON advance_payment TYPE datetime DEFAULT time::now();