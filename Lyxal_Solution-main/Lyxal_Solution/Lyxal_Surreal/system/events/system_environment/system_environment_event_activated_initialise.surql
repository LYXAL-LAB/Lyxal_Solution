-- ================================================================================================
-- | Fichier : system_environment_event_activated_initialise.surql
-- | Module  : system_environment
-- | Desc.   : Définit l'événement qui active les tâches planifiées lors de l'activation d'un environnement.
-- ================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_environment_event_activated_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation du début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_event', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de l_événement `event_environment_activated`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Événement pour l'activation
  DEFINE EVENT IF NOT EXISTS event_environment_activated ON TABLE system_environment_tag WHEN
    type::table($after.out) = 'system_environment' AND $after.in = system_tag:system_environment_active
  THEN {
    LET $folder = (SELECT * FROM system_schedule_folder WHERE environment = $after.out);
    IF count($folder) > 0 {
        fn::system_schedule_folder_enable_jobs($folder[0].id);
    };
  };

  -- Journalisation de fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_event', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de l_événement `event_environment_activated`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise l_événement pour l_activation d_un environnement.'
PERMISSIONS FULL;
