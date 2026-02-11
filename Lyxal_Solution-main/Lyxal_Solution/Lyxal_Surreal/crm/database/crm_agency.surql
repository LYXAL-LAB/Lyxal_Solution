DEFINE TABLE IF NOT EXISTS crm_agency TYPE NORMAL SCHEMAFULL
    COMMENT 'Agences du module CRM'
    PERMISSIONS FULL;

  -- ==================================
  -- DÉFINITION DES CHAMPS
  -- ==================================
  DEFINE FIELD name ON TABLE crm_agency TYPE string;

  DEFINE FIELD created_at ON TABLE crm_agency TYPE datetime;
  DEFINE FIELD updated_at ON TABLE crm_agency TYPE datetime;

  -- ==================================
  -- INDEX
  -- ==================================
  DEFINE INDEX idx_crm_agency_name ON crm_agency FIELDS name;