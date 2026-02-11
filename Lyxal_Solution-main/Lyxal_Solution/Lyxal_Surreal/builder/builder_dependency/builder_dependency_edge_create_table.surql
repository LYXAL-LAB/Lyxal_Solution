DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_edge_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_dependency_edge', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_dependency_edge TYPE RELATION SCHEMAFULL
COMMENT 'Graphe des dépendances entre ressources builder_* (edges)'
PERMISSIONS FULL;

-- Champs métier de l'arête (en plus de in/out)
DEFINE FIELD kind ON builder_dependency_edge TYPE string
COMMENT 'Type de lien (uses, extends, provides, etc.)';

DEFINE FIELD scope ON builder_dependency_edge TYPE option<string>
COMMENT 'Portée de la dépendance (deploy, runtime, test, doc...)';

DEFINE FIELD required ON builder_dependency_edge TYPE bool DEFAULT true
COMMENT 'Lien obligatoire (true) ou facultatif (false)';

DEFINE FIELD since_version ON builder_dependency_edge TYPE option<string>
COMMENT 'Version à partir de laquelle la dépendance est requise';

DEFINE FIELD until_version ON builder_dependency_edge TYPE option<string>
COMMENT 'Version jusqu\'à laquelle la dépendance s\'applique';

DEFINE FIELD notes ON builder_dependency_edge TYPE option<string>
COMMENT 'Commentaires libres';

DEFINE FIELD created_at ON builder_dependency_edge TYPE datetime DEFAULT time::now()
COMMENT 'Date de création du lien';

-- Index
DEFINE INDEX idx_builder_dependency_edge_out ON builder_dependency_edge FIELDS out;
DEFINE INDEX idx_builder_dependency_edge_in  ON builder_dependency_edge FIELDS in;
DEFINE INDEX idx_builder_dependency_edge_kind ON builder_dependency_edge FIELDS kind;
DEFINE INDEX idx_builder_dependency_edge_uni ON builder_dependency_edge FIELDS out, in, kind UNIQUE;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_dependency' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_dependency introuvable pour builder_table (edge)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_dependency_edge', $sm.id, 'Arêtes du graphe de dépendances builder_*', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_dependency_edge', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_dependency_edge_create_table_initialise', $sm.id, 'Initialise la création de la table builder_dependency_edge', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_dependency_edge_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_dependency_edge', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_dependency_edge' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table d'arêtes builder_dependency_edge"
PERMISSIONS FULL;


