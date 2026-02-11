DEFINE FUNCTION IF NOT EXISTS fn::base_team_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_team', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_team TYPE NORMAL SCHEMAFULL 
COMMENT 'Référentiel des équipes (organisation)'
PERMISSIONS FULL;

-- FIELDS
DEFINE FIELD code ON base_team TYPE string
COMMENT 'Code de l\'équipe';
DEFINE FIELD name ON base_team TYPE string
COMMENT 'Nom de l\'équipe';
DEFINE FIELD description ON base_team TYPE option<string>
COMMENT 'Description de l\'équipe';
DEFINE FIELD manager ON base_team TYPE option<record<base_user>>
COMMENT 'Responsable de l\'équipe';
DEFINE FIELD members ON base_team TYPE array<record<user>>
COMMENT 'Membres de l\'équipe';
DEFINE FIELD parentTeam ON base_team TYPE option<record<base_team>>
COMMENT 'Équipe parente (hiérarchie)';
DEFINE FIELD tags ON base_team TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags (ex: team_type_*)';

-- Audit
DEFINE FIELD created_at ON base_team TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON base_team TYPE option<record<base_user>>;
DEFINE FIELD updated_at ON base_team TYPE datetime DEFAULT time::now();

-- INDEXES
DEFINE INDEX idx_base_team_code_unique ON base_team FIELDS code UNIQUE;
DEFINE INDEX idx_base_team_name ON base_team FIELDS name;
DEFINE INDEX idx_base_team_parent ON base_team FIELDS parentTeam;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module base_organisation introuvable pour builder_table (team)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('base_team', $sm.id, 'Table des équipes (organisation)', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour base_team', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('base_team_create_table_initialise', $sm.id, 'Initialise la création de la table base_team', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_team_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table base_team', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'base_team' });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_team (organisation)'
PERMISSIONS FULL;

