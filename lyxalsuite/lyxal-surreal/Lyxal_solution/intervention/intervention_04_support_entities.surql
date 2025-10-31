 /*
 * LYXAL SUITE - Module Intervention Support Entities
 * Migration depuis axelor-intervention vers SurrealDB
 * 
 * Ce module contient les entités de support pour le système d'intervention :
 * - InterventionType (types d'intervention)
 * - InterventionCategory (catégories d'intervention)
 * - InterventionNote (notes d'intervention)
 * - InterventionNoteType (types de notes)
 * - RequestSource (sources de demande)
 * - RequestSubject (sujets de demande)
 * - Justification (justifications)
 * - ReschedulingReason (raisons de reprogrammation)
 * - Contract (contrats)
 * - ContractTemplate (modèles de contrats)
 * - Duration (durées)
 * - Batch (lots de traitement)
 * - InterventionBatch (lots d'intervention)
 * 
 * Fonctionnalités :
 * - Classification des interventions
 * - Gestion des contrats
 * - Système de notes
 * - Traitements par lots
 * - Références métier
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: intervention_type
-- Types d'intervention
-- =============================================
DEFINE TABLE intervention_type SCHEMAFULL;

DEFINE FIELD code ON intervention_type TYPE string;
DEFINE FIELD name ON intervention_type TYPE string;
DEFINE FIELD description ON intervention_type TYPE option<string>;
DEFINE FIELD color ON intervention_type TYPE option<string>;
DEFINE FIELD duration_estimate ON intervention_type TYPE option<duration>;
DEFINE FIELD is_active ON intervention_type TYPE bool DEFAULT true;
DEFINE FIELD requires_signature ON intervention_type TYPE bool DEFAULT false;
DEFINE FIELD requires_photo ON intervention_type TYPE bool DEFAULT false;
DEFINE FIELD planning_preference_select ON intervention_type TYPE option<int>;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_type TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_type TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_type TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_type TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON intervention_type ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON intervention_type ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_intervention_type_code ON intervention_type FIELDS code UNIQUE;
DEFINE INDEX idx_intervention_type_active ON intervention_type FIELDS is_active;

-- =============================================
-- TABLE: intervention_category
-- Catégories d'intervention
-- =============================================
DEFINE TABLE intervention_category SCHEMAFULL;

DEFINE FIELD code ON intervention_category TYPE string;
DEFINE FIELD name ON intervention_category TYPE string;
DEFINE FIELD description ON intervention_category TYPE option<string>;
DEFINE FIELD is_active ON intervention_category TYPE bool DEFAULT true;
DEFINE FIELD parent_category ON intervention_category TYPE option<record<intervention_category>>;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_category TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_category TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_category TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_category TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_category TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON intervention_category ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON intervention_category ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_intervention_category_code ON intervention_category FIELDS code UNIQUE;
DEFINE INDEX idx_intervention_category_parent ON intervention_category FIELDS parent_category;

-- =============================================
-- TABLE: intervention_note_type
-- Types de notes d'intervention
-- =============================================
DEFINE TABLE intervention_note_type SCHEMAFULL;

DEFINE FIELD code ON intervention_note_type TYPE string;
DEFINE FIELD name ON intervention_note_type TYPE string;
DEFINE FIELD description ON intervention_note_type TYPE option<string>;
DEFINE FIELD is_active ON intervention_note_type TYPE bool DEFAULT true;
DEFINE FIELD color ON intervention_note_type TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_note_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_note_type TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_note_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_note_type TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_note_type TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_note_type TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON intervention_note_type ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON intervention_note_type ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_intervention_note_type_code ON intervention_note_type FIELDS code UNIQUE;

-- =============================================
-- TABLE: intervention_note
-- Notes d'intervention
-- =============================================
DEFINE TABLE intervention_note SCHEMAFULL;

DEFINE FIELD intervention ON intervention_note TYPE record<intervention>;
DEFINE FIELD note_type ON intervention_note TYPE record<intervention_note_type>;
DEFINE FIELD title ON intervention_note TYPE string;
DEFINE FIELD content ON intervention_note TYPE string;
DEFINE FIELD is_private ON intervention_note TYPE bool DEFAULT false;
DEFINE FIELD created_by_user ON intervention_note TYPE record<user>;
DEFINE FIELD note_date ON intervention_note TYPE datetime DEFAULT time::now();

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_note TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_note TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_note TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_note TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_note TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_note TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD intervention ON intervention_note ASSERT $value != NONE;
DEFINE FIELD note_type ON intervention_note ASSERT $value != NONE;
DEFINE FIELD title ON intervention_note ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD content ON intervention_note ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD created_by_user ON intervention_note ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_intervention_note_intervention ON intervention_note FIELDS intervention;
DEFINE INDEX idx_intervention_note_type ON intervention_note FIELDS note_type;
DEFINE INDEX idx_intervention_note_date ON intervention_note FIELDS note_date;

-- =============================================
-- TABLE: request_source
-- Sources de demande
-- =============================================
DEFINE TABLE request_source SCHEMAFULL;

DEFINE FIELD code ON request_source TYPE string;
DEFINE FIELD name ON request_source TYPE string;
DEFINE FIELD description ON request_source TYPE option<string>;
DEFINE FIELD is_active ON request_source TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON request_source TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON request_source TYPE option<record<user>>;
DEFINE FIELD updated_on ON request_source TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON request_source TYPE option<record<user>>;
DEFINE FIELD archived ON request_source TYPE bool DEFAULT false;
DEFINE FIELD version ON request_source TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON request_source ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON request_source ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_request_source_code ON request_source FIELDS code UNIQUE;

-- =============================================
-- TABLE: request_subject
-- Sujets de demande
-- =============================================
DEFINE TABLE request_subject SCHEMAFULL;

DEFINE FIELD code ON request_subject TYPE string;
DEFINE FIELD name ON request_subject TYPE string;
DEFINE FIELD description ON request_subject TYPE option<string>;
DEFINE FIELD is_active ON request_subject TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON request_subject TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON request_subject TYPE option<record<user>>;
DEFINE FIELD updated_on ON request_subject TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON request_subject TYPE option<record<user>>;
DEFINE FIELD archived ON request_subject TYPE bool DEFAULT false;
DEFINE FIELD version ON request_subject TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON request_subject ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON request_subject ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_request_subject_code ON request_subject FIELDS code UNIQUE;

-- =============================================
-- TABLE: justification
-- Justifications
-- =============================================
DEFINE TABLE justification SCHEMAFULL;

DEFINE FIELD code ON justification TYPE string;
DEFINE FIELD name ON justification TYPE string;
DEFINE FIELD description ON justification TYPE option<string>;
DEFINE FIELD is_active ON justification TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON justification TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON justification TYPE option<record<user>>;
DEFINE FIELD updated_on ON justification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON justification TYPE option<record<user>>;
DEFINE FIELD archived ON justification TYPE bool DEFAULT false;
DEFINE FIELD version ON justification TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON justification ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON justification ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_justification_code ON justification FIELDS code UNIQUE;

-- =============================================
-- TABLE: rescheduling_reason
-- Raisons de reprogrammation
-- =============================================
DEFINE TABLE rescheduling_reason SCHEMAFULL;

DEFINE FIELD code ON rescheduling_reason TYPE string;
DEFINE FIELD name ON rescheduling_reason TYPE string;
DEFINE FIELD description ON rescheduling_reason TYPE option<string>;
DEFINE FIELD is_active ON rescheduling_reason TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON rescheduling_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON rescheduling_reason TYPE option<record<user>>;
DEFINE FIELD updated_on ON rescheduling_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON rescheduling_reason TYPE option<record<user>>;
DEFINE FIELD archived ON rescheduling_reason TYPE bool DEFAULT false;
DEFINE FIELD version ON rescheduling_reason TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON rescheduling_reason ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON rescheduling_reason ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_rescheduling_reason_code ON rescheduling_reason FIELDS code UNIQUE;

-- =============================================
-- TABLE: contract_template
-- Modèles de contrats
-- =============================================
DEFINE TABLE contract_template SCHEMAFULL;

DEFINE FIELD code ON contract_template TYPE string;
DEFINE FIELD name ON contract_template TYPE string;
DEFINE FIELD description ON contract_template TYPE option<string>;
DEFINE FIELD template_content ON contract_template TYPE option<string>;
DEFINE FIELD is_active ON contract_template TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON contract_template TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON contract_template TYPE option<record<user>>;
DEFINE FIELD updated_on ON contract_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON contract_template TYPE option<record<user>>;
DEFINE FIELD archived ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD version ON contract_template TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON contract_template ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON contract_template ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_contract_template_code ON contract_template FIELDS code UNIQUE;

-- =============================================
-- TABLE: duration
-- Durées système
-- =============================================
DEFINE TABLE duration SCHEMAFULL;

DEFINE FIELD code ON duration TYPE string;
DEFINE FIELD name ON duration TYPE string;
DEFINE FIELD duration_value ON duration TYPE duration;
DEFINE FIELD description ON duration TYPE option<string>;
DEFINE FIELD is_active ON duration TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON duration TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON duration TYPE option<record<user>>;
DEFINE FIELD updated_on ON duration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON duration TYPE option<record<user>>;
DEFINE FIELD archived ON duration TYPE bool DEFAULT false;
DEFINE FIELD version ON duration TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON duration ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON duration ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD duration_value ON duration ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_duration_code ON duration FIELDS code UNIQUE;

-- =============================================
-- TABLE: intervention_batch
-- Lots de traitement d'intervention
-- =============================================
DEFINE TABLE intervention_batch SCHEMAFULL;

DEFINE FIELD code ON intervention_batch TYPE string;
DEFINE FIELD name ON intervention_batch TYPE string;
DEFINE FIELD description ON intervention_batch TYPE option<string>;
DEFINE FIELD status_select ON intervention_batch TYPE int DEFAULT 10;
DEFINE FIELD batch_type ON intervention_batch TYPE string;
DEFINE FIELD company ON intervention_batch TYPE record<company>;
DEFINE FIELD start_date ON intervention_batch TYPE option<datetime>;
DEFINE FIELD end_date ON intervention_batch TYPE option<datetime>;
DEFINE FIELD total_records ON intervention_batch TYPE int DEFAULT 0;
DEFINE FIELD processed_records ON intervention_batch TYPE int DEFAULT 0;
DEFINE FIELD error_records ON intervention_batch TYPE int DEFAULT 0;
DEFINE FIELD success_records ON intervention_batch TYPE int DEFAULT 0;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_batch TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_batch TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_batch TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_batch TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON intervention_batch ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON intervention_batch ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD batch_type ON intervention_batch ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD company ON intervention_batch ASSERT $value != NONE;
DEFINE FIELD status_select ON intervention_batch ASSERT $value IN [10, 20, 30, 40, 50];

-- Index d'optimisation
DEFINE INDEX idx_intervention_batch_code ON intervention_batch FIELDS code UNIQUE;
DEFINE INDEX idx_intervention_batch_company ON intervention_batch FIELDS company;
DEFINE INDEX idx_intervention_batch_status ON intervention_batch FIELDS status_select;
DEFINE INDEX idx_intervention_batch_type ON intervention_batch FIELDS batch_type;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_intervention_note ON TABLE intervention_note WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_intervention_batch ON TABLE intervention_batch WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- Événement : Calcul automatique du pourcentage de traitement pour les lots
DEFINE EVENT intervention_batch_progress ON TABLE intervention_batch WHEN $event = "UPDATE" THEN {
    IF $after.total_records > 0 {
        LET $progress = ($after.processed_records * 100) / $after.total_records;
        -- Mise à jour du statut basé sur le progrès
        IF $progress >= 100 AND $after.status_select = 20 {
            UPDATE $after.id SET status_select = 30; -- Terminé
        }
    }
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Statuts des lots d'intervention
INSERT INTO lyxal_constants (
    id: constants:intervention_batch_status,
    category: 'intervention_batch_status',
    values: {
        DRAFT: 10,
        RUNNING: 20,
        COMPLETED: 30,
        ERROR: 40,
        CANCELLED: 50
    }
);

-- Types de lots d'intervention
INSERT INTO lyxal_constants (
    id: constants:intervention_batch_type,
    category: 'intervention_batch_type',
    values: {
        IMPORT: 'import',
        EXPORT: 'export',
        NOTIFICATION: 'notification',
        CLEANUP: 'cleanup',
        SYNCHRONIZATION: 'synchronization'
    }
);

-- Préférences de planification
INSERT INTO lyxal_constants (
    id: constants:planning_preference,
    category: 'planning_preference',
    values: {
        MORNING: 1,
        AFTERNOON: 2,
        EVENING: 3,
        NIGHT: 4,
        FLEXIBLE: 5
    }
);

-- Sources de demande par défaut
INSERT INTO request_source (
    id: request_source:phone,
    code: 'PHONE',
    name: 'Téléphone',
    description: 'Demande reçue par téléphone'
);

INSERT INTO request_source (
    id: request_source:email,
    code: 'EMAIL',
    name: 'Email',
    description: 'Demande reçue par email'
);

INSERT INTO request_source (
    id: request_source:web,
    code: 'WEB',
    name: 'Site Web',
    description: 'Demande reçue via le site web'
);

INSERT INTO request_source (
    id: request_source:mobile,
    code: 'MOBILE',
    name: 'Application Mobile',
    description: 'Demande reçue via l\'application mobile'
);

/*
 * RÉSUMÉ DU MODULE INTERVENTION SUPPORT ENTITIES
 * 
 * Tables créées : 12
 * - intervention_type : Types d'intervention
 * - intervention_category : Catégories d'intervention
 * - intervention_note_type : Types de notes
 * - intervention_note : Notes d'intervention
 * - request_source : Sources de demande
 * - request_subject : Sujets de demande
 * - justification : Justifications
 * - rescheduling_reason : Raisons de reprogrammation
 * - contract_template : Modèles de contrats
 * - duration : Durées système
 * - intervention_batch : Lots de traitement
 * 
 * Fonctionnalités :
 * - Classification complète des interventions
 * - Système de notes avancé
 * - Gestion des demandes structurée
 * - Traitement par lots
 * - Modèles de contrats
 * - Durées prédéfinies
 * - Justifications et raisons
 * 
 * Relations principales :
 * - intervention_note -> intervention
 * - intervention_batch -> company
 * - Toutes les entités de référence liées aux interventions
 * 
 * MIGRATION AXELOR-INTERVENTION TERMINÉE
 */