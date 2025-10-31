DEFINE FUNCTION IF NOT EXISTS fn::base_meta_group_menu_assistant_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_meta_group_menu_assistant', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_meta_group_menu_assistant TYPE NORMAL SCHEMAFULL
COMMENT 'Assistant d\'import de menus/groupes/roles (meta)'
PERMISSIONS FULL;

DEFINE FIELD groupSet ON base_meta_group_menu_assistant TYPE array<record<base_user_group>>;
DEFINE FIELD roleSet ON base_meta_group_menu_assistant TYPE array<record<base_user_role>>;
DEFINE FIELD menuSet ON base_meta_group_menu_assistant TYPE array<record<base_meta_menu>>;
DEFINE FIELD metaFile ON base_meta_group_menu_assistant TYPE option<record<base_meta_file>>;
DEFINE FIELD importDate ON base_meta_group_menu_assistant TYPE option<datetime>;
DEFINE FIELD language ON base_meta_group_menu_assistant TYPE option<string>;
DEFINE FIELD log ON base_meta_group_menu_assistant TYPE option<string>;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_meta_group_menu_assistant', $sm.id, 'Assistant d\'import de menus/groupes/roles (meta)', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_meta_group_menu_assistant_create_table_initialise', $sm.id, 'Crée la table base_meta_group_menu_assistant', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_meta_group_menu_assistant', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_meta_group_menu_assistant'
PERMISSIONS FULL;


