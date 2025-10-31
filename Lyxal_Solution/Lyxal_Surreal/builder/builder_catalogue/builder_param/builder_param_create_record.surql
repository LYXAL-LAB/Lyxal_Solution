DEFINE FUNCTION IF NOT EXISTS fn::builder_param_create_record_initialise(
  $parent_run_id: option<string>,
  $phase: string
){
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_param_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Référencer la fonction d'initialisation dans builder_function (si non référencée ailleurs)
  LET $sm_param = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_param' LIMIT 1)[0];
  IF $sm_param != NONE {
    LET $ref_fn = fn::builder_function_create_record('builder_param_create_record_initialise', $sm_param.id, 'Initialise la fonction de création de record builder_param', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_rec = fn::builder_function_create_record('builder_param_create_record', $sm_param.id, 'Crée un enregistrement builder_param', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  DEFINE FUNCTION IF NOT EXISTS fn::builder_param_create_record(
    $param_name: string,
    $sub_module_id: record<builder_sub_module>,
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
    LET $start_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_start', 'log_initialise'], ($log_extra_tags ?? []));
    LET $start = fn::system_log_create_record($start_tags, 'Start: création du param', { run_id: $run_id, parent_run_id: $parent_run_id, input: { param_name: $param_name, sub_module_id: $sub_module_id } });
    LET $required_check = fn::system_validate_required_fields({
      param_name: $param_name,
      sub_module_id: $sub_module_id,
      description: $description,
      log_phase: $log_phase
    }, ['param_name', 'sub_module_id', 'description', 'log_phase']);
    IF $required_check.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création PARAM: champs requis manquants';
      LET $log_det = { errors: $required_check.errors ?? [], input: { param_name: $param_name, sub_module_id: $sub_module_id } };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $required_check; 
      };

    LET $sanitize = fn::system_sanitize_value_bulk([
      { 
        value: $param_name, 
        pattern_name: 'default' 
        },
      { 
        value: $description, 
        pattern_name: 'default' 
        },
    ]);
    IF $sanitize.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création PARAM: sanitisation échouée';
      LET $log_det = { errors: $sanitize.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $sanitize; 
      };
    LET $clean_param_name = $sanitize.valids[0].sanitized;
    LET $clean_description = $sanitize.valids[1].sanitized;

    LET $lower_param_name = string::lowercase(string::trim($clean_param_name));
    LET $generated_param_code = 'param_' + $lower_param_name;

    LET $parent_row = (SELECT sub_module_code, sub_module_name FROM type::thing($sub_module_id) LIMIT 1)[0];
    IF $parent_row == NONE 
    { 
      LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création PARAM: sous-module parent introuvable';
      LET $log_det = { sub_module_id: $sub_module_id };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      { 
        success: false, 
        message: 'Sous-module parent introuvable', 
        error: 'invalid_sub_module_id' 
        }; 
        };
    LET $parent_name_lower = string::lowercase(string::trim($parent_row.sub_module_name));

    LET $conform = fn::system_validate_conformity_bulk([
      { 
        value: $lower_param_name, 
        label: 'Nom du param', 
        min_length: 1, 
        max_length: 100 
        },
      { 
        value: $generated_param_code, 
        label: 'Code du param', 
        min_length: 7, 
        max_length: 150 
        },
      { 
        value: $clean_description, 
        label: 'Description', 
        min_length: 5, 
        max_length: 500 
        }
    ]);
    IF $conform.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création PARAM: validation de conformité échouée';
      LET $log_det = { errors: $conform.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $conform; 
      };

    LET $exist_items = [
      { 
        table: 'builder_param', 
        field: 'param_name', 
        value: $lower_param_name, 
        label: 'Nom du param', 
        lowercase: true },
      { 
        table: 'builder_param', 
        field: 'param_code', 
        value: $generated_param_code, 
        label: 'Code du param', 
        lowercase: true }
    ];
    LET $exist_check = fn::system_validate_existing_bulk($exist_items);
    IF $exist_check.total_not_missing > 0 
    { 
      LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création PARAM: unicité violée';
      LET $log_det = { conflicts: $exist_check.not_missing, total_conflicts: $exist_check.total_not_missing };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      { 
        success: false, 
        message: 'Unicité violée: certaines valeurs existent déjà', 
        conflicts: $exist_check.not_missing, 
        total_conflicts: $exist_check.total_not_missing 
        }; 
        };

    LET $tag_name = 'param_' + $lower_param_name;
    LET $existing_tag = (SELECT * FROM system_tag WHERE name = $tag_name LIMIT 1)[0];
    LET $personnal_tag_id = IF $existing_tag != NONE 
    THEN $existing_tag.id 
    ELSE fn::system_tag_create_record(
      $tag_name,
      $lower_param_name,
      'Tag du param ' + $parent_name_lower + '/' + $lower_param_name,
      NONE,
      true
    ).tag.id 
    END;

    LET $final_tags = [$personnal_tag_id];
    LET $system_tag_names = [];
    IF $activate == true 
    { 
      LET $system_tag_names = array::union($system_tag_names, ['system_activate']); 
      };
    IF $mandatory == true 
    { 
      LET $system_tag_names = array::union($system_tag_names, ['system_mandatory']); 
      };
    IF $obligatory == true 
    { 
      LET $system_tag_names = array::union($system_tag_names, ['system_obligatory']); 
      };

    LET $new_param = CREATE builder_param SET
      param_name     = $lower_param_name,
      param_code     = $generated_param_code,
      description    = $clean_description,
      sub_module_id  = $sub_module_id,
      spec           = $spec,
      personnal_tag  = $personnal_tag_id,
      tags           = $final_tags,
      updated_at     = time::now();

    LET $created_id = type::string($new_param[0].id);
    IF array::len($system_tag_names) > 0 
    { 
      LET $res_add = fn::system_add_tags_to_record('builder_param', 
      $created_id, $system_tag_names, true);
      };

    -- Retour + journalisation
    LET $param_refreshed = (SELECT * FROM type::thing($created_id) LIMIT 1)[0];
    LET $phase_check = fn::system_validate_existing_bulk([
      { table: 'system_tag', 
      field: 'name', value: $log_phase, 
      label: 'Phase de log', 
      lowercase: true 
      }]);
    IF $phase_check.total_missing > 0 
    { 
      RETURN 
      { 
        success: false, 
        message: "Phase de log inconnue: '" + $log_phase + "'" 
        }; 
        };
    LET $log_tags = array::union([$log_phase, 'log_param', 'log_create', 'log_done', 'log_success'], ($system_tag_names ?? []));
    LET $log_tags = array::union($log_tags, ($log_extra_tags ?? []));
    LET $log_msg = "Param '" + $lower_param_name + "' créé";
    LET $log_det = 
    { 
      param_id: $created_id, 
    param_code: $generated_param_code,
    param_name: $lower_param_name, 
    sub_module_id: $sub_module_id 
    };
    LET $log_res = fn::system_log_create_record($log_tags, $log_msg, $log_det);
    RETURN 
    { 
      success: true, 
      message: 'Param \'' + $lower_param_name + '\' créé avec succès', 
      param: $param_refreshed 
      };
  }
  COMMENT 'Crée un enregistrement dans la table builder_param (version record)'
  PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  LET $done = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_success'], 'Done: création de la fonction builder_param_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de création record pour builder_param'
PERMISSIONS FULL;




