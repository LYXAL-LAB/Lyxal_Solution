-- =============================================================================================
-- |
-- | Fichier : deploy_configuration_table_create_initialise.surql
-- | Module : deploy
-- | Description : Crée la table `deploy_configuration` (configuration de déploiement runtime).
-- |              Pour le moment, une seule field est définie.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::deploy_configuration_table_create_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_deploy', 'table_deploy_configuration'];
  LET $run_id = rand::uuid();

  fn::system_log_helper_initialise('table', 'start', 'deploy_configuration_create_table',
    { run_id: $run_id, parent_run_id: $parent_run_id }, $log_extra_tags);

  DEFINE TABLE IF NOT EXISTS deploy_configuration
  TYPE NORMAL SCHEMAFULL
  COMMENT 'Paramètres de déploiement runtime (template)'
  PERMISSIONS FULL;

  -- Field unique pour pilotage granulaire par codes builder (modules / tables)
  DEFINE FIELD IF NOT EXISTS codes ON TABLE deploy_configuration
  TYPE array<string>
  COMMENT 'Liste de codes (builder) à déployer';

  fn::system_log_helper_initialise('table', 'done', 'deploy_configuration_create_table',
    { run_id: $run_id, parent_run_id: $parent_run_id }, $log_extra_tags);

  RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la création de la table deploy_configuration (1 field: codes)'
PERMISSIONS FULL;


