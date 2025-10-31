-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_list_initialise.surql
-- | Module : system_schedule
-- | Description : Liste les dossiers disponibles pour un environnement
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_list_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_list`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_list(
    $environment_id: option<string>
  ) {
    -- Si un environnement est spécifié, filtrer par cet environnement
    IF $environment_id != NONE {
      RETURN SELECT * FROM system_schedule_folder 
        WHERE environment = type::thing('system_environment', $environment_id)
        ORDER BY name ASC;
    };
    
    -- Sinon, retourner tous les dossiers
    RETURN SELECT * FROM system_schedule_folder 
      ORDER BY environment ASC, name ASC;
  }
  COMMENT 'Liste les dossiers disponibles, optionnellement filtrés par environnement.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_list`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de listage des dossiers.'
PERMISSIONS FULL;
