-- =============================================================================================
-- |
-- | Fichier : i18n_key_validate_length.surql
-- | Module : i18n / key
-- | Description : Valide la longueur minimale et maximale d'une valeur selon son type.
-- | Paramètres :
-- |   - $value: string

-- |
-- | Règles par défaut :
-- |   - min=3,  max=64
-- |
-- | Retour : { success, reason_code, data }
-- |   - success: bool
-- |   - reason_code: 'i18n.key.length.min.violation' | 'i18n.key.length.max.violation' |
-- |   - reason_code: 'i18n.key.length.success'
-- |   - data: { table:'i18n_key', key, length, min, max }
-- |
-- | Notes :
-- |   - Pas de logging/i18n ici; helper pur de validation.
-- |   - La valeur est trimée mais non sanitizée (utiliser la fonction sanitize en amont si besoin).
-- |   - Utilise le pattern $step_valid pour des étapes de validation séquentielles.
-- =============================================================================================
  DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_validate_length(
  $value: string
) {
  -- Normaliser l'entrée (sans sanitation spécifique)
  LET $input = string::trim($value);
  LET $len = string::len($input);
  -- On définit les bornes par défaut selon le type
  LET $min_len = 3;
  LET $max_len = 64;

  LET $table = 'i18n_key';

  -- STEP 1: VALIDATION DE LA LONGUEUR MINIMALE
  IF $len < $min_len {
    RETURN { success: false, reason_code: 'i18n.key.length.min.violation', 
    data: { table: $table, key: $value } };
  };

  -- STEP 3: VALIDATION DE LA LONGUEUR MAXIMALE
  IF $len > $max_len {
    RETURN { success: false, reason_code: 'i18n.key.length.max.violation', 
    data: { table: $table, key: $value } };
  };

  -- STEP 4: RETURN
  RETURN { success: true, reason_code: 'i18n.key.length.success', 
  data: { table: $table, key: $value } };
}
COMMENT 'Valide la longueur d\'une valeur pour i18n_key: (3-64).'
PERMISSIONS FULL;