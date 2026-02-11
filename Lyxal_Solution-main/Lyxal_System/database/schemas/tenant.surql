-- ============================================================
-- TABLE: tenant
-- DESCRIPTION: Représente un client / une organisation facturée.
-- ============================================================

DEFINE TABLE tenant SCHEMAFULL;

-- CHAMPS
DEFINE FIELD name             ON TABLE tenant TYPE string;
DEFINE FIELD status           ON TABLE tenant TYPE string DEFAULT 'active' ASSERT $value INSIDE ['active', 'suspended', 'archived'];
DEFINE FIELD plan             ON TABLE tenant TYPE string DEFAULT 'free'; 
DEFINE FIELD created_at       ON TABLE tenant TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at       ON TABLE tenant TYPE datetime DEFAULT time::now() VALUE time::now();

-- INFO TECHNIQUE POUR LE ROUTAGE (Typage Fort)
-- Quel Namespace SurrealDB ce tenant utilise-t-il ?
DEFINE FIELD target_namespace ON TABLE tenant TYPE record<namespace_registry>;

-- Quelle Database SurrealDB ce tenant utilise-t-il par défaut ?
DEFINE FIELD target_database  ON TABLE tenant TYPE record<database_registry>;

-- INDEX
DEFINE INDEX idx_target_ns_db ON TABLE tenant COLUMNS target_namespace, target_database UNIQUE;
