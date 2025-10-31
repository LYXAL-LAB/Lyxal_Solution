-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_list_recursive_initialise.surql
-- | Module : system_schedule
-- | Description : Liste les dossiers d'un environnement et de tous ses descendants.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_list_recursive_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_list_recursive`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_list_recursive(
    $environment_id: string
  ) {
    -- 1. Valider le paramètre
    IF $environment_id = NONE OR $environment_id = '' {
      THROW "L'ID de l'environnement est requis";
    };

    -- 2. Récupérer l'environnement parent lui-même pour s'assurer qu'il existe
    LET $parent_env = SELECT * FROM ONLY type::thing('system_environment', $environment_id);
    IF count($parent_env) = 0 {
      THROW "L'environnement spécifié n'existe pas.";
    };

    -- 3. Récupérer tous les descendants
    LET $descendants = fn::system_environment_get_descendants($environment_id);

    -- 4. Créer une liste de tous les IDs d'environnement pertinents (parent + enfants)
    LET $all_env_ids = [$parent_env[0].id];
    FOR $descendant IN $descendants {
        $all_env_ids = array::push($all_env_ids, $descendant.id);
    };

    -- 5. Récupérer tous les dossiers appartenant à ces environnements
    LET $folders = SELECT * FROM system_schedule_folder
      WHERE environment IN $all_env_ids
      ORDER BY environment ASC, name ASC;
      
    RETURN $folders;
  }
  COMMENT 'Liste les dossiers d\'un environnement et de tous ses descendants.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_list_recursive`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de listage récursif des dossiers.'
PERMISSIONS FULL;
