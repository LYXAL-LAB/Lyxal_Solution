DEFINE FUNCTION IF NOT EXISTS fn::builder_config_create_record_initialise(
  $parent_run_id: option<string>,
  $phase: string
){
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_config_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Référencer la fonction d'initialisation dans builder_function (si non référencée ailleurs)
  LET $sm_cfg = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_config' LIMIT 1)[0];
  IF $sm_cfg != NONE {
    LET $ref_fn = fn::builder_function_create_record('builder_config_create_record_initialise', $sm_cfg.id, 'Initialise la fonction de création de record builder_config', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_rec = fn::builder_function_create_record('builder_config_create_record', $sm_cfg.id, 'Crée un enregistrement builder_config', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  DEFINE FUNCTION IF NOT EXISTS fn::builder_config_create_record(
    $config_name: string,
    $module_id: record<builder_module>,
    $description: string,
    $spec: option<object>,
    $activate: bool,
    $mandatory: bool,
    $obligatory: bool,
    $log_phase: string,
    $log_extra_tags: option<array<string>>,
    $parent_run_id: option<string>
  ) {
    LET $run_id = rand::uuid();
    LET $start_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_start', 'log_initialise'], ($log_extra_tags ?? []));
    LET $start = fn::system_log_create_record($start_tags, 'Start: création de la config', { run_id: $run_id, parent_run_id: $parent_run_id, input: { config_name: $config_name, module_id: $module_id } });
    LET $required_check = fn::system_validate_required_fields({
      config_name: $config_name,
      module_id: $module_id,
      description: $description,
      log_phase: $log_phase
    }, ['config_name', 'module_id', 'description', 'log_phase']);
    IF $required_check.success != true {
      LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création CONFIG: champs requis manquants';
      LET $log_det = { errors: $required_check.errors ?? [], input: { config_name: $config_name, module_id: $module_id } };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $required_check;
    };


    LET $sanitize = fn::system_sanitize_value_bulk([
      { value: $config_name, pattern_name: 'default' },
      { value: $description, pattern_name: 'default' }
    ]);
    IF $sanitize.success != true {
      LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création CONFIG: sanitisation échouée';
      LET $log_det = { errors: $sanitize.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $sanitize;
    };
    LET $clean_config_name = $sanitize.valids[0].sanitized;
    LET $clean_description = $sanitize.valids[1].sanitized;

    LET $lower_config_name = string::lowercase(string::trim($clean_config_name));
    LET $generated_config_code = 'config_' + $lower_config_name;

    LET $parent_row = (SELECT module_code, module_name FROM type::thing($module_id) LIMIT 1)[0];
    IF $parent_row == NONE {
      LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création CONFIG: module parent introuvable';
      LET $log_det = { module_id: $module_id };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN { success: false, message: 'Module parent introuvable', error: 'invalid_module_id' };
    };
    LET $parent_name_lower = string::lowercase(string::trim($parent_row.module_name));

    LET $conform = fn::system_validate_conformity_bulk([
      { value: $lower_config_name, label: 'Nom de la config', min_length: 1, max_length: 100 },
      { value: $generated_config_code, label: 'Code de la config', min_length: 7, max_length: 150 },
      { value: $clean_description, label: 'Description', min_length: 5, max_length: 500 }
    ]);
    IF $conform.success != true {
      LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création CONFIG: validation de conformité échouée';
      LET $log_det = { errors: $conform.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $conform;
    };

    LET $exist_items = [
      { table: 'builder_config', field: 'config_name', value: $lower_config_name, label: 'Nom de la config', lowercase: true },
      { table: 'builder_config', field: 'config_code', value: $generated_config_code, label: 'Code de la config', lowercase: true }
    ];
    LET $exist_check = fn::system_validate_existing_bulk($exist_items);
    IF $exist_check.total_not_missing > 0 {
      LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création CONFIG: unicité violée';
      LET $log_det = { conflicts: $exist_check.not_missing, total_conflicts: $exist_check.total_not_missing };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN { success: false, message: 'Unicité violée: certaines valeurs existent déjà', conflicts: $exist_check.not_missing, total_conflicts: $exist_check.total_not_missing };
    };

    LET $tag_name = 'config_' + $lower_config_name;
    LET $existing_tag = (SELECT * FROM system_tag WHERE name = $tag_name LIMIT 1)[0];
    LET $personnal_tag_id = IF $existing_tag != NONE THEN $existing_tag.id ELSE fn::system_tag_create_record(
      $tag_name,
      $lower_config_name,
      'Tag de la config ' + $parent_name_lower + '/' + $lower_config_name,
      NONE,
      true
    ).tag.id END;

    LET $final_tags = [$personnal_tag_id];
    LET $system_tag_names = [];
    IF $activate == true { LET $system_tag_names = array::union($system_tag_names, ['system_activate']); };
    IF $mandatory == true { LET $system_tag_names = array::union($system_tag_names, ['system_mandatory']); };
    IF $obligatory == true { LET $system_tag_names = array::union($system_tag_names, ['system_obligatory']); };

    LET $new_config = CREATE builder_config SET
      config_name    = $lower_config_name,
      config_code    = $generated_config_code,
      description    = $clean_description,
      module_id      = $module_id,
      spec           = $spec,
      personnal_tag  = $personnal_tag_id,
      tags           = $final_tags,
      updated_at     = time::now();

    LET $created_id = type::string($new_config[0].id);
    IF array::len($system_tag_names) > 0 { LET $res_add = fn::system_add_tags_to_record('builder_config', $created_id, $system_tag_names, true); };

-- Retour + journalisation
LET $config_refreshed = (SELECT * FROM type::thing($created_id) LIMIT 1)[0];
LET $phase_check = fn::system_validate_existing_bulk([{ table: 'system_tag', field: 'name', value: $log_phase, label: 'Phase de log', lowercase: true }]);
IF $phase_check.total_missing > 0 { RETURN { success: false, message: "Phase de log inconnue: '" + $log_phase + "'" }; };
LET $log_tags = array::union([$log_phase, 'log_config', 'log_create', 'log_done', 'log_success'], ($system_tag_names ?? []));
LET $log_tags = array::union($log_tags, ($log_extra_tags ?? []));
LET $log_msg = 'Config ' + $lower_config_name + ' créée';
LET $log_det = { config_id: $created_id, config_code: $generated_config_code, config_name: $lower_config_name, module_id: $module_id };
LET $log_res = fn::system_log_create_record($log_tags, $log_msg, $log_det);
RETURN { success: true, message: 'Config ' + $lower_config_name + ' créée avec succès', config: $config_refreshed };

  }
  COMMENT 'Crée un enregistrement dans la table builder_config (version record)'
  PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  LET $done = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_success'], 'Done: création de la fonction builder_config_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de création record pour builder_config'
PERMISSIONS FULL;




