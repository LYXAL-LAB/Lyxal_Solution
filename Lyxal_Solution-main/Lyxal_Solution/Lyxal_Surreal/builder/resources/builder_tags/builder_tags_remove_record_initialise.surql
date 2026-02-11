-- Initialisation de la fonction pour supprimer une relation de tag
DEFINE FUNCTION fn::builder_tags_remove_record_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'relation_function'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_tags_remove_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_tags_remove_record(
    $from_id: string,
    $from_type: string,
    $tag_id: string,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_relation'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start', 'log_delete'], $log_extra_tags),
        'Start: suppression d\'une liaison de tag',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { from_id: $from_id, from_type: $from_type, tag_id: $tag_id } }
    );

    -- Construction des records
    LET $from_entity = type::thing($from_type, $from_id);
    LET $to_entity = type::thing('system_tag', $tag_id);

    -- Suppression de la relation
    LET $deleted_relation = DELETE builder_tags WHERE in = $from_entity AND out = $to_entity;

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success', 'log_delete'], $log_extra_tags),
        'Done: liaison de tag supprimée',
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
  COMMENT "Détache un tag d'un élément du catalogue en supprimant la relation dans builder_tags."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_tags_remove_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour détacher un tag d'un élément du catalogue."
PERMISSIONS FULL;
