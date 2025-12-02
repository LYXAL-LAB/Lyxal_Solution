-- =============================================================================================
-- | Fichier : test_error_code_event_config.surql
-- | Module : error
-- | Description : Configuration de test pour tester l'event error_code_auto_create_i18n_keys
-- |
-- | Ce script crée la configuration i18n_config avec le français comme langue par défaut
-- |
-- | Prérequis : La langue language:fr doit exister
-- | Utilisation : Exécuter ce script AVANT de tester la création d'un error_code
-- =============================================================================================

-- Récupérer le record de la langue française
LET $fr_language = SELECT * FROM language:fr LIMIT 1;

-- Créer la configuration i18n_config (seulement les champs obligatoires)
CREATE i18n_config SET
    config.default_language = $fr_language[0].id,
    config.fallback_language = $fr_language[0].id,
    metadata.updated_by = "system",
    metadata.description = "Configuration i18n pour les tests";

