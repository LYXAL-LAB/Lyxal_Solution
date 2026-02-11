DEFINE TABLE app_portal SCHEMAFUL;
DEFINE FIELD app ON app_portal TYPE record<app> ASSERT $value != NONE;
DEFINE FIELD manageSaleOrders ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD manageInvoices ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD manageTickets ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD manageProjects ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD manageDelivery ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD canConfirmOnline ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD showCatalog ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD canPayOnline ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD portalSelect ON app_portal TYPE int DEFAULT 1;
DEFINE FIELD onlinePaymentMethodSet ON app_portal TYPE array<record<online_payment_method>>;

DEFINE TABLE online_payment_method SCHEMAFUL;
DEFINE FIELD name ON online_payment_method TYPE string ASSERT $value != NULL;
DEFINE FIELD code ON online_payment_method TYPE string ASSERT $value != NULL;
