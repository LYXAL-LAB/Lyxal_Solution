-- ============================================================================
-- SEEDS : files d'exécution du planificateur
-- MODULE : lyxal_scheduler
-- ============================================================================
-- Rejouable et non destructif : chaque file est créée seulement si elle n'existe pas (une
-- concurrence réglée par l'exploitant est conservée). Tous les champs sont donnés : une
-- installation en mode import n'applique pas les valeurs par défaut du schéma.

IF !record::exists(scheduler_queue:default) THEN (
    CREATE scheduler_queue:default CONTENT { concurrency: 10, running: 0, paused: false, updated_at: time::now(), description: { fr: "File par défaut des tâches des modules", en: "Default queue for module tasks" } }
) END;

IF !record::exists(scheduler_queue:maintenance) THEN (
    CREATE scheduler_queue:maintenance CONTENT { concurrency: 2, running: 0, paused: false, updated_at: time::now(), description: { fr: "Tâches d'entretien (purges, recalculs), à faible concurrence", en: "Maintenance tasks (purges, recomputations), low concurrency" } }
) END;
