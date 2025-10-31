-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT project_template_updated ON TABLE project_template WHEN $event = "UPDATE" THEN {
    UPDATE project_template SET updated_on = time::now() WHERE id = $after.id;
};