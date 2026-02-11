DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_create_record_initialise(
  $parent_run_id: option<string>,
  $phase: string
){
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_dependency_create_record', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Référencer les fonctions (initialise + record) dans builder_function
  LET $sm_dep = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_dependency' LIMIT 1)[0];
  IF $sm_dep != NONE {
    LET $ref_init = fn::builder_function_create_record('builder_dependency_create_record_initialise', $sm_dep.id, 'Initialise la fonction de création de record builder_dependency', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_rec = fn::builder_function_create_record('builder_dependency_create_record', $sm_dep.id, 'Crée un enregistrement builder_dependency', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_create_record(
    $dependency_name: string,
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
    LET $start_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_start', 'log_initialise'], ($log_extra_tags ?? []));
    LET $start = fn::system_log_create_record($start_tags, 'Start: création de la dépendance', { run_id: $run_id, parent_run_id: $parent_run_id, input: { dependency_name: $dependency_name, sub_module_id: $sub_module_id } });

    -- Requis
    LET $required_check = fn::system_validate_required_fields({
      dependency_name: $dependency_name,
      sub_module_id: $sub_module_id,
      description: $description,
      log_phase: $log_phase
    }, ['dependency_name', 'sub_module_id', 'description', 'log_phase']);
    IF $required_check.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création DEPENDENCY: champs requis manquants';
      LET $log_det = { errors: $required_check.errors ?? [], input: { dependency_name: $dependency_name, sub_module_id: $sub_module_id } };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN 
      $required_check; 
    };

    -- Sanitisation
    LET $sanitize = fn::system_sanitize_value_bulk([
      { value: $dependency_name, pattern_name: 'default' },
      { value: $description,     pattern_name: 'default' }
    ]);
    IF $sanitize.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création DEPENDENCY: sanitisation échouée';
      LET $log_det = { errors: $sanitize.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $sanitize; 
    };
    LET $clean_name = $sanitize.valids[0].sanitized;
    LET $clean_description = $sanitize.valids[1].sanitized;

    -- Normalisation
    LET $lower_name = string::lowercase(string::trim($clean_name));
    LET $generated_code = 'dependency_' + $lower_name;

    -- Parent sous-module (coercition en string pour type::thing)
    LET $sid = type::string($sub_module_id);
    LET $parent_row = (SELECT sub_module_code, sub_module_name FROM type::thing($sid) LIMIT 1)[0];
    IF $parent_row == NONE 
    { 
      LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création DEPENDENCY: sous-module parent introuvable';
      LET $log_det = { sub_module_id: $sub_module_id };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN { success: false, message: 'Sous-module parent introuvable', error: 'invalid_sub_module_id' }; 
    };
    LET $parent_name_lower = string::lowercase(string::trim(IF $parent_row.sub_module_name != NONE AND string::trim($parent_row.sub_module_name) != '' THEN $parent_row.sub_module_name ELSE 'unknown' END));

    -- Conformité
    LET $conform = fn::system_validate_conformity_bulk([
      { value: $lower_name,     label: 'Nom de la dépendance', min_length: 1,  max_length: 100 },
      { value: $generated_code, label: 'Code de la dépendance', min_length: 11, max_length: 150 },
      { value: $clean_description, label: 'Description',        min_length: 5,  max_length: 500 }
    ]);
    IF $conform.success != true 
    { 
      LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création DEPENDENCY: validation de conformité échouée';
      LET $log_det = { errors: $conform.errors ?? [] };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN $conform; 
    };

    -- Unicité
    LET $exist_items = [
      { table: 'builder_dependency', field: 'dependency_name', value: $lower_name,     label: 'Nom',  lowercase: true },
      { table: 'builder_dependency', field: 'dependency_code', value: $generated_code, label: 'Code', lowercase: true }
    ];
    LET $exist_check = fn::system_validate_existing_bulk($exist_items);
    IF $exist_check.total_not_missing > 0 
    { 
      LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_failure'], ($log_extra_tags ?? []));
      LET $log_msg = 'Erreur création DEPENDENCY: unicité violée';
      LET $log_det = { conflicts: $exist_check.not_missing, total_conflicts: $exist_check.total_not_missing };
      LET $log_err = fn::system_log_create_record($log_tags, $log_msg, $log_det);
      RETURN { success: false, message: 'Unicité violée: certaines valeurs existent déjà', conflicts: $exist_check.not_missing, total_conflicts: $exist_check.total_not_missing }; 
    };

    -- Tag personnel
    LET $tag_name = 'dependency_' + $lower_name;
    LET $existing_tag = (SELECT * FROM system_tag WHERE name = $tag_name LIMIT 1)[0];
    LET $personnal_tag_id = IF $existing_tag != NONE 
      THEN $existing_tag.id 
      ELSE fn::system_tag_create_record($tag_name, $lower_name, 'Tag de la dépendance ' + $parent_name_lower + '/' + $lower_name, NONE, true).tag.id 
    END;

    -- Tags système
    LET $final_tags = [$personnal_tag_id];
    LET $system_tag_names = [];
    IF $activate == true { LET $system_tag_names = array::union($system_tag_names, ['system_activate']); };
    IF $mandatory == true { LET $system_tag_names = array::union($system_tag_names, ['system_mandatory']); };
    IF $obligatory == true { LET $system_tag_names = array::union($system_tag_names, ['system_obligatory']); };

    -- Création
    LET $new_dep = CREATE builder_dependency SET
      dependency_name = $lower_name,
      dependency_code = $generated_code,
      description     = $clean_description,
      sub_module_id   = $sub_module_id,
      spec            = $spec,
      personnal_tag   = $personnal_tag_id,
      tags            = $final_tags,
      updated_at      = time::now();

    LET $created_id = type::string($new_dep[0].id);
    IF array::len($system_tag_names) > 0 { 
      LET $res_add = fn::system_add_tags_to_record('builder_dependency', $created_id, $system_tag_names, true); 
    };

    LET $dep_refreshed = (SELECT * FROM type::thing($created_id) LIMIT 1)[0];
    -- Retour + journalisation
    LET $phase_check = fn::system_validate_existing_bulk([{ table: 'system_tag', field: 'name', value: $log_phase, label: 'Phase de log', lowercase: true }]);
    IF $phase_check.total_missing > 0 { 
      RETURN { success: false, message: "Phase de log inconnue: '" + $log_phase + "'" }; 
    };
    LET $log_tags = array::union([$log_phase, 'log_dependency', 'log_create', 'log_done', 'log_success'], ($system_tag_names ?? []));
    LET $log_tags = array::union($log_tags, ($log_extra_tags ?? []));
    LET $log_msg = "Dependency '" + $lower_name + "' créée";
    LET $log_det = { dependency_id: $created_id, dependency_code: $generated_code, dependency_name: $lower_name, sub_module_id: $sub_module_id };
    LET $log_res = fn::system_log_create_record($log_tags, $log_msg, $log_det);
    RETURN { success: true, message: "Dependency '" + $lower_name + "' créée avec succès", dependency: $dep_refreshed };
  }
  COMMENT 'Crée un enregistrement dans la table builder_dependency (version record)'
  PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  RETURN { message: 'Fonction de création builder_dependency (record) initialisée avec succès', success: true };
}
COMMENT 'Initialise la fonction de création record pour builder_dependency'
PERMISSIONS FULL;


