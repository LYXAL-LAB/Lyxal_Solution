-- Table: bunny_drm_certificate_model
-- Source: DrmCertificateModel
-- Description: Table pour DrmCertificateModel

DEFINE TABLE IF NOT EXISTS bunny_drm_certificate_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour DrmCertificateModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_drm_certificate_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS private_key ON bunny_drm_certificate_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS secret_key ON bunny_drm_certificate_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS certificate ON bunny_drm_certificate_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS provider ON bunny_drm_certificate_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS expiration_date ON bunny_drm_certificate_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS certificate_type ON bunny_drm_certificate_model
  TYPE option<record<certificate_type>>
;

DEFINE FIELD IF NOT EXISTS date_modified ON bunny_drm_certificate_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS date_created ON bunny_drm_certificate_model
  TYPE datetime
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_drm_certificate_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_drm_certificate_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
