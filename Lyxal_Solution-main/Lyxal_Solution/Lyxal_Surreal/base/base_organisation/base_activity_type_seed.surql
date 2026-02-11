DEFINE FUNCTION IF NOT EXISTS fn::base_activity_type_seed_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds base_activity_type', { run_id: $run_id, parent_run_id: $parent_run_id });

  LET $mk = function($rid, $data) {
    LET $exists = (SELECT id FROM type::thing('base_activity_type', $rid) LIMIT 1)[0];
    IF $exists == NONE { CREATE type::thing('base_activity_type', $rid) CONTENT $data; };
  };

  RETURN {
    seed: [
      $mk('CALL', { name: 'Appel téléphonique', code: 'CALL', description: 'Appel téléphonique entrant ou sortant', name_fr: 'Appel téléphonique', name_en: 'Phone Call', category: base_activity_category:CRM, icon: 'fa-phone', color: '#28a745', sort_order: 1, auto_track: true, default_duration_minutes: 15, default_reminder_minutes: 5 }),
      $mk('EMAIL', { name: 'Email', code: 'EMAIL', description: 'Envoi ou réception d\'email', name_fr: 'Email', name_en: 'Email', category: base_activity_category:CRM, icon: 'fa-envelope', color: '#007bff', sort_order: 2, auto_track: true, default_duration_minutes: 0, default_reminder_minutes: 0 }),
      $mk('MEETING', { name: 'Réunion', code: 'MEETING', description: 'Réunion en personne ou virtuelle', name_fr: 'Réunion', name_en: 'Meeting', category: base_activity_category:CRM, icon: 'fa-users', color: '#6f42c1', sort_order: 3, is_billable: true, requires_location: true, requires_attendees: true, default_duration_minutes: 60, default_reminder_minutes: 15 }),
      $mk('TASK', { name: 'Tâche', code: 'TASK', description: 'Tâche ou action à réaliser', name_fr: 'Tâche', name_en: 'Task', category: base_activity_category:CRM, icon: 'fa-tasks', color: '#ffc107', sort_order: 4, is_billable: true, default_duration_minutes: 120, default_reminder_minutes: 30 }),
      $mk('NORMAL_TIME', { name: 'Temps normal', code: 'NORMAL_TIME', description: 'Temps de travail normal', name_fr: 'Temps normal', name_en: 'Normal Time', category: base_activity_category:TIMESHEET, icon: 'fa-clock', color: '#17a2b8', sort_order: 5, is_billable: true, default_duration_minutes: 480 }),
      $mk('OVERTIME', { name: 'Heures supplémentaires', code: 'OVERTIME', description: 'Temps de travail en heures supplémentaires', name_fr: 'Heures supplémentaires', name_en: 'Overtime', category: base_activity_category:TIMESHEET, icon: 'fa-clock', color: '#fd7e14', sort_order: 6, is_billable: true, default_duration_minutes: 60 }),
      $mk('NIGHT_WORK', { name: 'Travail de nuit', code: 'NIGHT_WORK', description: 'Temps de travail de nuit', name_fr: 'Travail de nuit', name_en: 'Night Work', category: base_activity_category:TIMESHEET, icon: 'fa-moon', color: '#6c757d', sort_order: 7, is_billable: true, default_duration_minutes: 480 }),
      $mk('TRAINING', { name: 'Formation', code: 'TRAINING', description: 'Session de formation', name_fr: 'Formation', name_en: 'Training', category: base_activity_category:GENERAL, icon: 'fa-graduation-cap', color: '#20c997', sort_order: 8, default_duration_minutes: 240 }),
      $mk('TRAVEL', { name: 'Déplacement', code: 'TRAVEL', description: 'Temps de déplacement', name_fr: 'Déplacement', name_en: 'Travel', category: base_activity_category:GENERAL, icon: 'fa-car', color: '#e83e8c', sort_order: 9, is_billable: true, requires_location: true, auto_track: true, default_duration_minutes: 60 })
    ]
  };
}
COMMENT 'Seeds base_activity_type'
PERMISSIONS FULL;

