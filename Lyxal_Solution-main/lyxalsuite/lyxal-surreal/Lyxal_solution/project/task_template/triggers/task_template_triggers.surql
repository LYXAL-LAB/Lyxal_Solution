-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT task_template_updated ON TABLE task_template WHEN $event = "UPDATE" THEN {
    UPDATE task_template SET updated_on = time::now() WHERE id = $after.id;
};