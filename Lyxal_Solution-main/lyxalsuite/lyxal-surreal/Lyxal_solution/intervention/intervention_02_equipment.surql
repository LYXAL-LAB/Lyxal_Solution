/*
 * LYXAL SUITE - Module Intervention Equipment
 * Migration depuis axelor-intervention vers SurrealDB
 * 
 * Ce module contient les entités liées aux équipements d'intervention :
 * - Equipment (équipements)
 * - EquipmentFamily (familles d'équipements)
 * - EquipmentLine (lignes d'équipements)
 * - EquipmentModel (modèles d'équipements)
 * - Picture (images d'équipements)
 * 
 * Fonctionnalités :
 * - Gestion des équipements clients
 * - Classification par familles et modèles
 * - Historique des interventions
 * - Gestion des garanties
 * - Photos et documentation
 * 
 * Conformité : SurrealDB v2.0+
 * Date : 2024
 */

-- =============================================
-- TABLE: equipment_family
-- Familles d'équipements pour classification
-- =============================================
DEFINE TABLE equipment_family SCHEMAFULL;

DEFINE FIELD code ON equipment_family TYPE string;
DEFINE FIELD name ON equipment_family TYPE string;
DEFINE FIELD number_of_maintenance_hours ON equipment_family TYPE option<decimal>;
DEFINE FIELD description ON equipment_family TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON equipment_family TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON equipment_family TYPE option<record<user>>;
DEFINE FIELD updated_on ON equipment_family TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON equipment_family TYPE option<record<user>>;
DEFINE FIELD archived ON equipment_family TYPE bool DEFAULT false;
DEFINE FIELD version ON equipment_family TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON equipment_family ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON equipment_family ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_equipment_family_code ON equipment_family FIELDS code UNIQUE;
DEFINE INDEX idx_equipment_family_name ON equipment_family FIELDS name;

-- =============================================
-- TABLE: equipment_model
-- Modèles d'équipements
-- =============================================
DEFINE TABLE equipment_model SCHEMAFULL;

DEFINE FIELD code ON equipment_model TYPE string;
DEFINE FIELD name ON equipment_model TYPE string;
DEFINE FIELD description ON equipment_model TYPE option<string>;
DEFINE FIELD equipment_family ON equipment_model TYPE option<record<equipment_family>>;
DEFINE FIELD brand ON equipment_model TYPE option<string>;
DEFINE FIELD reference ON equipment_model TYPE option<string>;
DEFINE FIELD technical_documentation ON equipment_model TYPE option<string>;

-- Métadonnées communes
DEFINE FIELD created_on ON equipment_model TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON equipment_model TYPE option<record<user>>;
DEFINE FIELD updated_on ON equipment_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON equipment_model TYPE option<record<user>>;
DEFINE FIELD archived ON equipment_model TYPE bool DEFAULT false;
DEFINE FIELD version ON equipment_model TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON equipment_model ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON equipment_model ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_equipment_model_code ON equipment_model FIELDS code UNIQUE;
DEFINE INDEX idx_equipment_model_family ON equipment_model FIELDS equipment_family;

-- =============================================
-- TABLE: equipment
-- Équipements clients
-- =============================================
DEFINE TABLE equipment SCHEMAFULL;

DEFINE FIELD sequence ON equipment TYPE string;
DEFINE FIELD code ON equipment TYPE option<string>;
DEFINE FIELD name ON equipment TYPE string;
DEFINE FIELD type_select ON equipment TYPE string;
DEFINE FIELD in_service ON equipment TYPE bool DEFAULT true;
DEFINE FIELD commissioning_date ON equipment TYPE option<date>;
DEFINE FIELD customer_warranty_on_part_end_date ON equipment TYPE option<date>;
DEFINE FIELD schedule_of_operation ON equipment TYPE option<string>;
DEFINE FIELD specific_access_schedule ON equipment TYPE option<string>;
DEFINE FIELD comments ON equipment TYPE option<string>;
DEFINE FIELD indicator_select ON equipment TYPE option<string>;
DEFINE FIELD partner ON equipment TYPE record<partner>;
DEFINE FIELD parent_equipment ON equipment TYPE option<record<equipment>>;
DEFINE FIELD contract ON equipment TYPE option<record<contract>>;
DEFINE FIELD equipment_family ON equipment TYPE option<record<equipment_family>>;
DEFINE FIELD equipment_model ON equipment TYPE option<record<equipment_model>>;
DEFINE FIELD installation_address ON equipment TYPE option<record<address>>;
DEFINE FIELD serial_number ON equipment TYPE option<string>;
DEFINE FIELD purchase_date ON equipment TYPE option<date>;
DEFINE FIELD purchase_price ON equipment TYPE option<decimal>;
DEFINE FIELD warranty_expiry_date ON equipment TYPE option<date>;

-- Métadonnées communes
DEFINE FIELD created_on ON equipment TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON equipment TYPE option<record<user>>;
DEFINE FIELD updated_on ON equipment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON equipment TYPE option<record<user>>;
DEFINE FIELD archived ON equipment TYPE bool DEFAULT false;
DEFINE FIELD version ON equipment TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD name ON equipment ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD type_select ON equipment ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD partner ON equipment ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_equipment_sequence ON equipment FIELDS sequence UNIQUE;
DEFINE INDEX idx_equipment_code ON equipment FIELDS code;
DEFINE INDEX idx_equipment_partner ON equipment FIELDS partner;
DEFINE INDEX idx_equipment_family ON equipment FIELDS equipment_family;
DEFINE INDEX idx_equipment_model ON equipment FIELDS equipment_model;
DEFINE INDEX idx_equipment_contract ON equipment FIELDS contract;
DEFINE INDEX idx_equipment_parent ON equipment FIELDS parent_equipment;

-- =============================================
-- TABLE: equipment_line
-- Lignes d'équipements (pièces, composants)
-- =============================================
DEFINE TABLE equipment_line SCHEMAFULL;

DEFINE FIELD equipment ON equipment_line TYPE record<equipment>;
DEFINE FIELD product ON equipment_line TYPE option<record<product>>;
DEFINE FIELD quantity ON equipment_line TYPE option<decimal>;
DEFINE FIELD comments ON equipment_line TYPE option<string>;
DEFINE FIELD tracking_number ON equipment_line TYPE option<record<tracking_number>>;
DEFINE FIELD stock_move ON equipment_line TYPE option<record<stock_move>>;
DEFINE FIELD equipment_line_product_label ON equipment_line TYPE option<string>;
DEFINE FIELD installation_date ON equipment_line TYPE option<date>;
DEFINE FIELD replacement_date ON equipment_line TYPE option<date>;
DEFINE FIELD warranty_expiry_date ON equipment_line TYPE option<date>;

-- Métadonnées communes
DEFINE FIELD created_on ON equipment_line TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON equipment_line TYPE option<record<user>>;
DEFINE FIELD updated_on ON equipment_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON equipment_line TYPE option<record<user>>;
DEFINE FIELD archived ON equipment_line TYPE bool DEFAULT false;
DEFINE FIELD version ON equipment_line TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD equipment ON equipment_line ASSERT $value != NONE;

-- Index d'optimisation
DEFINE INDEX idx_equipment_line_equipment ON equipment_line FIELDS equipment;
DEFINE INDEX idx_equipment_line_product ON equipment_line FIELDS product;
DEFINE INDEX idx_equipment_line_tracking ON equipment_line FIELDS tracking_number;

-- =============================================
-- TABLE: picture
-- Images d'équipements
-- =============================================
DEFINE TABLE picture SCHEMAFULL;

DEFINE FIELD equipment ON picture TYPE record<equipment>;
DEFINE FIELD name ON picture TYPE string;
DEFINE FIELD description ON picture TYPE option<string>;
DEFINE FIELD file_path ON picture TYPE string;
DEFINE FIELD file_size ON picture TYPE option<int>;
DEFINE FIELD mime_type ON picture TYPE option<string>;
DEFINE FIELD is_main_picture ON picture TYPE bool DEFAULT false;
DEFINE FIELD taken_date ON picture TYPE option<datetime>;
DEFINE FIELD taken_by ON picture TYPE option<record<user>>;

-- Métadonnées communes
DEFINE FIELD created_on ON picture TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON picture TYPE option<record<user>>;
DEFINE FIELD updated_on ON picture TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON picture TYPE option<record<user>>;
DEFINE FIELD archived ON picture TYPE bool DEFAULT false;
DEFINE FIELD version ON picture TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD equipment ON picture ASSERT $value != NONE;
DEFINE FIELD name ON picture ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD file_path ON picture ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_picture_equipment ON picture FIELDS equipment;
DEFINE INDEX idx_picture_main ON picture FIELDS equipment, is_main_picture;

-- =============================================
-- TABLE: park_model
-- Modèles de parcs d'équipements
-- =============================================
DEFINE TABLE park_model SCHEMAFULL;

DEFINE FIELD code ON park_model TYPE string;
DEFINE FIELD name ON park_model TYPE string;
DEFINE FIELD description ON park_model TYPE option<string>;
DEFINE FIELD equipment_family ON park_model TYPE option<record<equipment_family>>;

-- Métadonnées communes
DEFINE FIELD created_on ON park_model TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON park_model TYPE option<record<user>>;
DEFINE FIELD updated_on ON park_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON park_model TYPE option<record<user>>;
DEFINE FIELD archived ON park_model TYPE bool DEFAULT false;
DEFINE FIELD version ON park_model TYPE int DEFAULT 0;

-- Contraintes
DEFINE FIELD code ON park_model ASSERT $value != NONE AND string::len($value) > 0;
DEFINE FIELD name ON park_model ASSERT $value != NONE AND string::len($value) > 0;

-- Index d'optimisation
DEFINE INDEX idx_park_model_code ON park_model FIELDS code UNIQUE;
DEFINE INDEX idx_park_model_family ON park_model FIELDS equipment_family;

-- =============================================
-- ÉVÉNEMENTS ET DÉCLENCHEURS
-- =============================================

-- Événement : Génération automatique de séquence pour equipment
DEFINE EVENT equipment_sequence ON TABLE equipment WHEN $event = "CREATE" THEN {
    IF $after.sequence == NONE {
        UPDATE $after.id SET sequence = string::concat("EQ", string::slice(string::replace(time::now(), ["-", ":", "T", "."], ""), 2, 14));
    }
};

-- Événement : Calcul du libellé produit pour equipment_line
DEFINE EVENT equipment_line_product_label ON TABLE equipment_line WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $label_parts = [];
    
    IF $after.product != NONE {
        LET $product_info = (SELECT full_name FROM $after.product LIMIT 1);
        IF array::len($product_info) > 0 {
            LET $label_parts = array::append($label_parts, $product_info[0].full_name);
        }
    };
    
    IF $after.tracking_number != NONE {
        LET $tracking_info = (SELECT tracking_number_seq FROM $after.tracking_number LIMIT 1);
        IF array::len($tracking_info) > 0 {
            LET $label_parts = array::append($label_parts, $tracking_info[0].tracking_number_seq);
        }
    };
    
    LET $computed_label = IF array::len($label_parts) > 0 {
        array::join($label_parts, " - ")
    } ELSE {
        ""
    };
    
    UPDATE $after.id SET equipment_line_product_label = $computed_label;
};

-- Événement : Mise à jour automatique du champ updated_on
DEFINE EVENT update_timestamp_equipment ON TABLE equipment WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

DEFINE EVENT update_timestamp_equipment_line ON TABLE equipment_line WHEN $event = "UPDATE" THEN {
    UPDATE $after.id SET updated_on = time::now();
};

-- =============================================
-- DONNÉES DE RÉFÉRENCE
-- =============================================

-- Types d'équipements
INSERT INTO lyxal_constants (
    id: constants:equipment_type,
    category: 'equipment_type',
    values: {
        MACHINE: 'machine',
        TOOL: 'tool',
        SYSTEM: 'system',
        COMPONENT: 'component',
        VEHICLE: 'vehicle',
        BUILDING: 'building',
        OTHER: 'other'
    }
);

-- Indicateurs d'état des équipements
INSERT INTO lyxal_constants (
    id: constants:equipment_indicator,
    category: 'equipment_indicator',
    values: {
        OPERATIONAL: 'operational',
        WARNING: 'warning',
        CRITICAL: 'critical',
        OUT_OF_SERVICE: 'out_of_service',
        MAINTENANCE: 'maintenance'
    }
);

-- Types MIME supportés pour les images
INSERT INTO lyxal_constants (
    id: constants:picture_mime_types,
    category: 'picture_mime_types',
    values: {
        JPEG: 'image/jpeg',
        PNG: 'image/png',
        GIF: 'image/gif',
        WEBP: 'image/webp',
        PDF: 'application/pdf'
    }
);

/*
 * RÉSUMÉ DU MODULE INTERVENTION EQUIPMENT
 * 
 * Tables créées : 6
 * - equipment_family : Familles d'équipements
 * - equipment_model : Modèles d'équipements
 * - equipment : Équipements clients
 * - equipment_line : Lignes/composants d'équipements
 * - picture : Images d'équipements
 * - park_model : Modèles de parcs
 * 
 * Fonctionnalités :
 * - Gestion complète des équipements clients
 * - Classification par familles et modèles
 * - Suivi des garanties et dates importantes
 * - Documentation photographique
 * - Gestion des composants et pièces
 * - Hiérarchie d'équipements (parent/enfant)
 * - Intégration avec contrats et partenaires
 * 
 * Relations principales :
 * - equipment -> partner (propriétaire)
 * - equipment -> equipment_family (classification)
 * - equipment -> contract (contrat de maintenance)
 * - equipment_line -> equipment (appartenance)
 * - picture -> equipment (documentation)
 * 
 * Prochaines étapes :
 * - intervention_03_questions_ranges.surql
 * - intervention_04_support_entities.surql
 */ 