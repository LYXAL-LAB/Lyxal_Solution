-- Initialisation de la fonction de création de la table builder_documentation
DEFINE FUNCTION fn::builder_documentation_create_table_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_start'], $log_extra_tags),
    'Start: création de la table `builder_documentation`',
    { run_id: $run_id, parent_run_id: $parent_run_id, input: { table: 'builder_documentation' } }
  );

-- Table
DEFINE TABLE IF NOT EXISTS builder_documentation TYPE RELATION
  COMMENT 'Relation entre un élément du catalogue et sa documentation (base_metafile)'
  PERMISSIONS FULL;

-- Fields
DEFINE FIELD IF NOT EXISTS from ON TABLE builder_documentation TYPE record
  COMMENT 'Élément du catalogue (ex: builder_module:crm)';

DEFINE FIELD IF NOT EXISTS to ON TABLE builder_documentation TYPE record<base_metafile>
READONLY
VALUE type::thing('base_metafile', $value)
  COMMENT 'Fichier de documentation (base_metafile)';

DEFINE FIELD IF NOT EXISTS lang ON TABLE builder_documentation TYPE option<record<base_language>>
READONLY
VALUE type::thing('base_language', $value)
 COMMENT 'Langue de la documentation (spécifique à la relation)';

DEFINE FIELD IF NOT EXISTS version ON TABLE builder_documentation TYPE string DEFAULT '1.0.0'
  COMMENT 'Version de la documentation pour cette entité';

DEFINE FIELD IF NOT EXISTS added_at ON TABLE builder_documentation TYPE datetime DEFAULT time::now()
COMMENT 'Date d\'ajout de la relation';

-- Index
DEFINE INDEX IF NOT EXISTS idx_builder_doc_from ON builder_documentation FIELDS from
COMMENT 'Index sur l\'entité du catalogue';

DEFINE INDEX IF NOT EXISTS idx_builder_doc_to ON builder_documentation FIELDS to
COMMENT 'Index sur la documentation';

DEFINE INDEX IF NOT EXISTS idx_builder_doc_from_to ON builder_documentation FIELDS from, to UNIQUE
COMMENT 'Index sur l\'entité du catalogue et la documentation';

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: création de la table `builder_documentation`',
    { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_documentation' }
  );

  -- Retour de la fonction
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la création de la table builder_documentation"
PERMISSIONS FULL;
