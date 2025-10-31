-- Initialisation de la fonction de création de la table de relation base_metafile_tag
DEFINE FUNCTION fn::base_metafile_tag_create_table_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_base', 'sub_module_base_research_metadata'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_start'], $log_extra_tags),
    'Start: création de la table de relation `base_metafile_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id, input: { table: 'base_metafile_tag' } }
  );

  -- Définition de la table
  DEFINE TABLE IF NOT EXISTS base_metafile_tag TYPE RELATION
    COMMENT 'Relation entre un metafile et un tag system.'
    PERMISSIONS FULL;

  -- Définition des champs
  DEFINE FIELD IF NOT EXISTS in ON TABLE base_metafile_tag TYPE record<base_metafile>
    COMMENT 'Référence vers le metafile';

  DEFINE FIELD IF NOT EXISTS out ON TABLE base_metafile_tag TYPE record<system_tag>
    COMMENT 'Référence vers le tag';
  
  DEFINE FIELD IF NOT EXISTS added_at ON TABLE base_metafile_tag TYPE datetime DEFAULT time::now()
    COMMENT 'Date d\'ajout de la relation';

  -- Définition des index
  DEFINE INDEX IF NOT EXISTS idx_metafile_tag_unique ON base_metafile_tag FIELDS in, out UNIQUE;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: création de la table de relation `base_metafile_tag`',
    { run_id: $run_id, parent_run_id: $parent_run_id, table: 'base_metafile_tag' }
  );

  -- Retour de la fonction
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la création de la table de relation base_metafile_tag"
PERMISSIONS FULL;
