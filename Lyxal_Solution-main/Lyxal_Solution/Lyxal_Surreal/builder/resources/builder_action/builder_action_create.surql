-- =============================================================================
-- FONCTION: fn::builder_action_create
-- =============================================================================
-- RÔLE
--   Créer une action dans `builder_action` avec validations simples.
-- PARAMÈTRES
--   - $code: string (identifiant unique)
--   - $key: string (record id builder_i18n_key)
--   - $description_key: option<string> (record id builder_i18n_key)
--   - $category: option<string> (code de catégorie)
--   - $severity: option<string> (info|warning|error|critical)
--   - $is_active: option<bool>
--   - $metadata: option<object>
--   - $payload: option<object>
--   - $created_by: option<string> (record id base_user)
-- RETOUR
--   { success, message, action, run_id }
-- =============================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_create(
  $code: string,
  $key: string,
  $description_key: option<string>,
  $category: option<string>,
  $severity: option<string>,
  $is_active: option<bool>,
  $metadata: option<object>,
  $payload: option<object>,
  $created_by: option<string>
) {
  LET $run_id = rand::uuid();

  -- Normalisation
  LET $code_norm = string::trim($code);
  IF $code_norm = NONE OR string::len($code_norm) = 0 {
    RETURN { success: false, message: 'code requis', action: NONE, run_id: $run_id };
  };
  IF $key = NONE OR string::len(string::trim($key)) = 0 {
    RETURN { success: false, message: 'key requis', action: NONE, run_id: $run_id };
  };

  -- Unicité
  LET $exists = SELECT count() AS c FROM builder_action WHERE code = $code_norm;
  IF $exists[0].c > 0 {
    RETURN { success: false, message: 'code déjà existant', action: NONE, run_id: $run_id };
  };

  -- Sévérité par défaut/validation
  LET $sev = IF $severity = NONE THEN 'info' ELSE string::lowercase($severity) END;
  IF $sev NOT IN ['info','warning','error','critical'] {
    RETURN { success: false, message: 'severity invalide', action: NONE, run_id: $run_id };
  };

  -- Création
  BEGIN;
  LET $rec_id = type::thing('builder_action', $code_norm);
  CREATE $rec_id SET
    code = $code_norm,
    key = $key,
    description = IF $description_key != NONE THEN $description_key ELSE NONE END,
    category = IF $category != NONE THEN $category ELSE NONE END,
    severity = $sev,
    is_active = IF $is_active = NONE THEN true ELSE $is_active END,
    metadata = IF $metadata = NONE THEN {} ELSE $metadata END,
    payload = IF $payload = NONE THEN {} ELSE $payload END,
    created_at = time::now(),
    created_by = IF $created_by != NONE THEN $created_by ELSE NONE END;

  LET $created = SELECT * FROM $rec_id;
  IF array::len($created) = 0 {
    CANCEL;
    RETURN { success: false, message: 'création non appliquée', action: NONE, run_id: $run_id };
  };
  COMMIT;

  RETURN { success: true, message: 'action créée', action: $created[0], run_id: $run_id };
}
COMMENT 'Créer une action builder'
PERMISSIONS FULL;
