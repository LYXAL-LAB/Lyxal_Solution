-- =============================================================================================
-- |
-- | Fichier : builder_i18n_language_verify_id_active.surql
-- | Module : builder / translate
-- | Description : Vérifie qu'une langue i18n existe et précise si elle est active.
-- | Paramètres :
-- |   - $langue_id: string (identifiant/suffixe de la langue)
-- |   - $verify_active: bool (si true, impose l'état actif; si false, se contente de l'existence)
-- |
-- | Retour : { success, reason_code, data }
-- |   - reason_code: 'i18n.language.not.found' | 'i18n.language.not.active' | 'i18n.language.found'
-- |   - data: record<i18n_language> si trouvée, sinon { langue_id }
-- |
-- | Notes : Helper sans logging; utilisé pour prévalider les opérations dépendantes de la langue.
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_language_verify_id_active(
  $langue_id: string,
  $verify_active: bool
) {
  -- on construit le retour par défaut
  LET $resource_table = 'builder_i18n_key';

  -- On vérifie que la langue existe
  LET $langue_ref_id = type::thing('i18n_language', $langue_id);
  LET $langue_ref = SELECT * FROM i18n_language WHERE id = $langue_ref_id LIMIT 1;
  -- si la langue n'existe pas, on retourne l'échec
  IF array::len($langue_ref) = 0 {
    LET $success = false;
    LET $reason_code = 'i18n.language.not.found';
    LET $data = { table: $resource_table, id: $langue_id };
    RETURN { success: $success, reason_code: $reason_code, data: $data };
  }
  -- si la langue existe
  ELSE {
    -- si la langue existe et que l'on doit vérifier si elle est active
    IF $verify_active = true {
      -- si la langue existe mais n'est pas active
      IF $langue_ref[0].is_active = false {
        LET $success = false;
        LET $reason_code = 'i18n.language.not.active';
        LET $data = { table: $resource_table, id: $langue_id };
        RETURN { success: $success, reason_code: $reason_code, data: $data };
      };
    };
  };
  LET $success = true;
  LET $reason_code = 'i18n.language.found';
  LET $data = { table: $resource_table, id: $langue_id, data: $langue_ref[0] };
  RETURN { success: $success, reason_code: $reason_code, data: $data };
}
COMMENT 'Vérifie qu\'une langue existe et indique si elle est active ou non'
PERMISSIONS FULL;
