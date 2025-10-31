DEFINE FUNCTION fn::builder_catalogue_get_records(
      $names: option<array<string>>,
      $tags: option<array<string>>,
      $parent_id: option<string>
  ) {
      -- On prépare les filtres : s'ils sont absents ou vides, on les considère comme NONE.
      LET $name_filter = IF $names AND array::len($names) > 0 THEN $names ELSE NONE END;
      LET $tags_filter = IF $tags AND array::len($tags) > 0 THEN $tags ELSE NONE END;
      LET $parent_filter = IF $parent_id != NONE THEN type::thing('builder_catalogue', $parent_id) ELSE NONE END;

      -- On pré-calcule la liste des record IDs pour les tags
      LET $tag_records_filter = IF $tags_filter != NONE THEN array::map($tags_filter, function($tag_id) {
          RETURN type::thing('system_tag', $tag_id);
      }) ELSE NONE END;

      -- --- Approche par Intersection ---

      -- Étape 1 : Récupérer les éléments correspondant au filtre de nom.
      LET $items_par_nom = (
          SELECT * FROM builder_catalogue 
          WHERE $name_filter IS NONE OR name IN $name_filter
      );

      -- Étape 2 : Récupérer les éléments correspondant au filtre de tags.
      LET $items_par_tag = (
          SELECT * FROM builder_catalogue 
          WHERE $tag_records_filter IS NONE OR ->builder_tags->system_tag CONTAINS $tag_records_filter
      );

      -- Étape 3 : Récupérer les éléments correspondant au filtre de parent.
      LET $items_par_parent = (
          SELECT * FROM builder_catalogue
          WHERE $parent_filter IS NONE OR parent = $parent_filter
      );

      -- Étape 4 : Retourner l'intersection des trois listes.
      RETURN array::intersect(array::intersect($items_par_nom, $items_par_tag), $items_par_parent);
  }
  COMMENT 'Récupère les éléments du catalogue en utilisant une méthode d\'intersection de filtres.'
  PERMISSIONS FULL;
