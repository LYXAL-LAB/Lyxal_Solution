DEFINE FUNCTION IF NOT EXISTS fn::builder_bucket_create_record_initialise(
  $parent_run_id: option<string>,
  $phase: string
){
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_bucket_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Référencer la fonction d'initialisation dans builder_function (si non référencée ailleurs)
  LET $sm_bkt = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_bucket' LIMIT 1)[0];
  IF $sm_bkt != NONE {
    LET $ref_fn = fn::builder_function_create_record('builder_bucket_create_record_initialise', $sm_bkt.id, 'Initialise la fonction de création de record builder_bucket', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_rec = fn::builder_function_create_record('builder_bucket_create_record', $sm_bkt.id, 'Crée un enregistrement builder_bucket', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  DEFINE FUNCTION IF NOT EXISTS fn::builder_bucket_create_record(
    $bucket_name: string,
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
    LET $start_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_start', 'log_initialise'], ($log_extra_tags ?? []));
    LET $start = fn::system_log_create_record($start_tags, 'Start: création du bucket', { run_id: $run_id, parent_run_id: $parent_run_id, input: { bucket_name: $bucket_name, module_id: $module_id } });
    LET $required_check = fn::system_validate_required_fields(
      {
       bucket_name: $bucket_name,
       module_id: $module_id,
       description: $description,
       log_phase: $log_phase
      }, ['bucket_name', 'module_id', 'description', 'log_phase']);
    IF $required_check.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création BUCKET: champs requis manquants';
      LET $log_det = { errors: $required_check.errors ?? [], input: { bucket_name: $bucket_name, module_id: $module_id } };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $required_check; 
      };

    LET $sanitize = fn::system_sanitize_value_bulk([
      { 
        value: $bucket_name, 
        pattern_name: 'default' 
        },
      { 
        value: $description, 
        pattern_name: 'default' 
        }
    ]);
    IF $sanitize.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création BUCKET: sanitisation échouée';
      LET $log_det = { errors: $sanitize.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $sanitize; 
      };
    LET $clean_bucket_name = $sanitize.valids[0].sanitized;
    LET $clean_description = $sanitize.valids[1].sanitized;

    LET $lower_bucket_name = string::lowercase(string::trim($clean_bucket_name));
    LET $generated_bucket_code = 'bucket_' + $lower_bucket_name;

    LET $parent_row = (SELECT module_code, module_name FROM type::thing($module_id) LIMIT 1)[0];
    IF $parent_row == NONE 
    { 
      LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création BUCKET: module parent introuvable';
      LET $log_det = { module_id: $module_id };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      { 
        success: false, 
        message: 'Module parent introuvable', 
        error: 'invalid_module_id' 
        }; 
        };
    LET $parent_name_lower = string::lowercase(string::trim($parent_row.module_name));

    LET $conform = fn::system_validate_conformity_bulk([
      { 
        value: $lower_bucket_name, 
        label: 'Nom du bucket', 
        min_length: 1, 
        max_length: 100 
        },
      { 
        value: $generated_bucket_code, 
        label: 'Code du bucket', 
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
      LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création BUCKET: validation de conformité échouée';
      LET $log_det = { errors: $conform.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $conform; 
      };

    LET $exist_items = [
      { 
        table: 'builder_bucket', 
        field: 'bucket_name', 
        value: $lower_bucket_name, 
        label: 'Nom du bucket', 
        lowercase: true 
        },
      { 
        table: 'builder_bucket', 
        field: 'bucket_code', 
        value: $generated_bucket_code, 
        label: 'Code du bucket', 
        lowercase: true 
        }
    ];
    LET $exist_check = fn::system_validate_existing_bulk($exist_items);
    IF $exist_check.total_not_missing > 0 
    { 
      LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création BUCKET: unicité violée';
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

    LET $tag_name = 'bucket_' + $lower_bucket_name;
    LET $existing_tag = (SELECT * FROM system_tag WHERE name = $tag_name LIMIT 1)[0];
    LET $personnal_tag_id = IF $existing_tag != NONE 
    THEN $existing_tag.id 
    ELSE fn::system_tag_create_record(
      $tag_name,
      $lower_bucket_name,
      'Tag du bucket ' + $parent_name_lower + '/' + $lower_bucket_name,
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

    LET $new_bucket = CREATE builder_bucket SET
      bucket_name    = $lower_bucket_name,
      bucket_code    = $generated_bucket_code,
      description    = $clean_description,
      module_id      = $module_id,
      spec           = $spec,
      personnal_tag  = $personnal_tag_id,
      tags           = $final_tags,
      updated_at     = time::now();

    LET $created_id = type::string($new_bucket[0].id);
    IF array::len($system_tag_names) > 0 
    { 
      LET $res_add = fn::system_add_tags_to_record('builder_bucket', 
      $created_id, $system_tag_names, true); 
      };

    LET $bucket_refreshed = (SELECT * FROM type::thing($created_id) LIMIT 1)[0];
   -- Retour + journalisation
LET $phase_check = fn::system_validate_existing_bulk([
  { 
    table: 'system_tag', 
    field: 'name', 
    value: $log_phase, 
    label: 'Phase de log', 
    lowercase: true 
    }]);
IF $phase_check.total_missing > 0 
{ 
  RETURN 
  { 
    success: false, 
    message: "Phase de log inconnue: '" + $log_phase + "'" }; 
    };
LET $log_tags = array::union([$log_phase, 'log_bucket', 'log_create', 'log_done', 'log_success'], ($system_tag_names ?? []));
LET $log_tags = array::union($log_tags, ($log_extra_tags ?? []));
LET $log_msg = "Bucket '" + $lower_bucket_name + "' créé";
LET $log_det = 
{ 
  bucket_id: $created_id, 
  bucket_code: $generated_bucket_code, 
  bucket_name: $lower_bucket_name, 
  module_id: $module_id 
  };
LET $log_res = fn::system_log_create_record($log_tags, $log_msg, $log_det);
RETURN 
{ 
  success: true, 
  message: 'Bucket \'' + $lower_bucket_name + '\' créé avec succès', 
  bucket: $bucket_refreshed 
  };
  }
  COMMENT 'Crée un enregistrement dans la table builder_bucket (version record)'
  PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  LET $done = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_success'], 'Done: création de la fonction builder_bucket_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de création record pour builder_bucket'
PERMISSIONS FULL;

