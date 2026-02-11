-- ================================================
-- MODULE AXELOR QUALITY - AMÉLIORATION ET ALERTES
-- ================================================

-- Table quality_alert
DEFINE TABLE quality_alert SCHEMAFULL;
DEFINE FIELD id ON quality_alert TYPE record<quality_alert>;
DEFINE FIELD product ON quality_alert TYPE string;
DEFINE FIELD work_center ON quality_alert TYPE string;
DEFINE FIELD team ON quality_alert TYPE string;
DEFINE FIELD responsible ON quality_alert TYPE string;
DEFINE FIELD root_cause ON quality_alert TYPE string;
DEFINE FIELD reference ON quality_alert TYPE string;
DEFINE FIELD full_name ON quality_alert TYPE string;
DEFINE FIELD priority_select ON quality_alert TYPE int;
DEFINE FIELD status_select ON quality_alert TYPE int;
DEFINE FIELD start_date ON quality_alert TYPE date;
DEFINE FIELD end_date ON quality_alert TYPE date;
DEFINE FIELD deadline_date ON quality_alert TYPE date;
DEFINE FIELD description ON quality_alert TYPE string;
DEFINE FIELD corrective_actions ON quality_alert TYPE string;
DEFINE FIELD preventive_actions ON quality_alert TYPE string;
DEFINE FIELD created_on ON quality_alert TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_alert TYPE datetime DEFAULT time::now();

-- Table quality_improvement
DEFINE TABLE quality_improvement SCHEMAFULL;
DEFINE FIELD id ON quality_improvement TYPE record<quality_improvement>;
DEFINE FIELD sequence ON quality_improvement TYPE string;
DEFINE FIELD technical_seq ON quality_improvement TYPE int DEFAULT 1;
DEFINE FIELD type ON quality_improvement TYPE int DEFAULT 1;
DEFINE FIELD gravity_type_select ON quality_improvement TYPE int;
DEFINE FIELD company ON quality_improvement TYPE string;
DEFINE FIELD qi_detection ON quality_improvement TYPE string;
DEFINE FIELD qi_status ON quality_improvement TYPE string;
DEFINE FIELD qi_identification ON quality_improvement TYPE string;
DEFINE FIELD qi_resolution ON quality_improvement TYPE string;
DEFINE FIELD qi_analysis ON quality_improvement TYPE string;
DEFINE FIELD analysis_method ON quality_improvement TYPE string;
DEFINE FIELD created_on ON quality_improvement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON quality_improvement TYPE datetime DEFAULT time::now();

-- Table qi_analysis
DEFINE TABLE qi_analysis SCHEMAFULL;
DEFINE FIELD id ON qi_analysis TYPE record<qi_analysis>;
DEFINE FIELD qi ON qi_analysis TYPE string;
DEFINE FIELD causes_written_by ON qi_analysis TYPE string;
DEFINE FIELD causes_written_on ON qi_analysis TYPE datetime;
DEFINE FIELD plan_owner ON qi_analysis TYPE string;
DEFINE FIELD earliest_date ON qi_analysis TYPE date;
DEFINE FIELD latest_date ON qi_analysis TYPE date;
DEFINE FIELD advancement ON qi_analysis TYPE int;
DEFINE FIELD objective ON qi_analysis TYPE string;
DEFINE FIELD efficiency_criteria ON qi_analysis TYPE string;
DEFINE FIELD analysis_check ON qi_analysis TYPE string;
DEFINE FIELD efficiency_select ON qi_analysis TYPE int DEFAULT 1;
DEFINE FIELD efficiency_checked_by ON qi_analysis TYPE string;
DEFINE FIELD efficiency_checked_on ON qi_analysis TYPE datetime;
DEFINE FIELD created_on ON qi_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_analysis TYPE datetime DEFAULT time::now();

-- Table qi_analysis_cause
DEFINE TABLE qi_analysis_cause SCHEMAFULL;
DEFINE FIELD id ON qi_analysis_cause TYPE record<qi_analysis_cause>;
DEFINE FIELD qi_analysis ON qi_analysis_cause TYPE string;
DEFINE FIELD qi_cause ON qi_analysis_cause TYPE string;
DEFINE FIELD cause_description ON qi_analysis_cause TYPE string;
DEFINE FIELD probability ON qi_analysis_cause TYPE float;
DEFINE FIELD impact ON qi_analysis_cause TYPE int;
DEFINE FIELD created_on ON qi_analysis_cause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_analysis_cause TYPE datetime DEFAULT time::now();

-- Table qi_analysis_method
DEFINE TABLE qi_analysis_method SCHEMAFULL;
DEFINE FIELD id ON qi_analysis_method TYPE record<qi_analysis_method>;
DEFINE FIELD name ON qi_analysis_method TYPE string;
DEFINE FIELD code ON qi_analysis_method TYPE string;
DEFINE FIELD description ON qi_analysis_method TYPE string;
DEFINE FIELD active ON qi_analysis_method TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_analysis_method TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_analysis_method TYPE datetime DEFAULT time::now();

-- Table qi_analysis_method_item
DEFINE TABLE qi_analysis_method_item SCHEMAFULL;
DEFINE FIELD id ON qi_analysis_method_item TYPE record<qi_analysis_method_item>;
DEFINE FIELD qi_analysis_method ON qi_analysis_method_item TYPE string;
DEFINE FIELD name ON qi_analysis_method_item TYPE string;
DEFINE FIELD description ON qi_analysis_method_item TYPE string;
DEFINE FIELD sequence ON qi_analysis_method_item TYPE int;
DEFINE FIELD created_on ON qi_analysis_method_item TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_analysis_method_item TYPE datetime DEFAULT time::now();

-- Table qi_resolution
DEFINE TABLE qi_resolution SCHEMAFULL;
DEFINE FIELD id ON qi_resolution TYPE record<qi_resolution>;
DEFINE FIELD qi ON qi_resolution TYPE string;
DEFINE FIELD default_written_by ON qi_resolution TYPE string;
DEFINE FIELD default_written_on ON qi_resolution TYPE datetime;
DEFINE FIELD decisions_written_by ON qi_resolution TYPE string;
DEFINE FIELD decisions_written_on ON qi_resolution TYPE datetime;
DEFINE FIELD created_on ON qi_resolution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_resolution TYPE datetime DEFAULT time::now();

-- Table qi_resolution_default
DEFINE TABLE qi_resolution_default SCHEMAFULL;
DEFINE FIELD id ON qi_resolution_default TYPE record<qi_resolution_default>;
DEFINE FIELD qi_resolution ON qi_resolution_default TYPE string;
DEFINE FIELD qi_default ON qi_resolution_default TYPE string;
DEFINE FIELD default_description ON qi_resolution_default TYPE string;
DEFINE FIELD severity ON qi_resolution_default TYPE int;
DEFINE FIELD created_on ON qi_resolution_default TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_resolution_default TYPE datetime DEFAULT time::now();

-- Table qi_resolution_decision
DEFINE TABLE qi_resolution_decision SCHEMAFULL;
DEFINE FIELD id ON qi_resolution_decision TYPE record<qi_resolution_decision>;
DEFINE FIELD qi_resolution ON qi_resolution_decision TYPE string;
DEFINE FIELD qi_decision ON qi_resolution_decision TYPE string;
DEFINE FIELD decision_description ON qi_resolution_decision TYPE string;
DEFINE FIELD priority ON qi_resolution_decision TYPE int;
DEFINE FIELD responsible ON qi_resolution_decision TYPE string;
DEFINE FIELD deadline ON qi_resolution_decision TYPE date;
DEFINE FIELD created_on ON qi_resolution_decision TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_resolution_decision TYPE datetime DEFAULT time::now();

-- Table qi_action
DEFINE TABLE qi_action SCHEMAFULL;
DEFINE FIELD id ON qi_action TYPE record<qi_action>;
DEFINE FIELD code ON qi_action TYPE string;
DEFINE FIELD name ON qi_action TYPE string;
DEFINE FIELD company ON qi_action TYPE string;
DEFINE FIELD is_product_action ON qi_action TYPE bool DEFAULT false;
DEFINE FIELD is_system_action ON qi_action TYPE bool DEFAULT false;
DEFINE FIELD created_on ON qi_action TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_action TYPE datetime DEFAULT time::now();

-- Table qi_action_distribution
DEFINE TABLE qi_action_distribution SCHEMAFULL;
DEFINE FIELD id ON qi_action_distribution TYPE record<qi_action_distribution>;
DEFINE FIELD qi_analysis ON qi_action_distribution TYPE string;
DEFINE FIELD recipient ON qi_action_distribution TYPE string;
DEFINE FIELD distribution_date ON qi_action_distribution TYPE datetime;
DEFINE FIELD status ON qi_action_distribution TYPE string;
DEFINE FIELD comments ON qi_action_distribution TYPE string;
DEFINE FIELD created_on ON qi_action_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_action_distribution TYPE datetime DEFAULT time::now();

-- Table qi_task
DEFINE TABLE qi_task SCHEMAFULL;
DEFINE FIELD id ON qi_task TYPE record<qi_task>;
DEFINE FIELD qi_analysis ON qi_task TYPE string;
DEFINE FIELD name ON qi_task TYPE string;
DEFINE FIELD description ON qi_task TYPE string;
DEFINE FIELD responsible ON qi_task TYPE string;
DEFINE FIELD start_date ON qi_task TYPE date;
DEFINE FIELD end_date ON qi_task TYPE date;
DEFINE FIELD status ON qi_task TYPE string;
DEFINE FIELD priority ON qi_task TYPE int;
DEFINE FIELD progress ON qi_task TYPE int DEFAULT 0;
DEFINE FIELD created_on ON qi_task TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_task TYPE datetime DEFAULT time::now();

-- Table qi_status
DEFINE TABLE qi_status SCHEMAFULL;
DEFINE FIELD id ON qi_status TYPE record<qi_status>;
DEFINE FIELD name ON qi_status TYPE string;
DEFINE FIELD code ON qi_status TYPE string;
DEFINE FIELD description ON qi_status TYPE string;
DEFINE FIELD color ON qi_status TYPE string;
DEFINE FIELD sequence ON qi_status TYPE int;
DEFINE FIELD active ON qi_status TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_status TYPE datetime DEFAULT time::now();

-- Table qi_process
DEFINE TABLE qi_process SCHEMAFULL;
DEFINE FIELD id ON qi_process TYPE record<qi_process>;
DEFINE FIELD name ON qi_process TYPE string;
DEFINE FIELD code ON qi_process TYPE string;
DEFINE FIELD description ON qi_process TYPE string;
DEFINE FIELD active ON qi_process TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_process TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_process TYPE datetime DEFAULT time::now();

-- Table qi_detection
DEFINE TABLE qi_detection SCHEMAFULL;
DEFINE FIELD id ON qi_detection TYPE record<qi_detection>;
DEFINE FIELD name ON qi_detection TYPE string;
DEFINE FIELD code ON qi_detection TYPE string;
DEFINE FIELD description ON qi_detection TYPE string;
DEFINE FIELD active ON qi_detection TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_detection TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_detection TYPE datetime DEFAULT time::now();

-- Table qi_default
DEFINE TABLE qi_default SCHEMAFULL;
DEFINE FIELD id ON qi_default TYPE record<qi_default>;
DEFINE FIELD name ON qi_default TYPE string;
DEFINE FIELD code ON qi_default TYPE string;
DEFINE FIELD description ON qi_default TYPE string;
DEFINE FIELD severity_level ON qi_default TYPE int;
DEFINE FIELD active ON qi_default TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_default TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_default TYPE datetime DEFAULT time::now();

-- Table qi_decision
DEFINE TABLE qi_decision SCHEMAFULL;
DEFINE FIELD id ON qi_decision TYPE record<qi_decision>;
DEFINE FIELD name ON qi_decision TYPE string;
DEFINE FIELD code ON qi_decision TYPE string;
DEFINE FIELD description ON qi_decision TYPE string;
DEFINE FIELD active ON qi_decision TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_decision TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_decision TYPE datetime DEFAULT time::now();

-- Table qi_decision_distribution
DEFINE TABLE qi_decision_distribution SCHEMAFULL;
DEFINE FIELD id ON qi_decision_distribution TYPE record<qi_decision_distribution>;
DEFINE FIELD qi_resolution ON qi_decision_distribution TYPE string;
DEFINE FIELD recipient ON qi_decision_distribution TYPE string;
DEFINE FIELD distribution_date ON qi_decision_distribution TYPE datetime;
DEFINE FIELD status ON qi_decision_distribution TYPE string;
DEFINE FIELD comments ON qi_decision_distribution TYPE string;
DEFINE FIELD created_on ON qi_decision_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_decision_distribution TYPE datetime DEFAULT time::now();

-- Table qi_decision_config_company
DEFINE TABLE qi_decision_config_company SCHEMAFULL;
DEFINE FIELD id ON qi_decision_config_company TYPE record<qi_decision_config_company>;
DEFINE FIELD company ON qi_decision_config_company TYPE string;
DEFINE FIELD qi_decision ON qi_decision_config_company TYPE string;
DEFINE FIELD is_active ON qi_decision_config_company TYPE bool DEFAULT true;
DEFINE FIELD sequence ON qi_decision_config_company TYPE int;
DEFINE FIELD created_on ON qi_decision_config_company TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_decision_config_company TYPE datetime DEFAULT time::now();

-- Table qi_identification
DEFINE TABLE qi_identification SCHEMAFULL;
DEFINE FIELD id ON qi_identification TYPE record<qi_identification>;
DEFINE FIELD qi ON qi_identification TYPE string;
DEFINE FIELD identification_date ON qi_identification TYPE datetime;
DEFINE FIELD identified_by ON qi_identification TYPE string;
DEFINE FIELD description ON qi_identification TYPE string;
DEFINE FIELD context ON qi_identification TYPE string;
DEFINE FIELD impact_description ON qi_identification TYPE string;
DEFINE FIELD created_on ON qi_identification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_identification TYPE datetime DEFAULT time::now();

-- Table qi_cause
DEFINE TABLE qi_cause SCHEMAFULL;
DEFINE FIELD id ON qi_cause TYPE record<qi_cause>;
DEFINE FIELD name ON qi_cause TYPE string;
DEFINE FIELD code ON qi_cause TYPE string;
DEFINE FIELD description ON qi_cause TYPE string;
DEFINE FIELD category ON qi_cause TYPE string;
DEFINE FIELD active ON qi_cause TYPE bool DEFAULT true;
DEFINE FIELD created_on ON qi_cause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON qi_cause TYPE datetime DEFAULT time::now();