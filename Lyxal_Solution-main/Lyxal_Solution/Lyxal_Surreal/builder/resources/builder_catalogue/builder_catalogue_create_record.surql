DEFINE FUNCTION fn::builder_catalogue_create_record(
    $name: string, -- nom de l'élément (minuscule, underscores conservés)
    $type: string, -- module,table,function,param,config,bucket,template,event,sequence..
    $description: string, -- description de l'élément (brève)
    $langue_id: string, -- langue de l'user par défaut
    $tags: option<array<string>>, -- tags de classification de l'élément
    $parent_id: option<string>, -- id du parent de l'élément
    $deploy_function: option<string>, -- version de l'élément
    $metadata: option<object>, -- données libres pour extension future (utilisé par l'IA, le builder, ou plugins)
    $documentation: option<array>, -- documentations de l'élément
    $parent_run_id: option<string>
  ) {
    -- Paramètres par défaut
    LET $metadata = $metadata OR {};
    LET $tags = $tags OR [];
    LET $documentation = $documentation OR [];
    LET $deploy_function = $deploy_function OR NONE;
    LET $parent_id = $parent_id OR NONE;
    LET $parent_run_id = $parent_run_id OR NONE;  
    LET $run_id = rand::uuid();


   

    -- Name
    ----On vérifie que le nom est valide
    IF $name = NONE OR string::len(string::trim($name)) = 0 {
      LET $error_result = fn::system_error_code_get_return('NAME_REQUIRED', $langue_id, 
      $run_id, { name: $name });
      LET $_log = fn::builder_catalogue_log('create', $error_result, $user_id, $langue_id);
      RETURN $error_result;
    };

    -- Langue par défaut
    ----On récupère l'id de la langue par défaut
    LET $langue_id = type::thing('i18n_language', $langue_id);
    LET $langue_ref = SELECT * FROM i18n_language WHERE id = $langue_id LIMIT 1;
    ----On vérifie que la langue existe
    IF $langue_ref = NONE {
      LET $error_result = fn::system_error_code_get_return('LANGUE_NOT_FOUND', $langue_id, 
      $run_id, { langue_id: $langue_id });
      LET $_log = fn::builder_catalogue_log('create', $error_result, $user_id, $langue_id);
      RETURN $error_result;
    };

    -- Nettoyage du nom
    LET $clean_name = string::lowercase(string::trim($name));


    -- création du code de l'élément
    LET $generated_code = string::lowercase(string::trim($type + '_' + $name));
    -- création de l'id de l'élément
    LET $generated_id = type::thing('builder_catalogue', $generated_code);
    -- création de l'id de la fonction de déploiement
    LET $generated_deploy_function = 
    IF $deploy_function != NONE {
     type::thing('builder_catalogue', $deploy_function) }
    ELSE {NONE };

    -- Cet élément détient un parent
    IF $parent_id != NONE {
      LET $parent_item = (SELECT * FROM builder_catalogue 
      WHERE id = type::thing('builder_catalogue', $parent_id) LIMIT 1)[0];
      IF $parent_item = NONE {
      LET $error_result = fn::system_error_code_get_return('PARENT_NOT_FOUND', $langue_id, 
      $run_id, { parent_id: $parent_id, name: $clean_name });
      LET $_log = fn::builder_catalogue_log('create', $error_result, $user_id, $langue_id);
      RETURN $error_result;
      };
    };
    -- vérification que le parent existe
    LET $generated_parent_id = IF $parent_id != NONE 
    THEN type::thing('builder_catalogue', $parent_id)
    ELSE NONE 
    END;
    -- création de l'id du personnal_tag
    LET $generated_personnal_tag_id = type::thing('system_tag', $type + '_' + $name);

    -- Création de l'élément dans la table builder_catalogue
    LET $new_item = CREATE $generated_id SET
      name             = $name,
      code             = $generated_code,
      description      = $description,
      personnal_tag    = $generated_personnal_tag_id,
      version          = $version,
      metadata         = $metadata,
      deploy_function  = $generated_deploy_function,
      parent           = $generated_parent_id;

    -- Création du tag system associé dans system_tag
    LET $generated_tag_system_name = $type + '_' + $name;
    LET $generated_tag_system_label = string::uppercase(string::slice($type, 0, 1)) + string::slice($type, 1) + ' - ' + $name;
    LET $generated_tag_system_description = 'Tag personnalisépour l élément de catalogue ' + $name;
    fn::system_tag_create_record_system(
      $generated_tag_system_name, $generated_tag_system_label, $generated_tag_system_description,
      NONE, 0, true, 
      ['log_data_reference'], -- $log_extra_tags
      $run_id                 -- $parent_run_id
    );

    -- Lier automatiquement le tag de type
    LET $type_tag_id = 'builder_type_' + $type;
    fn::builder_tags_add_record($new_item.id, 'builder_catalogue', $type_tag_id, $run_id);

    -- Ajout des tags manuels via la relation générique builder_tags
    IF array::len($tags) > 0 {
      LET $tag_results = array::map($tags, function($tag_id) {
        RETURN fn::builder_tags_add_record($new_item.id, 'builder_catalogue', $tag_id, $run_id);
      });
    };

    -- Lier la documentation si elle est fournie
    IF array::len($documentation) > 0 {
      LET $doc_results = array::map($documentation, function($doc) {
        RETURN fn::builder_documentation_add_record(
          $new_item.id,
          'builder_catalogue',
          $doc.to_id,
          $doc.lang_id,
          $doc.version,
          $doc.tags_documentation,
          $run_id
        );
      });
    };

    -- Journalisation: fin
    fn::system_log_create_record_system(
        array::union(['log_data_reference', 'log_catalogue', 'log_create', 'log_done', 'log_success'], $local_log_extra_tags),
        'Done: création de l élément de catalogue `' + $name + '`',
        { run_id: $run_id, parent_run_id: $parent_run_id, result: $new_item }
    );

    RETURN {
      success: true,
      run_id: $run_id,
      parent_run_id: $parent_run_id,
      data: $new_item
    };
  }
  COMMENT "Crée un enregistrement dans la table builder_catalogue"
  PERMISSIONS FULL;
