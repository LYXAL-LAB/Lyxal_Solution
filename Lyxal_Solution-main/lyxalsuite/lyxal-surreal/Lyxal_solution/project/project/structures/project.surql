-- ======================================================================
--  TABLE : PROJECT
-- ======================================================================
DEFINE TABLE project SCHEMAFULL
    COMMENT "Projet - entité centrale de gestion de projet";

-- Champs principaux
DEFINE FIELD id ON project TYPE record<project>;
DEFINE FIELD created_on ON project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project TYPE string;
DEFINE FIELD full_name ON project TYPE string;
DEFINE FIELD code ON project TYPE string;
DEFINE FIELD description ON project TYPE string;

-- Relations de base
DEFINE FIELD company_id ON project TYPE option<record<company>>;
DEFINE FIELD team_id ON project TYPE option<record<team>>;
DEFINE FIELD assigned_to_id ON project TYPE option<record<user>>;
DEFINE FIELD project_status_id ON project TYPE option<record<project_status>>;

-- Relations clients
DEFINE FIELD client_partner_id ON project TYPE option<record<partner>>;
DEFINE FIELD contact_partner_id ON project TYPE option<record<partner>>;

-- Hiérarchie de projets
DEFINE FIELD parent_project_id ON project TYPE option<record<project>>;
DEFINE FIELD extends_members_from_parent ON project TYPE bool DEFAULT false;

-- Dates et planification
DEFINE FIELD from_date ON project TYPE datetime;
DEFINE FIELD to_date ON project TYPE datetime;
DEFINE FIELD estimated_time_hrs ON project TYPE decimal;
DEFINE FIELD number_hours_a_day ON project TYPE decimal;

-- Configuration
DEFINE FIELD sequence ON project TYPE decimal;
DEFINE FIELD order_by_state ON project TYPE int;
DEFINE FIELD synchronize ON project TYPE bool DEFAULT false;

-- Membres et équipe
DEFINE FIELD members_user_set ON project TYPE array<record<user>>;

-- Relations de dépendances
DEFINE FIELD finish_to_start_task_set ON project TYPE array<record<project>>;
DEFINE FIELD start_to_start_task_set ON project TYPE array<record<project>>;
DEFINE FIELD finish_to_finish_task_set ON project TYPE array<record<project>>;
DEFINE FIELD start_to_finish_task_set ON project TYPE array<record<project>>;

-- Produits autorisés
DEFINE FIELD product_set ON project TYPE array<record<product>>;

-- Configuration affichage
DEFINE FIELD is_show_phases_elements ON project TYPE bool DEFAULT false;
DEFINE FIELD gen_proj_type_per_order_line ON project TYPE string DEFAULT "BUSINESS_PROJECT";

-- Séquence des tâches
DEFINE FIELD next_project_task_sequence ON project TYPE int DEFAULT 1;

-- Unité de temps
DEFINE FIELD project_time_unit_id ON project TYPE option<record<unit>>;

-- Sites
DEFINE FIELD site_set ON project TYPE array<record<site>>;

-- Configuration gestion des statuts
DEFINE FIELD task_status_management_select ON project TYPE int DEFAULT 2;
DEFINE FIELD project_task_status_set ON project TYPE array<record<task_status>>;

-- Configuration affichage des éléments
DEFINE FIELD is_show_priority ON project TYPE bool DEFAULT true;
DEFINE FIELD project_task_priority_set ON project TYPE array<record<project_priority>>;
DEFINE FIELD is_show_task_category ON project TYPE bool DEFAULT true;
DEFINE FIELD project_task_category_set ON project TYPE array<record<project_task_category>>;
DEFINE FIELD is_show_progress ON project TYPE bool DEFAULT true;
DEFINE FIELD is_show_planning ON project TYPE bool DEFAULT true;
DEFINE FIELD is_show_frequency ON project TYPE bool DEFAULT false;
DEFINE FIELD manage_time_spent ON project TYPE bool DEFAULT true;

-- Configuration vues
DEFINE FIELD is_show_topic ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_gantt ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_kanban_per_status ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_kanban_per_category ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_calendar_per_status ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_calendar_per_category ON project TYPE bool DEFAULT false;
DEFINE FIELD is_show_calendar_per_user ON project TYPE bool DEFAULT false;

-- Configuration avancée
DEFINE FIELD completed_task_status_id ON project TYPE option<record<task_status>>;
DEFINE FIELD project_task_link_type_set ON project TYPE array<record<project_task_link_type>>;
DEFINE FIELD custom_field_management_select ON project TYPE string DEFAULT "app";
DEFINE FIELD enable_status_progress_by_category ON project TYPE bool DEFAULT false;

-- Wiki et description
DEFINE FIELD wiki_description ON project TYPE string;

-- Relations One-to-Many
DEFINE FIELD project_task_list ON project TYPE array<record<project_task>>;
DEFINE FIELD resource_booking_list ON project TYPE array<record<resource_booking>>;

-- Index
DEFINE INDEX idx_project_company ON project COLUMNS company_id;
DEFINE INDEX idx_project_status ON project COLUMNS project_status_id;
DEFINE INDEX idx_project_assigned_to ON project COLUMNS assigned_to_id;
DEFINE INDEX idx_project_parent ON project COLUMNS parent_project_id;
DEFINE INDEX idx_project_code ON project COLUMNS code UNIQUE;
DEFINE INDEX idx_project_dates ON project COLUMNS from_date, to_date;
