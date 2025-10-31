-- # SurrealDB Custom Function: fn::system_tag_reference_tags_initialise
-- ## Description
-- This file initialises the `fn::system_tag_reference_tags` function,
-- which creates the base system tags.

DEFINE FUNCTION IF NOT EXISTS fn::system_tag_reference_tags_initialise(
  $parent_run_id: option<string>
) {
  -- Parameters
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags =  ['module_system'];
  LET $run_id = rand::uuid();

  -- Initialisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'],
     $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_tag_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Define the main function
  DEFINE FUNCTION IF NOT EXISTS fn::system_tag_reference_tags(
    $parent_run_id: option<string>
  ) {
    -- Use the system function to create tags, passing parent_run_id for traceability
    LET $log_extra_tags = ['module_system', 'log_reference_tags'];

    fn::system_tag_create_record_system('system_activate', 'Système: Activate', 
    'Active la ressource ou son comportement', '#00C853', 10, true, 
    $log_extra_tags, $parent_run_id);
    fn::system_tag_create_record_system('system_mandatory', 'Système: Mandatory', 
    'Indique une attente forte (ex: champ recommandé). 
    Peut déclencher un avertissement non-bloquant.', '#FFAB00', 20, 
    true, $log_extra_tags, $parent_run_id);
    fn::system_tag_create_record_system('system_obligatory', 'Système: Obligatory', 
    'Indique une obligation stricte (ex: champ requis). 
    Le non-respect déclenche une erreur bloquante.', '#D50000', 30, true, $log_extra_tags, 
    $parent_run_id);

    RETURN { success: true, message: 'Tags système de base créés/validés' };
  }
  COMMENT 'Crée les tags système de base (protégés)'
  PERMISSIONS FULL;

  -- Finalisation Logging
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_tag_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    run_id: $run_id,
    parent_run_id: $parent_run_id,
    success: true
  };
}
COMMENT 'Initialises the function for creating base system tags.'
PERMISSIONS FULL;

