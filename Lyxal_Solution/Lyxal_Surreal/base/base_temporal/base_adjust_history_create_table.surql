-- =============================================================================
-- MODULE: BASE SOUS MODULE : TEMPORAL
-- TABLE: base_adjust_history (AdjustHistory)
-- Historique des ajustements sur périodes et années
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_adjust_history TYPE NORMAL SCHEMAFULL
COMMENT 'Historique des ajustements sur périodes et années'
PERMISSIONS FULL;

-- Relations
DEFINE FIELD period ON base_adjust_history TYPE option<record<base_period>>
COMMENT 'Période de l\'ajustement';
DEFINE FIELD fiscalYear ON base_adjust_history TYPE option<record<base_year>>
COMMENT 'Année de l\'ajustement';

-- Dates
DEFINE FIELD adjustDate ON base_adjust_history TYPE option<datetime>
COMMENT 'Date de l\'ajustement';
DEFINE FIELD adjustType ON base_adjust_history TYPE option<string>
COMMENT 'Type d\'ajustement';

-- Détails
DEFINE FIELD reason ON base_adjust_history TYPE option<string>
COMMENT 'Raison de l\'ajustement';
DEFINE FIELD user ON base_adjust_history TYPE record<base_user>
COMMENT 'Utilisateur de l\'ajustement';

-- Index
DEFINE INDEX idx_adjust_history_period ON base_adjust_history FIELDS period;
DEFINE INDEX idx_adjust_history_year ON base_adjust_history FIELDS fiscalYear;
DEFINE INDEX idx_adjust_history_date ON base_adjust_history FIELDS adjustDate;
