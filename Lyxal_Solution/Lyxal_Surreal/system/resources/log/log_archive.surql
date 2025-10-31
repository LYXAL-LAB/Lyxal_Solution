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
-- |   1. Sélectionne les logs dans `log` où `log_date.expires_at` est dans le passé.
-- |   2. Lit `app_configuration` pour obtenir la durée de `cold_retention`.
-- |   3. Calcule la nouvelle date d'expiration pour les archives.
-- |   4. Copie les logs dans `log_archive` en mettant à jour `log_date.expires_at`.
-- |   5. Supprime les logs originaux de la table `log`.
-- |
-- | Retour :
-- |   - { archived_count: number, deleted_count: number }
-- =============================================================================================
DEFINE FUNCTION fn::log_archive() {
    -- Étape 1: Identifier les logs dont la rétention chaude a expiré
    LET $now = time::now();
    LET $logs_to_archive = SELECT * FROM log WHERE log_date.expires_at <= $now;

    IF array::len($logs_to_archive) = 0 {
      RETURN { archived_count: 0, deleted_count: 0, message: 'No logs to archive' };
    }

    -- Étape 2: Récupérer la configuration pour la rétention froide
    LET $config = (SELECT * FROM app_configuration:default)[0];
    IF $config IS NONE {
        -- On ne peut pas continuer sans configuration, on logue une erreur critique
        -- Note: Cette fonction de log devra être créée ou adaptée
        -- fn::log_create_record(...); 
        RETURN { error: true, message: 'app_configuration:default not found' };
    };

    -- Étape 3: Calculer la nouvelle date d'expiration pour l'archive
    LET $retention_unit = $config.log_configuration.cold_retention.unit;
    LET $retention_value = $config.log_configuration.cold_retention.value;
    LET $retention_duration = 
        IF $retention_unit = 'seconds' { <duration>::from_secs($retention_value) }
        ELSE IF $retention_unit = 'minutes' { <duration>::from_mins($retention_value) }
        ELSE IF $retention_unit = 'hours' { <duration>::from_hours($retention_value) }
        ELSE IF $retention_unit = 'days' { <duration>::from_days($retention_value) }
        ELSE IF $retention_unit = 'weeks' { <duration>::from_weeks($retention_value) }
        ELSE { <duration>::from_days(365) } -- Fallback de sécurité sur 1 an
    ;
    LET $new_expiration_date = $now + $retention_duration;

    -- Étape 4: Créer les enregistrements dans l'archive avec la nouvelle date d'expiration
    LET $archived = CREATE log_archive CONTENT (
        SELECT
            result, operation, resource, target, message, user_id, meta, data, before, after,
            {
                timestamp: log_date.timestamp,
                year: log_date.year,
                week: log_date.week,
                day: log_date.day,
                expires_at: $new_expiration_date
            } AS log_date
        FROM $logs_to_archive
    );

    -- Étape 5: Supprimer les logs originaux
    LET $deleted = DELETE $logs_to_archive;

    -- Étape 6: Retourner le résultat
    RETURN {
        archived_count: array::len($archived),
        deleted_count: array::len($deleted)
    };
  }
  COMMENT 'Archive les logs expirés de `log` vers `log_archive` en appliquant la politique de rétention froide.';
