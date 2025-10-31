-- Table: bunny_billing_record_model
-- Source: BillingRecordModel
-- Description: Table pour BillingRecordModel

DEFINE TABLE IF NOT EXISTS bunny_billing_record_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour BillingRecordModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_billing_record_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the billing record';

DEFINE FIELD IF NOT EXISTS payment_id ON bunny_billing_record_model
  TYPE option<string>
  COMMENT 'The external ID of the payment';

DEFINE FIELD IF NOT EXISTS amount ON bunny_billing_record_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The amount linked to the record model';

DEFINE FIELD IF NOT EXISTS payer ON bunny_billing_record_model
  TYPE option<string>
  COMMENT 'The payer reference that sent the payment';

DEFINE FIELD IF NOT EXISTS timestamp ON bunny_billing_record_model
  TYPE datetime
  ASSERT $value != NONE
  COMMENT 'The date and time when the billing record was created';

DEFINE FIELD IF NOT EXISTS type ON bunny_billing_record_model
  TYPE option<string>
  COMMENT 'The type of the billing record. PayPal = 0, Crypto = 1, CreditCard = 2, MonthlyUsage = 3, Refund = 4, CouponCode = 5, BankTransfer = 6, AffiliateCredits = 7';

DEFINE FIELD IF NOT EXISTS invoice_available ON bunny_billing_record_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if an invoice is available';

DEFINE FIELD IF NOT EXISTS document_download_url ON bunny_billing_record_model
  TYPE option<string>
  COMMENT 'The URL where the invoice or document can be downloaded. Null if this is not available.';

DEFINE FIELD IF NOT EXISTS detailed_document_download_url ON bunny_billing_record_model
  TYPE option<string>
  COMMENT 'The URL where the document with product usage breakdown can be downloaded. Null if this is not available.';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_billing_record_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_billing_record_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
