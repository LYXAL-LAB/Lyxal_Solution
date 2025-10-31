DEFINE FUNCTION IF NOT EXISTS fn::builder_analyzer_create_record_initialise(
  $parent_run_id: option<string>,
  $phase: string
){
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_analyzer_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Référencer les fonctions dans builder_function (initialise + record)
  LET $sm_an = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_analyzer' LIMIT 1)[0];
  IF $sm_an != NONE {
    LET $ref_init = fn::builder_function_create_record('builder_analyzer_create_record_initialise', $sm_an.id, 'Initialise la fonction de création de record builder_analyzer', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_rec = fn::builder_function_create_record('builder_analyzer_create_record', $sm_an.id, 'Crée un enregistrement builder_analyzer', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  DEFINE FUNCTION IF NOT EXISTS fn::builder_analyzer_create_record(
  $analyzer_name: string,
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
    LET $start_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_start', 'log_initialise'], ($log_extra_tags ?? []));
    LET $start = fn::system_log_create_record($start_tags, 'Start: création de l\'analyzer', { run_id: $run_id, parent_run_id: $parent_run_id, input: { analyzer_name: $analyzer_name, sub_module_id: $sub_module_id } });
    -- Requis
    LET $required_check = fn::system_validate_required_fields({
      analyzer_name: $analyzer_name,
      sub_module_id: $sub_module_id,
      description: $description,
      log_phase: $log_phase
    }, ['analyzer_name', 'sub_module_id', 'description', 'log_phase']);
    IF $required_check.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création ANALYZER: champs requis manquants';
      LET $log_det = { errors: $required_check.errors ?? [], input: { analyzer_name: $analyzer_name, sub_module_id: $sub_module_id } };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $required_check; 
      };

    -- Sanitisation
    LET $sanitize = fn::system_sanitize_value_bulk([
      { 
        value: $analyzer_name, 
        pattern_name: 'default' 
        },
      { 
        value: $description, 
        pattern_name: 'default' 
        }
    ]);
    IF $sanitize.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création ANALYZER: sanitisation échouée';
      LET $log_det = { errors: $sanitize.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $sanitize; 
      };
    LET $clean_analyzer_name = $sanitize.valids[0].sanitized;
    LET $clean_description = $sanitize.valids[1].sanitized;

    -- Normalisation nom (minuscules, conserver underscores)
    LET $lower_analyzer_name = string::lowercase(string::trim($clean_analyzer_name));
    LET $generated_analyzer_code = 'analyzer_' + $lower_analyzer_name;

    -- Parent sous-module
    LET $parent_row = (SELECT sub_module_code, sub_module_name FROM type::thing($sub_module_id) LIMIT 1)[0];
    IF $parent_row == NONE 
    { 
      LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création ANALYZER: sous-module parent introuvable';
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

    -- Conformité
    LET $conform = fn::system_validate_conformity_bulk([
      { 
        value: $lower_analyzer_name, 
        label: 'Nom de l\'analyzer', 
        min_length: 1, 
        max_length: 100 
        },
      { 
        value: $generated_analyzer_code, 
        label: 'Code de l\'analyzer', 
        min_length: 9, 
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
      LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création ANALYZER: validation de conformité échouée';
      LET $log_det = { errors: $conform.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $conform; 
      };

    -- Unicité (builder_analyzer)
    LET $exist_items = [
      { 
        table: 'builder_analyzer', 
        field: 'analyzer_name', 
        value: $lower_analyzer_name, 
        label: 'Nom de l\'analyzer', 
        lowercase: true 
        },
      { 
        table: 'builder_analyzer', 
        field: 'analyzer_code', 
        value: $generated_analyzer_code, 
        label: 'Code de l\'analyzer', 
        lowercase: true 
        }
    ];
    LET $exist_check = fn::system_validate_existing_bulk($exist_items);
    IF $exist_check.total_not_missing > 0 {
      LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création ANALYZER: unicité violée';
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

    -- Tag personnel
    LET $tag_name = 'analyzer_' + $lower_analyzer_name;
    LET $existing_tag = (SELECT * FROM system_tag WHERE name = $tag_name LIMIT 1)[0];
    LET $personnal_tag_id = IF $existing_tag != NONE 
    THEN $existing_tag.id 
    ELSE fn::system_tag_create_record(
      $tag_name,
      $lower_analyzer_name,
      'Tag de l\'analyzer ' + $parent_name_lower + '/' + $lower_analyzer_name,
      NONE,
      true
    ).tag.id 
    END;

    -- Tags système
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

    -- Création
    LET $new_analyzer = CREATE builder_analyzer SET
      analyzer_name   = $lower_analyzer_name,
      analyzer_code   = $generated_analyzer_code,
      description     = $clean_description,
      sub_module_id   = $sub_module_id,
      spec            = $spec,
      personnal_tag   = $personnal_tag_id,
      tags            = $final_tags,
      updated_at      = time::now();

    -- Ajout tags système
    LET $created_id = type::string($new_analyzer[0].id);
    IF array::len($system_tag_names) > 0 { 
      LET $res_add = fn::system_add_tags_to_record('builder_analyzer', $created_id, $system_tag_names, true); 
      IF $res_add.success != true 
      { 
        RETURN 
        $res_add; 
        };
    };

    -- Retour
    LET $analyzer_refreshed = (SELECT * FROM type::thing($created_id) LIMIT 1)[0];
    -- Retour + journalisation
    LET $phase_check = fn::system_validate_existing_bulk([{ 
      table: 'system_tag', 
      field: 'name', 
      value: $log_phase, 
      label: 'Phase de log', 
      lowercase: true 
      }]);
    IF $phase_check.total_missing > 0 { 
      RETURN 
      { 
        success: false, 
        message: "Phase de log inconnue: '" + $log_phase + "'" 
        };
         };
    LET $log_tags = array::union([$log_phase, 'log_analyzer', 'log_create', 'log_done', 'log_success'], ($system_tag_names ?? []));
    LET $log_tags = array::union($log_tags, ($log_extra_tags ?? []));
    LET $log_msg = "Analyzer '" + $lower_analyzer_name + "' créé";
    LET $log_det = { analyzer_id: $created_id, analyzer_code: $generated_analyzer_code, analyzer_name: $lower_analyzer_name, sub_module_id: $sub_module_id };
    LET $log_res = fn::system_log_create_record($log_tags, $log_msg, $log_det);
    RETURN 
    { 
      success: true, 
      message: "Analyzer '" + $lower_analyzer_name + "' créé avec succès", 
      analyzer: $analyzer_refreshed 
      };
  }
  COMMENT 'Crée un enregistrement dans la table builder_analyzer (version record)'
  PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  RETURN 
  { 
    message: 'Fonction de création builder_analyzer (record) initialisée avec succès', 
    success: true 
    };
}
COMMENT 'Initialise la fonction de création record pour builder_analyzer'
PERMISSIONS FULL;




