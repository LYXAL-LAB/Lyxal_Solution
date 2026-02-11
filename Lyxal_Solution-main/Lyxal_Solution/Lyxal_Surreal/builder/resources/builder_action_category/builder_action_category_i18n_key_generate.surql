-- =============================================================================================
-- |
-- | Fichier : builder_action_category_i18n_key_generate.surql
-- | Module : builder / action_category
-- | Description : Génère une clé i18n pour une catégorie d'action.
-- | Paramètres :
-- |   - $value: string (segment de valeur à injecter dans la clé)
-- |   - $key_type: string ('name' | 'description')
-- |
-- | Comportement :
-- |   - Valide $key_type ∈ { 'name','description' }
-- |   - En cas de succès, compose: 'builder.action.category.i18n.key.' || $value || '.' || $key_type
-- |   - Ne réalise pas de sanitize/length ici (à faire en amont si requis)
-- |
-- | Retour : { success, reason_code, data }
-- |   - success: bool
-- |   - reason_code: 'KEY.I18N.TYPE.INVALID' | 'KEY.I18N.VALID'
-- |   - data: { table:'builder_action_category', value, key_type, key_i18n? }
-- |       (key_i18n présent uniquement en cas de succès)
-- |
-- | Notes :
-- |   - Helper pur, sans logging ni i18n.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_i18n_key_generate(
  $value: string, 
  $key_type: string
) {

  -- on construit le return standard
  LET $success = false;
  LET $reason_code = '';
  LET $table = 'builder_action_category';
  LET $key_i18n = '';

  -- on vérifie que le type de la clé i18n est valide
  IF $key_type != 'name' AND $key_type != 'description' {
    -- on retourne l'erreur
    LET $reason_code = 'KEY.I18N.TYPE.INVALID'; 
  }
  ELSE {
    -- on compose la clé i18n
    LET $key_i18n = string::concat('builder.action.category.i18n.key.', $value,'.',$key_type);
    LET $success = true;
    LET $reason_code = 'KEY.I18N.VALID';
    LET $key_i18n = $key_i18n;
  };
-- on retourne le retour standard
  RETURN {
    success: $success,
    reason_code: $reason_code,
    data: { table: $table, value: $value, key_type: $key_type } || { key_i18n: $key_i18n }
  };
}
COMMENT 'Génère une clé i18n pour une catégorie d\'action builder'
PERMISSIONS FULL;