-- ============================================================
-- TABLE: organization (ANCRE ABSTRAITE)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization TYPE NORMAL SCHEMAFULL
COMMENT "Ancre d'organisation (Coquille vide pour lier les registres)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS status ON TABLE organization 
    TYPE string
    DEFAULT 'active'
    ASSERT $value INSIDE ['active', 'suspended', 'archived']
    COMMENT "Statut de l'organisation";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE organization 
    TYPE datetime
    READONLY
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE organization 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now();

-- AUCUN INDEX PUBLIC (Sauf ID)
