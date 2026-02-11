-- =============================================================================
-- FONCTION: fn::get_category_hierarchy
-- =============================================================================
-- DESCRIPTION: Récupère la hiérarchie complète d'une catégorie juridique (de la racine vers la catégorie)
-- PARAMETRES:
--   $category_id: Identifiant de la catégorie (ex: legal_category:abc123)
-- RETOUR: Array contenant la hiérarchie complète [racine, parent, ..., catégorie]
-- USAGE:
--   -- Récupérer la hiérarchie d'une catégorie:
--   RETURN fn::get_category_hierarchy(legal_category:abc123);
--   
--   -- Utiliser dans une requête:
--   SELECT *, fn::get_category_hierarchy(id) AS hierarchy FROM legal_category WHERE active = true;
--   
--   -- Afficher le chemin complet:
--   LET $hierarchy = fn::get_category_hierarchy(legal_category:abc123);
--   LET $path = array::join(array::map($hierarchy, |$cat| $cat.name), " > ");
-- 
-- EXEMPLE DE RETOUR:
--   [
--     { id: legal_category:root, name: "Entreprises", level: 1, parent_category: null },
--     { id: legal_category:child, name: "Sociétés", level: 2, parent_category: legal_category:root },
--     { id: legal_category:target, name: "SARL", level: 3, parent_category: legal_category:child }
--   ]
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_category_hierarchy($category_id: record<legal_category>) {
    -- Récupérer la catégorie demandée
    LET $cat = (SELECT * FROM legal_category WHERE id = $category_id)[0];
    
    -- Si la catégorie existe
    IF $cat {
        -- Si elle a un parent
        IF $cat.parent_category AND $cat.parent_category != NONE {
            -- Récupérer récursivement la hiérarchie du parent
            LET $parent_hierarchy = fn::get_category_hierarchy($cat.parent_category);
            
            -- Retourner la hiérarchie du parent + cette catégorie
            RETURN array::concat($parent_hierarchy, [$cat]);
        } 
        -- Si c'est une catégorie racine (pas de parent)
        ELSE {
            -- Retourner juste cette catégorie
            RETURN [$cat];
        };
    }
    -- Si la catégorie n'existe pas
    ELSE {
        -- Retourner un array vide
        RETURN [];
    };
} COMMENT "Récupère la hiérarchie complète d'une catégorie juridique de la racine vers la catégorie cible. Utilise la récursion pour remonter jusqu'à la racine. Retourne un array ordonné [racine, parent, ..., catégorie]. Retourne un array vide si la catégorie n'existe pas."

-- =============================================================================
-- MÉTHODE JAVASCRIPT POUR INTERFACE UTILISATEUR REACT
-- =============================================================================
-- Cette fonction peut être utilisée dans React pour afficher le fil d'Ariane (breadcrumb)
-- 
-- EXEMPLE D'UTILISATION DANS REACT:
-- 
-- async function getCategoryHierarchy(categoryId) {
--   try {
--     const result = await db.query(`RETURN fn::get_category_hierarchy(${categoryId})`);
--     
--     if (result[0] && result[0].length > 0) {
--       return {
--         success: true,
--         hierarchy: result[0],
--         path: result[0].map(cat => cat.name).join(' > '),
--         level: result[0].length,
--         root: result[0][0],
--         target: result[0][result[0].length - 1]
--       };
--     } else {
--       return {
--         success: false,
--         error: 'Catégorie non trouvée',
--         hierarchy: []
--       };
--     }
--   } catch (error) {
--     console.error('❌ Erreur récupération hiérarchie:', error);
--     return {
--       success: false,
--       error: error.message,
--       hierarchy: []
--     };
--   }
-- }
-- 
-- EXEMPLE COMPOSANT BREADCRUMB REACT AVEC DAISYUI:
-- 
-- function CategoryBreadcrumb({ categoryId }) {
--   const [hierarchy, setHierarchy] = useState([]);
--   const [loading, setLoading] = useState(true);
--   const { db } = useSurrealDB();
-- 
--   useEffect(() => {
--     async function loadHierarchy() {
--       setLoading(true);
--       const result = await getCategoryHierarchy(categoryId);
--       if (result.success) {
--         setHierarchy(result.hierarchy);
--       }
--       setLoading(false);
--     }
--     
--     if (categoryId) {
--       loadHierarchy();
--     }
--   }, [categoryId]);
-- 
--   if (loading) {
--     return <div className="loading loading-spinner loading-sm"></div>;
--   }
-- 
--   if (hierarchy.length === 0) {
--     return <div className="text-error">Catégorie non trouvée</div>;
--   }
-- 
--   return (
--     <div className="breadcrumbs text-sm">
--       <ul>
--         {hierarchy.map((category, index) => (
--           <li key={category.id}>
--             <a 
--               href={`/categories/${category.id}`}
--               className={index === hierarchy.length - 1 ? 'font-bold' : ''}
--             >
--               {category.name}
--             </a>
--           </li>
--         ))}
--       </ul>
--     </div>
--   );
-- }
-- 
-- EXEMPLE AFFICHAGE HIÉRARCHIE COMPLÈTE:
-- 
-- function CategoryHierarchyDisplay({ categoryId }) {
--   const [data, setData] = useState(null);
--   const { db } = useSurrealDB();
-- 
--   useEffect(() => {
--     async function loadData() {
--       const result = await getCategoryHierarchy(categoryId);
--       setData(result);
--     }
--     loadData();
--   }, [categoryId]);
-- 
--   if (!data || !data.success) return null;
-- 
--   return (
--     <div className="card w-96 bg-base-100 shadow-xl">
--       <div className="card-body">
--         <h2 className="card-title">Hiérarchie de la catégorie</h2>
--         
--         <div className="space-y-2">
--           <div className="stat">
--             <div className="stat-title">Chemin complet</div>
--             <div className="stat-value text-sm">{data.path}</div>
--           </div>
--           
--           <div className="stat">
--             <div className="stat-title">Niveau</div>
--             <div className="stat-value">{data.level}</div>
--           </div>
--         </div>
--         
--         <div className="space-y-1">
--           {data.hierarchy.map((category, index) => (
--             <div key={category.id} className="flex items-center space-x-2">
--               <div className="w-4 text-center text-xs">{index + 1}</div>
--               <div className={`badge ${index === data.hierarchy.length - 1 ? 'badge-primary' : 'badge-outline'}`}>
--                 Level {category.level}
--               </div>
--               <div className="flex-1">{category.name}</div>
--             </div>
--           ))}
--         </div>
--       </div>
--     </div>
--   );
-- }
-- ============================================================================= 