-- Initialisation de la fonction JavaScript de recherche de documentation
DEFINE FUNCTION fn::builder_documentation_get_records_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'function_query', 'javascript_function'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction JavaScript `builder_documentation_get_records`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Définition de la fonction principale en JavaScript
  DEFINE FUNCTION fn::builder_documentation_get_records(
    $filters: object
  )  {
    RETURN  function() {
      // Appeler la fonction helper pour construire la clause WHERE
      const where_clause = await surrealdb.fn('builder_documentation_build_where_clause', [$filters]);
      
      // Construire la requête finale
      let query = `SELECT * FROM builder_documentation ${where_clause} ORDER BY added_at DESC;`;
      
      // Exécuter la requête et retourner le résultat
      return await surrealdb.query(query);
    }
  }
  COMMENT "Exécute une requête pour récupérer les enregistrements de documentation en utilisant un helper pour la clause WHERE."
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction JavaScript `builder_documentation_get_records`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT "Initialise la fonction JavaScript de recherche de documentation."
PERMISSIONS FULL;
