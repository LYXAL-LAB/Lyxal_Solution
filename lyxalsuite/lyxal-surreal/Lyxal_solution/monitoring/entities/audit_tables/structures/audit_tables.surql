-- ================================================================================
-- Table de référence des tables auditées
-- ================================================================================
-- DESCRIPTION: Définit toutes les tables qui peuvent être auditées
-- USAGE: Référence pour system_references_audit.table_name
-- ================================================================================

DEFINE TABLE audit_tables SCHEMAFULL;

-- Nom de la table
DEFINE FIELD table_name ON audit_tables TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 100;

-- Module auquel appartient la table
DEFINE FIELD module_name ON audit_tables TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 50;

-- Nom d'affichage
DEFINE FIELD display_name ON audit_tables TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 100;

-- Description de la table
DEFINE FIELD description ON audit_tables TYPE string;

-- Niveau de sensibilité des données (référence vers sensitivity_level)
DEFINE FIELD sensitivity ON audit_tables TYPE <record<sensitivity_level>>;

-- Rétention des logs d'audit (en jours)
DEFINE FIELD audit_retention_days ON audit_tables TYPE int DEFAULT 365
    ASSERT $value >= 30 AND $value <= 2555; -- Min 30 jours, Max 7 ans

-- Audit activé/désactivé
DEFINE FIELD audit_enabled ON audit_tables TYPE bool DEFAULT true;

-- Actions auditées (référence vers audit_actions)
DEFINE FIELD audited_actions ON audit_tables TYPE array<record<audit_actions>> DEFAULT [];

-- Actif/Inactif
DEFINE FIELD is_active ON audit_tables TYPE bool DEFAULT true;

-- Métadonnées
DEFINE FIELD created_at ON audit_tables TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON audit_tables TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_audit_tables_name ON audit_tables COLUMNS table_name UNIQUE;
DEFINE INDEX idx_audit_tables_module ON audit_tables COLUMNS module_name;
DEFINE INDEX idx_audit_tables_sensitivity ON audit_tables COLUMNS sensitivity;
DEFINE INDEX idx_audit_tables_enabled ON audit_tables COLUMNS audit_enabled;
DEFINE INDEX idx_audit_tables_active ON audit_tables COLUMNS is_active;

-- Permissions
PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin';