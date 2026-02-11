-- Triggers for lyxalproduction

-- Met à jour automatiquement le statut d’un OperationOrder si sa durée dépasse un seuil
DEFINE EVENT operation_status_check ON TABLE operation_order
WHEN $after.duration > time::duration("1h") THEN {
UPDATE $this SET status = "completed";
};

-- Met à jour automatiquement le statut d’un ProductionOrder si toutes les opérations sont terminées
DEFINE EVENT production_status_update ON TABLE production_order
WHEN (SELECT count() FROM operation_order WHERE manufOrder.productionOrder = $this.id AND status != "completed") = 0 THEN {
UPDATE $this SET status = "done";
};

-- Clôture automatique d’un ManufOrder une fois la ProductionOrder liée terminée
DEFINE EVENT close_manuf_order ON TABLE manuf_order
WHEN $after.productionOrder.status = "done" THEN {
UPDATE $this SET toInvoice = true;
};

-- Génère un log d’audit à chaque création de TimesheetLine
DEFINE EVENT audit_timesheet_line ON TABLE timesheet_line
WHEN $before = NONE THEN {
LET $log = {
event: "timesheet_created",
user: $auth.id,
workspace: $auth.workspace,
payload: $after,
timestamp: time::now()
};
CREATE production_audit_log CONTENT $log;
};
