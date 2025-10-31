-- =============================================================================================
-- |
-- | Fichier : log_cleanup.surql
-- | Module : system / log
-- | Description : Supprime définitivement les logs de la table `log_archive` lorsque leur
-- |               date d'expiration de rétention "froide" (cold_retention) est atteinte.
-- |
-- | Comportement :
-- |   - Sélectionne les logs dans `log_archive` où `log_date.expires_at` est dans le passé.
-- |   - Supprime définitivement ces enregistrements.
-- |
-- | Retour :
-- |   - { deleted_count: number }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::log_cleanup() {
    -- Étape 1: Identifier les archives dont la rétention froide a expiré
    LET $now = time::now();
    LET $archives_to_delete = SELECT id FROM log_archive WHERE log_date.expires_at <= $now;

    IF array::len($archives_to_delete) = 0 {
      RETURN { deleted_count: 0, message: 'No archived logs to delete' };
    }

    -- Étape 2: Supprimer les archives expirées
    LET $deleted = DELETE $archives_to_delete;

    -- Étape 3: Retourner le résultat
    RETURN {
      deleted_count: array::len($deleted)
    };
  }
  COMMENT "Supprime les enregistrements de `log_archive` dont la date d'expiration est passée."
  PERMISSIONS FULL;