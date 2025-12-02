-- ============================================================
-- TABLE: saas_registry
-- DESCRIPTION: Catalogue officiel des modules/applications Lyxal disponibles.
-- ============================================================

DEFINE TABLE saas_registry SCHEMAFULL;

-- CHAMPS
DEFINE FIELD id               ON TABLE saas_registry TYPE string; -- ex: "crm", "erp" (Clé primaire manuelle recommandée)
DEFINE FIELD name             ON TABLE saas_registry TYPE string; -- ex: "Lyxal CRM"
DEFINE FIELD description      ON TABLE saas_registry TYPE string;
DEFINE FIELD category         ON TABLE saas_registry TYPE string; -- ex: "business", "productivity"
DEFINE FIELD version          ON TABLE saas_registry TYPE string DEFAULT "1.0.0";
DEFINE FIELD is_public        ON TABLE saas_registry TYPE bool DEFAULT true; -- Visible dans le marketplace ?

DEFINE FIELD created_at       ON TABLE saas_registry TYPE datetime DEFAULT time::now();

-- TODO: Ajouter gestion pricing/features plus tard

