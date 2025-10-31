-- =============================================================================================
-- |
-- | Fichier : i18n_key_verify_unicity.surql
-- | Module : i18n / i18n_key
-- | Description : Vérifie l'unicité d'une clé i18n par son identifiant (id record).
-- | Paramètres :
-- |   - $code_id: string, identifiant (suffixe) de la clé i18n
-- |
-- | Comportement :
-- |   - Si aucune entrée n'existe -> success=true, reason_code='i18n.key.unique'
-- |     data = { table: 'i18n_key', key: $code_id }
-- |   - Si une entrée existe -> success=false, reason_code='i18n.key.already.exists'
-- |     data = { table: 'i18n_key', key: $code_id }
-- |
-- | Retour :
-- |   - success: bool
-- |   - reason_code: string ('i18n.key.unique' | 'i18n.key.already.exists')
-- |   - data: object | { table: 'i18n_key', key: $code_id }
-- |
-- | Notes :
-- |   - Pas de logging ni de i18n ici.
-- |   - Recherche directe par id (type::thing) avec LIMIT 1.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_verify_unicity(
  $code_id: string
) {

  -- on transforme le code en record i18n_key
  LET $code_ref = type::thing('i18n_key', $code_id);
  -- on récupère la catégorie
  LET $code_row = SELECT * FROM i18n_key WHERE id = $code_ref LIMIT 1;
  -- si la catégorie n'existe pas, on retourne la réussite d'unicité
  IF array::len($code_row) = 0 {
    RETURN { success: true, reason_code: 'i18n.key.unique', 
    data: { table: 'i18n_key', key: $code_id } };
  }
  -- si la clé i18n existe, on retourne l'erreur d'unicité
  ELSE {
    RETURN { success: false, reason_code: 'i18n.key.already.exists', 
    data: { table: 'i18n_key', key: $code_id } };
  };
}
COMMENT 'Vérifie l\'unicité d\'une clé i18n'
PERMISSIONS FULL;