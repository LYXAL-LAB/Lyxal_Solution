-- =============================================================================================
-- |
-- | Fichier : builder_i18n_key_get_by_code.surql
-- | Module : builder / translate
-- | Description : Récupère une clé i18n `builder_i18n_key` par son identifiant (code/id).
-- | Paramètres :
-- |   - $value: string (identifiant/suffixe de la clé i18n)
-- |
-- | Comportement :
-- |   - Transforme $value en record id (type::thing) et sélectionne LIMIT 1
-- |
-- | Retour : { success, reason_code, data }
-- |   - reason_code: 'i18n.key.found' | 'i18n.key.not.found'
-- |   - data: record<builder_i18n_key> si trouvé, sinon { table:'builder_i18n_key', id:$value }
-- |
-- | Notes :
-- |   - Helper sans logging; utilisé par les fonctions de création/validation pour résoudre des messages.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_key_get_by_code(
  $value:string
) {

  LET $data = { table: 'builder_i18n_key', id: $value };

  -- Vérification de la conformité des paramètres
  -- on convertit la valeur en record builder_i18n_key
  LET $key_ref = type::thing('builder_i18n_key', $value);
  -- on vérifie si la clé i18n existe
  LET $key_row = SELECT * FROM builder_i18n_key WHERE id = $key_ref LIMIT 1;
  -- si la clé i18n n'existe pas, on retourne l'échec clé non trouvée
  IF array::len($key_row) = 0 {
    LET $success = false;
    LET $reason_code = 'i18n.key.not.found';
    LET $data = { table: 'builder_i18n_key', id: $value };
    RETURN { success: $success, reason_code: $reason_code, data: $data };
  }
  -- si la clé i18n existe, on retourne la clé i18n
  ELSE {
    LET $success = true;
    LET $reason_code = 'i18n.key.found';
    LET $data =  { table: 'builder_i18n_key', id: $value, data: $key_row[0] } ;
    RETURN { success: $success, reason_code: $reason_code, data: $data };
  };
}
COMMENT 'Récupère une clé i18n par son code'
PERMISSIONS FULL;