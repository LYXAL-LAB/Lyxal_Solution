
-- Vues préférées utilisateur
LET $PREFERRED_TASK_VIEW_LIST = "list";
LET $PREFERRED_TASK_VIEW_KANBAN = "kanban";
LET $PREFERRED_TASK_VIEW_GANTT = "gantt";
LET $PREFERRED_TASK_VIEW_CALENDAR = "calendar";

-- Statuts de traitement par lot
LET $BATCH_STATUS_READY = 0;
LET $BATCH_STATUS_RUNNING = 1;
LET $BATCH_STATUS_SUCCESS = 2;
LET $BATCH_STATUS_ANOMALY = 3;
LET $BATCH_STATUS_TERMINATED = 4;

-- ======================================================================
-- VUES COMPLEXES
-- ======================================================================

-- Vue pour les wikis avec hiérarchie
DEFINE TABLE wiki_hierarchy AS SELECT 
    w.*,
    wf.name as folder_name,
    p.name as project_name,
    pt.name as template_name,
    fn::get_wiki_folder_hierarchy(w.folder_id) as folder_hierarchy
FROM wiki w
LEFT JOIN wiki_folder wf ON wf.id = w.folder_id
LEFT JOIN project p ON p.id = w.project_id
LEFT JOIN project_template pt ON pt.id = w.project_template_id;

-- Vue pour les dossiers wiki avec compteurs
DEFINE TABLE wiki_folder_dashboard AS SELECT 
    wf.*,
    array::length(wf.wiki_list) as wiki_count,
    array::length(wf.wiki_folder_list) as subfolder_count,
    pwf.name as parent_folder_name
FROM wiki_folder wf
LEFT JOIN wiki_folder pwf ON pwf.id = wf.parent_folder_id;

-- Vue pour les utilisateurs avec préférences projet
DEFINE TABLE user_project_dashboard AS SELECT 
    u.*,
    upe.preferred_task_view,
    upe.show_completed_tasks,
    dp.name as default_project_name
FROM user u
LEFT JOIN user_project_extension upe ON upe.user_id = u.id
LEFT JOIN project dp ON dp.id = upe.default_project_id;

-- Vue pour les entreprises avec configuration projet
DEFINE TABLE company_project_dashboard AS SELECT 
    c.*,
    cpe.project_numbering_auto,
    cpe.task_numbering_auto,
    dps.name as default_project_status,
    dts.name as default_task_status,
    dp.name as default_priority
FROM company c
LEFT JOIN company_project_extension cpe ON cpe.company_id = c.id
LEFT JOIN project_status dps ON dps.id = cpe.default_project_status_id
LEFT JOIN task_status dts ON dts.id = cpe.default_task_status_id
LEFT JOIN project_priority dp ON dp.id = cpe.default_priority_id;
