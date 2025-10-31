-- =============================================================================================
-- |
-- | Fichier : builder_action_category_verify_unicity.surql
-- | Module : builder / action / category
-- | Description : Vérifie l'unicité d'une catégorie d'action par son identifiant (id record).
-- | Paramètres :
-- |   - $code_id: string, identifiant (suffixe) de la catégorie
-- |
-- | Comportement :
-- |   - Si aucune entrée n'existe -> success=true, reason_code='CODE.VALID'
-- |     data = { table: 'builder_action_category', code: $code_id }
-- |   - Si une entrée existe -> success=false, reason_code='CODE.ALREADY.EXISTS'
-- |     data = record<builder_action_category>
-- |
-- | Retour :
-- |   - success: bool
-- |   - reason_code: string ('CODE.VALID' | 'CODE.ALREADY.EXISTS')
-- |   - data: object | record<builder_action_category>
-- |
-- | Notes :
-- |   - Pas de logging ni de i18n ici.
-- |   - Recherche directe par id (type::thing) avec LIMIT 1.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_verify_unicity(
  $code_id: string
) {

  -- on construit le return standard
  LET $success = false;
  LET $reason_code = '';
  LET $data = { table: 'builder_action_category', code: $code_id };

  -- on transforme le code en record builder_action_category
  LET $code_ref = type::thing('builder_action_category', $code_id);
  -- on récupère la catégorie
  LET $code_row = SELECT * FROM builder_action_category WHERE id = $code_ref LIMIT 1;
  -- si la catégorie n'existe pas, on retourne la réussite d'unicité
  IF array::len($code_row) = 0 {
    LET $success = true;
    LET $reason_code = 'CODE.VALID';
    LET $data =  $data ;
  }
  -- si la catégorie existe, on retourne l'erreur d'unicité
  ELSE {
    LET $success = false;
    LET $reason_code = 'CODE.ALREADY.EXISTS';
    LET $data =  $code_row[0] ;
  };

  -- on retourne le retour standard
  RETURN { 
    success: $success, 
    reason_code: $reason_code, 
    data: $data };
}
COMMENT 'Vérifie l\'unicité d\'une catégorie d\'action'
PERMISSIONS FULL;