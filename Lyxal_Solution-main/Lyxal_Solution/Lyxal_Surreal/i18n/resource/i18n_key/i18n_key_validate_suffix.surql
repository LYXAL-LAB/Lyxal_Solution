-- =============================================================================================
-- |
-- | Fichier : i18n_key_validate_suffix.surql
-- | Module : i18n / key
-- | Description : Valide le suffixe d'une valeur pour i18n_key: (label, description, message).
-- | Paramètres :
-- |   - $suffix: string

-- |
-- | Règles par défaut :
-- |   - suffix: 'label', 'description', 'message'
-- |
-- | Retour : { success, reason_code, data }
-- |   - success: bool
-- |   - reason_code: 'i18n.key.suffix.invalid' | 'i18n.key.suffix.valid'
-- |   - data: { table:'i18n_key', suffix }
-- |
-- | Notes :
-- |   - Pas de logging/i18n ici; helper pur de validation.
-- =============================================================================================
  DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_validate_suffix(
  $suffix: string
) {

  -- Vérification du suffixe de la clé i18n
  IF $suffix != 'label' AND $suffix != 'description' AND $suffix != 'message' {
    -- on retourne l'erreur
    RETURN { success: false, reason_code: 'i18n.key.suffix.invalid', 
    data: { table: 'i18n_key', suffix: $suffix } };
  };

  -- on retourne le succès
  RETURN { success: true, reason_code: 'i18n.key.suffix.valid', 
  data: { table: 'i18n_key', suffix: $suffix } };
}
COMMENT 'Valide le suffixe d\'une valeur pour i18n_key: (label, description, message).'
PERMISSIONS FULL;