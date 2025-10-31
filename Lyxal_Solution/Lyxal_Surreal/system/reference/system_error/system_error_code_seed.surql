-- =============================================================================
-- SEED: system_error_code_seed
-- =============================================================================
-- RÔLE
--   Enregistrer les codes d'erreur utilisés par system_tag_pattern_create.
--   Ces codes restent génériques pour l'ensemble de l'application.
-- =============================================================================
DEFINE IF NOT EXISTS fn::system_error_code_seed() {
  LET $payload_generic = {};

  -- Ordre des paramètres: code, message_key, description, severity, payload, created_by
  fn::system_error_code_create('NAME_REQUIRED', 'field.name_required', 
    'Nom requis (générique).', 'error', $payload_generic, NONE);
  fn::system_error_code_create('LABEL_REQUIRED', 'field.label_required', 
    'Libellé requis (générique).', 'error', $payload_generic, NONE);
  fn::system_error_code_create('DESCRIPTION_REQUIRED', 'field.description_required', 
    'Description requise (générique).', 'error', $payload_generic, NONE);
  fn::system_error_code_create('FORMAT_INVALID', 'field.name.format.invalid.snake_case', 
    'Format snake_case invalide.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('UNIQUENESS_VIOLATED', 'field.name.uniqueness_violated', 
    'Violation d\'unicité.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('PARENT_NOT_FOUND', 'record.parent.not_found', 
    'Parent introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('NOT_APPLIED', 'create.record.not_applied', 
    'Création non appliquée.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('I18N_KEY_CREATE_FAILED', 'i18n_key.create.error', 
    'Échec de création de clé i18n.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('I18N_TRANSLATION_UPSERT_FAILED', 'i18n_translation.upsert.error', 
    'Échec d\'upsert de traduction i18n.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('OK', 'create.record.success', 
    'Opération réussie.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('CODE_NOT_FOUND', 'code.not_found', 
    'Code d\'erreur introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('LANGUE_NOT_FOUND', 'langue.not_found', 
    'Langue introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('I18N_TRANSLATION_FAILED', 'i18n_translation.failed', 
    'Échec de traduction i18n.', 'error', $payload_generic, NONE);
  
  -- Codes pour les opérations CRUD génériques
  fn::system_error_code_create('ID_REQUIRED', 'field.id_required', 
    'Identifiant requis.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('NOT_FOUND', 'resource.not_found', 
    'Ressource introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('GET_SUCCESS', 'resource.get.success', 
    'Récupération réussie.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('UPDATE_SUCCESS', 'resource.update.success', 
    'Mise à jour réussie.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('DELETE_SUCCESS', 'resource.delete.success', 
    'Suppression réussie.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('IN_USE', 'resource.delete.in_use', 
    'Ressource en cours d\'utilisation.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('DELETE_NOT_APPLIED', 'resource.delete.not_applied', 
    'Suppression non appliquée.', 'error', $payload_generic, NONE);
  
  -- Codes pour les listes
  fn::system_error_code_create('PATTERN_NOT_FOUND', 'system_tag_pattern.not_found', 
    'Pattern introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('NO_PATTERN_FOUND', 'system_tag_pattern.list.no_pattern_found', 
    'Aucun pattern trouvé.', 'warning', $payload_generic, NONE);
  fn::system_error_code_create('NO_I18N_KEY_FOUND', 'system_tag_pattern.list.no_i18n_key_found', 
    'Aucune clé i18n trouvée.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('NO_TRANSLATION_FOUND', 'system_tag_pattern.list.no_translation_found', 
    'Aucune traduction trouvée.', 'warning', $payload_generic, NONE);
  fn::system_error_code_create('LIST_SUCCESS', 'resource.list.success', 
    'Liste récupérée avec succès.', 'info', $payload_generic, NONE);
  
  -- Codes pour resolve_by_prefix et validate_tag_name
  fn::system_error_code_create('PREFIX_REQUIRED', 'system_tag_pattern.resolve.prefix_required', 
    'Le préfixe est requis.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('RESOLVE_SUCCESS', 'system_tag_pattern.resolve.success', 
    'Pattern résolu avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('PREFIX_MISMATCH', 'system_tag_pattern.validate.prefix_mismatch', 
    'Le nom ne correspond pas au préfixe du pattern.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('SUFFIX_REQUIRED', 'system_tag_pattern.validate.suffix_required', 
    'Le suffixe après le préfixe est requis.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('VALIDATE_SUCCESS', 'system_tag_pattern.validate.success', 
    'Validation réussie.', 'info', $payload_generic, NONE);
  
  -- Code pour fonction non implémentée
  fn::system_error_code_create('NOT_IMPLEMENTED', 'function.not_implemented', 
    'Fonction non implémentée.', 'warning', $payload_generic, NONE);
  
  -- Codes pour le système de logging
  fn::system_error_code_create('LOG_CREATE_SUCCESS', 'log.create.success', 
    'Entrée de log créée avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_CREATE_FAILED', 'log.create.failed', 
    'Échec de création de l\'entrée de log.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('LOG_CLEANUP_SUCCESS', 'log.cleanup.success', 
    'Nettoyage des logs réussi.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_ARCHIVE_SUCCESS', 'log.archive.success', 
    'Archivage des logs réussi.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_ARCHIVE_FAILED', 'log.archive.failed', 
    'Échec de l\'archivage des logs.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('LOG_ARCHIVE_EMPTY', 'log.archive.empty', 
    'Aucun log à archiver.', 'warning', $payload_generic, NONE);
  fn::system_error_code_create('LOG_QUERY_SUCCESS', 'log.query.success', 
    'Requête de logs réussie.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_STATS_SUCCESS', 'log.stats.success', 
    'Statistiques des logs calculées.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_ERRORS_SUCCESS', 'log.errors.success', 
    'Rapport d\'erreurs généré.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('LOG_NO_ERRORS', 'log.no_errors', 
    'Aucune erreur trouvée.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('INVALID_PARAMETER', 'validation.parameter.invalid', 
    'Paramètre invalide.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('INVALID_DATE_RANGE', 'validation.date_range.invalid', 
    'Plage de dates invalide.', 'error', $payload_generic, NONE);

  -- =============================================================================
  -- Codes spécifiques pour system_tag
  -- =============================================================================
  
  -- Codes pour les opérations CRUD sur les tags
  fn::system_error_code_create('TAG_CREATE_SUCCESS', 'system_tag.create.success',
    'Tag créé avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_UPDATE_SUCCESS', 'system_tag.update.success',
    'Tag mis à jour avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_DELETE_SUCCESS', 'system_tag.delete.success',
    'Tag supprimé avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_GET_SUCCESS', 'system_tag.get.success',
    'Tag récupéré avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_LIST_SUCCESS', 'system_tag.list.success',
    'Liste des tags récupérée.', 'info', $payload_generic, NONE);
  
  -- Codes pour les erreurs spécifiques aux tags
  fn::system_error_code_create('TAG_NOT_FOUND', 'system_tag.not_found',
    'Tag introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_IN_USE', 'system_tag.in_use',
    'Tag en cours d\'utilisation.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_HAS_CHILDREN', 'system_tag.has_children',
    'Tag avec des enfants ne peut pas être supprimé.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_PARENT_NOT_FOUND', 'system_tag.parent.not_found',
    'Tag parent introuvable.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_PATTERN_REQUIRED', 'system_tag.pattern.required',
    'Pattern obligatoire pour ce tag.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_PATTERN_MISMATCH', 'system_tag.pattern.mismatch',
    'Le nom du tag ne correspond pas au pattern.', 'error', $payload_generic, NONE);
  
  -- Codes pour les opérations attach/detach
  fn::system_error_code_create('TAG_ATTACH_SUCCESS', 'system_tag.attach.success',
    'Tag attaché avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_DETACH_SUCCESS', 'system_tag.detach.success',
    'Tag détaché avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_ALREADY_ATTACHED', 'system_tag.already_attached',
    'Tag déjà attaché à cette cible.', 'warning', $payload_generic, NONE);
  fn::system_error_code_create('TAG_NOT_ATTACHED', 'system_tag.not_attached',
    'Tag non attaché à cette cible.', 'warning', $payload_generic, NONE);
  fn::system_error_code_create('TAG_TARGET_NOT_FOUND', 'system_tag.target.not_found',
    'Cible pour l\'attachement introuvable.', 'error', $payload_generic, NONE);
  
  -- Codes pour les opérations d'exclusivité
  fn::system_error_code_create('TAG_EXCLUSIVE_SET', 'system_tag.exclusive.set',
    'Tag exclusif défini avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_EXCLUSIVE_CONFLICT', 'system_tag.exclusive.conflict',
    'Conflit avec un autre tag exclusif.', 'error', $payload_generic, NONE);
  
  -- Codes pour l'import/export
  fn::system_error_code_create('TAG_IMPORT_SUCCESS', 'system_tag.import.success',
    'Tags importés avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_EXPORT_SUCCESS', 'system_tag.export.success',
    'Tags exportés avec succès.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_IMPORT_FAILED', 'system_tag.import.failed',
    'Échec de l\'import des tags.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_EXPORT_FAILED', 'system_tag.export.failed',
    'Échec de l\'export des tags.', 'error', $payload_generic, NONE);
  
  -- Codes pour les statistiques et hiérarchie
  fn::system_error_code_create('TAG_STATS_SUCCESS', 'system_tag.stats.success',
    'Statistiques du tag calculées.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_ANCESTORS_SUCCESS', 'system_tag.ancestors.success',
    'Ancêtres du tag récupérés.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_CHILDREN_SUCCESS', 'system_tag.children.success',
    'Enfants du tag récupérés.', 'info', $payload_generic, NONE);
  fn::system_error_code_create('TAG_DESCENDANTS_SUCCESS', 'system_tag.descendants.success',
    'Descendants du tag récupérés.', 'info', $payload_generic, NONE);
  
  -- Codes pour les validations
  fn::system_error_code_create('TAG_NAME_INVALID', 'system_tag.name.invalid',
    'Nom du tag invalide (doit être en snake_case).', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_COLOR_INVALID', 'system_tag.color.invalid',
    'Code couleur invalide.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_PROTECTED', 'system_tag.protected',
    'Tag protégé, modification interdite.', 'error', $payload_generic, NONE);
  fn::system_error_code_create('TAG_EXPIRED', 'system_tag.expired',
    'Tag expiré.', 'warning', $payload_generic, NONE);

  RETURN { success: true };
}
COMMENT 'Seed des codes d\'erreur pour system_tag_pattern et system_tag'
PERMISSIONS FULL;
