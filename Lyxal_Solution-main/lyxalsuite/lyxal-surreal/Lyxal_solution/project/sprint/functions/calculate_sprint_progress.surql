-- Fonction pour calculer le pourcentage d'avancement d'un sprint
DEFINE FUNCTION fn::calculate_sprint_progress($sprint_id: record<sprint>) {
    LET $tasks = fn::get_sprint_tasks($sprint_id);
    LET $total_tasks = array::length($tasks);
    LET $completed_tasks = array::length(array::filter($tasks, |$task| $task.progress >= 100));
    RETURN IF $total_tasks > 0 THEN ($completed_tasks / $total_tasks) * 100 ELSE 0 END;
};