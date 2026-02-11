-- Fonction pour créer un projet à partir d'un template
DEFINE FUNCTION fn::create_project_from_template($template_id: record<project_template>, $project_name: string) {
    LET $template = (SELECT * FROM project_template WHERE id = $template_id);
    LET $new_project = (CREATE project SET
        name = $project_name,
        full_name = $project_name,
        team_id = $template.team_id,
        assigned_to_id = $template.assigned_to_id,
        company_id = $template.company_id,
        synchronize = $template.synchronize,
        task_status_management_select = $template.task_status_management_select,
        project_task_category_set = $template.project_task_category_set,
        members_user_set = $template.members_user_set,
        product_set = $template.product_set,
        project_task_status_set = $template.project_task_status_set
    );
    RETURN $new_project;
};