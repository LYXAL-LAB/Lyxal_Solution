-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_create_initialise.surql
-- | Module : system_schedule
-- | Description : Crée un nouveau dossier pour organiser les tâches planifiées
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_create_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_create`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_create(
    $environment_id: string,
    $description: option<string>
  ) {
    -- Validation des paramètres
    IF $environment_id = NONE OR $environment_id = '' {
      THROW "L'environnement est requis";
    };
    
    -- Vérifier que l'environnement existe et récupérer son nom
    LET $env = (SELECT * FROM type::thing('system_environment', $environment_id));
    IF count($env) = 0 {
      THROW "L'environnement spécifié n'existe pas";
    };
    LET $environment_name = $env[0].name;
    
    -- Générer le nom du dossier
    LET $name = 'folder_' + $environment_name;
    
    -- Vérifier l'unicité du nom dans cet environnement
    LET $existing = SELECT * FROM system_schedule_folder 
      WHERE name = $name AND environment = type::thing('system_environment', $environment_id);
    IF count($existing) > 0 {
      THROW "Un dossier avec ce nom existe déjà dans cet environnement";
    };
    
    -- Générer l'ID du dossier
    LET $folder_id = 'system_schedule_' + $name;
    
    -- Créer le dossier
    LET $folder = CREATE type::thing('system_schedule_folder', $folder_id) SET
      name = $name,
      environment = type::thing('system_environment', $environment_id),
      description = $description,
      created_at = time::now(),
      updated_at = time::now();
    
    -- Journalisation de fin
    fn::system_log_create_record_system(
        ['log_function', 'log_create', 'log_done', 'log_success'],
        "Dossier de planification créé avec succès.",
        { 
            created_folder: $folder
        }
    );
    
    RETURN $folder;
  }
  COMMENT 'Crée un nouveau dossier pour organiser les tâches planifiées.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_create`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de création de dossier.'
PERMISSIONS FULL;
