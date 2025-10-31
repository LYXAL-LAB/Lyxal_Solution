-- Création d'une app portal avec méthodes de paiement
CREATE app_portal SET
  app = app:1,
  canConfirmOnline = true,
  canPayOnline = true,
  portalSelect = 1,
  manageSaleOrders = true,
  onlinePaymentMethodSet = [online_payment_method:1, online_payment_method:2];
