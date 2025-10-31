DEFINE EVENT IF NOT EXISTS crm_app_evt_track_update
ON TABLE crm_app
WHEN $event = 'UPDATE'
THEN {
  LET $tracked_fields = [
    'assignable_users',
    'groups_assignable',
    'display_customer_description_in_opportunity',
    'is_manage_recurrent',
    'default_recurring_duration',
    'is_manage_catalogs',
    'agencies_management',
    'closed_win_opportunity_status',
    'closed_lost_opportunity_status',
    'sales_proposition_status',
    'converted_lead_status',
    'lost_lead_status'
  ];

  FOR $field IN $tracked_fields {
    LET $old_value = ($before).*[$field];
    LET $new_value = ($after).*[$field];

    IF $old_value != $new_value {
      CREATE crm_app_audit SET
        field = $field,
        old_value = $old_value,
        new_value = $new_value,
        record_id = $after.id,     
        modified_by = $auth.id,
        modified_at = time::now();

      fn::system_log_create_record(
        ['log_audit', 'log_event', 'log_update', 'log_done','log_success'],
        'Done: champ modifié: ' + $field,
        {
          table : 'crm_app_crm',  
          record_id: $after.id,
          field: $field,
          from: $old_value,
          to: $new_value,
          modified_by: $auth.id,
          run_id: rand::uuid()
        }
      );
    }
  }
};
