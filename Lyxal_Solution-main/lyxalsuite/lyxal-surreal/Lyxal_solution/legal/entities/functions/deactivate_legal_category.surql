-- =============================================================================
-- FONCTION: fn::deactivate_legal_category
-- =============================================================================
-- DESCRIPTION: Désactive une catégorie juridique et optionnellement ses enfants
-- PARAMETRES:
--   $id: Identifiant de la catégorie à désactiver (ex: legal_category:abc123)
--   $deactivate_children: Désactiver aussi les catégories enfants (défaut: false)
-- RETOUR: Enregistrement de la catégorie désactivée avec nombre d'enfants affectés
-- USAGE:
--   -- Désactiver seulement la catégorie:
--   RETURN fn::deactivate_legal_category(legal_category:abc123, false);
--   -- Désactiver la catégorie et tous ses enfants:
--   RETURN fn::deactivate_legal_category(legal_category:abc123, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::deactivate_legal_category(
  $id: record<legal_category>,
  $deactivate_children: option<bool>
) {
  
  -- Vérifier que l'enregistrement existe
  LET $existing_records = SELECT * FROM legal_category WHERE id = $id;
  
  -- Si l'enregistrement n'existe pas, retourner NULL
  IF count($existing_records) = 0 {
    RETURN NULL;
  };
  
  LET $existing = $existing_records[0];
  
  -- Si déjà désactivé, retourner l'enregistrement tel quel
  IF $existing.active = false {
    RETURN {
      category: $existing,
      children_affected: 0,
      message: "Catégorie déjà désactivée"
    };
  };
  
  -- Désactiver la catégorie principale
  UPDATE $id SET
    active = false,
    updated_on = time::now(),
    updated_by = 'system';
  
  -- Gérer les enfants si demandé
  LET $children_affected = IF $deactivate_children IS NULL OR $deactivate_children = false {
    0
  } ELSE {
    -- Récupérer tous les enfants directs et indirects
    LET $direct_children = SELECT * FROM legal_category WHERE parent_category = $id AND active = true;
    LET $all_children = $direct_children;
    
    -- Ajouter les petits-enfants (niveau 2)
    FOR $child IN $direct_children {
      LET $grandchildren = SELECT * FROM legal_category WHERE parent_category = $child.id AND active = true;
      LET $all_children = array::union($all_children, $grandchildren);
    };
    
    -- Désactiver tous les enfants
    FOR $child IN $all_children {
      UPDATE $child.id SET
        active = false,
        updated_on = time::now(),
        updated_by = 'system';
    };
    
    count($all_children)
  };
  
  -- Récupérer la catégorie mise à jour
  LET $updated_category = (SELECT * FROM legal_category WHERE id = $id)[0];
  
  -- Retourner le résultat avec statistiques
  RETURN {
    category: $updated_category,
    children_affected: $children_affected,
    message: IF $children_affected > 0 {
      "Catégorie et " + $children_affected + " enfants désactivés"
    } ELSE {
      "Catégorie désactivée"
    }
  };
} COMMENT "Désactive une catégorie juridique avec option pour désactiver récursivement tous ses enfants. Retourne la catégorie mise à jour avec le nombre d'enfants affectés." 