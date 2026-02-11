-- ============================================================
-- TABLE: workspace
-- DESCRIPTION: Un espace de travail spécifique au sein d'un tenant.
-- Permet le multi-environnement (Prod/Dev) ou multi-filiale.
-- ============================================================

DEFINE TABLE workspace SCHEMAFULL;

-- CHAMPS
DEFINE FIELD name             ON TABLE workspace TYPE string;
DEFINE FIELD tenant           ON TABLE workspace TYPE record<tenant>; -- Lien parent
DEFINE FIELD slug             ON TABLE workspace TYPE string;         -- Identifiant unique URL-friendly (ex: "marketing")

DEFINE FIELD created_at       ON TABLE workspace TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at       ON TABLE workspace TYPE datetime DEFAULT time::now() VALUE time::now();

-- ROUTAGE SPECIFIQUE (Optionnel)
-- Si vide, utilise le namespace/database du tenant parent.
-- Si rempli, surcharge le routage (ex: Workspace "Dev" sur une autre DB).
DEFINE FIELD target_database  ON TABLE workspace TYPE string;

-- INDEX
DEFINE INDEX idx_tenant_slug ON TABLE workspace COLUMNS tenant, slug UNIQUE;

