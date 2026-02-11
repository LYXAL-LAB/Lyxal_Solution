/*
 * LYXAL SUITE - Module Maintenance
 * Migration depuis axelor-maintenance vers SurrealDB
 * 
 * Ce module contient les entités pour la gestion de la maintenance :
 * - MaintenanceRequest (demandes de maintenance)
 * - EquipementMaintenance (équipements de maintenance)
 * - MaintenanceCategory (catégories de maintenance)
 * - Extensions pour ProductionConfig, ManufOrder, BillOfMaterial, ProdProcess
 * 
 * Fonctionnalités :
 * - Gestion des demandes de maintenance préventive et corrective
 * - Planification de la maintenance
 * - Suivi des équipements
 * - Intégration avec la production
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: maintenance_category
-- Catégories de maintenance
-- =============================================
DEFINE TABLE maintenance_category SCHEMAFULL;

DEFINE FIELD name ON maintenance_category TYPE string;
DEFINE FIELD code ON maintenance_category TYPE string;
DEFINE FIELD description ON maintenance_category TYPE option<string>;
DEFINE FIELD is_active ON maintenance_category TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_category TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_category TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_category TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_category TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_category TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON maintenance_category ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_maintenance_category_name ON maintenance_category FIELDS name;
DEFINE INDEX idx_maintenance_category_code ON maintenance_category FIELDS code;

-- =============================================
-- TABLE: equipement_maintenance
-- Équipements de maintenance
-- =============================================
DEFINE TABLE equipement_maintenance SCHEMAFULL;

DEFINE FIELD code ON equipement_maintenance TYPE string;
DEFINE FIELD name ON equipement_maintenance TYPE string;
DEFINE FIELD maintenance_category ON equipement_maintenance TYPE option<record<maintenance_category>>;
DEFINE FIELD machine ON equipement_maintenance TYPE option<record<machine>>;
DEFINE FIELD mtn_each_day ON equipement_maintenance TYPE option<int>;
DEFINE FIELD mtn_each_cycle ON equipement_maintenance TYPE option<int>;
DEFINE FIELD mtn_each_duration ON equipement_maintenance TYPE option<int>;
DEFINE FIELD create_mtn_request_select ON equipement_maintenance TYPE option<int>;
DEFINE FIELD next_mtn_date ON equipement_maintenance TYPE option<date>;
DEFINE FIELD mtn_procedure ON equipement_maintenance TYPE option<string>;
DEFINE FIELD mtn_file ON equipement_maintenance TYPE option<string>; -- path to file
DEFINE FIELD image ON equipement_maintenance TYPE option<string>; -- path to image
DEFINE FIELD is_active ON equipement_maintenance TYPE bool DEFAULT true;

-- Métadonnées communes
DEFINE FIELD created_on ON equipement_maintenance TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON equipement_maintenance TYPE option<record<user>>;
DEFINE FIELD updated_on ON equipement_maintenance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON equipement_maintenance TYPE option<record<user>>;
DEFINE FIELD archived ON equipement_maintenance TYPE bool DEFAULT false;
DEFINE FIELD version ON equipement_maintenance TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON equipement_maintenance ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_equipement_maintenance_code ON equipement_maintenance FIELDS code UNIQUE;
DEFINE INDEX idx_equipement_maintenance_name ON equipement_maintenance FIELDS name;
DEFINE INDEX idx_equipement_maintenance_category ON equipement_maintenance FIELDS maintenance_category;
DEFINE INDEX idx_equipement_maintenance_machine ON equipement_maintenance FIELDS machine;
DEFINE INDEX idx_equipement_maintenance_next_date ON equipement_maintenance FIELDS next_mtn_date;

-- =============================================
-- TABLE: maintenance_request
-- Demandes de maintenance
-- =============================================
DEFINE TABLE maintenance_request SCHEMAFULL;

DEFINE FIELD sequence ON maintenance_request TYPE int;
DEFINE FIELD equipement_maintenance ON maintenance_request TYPE option<record<equipement_maintenance>>;
DEFINE FIELD status_select ON maintenance_request TYPE int DEFAULT 0;
DEFINE FIELD request_date ON maintenance_request TYPE date;
DEFINE FIELD request_by ON maintenance_request TYPE option<record<user>>;
DEFINE FIELD expected_date ON maintenance_request TYPE date;
DEFINE FIELD duration_hours ON maintenance_request TYPE option<decimal>;
DEFINE FIELD assigned_to ON maintenance_request TYPE option<record<user>>;
DEFINE FIELD mtn_task ON maintenance_request TYPE option<string>;
DEFINE FIELD action_select ON maintenance_request TYPE option<int>;
DEFINE FIELD manuf_order ON maintenance_request TYPE option<record<manuf_order>>;
DEFINE FIELD done_on ON maintenance_request TYPE option<date>;
DEFINE FIELD mtn_comments ON maintenance_request TYPE option<string>;
DEFINE FIELD start_date ON maintenance_request TYPE option<date>;
DEFINE FIELD end_date ON maintenance_request TYPE option<date>;
DEFINE FIELD machine ON maintenance_request TYPE option<record<machine>>;
DEFINE FIELD priority ON maintenance_request TYPE string DEFAULT "normal";

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_request TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_request TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_request TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_request TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_request TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD request_date ON maintenance_request ASSERT $value != NONE;
DEFINE FIELD expected_date ON maintenance_request ASSERT $value != NONE;
DEFINE FIELD status_select ON maintenance_request ASSERT $value IN [0, 1, 2, 3];
DEFINE FIELD action_select ON maintenance_request ASSERT $value == NONE OR $value IN [0, 1];
DEFINE FIELD priority ON maintenance_request ASSERT $value IN ["urgent", "high", "normal", "low"];

-- Index d'optimisation
DEFINE INDEX idx_maintenance_request_sequence ON maintenance_request FIELDS sequence UNIQUE;
DEFINE INDEX idx_maintenance_request_equipement ON maintenance_request FIELDS equipement_maintenance;
DEFINE INDEX idx_maintenance_request_status ON maintenance_request FIELDS status_select;
DEFINE INDEX idx_maintenance_request_assigned_to ON maintenance_request FIELDS assigned_to;
DEFINE INDEX idx_maintenance_request_request_date ON maintenance_request FIELDS request_date;
DEFINE INDEX idx_maintenance_request_expected_date ON maintenance_request FIELDS expected_date;
DEFINE INDEX idx_maintenance_request_machine ON maintenance_request FIELDS machine;
DEFINE INDEX idx_maintenance_request_priority ON maintenance_request FIELDS priority;

-- =============================================
-- TABLE: maintenance_production_config
-- Configuration de production pour la maintenance
-- =============================================
DEFINE TABLE maintenance_production_config SCHEMAFULL;

DEFINE FIELD company ON maintenance_production_config TYPE record<company>;
DEFINE FIELD maintenance_bill_of_material_print_template ON maintenance_production_config TYPE option<record<printing_template>>;
DEFINE FIELD maintenance_manuf_order_print_template ON maintenance_production_config TYPE option<record<printing_template>>;
DEFINE FIELD maintenance_prod_process_print_template ON maintenance_production_config TYPE option<record<printing_template>>;

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_production_config TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_production_config TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_production_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_production_config TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_production_config TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_production_config TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD company ON maintenance_production_config ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_maintenance_production_config_company ON maintenance_production_config FIELDS company UNIQUE;

-- =============================================
-- TABLE: maintenance_manuf_order
-- Ordres de fabrication de maintenance
-- =============================================
DEFINE TABLE maintenance_manuf_order SCHEMAFULL;

DEFINE FIELD code ON maintenance_manuf_order TYPE string;
DEFINE FIELD name ON maintenance_manuf_order TYPE string;
DEFINE FIELD type_select ON maintenance_manuf_order TYPE int DEFAULT 3; -- TYPE_MAINTENANCE
DEFINE FIELD machine_type ON maintenance_manuf_order TYPE option<record<machine_type>>;
DEFINE FIELD machine ON maintenance_manuf_order TYPE option<record<machine>>;
DEFINE FIELD maintenance_request ON maintenance_manuf_order TYPE option<record<maintenance_request>>;
DEFINE FIELD status_select ON maintenance_manuf_order TYPE int DEFAULT 1;
DEFINE FIELD planned_start_date ON maintenance_manuf_order TYPE option<datetime>;
DEFINE FIELD planned_end_date ON maintenance_manuf_order TYPE option<datetime>;
DEFINE FIELD real_start_date ON maintenance_manuf_order TYPE option<datetime>;
DEFINE FIELD real_end_date ON maintenance_manuf_order TYPE option<datetime>;

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_manuf_order TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_manuf_order TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_manuf_order TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_manuf_order TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON maintenance_manuf_order ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON maintenance_manuf_order ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD type_select ON maintenance_manuf_order ASSERT $value = 3; -- Maintenance only

-- Index d'optimisation
DEFINE INDEX idx_maintenance_manuf_order_code ON maintenance_manuf_order FIELDS code UNIQUE;
DEFINE INDEX idx_maintenance_manuf_order_machine ON maintenance_manuf_order FIELDS machine;
DEFINE INDEX idx_maintenance_manuf_order_request ON maintenance_manuf_order FIELDS maintenance_request;
DEFINE INDEX idx_maintenance_manuf_order_status ON maintenance_manuf_order FIELDS status_select;

-- =============================================
-- TABLE: maintenance_bill_of_material
-- Nomenclatures de maintenance
-- =============================================
DEFINE TABLE maintenance_bill_of_material SCHEMAFULL;

DEFINE FIELD code ON maintenance_bill_of_material TYPE string;
DEFINE FIELD name ON maintenance_bill_of_material TYPE string;
DEFINE FIELD type_select ON maintenance_bill_of_material TYPE int DEFAULT 3; -- Maintenance
DEFINE FIELD machine_type ON maintenance_bill_of_material TYPE option<record<machine_type>>;
DEFINE FIELD product ON maintenance_bill_of_material TYPE option<record<product>>;
DEFINE FIELD equipement_maintenance ON maintenance_bill_of_material TYPE option<record<equipement_maintenance>>;
DEFINE FIELD quantity ON maintenance_bill_of_material TYPE decimal DEFAULT 1;
DEFINE FIELD unit ON maintenance_bill_of_material TYPE option<record<unit>>;

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_bill_of_material TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_bill_of_material TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_bill_of_material TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_bill_of_material TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_bill_of_material TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_bill_of_material TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON maintenance_bill_of_material ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON maintenance_bill_of_material ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD quantity ON maintenance_bill_of_material ASSERT $value > 0;

-- Index d'optimisation
DEFINE INDEX idx_maintenance_bill_of_material_code ON maintenance_bill_of_material FIELDS code UNIQUE;
DEFINE INDEX idx_maintenance_bill_of_material_equipement ON maintenance_bill_of_material FIELDS equipement_maintenance;
DEFINE INDEX idx_maintenance_bill_of_material_product ON maintenance_bill_of_material FIELDS product;

-- =============================================
-- TABLE: maintenance_prod_process
-- Processus de production de maintenance
-- =============================================
DEFINE TABLE maintenance_prod_process SCHEMAFULL;

DEFINE FIELD code ON maintenance_prod_process TYPE string;
DEFINE FIELD name ON maintenance_prod_process TYPE string;
DEFINE FIELD type_select ON maintenance_prod_process TYPE int DEFAULT 3; -- Maintenance
DEFINE FIELD machine_type ON maintenance_prod_process TYPE option<record<machine_type>>;
DEFINE FIELD equipement_maintenance ON maintenance_prod_process TYPE option<record<equipement_maintenance>>;
DEFINE FIELD description ON maintenance_prod_process TYPE option<string>;
DEFINE FIELD duration_hours ON maintenance_prod_process TYPE option<decimal>;

-- Métadonnées communes
DEFINE FIELD created_on ON maintenance_prod_process TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON maintenance_prod_process TYPE option<record<user>>;
DEFINE FIELD updated_on ON maintenance_prod_process TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON maintenance_prod_process TYPE option<record<user>>;
DEFINE FIELD archived ON maintenance_prod_process TYPE bool DEFAULT false;
DEFINE FIELD version ON maintenance_prod_process TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON maintenance_prod_process ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON maintenance_prod_process ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_maintenance_prod_process_code ON maintenance_prod_process FIELDS code UNIQUE;
DEFINE INDEX idx_maintenance_prod_process_equipement ON maintenance_prod_process FIELDS equipement_maintenance;
DEFINE INDEX idx_maintenance_prod_process_machine_type ON maintenance_prod_process FIELDS machine_type;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Génération automatique de séquence pour maintenance_request
DEFINE EVENT maintenance_request_sequence ON TABLE maintenance_request WHEN $event = "CREATE" THEN {
    LET $max_sequence = (SELECT VALUE sequence FROM maintenance_request ORDER BY sequence DESC LIMIT 1);
    LET $next_sequence = IF array::len($max_sequence) > 0 { $max_sequence[0] + 1 } ELSE { 1 };
    UPDATE $after.id SET sequence = $next_sequence;
};

-- Événement : Génération automatique de code pour equipement_maintenance
DEFINE EVENT equipement_maintenance_code ON TABLE equipement_maintenance WHEN $event = "CREATE" THEN {
    IF $after.code == NONE {
        UPDATE $after.id SET code = string::concat("EQM", string::slice(string::replace(time::now(), ["-", ":", "T", "."], ""), 2, 14));
    }
};

-- Événement : Calcul automatique de la prochaine date de maintenance
DEFINE EVENT equipement_maintenance_next_date ON TABLE equipement_maintenance WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.mtn_each_day != NONE AND $after.mtn_each_day > 0 {
        LET $next_date = time::now() + <duration>string::concat($after.mtn_each_day, "d");
        UPDATE $after.id SET next_mtn_date = <date>$next_date;
    }
};

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_maintenance_request ON TABLE maintenance_request WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_equipement_maintenance ON TABLE equipement_maintenance WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Statuts des demandes de maintenance
INSERT INTO lyxal_constants (
    id: constants:maintenance_request_status,
    category: 'maintenance_request_status',
    values: {
        PLANNED: 0,
        IN_PROGRESS: 1,
        COMPLETED: 2,
        CANCELED: 3
    }
);

-- Actions de maintenance
INSERT INTO lyxal_constants (
    id: constants:maintenance_action,
    category: 'maintenance_action',
    values: {
        CORRECTIVE: 0,
        PREVENTIVE: 1
    }
);

-- Types de création de demande de maintenance
INSERT INTO lyxal_constants (
    id: constants:maintenance_create_request,
    category: 'maintenance_create_request',
    values: {
        MANUAL: 0,
        AUTOMATIC_DAYS: 1,
        AUTOMATIC_CYCLES: 2,
        AUTOMATIC_DURATION: 3
    }
);

-- Priorités des demandes de maintenance
INSERT INTO lyxal_constants (
    id: constants:maintenance_priority,
    category: 'maintenance_priority',
    values: {
        URGENT: 'urgent',
        HIGH: 'high',
        NORMAL: 'normal',
        LOW: 'low'
    }
);

-- Catégories de maintenance par défaut
INSERT INTO maintenance_category (
    id: maintenance_category:preventive,
    name: 'Maintenance préventive',
    code: 'PREVENTIVE',
    description: 'Maintenance planifiée pour prévenir les pannes'
);

INSERT INTO maintenance_category (
    id: maintenance_category:corrective,
    name: 'Maintenance corrective',
    code: 'CORRECTIVE',
    description: 'Maintenance suite à une panne ou un dysfonctionnement'
);

INSERT INTO maintenance_category (
    id: maintenance_category:predictive,
    name: 'Maintenance prédictive',
    code: 'PREDICTIVE',
    description: 'Maintenance basée sur l\'analyse des données'
);

/*
 * RÉSUMÉ DU MODULE MAINTENANCE
 * 
 * Tables créées : 7
 * - maintenance_category : Catégories de maintenance
 * - equipement_maintenance : Équipements de maintenance
 * - maintenance_request : Demandes de maintenance
 * - maintenance_production_config : Configuration de production
 * - maintenance_manuf_order : Ordres de fabrication de maintenance
 * - maintenance_bill_of_material : Nomenclatures de maintenance
 * - maintenance_prod_process : Processus de production de maintenance
 * 
 * Fonctionnalités :
 * - Gestion complète des demandes de maintenance
 * - Planification automatique de la maintenance
 * - Maintenance préventive et corrective
 * - Intégration avec la production
 * - Suivi des équipements
 * - Génération automatique de séquences
 * - Calcul des dates de maintenance
 * 
 * Relations principales :
 * - maintenance_request -> equipement_maintenance
 * - equipement_maintenance -> maintenance_category
 * - maintenance_request -> machine
 * - maintenance_manuf_order -> maintenance_request
 * 
 * MIGRATION AXELOR-MAINTENANCE TERMINÉE
 */ 