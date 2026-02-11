-- Table: bunny_billing_saved_payment_method
-- Source: BillingSavedPaymentMethod
-- Description: Table pour BillingSavedPaymentMethod

DEFINE TABLE IF NOT EXISTS bunny_billing_saved_payment_method TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour BillingSavedPaymentMethod';

DEFINE FIELD IF NOT EXISTS token ON bunny_billing_saved_payment_method
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS image_url ON bunny_billing_saved_payment_method
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS expiration_date ON bunny_billing_saved_payment_method
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS last_four ON bunny_billing_saved_payment_method
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS email ON bunny_billing_saved_payment_method
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_billing_saved_payment_method
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_billing_saved_payment_method
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
