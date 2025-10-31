-- Initialisation de la fonction pour récupérer les tags d'un élément du catalogue
DEFINE FUNCTION fn::builder_tags_get_by_record_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'relation_function'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_tags_get_by_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_tags_get_by_record(
    $from_id: string,
    $from_type: string,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_relation', 'log_read'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: récupération des tags pour un élément du catalogue',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { from_id: $from_id, from_type: $from_type } }
    );

    -- Construction de l'entité
    LET $from_entity = type::thing($from_type, $from_id);

    -- Récupération des tags
    LET $tags = (SELECT out AS tag FROM builder_tags WHERE in = $from_entity FETCH tag);

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: récupération des tags terminée',
        { run_id: $run_id, parent_run_id: $parent_run_id, result_count: array::len($tags) }
    );

    -- Retour
    RETURN {
      success: true,
      run_id: $run_id,
      parent_run_id: $parent_run_id,
      data: $tags
    };
  }
  COMMENT "Récupère tous les tags associés à un élément spécifique du catalogue."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_tags_get_by_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour récupérer les tags d'un élément du catalogue."
PERMISSIONS FULL;
