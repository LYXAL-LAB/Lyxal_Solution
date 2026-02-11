-- =====================================================
-- NAMESPACE : lyxal_solution
-- DATABASE : main
-- TABLE  : identity_status
-- =====================================================

-- Table des statuts des utilisateurs Lyxal
DEFINE TABLE IF NOT EXISTS identity_status TYPE NORMAL SCHEMAFULL
  COMMENT 'Statuts des utilisateurs Lyxal'
  PERMISSIONS FOR SELECT FULL
  FOR CREATE, UPDATE, DELETE NONE;

-- Informations de base
DEFINE FIELD IF NOT EXISTS code ON identity_status 
  TYPE string
  COMMENT 'Code du statut';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON identity_status 
  TYPE record<i18n_key>
  COMMENT 'Clé i18n pour le libellé du statut';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON identity_status
  TYPE record<i18n_key>
  COMMENT 'Clé i18n pour la description du statut';

DEFINE FIELD IF NOT EXISTS is_active ON identity_status
  TYPE bool
  COMMENT 'Indique si le statut est actif';

DEFINE FIELD IF NOT EXISTS sort_order ON identity_status
  TYPE int
  DEFAULT 0
  COMMENT 'Ordre de tri';

DEFINE FIELD IF NOT EXISTS color ON identity_status
  TYPE string
  COMMENT 'Couleur du statut';

-- Index ESSENTIELS
DEFINE INDEX code_unique ON identity_status 
  FIELDS code UNIQUE;