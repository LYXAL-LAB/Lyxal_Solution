-- Initialisation de la fonction pour ajouter un enregistrement de documentation
DEFINE FUNCTION fn::builder_documentation_add_record_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_documentation_add_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_documentation_add_record(
    $from: string, -- id de type builder_ issu du catalogue
    $type: string, -- type de l'entité à lier (builder_module, builder_template, builder_function, builder_plugin, builder_data)
    $to_id: string, --id de base_metafile
    $lang_id: option<string>,
    $version: option<string>,
    $tags_documentation: option<array<string>>, --tags eventuels à associer au document
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_relation'];

    -- Journalisation
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: ajout d\'une relation de documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id, input: { from: $from, to: $to_id, lang: $lang_id, version: $version } }
    );

    -- Récupération de l'entité du catalogue
    LET $from_entity = type::thing($type, $from);
    -- Création de la relation
    LET $relation = RELATE $from_entity->builder_documentation->$to_id SET
      lang = $lang_id,
      version = $version;

      -- Ajout des tags à la relation base_metafile system_tag
    LET $tags_documentation = $tags_documentation OR [];
    LET $tag_results = NONE;
    IF array::len($tags_documentation) > 0 THEN
      $tag_results = array::map($tags_documentation, function($tag_id) {
        RETURN fn::base_metafile_add_tag($to_id, $tag_id, $run_id);
      });
    END;

    -- Journalisation de fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: relation de documentation ajoutée',
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
  COMMENT "Ajoute une relation entre un élément du catalogue et sa documentation."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_documentation_add_record`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction pour ajouter un enregistrement de documentation."
PERMISSIONS FULL;
