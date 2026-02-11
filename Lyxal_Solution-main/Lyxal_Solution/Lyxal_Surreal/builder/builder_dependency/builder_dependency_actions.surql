DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_actions_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $log_phase = IF $phase == NONE OR string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END;
LET $start = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: initialisation des actions builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });

-- La table relationnelle 'builder_dependency_edge' est créée via
-- fn::builder_dependency_edge_create_table_initialise dans builder_dependency_create_table.surql

-- Référencer les fonctions d'actions dans builder_function
LET $sm_dep = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_dependency' LIMIT 1)[0];
IF $sm_dep != NONE {
  LET $f1 = fn::builder_function_create_record('builder_dependency_actions_initialise', $sm_dep.id, 'Initialise les fonctions d\'actions builder_dependency', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f2 = fn::builder_function_create_record('builder_dependency_create_edge', $sm_dep.id, 'Crée une arête de dépendance', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f3 = fn::builder_function_create_record('builder_dependency_list_uses', $sm_dep.id, 'Liste les cibles utilisées par une ressource', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f4 = fn::builder_function_create_record('builder_dependency_list_used_by', $sm_dep.id, 'Liste les sources qui utilisent une ressource', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f5 = fn::builder_function_create_record('builder_dependency_sync_existing', $sm_dep.id, 'Synchronise les arêtes depuis le catalogue existant', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f6 = fn::builder_function_create_record('builder_dependency_create_module_link', $sm_dep.id, 'Crée un lien Module→Module', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f7 = fn::builder_function_create_record('builder_dependency_seed_contains_edges_for_module', $sm_dep.id, 'Crée les liens de composition Module→ressources', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f8 = fn::builder_function_create_record('builder_dependency_list_module_contents', $sm_dep.id, 'Liste le contenu d\'un module', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f9 = fn::builder_function_create_record('builder_dependency_list_module_dependencies', $sm_dep.id, 'Liste les dépendances Module↔Module', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f10 = fn::builder_function_create_record('builder_dependency_seed_all_existing', $sm_dep.id, 'Peuple automatiquement edges et catalogue à partir de l\'existant', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f11 = fn::builder_function_create_record('builder_dependency_catalogue_refresh_all', $sm_dep.id, 'Reconstruit le catalogue builder_dependency à partir des edges existants', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f12 = fn::builder_function_create_record('builder_dependency_catalogue_refresh_for_sub_module', $sm_dep.id, 'Reconstruit le catalogue pour un sous-module', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  LET $f13 = fn::builder_function_create_record('deploy_builder_dependency_finalize', $sm_dep.id, 'Finalisation globale builder_dependency (seed + refresh)', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
};

-- Crée un lien de dépendance (edge)
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_create_edge(
  $source_id: string,
  $target_id: string,
  $kind: string,
  $scope: option<string>,
  $required: option<bool>,
  $since_version: option<string>,
  $until_version: option<string>,
  $notes: option<string>
) {
  -- Sanitisation et validation minimale
  LET $src = IF $source_id != NONE THEN string::trim(type::string($source_id)) ELSE '' END;
  LET $dst = IF $target_id != NONE THEN string::trim(type::string($target_id)) ELSE '' END;
  IF $src == '' OR $dst == '' { RETURN { success: false, message: 'IDs source/target manquants' }; };

  -- Kind requis
  LET $k = IF $kind != NONE THEN string::trim($kind) ELSE '' END;
  IF $k == '' { RETURN { success: false, message: 'Kind manquant' }; };

  -- Existence directe des records via type::thing()
  LET $src_exist = (SELECT id FROM type::thing($src) LIMIT 1);
  LET $dst_exist = (SELECT id FROM type::thing($dst) LIMIT 1);
  IF array::len($src_exist) == 0 OR array::len($dst_exist) == 0 {
    RETURN { success: false, message: 'Source/Target introuvables' };
  };

  -- Création du lien (unicité assurée par l'index UNIQUE sur (out,in,kind))
  LET $from = type::thing($src);
  LET $to = type::thing($dst);
  LET $edge = RELATE $from->builder_dependency_edge->$to SET
    kind = string::lowercase($k),
    scope = $scope,
    required = $required ?? true,
    since_version = $since_version,
    until_version = $until_version,
    notes = $notes;
  LET $edge_len = array::len($edge);
  IF $edge_len == 0 {
    LET $after = (SELECT id FROM builder_dependency_edge WHERE out = $from AND in = $to AND kind = string::lowercase($k) LIMIT 1);
    RETURN { success: false, message: 'CREATE edge failed', from: $src, to: $dst, kind: string::lowercase($k), found_after: array::len($after) > 0, edge_after: ($after[0] ?? NONE) };
  };

  RETURN { success: true, message: 'Dépendance créée', edge: $edge[0] };
}
COMMENT 'Crée une arête builder_dependency_edge (source->target)'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Liste les cibles utilisées par une ressource
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_list_uses($source_id: string) {
  LET $src = string::trim($source_id);
  RETURN SELECT in AS target FROM builder_dependency_edge WHERE out = type::thing($src);
}
COMMENT 'Liste des cibles (targets) utilisées par source via builder_dependency'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Liste les sources qui utilisent une ressource
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_list_used_by($target_id: string) {
  LET $dst = string::trim($target_id);
  RETURN SELECT out AS source FROM builder_dependency_edge WHERE in = type::thing($dst);
}
COMMENT 'Liste des sources (sources) qui dépendent de target via builder_dependency'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Synchroniser les arêtes à partir des enregistrements catalogue (spec)
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_sync_existing(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE OR string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END;
  LET $start = fn::system_log_create_record([$log_phase, 'log_function', 'log_deploy', 'log_start', 'log_initialise'], 'Start: synchronisation des arêtes builder_dependency_edge depuis le catalogue', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Liens multiples via spec.links (array)
  LET $links_arrays = (SELECT VALUE spec.links FROM builder_dependency WHERE spec != NONE AND spec.links != NONE);
  LET $links = array::flatten($links_arrays);
  IF array::len($links) > 0 {
    LET $res_links = (SELECT VALUE fn::builder_dependency_create_edge(value.source_id, value.target_id, value.kind, value.scope, value.required, value.since_version, value.until_version, value.notes) FROM $links);
  };

  -- Liens unitaires via spec.source_id / spec.target_id
  LET $single = (SELECT VALUE spec FROM builder_dependency WHERE spec != NONE AND spec.source_id != NONE AND spec.target_id != NONE);
  IF array::len($single) > 0 {
    LET $res_single = (SELECT VALUE fn::builder_dependency_create_edge(value.source_id, value.target_id, value.kind, value.scope, value.required, value.since_version, value.until_version, value.notes) FROM $single);
  };

  LET $done = fn::system_log_create_record([$log_phase, 'log_function', 'log_deploy', 'log_done', 'log_success'], 'Done: synchronisation des arêtes builder_dependency_edge', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Synchronise les arêtes builder_dependency_edge depuis la table catalogue builder_dependency'
PERMISSIONS FULL;

-- Reconstruit entièrement le catalogue à partir des arêtes
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_catalogue_refresh_all(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE OR string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END;
  LET $start = fn::system_log_create_record([$log_phase, 'module_builder', 'log_dependency', 'log_deploy', 'log_start', 'log_initialise'], 'Start: refresh complet du catalogue builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });

  LET $subs = (SELECT VALUE id FROM builder_sub_module);
  IF array::len($subs) > 0 {
    LET $res = (SELECT VALUE fn::builder_dependency_catalogue_refresh_for_sub_module(value, $phase, $run_id) FROM $subs);
  };

  LET $done = fn::system_log_create_record([$log_phase, 'module_builder', 'log_dependency', 'log_deploy', 'log_done', 'log_success'], 'Done: refresh complet du catalogue builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Reconstruit pour chaque sous-module une entrée catalogue avec spec.links (contains + edges existants)'
PERMISSIONS FULL;

-- Reconstruit le catalogue pour un sous-module donné
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_catalogue_refresh_for_sub_module(
  $sub_module_id: record<builder_sub_module>,
  $phase: string,
  $parent_run_id: option<string>
) {
  LET $sid = type::string($sub_module_id);
  LET $row = (SELECT sub_module_name FROM type::thing($sid) LIMIT 1)[0];
  IF $row == NONE { RETURN { success: false, message: 'Sous-module introuvable' }; };
  LET $run_id = rand::uuid();
  LET $name = string::lowercase(IF $row.sub_module_name != NONE THEN $row.sub_module_name ELSE 'unknown' END);
  LET $code = 'dependency_' + $name;

  LET $res_ids = array::union(
    (SELECT VALUE type::string(id) FROM builder_table    WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_function WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_event    WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_analyzer WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_sequence WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_bucket   WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_param    WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_config   WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_api      WHERE sub_module_id = $sub_module_id),
    (SELECT VALUE type::string(id) FROM builder_template WHERE sub_module_id = $sub_module_id)
  );

  LET $links_contains = (
    SELECT VALUE { source_id: $sid, target_id: value, kind: 'contains', scope: 'structure', required: true }
    FROM $res_ids
    WHERE value != NONE
  );
  LET $edges_from_here = (SELECT in AS target, out AS source, kind, scope, required, notes FROM builder_dependency_edge WHERE type::string(out) IN $res_ids);
  LET $edges_to_here   = (SELECT out AS source, in AS target, kind, scope, required, notes FROM builder_dependency_edge WHERE type::string(in) IN $res_ids);
  LET $rels = array::union(
    (SELECT VALUE { source_id: type::string(value.source), target_id: type::string(value.target), kind: value.kind, scope: value.scope, required: value.required, notes: value.notes } FROM $edges_from_here),
    (SELECT VALUE { source_id: type::string(value.source), target_id: type::string(value.target), kind: value.kind, scope: value.scope, required: value.required, notes: value.notes } FROM $edges_to_here)
  );
  LET $spec_links = array::union($links_contains, $rels);

  LET $existing = (SELECT id FROM builder_dependency WHERE sub_module_id = $sub_module_id AND dependency_code = $code LIMIT 1)[0];
  IF $existing == NONE {
    LET $desc = 'Catalogue complet auto pour ' + (IF $row.sub_module_name != NONE THEN $row.sub_module_name ELSE 'inconnu' END);
    LET $cr = fn::builder_dependency_create_record($name, $sub_module_id, $desc, { links: $spec_links }, true, true, true, $phase, ['module_builder'], $run_id);
    IF $cr.success == true {
      UPDATE type::thing(type::string($cr.dependency.id)) SET owner_id = $sub_module_id, updated_at = time::now();
    };
    RETURN $cr;
  } ELSE {
    UPDATE type::thing($existing.id) SET spec = { links: $spec_links }, owner_id = $sub_module_id, updated_at = time::now();
    RETURN { success: true, updated: type::string($existing.id) };
  }
}
COMMENT 'Reconstruit le catalogue builder_dependency pour un sous-module spécifique'
PERMISSIONS FULL;

-- Crée un lien Module→Module à partir des codes
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_create_module_link(
  $module_from_code: string,
  $module_to_code: string,
  $kind: string,
  $scope: option<string>,
  $required: option<bool>,
  $notes: option<string>
) {
  LET $m_from = (SELECT id FROM builder_module WHERE module_code = $module_from_code LIMIT 1)[0];
  LET $m_to = (SELECT id FROM builder_module WHERE module_code = $module_to_code LIMIT 1)[0];
  IF $m_from == NONE OR $m_to == NONE { RETURN { success: false, message: 'Module source/target introuvable' }; };
  RETURN fn::builder_dependency_create_edge(type::string($m_from.id), type::string($m_to.id), $kind, $scope, $required ?? true, NONE, NONE, $notes);
}
COMMENT 'Crée une arête Module→Module (depends_on/uses/extends...)'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Crée les arêtes de composition Module→ressources (contains)
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_seed_contains_edges_for_module(
  $module_code: string,
  $scope: option<string>
) {
  LET $mod = (SELECT id FROM builder_module WHERE module_code = $module_code LIMIT 1)[0];
  IF $mod == NONE { RETURN { success: false, message: 'Module introuvable' }; };
  LET $mid = type::string($mod.id);
  LET $subs = (SELECT VALUE id FROM builder_sub_module WHERE module_id = $mod.id);

  -- Pas de lambda: on exécutera des SELECT VALUE directs pour chaque collection

  LET $t_tables = (SELECT VALUE id FROM builder_table WHERE sub_module_id IN $subs);
  LET $t_funcs  = (SELECT VALUE id FROM builder_function WHERE sub_module_id IN $subs);
  LET $t_events = (SELECT VALUE id FROM builder_event WHERE sub_module_id IN $subs);
  LET $t_analyz = (SELECT VALUE id FROM builder_analyzer WHERE sub_module_id IN $subs);
  LET $t_seq    = (SELECT VALUE id FROM builder_sequence WHERE sub_module_id IN $subs);
  LET $t_bucket = (SELECT VALUE id FROM builder_bucket WHERE sub_module_id IN $subs);
  LET $t_param  = (SELECT VALUE id FROM builder_param WHERE sub_module_id IN $subs);
  LET $t_config = (SELECT VALUE id FROM builder_config WHERE sub_module_id IN $subs);
  LET $t_api    = (SELECT VALUE id FROM builder_api WHERE sub_module_id IN $subs);
  LET $t_tpl    = (SELECT VALUE id FROM builder_template WHERE sub_module_id IN $subs);

  LET $edges_sm   = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $subs     WHERE value != NONE);
  LET $edges_tab  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_tables WHERE value != NONE);
  LET $edges_fun  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_funcs  WHERE value != NONE);
  LET $edges_evt  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_events WHERE value != NONE);
  LET $edges_ana  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_analyz WHERE value != NONE);
  LET $edges_seq  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_seq    WHERE value != NONE);
  LET $edges_bkt  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_bucket WHERE value != NONE);
  LET $edges_par  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_param  WHERE value != NONE);
  LET $edges_cfg  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_config WHERE value != NONE);
  LET $edges_api  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_api   WHERE value != NONE);
  LET $edges_tpl  = (SELECT VALUE fn::builder_dependency_create_edge($mid, type::string(value), 'contains', ($scope ?? 'structure'), true, NONE, NONE, 'seed: module contains resource') FROM $t_tpl   WHERE value != NONE);

  RETURN { success: true };
}
COMMENT 'Génère les arêtes contains: Module → {sub_modules, tables, functions, ...}'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Liste le contenu d'un module
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_list_module_contents(
  $module_code: string
) {
  LET $mod = (SELECT id FROM builder_module WHERE module_code = $module_code LIMIT 1)[0];
  IF $mod == NONE { RETURN { success: false, message: 'Module introuvable' }; };
  LET $subs = (SELECT id, sub_module_code FROM builder_sub_module WHERE module_id = $mod.id);
  LET $sub_ids = (SELECT VALUE id FROM $subs);
  RETURN {
    success: true,
    module_id: $mod.id,
    sub_modules: $subs,
    tables: (SELECT id, table_name FROM builder_table WHERE sub_module_id IN $sub_ids),
    functions: (SELECT id, function_name FROM builder_function WHERE sub_module_id IN $sub_ids),
    events: (SELECT id, event_name FROM builder_event WHERE sub_module_id IN $sub_ids),
    analyzers: (SELECT id, analyzer_name FROM builder_analyzer WHERE sub_module_id IN $sub_ids),
    sequences: (SELECT id, sequence_name FROM builder_sequence WHERE sub_module_id IN $sub_ids),
    buckets: (SELECT id, bucket_name FROM builder_bucket WHERE sub_module_id IN $sub_ids),
    params: (SELECT id, param_name FROM builder_param WHERE sub_module_id IN $sub_ids),
    configs: (SELECT id, config_name FROM builder_config WHERE sub_module_id IN $sub_ids),
    apis: (SELECT id, api_name FROM builder_api WHERE sub_module_id IN $sub_ids),
    templates: (SELECT id, template_name FROM builder_template WHERE sub_module_id IN $sub_ids)
  };
}
COMMENT 'Retourne toutes les ressources rattachées à un module'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Liste les dépendances Module↔Module
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_list_module_dependencies(
  $module_code: string
) {
  LET $mod = (SELECT id FROM builder_module WHERE module_code = $module_code LIMIT 1)[0];
  IF $mod == NONE { RETURN { success: false, message: 'Module introuvable' }; };
  LET $mid = type::string($mod.id);
  RETURN {
    success: true,
    out_to_modules: (SELECT in AS module_to, kind, scope, required, notes FROM builder_dependency_edge WHERE out = $mod.id AND string::starts_with(type::string(in), 'builder_module:')),
    in_from_modules: (SELECT out AS module_from, kind, scope, required, notes FROM builder_dependency_edge WHERE in = $mod.id AND string::starts_with(type::string(out), 'builder_module:'))
  };
}
COMMENT 'Dépendances entre modules (sortantes/entrantes)'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

-- Seed global: crée les arêtes contains pour tous les modules et
-- crée des enregistrements catalogue minimaux par sous-module
DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_seed_all_existing(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE OR string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END;
  LET $start = fn::system_log_create_record([$log_phase, 'log_function', 'log_deploy', 'log_start', 'log_initialise'], 'Start: seed global des dépendances (edges + catalogue)', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- 1) Arêtes contains pour tous les modules (uniquement ceux avec module_code valide)
  LET $mods = (SELECT VALUE module_code FROM builder_module WHERE module_code != NONE AND string::trim(module_code) != '');
  IF array::len($mods) > 0 {
    LET $seed_edges = (SELECT VALUE fn::builder_dependency_seed_contains_edges_for_module(value, 'structure') FROM $mods);
  };

  -- 2) Catalogue minimal pour tous les sous-modules (si vide)
  LET $subs = (SELECT id, sub_module_code, sub_module_name FROM builder_sub_module);
  IF array::len($subs) > 0 {
    LET $seed_catalog = (SELECT VALUE fn::builder_dependency_create_record(
      'auto_' + (
        IF value.sub_module_code != NONE
          THEN string::lowercase(string::replace(value.sub_module_code, 'sub_module_', ''))
          ELSE 'unknown'
        END
      ),
      value.id,
      'Dépendances implicites pour ' + (IF value.sub_module_name != NONE THEN value.sub_module_name ELSE 'inconnu' END),
      { links: [] },
      true, true, true,
      $phase, ['module_builder'], $run_id
    ) FROM $subs);
  };

  LET $done = fn::system_log_create_record([$log_phase, 'log_function', 'log_deploy', 'log_done', 'log_success'], 'Done: seed global des dépendances', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Peuple builder_dependency_edge et builder_dependency à partir des ressources existantes'
PERMISSIONS FULL;

LET $done = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_success'], 'Done: initialisation des actions builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise les actions (helpers) pour builder_dependency'
PERMISSIONS FULL;


