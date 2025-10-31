-- =================================================================================================
-- |
-- | Fichier : system_schedule_security_initialise.surql
-- | Module : system_schedule
-- | Description : Ce fichier initialise la sécurité pour les tâches planifiées.
-- |              Il crée un utilisateur de service dédié.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_security_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_user', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de l\'utilisateur de service `scheduler_user`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- 1. Définir un utilisateur de service avec des permissions minimales.
  --    Cet utilisateur n'a pas de mot de passe car l'authentification se fera via un token.
  --    Ses droits seront définis par le SCOPE implicite de sa session,
  --    mais pour appeler une fonction, il faut être un utilisateur DB, NS ou ROOT.
  --    Nous le créons en tant qu'utilisateur NAMESPACE pour plus de sécurité.
  DEFINE USER IF NOT EXISTS scheduler_user ON NAMESPACE PASSWORD '';

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_user', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de l\'utilisateur de service `scheduler_user`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise l\'utilisateur de service pour le planificateur.'
PERMISSIONS FULL;

