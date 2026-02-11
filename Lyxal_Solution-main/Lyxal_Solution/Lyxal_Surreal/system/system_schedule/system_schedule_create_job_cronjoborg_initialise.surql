-- =================================================================================================
-- |
-- | Fichier : system_schedule_create_job_cronjoborg_initialise.surql
-- | Module : system_schedule
-- | Description : Définit la fonction pour créer un job dans cron-job.org.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_create_job_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_create_job_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_create_job_cronjoborg(
    $body_query: string,
    $request_method: int,
    $schedule: object,
    $enabled: bool,
    $save_responses: bool,
    $title: string,
    $notification: option<object>,
    $auth: option<object>,
    $request_timeout: option<int>,
    $redirect_success: option<bool>
  ) {
    RETURN  function() {
      // On récupère explicitement chaque variable SurrealQL via surrealdb.value()
      const title = await surrealdb.value('$title');
      const enabled = await surrealdb.value('$enabled');
      const save_responses = await surrealdb.value('$save_responses');
      const request_method = await surrealdb.value('$request_method');
      const schedule = await surrealdb.value('$schedule');
      const body_query = await surrealdb.value('$body_query');
      const notification = await surrealdb.value('$notification');
      const auth = await surrealdb.value('$auth');
      const request_timeout = await surrealdb.value('$request_timeout');
      const redirect_success = await surrealdb.value('$redirect_success');
      const surreal_instance = await surrealdb.value('$surreal_instance');
      const surreal_token = await surrealdb.value('$cronjob_surreal_token');
      const surreal_namespace = await surrealdb.value('$surreal_namespace');
      const surreal_database = await surrealdb.value('$surreal_database');
      const cronjob_api_key = await surrealdb.value('$cronjob_api_key');

      // Validation des paramètres récupérés
      const params = {
        title, enabled, save_responses, request_method, schedule,
        body_query, notification, auth, request_timeout, redirect_success,
        surreal_instance, surreal_token, surreal_namespace, surreal_database,
        cronjob_api_key
      };

      // Construction des variables finales pour le débogage
      const surreal_url = 'https://' + params.surreal_instance + '.surrealdb.cloud/sql';
      const api_url = `https://api.cron-job.org/jobs`;
      const job = {
        title: params.title,
        url: surreal_url,
        enabled: params.enabled,
        saveResponses: params.save_responses,
        requestMethod: 1, // POST
        
        // Compléter l'objet schedule pour correspondre exactement à la documentation de l'API
        schedule: {
          timezone: params.schedule.timezone,
          expiresAt: 0, // Valeur par défaut
          hours: params.schedule.hours ?? [-1],
          mdays: params.schedule.mdays ?? [-1],
          minutes: params.schedule.minutes ?? [-1],
          months: params.schedule.months ?? [-1],
          wdays: params.schedule.wdays ?? [-1]
        },
        
        extendedData: {
          body: params.body_query,
          headers: {
            "Authorization": 'Bearer ' + params.surreal_token,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "NS": params.surreal_namespace,
            "DB": params.surreal_database
          }
        }
      };

      // L'API cron-job.org attend que l'objet du job soit encapsulé dans un objet parent avec la clé "job".
      const payload = {
           job: job
      };

     try {
       const response = await fetch(api_url, {
         method: 'PUT', // La création se fait avec PUT
         headers: {
           'Authorization': 'Bearer ' + params.cronjob_api_key,
           'Content-Type': 'application/json'
         },
         body: JSON.stringify(payload)
       });

       if (!response.ok) {
         const errorText = await response.text();
         // Retourner une structure d'erreur claire pour le débogage
         return {
           error: true,
           status: response.status,
           statusText: response.statusText,
           body: errorText,
           message: `L'API Cron-job.org a retourné une erreur.`
         };
       }

       // Tenter de parser la réponse en JSON. La réponse peut être vide sur certains succès.
       const responseText = await response.text();
       if (responseText) {
         return JSON.parse(responseText);
       }
       return { success: true }; // Retourner un succès générique si le corps est vide

     } catch (e) {
       // Gérer les erreurs réseau ou autres exceptions
       return {
         error: true,
         message: e.message
       };
     }
    };
  }
  COMMENT 'Crée un job dans cron-job.org pour exécuter la maintenance des logs.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_create_job_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de création de job cron-job.org.'
PERMISSIONS FULL;
