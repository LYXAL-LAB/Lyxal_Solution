-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT wiki_folder_updated ON TABLE wiki_folder WHEN $event = "UPDATE" THEN {
    UPDATE wiki_folder SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour maintenir la hiérarchie des dossiers wiki
DEFINE EVENT wiki_folder_hierarchy_check ON TABLE wiki_folder WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.parent_folder_id IS NOT NONE AND $after.parent_folder_id = $after.id THEN {
        THROW "A folder cannot be its own parent";
    };
};