-- Initialisation de la fonction helper pour construire la clause WHERE pour la recherche de documentation
DEFINE FUNCTION fn::builder_documentation_build_where_clause_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_documentation_build_where_clause`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale
  DEFINE FUNCTION fn::builder_documentation_build_where_clause(
    $filters: object
  ) {
    LET $where_clauses = [];

    IF $filters.from != NONE {
      LET $where_clauses = array::push($where_clauses, "from = " + type::string($filters.from));
    };

    IF $filters.to != NONE {
      LET $where_clauses = array::push($where_clauses, "to = " + type::string($filters.to));
    };

    IF $filters.lang != NONE {
      LET $where_clauses = array::push($where_clauses, "lang = " + type::string($filters.lang));
    };
    
    IF $filters.version != NONE {
      LET $where_clauses = array::push($where_clauses, "version = '" + $filters.version + "'");
    };

    IF array::len($where_clauses) > 0 {
        RETURN "WHERE " + string::join(" AND ", $where_clauses);
    } ELSE {
        RETURN "";
    }
  }
  COMMENT "Construit une clause WHERE pour la table builder_documentation à partir d'un objet de filtres."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_documentation_build_where_clause`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction helper pour construire la clause WHERE pour la recherche de documentation."
PERMISSIONS FULL;
