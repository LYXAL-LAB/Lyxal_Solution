-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT sprint_updated ON TABLE sprint WHEN $event = "UPDATE" THEN {
    UPDATE sprint SET updated_on = time::now() WHERE id = $after.id;
};