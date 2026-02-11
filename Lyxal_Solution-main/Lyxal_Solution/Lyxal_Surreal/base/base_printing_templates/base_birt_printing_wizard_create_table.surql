DEFINE FUNCTION IF NOT EXISTS fn::base_birt_printing_wizard_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_birt_printing_wizard', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_birt_printing_wizard TYPE NORMAL SCHEMAFULL
  COMMENT 'BirtPrintingWizard (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD metaModel ON base_birt_printing_wizard TYPE record<base_meta_model>;
  DEFINE FIELD metaModelTargetName ON base_birt_printing_wizard TYPE option<string>;
  DEFINE FIELD recordTitle ON base_birt_printing_wizard TYPE option<string>;
  DEFINE FIELD recordValue ON base_birt_printing_wizard TYPE option<string>;
  DEFINE FIELD name ON base_birt_printing_wizard TYPE option<string>;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_printing_templates' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_printing_templates introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_birt_printing_wizard', $sm.id, 'BIRT Printing Wizard', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_birt_printing_wizard_create_table_initialise', $sm.id, 'Crée la table base_birt_printing_wizard (Axelor)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_birt_printing_wizard', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_birt_printing_wizard'
PERMISSIONS FULL;

