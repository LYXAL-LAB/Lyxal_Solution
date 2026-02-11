DEFINE FUNCTION IF NOT EXISTS fn::base_partner_address_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_partner_address', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_partner_address TYPE NORMAL SCHEMAFULL 
COMMENT 'Adresses multiples par partenaire avec typage via tags' 
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

DEFINE FIELD address ON base_partner_address TYPE record<base_address> 
COMMENT "Référence vers l'adresse";
DEFINE FIELD name ON base_partner_address TYPE option<string>
COMMENT "Nom de l'adresse";
DEFINE FIELD description ON base_partner_address TYPE option<string>
COMMENT "Description de l'adresse";
DEFINE FIELD tags ON base_partner_address TYPE array<record<system_tag>> DEFAULT []
COMMENT "Tags de l'adresse";

DEFINE FIELD created_at ON base_partner_address TYPE datetime DEFAULT time::now() 
COMMENT "Date de création de l'association";
DEFINE FIELD created_by ON base_partner_address TYPE record<base_user> 
COMMENT "Utilisateur qui a créé l'association";
DEFINE FIELD partner ON base_partner_address TYPE record<base_partner>
COMMENT 'Référence vers le partenaire';
DEFINE FIELD updated_at ON base_partner_address TYPE datetime DEFAULT time::now() 
COMMENT 'Date de dernière modification';

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_address_address ON base_partner_address FIELDS address;
DEFINE INDEX idx_partner_address_created_at ON base_partner_address FIELDS created_at;
DEFINE INDEX idx_partner_address_created_by ON base_partner_address FIELDS created_by;
DEFINE INDEX idx_partner_address_partner ON base_partner_address FIELDS partner;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_partner' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module base_partner introuvable pour builder_table (address)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('base_partner_address', $sm.id, 'Table des adresses partenaires', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour base_partner_address', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('base_partner_address_create_table_initialise', $sm.id, 'Initialise la création de la table base_partner_address', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_partner_address_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table base_partner_address', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'base_partner_address' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table base_partner_address dans la base de données"
PERMISSIONS FULL;