-- ============================================================================
-- SEEDS : permissions lyxal_auth du planificateur
-- MODULE : lyxal_scheduler
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent
-- pas. organization_admin reçoit les permissions d'organisation ; platform_admin reçoit
-- scheduler.installation.manage ; scheduler.worker n'est attribuée à aucun rôle (compte de
-- service du moteur).

IF !record::exists(auth_permission:⟨scheduler.schedule.read⟩) THEN (
    CREATE auth_permission:⟨scheduler.schedule.read⟩ CONTENT { code: "scheduler.schedule.read", module: "lyxal_scheduler", scope: "organization", description: { fr: "Lire les tâches, files, calendriers, planifications, exécutions et le journal du planificateur de son organisation", en: "Read one's organization scheduler tasks, queues, calendars, schedules, runs and journal" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.schedule.write⟩) THEN (
    CREATE auth_permission:⟨scheduler.schedule.write⟩ CONTENT { code: "scheduler.schedule.write", module: "lyxal_scheduler", scope: "organization", description: { fr: "Créer, modifier, mettre en pause, reprendre et supprimer des planifications ; déclencher, rejouer une période, différer une exécution (avec la permission propre de la tâche)", en: "Create, edit, pause, resume and delete schedules; trigger, backfill, enqueue a run (with the task's own permission)" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.run.manage⟩) THEN (
    CREATE auth_permission:⟨scheduler.run.manage⟩ CONTENT { code: "scheduler.run.manage", module: "lyxal_scheduler", scope: "organization", description: { fr: "Annuler une exécution et relancer une exécution terminée en échec ou annulée", en: "Cancel a run and retry a dead or cancelled run" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.calendar.write⟩) THEN (
    CREATE auth_permission:⟨scheduler.calendar.write⟩ CONTENT { code: "scheduler.calendar.write", module: "lyxal_scheduler", scope: "organization", description: { fr: "Créer, modifier et supprimer les calendriers d'exceptions de son organisation", en: "Create, edit and delete one's organization exception calendars" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.settings.manage⟩) THEN (
    CREATE auth_permission:⟨scheduler.settings.manage⟩ CONTENT { code: "scheduler.settings.manage", module: "lyxal_scheduler", scope: "organization", description: { fr: "Régler le planificateur de son organisation", en: "Configure one's organization scheduler" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.installation.manage⟩) THEN (
    CREATE auth_permission:⟨scheduler.installation.manage⟩ CONTENT { code: "scheduler.installation.manage", module: "lyxal_scheduler", scope: "installation", description: { fr: "Gérer les planifications, calendriers et réglages de l'installation ; mettre les files en pause", en: "Manage installation schedules, calendars and settings; pause queues" } }
) END;

IF !record::exists(auth_permission:⟨scheduler.worker⟩) THEN (
    CREATE auth_permission:⟨scheduler.worker⟩ CONTENT { code: "scheduler.worker", module: "lyxal_scheduler", scope: "installation", description: { fr: "Compte de service du moteur du planificateur : échéances, réservation, fin des exécutions, reprise, élagage", en: "Scheduler engine service account: due times, claiming, run completion, rescue, pruning" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.schedule.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.schedule.read⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.schedule.write⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.schedule.write⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.run.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.run.manage⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.calendar.write⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.calendar.write⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.settings.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.settings.manage⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨scheduler.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨scheduler.installation.manage⟩
) END;
