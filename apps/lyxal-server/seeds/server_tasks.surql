-- ============================================================================
-- SEED   : tâches de fond déclarées par l'hôte
-- HÔTE   : lyxal_server
-- RÔLE   : Purge de lyxal_auth, nettoyage de lyxal_storage et maintenance de lyxal_secrets,
--          exécutés par lyxal_scheduler
-- ============================================================================
-- lyxal_scheduler dépend de lyxal_auth : aucun de ces trois modules ne peut dépendre du
-- planificateur (.agents/AGENTS.md §6). L'hôte, qui les héberge tous, déclare donc leurs tâches
-- à leur place, en session système, après l'installation des modules (les tables
-- auth_permission et scheduler_task existent, la release de chaque module est installée : garde
-- de scheduler_task). Rejouable : rien n'est recréé ni écrasé.
--
-- Exécuteur `handler` : le code Rust est inscrit par l'hôte sous le nom de la tâche
-- (apps/lyxal-server/src/modules/tasks.rs) et appelle l'opération publique du module
-- (AuthPurge, StorageCleanup, SecretsMaintenance). Portée `installation`. Tous les champs sont
-- donnés (une installation en mode import n'applique pas les valeurs par défaut du schéma).
--
-- Permission propre de chaque tâche : attribuée à aucun rôle, elle réserve tout ce qui fait
-- exécuter la tâche (planification, déclenchement, rejeu, relance) à la session système de
-- l'hôte.

-- ----------------------------------------------------------------------------
-- Permissions
-- ----------------------------------------------------------------------------

IF !record::exists(auth_permission:⟨auth.purge.run⟩) THEN (
    CREATE auth_permission:⟨auth.purge.run⟩ CONTENT { code: "auth.purge.run", module: "lyxal_server", scope: "installation", description: { fr: "Faire exécuter la purge de lyxal_auth (réservée à l'hôte)", en: "Run the lyxal_auth purge (host only)" } }
) END;

IF !record::exists(auth_permission:⟨storage.cleanup.run⟩) THEN (
    CREATE auth_permission:⟨storage.cleanup.run⟩ CONTENT { code: "storage.cleanup.run", module: "lyxal_server", scope: "installation", description: { fr: "Faire exécuter le nettoyage du stockage (réservée à l'hôte)", en: "Run the storage cleanup (host only)" } }
) END;

IF !record::exists(auth_permission:⟨secrets.maintenance.run⟩) THEN (
    CREATE auth_permission:⟨secrets.maintenance.run⟩ CONTENT { code: "secrets.maintenance.run", module: "lyxal_server", scope: "installation", description: { fr: "Faire exécuter la maintenance du coffre-fort (réservée à l'hôte)", en: "Run the vault maintenance (host only)" } }
) END;

-- ----------------------------------------------------------------------------
-- Tâches
-- ----------------------------------------------------------------------------

IF !record::exists(scheduler_task:⟨auth.purge⟩) THEN (
    CREATE scheduler_task:⟨auth.purge⟩ CONTENT {
        module: "lyxal_auth",
        executor: "handler",
        target: "auth.purge",
        permission: "auth.purge.run",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 7,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 5m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Purge de lyxal_auth : sessions, parcours, codes, jetons, compteurs d'échecs et invitations expirés", en: "lyxal_auth purge: expired sessions, flows, codes, tokens, failure counters and invitations" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(scheduler_task:⟨storage.cleanup⟩) THEN (
    CREATE scheduler_task:⟨storage.cleanup⟩ CONTENT {
        module: "lyxal_storage",
        executor: "handler",
        target: "storage.cleanup",
        permission: "storage.cleanup.run",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 7,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 30m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Nettoyage du stockage : écritures abandonnées, envois reprenables à assembler, fichiers supprimés, octets des buckets supprimés", en: "Storage cleanup: abandoned writes, resumable uploads to assemble, deleted files, bytes of deleted buckets" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(scheduler_task:⟨secrets.maintenance⟩) THEN (
    CREATE scheduler_task:⟨secrets.maintenance⟩ CONTENT {
        module: "lyxal_secrets",
        executor: "handler",
        target: "secrets.maintenance",
        permission: "secrets.maintenance.run",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 7,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 15m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Maintenance du coffre-fort : purge à échéance, alertes, rotations, rescellement, accès et partages échus", en: "Vault maintenance: due purge, alerts, rotations, resealing, expired grants and shares" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
