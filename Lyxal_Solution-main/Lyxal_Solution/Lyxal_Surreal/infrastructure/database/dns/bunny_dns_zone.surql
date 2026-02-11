-- ============================================================================
-- BUNNY DNS ZONE - Zone DNS
-- ============================================================================
-- Description : Table miroir de l'API Bunny.net pour les zones DNS
-- API Docs    : https://docs.bunny.net/reference/dnszonepublic_index2
-- Version     : 2.0.0
-- Date        : 2025-10-25
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_dns_zone
-- ============================================================================
-- Description : Zones DNS - Miroir exact de l'API Bunny.net
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_dns_zone TYPE NORMAL SCHEMAFULL
  COMMENT 'Zones DNS Bunny.net (miroir API)';

-- Champs API Bunny.net (structure exacte)

DEFINE FIELD IF NOT EXISTS bunny_id ON bunny_dns_zone
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Id - ID unique Bunny.net de la zone DNS';

DEFINE FIELD IF NOT EXISTS domain ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Domain - Nom de domaine (ex: lyxal.com)';

-- Nameservers

DEFINE FIELD IF NOT EXISTS nameservers_detected ON bunny_dns_zone
  TYPE bool
  DEFAULT false
  COMMENT 'NameserversDetected - Détection automatique des nameservers';

DEFINE FIELD IF NOT EXISTS custom_nameservers_enabled ON bunny_dns_zone
  TYPE bool
  DEFAULT false
  COMMENT 'CustomNameserversEnabled - Utilisation de nameservers personnalisés';

DEFINE FIELD IF NOT EXISTS nameserver1 ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Nameserver1 - Premier nameserver (ex: kiki.bunny.net)';

DEFINE FIELD IF NOT EXISTS nameserver2 ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Nameserver2 - Second nameserver (ex: coco.bunny.net)';

DEFINE FIELD IF NOT EXISTS nameservers_next_check ON bunny_dns_zone
  TYPE datetime
  COMMENT 'NameserversNextCheck - Prochaine vérification des nameservers';

-- SOA (Start of Authority)

DEFINE FIELD IF NOT EXISTS soa_email ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'SoaEmail - Email admin du SOA (ex: hostmaster@bunny.net)';

-- Logging

DEFINE FIELD IF NOT EXISTS logging_enabled ON bunny_dns_zone
  TYPE bool
  DEFAULT false
  COMMENT 'LoggingEnabled - Logs DNS activés';

DEFINE FIELD IF NOT EXISTS logging_ip_anonymization_enabled ON bunny_dns_zone
  TYPE bool
  DEFAULT true
  COMMENT 'LoggingIPAnonymizationEnabled - Anonymisation des IP dans les logs';

DEFINE FIELD IF NOT EXISTS log_anonymization_type ON bunny_dns_zone
  TYPE option<string>
  ASSERT $value == NONE OR $value INSIDE ['OneDigit', 'Drop']
  COMMENT 'LogAnonymizationType - Type d\'anonymisation (OneDigit, Drop)';

-- DNSSEC

DEFINE FIELD IF NOT EXISTS dnssec_enabled ON bunny_dns_zone
  TYPE bool
  DEFAULT false
  COMMENT 'DnsSecEnabled - DNSSEC activé sur cette zone';

DEFINE FIELD IF NOT EXISTS dnssec_config ON bunny_dns_zone
  TYPE option<object>
  COMMENT 'DnsSecConfig - Configuration DNSSEC complète';

DEFINE FIELD IF NOT EXISTS dnssec_config.enabled ON bunny_dns_zone
  TYPE option<bool>
  COMMENT 'DNSSEC enabled status';

DEFINE FIELD IF NOT EXISTS dnssec_config.ds_record ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'DS Record - Delegation Signer record';

DEFINE FIELD IF NOT EXISTS dnssec_config.digest ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Digest - Hash du DS record';

DEFINE FIELD IF NOT EXISTS dnssec_config.digest_type ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Digest Type - Type d\'algorithme de hash';

DEFINE FIELD IF NOT EXISTS dnssec_config.algorithm ON bunny_dns_zone
  TYPE option<int>
  COMMENT 'Algorithm - Algorithme de signature DNSSEC';

DEFINE FIELD IF NOT EXISTS dnssec_config.public_key ON bunny_dns_zone
  TYPE option<string>
  COMMENT 'Public Key - Clé publique DNSSEC';

DEFINE FIELD IF NOT EXISTS dnssec_config.key_tag ON bunny_dns_zone
  TYPE option<int>
  COMMENT 'Key Tag - Identifiant de la clé';

DEFINE FIELD IF NOT EXISTS dnssec_config.flags ON bunny_dns_zone
  TYPE option<int>
  COMMENT 'Flags - Flags de configuration DNSSEC';

DEFINE FIELD IF NOT EXISTS dnssec_config.ds_configured ON bunny_dns_zone
  TYPE option<bool>
  COMMENT 'DS Configured - Indique si DS est configuré';

-- Certificat SSL

DEFINE FIELD IF NOT EXISTS certificate_key_type ON bunny_dns_zone
  TYPE string
  ASSERT $value INSIDE ['Ecdsa', 'Rsa']
  DEFAULT 'Ecdsa'
  COMMENT 'CertificateKeyType - Type de clé SSL (Ecdsa, Rsa)';

-- Dates (format API Bunny)

DEFINE FIELD IF NOT EXISTS date_created ON bunny_dns_zone
  TYPE datetime
  COMMENT 'DateCreated - Date de création sur Bunny.net';

DEFINE FIELD IF NOT EXISTS date_modified ON bunny_dns_zone
  TYPE datetime
  COMMENT 'DateModified - Dernière modification sur Bunny.net';

-- Métadonnées locales (ajout Lyxal)

DEFINE FIELD IF NOT EXISTS metadata ON bunny_dns_zone
  TYPE object
  COMMENT 'Métadonnées locales (hors API Bunny)';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_dns_zone
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation depuis l\'API';

DEFINE FIELD IF NOT EXISTS metadata.tenant ON bunny_dns_zone
  TYPE option<record<tenant>>
  COMMENT 'Tenant propriétaire (multi-tenant Lyxal)';

DEFINE FIELD IF NOT EXISTS metadata.status ON bunny_dns_zone
  TYPE string
  ASSERT $value INSIDE ['active', 'suspended', 'deleted']
  DEFAULT 'active'
  COMMENT 'Statut local (active, suspended, deleted)';

-- Index

DEFINE INDEX IF NOT EXISTS bunny_id_unique ON bunny_dns_zone
  FIELDS bunny_id UNIQUE;

DEFINE INDEX IF NOT EXISTS domain_idx ON bunny_dns_zone
  FIELDS domain;

DEFINE INDEX IF NOT EXISTS tenant_idx ON bunny_dns_zone
  FIELDS metadata.tenant;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_dns_zone
  FIELDS metadata.status;


-- ============================================================================
-- NOTES
-- ============================================================================

-- Enum LogAnonymizationType:
-- - OneDigit (0) : Anonymisation partielle (dernier octet)
-- - Drop (1) : Suppression complète de l'IP

-- Enum CertificateKeyType:
-- - Ecdsa (0) : Clé ECDSA (recommandé, plus performant)
-- - Rsa (1) : Clé RSA (compatibilité legacy)

