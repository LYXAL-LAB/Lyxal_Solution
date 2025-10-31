-- lyxalbank: TEST FLOW

--  Création de BankDetails
CREATE bank_details SET balance = 12500, balance_updated_date = time::now();

--  Création d’un partenaire
CREATE partner:acme SET name = "ACME Corp";

--  Création d’un mode de paiement
CREATE payment_mode:virement SET name = "Virement", code = "WIRE";

--  Création d’un BankOrder (brouillon)
CREATE bank_order SET
  order_date = time::now(),
  status = "draft",
  amount = 4200,
  company = company:1,
  partner = partner:acme,
  payment_mode = payment_mode:virement;

--  Création d’un relevé bancaire
CREATE bank_statement SET
  name = "RELEVE-2025-001",
  from_date = "2025-01-01",
  to_date = "2025-01-31",
  status_select = 1;

--  Ajout d’une ligne dans le relevé
CREATE bank_statement_line SET
  operation_date = "2025-01-15",
  value_date = "2025-01-15",
  debit = 4200,
  description = "Paiement facture ACME",
  reference = "FAC-2025-045",
  bank_statement = bank_statement:RELEVE-2025-001;

--  Simulation de rapprochement
CREATE bank_reconciliation SET
  name = "RAPPRO-01",
  company = company:1,
  from_date = "2025-01-01",
  to_date = "2025-01-31",
  bank_details = bank_details:1;

CREATE bank_reconciliation_line SET
  name = "Rappro Paiement ACME",
  effect_date = "2025-01-15",
  partner = partner:acme,
  type_select = 2,
  debit = 4200,
  bank_statement_line = bank_statement_line:1,
  bank_reconciliation = bank_reconciliation:RAPPRO-01;
