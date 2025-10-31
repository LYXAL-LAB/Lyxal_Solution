-- ================================================================================
-- Création des données de référence pour audit_tables
-- ================================================================================
-- DESCRIPTION: Crée les configurations d'audit pour les tables system_references
-- USAGE: Exécuter une seule fois lors de l'initialisation
-- CRÉATEUR: system
-- ================================================================================

-- Configuration audit pour severity_level
CREATE audit_tables:severity_level CONTENT {
    table_name: "severity_level",
    module_name: "system_references",
    display_name: "Niveaux de Gravité",
    description: "Table des niveaux de gravité globaux du système",
    sensitivity: sensitivity_level:internal,
    audit_retention_days: 1095, -- 3 ans
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete, audit_actions:activate, audit_actions:deactivate, audit_actions:bulk_activate, audit_actions:bulk_deactivate, audit_actions:bulk_toggle, audit_actions:clean],
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Configuration audit pour sensitivity_level
CREATE audit_tables:sensitivity_level CONTENT {
    table_name: "sensitivity_level",
    module_name: "system_references",
    display_name: "Niveaux de Sensibilité",
    description: "Table des niveaux de sensibilité des données",
    sensitivity: sensitivity_level:confidential,
    audit_retention_days: 2555, -- 7 ans (très important)
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete, audit_actions:activate, audit_actions:deactivate],
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Configuration audit pour alert_status
CREATE audit_tables:alert_status CONTENT {
    table_name: "alert_status", 
    module_name: "system_references",
    display_name: "Statuts d'Alerte",
    description: "Table des statuts d'alerte disponibles",
    sensitivity: sensitivity_level:internal,
    audit_retention_days: 730, -- 2 ans
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete, audit_actions:activate, audit_actions:deactivate],
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Configuration audit pour ticket_priority
CREATE audit_tables:ticket_priority CONTENT {
    table_name: "ticket_priority",
    module_name: "system_references", 
    display_name: "Priorités de Ticket",
    description: "Table des priorités de tickets",
    sensitivity: sensitivity_level:internal,
    audit_retention_days: 730, -- 2 ans
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete, audit_actions:activate, audit_actions:deactivate],
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Configuration audit pour source_type
CREATE audit_tables:source_type CONTENT {
    table_name: "source_type",
    module_name: "system_references",
    display_name: "Types de Source", 
    description: "Table des types de source de données",
    sensitivity: sensitivity_level:public,
    audit_retention_days: 365, -- 1 an
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete],
    is_active: true,
    created_by: "system",
    updated_by: "system"
};

-- Configuration audit pour document_status
CREATE audit_tables:document_status CONTENT {
    table_name: "document_status",
    module_name: "system_references",
    display_name: "Statuts de Document",
    description: "Table des statuts de documents",
    sensitivity: sensitivity_level:internal,
    audit_retention_days: 1095, -- 3 ans
    audit_enabled: true,
    audited_actions: [audit_actions:create, audit_actions:update, audit_actions:delete, audit_actions:activate, audit_actions:deactivate],
    is_active: true,
    created_by: "system",
    updated_by: "system"
}; 