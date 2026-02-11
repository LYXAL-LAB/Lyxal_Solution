-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT wiki_updated ON TABLE wiki WHEN $event = "UPDATE" THEN {
    UPDATE wiki SET updated_on = time::now() WHERE id = $after.id;
};