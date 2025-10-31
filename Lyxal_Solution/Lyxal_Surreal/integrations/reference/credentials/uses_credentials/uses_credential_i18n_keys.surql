-- =============================================================================================
-- |
-- | Fichier : uses_credential_i18n_keys.surql
-- | Module : integrations > reference > credentials > uses_credential
-- | Description : Clés i18n génériques et réutilisables pour uses_credential.
-- |
-- | Ces clés permettent de personnaliser les labels et descriptions des credentials
-- | dans différents contextes d'utilisation (recommandé, développement, production, etc.)
-- |
-- | Total : 20 clés i18n génériques
-- |
-- =============================================================================================

-- =====================================================
-- LABELS GÉNÉRIQUES (pour custom_label_i18n)
-- =====================================================

CREATE i18n_key:uses_cred_oauth2_recommended SET
    description = "Label générique : OAuth2 (Recommandé)";

CREATE i18n_key:uses_cred_oauth2_standard SET
    description = "Label générique : OAuth2 (Standard)";

CREATE i18n_key:uses_cred_api_dev_only SET
    description = "Label générique : API Key (Développement uniquement)";

CREATE i18n_key:uses_cred_api_alternative SET
    description = "Label générique : API Key (Alternative)";

CREATE i18n_key:uses_cred_token_legacy SET
    description = "Label générique : Token (Legacy)";

CREATE i18n_key:uses_cred_token_advanced SET
    description = "Label générique : Token (Avancé)";

CREATE i18n_key:uses_cred_basic_auth_simple SET
    description = "Label générique : Basic Auth (Simple)";

CREATE i18n_key:uses_cred_service_account_automation SET
    description = "Label générique : Service Account (Automation)";

-- =====================================================
-- DESCRIPTIONS GÉNÉRIQUES (pour custom_description_i18n)
-- =====================================================

CREATE i18n_key:uses_cred_desc_oauth2_recommended SET
    description = "Description générique : OAuth2 est recommandé pour la plupart des cas";

CREATE i18n_key:uses_cred_desc_oauth2_secure SET
    description = "Description générique : OAuth2 offre une sécurité optimale";

CREATE i18n_key:uses_cred_desc_api_quick_integration SET
    description = "Description générique : API Key pour intégration rapide";

CREATE i18n_key:uses_cred_desc_api_dev_test SET
    description = "Description générique : API Key pour développement et tests uniquement";

CREATE i18n_key:uses_cred_desc_token_legacy_use SET
    description = "Description générique : Token legacy, OAuth2 recommandé pour nouvelles intégrations";

CREATE i18n_key:uses_cred_desc_basic_auth_simple SET
    description = "Description générique : Basic Auth pour une configuration simple";

CREATE i18n_key:uses_cred_desc_service_account_automation SET
    description = "Description générique : Service Account pour automatisation serveur sans interaction utilisateur";

CREATE i18n_key:uses_cred_desc_production_ready SET
    description = "Description générique : Prêt pour la production";

CREATE i18n_key:uses_cred_desc_high_security SET
    description = "Description générique : Configuration haute sécurité requise";

CREATE i18n_key:uses_cred_desc_enterprise_only SET
    description = "Description générique : Réservé aux comptes entreprise";

CREATE i18n_key:uses_cred_desc_deprecated_warning SET
    description = "Description générique : Cette méthode est dépréciée, migrez vers OAuth2";

CREATE i18n_key:uses_cred_desc_free_tier_compatible SET
    description = "Description générique : Compatible avec le plan gratuit";
