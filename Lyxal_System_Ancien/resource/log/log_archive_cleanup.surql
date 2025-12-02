DEFINE FUNCTION IF NOT EXISTS fn::log_archive_cleanup(
    $older_than_days: int
  ) {

    -- Calcul de la date limite
    LET $cutoff_date = time::now() - <duration>$older_than_days + 'd';

    -- Suppression des anciens logs archivés
    LET $deleted_logs = (DELETE log_archive WHERE timestamp.created_at < $cutoff_date);
    LET $deleted_count = count($deleted_logs);

    -- Retour
    RETURN {
      success: true,
      reason_code: 'log_archive_cleanup_success',
      deleted_count: $deleted_count
    };
  }
  COMMENT "Supprime les enregistrements de `log_archive` plus anciens que le nombre de jours spécifié."
  PERMISSIONS FULL;
