DEFINE FUNCTION IF NOT EXISTS fn::system_log_archive_cleanup(
    $older_than_days: int,
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_system'];

    -- Calcul de la date limite
    LET $cutoff_date = time::now() - <duration>$older_than_days + 'd';



    -- Suppression des anciens logs archivés
    LET $deleted_logs = (DELETE system_log_archive WHERE timestamp < $cutoff_date);
    LET $deleted_count = count($deleted_logs);



    -- Retour
    RETURN {
      success: true,
      run_id: $run_id,
      message: "Nettoyage des archives terminé.",
      deleted_count: $deleted_count
    };
  }
  COMMENT "Supprime les enregistrements de system_log_archive plus anciens que le nombre de jours spécifié."
  PERMISSIONS FULL;

