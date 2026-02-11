-- Initialisation de la fonction de création de la table de relation générique builder_tags
DEFINE FUNCTION fn::builder_tags_create_table_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'relation_table'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_start'], $log_extra_tags),
    'Start: création de la table de relation `builder_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id, input: { table: 'builder_tags' } }
  );

  -- Définition de la table
  DEFINE TABLE IF NOT EXISTS builder_tags TYPE RELATION
    COMMENT 'Relation générique entre un élément du catalogue et un tag system.'
    PERMISSIONS FULL;

  -- Définition des champs
  DEFINE FIELD IF NOT EXISTS in ON TABLE builder_tags TYPE record
    COMMENT 'Référence vers l élément du catalogue (module, template, etc.)';

  DEFINE FIELD IF NOT EXISTS out ON TABLE builder_tags TYPE record<system_tag>
    COMMENT 'Référence vers le tag';
  
  DEFINE FIELD IF NOT EXISTS added_at ON TABLE builder_tags TYPE datetime DEFAULT time::now()
    COMMENT 'Date d ajout de la relation';

  -- Définition des index
  DEFINE INDEX IF NOT EXISTS idx_builder_tags_unique ON builder_tags FIELDS in, out UNIQUE;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: création de la table de relation `builder_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_tags' }
  );

  -- Retour de la fonction
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la création de la table de relation générique builder_tags."
PERMISSIONS FULL;
