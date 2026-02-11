-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT project_task_updated ON TABLE project_task WHEN $event = "UPDATE" THEN {
    UPDATE project_task SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour incrémenter la séquence des tâches
DEFINE EVENT increment_task_sequence ON TABLE project_task WHEN $event = "CREATE" THEN {
    IF $after.project_id IS NOT NONE THEN {
        UPDATE project SET next_project_task_sequence = next_project_task_sequence + 1 
        WHERE id = $after.project_id;
    };
};

-- Trigger pour gérer l'auto-numérotation des tâches
DEFINE EVENT task_auto_numbering ON TABLE project_task WHEN $event = "CREATE" THEN {
    LET $company_config = (SELECT * FROM company_project_extension WHERE company_id = (
        SELECT company_id FROM project WHERE id = $after.project_id
    ));
    IF $company_config.task_numbering_auto AND ($after.task_id IS NONE OR $after.task_id = "") THEN {
        LET $sequence = (SELECT * FROM sequence_project WHERE code = "TASK" AND company_id = (
            SELECT company_id FROM project WHERE id = $after.project_id
        ));
        IF $sequence IS NOT NONE THEN {
            UPDATE project_task SET task_id = fn::generate_project_sequence($sequence.id) WHERE id = $after.id;
        };
    };
};