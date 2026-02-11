DEFINE IF NOT EXISTS fn::system_tag_i18n_key_seed($parent_run_id:option<string>) {

-- Préparation des variables
LET $parent_run_id = $parent_run_id OR NONE;
LET $log_extra_tags = ['module_system'];
LET $run_id = rand::uuid();

-- Journalisation de début
fn::deploy_log_helper('create', 'start', 'initialise', 
NONE, $run_id, $parent_run_id, NONE, NONE, NONE, NONE);

-- =============================================================================
-- CLÉS SPÉCIFIQUES AU MODULE SYSTEM_TAG
-- =============================================================================

-- Clés transverses pour system_tag (utilisables par tous les sous-modules)
fn::i18n_key_create('system_tag.validate.uniqueness_violated', 
    'Un tag avec ce nom existe déjà');

-- =============================================================================
-- CLÉS SPÉCIFIQUES À SYSTEM_TAG_PATTERN
-- =============================================================================

-- Clés pour les listes de patterns
fn::i18n_key_create('system_tag_pattern.list.no_pattern_found', 
    'Aucun pattern trouvé');
fn::i18n_key_create('system_tag_pattern.list.no_i18n_key_found', 
    'Aucune clé i18n trouvée pour les patterns');
fn::i18n_key_create('system_tag_pattern.list.no_translation_found', 
    'Aucune traduction trouvée pour les patterns');
fn::i18n_key_create('system_tag_pattern.list_children.no_pattern_found', 
    'Aucun pattern enfant trouvé');

-- Clés pour pattern not found (spécifique car message contextuel)
fn::i18n_key_create('system_tag_pattern.not_found', 
    'Pattern de tag introuvable');

-- Clés pour resolve_by_prefix (spécifiques au contexte de résolution de préfixe)
fn::i18n_key_create('system_tag_pattern.resolve.prefix_required', 
    'Le préfixe du pattern est requis');
fn::i18n_key_create('system_tag_pattern.resolve.success', 
    'Pattern résolu à partir du préfixe');

-- Clés pour validate_tag_name (spécifiques à la validation de nom de tag)
fn::i18n_key_create('system_tag_pattern.validate.prefix_mismatch',
    'Le nom du tag ne correspond pas au préfixe du pattern');
fn::i18n_key_create('system_tag_pattern.validate.suffix_required',
    'Le suffixe après le préfixe du pattern est requis');
fn::i18n_key_create('system_tag_pattern.validate.success',
    'Nom de tag valide pour ce pattern');

-- =============================================================================
-- CLÉS SPÉCIFIQUES À SYSTEM_TAG
-- =============================================================================

-- Clés pour les opérations CRUD
fn::i18n_key_create('system_tag.create.success',
    'Tag créé avec succès');
fn::i18n_key_create('system_tag.update.success',
    'Tag mis à jour avec succès');
fn::i18n_key_create('system_tag.delete.success',
    'Tag supprimé avec succès');
fn::i18n_key_create('system_tag.get.success',
    'Tag récupéré avec succès');
fn::i18n_key_create('system_tag.list.success',
    'Liste des tags récupérée');

-- Clés pour les erreurs
fn::i18n_key_create('system_tag.not_found',
    'Tag introuvable');
fn::i18n_key_create('system_tag.in_use',
    'Tag en cours d\'utilisation, suppression impossible');
fn::i18n_key_create('system_tag.has_children',
    'Tag avec des enfants ne peut pas être supprimé');
fn::i18n_key_create('system_tag.parent.not_found',
    'Tag parent introuvable');
fn::i18n_key_create('system_tag.pattern.required',
    'Pattern obligatoire pour ce tag');
fn::i18n_key_create('system_tag.pattern.mismatch',
    'Le nom du tag ne correspond pas au pattern');

-- Clés pour attach/detach
fn::i18n_key_create('system_tag.attach.success',
    'Tag attaché avec succès');
fn::i18n_key_create('system_tag.detach.success',
    'Tag détaché avec succès');
fn::i18n_key_create('system_tag.already_attached',
    'Tag déjà attaché à cette cible');
fn::i18n_key_create('system_tag.not_attached',
    'Tag non attaché à cette cible');
fn::i18n_key_create('system_tag.target.not_found',
    'Cible pour l\'attachement introuvable');

-- Clés pour l'exclusivité
fn::i18n_key_create('system_tag.exclusive.set',
    'Tag exclusif défini avec succès');
fn::i18n_key_create('system_tag.exclusive.conflict',
    'Conflit avec un autre tag exclusif du même pattern');

-- Clés pour import/export
fn::i18n_key_create('system_tag.import.success',
    'Tags importés avec succès');
fn::i18n_key_create('system_tag.export.success',
    'Tags exportés avec succès');
fn::i18n_key_create('system_tag.import.failed',
    'Échec de l\'import des tags');
fn::i18n_key_create('system_tag.export.failed',
    'Échec de l\'export des tags');

-- Clés pour hiérarchie
fn::i18n_key_create('system_tag.stats.success',
    'Statistiques du tag calculées');
fn::i18n_key_create('system_tag.ancestors.success',
    'Ancêtres du tag récupérés');
fn::i18n_key_create('system_tag.children.success',
    'Enfants du tag récupérés');
fn::i18n_key_create('system_tag.descendants.success',
    'Descendants du tag récupérés');

-- Clés pour validations
fn::i18n_key_create('system_tag.name.invalid',
    'Nom du tag invalide (doit être en snake_case)');
fn::i18n_key_create('system_tag.color.invalid',
    'Code couleur invalide');
fn::i18n_key_create('system_tag.protected',
    'Tag protégé, modification interdite');
fn::i18n_key_create('system_tag.expired',
    'Tag expiré');

RETURN { success: true, data: NONE };
}
COMMENT 'Seed de clé i18n'
PERMISSIONS FULL;