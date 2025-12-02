-- ============================================================
-- TABLE: application (ANCRE ABSTRAITE)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE application TYPE NORMAL SCHEMAFULL
COMMENT "Ancre d'application (Coquille vide pour lier les registres)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS status ON TABLE application 
    TYPE string
    DEFAULT 'active'
    ASSERT $value INSIDE ['active', 'inactive', 'suspended']
    COMMENT "Statut de l'application";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE application 
    TYPE datetime
    READONLY
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE application 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now();

-- AUCUN INDEX PUBLIC (Sauf ID)
