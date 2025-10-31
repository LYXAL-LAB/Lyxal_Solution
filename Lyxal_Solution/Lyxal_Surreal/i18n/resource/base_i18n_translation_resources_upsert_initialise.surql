-- =============================================================================================
-- |
-- | Fichier : i18n_translation_resources_upsert_initialise.surql
-- | Module : base / i18n
-- | Description : Crée ou met à jour une traduction (clé + langue).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_translation_upsert(
  $key: string,
  $language_code: string,
  $text: string
) {
  IF $key = NONE OR string::len(string::trim($key)) = 0 {
    THROW 'La clé i18n est requise.';
  };
  IF $language_code = NONE OR string::len(string::trim($language_code)) = 0 {
    THROW 'Le code langue est requis.';
  };
  IF $text = NONE OR string::len(string::trim($text)) = 0 {
    THROW 'Le texte est requis.';
  };

  -- Récupérer clé et langue
  LET $key_rec = SELECT * FROM i18n_key WHERE key = $key LIMIT 1;
  IF array::len($key_rec) = 0 { THROW 'Clé introuvable. Créez-la d\'abord.'; };
  LET $lang_rec = SELECT * FROM i18n_language WHERE code = $language_code LIMIT 1;
  IF array::len($lang_rec) = 0 { THROW 'Langue introuvable.'; };

  LET $in_id = $key_rec[0].id;
  LET $out_id = $lang_rec[0].id;

  -- Upsert relation (unique par in/out)
  LET $existing = SELECT * FROM i18n_translation WHERE in = $in_id AND out = $out_id LIMIT 1;
  IF array::len($existing) = 0 {
    LET $created = RELATE $in_id->i18n_translation->$out_id SET text = $text, updated_at = time::now();
    RETURN { success: true, created: true, data: $created[0] };
  } else {
    LET $id = $existing[0].id;
    LET $updated = UPDATE $id SET text = $text, updated_at = time::now();
    RETURN { success: true, created: false, data: $updated };
  };
}
COMMENT 'Upsert d\'une traduction i18n (clé->langue).'
PERMISSIONS FULL;


