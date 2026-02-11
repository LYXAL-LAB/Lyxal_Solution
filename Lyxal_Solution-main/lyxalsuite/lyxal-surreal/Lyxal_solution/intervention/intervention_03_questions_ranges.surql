/*
 * LYXAL SUITE - Module Intervention Questions & Ranges
 * Migration depuis axelor-intervention vers SurrealDB
 * 
 * Ce module contient les entités liées aux questions et plages d'intervention :
 * - InterventionRange (plages d'intervention)
 * - InterventionQuestion (questions d'intervention)
 * - RangeType (types de plages)
 * - Range (plages)
 * - RangeQuestion (questions de plages)
 * - Question (questions)
 * - AnswerType (types de réponses)
 * - AnswerValue (valeurs de réponses)
 * - OrderedRange (plages ordonnées)
 * 
 * Fonctionnalités :
 * - Questionnaires d'intervention
 * - Gestion des plages d'intervention
 * - Types de questions variés
 * - Réponses conditionnelles
 * - Validation des réponses
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: answer_type
-- Types de réponses pour les questions
-- =============================================
DEFINE TABLE answer_type SCHEMAFULL;

DEFINE FIELD code ON answer_type TYPE string;
DEFINE FIELD name ON answer_type TYPE string;
DEFINE FIELD description ON answer_type TYPE option<string>;
DEFINE FIELD validation_rules ON answer_type TYPE option<string>;
DEFINE FIELD input_type ON answer_type TYPE string; -- text, number, date, checkbox, select, etc.

-- Métadonnées communes
DEFINE FIELD created_on ON answer_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON answer_type TYPE option<record<user>>;
DEFINE FIELD updated_on ON answer_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON answer_type TYPE option<record<user>>;
DEFINE FIELD archived ON answer_type TYPE bool DEFAULT false;
DEFINE FIELD version ON answer_type TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON answer_type ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON answer_type ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD input_type ON answer_type ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_answer_type_code ON answer_type FIELDS code UNIQUE;

-- =============================================
-- TABLE: answer_value
-- Valeurs de réponses prédéfinies
-- =============================================
DEFINE TABLE answer_value SCHEMAFULL;

DEFINE FIELD answer_type ON answer_value TYPE record<answer_type>;
DEFINE FIELD value_code ON answer_value TYPE string;
DEFINE FIELD value_label ON answer_value TYPE string;
DEFINE FIELD value_description ON answer_value TYPE option<string>;
DEFINE FIELD order_seq ON answer_value TYPE int DEFAULT 0;
DEFINE FIELD is_active ON answer_value TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON answer_value TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON answer_value TYPE option<record<user>>;
DEFINE FIELD updated_on ON answer_value TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON answer_value TYPE option<record<user>>;
DEFINE FIELD archived ON answer_value TYPE bool DEFAULT false;
DEFINE FIELD version ON answer_value TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD answer_type ON answer_value ASSERT $value != NONE;
DEFINE FIELD value_code ON answer_value ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD value_label ON answer_value ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_answer_value_type ON answer_value FIELDS answer_type;
DEFINE INDEX idx_answer_value_code ON answer_value FIELDS answer_type, value_code UNIQUE;

-- =============================================
-- TABLE: question
-- Questions de base
-- =============================================
DEFINE TABLE question SCHEMAFULL;

DEFINE FIELD code ON question TYPE string;
DEFINE FIELD title ON question TYPE string;
DEFINE FIELD description ON question TYPE option<string>;
DEFINE FIELD indication ON question TYPE option<string>;
DEFINE FIELD answer_type ON question TYPE record<answer_type>;
DEFINE FIELD is_required ON question TYPE bool DEFAULT false;
DEFINE FIELD is_private ON question TYPE bool DEFAULT false;
DEFINE FIELD is_conditional ON question TYPE bool DEFAULT false;
DEFINE FIELD default_text_value ON question TYPE option<string>;
DEFINE FIELD desired_unit ON question TYPE option<record<unit>>;
DEFINE FIELD checkbox_name ON question TYPE option<string>;
DEFINE FIELD summary ON question TYPE bool DEFAULT false;

-- Métadonnées communes
DEFINE FIELD created_on ON question TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON question TYPE option<record<user>>;
DEFINE FIELD updated_on ON question TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON question TYPE option<record<user>>;
DEFINE FIELD archived ON question TYPE bool DEFAULT false;
DEFINE FIELD version ON question TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON question ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD title ON question ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD answer_type ON question ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_question_code ON question FIELDS code UNIQUE;
DEFINE INDEX idx_question_answer_type ON question FIELDS answer_type;

-- =============================================
-- TABLE: range_type
-- Types de plages d'intervention
-- =============================================
DEFINE TABLE range_type SCHEMAFULL;

DEFINE FIELD code ON range_type TYPE string;
DEFINE FIELD name ON range_type TYPE string;
DEFINE FIELD description ON range_type TYPE option<string>;
DEFINE FIELD color ON range_type TYPE option<string>;
DEFINE FIELD is_active ON range_type TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON range_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON range_type TYPE option<record<user>>;
DEFINE FIELD updated_on ON range_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON range_type TYPE option<record<user>>;
DEFINE FIELD archived ON range_type TYPE bool DEFAULT false;
DEFINE FIELD version ON range_type TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON range_type ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON range_type ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_range_type_code ON range_type FIELDS code UNIQUE;

-- =============================================
-- TABLE: range
-- Plages d'intervention
-- =============================================
DEFINE TABLE range SCHEMAFULL;

DEFINE FIELD code ON range TYPE string;
DEFINE FIELD name ON range TYPE string;
DEFINE FIELD description ON range TYPE option<string>;
DEFINE FIELD range_type ON range TYPE record<range_type>;
DEFINE FIELD is_active ON range TYPE bool DEFAULT true;
DEFINE FIELD order_seq ON range TYPE int DEFAULT 0;

-- Métadonnées communes
DEFINE FIELD created_on ON range TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON range TYPE option<record<user>>;
DEFINE FIELD updated_on ON range TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON range TYPE option<record<user>>;
DEFINE FIELD archived ON range TYPE bool DEFAULT false;
DEFINE FIELD version ON range TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON range ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON range ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD range_type ON range ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_range_code ON range FIELDS code UNIQUE;
DEFINE INDEX idx_range_type ON range FIELDS range_type;

-- =============================================
-- TABLE: range_question
-- Questions associées aux plages
-- =============================================
DEFINE TABLE range_question SCHEMAFULL;

DEFINE FIELD range ON range_question TYPE record<range>;
DEFINE FIELD question ON range_question TYPE record<question>;
DEFINE FIELD order_seq ON range_question TYPE int DEFAULT 0;
DEFINE FIELD is_mandatory ON range_question TYPE bool DEFAULT false;
DEFINE FIELD conditional_question ON range_question TYPE option<record<question>>;
DEFINE FIELD conditional_answer_values ON range_question TYPE array<record<answer_value>> DEFAULT [];

-- Métadonnées communes
DEFINE FIELD created_on ON range_question TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON range_question TYPE option<record<user>>;
DEFINE FIELD updated_on ON range_question TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON range_question TYPE option<record<user>>;
DEFINE FIELD archived ON range_question TYPE bool DEFAULT false;
DEFINE FIELD version ON range_question TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD range ON range_question ASSERT $value != NONE;
DEFINE FIELD question ON range_question ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_range_question_range ON range_question FIELDS range;
DEFINE INDEX idx_range_question_question ON range_question FIELDS question;
DEFINE INDEX idx_range_question_unique ON range_question FIELDS range, question UNIQUE;

-- =============================================
-- TABLE: ordered_range
-- Plages ordonnées pour les interventions
-- =============================================
DEFINE TABLE ordered_range SCHEMAFULL;

DEFINE FIELD intervention_type ON ordered_range TYPE record<intervention_type>;
DEFINE FIELD range ON ordered_range TYPE record<range>;
DEFINE FIELD order_seq ON ordered_range TYPE int DEFAULT 0;
DEFINE FIELD is_mandatory ON ordered_range TYPE bool DEFAULT false;
DEFINE FIELD is_active ON ordered_range TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON ordered_range TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON ordered_range TYPE option<record<user>>;
DEFINE FIELD updated_on ON ordered_range TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON ordered_range TYPE option<record<user>>;
DEFINE FIELD archived ON ordered_range TYPE bool DEFAULT false;
DEFINE FIELD version ON ordered_range TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD intervention_type ON ordered_range ASSERT $value != NONE;
DEFINE FIELD range ON ordered_range ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_ordered_range_intervention_type ON ordered_range FIELDS intervention_type;
DEFINE INDEX idx_ordered_range_range ON ordered_range FIELDS range;
DEFINE INDEX idx_ordered_range_unique ON ordered_range FIELDS intervention_type, range UNIQUE;

-- =============================================
-- TABLE: intervention_range
-- Plages d'une intervention spécifique
-- =============================================
DEFINE TABLE intervention_range SCHEMAFULL;

DEFINE FIELD intervention ON intervention_range TYPE record<intervention>;
DEFINE FIELD range ON intervention_range TYPE record<range>;
DEFINE FIELD order_seq ON intervention_range TYPE int DEFAULT 0;
DEFINE FIELD status_select ON intervention_range TYPE int DEFAULT 10;
DEFINE FIELD start_date_time ON intervention_range TYPE option<datetime>;
DEFINE FIELD end_date_time ON intervention_range TYPE option<datetime>;
DEFINE FIELD duration ON intervention_range TYPE option<duration>;
DEFINE FIELD comments ON intervention_range TYPE option<string>;
DEFINE FIELD is_completed ON intervention_range TYPE bool DEFAULT false;
DEFINE FIELD completed_by ON intervention_range TYPE option<record<user>>;
DEFINE FIELD completed_on ON intervention_range TYPE option<datetime>;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_range TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_range TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_range TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_range TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_range TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_range TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD intervention ON intervention_range ASSERT $value != NONE;
DEFINE FIELD range ON intervention_range ASSERT $value != NONE;
DEFINE FIELD status_select ON intervention_range ASSERT $value IN [10, 20, 30, 40];

-- Index d'optimisation
DEFINE INDEX idx_intervention_range_intervention ON intervention_range FIELDS intervention;
DEFINE INDEX idx_intervention_range_range ON intervention_range FIELDS range;
DEFINE INDEX idx_intervention_range_status ON intervention_range FIELDS status_select;
DEFINE INDEX idx_intervention_range_unique ON intervention_range FIELDS intervention, range UNIQUE;

-- =============================================
-- TABLE: intervention_question
-- Questions d'une intervention spécifique
-- =============================================
DEFINE TABLE intervention_question SCHEMAFULL;

DEFINE FIELD intervention_range ON intervention_question TYPE record<intervention_range>;
DEFINE FIELD range_question_sequence ON intervention_question TYPE string;
DEFINE FIELD order_seq ON intervention_question TYPE int DEFAULT 0;
DEFINE FIELD title ON intervention_question TYPE string;
DEFINE FIELD indication ON intervention_question TYPE option<string>;
DEFINE FIELD answer_type_select ON intervention_question TYPE string;
DEFINE FIELD default_text_value ON intervention_question TYPE option<string>;
DEFINE FIELD desired_unit ON intervention_question TYPE option<record<unit>>;
DEFINE FIELD checkbox_name ON intervention_question TYPE option<string>;
DEFINE FIELD is_required ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD is_private ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD is_conditional ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD summary ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD conditional_intervention_question ON intervention_question TYPE option<record<intervention_question>>;
DEFINE FIELD conditional_answer_value_set ON intervention_question TYPE array<record<answer_value>> DEFAULT [];

-- Réponses
DEFINE FIELD list_answer ON intervention_question TYPE option<record<answer_value>>;
DEFINE FIELD text_answer ON intervention_question TYPE option<string>;
DEFINE FIELD date_answer ON intervention_question TYPE option<date>;
DEFINE FIELD picture_answer ON intervention_question TYPE option<string>; -- path to file
DEFINE FIELD measure_answer ON intervention_question TYPE option<decimal>;
DEFINE FIELD checkbox_answer ON intervention_question TYPE option<bool>;
DEFINE FIELD indication_text ON intervention_question TYPE option<string>;
DEFINE FIELD signature_answer ON intervention_question TYPE option<string>; -- path to file
DEFINE FIELD advanced_monitoring_answer ON intervention_question TYPE option<string>;
DEFINE FIELD advanced_monitoring_address ON intervention_question TYPE option<string>;

-- État
DEFINE FIELD is_answered ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD state ON intervention_question TYPE string DEFAULT "NOT_ANSWERED";

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_question TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_question TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_question TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_question TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_question TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_question TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD intervention_range ON intervention_question ASSERT $value != NONE;
DEFINE FIELD range_question_sequence ON intervention_question ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD title ON intervention_question ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD answer_type_select ON intervention_question ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD state ON intervention_question ASSERT $value IN ["ANSWERED", "NOT_ANSWERED", "INDICATION", "PRIVATE", "CONDITIONAL"];

-- Index d'optimisation
DEFINE INDEX idx_intervention_question_range ON intervention_question FIELDS intervention_range;
DEFINE INDEX idx_intervention_question_sequence ON intervention_question FIELDS intervention_range, range_question_sequence UNIQUE;
DEFINE INDEX idx_intervention_question_state ON intervention_question FIELDS state;
DEFINE INDEX idx_intervention_question_answered ON intervention_question FIELDS is_answered;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Mise à jour de l'état is_answered
DEFINE EVENT intervention_question_answered ON TABLE intervention_question WHEN $event = "UPDATE" THEN {
    LET $has_answer = $after.list_answer != NONE OR 
                      $after.text_answer != NONE OR 
                      $after.date_answer != NONE OR 
                      $after.picture_answer != NONE OR 
                      $after.measure_answer != NONE OR 
                      $after.checkbox_answer != NONE OR 
                      $after.signature_answer != NONE OR 
                      $after.advanced_monitoring_answer != NONE;
    
    IF $has_answer != $after.is_answered {
        UPDATE $after.id SET is_answered = $has_answer;
        UPDATE $after.id SET state = IF $has_answer { "ANSWERED" } ELSE { "NOT_ANSWERED" };
    }
};

-- Événement : Calcul de la durée des intervention_range
DEFINE EVENT intervention_range_duration ON TABLE intervention_range WHEN $event = "UPDATE" THEN {
    IF $after.start_date_time != NONE AND $after.end_date_time != NONE {
        LET $duration_seconds = time::unix($after.end_date_time) - time::unix($after.start_date_time);
        UPDATE $after.id SET duration = <duration>string::concat($duration_seconds, "s");
    }
};

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_intervention_range ON TABLE intervention_range WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_intervention_question ON TABLE intervention_question WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Types de réponses
INSERT INTO lyxal_constants (
    id: constants:answer_type,
    category: 'answer_type',
    values: {
        TEXT: 'text',
        NUMBER: 'number',
        DATE: 'date',
        CHECKBOX: 'checkbox',
        SELECT: 'select',
        PICTURE: 'picture',
        SIGNATURE: 'signature',
        MEASURE: 'measure',
        ADVANCED_MONITORING: 'advanced_monitoring'
    }
);

-- États des questions d'intervention
INSERT INTO lyxal_constants (
    id: constants:intervention_question_state,
    category: 'intervention_question_state',
    values: {
        ANSWERED: 'ANSWERED',
        NOT_ANSWERED: 'NOT_ANSWERED',
        INDICATION: 'INDICATION',
        PRIVATE: 'PRIVATE',
        CONDITIONAL: 'CONDITIONAL'
    }
);

-- Statuts des plages d'intervention
INSERT INTO lyxal_constants (
    id: constants:intervention_range_status,
    category: 'intervention_range_status',
    values: {
        PLANNED: 10,
        IN_PROGRESS: 20,
        COMPLETED: 30,
        CANCELLED: 40
    }
);

-- Réponses de surveillance avancée
INSERT INTO lyxal_constants (
    id: constants:advanced_monitoring_answer,
    category: 'advanced_monitoring_answer',
    values: {
        HOME: 'home',
        OFFICE: 'office',
        PREVIOUS: 'previous',
        NEXT: 'next'
    }
);

/*
 * RÉSUMÉ DU MODULE INTERVENTION QUESTIONS & RANGES
 * 
 * Tables créées : 9
 * - answer_type : Types de réponses
 * - answer_value : Valeurs prédéfinies
 * - question : Questions de base
 * - range_type : Types de plages
 * - range : Plages d'intervention
 * - range_question : Questions par plage
 * - ordered_range : Plages ordonnées
 * - intervention_range : Plages d'intervention
 * - intervention_question : Questions d'intervention
 * 
 * Fonctionnalités :
 * - Système de questionnaires flexible
 * - Gestion des plages d'intervention
 * - Questions conditionnelles
 * - Multiples types de réponses
 * - Validation automatique
 * - Calcul de durées
 * - États de questions
 * 
 * Relations principales :
 * - intervention_range -> intervention
 * - intervention_question -> intervention_range
 * - range_question -> range + question
 * - ordered_range -> intervention_type + range
 * 
 * Prochaines étapes :
 * - intervention_04_support_entities.surql
 */ 