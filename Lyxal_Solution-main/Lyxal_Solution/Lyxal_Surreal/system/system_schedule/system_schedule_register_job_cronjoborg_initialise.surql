-- =================================================================================================
-- |
-- | Fichier : system_schedule_register_job_cronjoborg_initialise.surql
-- | Module : system_schedule
-- | Description : Définit la fonction pour créer un job cron-job.org et l'enregistrer
-- |              dans la table `system_schedule`.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_register_job_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_register_job_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction de registre
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_register_job_cronjoborg(
    $namespace: string,
    $database: string,
    $job_type: string,
    $title: string,
    $body_query: string,
    $request_method: int,
    $schedule: object,
    $enabled: bool,
    $save_responses: bool,
    $notification: option<object>,
    $auth: option<object>,
    $request_timeout: option<int>,
    $redirect_success: option<bool>
  ) {
    LET $now = time::now();
    LET $api_result = fn::system_schedule_create_job_cronjoborg(
      $body_query,
      $request_method,
      $schedule,
      $enabled,
      $save_responses,
      $title,
      $notification,
      $auth,
      $request_timeout,
      $redirect_success
    );
    LET $job_id = $api_result.jobId;
    LET $schedule_id = NONE;

    -- Recherche d'un enregistrement existant pour (namespace,database,job_type)
    LET $existing = (
      SELECT id FROM system_schedule WHERE namespace = $namespace AND database = $database AND job_type = $job_type LIMIT 1
    );

    IF array::len($existing) > 0 THEN {
      UPDATE $existing[0].id SET
        title = $title,
        request_method = $request_method,
        schedule = $schedule,
        enabled = $enabled,
        save_responses = $save_responses,
        cron_job_id = $job_id,
        last_sync = $now,
        status = 'updated';
      LET $schedule_id = $existing[0].id;
    } ELSE {
      LET $new_schedule = CREATE system_schedule SET
        namespace = $namespace,
        database = $database,
        job_type = $job_type,
        title = $title,
        request_method = $request_method,
        schedule = $schedule,
        enabled = $enabled,
        save_responses = $save_responses,
        cron_job_id = $job_id,
        last_sync = $now,
        status = 'created';
      LET $schedule_id = $new_schedule.id;
    } END;

    -- Auto-tag idempotent (module + job)
    IF $schedule_id != NONE THEN {
      LET $tag_module = type::thing('system_tag', 'system_schedule');
      LET $tag_job = type::thing('system_tag', 'system_schedule_job');
      LET $tag_gateway = type::thing('system_tag', 'system_schedule_gateway');
      fn::system_schedule_tag_add($schedule_id, $tag_module);
      fn::system_schedule_tag_add($schedule_id, $tag_job);
      fn::system_schedule_tag_add($schedule_id, $tag_gateway);
    } END;

    RETURN {
      success: $job_id != NONE,
      job_id: $job_id,
      api_result: $api_result
    };
  }
  COMMENT 'Crée un job cron-job.org et l\'enregistre dans system_schedule.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_register_job_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction d\'enregistrement de job cron-job.org.'
PERMISSIONS FULL;
