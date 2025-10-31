-- =================================================================================================
-- |
-- | Fichier : system_schedule_create_job_initialise.surql
-- | Module : system_schedule
-- | Description : Orchestre la création d'un job (distant et local) et son assignation à un dossier.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_create_job_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_create_job`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_create_job(
    $folder_id: string,
    $body_query: string,
    $request_method: int,
    $schedule: object,
    $enabled: bool,
    $save_responses: bool,
    $title: string,
    $job_type: string,
    -- Paramètres additionnels pour l'enregistrement local
    $description: option<string>,
    $tags: option<array<record<system_tag>>>,
    $id: option<string>,
    -- Paramètres pour cron-job.org
    $notification: option<object>,
    $auth: option<object>,
    $request_timeout: option<int>,
    $redirect_success: option<bool>
  ) {
    -- 1. Valider que le dossier existe
    IF ($folder_id = NONE OR $folder_id = '') {
        THROW "L'ID du dossier est obligatoire.";
    };
    LET $folder = SELECT * FROM type::thing('system_schedule_folder', $folder_id);
    IF (count($folder) = 0) {
      THROW "Le dossier spécifié n'existe pas.";
    };
    -- Récupérer l'environnement à partir du dossier parent.
    LET $environment_record = $folder.environment[0];

    -- 2. Créer le job distant via l'API
    LET $remote_job = fn::system_schedule_create_job_cronjoborg(
        $body_query, $request_method, $schedule, $enabled, $save_responses,
        $title, $notification, $auth, $request_timeout, $redirect_success
    );

    -- Vérifier si la création du job distant a échoué.
    IF ($remote_job.error) {
        LET $error_message = $remote_job.message OR `Erreur ${string($remote_job.status)}: ${$remote_job.statusText}`;
        LET $error_details = $remote_job.body OR "Aucun détail supplémentaire.";
        
        fn::system_log_create_record_system(
            ['system_schedule_create_job', 'error'],
            'La création du cron job distant a échoué.',
            { 
                error: $error_message,
                details: $error_details
            }
        );
        RETURN { error: true, message: $error_message, details: $error_details };
    };

    -- Créer l'enregistrement local du job de planification.
    LET $local_job = CREATE system_schedule SET
        id = ($id OR rand::uuid()),
        namespace = $surreal_namespace,
        database = $surreal_database,
        job_type = $job_type,
        title = $title,
        description = $description,
        tags = $tags,
        cron_job_id = $remote_job.jobId,
        status = 'active',
        schedule = $schedule,
        enabled = $enabled,
        save_responses = $save_responses,
        request_method = $request_method,
        last_sync = time::now(),
        created_at = time::now(),
        updated_at = time::now(),
        environment = $environment_record
    ;

    -- Lier le job au dossier parent.
    RELATE $local_job->system_schedule_job_folder->$folder;

    -- Enregistrer un log de succès.
    fn::system_log_create_record_system(
        ['system_schedule_create_job', 'success'],
        'Le cron job a été créé avec succès localement et à distance.',
        {
            local_job_id: $local_job.id,
            remote_job_id: $remote_job.jobId
        }
    );

    -- Retourner les informations sur le job créé.
    RETURN {
        local_job: $local_job[0],
        remote_job_id: $remote_job.jobId
    };
  }
  COMMENT 'Crée un job distant et local, et l\'assigne à un dossier.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_create_job`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction d\'orchestration de création de job.'
PERMISSIONS FULL;
