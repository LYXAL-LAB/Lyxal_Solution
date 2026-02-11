-- ================================================
-- MODULE AXELOR TALENT - RECRUTEMENT & POSTES
-- ================================================

-- Table app_recruitment (configuration)
DEFINE TABLE app_recruitment SCHEMAFULL;
DEFINE FIELD id ON app_recruitment TYPE record<app_recruitment>;
DEFINE FIELD app ON app_recruitment TYPE string;
DEFINE FIELD is_manage_job_position ON app_recruitment TYPE bool DEFAULT false;
DEFINE FIELD is_manage_training ON app_recruitment TYPE bool DEFAULT false;
DEFINE FIELD is_manage_job_application ON app_recruitment TYPE bool DEFAULT false;
DEFINE FIELD is_manage_appraisal ON app_recruitment TYPE bool DEFAULT false;
DEFINE FIELD active ON app_recruitment TYPE bool DEFAULT true;
DEFINE FIELD created_on ON app_recruitment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_recruitment TYPE datetime DEFAULT time::now();

-- Table job_position (postes de travail)
DEFINE TABLE job_position SCHEMAFULL;
DEFINE FIELD id ON job_position TYPE record<job_position>;
DEFINE FIELD job_title ON job_position TYPE string;
DEFINE FIELD job_reference ON job_position TYPE string;
DEFINE FIELD company_department ON job_position TYPE string;
DEFINE FIELD employee ON job_position TYPE string;
DEFINE FIELD contract_type ON job_position TYPE string;
DEFINE FIELD experience_select ON job_position TYPE int;
DEFINE FIELD salary ON job_position TYPE string;
DEFINE FIELD location ON job_position TYPE string;
DEFINE FIELD job_description ON job_position TYPE string;
DEFINE FIELD mail_account ON job_position TYPE string;
DEFINE FIELD status_select ON job_position TYPE int DEFAULT 0;
DEFINE FIELD nb_open_job ON job_position TYPE int;
DEFINE FIELD nb_people_hired ON job_position TYPE int DEFAULT 0;
DEFINE FIELD publication_date ON job_position TYPE date;
DEFINE FIELD company ON job_position TYPE string;
DEFINE FIELD position_status_select ON job_position TYPE string;
DEFINE FIELD starting_date ON job_position TYPE date;
DEFINE FIELD profile_wanted ON job_position TYPE string;
DEFINE FIELD created_on ON job_position TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON job_position TYPE datetime DEFAULT time::now();

-- Table job_application (candidatures)
DEFINE TABLE job_application SCHEMAFULL;
DEFINE FIELD id ON job_application TYPE record<job_application>;
DEFINE FIELD last_name ON job_application TYPE string;
DEFINE FIELD first_name ON job_application TYPE string;
DEFINE FIELD full_name ON job_application TYPE string;
DEFINE FIELD email_address ON job_application TYPE string;
DEFINE FIELD fixed_phone ON job_application TYPE string;
DEFINE FIELD mobile_phone ON job_application TYPE string;
DEFINE FIELD education_level ON job_application TYPE string;
DEFINE FIELD experience_select ON job_application TYPE int;
DEFINE FIELD industry_sector_set ON job_application TYPE string;
DEFINE FIELD linked_in_profile ON job_application TYPE string;
DEFINE FIELD talent_source ON job_application TYPE string;
DEFINE FIELD referred_by ON job_application TYPE string;
DEFINE FIELD appreciation ON job_application TYPE int;
DEFINE FIELD job_position ON job_application TYPE string;
DEFINE FIELD responsible ON job_application TYPE string;
DEFINE FIELD employee ON job_application TYPE string;
DEFINE FIELD expected_salary ON job_application TYPE string;
DEFINE FIELD proposed_salary ON job_application TYPE string;
DEFINE FIELD availability_from ON job_application TYPE date;
DEFINE FIELD description ON job_application TYPE string;
DEFINE FIELD hiring_stage ON job_application TYPE string;
DEFINE FIELD reason_not_hired ON job_application TYPE string;
DEFINE FIELD skill_set ON job_application TYPE string;
DEFINE FIELD picture ON job_application TYPE string;
DEFINE FIELD creation_date ON job_application TYPE date;
DEFINE FIELD title_select ON job_application TYPE int;
DEFINE FIELD fax ON job_application TYPE string;
DEFINE FIELD employee_address ON job_application TYPE string;
DEFINE FIELD resume ON job_application TYPE string;
DEFINE FIELD dms_file ON job_application TYPE string;
DEFINE FIELD created_on ON job_application TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON job_application TYPE datetime DEFAULT time::now();

-- Table hiring_stage (étapes de recrutement)
DEFINE TABLE hiring_stage SCHEMAFULL;
DEFINE FIELD id ON hiring_stage TYPE record<hiring_stage>;
DEFINE FIELD name ON hiring_stage TYPE string;
DEFINE FIELD code ON hiring_stage TYPE string;
DEFINE FIELD description ON hiring_stage TYPE string;
DEFINE FIELD sequence ON hiring_stage TYPE int;
DEFINE FIELD is_initial_stage ON hiring_stage TYPE bool DEFAULT false;
DEFINE FIELD is_final_stage ON hiring_stage TYPE bool DEFAULT false;
DEFINE FIELD active ON hiring_stage TYPE bool DEFAULT true;
DEFINE FIELD created_on ON hiring_stage TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON hiring_stage TYPE datetime DEFAULT time::now();

-- Table talent_source (sources de recrutement)
DEFINE TABLE talent_source SCHEMAFULL;
DEFINE FIELD id ON talent_source TYPE record<talent_source>;
DEFINE FIELD name ON talent_source TYPE string;
DEFINE FIELD code ON talent_source TYPE string;
DEFINE FIELD description ON talent_source TYPE string;
DEFINE FIELD source_type_select ON talent_source TYPE int;
DEFINE FIELD website ON talent_source TYPE string;
DEFINE FIELD contact_person ON talent_source TYPE string;
DEFINE FIELD email ON talent_source TYPE string;
DEFINE FIELD phone ON talent_source TYPE string;
DEFINE FIELD active ON talent_source TYPE bool DEFAULT true;
DEFINE FIELD created_on ON talent_source TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON talent_source TYPE datetime DEFAULT time::now();

-- Table sequence (séquences)
DEFINE TABLE sequence SCHEMAFULL;
DEFINE FIELD id ON sequence TYPE record<sequence>;
DEFINE FIELD name ON sequence TYPE string;
DEFINE FIELD code ON sequence TYPE string;
DEFINE FIELD prefix ON sequence TYPE string;
DEFINE FIELD suffix ON sequence TYPE string;
DEFINE FIELD padding ON sequence TYPE int DEFAULT 1;
DEFINE FIELD next_num ON sequence TYPE int DEFAULT 1;
DEFINE FIELD increment ON sequence TYPE int DEFAULT 1;
DEFINE FIELD active ON sequence TYPE bool DEFAULT true;
DEFINE FIELD company ON sequence TYPE string;
DEFINE FIELD created_on ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sequence TYPE datetime DEFAULT time::now();

-- Table app (référence étendue)
DEFINE TABLE app SCHEMAFULL;
DEFINE FIELD id ON app TYPE record<app>;
DEFINE FIELD name ON app TYPE string;
DEFINE FIELD code ON app TYPE string;
DEFINE FIELD description ON app TYPE string;
DEFINE FIELD active ON app TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app TYPE int;
DEFINE FIELD version ON app TYPE string;
DEFINE FIELD depends_on ON app TYPE string;
DEFINE FIELD created_on ON app TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app TYPE datetime DEFAULT time::now(); 