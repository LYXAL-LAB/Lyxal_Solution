-- Fonction pour obtenir la hiérarchie des dossiers wiki
DEFINE FUNCTION fn::get_wiki_folder_hierarchy($folder_id: record<wiki_folder>) {
    LET $folder = (SELECT * FROM wiki_folder WHERE id = $folder_id);
    LET $parent_hierarchy = IF $folder.parent_folder_id IS NOT NONE THEN
        fn::get_wiki_folder_hierarchy($folder.parent_folder_id)
    ELSE
        []
    END;
    RETURN array::append($parent_hierarchy, $folder);
};