-- ======================================================================
-- TABLE : TASK_STATUS
-- ======================================================================
DEFINE TABLE task_status SCHEMAFULL
    COMMENT "Statut de tâche";

-- Champs principaux
DEFINE FIELD id ON task_status TYPE record<task_status>;
DEFINE FIELD created_on ON task_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON task_status TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON task_status TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON task_status TYPE string;
DEFINE FIELD sequence ON task_status TYPE int DEFAULT 0;

-- Configuration statut
DEFINE FIELD is_completed_status ON task_status TYPE bool DEFAULT false;

-- Couleur
DEFINE FIELD color ON task_status TYPE string;

-- Index
DEFINE INDEX idx_task_status_name ON task_status COLUMNS name UNIQUE;
DEFINE INDEX idx_task_status_sequence ON task_status COLUMNS sequence;
