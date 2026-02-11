-- =============================================================================================
-- |
-- | Fichier : builder_action_category_validate_length.surql
-- | Module : builder / action_category
-- | Description : Valide la longueur minimale et maximale d'une valeur selon son type.
-- | Paramètres :
-- |   - $value_type: string ('code' | 'name' | 'description')
-- |   - $value: string
-- |
-- | Règles par défaut :
-- |   - code:        min=3,  max=64
-- |   - name:        min=3,  max=64
-- |   - description: min=0,  max=512
-- |
-- | Retour : { success, reason_code, data }
-- |   - success: bool
-- |   - reason_code: 'TYPE.INVALID' | 'LENGTH.MIN.VIOLATION' | 'LENGTH.MAX.VIOLATION' | 'RESOLVE.SUCCESS'
-- |   - data: { table:'builder_action_category', value_type, value, length, min, max }
-- |
-- | Notes :
-- |   - Pas de logging/i18n ici; helper pur de validation.
-- |   - La valeur est trimée mais non sanitizée (utiliser la fonction sanitize en amont si besoin).
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_validate_length(
  $value_type: string,
  $value: string
) {
  -- Normaliser l'entrée (sans sanitation spécifique)
  LET $input = string::trim($value);
  LET $len = string::len($input);

  -- Retour standard initial
  LET $success = false;
  LET $reason_code = '';
  LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value };

  -- Type supporté ?
  IF $value_type NOT IN ['code','name','description'] {
    RETURN {
      success: false,
      reason_code: 'TYPE.INVALID',
      data: { table: 'builder_action_category', value_type: $value_type, value: $value }
    };
  };

  -- Bornes par défaut selon le type
  LET $min_len = IF $value_type = 'description' THEN 0 ELSE 3 END;
  LET $max_len = IF $value_type = 'description' THEN 512 ELSE 64 END;

  -- Vérifications
  IF $len < $min_len {
    LET $success = false;
    LET $reason_code = 'LENGTH.MIN.VIOLATION';
    LET $data = { 
        table: 'builder_action_category', 
        value_type: $value_type, value: $value, 
        length: $len, 
        min: $min_len, 
        max: $max_len };
  }
  ELSE IF $len > $max_len {
    LET $success = false;
    LET $reason_code = 'LENGTH.MAX.VIOLATION';
    LET $data = { 
        table: 'builder_action_category', 
        value_type: $value_type, 
        value: $value, 
        length: $len, 
        min: $min_len, 
        max: $max_len };
  }
  ELSE {
    LET $success = true;
    LET $reason_code = 'RESOLVE.SUCCESS';
    LET $data = { 
        table: 'builder_action_category', 
        value_type: $value_type, 
        value: $value, 
        length: $len, 
        min: $min_len, 
        max: $max_len };
  };

  RETURN {
    success: $success,
    reason_code: $reason_code,
    data: $data
  };
}
COMMENT 'Valide la longueur d\'une valeur pour builder_action_category avec des bornes 
par défaut par type: code (3-64), name (3-64), description (0-512).'
PERMISSIONS FULL;