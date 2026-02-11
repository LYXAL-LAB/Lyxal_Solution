```
-- ============================================================
-- TABLE: identity (ANCRE ABSTRAITE)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE identity TYPE NORMAL SCHEMAFULL
COMMENT "Ancre d'identité (Coquille vide pour lier les registres)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS status ON TABLE identity 
    TYPE record<identity_status>
    DEFAULT identity_status:created
    COMMENT "Statut de l'identité";

-- Métadonnées de traçabilité (Minimales)
DEFINE FIELD IF NOT EXISTS created_at ON TABLE identity 
    TYPE datetime
    READONLY
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE identity 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now();

-- AUCUN INDEX (Pas de recherche directe sur cette table)
```
