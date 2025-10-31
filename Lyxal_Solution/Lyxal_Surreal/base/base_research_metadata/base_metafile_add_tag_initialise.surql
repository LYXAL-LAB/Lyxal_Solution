-- Initialisation de la fonction pour lier un tag à un metafile
DEFINE FUNCTION fn::base_metafile_add_tag_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_base', 'sub_module_base_research_metadata'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `base_metafile_add_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::base_metafile_add_tag(
    $metafile_id: string,
    $tag_id: string,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_base','sub_module_base_research_metadata', 'log_relation'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: liaison d\'un tag à un metafile',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { metafile_id: $metafile_id, tag_id: $tag_id } }
    );

    -- Construction des records
    LET $from_entity = type::thing('base_metafile', $metafile_id);
    LET $to_entity = type::thing('system_tag', $tag_id);

    -- Création de la relation
    LET $relation = RELATE $from_entity->base_metafile_tag->$to_entity;

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: tag lié au metafile',
        { run_id: $run_id, parent_run_id: $parent_run_id, result: $relation[0] }
    );

    -- Retour
    RETURN {
      success: true,
      run_id: $run_id,
      parent_run_id: $parent_run_id,
      data: $relation[0]
    };
  }
  COMMENT "Lie un tag à un metafile via la table base_metafile_tag."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `base_metafile_add_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour lier un tag à un metafile."
PERMISSIONS FULL;
