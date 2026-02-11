-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_usergroupnode` (ARÊTE)
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_usergroupnode_create_table_initialise() {
    -- Création de la table scheduler_usergroupnode
    fn::system_log_create_record_system(['scheduler_usergroupnode_create_table_initialise', 'start'], 'Initialisation de la table d\'arête `scheduler_usergroupnode`.');

    DEFINE TABLE IF NOT EXISTS scheduler_usergroupnode SCHEMAFULL
        COMMENT 'Table d\'arête (edge) reliant les groupes d\'utilisateurs (usergroup) aux nœuds (node).';

    DEFINE FIELD IF NOT EXISTS enabled ON scheduler_usergroupnode TYPE bool DEFAULT true;

    -- Les champs `in` et `out` sont implicites pour les arêtes mais peuvent être définis pour la clarté.
    -- SurrealDB gère automatiquement les connexions via la syntaxe `RELATE`.
    -- Nous ne définissons pas explicitement `in` et `out` ici, mais la table est conçue pour être utilisée comme une arête
    -- entre `scheduler_usergroup` et `scheduler_node`.
    
    fn::system_log_create_record_system(['scheduler_usergroupnode_create_table_initialise', 'success'], 'Table d\'arête `scheduler_usergroupnode` initialisée avec succès.');

    RETURN true;
};
