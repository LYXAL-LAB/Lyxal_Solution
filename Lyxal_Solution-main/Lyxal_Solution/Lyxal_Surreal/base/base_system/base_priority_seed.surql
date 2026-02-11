DEFINE FUNCTION IF NOT EXISTS fn::base_priority_seed_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds base_priority', { run_id: $run_id, parent_run_id: $parent_run_id });

  LET $mk = function($rid, $data) {
    LET $exists = (SELECT id FROM type::thing('base_priority', $rid) LIMIT 1)[0];
    IF $exists == NONE { CREATE type::thing('base_priority', $rid) CONTENT $data; };
  };

  RETURN {
    seed: [
      $mk('VERY_LOW', { name: 'Très Basse', name_fr: 'Très Basse', name_en: 'Very Low', level: 1, color: '#28a745', icon: 'arrow-down', description: 'Priorité très basse, traitement non urgent', recommended_response_time: 72, recommended_resolution_time: 168, is_critical: false, requires_notification: false, display_order: 1, is_active: true }),
      $mk('LOW', { name: 'Basse', name_fr: 'Basse', name_en: 'Low', level: 2, color: '#6c757d', icon: 'chevron-down', description: 'Priorité basse, traitement standard', recommended_response_time: 48, recommended_resolution_time: 120, is_critical: false, requires_notification: false, display_order: 2, is_active: true }),
      $mk('MEDIUM', { name: 'Moyenne', name_fr: 'Moyenne', name_en: 'Medium', level: 3, color: '#ffc107', icon: 'minus', description: 'Priorité moyenne, traitement normal', recommended_response_time: 24, recommended_resolution_time: 72, is_critical: false, requires_notification: false, display_order: 3, is_active: true }),
      $mk('HIGH', { name: 'Haute', name_fr: 'Haute', name_en: 'High', level: 4, color: '#fd7e14', icon: 'chevron-up', description: 'Priorité haute, traitement accéléré', recommended_response_time: 8, recommended_resolution_time: 24, is_critical: false, requires_notification: true, display_order: 4, is_active: true }),
      $mk('CRITICAL', { name: 'Critique', name_fr: 'Critique', name_en: 'Critical', level: 5, color: '#dc3545', icon: 'exclamation-triangle', description: 'Priorité critique, intervention immédiate', recommended_response_time: 2, recommended_resolution_time: 8, is_critical: true, requires_notification: true, display_order: 5, is_active: true }),
      $mk('URGENT', { name: 'Urgente', name_fr: 'Urgente', name_en: 'Urgent', level: 5, color: '#e83e8c', icon: 'bolt', description: 'Priorité urgente, intervention immédiate', recommended_response_time: 1, recommended_resolution_time: 4, is_critical: true, requires_notification: true, display_order: 6, is_active: true })
    ]
  };
}
COMMENT 'Seeds base_priority'
PERMISSIONS FULL;

