-- ============================================================
-- FICHIER: infrastructure_registry.surql
-- Contient les tables de gestion de l'infrastructure physique SurrealDB.
-- ============================================================

-- 1. TABLE: namespace_registry
-- Liste des namespaces physiques créés sur le cluster.
DEFINE TABLE namespace_registry SCHEMAFULL;

DEFINE FIELD id           ON TABLE namespace_registry TYPE string; -- ex: "LYXAL_CRM"
DEFINE FIELD description  ON TABLE namespace_registry TYPE string;
DEFINE FIELD region       ON TABLE namespace_registry TYPE string DEFAULT "eu-west";
DEFINE FIELD created_at   ON TABLE namespace_registry TYPE datetime DEFAULT time::now();


-- 2. TABLE: database_registry
-- Liste des bases de données physiques.
DEFINE TABLE database_registry SCHEMAFULL;

DEFINE FIELD id           ON TABLE database_registry TYPE string; -- ex: "client_432"
DEFINE FIELD namespace    ON TABLE database_registry TYPE record<namespace_registry>; -- Lien vers le NS parent
DEFINE FIELD description  ON TABLE database_registry TYPE string;
DEFINE FIELD status       ON TABLE database_registry TYPE string DEFAULT "active"; -- active, maintenance, archived

DEFINE FIELD created_at   ON TABLE database_registry TYPE datetime DEFAULT time::now();

