-- =============================================================================================
-- |
-- | Fichier : builder_error_severity_seeds.surql
-- | Module : builder / reference
-- | Description : Initialisation des données de référence (seeds) pour la table
-- |               `builder_error_severity` et les clés i18n associées.
-- |
-- =============================================================================================

  LET $language_id = type::thing('i18n_language','fr');

  -- 1. Sévérité : 'info'
  -- Création des clés i18n
  LET $key_info_name = type::thing('builder_i18n_key', 'severity.info.name');
  LET $key_info_desc = type::thing('builder_i18n_key', 'severity.info.description');
  CREATE $key_info_name;
  CREATE $key_info_desc;
  -- Création des traductions i18n
  RELATE $key_info_name->builder_i18n_translation->$language_id SET text = 'Information';
  RELATE $key_info_desc->builder_i18n_translation->$language_id SET text = 'Message informatif';
  -- Création de la sévérité
  CREATE builder_error_severity:info CONTENT {  i18n_key: $key_info_name.id, 
  i18n_key_description: $key_info_desc.id, is_active: true, created_at: time::now()};

  -- 2. Sévérité : 'warning'
  -- Création des clés i18n
  LET $key_warning_name = type::thing('builder_i18n_key', 'severity.warning.name');
  LET $key_warning_desc = type::thing('builder_i18n_key', 'severity.warning.description');
  CREATE $key_warning_name;
  CREATE $key_warning_desc;
  -- Création des traductions i18n
  RELATE $key_warning_name->builder_i18n_translation->$language_id SET text = 'Avertissement';
  RELATE $key_warning_desc->builder_i18n_translation->$language_id SET text = 'Condition non bloquante';
  -- Création de la sévérité
  CREATE builder_error_severity:warning CONTENT {  i18n_key: $key_warning_name.id, 
  i18n_key_description: $key_warning_desc.id, is_active: true, created_at: time::now()};

  -- 3. Sévérité : 'error'
  LET $key_error_name = type::thing('builder_i18n_key', 'severity.error.name');
  LET $key_error_desc = type::thing('builder_i18n_key', 'severity.error.description');
  CREATE $key_error_name;
  CREATE $key_error_desc;
  -- Création des traductions i18n
  RELATE $key_error_name->builder_i18n_translation->$language_id SET text = 'Erreur';
  RELATE $key_error_desc->builder_i18n_translation->$language_id SET text = 'Échec de l\'opération';
  -- Création de la sévérité
  CREATE builder_error_severity:error CONTENT {  i18n_key: $key_error_name.id, 
  i18n_key_description: $key_error_desc.id, is_active: true, created_at: time::now()};

  -- 4. Sévérité : 'critical'
  LET $key_critical_name = type::thing('builder_i18n_key', 'severity.critical.name');
  LET $key_critical_desc = type::thing('builder_i18n_key', 'severity.critical.description');
  CREATE $key_critical_name;
  CREATE $key_critical_desc;
  -- Création des traductions i18n
  RELATE $key_critical_name->builder_i18n_translation->$language_id SET text = 'Critique';
  RELATE $key_critical_desc->builder_i18n_translation->$language_id SET 
  text = 'Erreur critique nécessitant une intervention';
  -- Création de la sévérité
  CREATE builder_error_severity:critical CONTENT {  i18n_key: $key_critical_name.id, 
  i18n_key_description: $key_critical_desc.id, is_active: true, created_at: time::now()};

  -- 5. Sévérité : 'success'
  LET $key_success_name = type::thing('builder_i18n_key', 'severity.success.name');
  LET $key_success_desc = type::thing('builder_i18n_key', 'severity.success.description');
  CREATE $key_success_name;
  CREATE $key_success_desc;
  -- Création des traductions i18n
  RELATE $key_success_name->builder_i18n_translation->$language_id SET text = 'Succès';
  RELATE $key_success_desc->builder_i18n_translation->$language_id SET text = 'Opération réussie';
  -- Création de la sévérité
  CREATE builder_error_severity:success CONTENT {  i18n_key: $key_success_name.id, 
  i18n_key_description: $key_success_desc.id, is_active: true, created_at: time::now()};