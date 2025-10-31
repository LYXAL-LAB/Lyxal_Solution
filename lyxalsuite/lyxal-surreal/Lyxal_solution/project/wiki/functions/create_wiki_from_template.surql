-- Fonction pour créer un wiki depuis un template
DEFINE FUNCTION fn::create_wiki_from_template($template_wiki_id: record<wiki>, $project_id: record<project>) {
    LET $template = (SELECT * FROM wiki WHERE id = $template_wiki_id);
    LET $new_wiki = (CREATE wiki SET
        title = $template.title,
        content = $template.content,
        sequence = $template.sequence,
        project_id = $project_id
    );
    RETURN $new_wiki;
};