-- # SurrealDB Custom Function: fn::system_validate_rules_deploy_initialise
-- ## Description
-- This file orchestrates the deployment of the validation rules part of the `system` module.
-- It follows the nested `_initialise` -> `_deploy` pattern.

DEFINE FUNCTION IF NOT EXISTS fn::system_validate_rules_deploy_initialise(
  $parent_run_id: option<string>
) {
  -- Parameters
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system', 'log_initialise'];
  LET $run_id = rand::uuid();

  -- Initialisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_validate_rules_deploy`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main deployment function
  DEFINE FUNCTION IF NOT EXISTS fn::system_validate_rules_deploy(
    $parent_run_id: option<string>
  ) {
    -- Parameters
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system', 'log_deploy'];
    LET $run_id = rand::uuid();
    LET $total_steps = 5;
    LET $step = 0;

    -- Summary Logging: Start
    fn::system_log_deploy_helper_summary('Déploiement des règles de validation du module `system`',
     'start', $run_id, $parent_run_id, $log_extra_tags);

    -- Étape 1: Initialiser fn::system_sanitize_value_bulk
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_sanitize_value_bulk`', 'start', $run_id, $parent_run_id, 
    $log_extra_tags);
    fn::system_sanitize_value_bulk_initialise($run_id);
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_sanitize_value_bulk`', 'done', $run_id, $parent_run_id, 
    $log_extra_tags);

    -- Étape 2: Initialiser fn::system_validate_color_bulk
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_color_bulk`', 'start', $run_id, $parent_run_id, 
    $log_extra_tags);
    fn::system_validate_color_bulk_initialise($run_id);
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_color_bulk`', 'done', $run_id, $parent_run_id, 
    $log_extra_tags);

    -- Étape 3: Initialiser fn::system_validate_conformity_bulk
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_conformity_bulk`', 'start', $run_id, 
    $parent_run_id, $log_extra_tags);
    fn::system_validate_conformity_bulk_initialise($run_id);
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_conformity_bulk`', 'done', $run_id, $parent_run_id, 
    $log_extra_tags);

    -- Étape 4: Initialiser fn::system_validate_existing_bulk
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_existing_bulk`', 'start', $run_id, $parent_run_id, 
    $log_extra_tags);
    fn::system_validate_existing_bulk_initialise($run_id);
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_existing_bulk`', 'done', $run_id, $parent_run_id, 
    $log_extra_tags);

    -- Étape 5: Initialiser fn::system_validate_required_fields
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_required_fields`', 'start', $run_id, $parent_run_id, 
    $log_extra_tags);
    fn::system_validate_required_fields_initialise($run_id);
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
    'Initialisation `fn::system_validate_required_fields`', 'done', $run_id, $parent_run_id, 
    $log_extra_tags);

    -- Summary Logging: Finish
    fn::system_log_deploy_helper_summary('Déploiement des règles de validation du module `system`', 
    'finish', $run_id, $parent_run_id, $log_extra_tags);
    
    RETURN { run_id: $run_id, parent_run_id: $parent_run_id, success: true, 
    message: "Déploiement des règles de validation du module `system` terminé." };
  }
  COMMENT 'Déploie l\'ensemble des règles de validation du module system.'
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_validate_rules_deploy`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true,
    message: "Fonction de déploiement `fn::system_validate_rules_deploy` initialisée."
  };
}
COMMENT 'Initialises the deployment function for the validation rules part of the system module.'
PERMISSIONS FULL;
