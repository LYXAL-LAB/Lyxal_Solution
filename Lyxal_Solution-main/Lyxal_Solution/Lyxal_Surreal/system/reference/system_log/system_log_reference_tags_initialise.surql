-- Initialisation de la fonction system_log_reference_tags
DEFINE FUNCTION IF NOT EXISTS fn::system_log_reference_tags_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres par défaut
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début de l'initialisation de la fonction system_log_reference_tags_initialise
  LET $start_tags = ['log_initialisation', 'log_function', 'log_create', 'log_start', 
  'log_initialise'];
  LET $log_msg = "Start: initialisation de la fonction system_log_reference_tags_initialise";
  LET $log_det = { run_id: $run_id, parent_run_id: $parent_run_id };
  fn::system_log_create_record_system(array::union($start_tags, $log_extra_tags), 
  $log_msg, $log_det);

DEFINE FUNCTION IF NOT EXISTS fn::system_log_reference_tags(
  $parent_run_id: option<string>
) {

  -- Paramètres par défaut
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début de la fonction system_log_reference_tags
  LET $start_tags = ['log_data_reference', 'log_tag', 'log_create', 'log_start', 
  'log_initialise'];
  LET $log_msg = "Start: création des tags de référence system_log";
  LET $log_det = { run_id: $run_id, parent_run_id: $parent_run_id, 
  sub: 'tag_reference system_log' };
  fn::system_log_create_record_system(array::union($start_tags, $log_extra_tags), 
  $log_msg, $log_det);

  -- Tags de référence phases
  CREATE system_tag:log_audit SET name = 'log_audit', label = 'log audit', 
  description = 'Fait référence à toutes les fonctions liées à l\'audit', 
  color = '#9B59B6', order = 100, is_protected = true;
  CREATE system_tag:log_deploy SET name = 'log_deploy', label = 'log deploy', 
  description = 'Fait référence à toutes les fonctions liées au déploiement', 
  color = '#3498DB', order = 110, is_protected = true;
  CREATE system_tag:log_initialisation SET name = 'log_initialisation', 
  label = 'log initialisation', description = 'Fait référence à toutes les fonctions 
  liées à l\'initialisation', color = '#1ABC9C', order = 120, is_protected = true;
  CREATE system_tag:log_migration SET name = 'log_migration', label = 'log migration', 
  description = 'Fait référence à toutes les fonctions liées aux migrations', 
  color = '#F1C40F', order = 130, is_protected = true;
  CREATE system_tag:log_data_reference SET name = 'log_data_reference', 
  label = 'log data reference', description = 'données système livrées par le code 
  (seeds, énumérations, fixtures)', color = '#E67E22', order = 140, is_protected = true;
  CREATE system_tag:log_data SET name = 'log_data', 
  label = 'log data', description = 'Fait référence à la création des données des utilisateurs, 
  saisies,création, modification, suppression (UI, imports, synchros, etc.)',
   color = '#bdc3c7', order = 150, is_protected = true;


  -- Tags de référence types
  CREATE system_tag:log_saas SET name = 'log_saas', label = 'log saas', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 500, 
  is_protected = true;
  CREATE system_tag:log_pre_requis SET name = 'log_pre_requis', label = 'log pre requis', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 510, 
  is_protected = true;
  CREATE system_tag:log_module SET name = 'log_module', label = 'log module', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 520, 
  is_protected = true;
  CREATE system_tag:log_component SET name = 'log_component', label = 'log component', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 530, 
  is_protected = true;
  CREATE system_tag:log_table SET name = 'log_table', label = 'log table', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 540, 
  is_protected = true;
  CREATE system_tag:log_function SET name = 'log_function', label = 'log function', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 550, 
  is_protected = true;
  CREATE system_tag:log_analyzer SET name = 'log_analyzer', label = 'log analyzer', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 560, 
  is_protected = true;
  CREATE system_tag:log_event SET name = 'log_event', label = 'log event', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 570, 
  is_protected = true;
  CREATE system_tag:log_sequence SET name = 'log_sequence', label = 'log sequence', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 580, 
  is_protected = true;
  CREATE system_tag:log_bucket SET name = 'log_bucket', label = 'log bucket', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 590, 
  is_protected = true;
  CREATE system_tag:log_param SET name = 'log_param', label = 'log param', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 600, 
  is_protected = true;
  CREATE system_tag:log_config SET name = 'log_config', label = 'log config', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 610, 
  is_protected = true;
  CREATE system_tag:log_api SET name = 'log_api', label = 'log api', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 620, 
  is_protected = true;
  CREATE system_tag:log_template SET name = 'log_template', label = 'log template', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 630, 
  is_protected = true;
  CREATE system_tag:log_dependency SET name = 'log_dependency', label = 'log dependency', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 640, 
  is_protected = true;
  CREATE system_tag:log_tag SET name = 'log_tag', label = 'log tag', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 650, 
  is_protected = true;
  CREATE system_tag:log_system SET name = 'log_system', label = 'log system', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 660, 
  is_protected = true;
  CREATE system_tag:log_builder SET name = 'log_builder', label = 'log builder', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 670, 
  is_protected = true;
  CREATE system_tag:log_record SET name = 'log_record', label = 'log record', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 680, 
  is_protected = true;
  CREATE system_tag:log_relation SET name = 'log_relation', label = 'log relation', 
  description = 'Fait référence à toutes les fonctions liées aux relations entre enregistrements',
   color = '#7F8C8D', order = 690, is_protected = true;
  CREATE system_tag:log_validation SET name = 'log_validation', label = 'log validation', 
  description = 'Fait référence à toutes les fonctions ou opérations de validation de données', 
  color = '#7F8C8D', order = 700, is_protected = true;


  -- Tags de référence actions
  CREATE system_tag:log_create SET name = 'log_create', label = 'log create', 
  description = 'Tag de référence system_log', color = '#2ECC71', order = 400, 
  is_protected = true;
  CREATE system_tag:log_delete SET name = 'log_delete', label = 'log delete', 
  description = 'Tag de référence system_log', color = '#E74C3C', order = 410, 
  is_protected = true;
  CREATE system_tag:log_update SET name = 'log_update', label = 'log update', 
  description = 'Tag de référence system_log', color = '#F39C12', order = 420, 
  is_protected = true;
  CREATE system_tag:log_read SET name = 'log_read', label = 'log read', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 430, 
  is_protected = true;
  CREATE system_tag:log_import SET name = 'log_import', label = 'log import', 
  description = 'Tag de référence system_log', color = '#16A085', order = 440, 
  is_protected = true;
  CREATE system_tag:log_export SET name = 'log_export', label = 'log export', 
  description = 'Tag de référence system_log', color = '#8E44AD', order = 450, 
  is_protected = true;
  CREATE system_tag:log_sync SET name = 'log_sync', label = 'log sync', 
  description = 'Tag de référence system_log', color = '#34495E', order = 460, 
  is_protected = true;

  -- Tags de référence statuts
  CREATE system_tag:log_start SET name = 'log_start', label = 'log start', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 300, 
  is_protected = true;
  CREATE system_tag:log_inprogress SET name = 'log_inprogress', label = 'log inprogress', 
  description = 'Tag de référence system_log', color = '#9B59B6', order = 310, 
  is_protected = true;
  CREATE system_tag:log_done SET name = 'log_done', label = 'log done', 
  description = 'Tag de référence system_log', color = '#27AE60', order = 320,
   is_protected = true;

  -- Tags de référence résultats
  CREATE system_tag:log_initialise SET name = 'log_initialise', label = 'log initialise', 
  description = 'Tag de référence system_log', color = '#BDC3C7', order = 200, 
  is_protected = true;
  CREATE system_tag:log_advanced SET name = 'log_advanced', label = 'log advanced', 
  description = 'Tag de référence system_log', color = '#BDC3C7', order = 210, 
  is_protected = true;
  CREATE system_tag:log_success SET name = 'log_success', label = 'log success', 
  description = 'Tag de référence system_log', color = '#2ECC71', order = 220, 
  is_protected = true;
  CREATE system_tag:log_failure SET name = 'log_failure', label = 'log failure', 
  description = 'Tag de référence system_log', color = '#E74C3C', order = 230, 
  is_protected = true;
  CREATE system_tag:log_error SET name = 'log_error', label = 'log error', 
  description = 'Tag de référence system_log', color = '#C0392B', order = 240, 
  is_protected = true;
  CREATE system_tag:log_warning SET name = 'log_warning', label = 'log warning', 
  description = 'Tag de référence system_log', color = '#F39C12', order = 250, 
  is_protected = true;
  CREATE system_tag:log_info SET name = 'log_info', label = 'log info', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 260, 
  is_protected = true;

  -- Journalisation: fin de la fonction system_log_reference_tags
  LET $end_tags = ['log_data_reference', 'log_tag', 'log_create', 'log_done','log_success'];
  LET $log_msg = "Done: création des tags de référence system_log";
  LET $log_det = { run_id: $run_id, parent_run_id: $parent_run_id, 
  sub: 'tag_reference system_log' };
  fn::system_log_create_record_system(array::union($end_tags, $log_extra_tags), 
  $log_msg, $log_det);

  RETURN { 
    success: true, 
    message: 'Tags de référence system_log insérés (un record par tag)',
    run_id: $run_id };
}
COMMENT 'Crée les tags de référence utilisés par la table system_log 
(phases, types, actions, statuts, résultats)'
PERMISSIONS FULL;


  -- Journalisation: fin de l'initialisation de la fonction system_log_reference_tags_initialise
  LET $done_tags = ['log_initialisation', 'log_function', 'log_create', 'log_done', 
  'log_success'];
  LET $log_msg_done = "Done: initialisation de la fonction system_log_reference_tags_initialise";
  LET $log_det_done = { run_id: $run_id, parent_run_id: $parent_run_id, 
  sub: 'sub_module_system_log' };
  fn::system_log_create_record_system(array::union($done_tags, $log_extra_tags), 
  $log_msg_done, $log_det_done);

  RETURN { 
    success: true, 
    message: 'Initialisation de la fonction system_log_reference_tags_initialise',
    run_id: $run_id };
}

COMMENT 'Initialise la fonction de création des tags de référence system_log'
PERMISSIONS FULL;