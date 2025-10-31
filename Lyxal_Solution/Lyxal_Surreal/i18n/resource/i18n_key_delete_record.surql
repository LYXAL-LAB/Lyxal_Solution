-- =============================================================================================
-- |
-- | Fichier : i18n_key_resources_create_initialise.surql
-- | Module : base / i18n
-- | Description : Crée une clé i18n.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_key_delete_record(
  $key: string,
  $parent_run_id: option<string>,
) {
  IF $key = NONE OR string::len(string::trim($key)) = 0 {
    THROW 'La clé i18n est requise.';
  };
  LET $now = time::now();
  LET $exists = SELECT * FROM i18n_key WHERE key = $key LIMIT 1;
  IF array::len($exists) > 0 { RETURN { success: true, data: $exists[0] }; };
  LET $rec = CREATE type::thing('i18n_key', $key) SET key = $key, description = $description, created_at = $now, updated_at = $now;
  RETURN { success: true, data: $rec[0] };
}
COMMENT 'Crée une clé i18n (idempotent).'
PERMISSIONS FULL;


