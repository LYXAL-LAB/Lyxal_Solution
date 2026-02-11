-- ================================================
-- MODULE AXELOR TALENT - FORMATION & COMPÉTENCES
-- ================================================

-- Table training (formations)
DEFINE TABLE training SCHEMAFULL;
DEFINE FIELD id ON training TYPE record<training>;
DEFINE FIELD name ON training TYPE string;
DEFINE FIELD category ON training TYPE string;
DEFINE FIELD company ON training TYPE string;
DEFINE FIELD skill_set ON training TYPE string;
DEFINE FIELD required_training_set ON training TYPE string;
DEFINE FIELD description ON training TYPE string;
DEFINE FIELD program ON training TYPE string;
DEFINE FIELD objectives ON training TYPE string;
DEFINE FIELD duration ON training TYPE float;
DEFINE FIELD mandatory_training ON training TYPE bool DEFAULT false;
DEFINE FIELD rating ON training TYPE float;
DEFINE FIELD created_on ON training TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON training TYPE datetime DEFAULT time::now();

-- Table training_category (catégories de formation)
DEFINE TABLE training_category SCHEMAFULL;
DEFINE FIELD id ON training_category TYPE record<training_category>;
DEFINE FIELD name ON training_category TYPE string;
DEFINE FIELD code ON training_category TYPE string;
DEFINE FIELD description ON training_category TYPE string;
DEFINE FIELD parent_category ON training_category TYPE string;
DEFINE FIELD active ON training_category TYPE bool DEFAULT true;
DEFINE FIELD created_on ON training_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON training_category TYPE datetime DEFAULT time::now();

-- Table training_session (sessions de formation)
DEFINE TABLE training_session SCHEMAFULL;
DEFINE FIELD id ON training_session TYPE record<training_session>;
DEFINE FIELD training ON training_session TYPE string;
DEFINE FIELD name ON training_session TYPE string;
DEFINE FIELD reference ON training_session TYPE string;
DEFINE FIELD trainer ON training_session TYPE string;
DEFINE FIELD training_location ON training_session TYPE string;
DEFINE FIELD from_date ON training_session TYPE date;
DEFINE FIELD to_date ON training_session TYPE date;
DEFINE FIELD from_time ON training_session TYPE string;
DEFINE FIELD to_time ON training_session TYPE string;
DEFINE FIELD duration ON training_session TYPE float;
DEFINE FIELD max_participants ON training_session TYPE int;
DEFINE FIELD current_participants ON training_session TYPE int DEFAULT 0;
DEFINE FIELD status_select ON training_session TYPE int DEFAULT 1;
DEFINE FIELD notes ON training_session TYPE string;
DEFINE FIELD created_on ON training_session TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON training_session TYPE datetime DEFAULT time::now();

-- Table training_register (inscriptions formations)
DEFINE TABLE training_register SCHEMAFULL;
DEFINE FIELD id ON training_register TYPE record<training_register>;
DEFINE FIELD training_session ON training_register TYPE string;
DEFINE FIELD employee ON training_register TYPE string;
DEFINE FIELD registration_date ON training_register TYPE date;
DEFINE FIELD status_select ON training_register TYPE int DEFAULT 1;
DEFINE FIELD attendance_select ON training_register TYPE int DEFAULT 0;
DEFINE FIELD rating ON training_register TYPE int;
DEFINE FIELD comments ON training_register TYPE string;
DEFINE FIELD certificate_delivered ON training_register TYPE bool DEFAULT false;
DEFINE FIELD certificate_date ON training_register TYPE date;
DEFINE FIELD cost ON training_register TYPE float;
DEFINE FIELD created_on ON training_register TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON training_register TYPE datetime DEFAULT time::now();

-- Table training_skill (compétences formations)
DEFINE TABLE training_skill SCHEMAFULL;
DEFINE FIELD id ON training_skill TYPE record<training_skill>;
DEFINE FIELD training ON training_skill TYPE string;
DEFINE FIELD skill ON training_skill TYPE string;
DEFINE FIELD skill_level ON training_skill TYPE int;
DEFINE FIELD is_mandatory ON training_skill TYPE bool DEFAULT false;
DEFINE FIELD weight ON training_skill TYPE float;
DEFINE FIELD created_on ON training_skill TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON training_skill TYPE datetime DEFAULT time::now();

-- Table skill (compétences)
DEFINE TABLE skill SCHEMAFULL;
DEFINE FIELD id ON skill TYPE record<skill>;
DEFINE FIELD name ON skill TYPE string;
DEFINE FIELD code ON skill TYPE string;
DEFINE FIELD description ON skill TYPE string;
DEFINE FIELD skill_type_select ON skill TYPE int;
DEFINE FIELD category ON skill TYPE string;
DEFINE FIELD parent_skill ON skill TYPE string;
DEFINE FIELD is_technical ON skill TYPE bool DEFAULT false;
DEFINE FIELD is_behavioral ON skill TYPE bool DEFAULT false;
DEFINE FIELD active ON skill TYPE bool DEFAULT true;
DEFINE FIELD created_on ON skill TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON skill TYPE datetime DEFAULT time::now();

-- Table education_level (niveaux d'éducation)
DEFINE TABLE education_level SCHEMAFULL;
DEFINE FIELD id ON education_level TYPE record<education_level>;
DEFINE FIELD name ON education_level TYPE string;
DEFINE FIELD code ON education_level TYPE string;
DEFINE FIELD description ON education_level TYPE string;
DEFINE FIELD level_rank ON education_level TYPE int;
DEFINE FIELD is_diploma ON education_level TYPE bool DEFAULT false;
DEFINE FIELD is_degree ON education_level TYPE bool DEFAULT false;
DEFINE FIELD years_of_study ON education_level TYPE int;
DEFINE FIELD active ON education_level TYPE bool DEFAULT true;
DEFINE FIELD created_on ON education_level TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON education_level TYPE datetime DEFAULT time::now(); 