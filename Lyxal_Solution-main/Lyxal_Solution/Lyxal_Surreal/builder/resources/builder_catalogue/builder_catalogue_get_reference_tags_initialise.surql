DEFINE FUNCTION fn::builder_catalogue_get_reference_tags(
      $prefix: option<string>
  ) {
      LET $tags = (
          SELECT * FROM system_tag 
          WHERE ($prefix IS NONE OR string::starts_with(name, $prefix))
          ORDER BY order ASC
      );
      
      RETURN $tags;
  }
  COMMENT 'Récupère les tags de référence du catalogue, avec un filtre optionnel par préfixe.'
  PERMISSIONS FULL;
