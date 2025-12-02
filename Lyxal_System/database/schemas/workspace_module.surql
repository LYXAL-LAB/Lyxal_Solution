-- ============================================================
-- TABLE: workspace_module
-- DESCRIPTION: Active un module SaaS pour un workspace spécifique.
-- Permet de surcharger la configuration du tenant.
-- ============================================================

DEFINE TABLE workspace_module SCHEMAFULL;

-- CHAMPS
DEFINE FIELD workspace        ON TABLE workspace_module TYPE record<workspace>;
DEFINE FIELD module_id        ON TABLE workspace_module TYPE record<saas_registry>; -- Lien fort vers le catalogue
DEFINE FIELD status           ON TABLE workspace_module TYPE string DEFAULT 'active';
DEFINE FIELD activated_at     ON TABLE workspace_module TYPE datetime DEFAULT time::now();

-- INDEX
DEFINE INDEX idx_ws_module ON TABLE workspace_module COLUMNS workspace, module_id UNIQUE;

