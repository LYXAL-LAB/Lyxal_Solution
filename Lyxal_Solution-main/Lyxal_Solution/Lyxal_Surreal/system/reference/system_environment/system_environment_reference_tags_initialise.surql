-- ================================================================================================
-- | Fichier : system_environment_reference_tags_initialise.surql
-- | Module  : system_environment
-- | Desc.   : Crée les tags de référence pour typer/état des environments (pattern builder)
-- ================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_environment_reference_tags_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation du début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation de la fonction `system_environment_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction principale
  DEFINE FUNCTION IF NOT EXISTS fn::system_environment_reference_tags(
    $parent_run_id: option<string>
  ) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $local_log_extra_tags = ['module_system', 'system_environment', 
    'log_reference_tags'];

    fn::system_log_create_record_system(
      array::union(['log_function', 'log_start'], $local_log_extra_tags),
      'Start: création des tags de référence pour `system_environment`',
      { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    -- Définition des tags (types + statuts)
    LET $tags_to_create = [
      { name: 'system_environment_type_instance',   label: 'Env Type - Instance',   
      description: 'Tag pour les environments de type Instance.', color: '#3498DB', order: 100 },
      { name: 'system_environment_type_namespace',  label: 'Env Type - Namespace', 
      description: 'Tag pour les environments de type Namespace.', color: '#2980B9', order: 110 },
      { name: 'system_environment_type_database',   label: 'Env Type - Database', 
      description: 'Tag pour les environments de type Database.', color: '#1ABC9C', order: 120 },
      { name: 'system_environment_active',          label: 'Env Status - Active',    
      description: 'Environment actif et utilisable.', color: '#2ECC71', order: 300 },
      { name: 'system_environment_inactive',        label: 'Env Status - Inactive', 
       description: 'Environment inactif ou désactivé.',  color: '#95A5A6', order: 310 },
      { name: 'system_environment_suspended',       label: 'Env Status - Suspended', 
      description: 'Environment suspendu temporairement.', color: '#E67E22', order: 320 }
    ];

    LET $results = [];
    FOR $tag IN $tags_to_create {
      LET $result = fn::system_tag_create_record_system(
        $tag.name, $tag.label, $tag.description,
        $tag.color, $tag.order, true,
        ['log_data_reference'],
        $run_id
      );
      LET $results = array::push($results, $result);
    };

    fn::system_log_create_record_system(
      array::union(['log_function', 'log_done', 'log_success'], $local_log_extra_tags),
      'Done: création des tags de référence terminée.',
      { run_id: $run_id, parent_run_id: $parent_run_id, count: array::len($results) }
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id, data: $results };
  }
  COMMENT 'Crée les tags de référence pour system_environment.'
  PERMISSIONS FULL;

  -- Journalisation de fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
    $log_extra_tags),
    'Done: initialisation de la fonction `system_environment_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la fonction de création des tags de référence pour system_environment.'
PERMISSIONS FULL;


