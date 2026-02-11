-- =============================================================================================
-- |
-- | Fichier : log_archive.surql
-- | Module : system / log
-- | Description : Déplace les logs de la table `log` vers `log_archive` lorsque leur
-- |               date d'expiration de rétention "chaude" (hot_retention) est atteinte.
-- |               Une nouvelle date d'expiration basée sur la rétention "froide"
-- |               (cold_retention) est calculée et assignée aux logs archivés.
-- |
-- | Comportement :
-- |   1. Sélectionne les logs dans `log` où `timestamp.expires_at` est dans le passé.
-- |   2. Lit `system_configuration` pour obtenir la durée de `cold_retention`.
-- |   3. Calcule la nouvelle date d'expiration pour les archives.
-- |   4. Copie les logs dans `log_archive` en mettant à jour `timestamp.expires_at` et les métadonnées d'archivage.
-- |   5. Supprime les logs originaux de la table `log`.
-- |
-- | Retour :
-- |   - { success: true, reason_code: "log_archive_success", archived_count: number, deleted_count: number }
-- |   - { success: true, reason_code: "log_archive_no_logs_to_archive", archived_count: 0, deleted_count: 0 }
-- |   - { success: false, reason_code: "log_archive_failed_config_not_found" }
-- =============================================================================================
DEFINE FUNCTION fn::log_archive() {
    -- Étape 1: Identifier les logs dont la rétention chaude a expiré
    LET $now = time::now();
    LET $logs_to_archive = SELECT * FROM log WHERE timestamp.expires_at <= $now;

    IF array::len($logs_to_archive) = 0 {
      RETURN { 
        success: true, 
        reason_code: 'log_archive_no_logs_to_archive',
        archived_count: 0, 
        deleted_count: 0 
      };
    };

    -- Étape 2: Récupérer la configuration pour la rétention froide
    LET $config = (SELECT * FROM system_configuration:default)[0];
    IF $config IS NONE {
        -- On ne peut pas continuer sans configuration, on logue une erreur critique
        -- Note: Cette fonction de log devra être créée ou adaptée
        -- fn::log_create_record(...); 
        RETURN { success: false, reason_code: 'log_archive_failed_config_not_found' };
    };

    -- Étape 3: Calculer la nouvelle date d'expiration pour l'archive
    -- Récupération de l'unité de temps (référence à time_unit)
    LET $retention_unit_record = $config.log_configuration.cold_retention.unit;
    IF $retention_unit_record IS NONE {
        RETURN { success: false, reason_code: 'log_archive_failed_config_invalid' };
    };
    LET $retention_unit_value = $retention_unit_record.identity.value;
    LET $retention_value = $config.log_configuration.cold_retention.value;
    
    -- Calcul de la durée selon l'unité (syntaxe correcte : duration::from::* avec deux deux-points)
    LET $retention_duration = 
        IF $retention_unit_value = 'seconds' THEN duration::from::secs($retention_value)
        ELSE IF $retention_unit_value = 'minutes' THEN duration::from::mins($retention_value)
        ELSE IF $retention_unit_value = 'hours' THEN duration::from::hours($retention_value)
        ELSE IF $retention_unit_value = 'days' THEN duration::from::days($retention_value)
        ELSE IF $retention_unit_value = 'weeks' THEN duration::from::weeks($retention_value)
        ELSE IF $retention_unit_value = 'months' THEN duration::from::days($retention_value * 30)
        ELSE IF $retention_unit_value = 'years' THEN duration::from::days($retention_value * 365)
        ELSE duration::from::days(365)
    END;
    LET $new_expiration_date = $now + $retention_duration;

    -- Étape 4: Créer les enregistrements dans l'archive avec la nouvelle structure modulaire
    LET $archived = CREATE log_archive CONTENT (
        SELECT
            identity,
            result,
            operation,
            resource,
            target,
            message,
            content,
            status = {
                is_active: false,
                is_archived: true
            },
            metadata = {
                created_by: metadata.created_by,
                source: metadata.source,
                archived_at: $now,
                archived_by: "system"
            },
            timestamp = {
                created_at: timestamp.created_at,
                updated_at: timestamp.updated_at,
                expires_at: $new_expiration_date,
                year: timestamp.year,
                week: timestamp.week,
                day: timestamp.day
            },
            etag
        FROM $logs_to_archive
    );

    -- Étape 5: Supprimer les logs originaux
    LET $deleted = DELETE $logs_to_archive;

    -- Étape 6: Retourner le résultat
    RETURN {
        success: true,
        reason_code: 'log_archive_success',
        archived_count: array::len($archived),
        deleted_count: array::len($deleted)
    };
  }
  COMMENT 'Archive les logs expirés de `log` vers `log_archive` en appliquant la politique de rétention froide.';
