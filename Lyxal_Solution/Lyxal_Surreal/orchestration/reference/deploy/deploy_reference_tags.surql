DEFINE FUNCTION IF NOT EXISTS fn::deploy_reference_tags(
  $parent_run_id: option<string>
) {

  -- Paramètres par défaut
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_deploy'];
  LET $run_id = rand::uuid();


  -- Tags de référence phases
  CREATE system_tag:deploy_audit SET name = 'deploy_audit', label = 'log audit', 
  description = 'Fait référence à toutes les fonctions liées à l\'audit', 
  color = '#9B59B6', order = 100, is_protected = true;
  CREATE system_tag:deploy_deploy SET name = 'deploy_deploy', label = 'log deploy', 
  description = 'Fait référence à toutes les fonctions liées au déploiement', 
  color = '#3498DB', order = 110, is_protected = true;
  CREATE system_tag:deploy_migration SET name = 'deploy_migration', label = 'log migration', 
  description = 'Fait référence à toutes les fonctions liées aux migrations', 
  color = '#F1C40F', order = 130, is_protected = true;
  CREATE system_tag:deploy_data_reference SET name = 'deploy_data_reference', 
  label = 'log data reference', description = 'données système livrées par le code 
  (seeds, énumérations, fixtures)', color = '#E67E22', order = 140, is_protected = true;


  -- Tags de référence types
  CREATE system_tag:deploy_saas SET name = 'deploy_saas', label = 'log saas', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 500, 
  is_protected = true;
  CREATE system_tag:deploy_module SET name = 'deploy_module', label = 'log module', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 520, 
  is_protected = true;
  CREATE system_tag:deploy_table SET name = 'deploy_table', label = 'log table', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 540, 
  is_protected = true;
  CREATE system_tag:deploy_function SET name = 'deploy_function', label = 'log function', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 550, 
  is_protected = true;
  CREATE system_tag:deploy_analyzer SET name = 'deploy_analyzer', label = 'log analyzer', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 560, 
  is_protected = true;
  CREATE system_tag:deploy_event SET name = 'deploy_event', label = 'log event', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 570, 
  is_protected = true;
  CREATE system_tag:deploy_sequence SET name = 'deploy_sequence', label = 'log sequence', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 580, 
  is_protected = true;
  CREATE system_tag:deploy_bucket SET name = 'deploy_bucket', label = 'log bucket', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 590, 
  is_protected = true;
  CREATE system_tag:deploy_param SET name = 'deploy_param', label = 'log param', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 600, 
  is_protected = true;
  CREATE system_tag:deploy_config SET name = 'deploy_config', label = 'log config', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 610, 
  is_protected = true;
  CREATE system_tag:deploy_api SET name = 'deploy_api', label = 'log api', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 620, 
  is_protected = true;
  CREATE system_tag:deploy_template SET name = 'deploy_template', label = 'log template', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 630, 
  is_protected = true;
  CREATE system_tag:deploy_builder SET name = 'deploy_builder', label = 'log builder', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 670, 
  is_protected = true;
  CREATE system_tag:deploy_record SET name = 'deploy_record', label = 'log record', 
  description = 'Tag de référence system_log', color = '#7F8C8D', order = 680, 
  is_protected = true;


  -- Tags de référence actions
  CREATE system_tag:deploy_create SET name = 'deploy_create', label = 'log create', 
  description = 'Tag de référence system_log', color = '#2ECC71', order = 400, 
  is_protected = true;
  CREATE system_tag:deploy_delete SET name = 'deploy_delete', label = 'log delete', 
  description = 'Tag de référence system_log', color = '#E74C3C', order = 410, 
  is_protected = true;
  CREATE system_tag:deploy_update SET name = 'deploy_update', label = 'log update', 
  description = 'Tag de référence system_log', color = '#F39C12', order = 420, 
  is_protected = true;
  CREATE system_tag:deploy_read SET name = 'deploy_read', label = 'log read', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 430, 
  is_protected = true;
  CREATE system_tag:deploy_import SET name = 'deploy_import', label = 'log import', 
  description = 'Tag de référence system_log', color = '#16A085', order = 440, 
  is_protected = true;
  CREATE system_tag:deploy_export SET name = 'deploy_export', label = 'log export', 
  description = 'Tag de référence system_log', color = '#8E44AD', order = 450, 
  is_protected = true;
  CREATE system_tag:deploy_sync SET name = 'deploy_sync', label = 'log sync', 
  description = 'Tag de référence system_log', color = '#34495E', order = 460, 
  is_protected = true;

  -- Tags de référence statuts
  CREATE system_tag:deploy_start SET name = 'deploy_start', label = 'log start', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 300, 
  is_protected = true;
  CREATE system_tag:deploy_inprogress SET name = 'deploy_inprogress', label = 'log inprogress', 
  description = 'Tag de référence system_log', color = '#9B59B6', order = 310, 
  is_protected = true;
  CREATE system_tag:deploy_done SET name = 'deploy_done', label = 'log done', 
  description = 'Tag de référence system_log', color = '#27AE60', order = 320,
   is_protected = true;

  -- Tags de référence résultats
  CREATE system_tag:deploy_initialise SET name = 'deploy_initialise', label = 'log initialise', 
  description = 'Tag de référence system_log', color = '#BDC3C7', order = 200, 
  is_protected = true;
  CREATE system_tag:deploy_advanced SET name = 'deploy_advanced', label = 'log advanced', 
  description = 'Tag de référence system_log', color = '#BDC3C7', order = 210, 
  is_protected = true;
  CREATE system_tag:deploy_success SET name = 'deploy_success', label = 'log success', 
  description = 'Tag de référence system_log', color = '#2ECC71', order = 220, 
  is_protected = true;
  CREATE system_tag:deploy_failure SET name = 'deploy_failure', label = 'log failure', 
  description = 'Tag de référence system_log', color = '#E74C3C', order = 230, 
  is_protected = true;
  CREATE system_tag:deploy_error SET name = 'deploy_error', label = 'log error', 
  description = 'Tag de référence system_log', color = '#C0392B', order = 240, 
  is_protected = true;
  CREATE system_tag:deploy_warning SET name = 'deploy_warning', label = 'log warning', 
  description = 'Tag de référence system_log', color = '#F39C12', order = 250, 
  is_protected = true;
  CREATE system_tag:deploy_info SET name = 'deploy_info', label = 'log info', 
  description = 'Tag de référence system_log', color = '#3498DB', order = 260, 
  is_protected = true;


  RETURN { 
    success: true, 
    message: 'Tags de référence deploy insérés (un record par tag)',
    run_id: $run_id };
}
COMMENT 'Crée les tags de référence utilisés par la table deploy 
(phases, types, actions, statuts, résultats)'
PERMISSIONS FULL;