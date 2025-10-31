DEFINE FUNCTION IF NOT EXISTS fn::system_deploy(
    $parent_run_id: option<string>
  ) {
    -- Parameters
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system', 'log_deploy'];
    LET $run_id = rand::uuid();
    LET $total_steps = 4;
    LET $step = 0;




    
    RETURN { run_id: $run_id, parent_run_id: $parent_run_id, success: true, 
    message: "Déploiement des composants du module `system` terminé." };
  }
  COMMENT 'Orchestre le déploiement de tous les composants du module system.'
  PERMISSIONS FULL;