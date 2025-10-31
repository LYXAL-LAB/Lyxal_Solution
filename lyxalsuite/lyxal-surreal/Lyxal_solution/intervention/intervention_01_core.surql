/*
 * LYXAL SUITE - Module Intervention Core
 * Migration depuis axelor-intervention vers SurrealDB
 * 
 * Ce module contient les entités principales du système d'intervention :
 * - Intervention (entité principale)
 * - CustomerRequest (demandes client)
 * - InterventionConfig (configuration)
 * - AppIntervention (configuration application)
 * 
 * Fonctionnalités :
 * - Gestion des interventions techniques
 * - Suivi des demandes client
 * - Configuration système
 * - Gestion des statuts et workflows
 * - Intégration avec les contrats et opportunités
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: intervention_config
-- Configuration des interventions par entreprise
-- =============================================
DEFINE TABLE intervention_config SCHEMAFULL;

DEFINE FIELD company ON intervention_config TYPE record<company>;
DEFINE FIELD customer_request_creation_automatic_mail ON intervention_config TYPE bool DEFAULT false;
DEFINE FIELD customer_request_creation_message_template ON intervention_config TYPE option<record<message_template>>;
DEFINE FIELD intervention_planification_automatic_mail ON intervention_config TYPE bool DEFAULT false;
DEFINE FIELD intervention_planification_message_template ON intervention_config TYPE option<record<message_template>>;
DEFINE FIELD intervention_re_planification_automatic_mail ON intervention_config TYPE bool DEFAULT false;
DEFINE FIELD intervention_re_planification_message_template ON intervention_config TYPE option<record<message_template>>;
DEFINE FIELD intervention_validation_automatic_mail ON intervention_config TYPE bool DEFAULT false;
DEFINE FIELD intervention_validation_message_template ON intervention_config TYPE option<record<message_template>>;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention_config TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention_config TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention_config TYPE option<record<user>>;
DEFINE FIELD archived ON intervention_config TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention_config TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD company ON intervention_config ASSERT $value != NONE;
DEFINE INDEX idx_intervention_config_company ON intervention_config FIELDS company UNIQUE;

-- =============================================
-- TABLE: app_intervention
-- Configuration de l'application intervention
-- =============================================
DEFINE TABLE app_intervention SCHEMAFULL;

DEFINE FIELD name ON app_intervention TYPE string;
DEFINE FIELD code ON app_intervention TYPE string;
DEFINE FIELD description ON app_intervention TYPE option<string>;
DEFINE FIELD is_active ON app_intervention TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_intervention TYPE int DEFAULT 0;

-- Métadonnées communes
DEFINE FIELD created_on ON app_intervention TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON app_intervention TYPE option<record<user>>;
DEFINE FIELD updated_on ON app_intervention TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON app_intervention TYPE option<record<user>>;
DEFINE FIELD archived ON app_intervention TYPE bool DEFAULT false;
DEFINE FIELD version ON app_intervention TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON app_intervention ASSERT $value != NONE AND string::len($value) > 0;
DEFINE INDEX idx_app_intervention_code ON app_intervention FIELDS code UNIQUE;

-- =============================================
-- TABLE: customer_request
-- Demandes d'intervention client
-- =============================================
DEFINE TABLE customer_request SCHEMAFULL;

DEFINE FIELD status_select ON customer_request TYPE int DEFAULT 10;
DEFINE FIELD email_sent ON customer_request TYPE bool DEFAULT false;
DEFINE FIELD sequence ON customer_request TYPE string;
DEFINE FIELD name ON customer_request TYPE string;
DEFINE FIELD company ON customer_request TYPE record<company>;
DEFINE FIELD trading_name ON customer_request TYPE option<record<trading_name>>;
DEFINE FIELD delivered_partner ON customer_request TYPE record<partner>;
DEFINE FIELD intervention_address ON customer_request TYPE record<address>;
DEFINE FIELD contact ON customer_request TYPE option<record<partner>>;
DEFINE FIELD equipment_set ON customer_request TYPE array<record<equipment>> DEFAULT [];
DEFINE FIELD contract ON customer_request TYPE option<record<contract>>;
DEFINE FIELD request_source ON customer_request TYPE option<record<request_source>>;
DEFINE FIELD request_subject ON customer_request TYPE option<record<request_subject>>;
DEFINE FIELD intervention_category ON customer_request TYPE option<record<intervention_category>>;
DEFINE FIELD description ON customer_request TYPE option<string>;
DEFINE FIELD priority ON customer_request TYPE string DEFAULT "normal";
DEFINE FIELD request_date_time ON customer_request TYPE datetime;
DEFINE FIELD user_in_charge ON customer_request TYPE option<record<user>>;
DEFINE FIELD on_call_management ON customer_request TYPE option<bool>;
DEFINE FIELD on_call_planning ON customer_request TYPE option<record<weekly_planning>>;
DEFINE FIELD sale_quotations ON customer_request TYPE option<record<sale_order>>;
DEFINE FIELD max_git_date_time ON customer_request TYPE option<datetime>;
DEFINE FIELD max_grt_date_time ON customer_request TYPE option<datetime>;
DEFINE FIELD real_git ON customer_request TYPE option<duration>;
DEFINE FIELD real_grt ON customer_request TYPE option<duration>;
DEFINE FIELD git_status_indicator ON customer_request TYPE option<string>;
DEFINE FIELD grt_status_indicator ON customer_request TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON customer_request TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON customer_request TYPE option<record<user>>;
DEFINE FIELD updated_on ON customer_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON customer_request TYPE option<record<user>>;
DEFINE FIELD archived ON customer_request TYPE bool DEFAULT false;
DEFINE FIELD version ON customer_request TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD company ON customer_request ASSERT $value != NONE;
DEFINE FIELD delivered_partner ON customer_request ASSERT $value != NONE;
DEFINE FIELD intervention_address ON customer_request ASSERT $value != NONE;
DEFINE FIELD request_date_time ON customer_request ASSERT $value != NONE;
DEFINE FIELD status_select ON customer_request ASSERT $value IN [10, 20, 30, 40, 50];
DEFINE FIELD priority ON customer_request ASSERT $value IN ["urgent", "important", "normal"];

-- Index d'optimisation
DEFINE INDEX idx_customer_request_sequence ON customer_request FIELDS sequence UNIQUE;
DEFINE INDEX idx_customer_request_company ON customer_request FIELDS company;
DEFINE INDEX idx_customer_request_delivered_partner ON customer_request FIELDS delivered_partner;
DEFINE INDEX idx_customer_request_status ON customer_request FIELDS status_select;
DEFINE INDEX idx_customer_request_priority ON customer_request FIELDS priority;
DEFINE INDEX idx_customer_request_date ON customer_request FIELDS request_date_time;

-- =============================================
-- TABLE: intervention
-- Interventions techniques
-- =============================================
DEFINE TABLE intervention SCHEMAFULL;

DEFINE FIELD status_select ON intervention TYPE int DEFAULT 10;
DEFINE FIELD sequence ON intervention TYPE string;
DEFINE FIELD name ON intervention TYPE string;
DEFINE FIELD is_survey_generation_running ON intervention TYPE bool DEFAULT false;
DEFINE FIELD company ON intervention TYPE record<company>;
DEFINE FIELD trading_name ON intervention TYPE option<record<trading_name>>;
DEFINE FIELD delivered_partner ON intervention TYPE option<record<partner>>;
DEFINE FIELD address ON intervention TYPE option<record<address>>;
DEFINE FIELD invoiced_partner ON intervention TYPE option<record<partner>>;
DEFINE FIELD contact ON intervention TYPE option<record<partner>>;
DEFINE FIELD description ON intervention TYPE option<string>;
DEFINE FIELD request_source ON intervention TYPE option<record<request_source>>;
DEFINE FIELD request_subject ON intervention TYPE option<record<request_subject>>;
DEFINE FIELD user_in_charge ON intervention TYPE option<record<user>>;
DEFINE FIELD outsourcing ON intervention TYPE bool DEFAULT false;
DEFINE FIELD supplier_partner ON intervention TYPE option<record<partner>>;
DEFINE FIELD intervention_category ON intervention TYPE option<record<intervention_category>>;
DEFINE FIELD intervention_type ON intervention TYPE option<record<intervention_type>>;
DEFINE FIELD planning_preference_select ON intervention TYPE option<int>;
DEFINE FIELD priority ON intervention TYPE option<string>;
DEFINE FIELD rescheduled_intervention ON intervention TYPE bool DEFAULT false;
DEFINE FIELD justification ON intervention TYPE option<record<justification>>;
DEFINE FIELD contract ON intervention TYPE option<record<contract>>;
DEFINE FIELD customer_request ON intervention TYPE option<record<customer_request>>;
DEFINE FIELD opportunity ON intervention TYPE option<record<opportunity>>;
DEFINE FIELD commercial_follow_up ON intervention TYPE bool DEFAULT false;
DEFINE FIELD after_sale_service_sale_order_follow_up ON intervention TYPE bool DEFAULT false;
DEFINE FIELD technical_follow_up ON intervention TYPE bool DEFAULT false;
DEFINE FIELD commercial_user ON intervention TYPE option<record<user>>;
DEFINE FIELD linked_sale_order ON intervention TYPE option<record<sale_order>>;
DEFINE FIELD linked_intervention ON intervention TYPE option<record<intervention>>;
DEFINE FIELD rescheduling_reason ON intervention TYPE option<record<rescheduling_reason>>;
DEFINE FIELD start_date_time ON intervention TYPE option<datetime>;
DEFINE FIELD end_date_time ON intervention TYPE option<datetime>;
DEFINE FIELD last_start_date_time ON intervention TYPE option<datetime>;
DEFINE FIELD estimated_date ON intervention TYPE option<date>;
DEFINE FIELD estimated_date_month ON intervention TYPE option<int>;
DEFINE FIELD total_duration ON intervention TYPE option<duration>;
DEFINE FIELD offline_intervention ON intervention TYPE bool DEFAULT false;
DEFINE FIELD equipment_set ON intervention TYPE array<record<equipment>> DEFAULT [];
DEFINE FIELD assigned_to ON intervention TYPE option<record<user>>;
DEFINE FIELD planif_start_date_time ON intervention TYPE option<datetime>;
DEFINE FIELD planif_end_date_time ON intervention TYPE option<datetime>;
DEFINE FIELD following ON intervention TYPE bool DEFAULT false;
DEFINE FIELD non_conforming ON intervention TYPE int DEFAULT 0;

-- Métadonnées communes
DEFINE FIELD created_on ON intervention TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON intervention TYPE option<record<user>>;
DEFINE FIELD updated_on ON intervention TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON intervention TYPE option<record<user>>;
DEFINE FIELD archived ON intervention TYPE bool DEFAULT false;
DEFINE FIELD version ON intervention TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD status_select ON intervention ASSERT $value IN [10, 20, 30, 40, 50, 60];
DEFINE FIELD priority ON intervention ASSERT $value == NONE OR $value IN ["urgent", "important", "normal"];

-- Index d'optimisation
DEFINE INDEX idx_intervention_sequence ON intervention FIELDS sequence UNIQUE;
DEFINE INDEX idx_intervention_company ON intervention FIELDS company;
DEFINE INDEX idx_intervention_status ON intervention FIELDS status_select;
DEFINE INDEX idx_intervention_date ON intervention FIELDS start_date_time;
DEFINE INDEX idx_intervention_assigned_to ON intervention FIELDS assigned_to;
DEFINE INDEX idx_intervention_customer_request ON intervention FIELDS customer_request;
DEFINE INDEX idx_intervention_contract ON intervention FIELDS contract;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Génération automatique de séquence pour customer_request
DEFINE EVENT customer_request_sequence ON TABLE customer_request WHEN $event = "CREATE" THEN {
    IF $after.sequence == NONE {
        UPDATE $after.id SET sequence = string::concat("CR", string::slice(string::replace(time::now(), ["-", ":", "T", "."], ""), 2, 14));
    }
};

-- Événement : Génération automatique de séquence pour intervention
DEFINE EVENT intervention_sequence ON TABLE intervention WHEN $event = "CREATE" THEN {
    IF $after.sequence == NONE {
        UPDATE $after.id SET sequence = string::concat("INT", string::slice(string::replace(time::now(), ["-", ":", "T", "."], ""), 2, 14));
    }
};

-- Événement : Calcul du nom d'une demande client
DEFINE EVENT customer_request_name ON TABLE customer_request WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $name_parts = [];
    IF $after.request_source != NONE {
        LET $name_parts = array::append($name_parts, (SELECT name FROM $after.request_source)[0].name);
    };
    IF $after.request_subject != NONE {
        LET $name_parts = array::append($name_parts, (SELECT name FROM $after.request_subject)[0].name);
    };
    
    LET $computed_name = IF array::len($name_parts) > 0 {
        string::concat($after.sequence, ": ", array::join($name_parts, " - "))
    } ELSE {
        $after.sequence
    };
    
    UPDATE $after.id SET name = $computed_name;
};

-- Événement : Calcul du nom d'une intervention
DEFINE EVENT intervention_name ON TABLE intervention WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $name_parts = [];
    IF $after.request_source != NONE {
        LET $name_parts = array::append($name_parts, (SELECT name FROM $after.request_source)[0].name);
    };
    IF $after.request_subject != NONE {
        LET $name_parts = array::append($name_parts, (SELECT name FROM $after.request_subject)[0].name);
    };
    
    LET $computed_name = IF array::len($name_parts) > 0 {
        string::concat($after.sequence, ": ", array::join($name_parts, " - "))
    } ELSE {
        $after.sequence
    };
    
    UPDATE $after.id SET name = $computed_name;
};

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_customer_request ON TABLE customer_request WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_intervention ON TABLE intervention WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Statuts des demandes client
INSERT INTO lyxal_constants (
    id: constants:customer_request_status,
    category: 'customer_request_status',
    values: {
        DRAFT: 10,
        TAKEN_INTO_ACCOUNT: 20,
        IN_PROGRESS: 30,
        FINISHED: 40,
        CANCELLED: 50
    }
);

-- Priorités des demandes client
INSERT INTO lyxal_constants (
    id: constants:customer_request_priority,
    category: 'customer_request_priority',
    values: {
        URGENT: 'urgent',
        IMPORTANT: 'important',
        NORMAL: 'normal'
    }
);

-- Statuts des interventions
INSERT INTO lyxal_constants (
    id: constants:intervention_status,
    category: 'intervention_status',
    values: {
        TO_PLAN: 10,
        PLANNED: 20,
        STARTED: 30,
        SUSPENDED: 40,
        FINISHED: 50,
        CANCELLED: 60
    }
);

-- Indicateurs de statut GT
INSERT INTO lyxal_constants (
    id: constants:gt_status_indicator,
    category: 'gt_status_indicator',
    values: {
        OK: 'ok',
        FAIL: 'fail',
        ALERT: 'alert',
        URGENT: 'urgent',
        RESPECTED: 'respected',
        NON_RESPECTED: 'nonRespected'
    }
);

/*
 * RÉSUMÉ DU MODULE INTERVENTION CORE
 * 
 * Tables créées : 4
 * - intervention_config : Configuration des interventions
 * - app_intervention : Configuration application
 * - customer_request : Demandes client
 * - intervention : Interventions techniques
 * 
 * Fonctionnalités :
 * - Gestion complète des interventions
 * - Suivi des demandes client
 * - Workflow de statuts
 * - Calcul automatique des noms
 * - Gestion des priorités
 * - Intégration avec contrats et équipements
 * - Gestion des délais (GIT/GRT)
 * - Configuration flexible
 * 
 * Relations :
 * - Lien avec company, partner, address
 * - Lien avec contracts et sale_orders
 * - Lien avec equipments
 * - Lien avec users pour assignation
 * 
 * Prochaines étapes :
 * - intervention_02_equipment.surql
 * - intervention_03_questions_ranges.surql
 * - intervention_04_contracts_types.surql
 * - intervention_05_support_entities.surql
 */ 