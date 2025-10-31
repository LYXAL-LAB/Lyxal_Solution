-- =============================================================================
-- FONCTION: fn::delete_legal_category
-- =============================================================================
-- DESCRIPTION: Supprime une catégorie juridique avec vérifications de sécurité
-- PARAMETRES:
--   $id: Identifiant de la catégorie à supprimer (ex: legal_category:abc123)
--   $force_delete_children: Supprimer aussi les catégories enfants (défaut: false)
--   $confirm_deletion: Confirmation explicite de suppression (sécurité)
-- RETOUR: Résultat de la suppression avec statistiques
-- USAGE:
--   -- Supprimer seulement si pas d'enfants:
--   RETURN fn::delete_legal_category(legal_category:abc123, false, true);
--   -- Supprimer avec tous les enfants (ATTENTION):
--   RETURN fn::delete_legal_category(legal_category:abc123, true, true);
-- SÉCURITÉ: Nécessite confirm_deletion = true pour éviter les suppressions accidentelles
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::delete_legal_category(
  $id: record<legal_category>,
  $force_delete_children: option<bool>,
  $confirm_deletion: bool
) {
  
  -- Vérification de sécurité obligatoire
  IF $confirm_deletion != true {
    RETURN {
      success: false,
      error: "SÉCURITÉ: confirm_deletion doit être true pour supprimer",
      message: "Suppression refusée - confirmation requise"
    };
  };
  
  -- Vérifier que l'enregistrement existe
  LET $existing_records = SELECT * FROM legal_category WHERE id = $id;
  
  -- Si l'enregistrement n'existe pas, retourner erreur
  IF count($existing_records) = 0 {
    RETURN {
      success: false,
      error: "Catégorie introuvable",
      message: "La catégorie à supprimer n'existe pas"
    };
  };
  
  LET $existing = $existing_records[0];
  
  -- Vérifier s'il y a des enfants
  LET $children = SELECT * FROM legal_category WHERE parent_category = $id;
  LET $children_count = count($children);
  
  -- Si il y a des enfants et qu'on ne force pas la suppression
  IF $children_count > 0 AND ($force_delete_children IS NULL OR $force_delete_children = false) {
    RETURN {
      success: false,
      error: "Catégorie a des enfants",
      message: "Impossible de supprimer - " + $children_count + " catégories enfants existent. Utilisez force_delete_children=true pour forcer.",
      children_count: $children_count,
      children: $children
    };
  };
  
  -- Supprimer récursivement tous les enfants si demandé
  LET $total_deleted = IF $force_delete_children = true AND $children_count > 0 {
    -- Récupérer tous les enfants directs et indirects
    LET $direct_children = SELECT * FROM legal_category WHERE parent_category = $id ORDER BY level DESC;
    LET $all_children = $direct_children;
    
    -- Ajouter les petits-enfants (niveau 2) - du plus profond au plus superficiel
    FOR $child IN $direct_children {
      LET $grandchildren = SELECT * FROM legal_category WHERE parent_category = $child.id ORDER BY level DESC;
      LET $all_children = array::union($all_children, $grandchildren);
    };
    
    -- Supprimer tous les enfants (du plus profond au plus superficiel)
    FOR $child IN $all_children {
      DELETE $child.id;
    };
    
    count($all_children)
  } ELSE {
    0
  };
  
  -- Supprimer la catégorie principale
  DELETE $id;
  
  -- Retourner le résultat de la suppression
  RETURN {
    success: true,
    deleted_category: $existing,
    children_deleted: $total_deleted,
    message: IF $total_deleted > 0 {
      "Catégorie '" + $existing.name + "' et " + $total_deleted + " enfants supprimés"
    } ELSE {
      "Catégorie '" + $existing.name + "' supprimée"
    }
  };
} COMMENT "Supprime une catégorie juridique avec vérifications de sécurité. Peut supprimer récursivement tous les enfants si force_delete_children=true. Nécessite une confirmation explicite pour éviter les suppressions accidentelles." 