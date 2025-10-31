-- ================================================
-- MODULE AXELOR QUALITY - CONTRÔLES ET PLANS
-- ================================================

-- Table quality_control
DEFINE TABLE quality_control SCHEMAFULL;
DEFINE FIELD id ON quality_control TYPE record<quality_control>;
DEFINE FIELD team ON quality_control TYPE string;
DEFINE FIELD responsible ON quality_control TYPE string;
DEFINE FIELD reference ON quality_control TYPE string;
DEFINE FIELD status_select ON quality_control TYPE int DEFAULT 1;
DEFINE FIELD start_date ON quality_control TYPE date;
DEFINE FIELD end_date ON quality_control TYPE date;
DEFINE FIELD deadline_date ON quality_control TYPE date;
DEFINE FIELD sequence ON quality_control TYPE int;
DEFINE FIELD project ON quality_control TYPE string;
DEFINE FIELD inspector_signature ON quality_control TYPE string;
DEFINE FIELD customer_signature ON quality_control TYPE string;
DEFINE FIELD name ON quality_control TYPE string;
DEFINE FIELD printing_settings ON quality_control TYPE string;
DEFINE FIELD created_on ON quality_control TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_control TYPE datetime DEFAULT time::now();

-- Table quality_corrective_action
DEFINE TABLE quality_corrective_action SCHEMAFULL;
DEFINE FIELD id ON quality_corrective_action TYPE record<quality_corrective_action>;
DEFINE FIELD quality_control ON quality_corrective_action TYPE string;
DEFINE FIELD name ON quality_corrective_action TYPE string;
DEFINE FIELD description ON quality_corrective_action TYPE string;
DEFINE FIELD responsible ON quality_corrective_action TYPE string;
DEFINE FIELD deadline ON quality_corrective_action TYPE date;
DEFINE FIELD status ON quality_corrective_action TYPE string;
DEFINE FIELD priority ON quality_corrective_action TYPE int;
DEFINE FIELD created_on ON quality_corrective_action TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_corrective_action TYPE datetime DEFAULT time::now();

-- Table control_plan
DEFINE TABLE control_plan SCHEMAFULL;
DEFINE FIELD id ON control_plan TYPE record<control_plan>;
DEFINE FIELD code ON control_plan TYPE string;
DEFINE FIELD name ON control_plan TYPE string;
DEFINE FIELD control_plan_frequency ON control_plan TYPE string;
DEFINE FIELD description ON control_plan TYPE string;
DEFINE FIELD status_select ON control_plan TYPE int DEFAULT 1;
DEFINE FIELD created_on ON control_plan TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_plan TYPE datetime DEFAULT time::now();

-- Table control_plan_frequency
DEFINE TABLE control_plan_frequency SCHEMAFULL;
DEFINE FIELD id ON control_plan_frequency TYPE record<control_plan_frequency>;
DEFINE FIELD name ON control_plan_frequency TYPE string;
DEFINE FIELD code ON control_plan_frequency TYPE string;
DEFINE FIELD description ON control_plan_frequency TYPE string;
DEFINE FIELD frequency_type ON control_plan_frequency TYPE string;
DEFINE FIELD frequency_value ON control_plan_frequency TYPE int;
DEFINE FIELD active ON control_plan_frequency TYPE bool DEFAULT true;
DEFINE FIELD created_on ON control_plan_frequency TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_plan_frequency TYPE datetime DEFAULT time::now();

-- Table control_entry
DEFINE TABLE control_entry SCHEMAFULL;
DEFINE FIELD id ON control_entry TYPE record<control_entry>;
DEFINE FIELD name ON control_entry TYPE string;
DEFINE FIELD entry_datetime ON control_entry TYPE datetime;
DEFINE FIELD inspector ON control_entry TYPE string;
DEFINE FIELD sample_count ON control_entry TYPE int;
DEFINE FIELD control_plan ON control_entry TYPE string;
DEFINE FIELD status_select ON control_entry TYPE int DEFAULT 1;
DEFINE FIELD created_on ON control_entry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_entry TYPE datetime DEFAULT time::now();

-- Table control_entry_sample
DEFINE TABLE control_entry_sample SCHEMAFULL;
DEFINE FIELD id ON control_entry_sample TYPE record<control_entry_sample>;
DEFINE FIELD control_entry ON control_entry_sample TYPE string;
DEFINE FIELD sample_number ON control_entry_sample TYPE int;
DEFINE FIELD measured_value ON control_entry_sample TYPE float;
DEFINE FIELD result_status ON control_entry_sample TYPE string;
DEFINE FIELD comments ON control_entry_sample TYPE string;
DEFINE FIELD created_on ON control_entry_sample TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_entry_sample TYPE datetime DEFAULT time::now();

-- Table control_entry_plan_line
DEFINE TABLE control_entry_plan_line SCHEMAFULL;
DEFINE FIELD id ON control_entry_plan_line TYPE record<control_entry_plan_line>;
DEFINE FIELD control_plan ON control_entry_plan_line TYPE string;
DEFINE FIELD control_point_model ON control_entry_plan_line TYPE string;
DEFINE FIELD sequence ON control_entry_plan_line TYPE int;
DEFINE FIELD is_mandatory ON control_entry_plan_line TYPE bool DEFAULT true;
DEFINE FIELD min_value ON control_entry_plan_line TYPE float;
DEFINE FIELD max_value ON control_entry_plan_line TYPE float;
DEFINE FIELD target_value ON control_entry_plan_line TYPE float;
DEFINE FIELD tolerance ON control_entry_plan_line TYPE float;
DEFINE FIELD created_on ON control_entry_plan_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_entry_plan_line TYPE datetime DEFAULT time::now();

-- Table control_point
DEFINE TABLE control_point SCHEMAFULL;
DEFINE FIELD id ON control_point TYPE record<control_point>;
DEFINE FIELD quality_control ON control_point TYPE string;
DEFINE FIELD optional_quality_control ON control_point TYPE string;
DEFINE FIELD control_point_model ON control_point TYPE string;
DEFINE FIELD sequence ON control_point TYPE int;
DEFINE FIELD result_select ON control_point TYPE int;
DEFINE FIELD comments ON control_point TYPE string;
DEFINE FIELD is_compliant ON control_point TYPE bool;
DEFINE FIELD measured_value ON control_point TYPE float;
DEFINE FIELD created_on ON control_point TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_point TYPE datetime DEFAULT time::now();

-- Table control_point_model
DEFINE TABLE control_point_model SCHEMAFULL;
DEFINE FIELD id ON control_point_model TYPE record<control_point_model>;
DEFINE FIELD name ON control_point_model TYPE string;
DEFINE FIELD code ON control_point_model TYPE string;
DEFINE FIELD control_point_type ON control_point_model TYPE string;
DEFINE FIELD description ON control_point_model TYPE string;
DEFINE FIELD unit ON control_point_model TYPE string;
DEFINE FIELD active ON control_point_model TYPE bool DEFAULT true;
DEFINE FIELD created_on ON control_point_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_point_model TYPE datetime DEFAULT time::now();

-- Table control_point_type
DEFINE TABLE control_point_type SCHEMAFULL;
DEFINE FIELD id ON control_point_type TYPE record<control_point_type>;
DEFINE FIELD name ON control_point_type TYPE string;
DEFINE FIELD code ON control_point_type TYPE string;
DEFINE FIELD description ON control_point_type TYPE string;
DEFINE FIELD active ON control_point_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON control_point_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_point_type TYPE datetime DEFAULT time::now();

-- Table control_type
DEFINE TABLE control_type SCHEMAFULL;
DEFINE FIELD id ON control_type TYPE record<control_type>;
DEFINE FIELD name ON control_type TYPE string;
DEFINE FIELD code ON control_type TYPE string;
DEFINE FIELD description ON control_type TYPE string;
DEFINE FIELD active ON control_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON control_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_type TYPE datetime DEFAULT time::now();

-- Table control_plan_line_characteristic
DEFINE TABLE control_plan_line_characteristic SCHEMAFULL;
DEFINE FIELD id ON control_plan_line_characteristic TYPE record<control_plan_line_characteristic>;
DEFINE FIELD control_plan_line ON control_plan_line_characteristic TYPE string;
DEFINE FIELD characteristic_name ON control_plan_line_characteristic TYPE string;
DEFINE FIELD characteristic_value ON control_plan_line_characteristic TYPE string;
DEFINE FIELD created_on ON control_plan_line_characteristic TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON control_plan_line_characteristic TYPE datetime DEFAULT time::now(); 