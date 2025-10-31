-- Fonction pour obtenir tous les wikis d'un projet
DEFINE FUNCTION fn::get_project_wikis($project_id: record<project>) {
    RETURN SELECT w.*, wf.name as folder_name
           FROM wiki w
           LEFT JOIN wiki_folder wf ON wf.id = w.folder_id
           WHERE w.project_id = $project_id
           ORDER BY w.sequence;
};