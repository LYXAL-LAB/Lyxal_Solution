-- =============================================================================================
-- |
-- | Fichier : i18n_key_generate.surql
-- | Module : i18n / i18n_key
-- | Description : Génère une clé i18n (value/prefix/suffix).
-- | Paramètres :
-- |   - $value: string (segment de valeur à injecter dans la clé)
-- |   - $prefix: string (clé i18n parente)
-- |   - $suffix: string ('label' | 'description'| 'message')
-- |
-- | Comportement :
-- |   - Valide $suffix ∈ { 'label','description','message' }
-- |   - En cas de succès, compose: $prefix || '.' || $value || '.' || $suffix
-- |   - Ne réalise pas de sanitize/length ici (à faire en amont si requis)
-- |
-- | Retour : { success, reason_code, data }
-- |   - success: bool
-- |   - reason_code: 'i18n.key.generate.success' | 'i18n.key.generate.failed'
-- |   - data: { table:'i18n_key', value, prefix, suffix, key_i18n? }
-- |       (key_i18n présent uniquement en cas de succès)
-- |
-- | Notes :
-- |   - Helper pur, sans logging ni i18n.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_generate(
  $value: string, 
  $prefix: string,
  $suffix: string
) {
  LET $suffix = string::lowercase($suffix);
  LET $prefix = string::lowercase($prefix);
  LET $value = string::lowercase($value);

  -- Sanitisation de la value de la clé
  LET $value_ref = fn::i18n_key_sanitize($value)
  -- La sanitisation échoue
  IF $value_ref.succes = false {
    RETURN { success: false, reason_code: 'i18n.key.generate.failed', failed_reason: 
    $value_ref.reason_code, failed_step: 'validate_value',data: $value_ref.data };
  }
  LET $value_final = $value_ref.data.sanitized;

  -- Valide la longueur de la value de la clé
  LET $value_length_ref = fn::i18n_key_validate_length($value_final);
  -- La validation de la longueur échoue
  IF $value_length_ref.success = false {
    RETURN { success: false, reason_code: 'i18n.key.generate.failed', failed_reason: 
    $value_length_ref.reason_code, failed_step: 'validate_length',data: $value_length_ref.data };
  };

  -- Vérification du suffixe de la clé i18n
  LET $suffix_ref = fn::i18n_key_validate_suffix($suffix);
  -- La validation du suffixe échoue
  IF $suffix_ref.success = false {
    RETURN { success: false, reason_code: 'i18n.key.generate.failed', failed_reason: 
    $suffix_ref.reason_code, failed_step: 'validate_suffix',data: $suffix_ref.data };
  };
  LET $suffix_final = $suffix_ref.data.suffix;

  -- Sanitisation du prefix de la clé i18n
  LET $prefix_ref = fn::i18n_key_sanitize($prefix);
  -- La sanitisation du prefix échoue
  IF $prefix_ref.success = false {
    RETURN { success: false, reason_code: 'i18n.key.generate.failed', failed_reason: 
    $prefix_ref.reason_code, failed_step: 'sanitize_prefix', data: $prefix_ref.data };
  };
  LET $prefix_final = $prefix_ref.data.sanitized;

  -- Composition de la clé i18n
  LET $key_i18n = string::concat($prefix_final,'.',$value_final,'.',$suffix_final);
  RETURN { success: true, reason_code: 'i18n.key.generate.success', 
  data: { table: 'i18n_key', value: $value, prefix: $prefix, suffix: $suffix, key_i18n: $key_i18n } };
}
COMMENT 'Génère une clé i18n pour une valeur (value/prefix/suffix).'
PERMISSIONS FULL;