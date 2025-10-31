DEFINE FUNCTION IF NOT EXISTS fn::builder_template_materialize_plan_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la fonction builder_template_materialize_plan', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE FUNCTION IF NOT EXISTS fn::builder_template_materialize_plan(
  $template_id: string
) {
  LET $tid = string::trim($template_id);
  IF $tid == '' { RETURN { success: false, message: 'template_id manquant' }; };

  -- Existence du template
  LET $exist = fn::system_validate_existing_bulk([
    { table: 'builder_template', field: 'id', value: $tid, label: 'Template' }
  ]);
  IF $exist.total_missing > 0 { RETURN { success: false, message: 'Template introuvable', missing: $exist.missing }; };

  -- Chargement du template
  LET $tpl = (SELECT id, template_name, template_code, module_id, spec FROM type::thing($tid) LIMIT 1)[0];
  LET $spec = IF $tpl.spec != NONE AND type::is::object($tpl.spec) THEN $tpl.spec ELSE {} END;

  -- Includes: liste de noms de tags (classification) à prendre comme graines
  LET $includes = IF type::is::array($spec.includes) THEN $spec.includes ELSE [] END;
  LET $includes_clean = array::filter($includes, |$n| { type::is::string($n) AND string::trim($n) != '' });

  -- Résolution des tags → ids
  LET $tags_rows = SELECT id, name FROM system_tag WHERE name INSIDE $includes_clean;
  LET $tag_ids = array::map($tags_rows, |$row| { $row.id });

  -- Helper: sélection des records par tags
  LET $sel_by_tags = function($table) {
    RETURN SELECT id, * FROM type::table($table)
    WHERE array::len($tag_ids) == 0 OR array::any(tags ?? [], |$t| { $t INSIDE $tag_ids });
  };

  -- Sélection des graines par type
  LET $modules     = $sel_by_tags('builder_module');
  LET $submodules  = $sel_by_tags('builder_sub_module');
  LET $tables      = $sel_by_tags('builder_table');
  LET $functions   = $sel_by_tags('builder_function');
  LET $analyzers   = $sel_by_tags('builder_analyzer');
  LET $events      = $sel_by_tags('builder_event');
  LET $sequences   = $sel_by_tags('builder_sequence');
  LET $buckets     = $sel_by_tags('builder_bucket');
  LET $params      = $sel_by_tags('builder_param');
  LET $configs     = $sel_by_tags('builder_config');
  LET $apis        = $sel_by_tags('builder_api');

  -- Ensemble des seeds (ids)
  LET $seed_ids = array::map(array::union(
    array::map($modules,    |$r| { $r.id }),
    array::map($submodules, |$r| { $r.id }),
    array::map($tables,     |$r| { $r.id }),
    array::map($functions,  |$r| { $r.id }),
    array::map($analyzers,  |$r| { $r.id }),
    array::map($events,     |$r| { $r.id }),
    array::map($sequences,  |$r| { $r.id }),
    array::map($buckets,    |$r| { $r.id }),
    array::map($params,     |$r| { $r.id }),
    array::map($configs,    |$r| { $r.id })
  ), |$x| { $x });

  -- Dépendances directes (out = seeds)
  LET $edges_out = SELECT id, out, in, kind, scope, required, since_version, until_version, notes
                   FROM builder_dependency WHERE array::len($seed_ids) > 0 AND out INSIDE $seed_ids;
  -- Dépendances inverses (in = seeds)
  LET $edges_in  = SELECT id, out, in, kind, scope, required, since_version, until_version, notes
                   FROM builder_dependency WHERE array::len($seed_ids) > 0 AND in INSIDE $seed_ids;

  RETURN {
    success: true,
    template: { id: $tpl.id, name: $tpl.template_name, code: $tpl.template_code },
    includes: $includes_clean,
    tag_ids: array::map($tags_rows, |$r| { { id: $r.id, name: $r.name } }),
    counts: {
      modules: array::len($modules), submodules: array::len($submodules), tables: array::len($tables),
      functions: array::len($functions), analyzers: array::len($analyzers), events: array::len($events),
      sequences: array::len($sequences), buckets: array::len($buckets), params: array::len($params), configs: array::len($configs), apis: array::len($apis)
    },
    items: {
      modules: $modules, submodules: $submodules, tables: $tables, functions: $functions, analyzers: $analyzers,
      events: $events, sequences: $sequences, buckets: $buckets, params: $params, configs: $configs, apis: $apis
    },
    dependencies: {
      uses: $edges_out,
      used_by: $edges_in
    }
  };
}
COMMENT 'Matérialise un plan (liste des items + dépendances) à partir d\'un template et de ses tags inclus'
PERMISSIONS WHERE $auth.permissions CONTAINS 'system';

  -- Référencer les fonctions dans builder_function (initialise + record)
  LET $sm_tpl = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_template' LIMIT 1)[0];
  IF $sm_tpl != NONE {
    LET $ref_init = fn::builder_function_create_record('builder_template_materialize_plan_initialise', $sm_tpl.id, 'Initialise la fonction de matérialisation de plan', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
    LET $ref_fn = fn::builder_function_create_record('builder_template_materialize_plan', $sm_tpl.id, 'Matérialise un plan à partir d\'un template', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  };

  LET $done = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_success'], 'Done: création de la fonction builder_template_materialize_plan', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de matérialisation de template'
PERMISSIONS FULL;


