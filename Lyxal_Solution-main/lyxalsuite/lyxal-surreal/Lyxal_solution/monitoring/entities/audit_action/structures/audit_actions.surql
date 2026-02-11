-- ================================================================================
-- Table de référence des actions d'audit
-- ================================================================================
-- DESCRIPTION: Définit toutes les actions possibles pour l'audit
-- USAGE: Référence pour system_references_audit.action
-- ================================================================================

DEFINE TABLE audit_actions SCHEMAFULL;

-- Code unique de l'action
DEFINE FIELD code ON audit_actions TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 50;

-- Nom lisible de l'action
DEFINE FIELD name ON audit_actions TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 100;

-- Description de l'action
DEFINE FIELD description ON audit_actions TYPE string;

-- Catégorie de l'action
DEFINE FIELD category ON audit_actions TYPE string 
    ASSERT $value INSIDE ['DATA', 'STATUS', 'BULK', 'MAINTENANCE'];

-- Niveau de criticité
DEFINE FIELD criticality ON audit_actions TYPE string 
    ASSERT $value INSIDE ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

-- Couleur d'affichage
DEFINE FIELD color ON audit_actions TYPE string 
    ASSERT string::len($value) = 7 AND string::starts_with($value, '#');

-- Icône associée
DEFINE FIELD icon ON audit_actions TYPE string;

-- Actif/Inactif
DEFINE FIELD is_active ON audit_actions TYPE bool DEFAULT true;

-- Métadonnées
DEFINE FIELD created_at ON audit_actions TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON audit_actions TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_audit_actions_code ON audit_actions COLUMNS code UNIQUE;
DEFINE INDEX idx_audit_actions_category ON audit_actions COLUMNS category;
DEFINE INDEX idx_audit_actions_active ON audit_actions COLUMNS is_active;

-- Permissions
PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin';

-- ================================================================================
-- Données de base
-- ================================================================================

-- Actions de données
INSERT INTO audit_actions {
    id: "audit_actions:create",
    code: "CREATE",
    name: "Création",
    description: "Création d'un nouvel enregistrement",
    category: "DATA",
    criticality: "MEDIUM",
    color: "#28a745",
    icon: "plus-circle"
};

INSERT INTO audit_actions {
    id: "audit_actions:update",
    code: "UPDATE", 
    name: "Modification",
    description: "Modification d'un enregistrement existant",
    category: "DATA",
    criticality: "MEDIUM",
    color: "#ffc107",
    icon: "edit"
};

INSERT INTO audit_actions {
    id: "audit_actions:delete",
    code: "DELETE",
    name: "Suppression",
    description: "Suppression d'un enregistrement",
    category: "DATA", 
    criticality: "HIGH",
    color: "#dc3545",
    icon: "trash"
};

-- Actions de statut
INSERT INTO audit_actions {
    id: "audit_actions:activate",
    code: "ACTIVATE",
    name: "Activation",
    description: "Activation d'un enregistrement",
    category: "STATUS",
    criticality: "LOW",
    color: "#20c997",
    icon: "check-circle"
};

INSERT INTO audit_actions {
    id: "audit_actions:deactivate", 
    code: "DEACTIVATE",
    name: "Désactivation",
    description: "Désactivation d'un enregistrement",
    category: "STATUS",
    criticality: "MEDIUM",
    color: "#6c757d",
    icon: "x-circle"
};

-- Actions bulk
INSERT INTO audit_actions {
    id: "audit_actions:bulk_activate",
    code: "BULK_ACTIVATE",
    name: "Activation en lot",
    description: "Activation de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM",
    color: "#17a2b8",
    icon: "check-square"
};

INSERT INTO audit_actions {
    id: "audit_actions:bulk_deactivate",
    code: "BULK_DEACTIVATE", 
    name: "Désactivation en lot",
    description: "Désactivation de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM",
    color: "#6f42c1",
    icon: "x-square"
};

INSERT INTO audit_actions {
    id: "audit_actions:bulk_toggle",
    code: "BULK_TOGGLE",
    name: "Basculement en lot",
    description: "Basculement de statut de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM", 
    color: "#fd7e14",
    icon: "shuffle"
};

-- Actions de maintenance
INSERT INTO audit_actions {
    id: "audit_actions:clean",
    code: "CLEAN",
    name: "Nettoyage",
    description: "Nettoyage/purge des données",
    category: "MAINTENANCE",
    criticality: "CRITICAL",
    color: "#e83e8c",
    icon: "trash-2"
}; 