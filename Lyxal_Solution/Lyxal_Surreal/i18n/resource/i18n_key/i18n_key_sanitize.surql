-- =============================================================================================
-- |
-- | Fichier : i18n_key_sanitize.surql
-- | Module : i18n / i18n_key
-- | Description : Nettoie une valeur selon son type pour le module i18n_key.
-- | Paramètres :
-- |   - $value: string (valeur à nettoyer)
-- |
-- | Comportement :
-- |   - 'code' :
-- |       * espaces, '_' et '-' → '.'
-- |       * conversion en minuscules
-- |       * filtre a-z 0-9 et '.' seulement
-- |       * compresser '..' → '.'
-- |       * supprimer '.' au début et à la fin
-- |
-- | Gestion d'erreur :
-- |   - chaîne vide après nettoyage → { success:false, reason_code:'i18n.key.sanitize.failed' }
-- |
-- | Retour : { success, reason_code, data }
-- |   - data.sanitized présent uniquement en cas de succès
-- |   - data contient toujours { table:'i18n_key', value_type, value, ... }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_sanitize(
  $value: string
) {
  -- Normaliser l'entrée
  LET $input = string::trim($value);

  -- STEP 2: NETTOYAGE SPÉCIFIQUE SELON LE TYPE
  LET $value_normalize =
  -- Souplesse: espaces/underscore/tiret deviennent '.'
  LET $s1 = string::replace($input, <regex>'[\\s_\\-]+', '.');
  -- Minuscules obligatoires
  LET $s2 = string::lowercase($s1);
  -- Garder uniquement a-z, 0-9 et '.'
  LET $s3 = string::replace($s2, <regex>'[^a-z0-9.]', '');
  -- Compresser les points consécutifs
  LET $s4 = string::replace($s3, <regex>'\\.{2,}', '.');
  -- Retirer les points en début et fin
  LET $s5 = string::replace($s4, <regex>'^\\.+', '');
  LET $s6 = string::replace($s5, <regex>'\\.+$', '');
  string::trim($s6)
  
  -- Résultat vide => invalide selon le type
  IF string::len($value_normalize) = 0 {
    RETURN { success: false, reason_code: 'i18n.key.sanitize.failed' , 
    data: { table: 'i18n_key', value_type: 'i18n_key', value: $value } }; 
  };

  -- STEP 3: RETURN
  RETURN { success: true, reason_code: 'i18n.key.sanitize.success' , 
  data: { table: 'i18n_key', value_type: 'i18n_key', value: $value, sanitized: $value_normalize } };
}
COMMENT 'Sanitize une valeur unique selon un pattern: code (minuscules, .)'
PERMISSIONS FULL;