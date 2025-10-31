-- Initialisation de la fonction pour supprimer un enregistrement de documentation
DEFINE FUNCTION fn::builder_documentation_remove_record_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_documentation_remove_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_documentation_remove_record(
    $from_id: string,
    $from_type: string,
    $to_id: string,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_relation'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: suppression d\'une relation de documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { from_id: $from_id, from_type: $from_type, to_id: $to_id } }
    );

    -- Construction des records
    LET $from_entity = type::thing($from_type, $from_id);
    LET $to_entity = type::thing('base_metafile', $to_id);

    -- Suppression de la relation
    LET $deleted_relation = DELETE builder_documentation WHERE from = $from_entity AND to = $to_entity;

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: relation de documentation supprimée',
        { run_id: $run_id, parent_run_id: $parent_run_id, result: $deleted_relation }
    );

    -- Retour
    RETURN {
      success: true,
      run_id: $run_id,
      parent_run_id: $parent_run_id,
      data: $deleted_relation
    };
  }
  COMMENT "Supprime une relation entre un élément du catalogue et sa documentation."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_documentation_remove_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour supprimer un enregistrement de documentation."
PERMISSIONS FULL;
