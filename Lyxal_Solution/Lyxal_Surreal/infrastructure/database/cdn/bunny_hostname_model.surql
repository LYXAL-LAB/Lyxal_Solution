-- Table: bunny_hostname_model
-- Source: HostnameModel
-- Description: Table pour HostnameModel

DEFINE TABLE IF NOT EXISTS bunny_hostname_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour HostnameModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_hostname_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The unique ID of the hostname';

DEFINE FIELD IF NOT EXISTS value ON bunny_hostname_model
  TYPE option<string>
  COMMENT 'The hostname value for the domain name';

DEFINE FIELD IF NOT EXISTS force_s_s_l ON bunny_hostname_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Force SSL feature is enabled';

DEFINE FIELD IF NOT EXISTS is_system_hostname ON bunny_hostname_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if this is a system hostname controlled by bunny.net';

DEFINE FIELD IF NOT EXISTS is_managed_hostname ON bunny_hostname_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if this is a managed hostname controlled by bunny.net';

DEFINE FIELD IF NOT EXISTS has_certificate ON bunny_hostname_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the hostname has an SSL certificate configured';

DEFINE FIELD IF NOT EXISTS certificate ON bunny_hostname_model
  TYPE option<string>
  COMMENT 'Contains the Base64Url encoded certificate for the hostname';

DEFINE FIELD IF NOT EXISTS certificate_key ON bunny_hostname_model
  TYPE option<string>
  COMMENT 'Contains the Base64Url encoded certificate key for the hostname';

DEFINE FIELD IF NOT EXISTS certificate_key_type ON bunny_hostname_model
  TYPE option<string>
  COMMENT 'The private key type to use for automatic certificates';

DEFINE FIELD IF NOT EXISTS certificate_provision_type ON bunny_hostname_model
  TYPE option<string>
  COMMENT 'The provisioned certificate type';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_hostname_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_hostname_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
