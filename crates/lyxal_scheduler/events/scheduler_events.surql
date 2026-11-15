-- ============================================================================
-- EVENTS : lyxal_scheduler
-- MODULE : lyxal_scheduler
-- RÔLE   : Gardes des écritures, journal des actions, publication des événements scheduler.*
-- ============================================================================
-- Exécutés dans la transaction de la mutation : une garde qui refuse, un journal qui ne peut
-- pas être écrit ou une publication refusée font échouer la mutation (.agents/AGENTS.md §5.6.1).
-- Les gardes valent aussi pour une écriture directe dans les tables. Jamais d'arguments au
-- journal ni sur le bus. Un enregistrement emporté par la suppression de son organisation n'est
-- ni journalisé ni publié (le journal part avec elle).

-- ----------------------------------------------------------------------------
-- Réglages : journal
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_settings_journal ON TABLE scheduler_settings
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    fn::scheduler_audit_write({
        tenant: $after.tenant,
        action: "settings.update",
        details: object::from_entries(array::map(["catchup_window", "run_retention", "keep_last_runs", "tenant_concurrency", "max_schedules", "max_pending_runs", "max_args_bytes"], |$f| [$f, $after[$f] ?? NULL]))
    });
};

-- ----------------------------------------------------------------------------
-- Tâches : gardes et journal
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_task_create_guard ON TABLE scheduler_task
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::scheduler_task_create_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_task_update_guard ON TABLE scheduler_task
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::scheduler_task_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_task_delete_guard ON TABLE scheduler_task
WHEN $event = "DELETE"
THEN {
    IF !fn::auth_session_valid({}).system { THROW "SCHEDULER_PERMISSION_DENIED"; };
};

DEFINE EVENT OVERWRITE scheduler_task_journal ON TABLE scheduler_task
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    fn::scheduler_audit_write({
        action: IF $after.state = "disabled" { "task.disable" } ELSE { "task.enable" },
        details: { task: record::id($after.id) }
    });
};

-- ----------------------------------------------------------------------------
-- Files : garde, journal et bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_queue_update_guard ON TABLE scheduler_queue
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::scheduler_queue_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_queue_journal ON TABLE scheduler_queue
WHEN $event = "UPDATE" AND $before.paused != $after.paused
THEN {
    fn::scheduler_audit_write({
        action: IF $after.paused { "queue.pause" } ELSE { "queue.resume" },
        details: { queue: record::id($after.id), reason: $after.paused_reason ?? NULL }
    });
    fn::scheduler_publish(IF $after.paused { "scheduler.queue.paused" } ELSE { "scheduler.queue.resumed" }, $after.id, {
        queue: record::id($after.id),
        reason: $after.paused_reason
    });
};

-- ----------------------------------------------------------------------------
-- Calendriers : gardes et journal
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_calendar_write_guard ON TABLE scheduler_calendar
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::scheduler_calendar_write_refusal(IF $event = "CREATE" { NONE } ELSE { $before }, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_calendar_delete_guard ON TABLE scheduler_calendar
WHEN $event = "DELETE"
THEN {
    LET $refusal = fn::scheduler_calendar_delete_refusal($before);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_calendar_journal ON TABLE scheduler_calendar
WHEN $event IN ["CREATE", "UPDATE"] OR ($event = "DELETE" AND ($before.tenant IS NONE OR record::exists($before.tenant)))
THEN {
    LET $doc = IF $event = "DELETE" { $before } ELSE { $after };
    fn::scheduler_audit_write({
        tenant: $doc.tenant,
        action: { CREATE: "calendar.create", UPDATE: "calendar.update", DELETE: "calendar.delete" }[$event],
        details: { calendar: <string> $doc.id, name: $doc.name }
    });
};

-- ----------------------------------------------------------------------------
-- Planifications : gardes
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_schedule_create_guard ON TABLE scheduler_schedule
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::scheduler_schedule_create_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_schedule_update_guard ON TABLE scheduler_schedule
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::scheduler_schedule_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

-- ----------------------------------------------------------------------------
-- Planifications : journal et bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_schedule_lifecycle ON TABLE scheduler_schedule
WHEN $event = "CREATE" OR ($event = "DELETE" AND ($before.tenant IS NONE OR record::exists($before.tenant)))
THEN {
    LET $doc = IF $event = "DELETE" { $before } ELSE { $after };
    fn::scheduler_audit_write({
        tenant: $doc.tenant,
        action: IF $event = "CREATE" { "schedule.create" } ELSE { "schedule.delete" },
        schedule: $doc.id,
        details: { name: $doc.name, task: record::id($doc.task) }
    });
    fn::scheduler_publish(IF $event = "CREATE" { "scheduler.schedule.created" } ELSE { "scheduler.schedule.deleted" }, $doc.id, fn::scheduler_schedule_payload($doc, {}));
};

DEFINE EVENT OVERWRITE scheduler_schedule_changes ON TABLE scheduler_schedule
WHEN $event = "UPDATE"
THEN {
    -- Modification par une personne (le moteur ne change que l'échéance, la dernière exécution et les exécutions restantes)
    LET $fields = array::filter(["args", "spec", "calendars", "overlap", "catchup", "catchup_window", "pause_on_failure", "remaining"],
        |$f| $before[$f] != $after[$f] AND ($f != "remaining" OR $before.last_fire_at = $after.last_fire_at));
    IF array::len($fields) > 0 {
        fn::scheduler_audit_write({ tenant: $after.tenant, action: "schedule.update", schedule: $after.id, details: { fields: $fields } });
        fn::scheduler_publish("scheduler.schedule.updated", $after.id, fn::scheduler_schedule_payload($after, { fields: $fields }));
    };
    IF $before.paused != $after.paused {
        fn::scheduler_audit_write({
            tenant: $after.tenant,
            action: IF $after.paused { "schedule.pause" } ELSE { "schedule.resume" },
            schedule: $after.id,
            details: { reason: $after.paused_reason ?? NULL }
        });
        fn::scheduler_publish(IF $after.paused { "scheduler.schedule.paused" } ELSE { "scheduler.schedule.resumed" }, $after.id,
            fn::scheduler_schedule_payload($after, { reason: $after.paused_reason }));
    };
    IF $before.state != $after.state AND $after.state IN ["completed", "invalid"] {
        fn::scheduler_publish("scheduler.schedule." + $after.state, $after.id, fn::scheduler_schedule_payload($after, { reason: $after.invalid_reason }));
    };
};

-- ----------------------------------------------------------------------------
-- Rejeux : garde et journal
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_backfill_guard ON TABLE scheduler_backfill
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::scheduler_backfill_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_backfill_journal ON TABLE scheduler_backfill
WHEN $event = "CREATE"
THEN {
    fn::scheduler_audit_write({
        tenant: $after.tenant,
        action: "schedule.backfill",
        schedule: $after.schedule,
        details: { backfill: <string> $after.id, from: $after.from, to: $after.to, overlap: $after.overlap ?? NULL }
    });
};

-- ----------------------------------------------------------------------------
-- Exécutions : gardes
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_run_create_guard ON TABLE scheduler_run
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::scheduler_run_create_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_run_update_guard ON TABLE scheduler_run
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::scheduler_run_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE scheduler_run_delete_guard ON TABLE scheduler_run
WHEN $event = "DELETE"
THEN {
    LET $refusal = fn::scheduler_run_delete_refusal($before);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

-- ----------------------------------------------------------------------------
-- Exécutions : journal des actions des personnes
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_run_journal ON TABLE scheduler_run
WHEN ($event = "CREATE" AND $after.origin IN ["trigger", "enqueue", "retry"])
    OR ($event = "UPDATE" AND $before.state != "running" AND $before.state != $after.state AND $after.state = "cancelled")
    OR ($event = "UPDATE" AND !$before.cancel_requested AND $after.cancel_requested)
THEN {
    fn::scheduler_audit_write({
        tenant: $after.tenant,
        action: IF $event = "CREATE" { "run." + $after.origin } ELSE { "run.cancel" },
        schedule: $after.schedule,
        run: $after.id,
        details: IF $event = "CREATE" { { task: record::id($after.task), scheduled_for: $after.scheduled_for } }
            ELSE { { state: $before.state, reason: $after.cancel_reason ?? NULL } }
    });
};

-- ----------------------------------------------------------------------------
-- Exécutions : bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE scheduler_run_bus ON TABLE scheduler_run
WHEN ($event = "CREATE" AND $after.state = "skipped")
    OR ($event = "UPDATE" AND $before.state != $after.state AND $after.state IN ["completed", "retrying", "dead", "cancelled"])
THEN {
    LET $type = IF $after.state = "retrying" { "scheduler.run.failed" } ELSE { "scheduler.run." + $after.state };
    fn::scheduler_publish($type, $after.id, fn::scheduler_run_payload($after));
};
