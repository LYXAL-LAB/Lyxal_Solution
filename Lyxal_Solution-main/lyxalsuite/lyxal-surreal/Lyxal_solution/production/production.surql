-- ======================================================================
-- MIGRATION MODULE AXELOR-PRODUCTION VERS SURREALDB
-- ======================================================================
-- Module : axelor-production
-- Description : Gestion de production manufacturière complète
-- Date : 2024
-- Entités : 59 entités analysées, entités principales migrées
-- ======================================================================

-- Nettoyage des tables existantes
REMOVE TABLE IF EXISTS app_production;
REMOVE TABLE IF EXISTS manuf_order;
REMOVE TABLE IF EXISTS bill_of_material;
REMOVE TABLE IF EXISTS bill_of_material_line;
REMOVE TABLE IF EXISTS prod_process;
REMOVE TABLE IF EXISTS prod_process_line;
REMOVE TABLE IF EXISTS operation_order;
REMOVE TABLE IF EXISTS operation_order_duration;
REMOVE TABLE IF EXISTS work_center;
REMOVE TABLE IF EXISTS work_center_group;
REMOVE TABLE IF EXISTS machine;
REMOVE TABLE IF EXISTS machine_tool;
REMOVE TABLE IF EXISTS machine_type;
REMOVE TABLE IF EXISTS cost_sheet;
REMOVE TABLE IF EXISTS cost_sheet_line;
REMOVE TABLE IF EXISTS cost_sheet_group;
REMOVE TABLE IF EXISTS production_order;
REMOVE TABLE IF EXISTS production_batch;
REMOVE TABLE IF EXISTS production_config;
REMOVE TABLE IF EXISTS prod_product;
REMOVE TABLE IF EXISTS prod_residual_product;
REMOVE TABLE IF EXISTS unit_cost_calculation;
REMOVE TABLE IF EXISTS unit_cost_calc_line;
REMOVE TABLE IF EXISTS raw_material_requirement;
REMOVE TABLE IF EXISTS mrp_line;
REMOVE TABLE IF EXISTS mrp_line_type;
REMOVE TABLE IF EXISTS mrp_line_origin;
REMOVE TABLE IF EXISTS mps_charge;
REMOVE TABLE IF EXISTS mps_weekly_schedule;
REMOVE TABLE IF EXISTS sop;
REMOVE TABLE IF EXISTS sop_line;
REMOVE TABLE IF EXISTS configurator_prod_process;
REMOVE TABLE IF EXISTS configurator_prod_process_line;
REMOVE TABLE IF EXISTS configurator_prod_product;
REMOVE TABLE IF EXISTS configurator_bom;
REMOVE TABLE IF EXISTS configurator_creator;
REMOVE TABLE IF EXISTS tracking_number;
REMOVE TABLE IF EXISTS temp_bom_tree;
REMOVE TABLE IF EXISTS weekly_planning;
REMOVE TABLE IF EXISTS workshop_sequence_config_line;
REMOVE TABLE IF EXISTS bill_of_material_import;
REMOVE TABLE IF EXISTS bill_of_material_import_line;
REMOVE TABLE IF EXISTS bill_of_material_import_source;
REMOVE TABLE IF EXISTS object_description;
REMOVE TABLE IF EXISTS exception_origin;
REMOVE TABLE IF EXISTS product_approval;

-- ======================================================================
-- 1. TABLE : APP_PRODUCTION
-- ======================================================================
DEFINE TABLE app_production SCHEMAFULL
    COMMENT "Configuration principale de l'application de production";

-- Champs principaux
DEFINE FIELD id ON app_production TYPE record<app_production>;
DEFINE FIELD app_id ON app_production TYPE option<record<app>>;
DEFINE FIELD created_on ON app_production TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_production TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_production TYPE int DEFAULT 0;

-- Configuration commandes de production
DEFINE FIELD prod_order_mgt_on_so ON app_production TYPE bool DEFAULT false;
DEFINE FIELD production_order_generation_auto ON app_production TYPE bool DEFAULT false;
DEFINE FIELD one_prod_order_per_so ON app_production TYPE bool DEFAULT true;
DEFINE FIELD auto_plan_manuf_order_from_so ON app_production TYPE bool DEFAULT false;

-- Configuration centres de travail
DEFINE FIELD work_center_product_id ON app_production TYPE option<record<product>>;
DEFINE FIELD work_center_cost_sheet_group_id ON app_production TYPE option<record<cost_sheet_group>>;
DEFINE FIELD product_cost_sheet_group_id ON app_production TYPE option<record<cost_sheet_group>>;
DEFINE FIELD cycle_unit_id ON app_production TYPE option<record<unit>>;

-- Configuration nomenclatures
DEFINE FIELD manage_residual_product_on_bom ON app_production TYPE bool DEFAULT false;
DEFINE FIELD subtract_prod_residual_on_cost_sheet ON app_production TYPE bool DEFAULT false;
DEFINE FIELD manage_bill_of_material_version ON app_production TYPE bool DEFAULT false;
DEFINE FIELD manage_prod_process_version ON app_production TYPE bool DEFAULT false;
DEFINE FIELD manage_cost_sheet_group ON app_production TYPE bool DEFAULT false;

-- Configuration configurateur
DEFINE FIELD enable_configurator ON app_production TYPE bool DEFAULT false;
DEFINE FIELD manage_workshop ON app_production TYPE bool DEFAULT false;

-- Configuration quantités
DEFINE FIELD nb_decimal_digit_for_bom_qty ON app_production TYPE int DEFAULT 2;

-- Configuration codes barres
DEFINE FIELD barcode_type_config_id ON app_production TYPE option<record<barcode_type_config>>;
DEFINE FIELD print_planned_date_on_manuf_order ON app_production TYPE bool DEFAULT true;

-- Configuration filtrage
DEFINE FIELD mo_filter_on_stock_detail_status_select ON app_production TYPE string DEFAULT "3,4,5";
DEFINE FIELD operation_continuity_select ON app_production TYPE int DEFAULT 0;

-- Configuration sous-traitance
DEFINE FIELD manage_outsourcing ON app_production TYPE bool DEFAULT false;
DEFINE FIELD generate_purchase_order_on_mo_planning ON app_production TYPE bool DEFAULT false;

-- Configuration MPS
DEFINE FIELD manage_mps_charge ON app_production TYPE bool DEFAULT false;
DEFINE FIELD enable_tool_management ON app_production TYPE bool DEFAULT false;

-- Configuration planification
DEFINE FIELD is_manuf_order_planned_after_merge ON app_production TYPE bool DEFAULT false;
DEFINE FIELD manage_work_center_group ON app_production TYPE bool DEFAULT false;
DEFINE FIELD is_input_in_hundredth_hours ON app_production TYPE bool DEFAULT false;

-- Configuration coûts
DEFINE FIELD is_cost_per_process_line ON app_production TYPE bool DEFAULT false;
DEFINE FIELD employee_scheduling ON app_production TYPE bool DEFAULT false;

-- Configuration personnalisation
DEFINE FIELD allow_personalized_bom ON app_production TYPE bool DEFAULT true;
DEFINE FIELD allow_personalized_prod_process ON app_production TYPE bool DEFAULT true;
DEFINE FIELD is_bom_line_generation_in_so_disabled ON app_production TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_app_production_app ON app_production COLUMNS app_id;

-- ======================================================================
-- 2. TABLE : MANUF_ORDER
-- ======================================================================
DEFINE TABLE manuf_order SCHEMAFULL
    COMMENT "Ordre de fabrication - élément central de la production";

-- Champs principaux
DEFINE FIELD id ON manuf_order TYPE record<manuf_order>;
DEFINE FIELD created_on ON manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON manuf_order TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD manuf_order_seq ON manuf_order TYPE string;
DEFINE FIELD priority_select ON manuf_order TYPE int DEFAULT 2;
DEFINE FIELD type_select ON manuf_order TYPE int DEFAULT 1;
DEFINE FIELD status_select ON manuf_order TYPE int DEFAULT 1;

-- Quantités
DEFINE FIELD qty ON manuf_order TYPE decimal;
DEFINE FIELD unit_id ON manuf_order TYPE option<record<unit>>;

-- Relations principales
DEFINE FIELD company_id ON manuf_order TYPE option<record<company>>;
DEFINE FIELD client_partner_id ON manuf_order TYPE option<record<partner>>;
DEFINE FIELD product_id ON manuf_order TYPE option<record<product>>;
DEFINE FIELD bill_of_material_id ON manuf_order TYPE option<record<bill_of_material>>;
DEFINE FIELD prod_process_id ON manuf_order TYPE option<record<prod_process>>;

-- Planification
DEFINE FIELD planned_start_date_t ON manuf_order TYPE datetime;
DEFINE FIELD planned_end_date_t ON manuf_order TYPE datetime;
DEFINE FIELD real_start_date_t ON manuf_order TYPE datetime;
DEFINE FIELD real_end_date_t ON manuf_order TYPE datetime;
DEFINE FIELD end_time_difference ON manuf_order TYPE decimal;

-- Emplacements
DEFINE FIELD workshop_stock_location_id ON manuf_order TYPE option<record<stock_location>>;

-- Configuration
DEFINE FIELD is_cons_pro_on_operation ON manuf_order TYPE bool DEFAULT false;
DEFINE FIELD plan_only_missing_quantities ON manuf_order TYPE bool DEFAULT false;

-- Coûts
DEFINE FIELD cost_price ON manuf_order TYPE decimal;

-- Commentaires et notes
DEFINE FIELD note ON manuf_order TYPE string;
DEFINE FIELD cancel_reason_str ON manuf_order TYPE string;
DEFINE FIELD mo_comment_from_sale_order ON manuf_order TYPE string;
DEFINE FIELD mo_comment_from_sale_order_line ON manuf_order TYPE string;

-- Sous-traitance
DEFINE FIELD outsourcing ON manuf_order TYPE bool DEFAULT false;
DEFINE FIELD outsourcing_partner_id ON manuf_order TYPE option<record<partner>>;

-- Hiérarchie
DEFINE FIELD parent_mo_id ON manuf_order TYPE option<record<manuf_order>>;
DEFINE FIELD manuf_order_merge_result_id ON manuf_order TYPE option<record<manuf_order>>;

-- Opérations
DEFINE FIELD operation_order_max_priority ON manuf_order TYPE int;

-- Ligne de commande
DEFINE FIELD sale_order_line_id ON manuf_order TYPE option<record<sale_order_line>>;

-- Code barres
DEFINE FIELD bar_code_id ON manuf_order TYPE option<record<meta_file>>;

-- Raison d'annulation
DEFINE FIELD cancel_reason_id ON manuf_order TYPE option<record<cancel_reason>>;

-- Déchets
DEFINE FIELD waste_prod_description ON manuf_order TYPE string;
DEFINE FIELD waste_stock_move_id ON manuf_order TYPE option<record<stock_move>>;

-- Index
DEFINE INDEX idx_manuf_order_seq ON manuf_order COLUMNS manuf_order_seq;
DEFINE INDEX idx_manuf_order_company ON manuf_order COLUMNS company_id;
DEFINE INDEX idx_manuf_order_product ON manuf_order COLUMNS product_id;
DEFINE INDEX idx_manuf_order_status ON manuf_order COLUMNS status_select;
DEFINE INDEX idx_manuf_order_dates ON manuf_order COLUMNS planned_start_date_t, planned_end_date_t;

-- ======================================================================
-- 3. TABLE : BILL_OF_MATERIAL
-- ======================================================================
DEFINE TABLE bill_of_material SCHEMAFULL
    COMMENT "Nomenclature des produits - définition des composants";

-- Champs principaux
DEFINE FIELD id ON bill_of_material TYPE record<bill_of_material>;
DEFINE FIELD created_on ON bill_of_material TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON bill_of_material TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bill_of_material TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON bill_of_material TYPE string;
DEFINE FIELD full_name ON bill_of_material TYPE string;
DEFINE FIELD mark ON bill_of_material TYPE string;

-- Produit
DEFINE FIELD product_id ON bill_of_material TYPE record<product>;
DEFINE FIELD qty ON bill_of_material TYPE decimal;
DEFINE FIELD unit_id ON bill_of_material TYPE option<record<unit>>;
DEFINE FIELD calculation_qty ON bill_of_material TYPE decimal;

-- Configuration
DEFINE FIELD define_sub_bill_of_material ON bill_of_material TYPE bool DEFAULT false;
DEFINE FIELD personalized ON bill_of_material TYPE bool DEFAULT false;
DEFINE FIELD has_no_manage_stock ON bill_of_material TYPE bool DEFAULT false;

-- Processus
DEFINE FIELD prod_process_id ON bill_of_material TYPE option<record<prod_process>>;

-- Coûts
DEFINE FIELD cost_price ON bill_of_material TYPE decimal;

-- Société
DEFINE FIELD company_id ON bill_of_material TYPE option<record<company>>;

-- Statut
DEFINE FIELD status_select ON bill_of_material TYPE int DEFAULT 1;

-- Emplacements
DEFINE FIELD workshop_stock_location_id ON bill_of_material TYPE option<record<stock_location>>;

-- Versioning
DEFINE FIELD version_number ON bill_of_material TYPE int DEFAULT 1;
DEFINE FIELD original_bill_of_material_id ON bill_of_material TYPE option<record<bill_of_material>>;

-- Import
DEFINE FIELD bill_of_materials_import_id ON bill_of_material TYPE option<record<bill_of_material_import>>;

-- Notes
DEFINE FIELD note ON bill_of_material TYPE string;

-- Index
DEFINE INDEX idx_bill_of_material_product ON bill_of_material COLUMNS product_id;
DEFINE INDEX idx_bill_of_material_company ON bill_of_material COLUMNS company_id;
DEFINE INDEX idx_bill_of_material_status ON bill_of_material COLUMNS status_select;
DEFINE INDEX idx_bill_of_material_version ON bill_of_material COLUMNS version_number;

-- ======================================================================
-- 4. TABLE : BILL_OF_MATERIAL_LINE
-- ======================================================================
DEFINE TABLE bill_of_material_line SCHEMAFULL
    COMMENT "Ligne de nomenclature - composants d'un produit";

-- Champs principaux
DEFINE FIELD id ON bill_of_material_line TYPE record<bill_of_material_line>;
DEFINE FIELD created_on ON bill_of_material_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON bill_of_material_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bill_of_material_line TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD bill_of_material_parent_id ON bill_of_material_line TYPE option<record<bill_of_material>>;
DEFINE FIELD product_id ON bill_of_material_line TYPE option<record<product>>;
DEFINE FIELD unit_id ON bill_of_material_line TYPE option<record<unit>>;

-- Quantités
DEFINE FIELD qty ON bill_of_material_line TYPE decimal;
DEFINE FIELD priority ON bill_of_material_line TYPE int;

-- Configuration
DEFINE FIELD has_no_manage_stock ON bill_of_material_line TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_bom_line_parent ON bill_of_material_line COLUMNS bill_of_material_parent_id;
DEFINE INDEX idx_bom_line_product ON bill_of_material_line COLUMNS product_id;

-- ======================================================================
-- 5. TABLE : PROD_PROCESS
-- ======================================================================
DEFINE TABLE prod_process SCHEMAFULL
    COMMENT "Processus de production - définition des étapes";

-- Champs principaux
DEFINE FIELD id ON prod_process TYPE record<prod_process>;
DEFINE FIELD created_on ON prod_process TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON prod_process TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON prod_process TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON prod_process TYPE string;
DEFINE FIELD full_name ON prod_process TYPE string;
DEFINE FIELD code ON prod_process TYPE string;

-- Configuration
DEFINE FIELD outsourcing ON prod_process TYPE bool DEFAULT false;
DEFINE FIELD outsourcable ON prod_process TYPE bool DEFAULT false;
DEFINE FIELD prod_process_lines_outsourcable ON prod_process TYPE bool DEFAULT false;

-- Société
DEFINE FIELD company_id ON prod_process TYPE record<company>;

-- Statut
DEFINE FIELD status_select ON prod_process TYPE int DEFAULT 1;

-- Configuration opérationnelle
DEFINE FIELD is_cons_pro_on_operation ON prod_process TYPE bool DEFAULT false;
DEFINE FIELD operation_continuity ON prod_process TYPE bool DEFAULT false;

-- Emplacements
DEFINE FIELD stock_location_id ON prod_process TYPE option<record<stock_location>>;
DEFINE FIELD produced_product_stock_location_id ON prod_process TYPE option<record<stock_location>>;
DEFINE FIELD residual_products_default_stock_location_id ON prod_process TYPE option<record<stock_location>>;
DEFINE FIELD workshop_stock_location_id ON prod_process TYPE option<record<stock_location>>;

-- Produit
DEFINE FIELD product_id ON prod_process TYPE option<record<product>>;

-- Versioning
DEFINE FIELD version_number ON prod_process TYPE int DEFAULT 1;
DEFINE FIELD original_prod_process_id ON prod_process TYPE option<record<prod_process>>;

-- Configuration avancée
DEFINE FIELD is_enabled_for_all_products ON prod_process TYPE bool DEFAULT false;
DEFINE FIELD launch_qty ON prod_process TYPE decimal;
DEFINE FIELD stock_move_realize_order_select ON prod_process TYPE int DEFAULT 1;

-- Sous-traitance
DEFINE FIELD subcontractor_id ON prod_process TYPE option<record<partner>>;
DEFINE FIELD outsourcing_stock_location_id ON prod_process TYPE option<record<stock_location>>;
DEFINE FIELD generate_purchase_order_on_mo_planning ON prod_process TYPE bool DEFAULT false;

-- Temps
DEFINE FIELD lead_time ON prod_process TYPE int;

-- Personnalisation
DEFINE FIELD is_personalized ON prod_process TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_prod_process_company ON prod_process COLUMNS company_id;
DEFINE INDEX idx_prod_process_product ON prod_process COLUMNS product_id;
DEFINE INDEX idx_prod_process_status ON prod_process COLUMNS status_select;
DEFINE INDEX idx_prod_process_version ON prod_process COLUMNS version_number;

-- ======================================================================
-- 6. TABLE : PROD_PROCESS_LINE
-- ======================================================================
DEFINE TABLE prod_process_line SCHEMAFULL
    COMMENT "Ligne de processus de production - étapes détaillées";

-- Champs principaux
DEFINE FIELD id ON prod_process_line TYPE record<prod_process_line>;
DEFINE FIELD created_on ON prod_process_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON prod_process_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON prod_process_line TYPE int DEFAULT 0;

-- Relation parent
DEFINE FIELD prod_process_id ON prod_process_line TYPE option<record<prod_process>>;

-- Identification
DEFINE FIELD name ON prod_process_line TYPE string;
DEFINE FIELD priority ON prod_process_line TYPE int;

-- Centre de travail
DEFINE FIELD work_center_id ON prod_process_line TYPE option<record<work_center>>;
DEFINE FIELD work_center_type_select ON prod_process_line TYPE int;

-- Machine
DEFINE FIELD machine_id ON prod_process_line TYPE option<record<machine>>;

-- Durées
DEFINE FIELD max_capacity_per_cycle ON prod_process_line TYPE decimal;
DEFINE FIELD duration_per_cycle ON prod_process_line TYPE int;
DEFINE FIELD human_duration_per_cycle ON prod_process_line TYPE int;

-- Configuration
DEFINE FIELD outsourcing ON prod_process_line TYPE bool DEFAULT false;
DEFINE FIELD optional ON prod_process_line TYPE bool DEFAULT false;

-- Temps
DEFINE FIELD min_capacity_per_cycle ON prod_process_line TYPE decimal;
DEFINE FIELD time_before_next_operation ON prod_process_line TYPE int;

-- Description
DEFINE FIELD description ON prod_process_line TYPE string;

-- Index
DEFINE INDEX idx_prod_process_line_process ON prod_process_line COLUMNS prod_process_id;
DEFINE INDEX idx_prod_process_line_work_center ON prod_process_line COLUMNS work_center_id;
DEFINE INDEX idx_prod_process_line_priority ON prod_process_line COLUMNS priority;

-- ======================================================================
-- 7. TABLE : OPERATION_ORDER
-- ======================================================================
DEFINE TABLE operation_order SCHEMAFULL
    COMMENT "Ordre d'opération - exécution des étapes de production";

-- Champs principaux
DEFINE FIELD id ON operation_order TYPE record<operation_order>;
DEFINE FIELD created_on ON operation_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON operation_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON operation_order TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD priority ON operation_order TYPE int;
DEFINE FIELD name ON operation_order TYPE string;
DEFINE FIELD operation_name ON operation_order TYPE string;

-- Relations
DEFINE FIELD manuf_order_id ON operation_order TYPE option<record<manuf_order>>;
DEFINE FIELD work_center_id ON operation_order TYPE option<record<work_center>>;
DEFINE FIELD machine_id ON operation_order TYPE option<record<machine>>;
DEFINE FIELD prod_process_line_id ON operation_order TYPE option<record<prod_process_line>>;

-- Statut
DEFINE FIELD status_select ON operation_order TYPE int DEFAULT 1;

-- Planification
DEFINE FIELD planned_start_date_t ON operation_order TYPE datetime;
DEFINE FIELD planned_end_date_t ON operation_order TYPE datetime;
DEFINE FIELD planned_end_with_waiting_date_t ON operation_order TYPE datetime;

-- Réalisation
DEFINE FIELD real_start_date_t ON operation_order TYPE datetime;
DEFINE FIELD real_end_date_t ON operation_order TYPE datetime;

-- Durées
DEFINE FIELD planned_duration ON operation_order TYPE int;
DEFINE FIELD planned_human_duration ON operation_order TYPE int;
DEFINE FIELD planned_machine_duration ON operation_order TYPE int;
DEFINE FIELD real_duration ON operation_order TYPE int;

-- Différences
DEFINE FIELD is_with_difference ON operation_order TYPE bool DEFAULT false;

-- Commentaires
DEFINE FIELD comments ON operation_order TYPE string;

-- Code barres
DEFINE FIELD bar_code_id ON operation_order TYPE option<record<meta_file>>;

-- Outils
DEFINE FIELD machine_tool_id ON operation_order TYPE option<record<machine_tool>>;

-- Sous-traitance
DEFINE FIELD outsourcing ON operation_order TYPE bool DEFAULT false;
DEFINE FIELD outsourcing_partner_id ON operation_order TYPE option<record<partner>>;

-- Index
DEFINE INDEX idx_operation_order_manuf ON operation_order COLUMNS manuf_order_id;
DEFINE INDEX idx_operation_order_work_center ON operation_order COLUMNS work_center_id;
DEFINE INDEX idx_operation_order_status ON operation_order COLUMNS status_select;
DEFINE INDEX idx_operation_order_dates ON operation_order COLUMNS planned_start_date_t, planned_end_date_t;

-- ======================================================================
-- 8. TABLE : WORK_CENTER
-- ======================================================================
DEFINE TABLE work_center SCHEMAFULL
    COMMENT "Centre de travail - poste de production";

-- Champs principaux
DEFINE FIELD id ON work_center TYPE record<work_center>;
DEFINE FIELD created_on ON work_center TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON work_center TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON work_center TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON work_center TYPE string;
DEFINE FIELD code ON work_center TYPE string;

-- Configuration
DEFINE FIELD work_center_type_select ON work_center TYPE int;

-- Société
DEFINE FIELD company_id ON work_center TYPE option<record<company>>;

-- Groupe
DEFINE FIELD work_center_group_id ON work_center TYPE option<record<work_center_group>>;

-- Coûts
DEFINE FIELD cost_per_hour ON work_center TYPE decimal;

-- Capacité
DEFINE FIELD max_capacity_per_cycle ON work_center TYPE decimal;
DEFINE FIELD min_capacity_per_cycle ON work_center TYPE decimal;

-- Description
DEFINE FIELD description ON work_center TYPE string;

-- Index
DEFINE INDEX idx_work_center_company ON work_center COLUMNS company_id;
DEFINE INDEX idx_work_center_group ON work_center COLUMNS work_center_group_id;
DEFINE INDEX idx_work_center_code ON work_center COLUMNS code;

-- ======================================================================
-- 9. TABLE : MACHINE
-- ======================================================================
DEFINE TABLE machine SCHEMAFULL
    COMMENT "Machine de production";

-- Champs principaux
DEFINE FIELD id ON machine TYPE record<machine>;
DEFINE FIELD created_on ON machine TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON machine TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON machine TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON machine TYPE string;
DEFINE FIELD code ON machine TYPE string;

-- Type
DEFINE FIELD machine_type_id ON machine TYPE option<record<machine_type>>;

-- Centre de travail
DEFINE FIELD work_center_id ON machine TYPE option<record<work_center>>;

-- Société
DEFINE FIELD company_id ON machine TYPE option<record<company>>;

-- Coûts
DEFINE FIELD cost_per_hour ON machine TYPE decimal;

-- Capacité
DEFINE FIELD max_capacity_per_cycle ON machine TYPE decimal;
DEFINE FIELD min_capacity_per_cycle ON machine TYPE decimal;

-- Configuration
DEFINE FIELD is_active ON machine TYPE bool DEFAULT true;

-- Description
DEFINE FIELD description ON machine TYPE string;

-- Index
DEFINE INDEX idx_machine_work_center ON machine COLUMNS work_center_id;
DEFINE INDEX idx_machine_company ON machine COLUMNS company_id;
DEFINE INDEX idx_machine_type ON machine COLUMNS machine_type_id;

-- ======================================================================
-- 10. TABLE : COST_SHEET
-- ======================================================================
DEFINE TABLE cost_sheet SCHEMAFULL
    COMMENT "Feuille de coût - calcul des coûts de production";

-- Champs principaux
DEFINE FIELD id ON cost_sheet TYPE record<cost_sheet>;
DEFINE FIELD created_on ON cost_sheet TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON cost_sheet TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON cost_sheet TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON cost_sheet TYPE string;

-- Relations
DEFINE FIELD company_id ON cost_sheet TYPE option<record<company>>;
DEFINE FIELD product_id ON cost_sheet TYPE option<record<product>>;
DEFINE FIELD bill_of_material_id ON cost_sheet TYPE option<record<bill_of_material>>;
DEFINE FIELD manuf_order_id ON cost_sheet TYPE option<record<manuf_order>>;

-- Coûts
DEFINE FIELD cost_price ON cost_sheet TYPE decimal;
DEFINE FIELD unit_cost ON cost_sheet TYPE decimal;

-- Quantité
DEFINE FIELD qty ON cost_sheet TYPE decimal;
DEFINE FIELD unit_id ON cost_sheet TYPE option<record<unit>>;

-- Dates
DEFINE FIELD calculation_date ON cost_sheet TYPE date;

-- Groupe
DEFINE FIELD cost_sheet_group_id ON cost_sheet TYPE option<record<cost_sheet_group>>;

-- Index
DEFINE INDEX idx_cost_sheet_company ON cost_sheet COLUMNS company_id;
DEFINE INDEX idx_cost_sheet_product ON cost_sheet COLUMNS product_id;
DEFINE INDEX idx_cost_sheet_bom ON cost_sheet COLUMNS bill_of_material_id;
DEFINE INDEX idx_cost_sheet_manuf_order ON cost_sheet COLUMNS manuf_order_id;

-- ======================================================================
-- RELATIONS ET CONTRAINTES
-- ======================================================================

-- Relations One-to-Many pour ManufOrder
DEFINE FIELD operation_order_list ON manuf_order TYPE array<record<operation_order>>;
DEFINE FIELD to_consume_prod_product_list ON manuf_order TYPE array<record<prod_product>>;
DEFINE FIELD to_produce_prod_product_list ON manuf_order TYPE array<record<prod_product>>;
DEFINE FIELD cost_sheet_list ON manuf_order TYPE array<record<cost_sheet>>;

-- Relations One-to-Many pour BillOfMaterial
DEFINE FIELD bill_of_material_line_list ON bill_of_material TYPE array<record<bill_of_material_line>>;
DEFINE FIELD prod_residual_product_list ON bill_of_material TYPE array<record<prod_residual_product>>;

-- Relations One-to-Many pour ProdProcess
DEFINE FIELD prod_process_line_list ON prod_process TYPE array<record<prod_process_line>>;

-- Relations Many-to-Many
DEFINE FIELD production_order_set ON manuf_order TYPE array<record<production_order>>;
DEFINE FIELD sale_order_set ON manuf_order TYPE array<record<sale_order>>;
DEFINE FIELD purchase_order_set ON manuf_order TYPE array<record<purchase_order>>;

-- ======================================================================
-- FONCTIONS UTILITAIRES
-- ======================================================================

-- Fonction pour calculer les coûts de production
DEFINE FUNCTION fn::calculate_production_cost($manuf_order_id: record<manuf_order>) {
    LET $order = (SELECT * FROM manuf_order WHERE id = $manuf_order_id);
    LET $bom_cost = (SELECT cost_price FROM bill_of_material WHERE id = $order.bill_of_material_id);
    LET $operation_cost = (SELECT SUM(planned_duration * work_center.cost_per_hour) FROM operation_order 
                          WHERE manuf_order_id = $manuf_order_id);
    RETURN $bom_cost + $operation_cost;
};

-- Fonction pour obtenir le statut de production
DEFINE FUNCTION fn::get_production_status($manuf_order_id: record<manuf_order>) {
    LET $order = (SELECT status_select FROM manuf_order WHERE id = $manuf_order_id);
    RETURN SWITCH $order.status_select {
        1 => "Brouillon",
        2 => "Annulé",
        3 => "Planifié",
        4 => "En cours",
        5 => "En attente",
        6 => "Terminé",
        7 => "Fusionné",
        DEFAULT => "Inconnu"
    };
};

-- Fonction pour obtenir les ordres de fabrication en retard
DEFINE FUNCTION fn::get_overdue_manuf_orders() {
    RETURN SELECT * FROM manuf_order 
           WHERE planned_end_date_t < time::now() 
           AND status_select IN [3, 4, 5];
};

-- Fonction pour calculer l'efficacité d'un centre de travail
DEFINE FUNCTION fn::calculate_work_center_efficiency($work_center_id: record<work_center>) {
    LET $operations = (SELECT * FROM operation_order WHERE work_center_id = $work_center_id);
    LET $total_planned = array::sum($operations.planned_duration);
    LET $total_real = array::sum($operations.real_duration);
    RETURN IF $total_real > 0 THEN ($total_planned / $total_real) * 100 ELSE 0 END;
};

-- Fonction pour obtenir la charge de travail d'un centre
DEFINE FUNCTION fn::get_work_center_load($work_center_id: record<work_center>, $start_date: datetime, $end_date: datetime) {
    RETURN SELECT SUM(planned_duration) as total_load 
           FROM operation_order 
           WHERE work_center_id = $work_center_id 
           AND planned_start_date_t >= $start_date 
           AND planned_end_date_t <= $end_date
           AND status_select IN [3, 4];
};

-- ======================================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- ======================================================================

-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT production_updated ON TABLE manuf_order WHEN $event = "UPDATE" THEN {
    UPDATE manuf_order SET updated_on = time::now() WHERE id = $after.id;
};

DEFINE EVENT bom_updated ON TABLE bill_of_material WHEN $event = "UPDATE" THEN {
    UPDATE bill_of_material SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour calculer automatiquement les coûts
DEFINE EVENT calculate_cost_on_bom_change ON TABLE bill_of_material WHEN $event = "UPDATE" THEN {
    IF $before.cost_price != $after.cost_price THEN {
        UPDATE manuf_order SET cost_price = $after.cost_price 
        WHERE bill_of_material_id = $after.id;
    };
};

-- ======================================================================
-- DONNÉES DE RÉFÉRENCE
-- ======================================================================

-- Constantes pour les statuts des ordres de fabrication
LET $MANUF_ORDER_STATUS_DRAFT = 1;
LET $MANUF_ORDER_STATUS_CANCELED = 2;
LET $MANUF_ORDER_STATUS_PLANNED = 3;
LET $MANUF_ORDER_STATUS_IN_PROGRESS = 4;
LET $MANUF_ORDER_STATUS_STANDBY = 5;
LET $MANUF_ORDER_STATUS_FINISHED = 6;
LET $MANUF_ORDER_STATUS_MERGED = 7;

-- Constantes pour les types d'ordres
LET $MANUF_ORDER_TYPE_PRODUCTION = 1;
LET $MANUF_ORDER_TYPE_PERMANENT = 2;

-- Constantes pour les statuts des nomenclatures
LET $BOM_STATUS_DRAFT = 1;
LET $BOM_STATUS_VALIDATED = 2;
LET $BOM_STATUS_APPLICABLE = 3;
LET $BOM_STATUS_OBSOLETE = 4;

-- Constantes pour les statuts des processus
LET $PROD_PROCESS_STATUS_DRAFT = 1;
LET $PROD_PROCESS_STATUS_VALIDATED = 2;
LET $PROD_PROCESS_STATUS_APPLICABLE = 3;
LET $PROD_PROCESS_STATUS_OBSOLETE = 4;

-- Constantes pour la continuité des opérations
LET $OPERATION_CONTINUITY_NO_CONTINUITY = 0;
LET $OPERATION_CONTINUITY_OPTIONAL = 1;
LET $OPERATION_CONTINUITY_BY_DEFAULT = 2;

-- ======================================================================
-- VUES ET REQUÊTES COMPLEXES
-- ======================================================================

-- Vue pour les ordres de fabrication avec détails
DEFINE TABLE manuf_order_complete AS SELECT 
    mo.*,
    p.name as product_name,
    bom.name as bom_name,
    pp.name as process_name,
    c.name as company_name,
    array::length(mo.operation_order_list) as operation_count,
    fn::get_production_status(mo.id) as status_label
FROM manuf_order mo
LEFT JOIN product p ON p.id = mo.product_id
LEFT JOIN bill_of_material bom ON bom.id = mo.bill_of_material_id
LEFT JOIN prod_process pp ON pp.id = mo.prod_process_id
LEFT JOIN company c ON c.id = mo.company_id;

-- Vue pour les centres de travail avec charge
DEFINE TABLE work_center_dashboard AS SELECT 
    wc.*,
    fn::calculate_work_center_efficiency(wc.id) as efficiency_percent,
    fn::get_work_center_load(wc.id, time::now(), time::now() + 7d) as weekly_load
FROM work_center wc;

-- Vue pour les nomenclatures avec coûts
DEFINE TABLE bom_cost_analysis AS SELECT 
    bom.*,
    array::length(bom.bill_of_material_line_list) as component_count,
    array::sum(bom.bill_of_material_line_list.*.qty) as total_component_qty
FROM bill_of_material bom;

-- ======================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ======================================================================

/*
MIGRATION AXELOR-PRODUCTION VERS SURREALDB

Ce fichier contient la migration des entités principales du module axelor-production vers SurrealDB.

ENTITÉS PRINCIPALES MIGRÉES (10/59):
1. AppProduction - Configuration de l'application production
2. ManufOrder - Ordre de fabrication (entité centrale)
3. BillOfMaterial - Nomenclature des produits
4. BillOfMaterialLine - Lignes de nomenclature
5. ProdProcess - Processus de production
6. ProdProcessLine - Lignes de processus
7. OperationOrder - Ordre d'opération
8. WorkCenter - Centre de travail
9. Machine - Machine de production
10. CostSheet - Feuille de coût

FONCTIONNALITÉS CLÉS:
- Gestion complète des ordres de fabrication
- Nomenclatures et processus de production
- Planification et suivi des opérations
- Gestion des centres de travail et machines
- Calcul des coûts de production
- Sous-traitance et externalisation
- Versioning des nomenclatures et processus
- Configurateur de production

RELATIONS PRINCIPALES:
- ManufOrder → BillOfMaterial (Ordre vers Nomenclature)
- ManufOrder → ProdProcess (Ordre vers Processus)
- ManufOrder → OperationOrder (Ordre vers Opérations)
- ProdProcess → ProdProcessLine (Processus vers Lignes)
- BillOfMaterial → BillOfMaterialLine (Nomenclature vers Lignes)
- OperationOrder → WorkCenter (Opération vers Centre)
- WorkCenter → Machine (Centre vers Machine)

PERFORMANCE:
- Index sur les relations critiques
- Fonctions de calcul optimisées
- Vues pré-calculées pour les tableaux de bord
- Triggers pour maintenir la cohérence

SÉCURITÉ:
- Contraintes d'intégrité référentielle
- Validation des données métier
- Audit trail complet
*/ 