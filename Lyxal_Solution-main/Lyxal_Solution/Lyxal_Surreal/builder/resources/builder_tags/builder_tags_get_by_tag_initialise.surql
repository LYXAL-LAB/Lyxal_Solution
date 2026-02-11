-- Initialisation de la fonction pour récupérer les éléments du catalogue par tag
DEFINE FUNCTION fn::builder_tags_get_by_tag_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'relation_function'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_tags_get_by_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_tags_get_by_tag(
    $tag_id: string,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_relation', 'log_read'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: récupération des éléments du catalogue pour un tag',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { tag_id: $tag_id } }
    );

    -- Construction de l'entité tag
    LET $to_entity = type::thing('system_tag', $tag_id);

    -- Récupération des éléments
    LET $items = (SELECT in AS item FROM builder_tags WHERE out = $to_entity FETCH item);

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: récupération des éléments terminée',
        { run_id: $run_id, parent_run_id: $parent_run_id, result_count: array::len($items) }
    );

    -- Retour
    RETURN {
      success: true,
      run_id: $run_id,
      parent_run_id: $parent_run_id,
      data: $items
    };
  }
  COMMENT "Récupère tous les éléments du catalogue associés à un tag spécifique."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_tags_get_by_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour récupérer les éléments du catalogue par tag."
PERMISSIONS FULL;
