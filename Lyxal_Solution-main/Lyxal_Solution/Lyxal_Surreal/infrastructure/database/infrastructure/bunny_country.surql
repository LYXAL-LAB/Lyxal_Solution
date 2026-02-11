-- ============================================================================
-- BUNNY COUNTRY - Liste des Pays Disponibles
-- ============================================================================
-- Description : Table de référence des pays supportés par Bunny.net
-- Source      : API Bunny.net /country
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_country
-- ============================================================================
-- Description : Pays disponibles sur Bunny.net avec infos fiscales et prix
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_country TYPE NORMAL SCHEMAFULL
  COMMENT 'Pays disponibles sur Bunny.net';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS iso_code ON bunny_country
  TYPE string
  ASSERT $value != NONE AND string::len($value) == 2
  COMMENT 'Code ISO pays (2 lettres, ex: FR, US, DE)';

DEFINE FIELD IF NOT EXISTS name ON bunny_country
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Nom du pays (ex: France, United States)';

-- Informations EU

DEFINE FIELD IF NOT EXISTS is_eu ON bunny_country
  TYPE bool
  DEFAULT false
  COMMENT 'Pays membre de l\'Union Européenne';

-- Informations fiscales

DEFINE FIELD IF NOT EXISTS tax_rate ON bunny_country
  TYPE float
  COMMENT 'Taux de taxe (%)';

DEFINE FIELD IF NOT EXISTS tax_prefix ON bunny_country
  TYPE option<string>
  COMMENT 'Préfixe taxe (ex: VAT pour Europe)';

-- Visuel

DEFINE FIELD IF NOT EXISTS flag_url ON bunny_country
  TYPE option<string>
  COMMENT 'URL du drapeau du pays';

-- Points de Présence (PoP)

DEFINE FIELD IF NOT EXISTS pop_list ON bunny_country
  TYPE option<array<string>>
  COMMENT 'Liste des PoP (Points of Presence) disponibles dans ce pays';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_country
  TYPE object
  COMMENT 'Métadonnées de synchronisation';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_country
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de dernière synchronisation';

-- Index

DEFINE INDEX IF NOT EXISTS iso_code_unique ON bunny_country
  FIELDS iso_code UNIQUE;

DEFINE INDEX IF NOT EXISTS name_idx ON bunny_country
  FIELDS name;

DEFINE INDEX IF NOT EXISTS is_eu_idx ON bunny_country
  FIELDS is_eu;


-- ============================================================================
-- EXEMPLE DE DONNÉES (Structure API Bunny.net)
-- ============================================================================

-- {
--   "IsoCode": "FR",
--   "Name": "France",
--   "IsEU": true,
--   "TaxRate": 20.0,
--   "TaxPrefix": "FR",
--   "FlagUrl": "https://bunnycdn.b-cdn.net/assets/dashboard/images/flags/fr.png",
--   "PopList": ["FR", "MS"]
-- }

