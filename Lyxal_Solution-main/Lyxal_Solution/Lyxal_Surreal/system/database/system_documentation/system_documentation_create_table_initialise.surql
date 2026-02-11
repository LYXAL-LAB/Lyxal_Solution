-- =================================================================================================
-- |
-- | Fichier : system_documentation_create_table_initialise.surql
-- | Module : system
-- | Description : Initialise la table `system_documentation` pour stocker le contenu de la documentation.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::system_documentation_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system'];
    LET $run_id = rand::uuid();

    -- Création du log de début
    fn::system_log_helper_initialise(
        'table', 'start', 'system_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    --
    -- Initialise la table `system_documentation`.
    -- Cette table stocke des blocs de documentation réutilisables.
    --
    DEFINE TABLE IF NOT EXISTS system_documentation SCHEMAFULL
        TYPE NORMAL
        COMMENT 'Stocke des blocs de documentation (description, paramètres, exemples).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS name ON TABLE system_documentation
        TYPE string
        COMMENT 'Nom unique et adressable pour la documentation (ex: automation_node_actionnetwork_description).';

    DEFINE FIELD IF NOT EXISTS type ON TABLE system_documentation 
        TYPE string
        COMMENT 'Catégorie du document (ex: description_generale, details_parametres).';
    
    DEFINE FIELD IF NOT EXISTS format ON TABLE system_documentation
        TYPE string
        COMMENT 'Format du contenu (ex: markdown, json).';

    DEFINE FIELD IF NOT EXISTS content ON TABLE system_documentation
        FLEXIBLE
        TYPE object
        COMMENT 'Contenu flexible de la documentation (texte ou objet JSON structuré).';

    -- Index pour accélérer les recherches par type
    DEFINE INDEX IF NOT EXISTS idx_type ON TABLE system_documentation 
    FIELDS type 
    COMMENT 'Index sur la catégorie du document';

    -- Index pour garantir l'unicité du nom
    DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE system_documentation
    FIELDS name UNIQUE
    COMMENT 'Index unique sur le nom de la documentation';

    -- Création du log de succès
    fn::system_log_helper_initialise(
        'table', 'done', 'system_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la table `system_documentation`."
PERMISSIONS FULL;
