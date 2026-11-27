-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- SEED   : tâches de fond déclarées par l'hôte
-- HÔTE   : lyxal_groupware
-- RÔLE   : Maintenance et clés DKIM de lyxal_mail, exécutées par lyxal_scheduler
-- ============================================================================
-- lyxal_scheduler dépend de lyxal_auth et lyxal_mail ne dépend pas du planificateur : l'hôte,
-- qui les héberge tous les deux, déclare la tâche à sa place, en session système, après
-- l'installation des modules (les tables auth_permission et scheduler_task existent, la release
-- de lyxal_mail est installée : garde de scheduler_task). Rejouable : rien n'est recréé ni
-- écrasé.
--
-- Exécuteur `handler` : le code Rust est inscrit par l'hôte sous le nom de la tâche
-- (apps/lyxal-groupware/src/services.rs) et appelle l'opération publique du module
-- (MailMaintenance). Seul un nœud de lyxal-groupware a ce code : la tâche n'est réservée que
-- par lui. Portée `installation`. Tous les champs sont donnés (une installation en mode import
-- n'applique pas les valeurs par défaut du schéma).
--
-- Permission propre de la tâche : attribuée à aucun rôle, elle réserve tout ce qui fait exécuter
-- la tâche (planification, déclenchement, rejeu, relance) à la session système de l'hôte.

IF !record::exists(auth_permission:⟨mail.maintenance.run⟩) THEN (
    CREATE auth_permission:⟨mail.maintenance.run⟩ CONTENT { code: "mail.maintenance.run", module: "lyxal_groupware", scope: "installation", description: { fr: "Faire exécuter la maintenance du courrier (réservée à l'hôte)", en: "Run the mail maintenance (host only)" } }
) END;

IF !record::exists(scheduler_task:⟨mail.maintenance⟩) THEN (
    CREATE scheduler_task:⟨mail.maintenance⟩ CONTENT {
        module: "lyxal_mail",
        executor: "handler",
        target: "mail.maintenance",
        permission: "mail.maintenance.run",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 7,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 30m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Maintenance du courrier : contenus abandonnés et libérés retirés avec leurs fichiers, effacements échus, comptes supprimés purgés, file d'envoi purgée", en: "Mail maintenance: abandoned and released contents removed with their files, expired deletions, deleted accounts purged, outbound queue purged" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- Clés DKIM des domaines de courrier (lot 6, plan §9.3) : création (RSA 2 048 bits et Ed25519,
-- secret rangé dans lyxal_secrets, fiche publique pending), puis activation quand le DNS montre
-- l'enregistrement publié. Toutes les 10 minutes ; handler de l'hôte (DkimProvisioner).
IF !record::exists(auth_permission:⟨mail.dkim_provision.run⟩) THEN (
    CREATE auth_permission:⟨mail.dkim_provision.run⟩ CONTENT { code: "mail.dkim_provision.run", module: "lyxal_groupware", scope: "installation", description: { fr: "Faire exécuter la création et l'activation des clés DKIM (réservée à l'hôte)", en: "Run the DKIM key provisioning (host only)" } }
) END;

IF !record::exists(scheduler_task:⟨mail.dkim_provision⟩) THEN (
    CREATE scheduler_task:⟨mail.dkim_provision⟩ CONTENT {
        module: "lyxal_mail",
        executor: "handler",
        target: "mail.dkim_provision",
        permission: "mail.dkim_provision.run",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 6,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 10m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Clés DKIM des domaines de courrier : création, rangement dans le coffre-fort, activation quand l'enregistrement DNS est publié", en: "DKIM keys of mail domains: creation, storage in the vault, activation once the DNS record is published" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
