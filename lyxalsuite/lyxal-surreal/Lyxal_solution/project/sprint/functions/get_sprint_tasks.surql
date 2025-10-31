-- Fonction pour obtenir les tâches d'un sprint
DEFINE FUNCTION fn::get_sprint_tasks($sprint_id: record<sprint>) {
    RETURN SELECT * FROM project_task WHERE id IN (
        SELECT task_list FROM sprint WHERE id = $sprint_id
    );
};