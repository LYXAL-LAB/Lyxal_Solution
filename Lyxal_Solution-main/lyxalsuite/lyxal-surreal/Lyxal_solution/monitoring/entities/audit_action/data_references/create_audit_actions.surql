-- ================================================================================
-- Création des données de référence pour audit_actions
-- ================================================================================
-- DESCRIPTION: Crée les actions d'audit disponibles dans le système
-- USAGE: Exécuter une seule fois lors de l'initialisation
-- CRÉATEUR: system
-- ================================================================================

-- Actions de données
CREATE audit_actions:create CONTENT {
    code: "CREATE",
    name: "Création",
    description: "Création d'un nouvel enregistrement",
    category: "DATA",
    criticality: "MEDIUM",
    color: "#28a745",
    icon: "plus-circle",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

CREATE audit_actions:update CONTENT {
    code: "UPDATE", 
    name: "Modification",
    description: "Modification d'un enregistrement existant",
    category: "DATA",
    criticality: "MEDIUM",
    color: "#ffc107",
    icon: "edit",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

CREATE audit_actions:delete CONTENT {
    code: "DELETE",
    name: "Suppression",
    description: "Suppression d'un enregistrement",
    category: "DATA", 
    criticality: "HIGH",
    color: "#dc3545",
    icon: "trash",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Actions de statut
CREATE audit_actions:activate CONTENT {
    code: "ACTIVATE",
    name: "Activation",
    description: "Activation d'un enregistrement",
    category: "STATUS",
    criticality: "LOW",
    color: "#20c997",
    icon: "check-circle",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

CREATE audit_actions:deactivate CONTENT {
    code: "DEACTIVATE",
    name: "Désactivation",
    description: "Désactivation d'un enregistrement",
    category: "STATUS",
    criticality: "MEDIUM",
    color: "#6c757d",
    icon: "x-circle",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Actions bulk
CREATE audit_actions:bulk_activate CONTENT {
    code: "BULK_ACTIVATE",
    name: "Activation en lot",
    description: "Activation de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM",
    color: "#17a2b8",
    icon: "check-square",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

CREATE audit_actions:bulk_deactivate CONTENT {
    code: "BULK_DEACTIVATE", 
    name: "Désactivation en lot",
    description: "Désactivation de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM",
    color: "#6f42c1",
    icon: "x-square",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

CREATE audit_actions:bulk_toggle CONTENT {
    code: "BULK_TOGGLE",
    name: "Basculement en lot",
    description: "Basculement de statut de plusieurs enregistrements",
    category: "BULK",
    criticality: "MEDIUM", 
    color: "#fd7e14",
    icon: "shuffle",
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Actions de maintenance
CREATE audit_actions:clean CONTENT {
    code: "CLEAN",
    name: "Nettoyage",
    description: "Nettoyage/purge des données",
    category: "MAINTENANCE",
    criticality: "CRITICAL",
    color: "#e83e8c",
    icon: "trash-2",
    is_active: true,
    created_by: "system",
    updated_by: "system"
}; 