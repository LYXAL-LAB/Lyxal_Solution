-- =============================================================================================
-- |
-- | Fichier : deploy_configuration_get_codes_by_id_initialise.surql
-- | Module : deploy
-- | Description : Initialise les fonctions permettant de récupérer le champ `codes`
-- |              de la table `deploy_configuration` par identifiant.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::deploy_configuration_get_codes_by_id_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_deploy', 'function_deploy_configuration_get_codes_by_id_initialise'];
  LET $run_id = rand::uuid();

  -- Journalisation: début d'initialisation
  fn::system_log_helper_initialise('function', 'start', 'deploy_configuration_get_codes_by_id_initialise',
    { run_id: $run_id, parent_run_id: $parent_run_id }, $log_extra_tags);

  -- Version système (minimaliste)
  DEFINE FUNCTION IF NOT EXISTS fn::deploy_configuration_get_codes_by_id_system(
    $id: string
  ) {
    LET $record = (SELECT codes FROM type::thing('deploy_configuration', $id) LIMIT 1)[0];
    LET $codes = $record.codes OR [];
    RETURN { success: $record != NONE, id: $id, codes: $codes, count: array::len($codes) };
  }
  COMMENT 'Retourne les codes de deploy_configuration par id (système)'
  PERMISSIONS FULL;

  -- Version publique (wrapper)
  DEFINE FUNCTION IF NOT EXISTS fn::deploy_configuration_get_codes_by_id(
    $id: string
  ) {
    RETURN fn::deploy_configuration_get_codes_by_id_system($id);
  }
  COMMENT 'Retourne les codes de deploy_configuration par id (public)'
  PERMISSIONS FULL;

  -- Journalisation: fin d'initialisation
  fn::system_log_helper_initialise('function', 'done', 'deploy_configuration_get_codes_by_id_initialise',
    { run_id: $run_id, parent_run_id: $parent_run_id }, $log_extra_tags);

  RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise les fonctions de récupération des codes par id pour deploy_configuration'
PERMISSIONS FULL;


