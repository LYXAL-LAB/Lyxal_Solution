-- =============================================================================================
-- |
-- | Fichier : builder_action_category_get_by_id.surql
-- | Module : builder / action / category
-- | Description : Récupère une catégorie d'action par son identifiant record (id). Helper sans logging.
-- |
-- | Paramètres :
-- |   - $category_id: string, identifiant (suffixe) de la catégorie
-- |
-- | Comportement :
-- |   - Transforme l'identifiant en record via type::thing.
-- |   - Sélectionne par id avec LIMIT 1 et renvoie success/reason_code selon présence.
-- |
-- | Retour :
-- |   - success: bool
-- |   - reason_code: 'CODE.FOUND' | 'CODE.NOT.FOUND'
-- |   - data: record<builder_action_category> si trouvé, sinon { table: 'builder_action_category', category_id }
-- |
-- | Notes :
-- |   - Pas de logging ni d'i18n.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_get_by_id(
  $category_id: string
) {

  -- on construit le return standard
  LET $success = false;
  LET $reason_code = '';
  LET $data = { table: 'builder_action_category', category_id: $category_id };

  -- on transforme le code en record builder_action_category
  LET $code_ref = type::thing('builder_action_category', $category_id);
  -- on récupère la catégorie
  LET $code_row = SELECT * FROM builder_action_category WHERE id = $code_ref LIMIT 1;
  -- si la catégorie n'existe pas, on retourne inexistant
  IF array::len($code_row) = 0 {
    LET $success = false;
    LET $reason_code = 'CODE.NOT.FOUND';
  }
  -- si la catégorie existe, on retourne la catégorie
  ELSE {
    LET $success = true;
    LET $reason_code = 'CODE.FOUND';
    LET $data =  $code_row[0] ;
  };

  -- on retourne le retour standard
  RETURN { 
    success: $success, 
    reason_code: $reason_code, 
    data: $data };
}
COMMENT 'Récupère une catégorie d\'action par son id'
PERMISSIONS FULL;