-- =============================================================================================
-- |
-- | Fichier : error_severity_seeds.surql
-- | Module : base
-- | Description : Initialisation des données de référence (seeds) pour la table
-- |               `error_severity`, en accord avec la structure immuable.
-- |
-- =============================================================================================

  LET $language_id = type::thing('language','fr');

  -- 1. Sévérité : 'success' (rank=0)
  LET $key_label = type::thing('i18n_key', 'error_severity_success_label');
  LET $key_desc = type::thing('i18n_key', 'error_severity_success_description');
  CREATE $key_label; CREATE $key_desc;
  RELATE $key_label->translation->$language_id SET text = 'Succès';
  RELATE $key_desc->translation->$language_id SET text = 'Opération réussie';
  CREATE error_severity:success SET 
    i18n = { label: $key_label, description: $key_desc },
    rank = 0,
    is_active = true;

  -- 2. Sévérité : 'info' (rank=10)
  LET $key_label = type::thing('i18n_key', 'error_severity_info_label');
  LET $key_desc = type::thing('i18n_key', 'error_severity_info_description');
  CREATE $key_label; CREATE $key_desc;
  RELATE $key_label->translation->$language_id SET text = 'Information';
  RELATE $key_desc->translation->$language_id SET text = 'Message informatif';
  CREATE error_severity:info SET
    i18n = { label: $key_label, description: $key_desc },
    rank = 10,
    is_active = true;

  -- 3. Sévérité : 'warning' (rank=20)
  LET $key_label = type::thing('i18n_key', 'error_severity_warning_label');
  LET $key_desc = type::thing('i18n_key', 'error_severity_warning_description');
  CREATE $key_label; CREATE $key_desc;
  RELATE $key_label->translation->$language_id SET text = 'Avertissement';
  RELATE $key_desc->translation->$language_id SET text = 'Condition non bloquante';
  CREATE error_severity:warning SET
    i18n = { label: $key_label, description: $key_desc },
    rank = 20,
    is_active = true;

  -- 4. Sévérité : 'error' (rank=30)
  LET $key_label = type::thing('i18n_key', 'error_severity_error_label');
  LET $key_desc = type::thing('i18n_key', 'error_severity_error_description');
  CREATE $key_label; CREATE $key_desc;
  RELATE $key_label->translation->$language_id SET text = 'Erreur';
  RELATE $key_desc->translation->$language_id SET text = 'Échec de l''opération';
  CREATE error_severity:error SET
    i18n = { label: $key_label, description: $key_desc },
    rank = 30,
    is_active = true;

  -- 5. Sévérité : 'critical' (rank=40)
  LET $key_label = type::thing('i18n_key', 'error_severity_critical_label');
  LET $key_desc = type::thing('i18n_key', 'error_severity_critical_description');
  CREATE $key_label; CREATE $key_desc;
  RELATE $key_label->translation->$language_id SET text = 'Critique';
  RELATE $key_desc->translation->$language_id SET text = 'Erreur critique nécessitant une intervention';
  CREATE error_severity:critical SET
    i18n = { label: $key_label, description: $key_desc },
    rank = 40,
    is_active = true;