-- =============================================================================================
-- |
-- | Fichier : error_severity_translation_fr_seeds.surql
-- | Module : Lyxal_System
-- | Description : Traductions françaises pour les sévérités d'erreur
-- |               Ces traductions sont créées pour la langue française (language:fr)
-- |
-- =============================================================================================

BEGIN;

-- Traductions pour SUCCESS
RELATE i18n_key:error_severity_success_label->translation->language:fr 
SET content.text = 'Succès', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

RELATE i18n_key:error_severity_success_description->translation->language:fr 
SET content.text = 'Opération réussie', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

-- Traductions pour INFO
RELATE i18n_key:error_severity_info_label->translation->language:fr 
SET content.text = 'Information', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

RELATE i18n_key:error_severity_info_description->translation->language:fr 
SET content.text = 'Information générale', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

-- Traductions pour WARNING
RELATE i18n_key:error_severity_warning_label->translation->language:fr 
SET content.text = 'Avertissement', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

RELATE i18n_key:error_severity_warning_description->translation->language:fr 
SET content.text = 'Attention requise', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

-- Traductions pour ERROR
RELATE i18n_key:error_severity_error_label->translation->language:fr 
SET content.text = 'Erreur', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

RELATE i18n_key:error_severity_error_description->translation->language:fr 
SET content.text = 'Une erreur s\'est produite', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

-- Traductions pour CRITICAL
RELATE i18n_key:error_severity_critical_label->translation->language:fr 
SET content.text = 'Critique', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

RELATE i18n_key:error_severity_critical_description->translation->language:fr 
SET content.text = 'Erreur critique nécessitant une intervention immédiate', status.is_published = true, status.is_validated = true, status.validation_status = 'approved', metadata.created_by = 'system', metadata.source = 'import';

COMMIT;

