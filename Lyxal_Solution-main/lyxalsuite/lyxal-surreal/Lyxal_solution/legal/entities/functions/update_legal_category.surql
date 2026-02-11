-- =============================================================================
-- FONCTION: fn::update_legal_category
-- =============================================================================
-- DESCRIPTION: Met à jour une catégorie juridique existante avec recalcul automatique du level
-- PARAMETRES:
--   $id: Identifiant de la catégorie à mettre à jour (ex: legal_category:abc123)
--   $name: Nouveau nom complet de la catégorie (optionnel)
--   $code: Nouveau code court de la catégorie (optionnel)
--   $description: Nouvelle description détaillée (optionnel)
--   $parent_category: Nouvelle catégorie parent (optionnel, NONE pour racine)
--   $active: Nouveau statut actif/inactif (optionnel)
-- RETOUR: Enregistrement de la catégorie mise à jour avec level recalculé si nécessaire
-- USAGE:
--   -- Mettre à jour seulement le nom:
--   RETURN fn::update_legal_category(legal_category:abc123, 'Nouveau Nom', NULL, NULL, NULL, NULL);
--   -- Changer le parent (recalcule automatiquement le level):
--   RETURN fn::update_legal_category(legal_category:abc123, NULL, NULL, NULL, legal_category:parent123, NULL);
--   -- Mettre à jour plusieurs champs:
--   RETURN fn::update_legal_category(legal_category:abc123, 'Nouveau Nom', 'NEW_CODE', 'Description', NONE, true);
-- 
-- UTILISATION AVEC LES TABLES:
--   -- Mettre à jour via SELECT:
--   SELECT * FROM legal_category WHERE id = fn::update_legal_category(legal_category:abc123, 'Nom', NULL, NULL, NULL, NULL).id;
--
--   -- Utiliser dans une transaction:
--   BEGIN TRANSACTION;
--     LET $updated = fn::update_legal_category(legal_category:abc123, 'Nouveau Nom', NULL, NULL, NULL, NULL);
--     -- Autres opérations...
--   COMMIT TRANSACTION;
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_legal_category(
  $id: record<legal_category>,
  $name: option<string>,
  $code: option<string>,
  $description: option<string>,
  $parent_category: option<record<legal_category>>,
  $active: option<bool>
) {
  
  -- Vérifier que l'enregistrement existe
  LET $existing_records = SELECT * FROM legal_category WHERE id = $id;
  
  -- Si l'enregistrement n'existe pas, retourner erreur
  IF count($existing_records) = 0 {
    RETURN {
      success: false,
      error: "CATEGORIE_INTROUVABLE",
      message: "La catégorie à mettre à jour n'existe pas",
      category_id: $id
    };
  };
  
  LET $existing = $existing_records[0];
  
  -- Préparer les nouvelles valeurs (garder les anciennes si NULL ou NONE)
  LET $new_name = IF $name IS NULL OR $name IS NONE { $existing.name } ELSE { $name };
  LET $new_code = IF $code IS NULL OR $code IS NONE { $existing.code } ELSE { $code };
  LET $new_description = IF $description IS NULL OR $description IS NONE { $existing.description } ELSE { $description };
  LET $new_active = IF $active IS NULL OR $active IS NONE { $existing.active } ELSE { $active };
  
  -- Gérer le parent_category 
  LET $parent_changed = $parent_category IS NOT NULL AND $parent_category IS NOT NONE;
  LET $new_parent_category = IF $parent_changed { 
    $parent_category 
  } ELSE { 
    $existing.parent_category 
  };
  
  -- Recalculer le level si le parent a changé
  LET $new_level = IF !$parent_changed {
    $existing.level
  } ELSE {
    IF $new_parent_category IS NULL OR $new_parent_category IS NONE {
      1
    } ELSE {
      LET $parent_records = SELECT level FROM legal_category WHERE id = $new_parent_category LIMIT 1;
      IF count($parent_records) > 0 AND $parent_records[0].level IS NOT NULL {
        $parent_records[0].level + 1
      } ELSE {
        1
      }
    }
  };
  
  -- Vérifier que $new_level n'est pas NONE
  LET $final_level = IF $new_level IS NULL OR $new_level IS NONE { 1 } ELSE { $new_level };
  
  -- Vérification anti-doublon (nom + parent) - exclure l'enregistrement actuel
  -- Vérifier TOUJOURS si le nom ou le parent change
  IF ($name IS NOT NULL AND $name IS NOT NONE) OR ($parent_category IS NOT NULL AND $parent_category IS NOT NONE) {
    LET $duplicate_check = SELECT * FROM legal_category 
      WHERE name = $new_name 
      AND parent_category = $new_parent_category 
      AND id != $id;
    
    IF count($duplicate_check) > 0 {
      RETURN {
        success: false,
        error: "DOUBLON_DETECTE",
        message: "Une catégorie avec ce nom existe déjà sous ce parent",
        duplicate_name: $new_name,
        existing_category: $duplicate_check[0],
        current_id: $id
      };
    };
  };
  
  -- Mettre à jour l'enregistrement
  UPDATE $id SET
    name = $new_name,
    code = $new_code,
    description = $new_description,
    parent_category = $new_parent_category,
    level = $final_level,
    active = $new_active,
    updated_on = time::now(),
    updated_by = 'system';
  
  -- Si le level a changé, mettre à jour récursivement tous les enfants
  IF $parent_changed AND $final_level != $existing.level {
    LET $children = SELECT * FROM legal_category WHERE parent_category = $id;
    
    FOR $child IN $children {
      fn::update_legal_category($child.id, NULL, NULL, NULL, $id, NULL);
    };
  };
  
  -- Retourner l'enregistrement mis à jour avec format cohérent
  LET $updated_category = (SELECT * FROM legal_category WHERE id = $id)[0];
  RETURN {
    success: true,
    data: $updated_category,
    message: "Catégorie mise à jour avec succès",
    updated_fields: {
      name_changed: $name IS NOT NULL AND $name IS NOT NONE,
      parent_changed: $parent_changed,
      level_changed: $final_level != $existing.level
    }
  };
} COMMENT "Met à jour une catégorie juridique existante avec recalcul automatique du level hiérarchique si le parent change. Empêche les doublons (même nom sous même parent) avec vérification anti-doublon. Gère la mise à jour récursive des enfants si nécessaire. Permet la mise à jour partielle (champs NULL ignorés). Retourne un objet avec success, data et message."

-- =============================================================================
-- MÉTHODE JAVASCRIPT POUR INTERFACE UTILISATEUR REACT
-- =============================================================================
-- Cette fonction peut être utilisée dans React pour mettre à jour une catégorie via un bouton
-- 
-- EXEMPLE D'UTILISATION DANS REACT:
-- 
-- async function updateLegalCategory(id, formData) {
--   try {
--     const result = await db.query(`
--       RETURN fn::update_legal_category(
--         ${id},
--         ${formData.name ? `'${formData.name}'` : 'NULL'},
--         ${formData.code ? `'${formData.code}'` : 'NULL'},
--         ${formData.description ? `'${formData.description}'` : 'NULL'},
--         ${formData.parentId ? formData.parentId : 'NULL'},
--         ${formData.active !== undefined ? formData.active : 'NULL'}
--       )
--     `);
--     
--     if (result[0]) {
--       console.log('✅ Catégorie mise à jour:', result[0]);
--       return {
--         success: true,
--         data: result[0],
--         message: `Catégorie "${result[0].name}" mise à jour avec succès (Level ${result[0].level})`
--       };
--     }
--   } catch (error) {
--     console.error('❌ Erreur mise à jour catégorie:', error);
--     return {
--       success: false,
--       error: error.message,
--       message: 'Erreur lors de la mise à jour de la catégorie'
--     };
--   }
-- }
-- 
-- EXEMPLE COMPOSANT REACT AVEC DAISYUI:
-- 
-- function EditLegalCategoryForm({ categoryId, initialData, onSuccess }) {
--   const [formData, setFormData] = useState({
--     name: initialData?.name || '',
--     code: initialData?.code || '',
--     description: initialData?.description || '',
--     parentId: initialData?.parent_category || null,
--     active: initialData?.active ?? true
--   });
--   const [loading, setLoading] = useState(false);
--   const { db } = useSurrealDB();
-- 
--   const handleSubmit = async (e) => {
--     e.preventDefault();
--     setLoading(true);
--     
--     try {
--       const result = await updateLegalCategory(categoryId, formData);
--       
--       if (result.success) {
--         toast.success(result.message);
--         onSuccess?.(result.data);
--       } else {
--         toast.error(result.message);
--       }
--     } finally {
--       setLoading(false);
--     }
--   };
-- 
--   return (
--     <div className="card w-96 bg-base-100 shadow-xl">
--       <div className="card-body">
--         <h2 className="card-title">Modifier Catégorie Juridique</h2>
--         
--         <form onSubmit={handleSubmit} className="space-y-4">
--           <div className="form-control">
--             <label className="label">
--               <span className="label-text">Nom</span>
--             </label>
--             <input 
--               type="text" 
--               className="input input-bordered" 
--               value={formData.name}
--               onChange={(e) => setFormData({...formData, name: e.target.value})}
--             />
--           </div>
-- 
--           <div className="form-control">
--             <label className="label">
--               <span className="label-text">Code</span>
--             </label>
--             <input 
--               type="text" 
--               className="input input-bordered" 
--               value={formData.code}
--               onChange={(e) => setFormData({...formData, code: e.target.value})}
--             />
--           </div>
-- 
--           <div className="form-control">
--             <label className="label">
--               <span className="label-text">Statut</span>
--             </label>
--             <input 
--               type="checkbox" 
--               className="toggle toggle-primary" 
--               checked={formData.active}
--               onChange={(e) => setFormData({...formData, active: e.target.checked})}
--             />
--           </div>
-- 
--           <div className="card-actions justify-end">
--             <button 
--               type="submit" 
--               className={`btn btn-primary ${loading ? 'loading' : ''}`}
--               disabled={loading}
--             >
--               {loading ? 'Mise à jour...' : 'Mettre à jour'}
--             </button>
--           </div>
--         </form>
--       </div>
--     </div>
--   );
-- }
-- ============================================================================= 