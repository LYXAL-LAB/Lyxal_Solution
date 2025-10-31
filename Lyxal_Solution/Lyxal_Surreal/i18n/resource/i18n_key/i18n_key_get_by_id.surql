-- =============================================================================================
-- |
-- | Fichier : i18n_key_get_by_id.surql
-- | Module : i18n / i18n_key
-- | Description : Récupère une clé i18n `i18n_key` par son identifiant (code/id).
-- | Paramètres :
-- |   - $value: string (identifiant/suffixe de la clé i18n)
-- |
-- | Comportement :
-- |   - Transforme $value en record id (type::thing) et sélectionne LIMIT 1
-- |
-- | Retour : { success, reason_code, data }
-- |   - reason_code: 'i18n.key.found' | 'i18n.key.not.found'
-- |   - data: record<i18n_key> si trouvé, sinon { table:'i18n_key', key:$value }
-- |
-- | Notes :
-- |   - Helper sans logging; utilisé par les fonctions de création/validation pour résoudre des messages.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_get_by_id(
  $value:string
) {

  -- on convertit la valeur en record i18n_key
  LET $key_ref = type::thing('i18n_key', $value);
  -- on vérifie si la clé i18n existe
  LET $key_row = SELECT * FROM i18n_key WHERE id = $key_ref LIMIT 1;
  -- si la clé i18n n'existe pas, on retourne l'échec clé non trouvée
  IF array::len($key_row) = 0 {
    RETURN { success: false, reason_code: 'i18n.key.not.found', 
    data: { table: 'i18n_key', key: $value } };
  }
  -- si la clé i18n existe, on retourne la clé i18n
  ELSE {
    RETURN { success: true, reason_code: 'i18n.key.found', 
    data: { table: 'i18n_key', key: $value, data: $key_row[0] } };
  };
}
COMMENT 'Récupère une clé i18n par son identifiant'
PERMISSIONS FULL;