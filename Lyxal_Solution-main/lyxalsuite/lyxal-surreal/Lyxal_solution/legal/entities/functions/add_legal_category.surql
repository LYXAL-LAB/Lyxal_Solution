 -- =============================================================================
-- MODULE LEGAL - ENTITÉS JURIDIQUES
-- =============================================================================

-- =============================================================================
-- FONCTIONS UTILITAIRES POUR LES CATÉGORIES ET FORMES JURIDIQUES
-- =============================================================================
-- =============================================================================
      -- FONCTION: fn::add_legal_category
-- =============================================================================
      -- DESCRIPTION: Crée une nouvelle catégorie juridique avec calcul automatique du level
      -- PARAMETRES:
      --   $name: Nom complet de la catégorie (ex: "Société à Responsabilité Limitée")
      --   $code: Code court de la catégorie (ex: "SARL")
      --   $description: Description détaillée de la catégorie
      --   $parent_category: Catégorie parent (NONE pour une catégorie racine)
      -- RETOUR: Enregistrement de la catégorie créée avec ID généré automatiquement et level calculé
      -- NOTE: Le tri se fait  côté client avec JavaScript 
      -- USAGE:
      --   -- Créer une catégorie racine:
      --   RETURN fn::add_legal_category('Commercial', 'COM', 'Entreprises commerciales', NONE);
      --   -- Créer une sous-catégorie:
      --   RETURN fn::add_legal_category('SARL', 'SARL', 'Société à responsabilité limitée', legal_category:commercial);
      -- 
      -- UTILISATION AVEC LES TABLES:
      --   -- Insérer plusieurs catégories en une fois:
      --   INSERT INTO legal_category (
      --     SELECT * FROM [
      --       fn::add_legal_category('Commercial', 'COM', 'Entreprises commerciales', NONE),
      --       fn::add_legal_category('SARL', 'SARL', 'Société à responsabilité limitée', legal_category:commercial)
      --     ]
      --   );
      --
      --   -- Utiliser dans une requête SELECT:
      --   SELECT * FROM legal_category WHERE id = fn::add_legal_category(...).id;
      --
      --   -- Utiliser dans une transaction:
      --   BEGIN TRANSACTION;
      --     LET $parent = fn::add_legal_category('Commercial', 'COM', 'Entreprises commerciales', NONE);
      --     LET $child = fn::add_legal_category('SARL', 'SARL', 'Société à responsabilité limitée', $parent.id);
      --   COMMIT TRANSACTION;
      -- =============================================================================
      
      DEFINE FUNCTION OVERWRITE fn::add_legal_category(
        $name: string,
        $code: string,
        $description: string,
        $parent_category: option<record<legal_category>>
      ) {
        
        -- Vérification des doublons avant création
        -- Index UNIQUE sur (name, parent_category) empêche les doublons automatiquement
        -- Mais on peut vérifier explicitement pour un message d'erreur plus clair
        LET $existing_check = SELECT * FROM legal_category 
          WHERE name = $name AND parent_category = $parent_category;
        
        IF count($existing_check) > 0 {
          RETURN {
            success: false,
            error: "DOUBLON_DETECTE",
            message: "Une catégorie avec ce nom existe déjà sous ce parent",
            duplicate_name: $name,
            existing_category: $existing_check[0]
          };
        };
        
        -- Calcul automatique du level basé sur la hiérarchie
        -- Si pas de parent = niveau 1 (racine)
        -- Si parent existe = niveau du parent + 1
        LET $level = IF $parent_category IS NONE THEN
          1
        ELSE
          (SELECT level FROM legal_category WHERE id = $parent_category)[0].level + 1
        END;
        
        -- Création de l'enregistrement avec tous les champs requis
        -- SurrealDB génère automatiquement l'ID
        -- L'index UNIQUE (name, parent_category) empêche les doublons
        LET $category = CREATE legal_category CONTENT {
          name: $name,
          code: $code,
          description: $description,
          parent_category: $parent_category,
          level: $level,                    -- Level calculé automatiquement
          active: true,                     -- Actif par défaut
          created_on: time::now(),          -- Timestamp de création
          updated_on: time::now(),          -- Timestamp de mise à jour
          created_by: 'system',             -- Créé par le système
          updated_by: 'system'              -- Mis à jour par le système
        };
        
        -- Retour de l'enregistrement créé avec ID généré automatiquement
        RETURN {
          success: true,
          data: $category[0],
          message: "Catégorie créée avec succès",
          name: $name,
          level: $level
        };
      } COMMENT "Crée une nouvelle catégorie juridique avec ID généré automatiquement et calcul automatique du level hiérarchique basé sur le parent. Empêche les doublons (même nom sous même parent) avec index UNIQUE. Retourne un objet avec success, data et message. Le tri se fait côté client (sort_order supprimé)."

-- =============================================================================
-- MÉTHODE JAVASCRIPT POUR INTERFACE UTILISATEUR
-- =============================================================================
-- Cette fonction peut être utilisée dans l'interface pour créer une catégorie via un bouton
-- 
-- EXEMPLE D'UTILISATION DANS L'INTERFACE:
-- 
-- async function createLegalCategory(formData) {
--   try {
--     const result = await db.query(`
--       RETURN fn::add_legal_category(
--         '${formData.name}',
--         '${formData.code}',
--         '${formData.description}',
--         ${formData.parentId || 'NONE'}
--       )
--     `);
--     
--     if (result[0]) {
--       console.log('✅ Catégorie créée:', result[0]);
--       return {
--         success: true,
--         data: result[0],
--         message: `Catégorie "${result[0].name}" créée avec succès (Level ${result[0].level})`
--       };
--     }
--   } catch (error) {
--     console.error('❌ Erreur création catégorie:', error);
--     return {
--       success: false,
--       error: error.message,
--       message: 'Erreur lors de la création de la catégorie'
--     };
--   }
-- }
-- 
-- EXEMPLE HTML AVEC BOUTON:
-- 
-- <form id="categoryForm">
--   <input type="text" id="name" placeholder="Nom de la catégorie" required>
--   <input type="text" id="code" placeholder="Code" required>
--   <textarea id="description" placeholder="Description"></textarea>
--   <select id="parent">
--     <option value="">Catégorie racine</option>
--     <!-- Options peuplées dynamiquement -->
--   </select>
--   <input type="number" id="sortOrder" value="1" min="1">
--   <button type="submit" onclick="handleCreateCategory(event)">Créer Catégorie</button>
-- </form>
-- 
-- <script>
-- async function handleCreateCategory(event) {
--   event.preventDefault();
--   
--   const formData = {
--     name: document.getElementById('name').value,
--     code: document.getElementById('code').value,
--     description: document.getElementById('description').value,
--     parentId: document.getElementById('parent').value || null,
--     sortOrder: parseInt(document.getElementById('sortOrder').value)
--   };
--   
--   const result = await createLegalCategory(formData);
--   
--   if (result.success) {
--     alert(result.message);
--     document.getElementById('categoryForm').reset();
--     // Rafraîchir la liste des catégories
--     loadCategories();
--   } else {
--     alert(result.message);
--   }
-- }
-- </script>
-- =============================================================================
