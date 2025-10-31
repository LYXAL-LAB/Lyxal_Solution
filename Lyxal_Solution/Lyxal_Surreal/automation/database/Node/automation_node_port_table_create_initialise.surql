-- =============================================================================================
-- |
-- | Fichier : automation_node_port_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_port` (ports d'entrées/sorties).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_port_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_port',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_port SCHEMAFULL TYPE NORMAL
        COMMENT 'Ports de connexion d\'un node (inputs/outputs, ex: Main, branches).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS node ON TABLE automation_node_port
        TYPE record<automation_node>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node', $value)
        COMMENT 'Référence au node.';

    DEFINE FIELD IF NOT EXISTS direction ON TABLE automation_node_port
        TYPE string
        ASSERT $value IN ['in','out']
        COMMENT 'Sens du port (in/out).';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node_port
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Nom du port (ex: Main).';

    DEFINE FIELD IF NOT EXISTS index ON TABLE automation_node_port
        TYPE int
        VALUE $value OR 0
        COMMENT 'Index du port (pour ordonner plusieurs sorties).';

    DEFINE FIELD IF NOT EXISTS type ON TABLE automation_node_port
        TYPE option<string>
        COMMENT 'Typage éventuel du port.';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_port
        TYPE option<string>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_port 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_port 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_node_port ON TABLE automation_node_port
        FIELDS node, direction, name, index UNIQUE
        COMMENT 'Unicité d\'un port par node + direction + nom + index.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_port',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table des ports des nodes.'
PERMISSIONS FULL;


