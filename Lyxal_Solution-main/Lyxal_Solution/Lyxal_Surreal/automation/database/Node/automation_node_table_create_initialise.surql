--
-- @name automation_node_table_create_initialise
-- @description Initialise la table `automation_node` pour stocker les nodes.
-- (ex: Google).
-- @related
--   - function:fn::automation_deploy_initialise
--
DEFINE FUNCTION fn::automation_node_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Création du log de début
    fn::system_log_create_record_system(['automation_node_table_create_initialise', 'start'],
    'Initialisation de la table `automation_node`.',
    { log_extra_tags: $log_extra_tags, run_id: $run_id, parent_run_id: $parent_run_id });

    --
    -- Initialise la table `automation_node`.
    -- Cette table stocke les organisations parentes des services (ex: Google, Facebook, etc.).
    --
    DEFINE TABLE IF NOT EXISTS automation_node SCHEMAFULL TYPE NORMAL
        COMMENT 'Stocke les organisations (ex: Google) qui fournissent des services nécessitant
         des credentials.'
         PERMISSIONS FULL;

    -- == Champs principaux
    DEFINE FIELD IF NOT EXISTS key ON TABLE automation_node 
        TYPE option<string>
        ASSERT $value = NONE OR string::len($value) > 0 AND string::len($value) <= 128
        COMMENT 'Identifiant interne technique (ex: github).';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node 
        TYPE string
        ASSERT string::len($value) > 0 AND string::len($value) <= 128
        COMMENT 'Nom unique de l\'organisation (ex: \'Google\').';

    DEFINE FIELD IF NOT EXISTS icon ON TABLE automation_node 
        TYPE option<record<storage_file>>
        VALUE type::thing('storage_file', $value)
        COMMENT 'URL ou nom de l\'icône pour l\'affichage.';

    DEFINE FIELD IF NOT EXISTS icon_dark ON TABLE automation_node 
        TYPE option<record<storage_file>>
        VALUE type::thing('storage_file', $value)
        COMMENT 'Icône thème sombre.';

    DEFINE FIELD IF NOT EXISTS website_url ON TABLE automation_node 
        TYPE option<string>
        COMMENT 'URL du site web principal de l\'organisation.';

    DEFINE FIELD IF NOT EXISTS display_name ON TABLE automation_node
        TYPE option<string>
        COMMENT 'Label d\'affichage (displayName).';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node
        TYPE option<string>
        COMMENT 'Description textuelle du node.';

    DEFINE FIELD IF NOT EXISTS provider ON TABLE automation_node
        TYPE option<record<integrations_provider>>
        REFERENCE ON DELETE REJECT
        VALUE IF $value == NONE THEN NONE ELSE type::thing('integrations_provider', $value) END
        COMMENT 'Provider/organisation associé au node (ex: Bunny).';

    DEFINE FIELD IF NOT EXISTS subtitle_template ON TABLE automation_node
        TYPE option<string>
        COMMENT 'Template de sous-titre (expression).';

    DEFINE FIELD IF NOT EXISTS usable_as_tool ON TABLE automation_node
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si utilisable comme outil.';

    DEFINE FIELD IF NOT EXISTS routing_json ON TABLE automation_node
        TYPE option<object>
        COMMENT 'Définition routing (déclaratif) brute.';

    -- == Timestamps
    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node 
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date et heure de création de l\'enregistrement.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node 
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date et heure de la dernière mise à jour de l\'enregistrement.';

    -- == Index
    -- Assure que le nom d'une organisation est unique.
    DEFINE INDEX IF NOT EXISTS node_name_unique ON TABLE automation_node 
    FIELDS name UNIQUE
    COMMENT 'Index sur le nom d\'une organisation.';

    DEFINE INDEX IF NOT EXISTS node_key_unique ON TABLE automation_node
    FIELDS key UNIQUE
    COMMENT 'Index sur la clé technique du node.';

    -- Création du log de succès
    fn::system_log_create_record_system(['automation_node_table_create_initialise', 'success'],
    'Table `automation_node` initialisée avec succès.',
    { log_extra_tags: $log_extra_tags, run_id: $run_id, parent_run_id: $parent_run_id });

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
