DEFINE FUNCTION fn::builder_catalogue_get_records_by_type(
      $type: string,
      $tags: option<array<string>>
  ) {
      -- Paramètres par défaut
      LET $tags = $tags OR [];
      
      -- Construit le tag de type à partir du paramètre $type
      LET $type_tag = 'builder_type_' + $type;
      
      -- Ajoute le tag de type à la liste des tags de filtre
      LET $all_tags = array::union($tags, [$type_tag]);
      
      -- Appelle la fonction de recherche principale avec la liste de tags complète
      RETURN fn::builder_catalogue_get_records(NONE, $all_tags, NONE);
  }
  COMMENT 'Récupère les éléments du catalogue par type et tags additionnels.'
  PERMISSIONS FULL;
