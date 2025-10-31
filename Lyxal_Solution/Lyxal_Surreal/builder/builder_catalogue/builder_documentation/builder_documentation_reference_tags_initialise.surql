-- Initialisation des tags de référence pour la section builder_documentation
DEFINE FUNCTION fn::builder_documentation_reference_tags_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `builder_documentation_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION fn::builder_documentation_reference_tags(
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $run_id = rand::uuid();
    LET $log_extra_tags = ['module_builder','sub_module_builder_catalogue', 'log_reference_tags'];

    -- Journalisation: début
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_start'], $log_extra_tags),
        'Start: création des tags de référence pour `builder_documentation`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    -- Tags de référence par Type de Documentation
    CREATE system_tag:doc_type_guide SET name = 'doc_type_guide', label = 'Doc Type: Guide', description = 'Documentation de type guide utilisateur.', color = '#3498DB', order = 400, is_protected = true;
    CREATE system_tag:doc_type_reference SET name = 'doc_type_reference', label = 'Doc Type: Reference', description = 'Documentation de type référence technique ou API.', color = '#9B59B6', order = 410, is_protected = true;
    CREATE system_tag:doc_type_tutorial SET name = 'doc_type_tutorial', label = 'Doc Type: Tutorial', description = 'Documentation de type tutoriel pas à pas.', color = '#2ECC71', order = 420, is_protected = true;

    -- Tags de référence par Audience de Documentation
    CREATE system_tag:doc_audience_developer SET name = 'doc_audience_developer', label = 'Doc Audience: Developer', description = 'Documentation destinée aux développeurs.', color = '#F1C40F', order = 500, is_protected = true;
    CREATE system_tag:doc_audience_user SET name = 'doc_audience_user', label = 'Doc Audience: User', description = 'Documentation destinée aux utilisateurs finaux.', color = '#E67E22', order = 510, is_protected = true;
    CREATE system_tag:doc_audience_admin SET name = 'doc_audience_admin', label = 'Doc Audience: Admin', description = 'Documentation destinée aux administrateurs système.', color = '#E74C3C', order = 520, is_protected = true;
    
    -- Journalisation: fin
    fn::system_log_create_record_system(
        array::union(['log_function', 'log_done', 'log_success'], $log_extra_tags),
        'Done: création des tags de référence pour `builder_documentation`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    -- Retour
    RETURN { 
      success: true, 
      run_id: $run_id, 
      parent_run_id: $parent_run_id
    };
  }
  COMMENT 'Crée les tags de référence utilisés par la section builder_documentation.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `builder_documentation_reference_tags`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Retour
  RETURN { 
    success: true, 
    run_id: $run_id,
    parent_run_id: $parent_run_id
  };
}
COMMENT 'Initialise la fonction de création des tags de référence pour builder_documentation.'
PERMISSIONS FULL;
