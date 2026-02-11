-- ============================================================
-- TABLE: identity_status (Référentiel)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE TABLE IF NOT EXISTS identity_status TYPE NORMAL SCHEMAFULL
    COMMENT "Statuts des identités"
    PERMISSIONS 
    FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS
DEFINE FIELD IF NOT EXISTS label ON TABLE identity_status 
    TYPE string
    COMMENT "Libellé du statut";

DEFINE FIELD IF NOT EXISTS code ON TABLE identity_status 
    TYPE string
    COMMENT "Code du statut";

DEFINE FIELD IF NOT EXISTS description ON TABLE identity_status 
    TYPE string
    COMMENT "Description du statut";

-- DONNÉES INITIALES (SEED)
-- On utilise UPSERT ou INSERT IGNORE pour garantir la présence des statuts
UPSERT identity_status:created CONTENT {
    label: "Created",
    description: "Compte créé, email non vérifié"
};

UPSERT identity_status:active CONTENT {
    label: "Active",
    description: "Compte actif et vérifié"
};

UPSERT identity_status:suspended CONTENT {
    label: "Suspended",
    description: "Compte suspendu (sécurité ou paiement)"
};

UPSERT identity_status:archived CONTENT {
    label: "Archived",
    description: "Compte supprimé logiquement (soft delete)"
};