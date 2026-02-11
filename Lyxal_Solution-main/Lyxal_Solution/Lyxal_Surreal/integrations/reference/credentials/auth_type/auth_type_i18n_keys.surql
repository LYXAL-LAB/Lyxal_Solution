-- =============================================================================================
-- |
-- | Fichier : auth_type_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > auth_type
-- | Description : Clés i18n pour le module auth_type.
-- |
-- | Ce fichier contient toutes les clés i18n nécessaires pour :
-- | • Noms des types d'authentification
-- | • Descriptions détaillées
-- | • Tooltips d'aide
-- | • Cas d'usage recommandés
-- | • Avantages
-- | • Inconvénients
-- |
-- | Types d'authentification couverts : 9
-- | • oauth2, oauth1, api_key, basic_auth, bearer_token
-- | • digest_auth, header_auth, query_auth, custom
-- |
-- | Total : 85 clés i18n (environ)
-- |
-- =============================================================================================

-- =====================================================
-- OAUTH2 (OAuth 2.0) - 9 clés
-- =====================================================

CREATE i18n_key:auth_type_oauth2_name SET
    description = "Nom affiché du type d'authentification OAuth 2.0";

CREATE i18n_key:auth_type_oauth2_description SET
    description = "Description complète d'OAuth 2.0";

CREATE i18n_key:auth_type_oauth2_tooltip SET
    description = "Tooltip d'aide pour OAuth 2.0";

CREATE i18n_key:auth_type_oauth2_usecase_user_auth SET
    description = "Cas d'usage : Authentification utilisateur";

CREATE i18n_key:auth_type_oauth2_usecase_third_party SET
    description = "Cas d'usage : Intégrations tierces";

CREATE i18n_key:auth_type_oauth2_advantage_secure SET
    description = "Avantage : Très sécurisé";

CREATE i18n_key:auth_type_oauth2_advantage_standard SET
    description = "Avantage : Standard de l'industrie";

CREATE i18n_key:auth_type_oauth2_disadvantage_complex SET
    description = "Inconvénient : Configuration complexe";

CREATE i18n_key:auth_type_oauth2_disadvantage_implementation SET
    description = "Inconvénient : Implémentation difficile pour débutants";

-- =====================================================
-- OAUTH1 (OAuth 1.0a) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_oauth1_name SET
    description = "Nom affiché du type d'authentification OAuth 1.0a";

CREATE i18n_key:auth_type_oauth1_description SET
    description = "Description complète d'OAuth 1.0a";

CREATE i18n_key:auth_type_oauth1_tooltip SET
    description = "Tooltip d'aide pour OAuth 1.0a";

CREATE i18n_key:auth_type_oauth1_usecase_legacy SET
    description = "Cas d'usage : APIs legacy (Twitter v1)";

CREATE i18n_key:auth_type_oauth1_usecase_signature SET
    description = "Cas d'usage : Authentification avec signature cryptographique";

CREATE i18n_key:auth_type_oauth1_advantage_secure SET
    description = "Avantage : Signature cryptographique sécurisée";

CREATE i18n_key:auth_type_oauth1_disadvantage_complex SET
    description = "Inconvénient : Très complexe à implémenter";

CREATE i18n_key:auth_type_oauth1_disadvantage_deprecated SET
    description = "Inconvénient : Déprécié en faveur d'OAuth 2.0";

-- =====================================================
-- API_KEY (API Key) - 9 clés
-- =====================================================

CREATE i18n_key:auth_type_api_key_name SET
    description = "Nom affiché du type d'authentification API Key";

CREATE i18n_key:auth_type_api_key_description SET
    description = "Description complète de l'authentification API Key";

CREATE i18n_key:auth_type_api_key_tooltip SET
    description = "Tooltip d'aide pour API Key";

CREATE i18n_key:auth_type_api_key_usecase_simple SET
    description = "Cas d'usage : APIs simples";

CREATE i18n_key:auth_type_api_key_usecase_automation SET
    description = "Cas d'usage : Scripts d'automation";

CREATE i18n_key:auth_type_api_key_advantage_simple SET
    description = "Avantage : Très simple à implémenter";

CREATE i18n_key:auth_type_api_key_advantage_popular SET
    description = "Avantage : Très populaire et bien supporté";

CREATE i18n_key:auth_type_api_key_disadvantage_security SET
    description = "Inconvénient : Sécurité moyenne";

CREATE i18n_key:auth_type_api_key_disadvantage_rotation SET
    description = "Inconvénient : Rotation manuelle des clés";

-- =====================================================
-- BASIC_AUTH (Basic Authentication) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_basic_auth_name SET
    description = "Nom affiché du type d'authentification Basic Authentication";

CREATE i18n_key:auth_type_basic_auth_description SET
    description = "Description complète de Basic Authentication";

CREATE i18n_key:auth_type_basic_auth_tooltip SET
    description = "Tooltip d'aide (avertissement sécurité) pour Basic Auth";

CREATE i18n_key:auth_type_basic_auth_usecase_internal SET
    description = "Cas d'usage : APIs internes";

CREATE i18n_key:auth_type_basic_auth_usecase_dev SET
    description = "Cas d'usage : Environnements de développement";

CREATE i18n_key:auth_type_basic_auth_advantage_simple SET
    description = "Avantage : Extrêmement simple";

CREATE i18n_key:auth_type_basic_auth_disadvantage_security SET
    description = "Inconvénient : Faible sécurité (credentials encodés en base64)";

CREATE i18n_key:auth_type_basic_auth_disadvantage_https SET
    description = "Inconvénient : HTTPS obligatoire";

-- =====================================================
-- BEARER_TOKEN (Bearer Token) - 9 clés
-- =====================================================

CREATE i18n_key:auth_type_bearer_token_name SET
    description = "Nom affiché du type d'authentification Bearer Token";

CREATE i18n_key:auth_type_bearer_token_description SET
    description = "Description complète de Bearer Token";

CREATE i18n_key:auth_type_bearer_token_tooltip SET
    description = "Tooltip d'aide pour Bearer Token";

CREATE i18n_key:auth_type_bearer_token_usecase_jwt SET
    description = "Cas d'usage : JWT tokens";

CREATE i18n_key:auth_type_bearer_token_usecase_session SET
    description = "Cas d'usage : Session tokens";

CREATE i18n_key:auth_type_bearer_token_advantage_simple SET
    description = "Avantage : Simple et standard";

CREATE i18n_key:auth_type_bearer_token_advantage_stateless SET
    description = "Avantage : Stateless";

CREATE i18n_key:auth_type_bearer_token_disadvantage_expiration SET
    description = "Inconvénient : Gestion de l'expiration nécessaire";

CREATE i18n_key:auth_type_bearer_token_disadvantage_theft SET
    description = "Inconvénient : Vulnérable au vol de token";

-- =====================================================
-- DIGEST_AUTH (Digest Authentication) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_digest_auth_name SET
    description = "Nom affiché du type d'authentification Digest Authentication";

CREATE i18n_key:auth_type_digest_auth_description SET
    description = "Description complète de Digest Authentication";

CREATE i18n_key:auth_type_digest_auth_tooltip SET
    description = "Tooltip d'aide pour Digest Auth";

CREATE i18n_key:auth_type_digest_auth_usecase_legacy SET
    description = "Cas d'usage : Systèmes legacy nécessitant plus de sécurité que Basic";

CREATE i18n_key:auth_type_digest_auth_usecase_http SET
    description = "Cas d'usage : HTTP sans TLS";

CREATE i18n_key:auth_type_digest_auth_advantage_secure SET
    description = "Avantage : Plus sécurisé que Basic Auth";

CREATE i18n_key:auth_type_digest_auth_disadvantage_unpopular SET
    description = "Inconvénient : Peu populaire";

CREATE i18n_key:auth_type_digest_auth_disadvantage_complex SET
    description = "Inconvénient : Plus complexe que Basic Auth";

-- =====================================================
-- HEADER_AUTH (Custom Header Authentication) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_header_auth_name SET
    description = "Nom affiché du type d'authentification Custom Header";

CREATE i18n_key:auth_type_header_auth_description SET
    description = "Description complète de Custom Header Authentication";

CREATE i18n_key:auth_type_header_auth_tooltip SET
    description = "Tooltip d'aide pour Custom Header";

CREATE i18n_key:auth_type_header_auth_usecase_proprietary SET
    description = "Cas d'usage : APIs propriétaires";

CREATE i18n_key:auth_type_header_auth_usecase_custom SET
    description = "Cas d'usage : Headers personnalisés (X-API-Token, etc.)";

CREATE i18n_key:auth_type_header_auth_advantage_flexible SET
    description = "Avantage : Flexible";

CREATE i18n_key:auth_type_header_auth_disadvantage_nonstandard SET
    description = "Inconvénient : Non-standard";

CREATE i18n_key:auth_type_header_auth_disadvantage_documentation SET
    description = "Inconvénient : Nécessite documentation spécifique";

-- =====================================================
-- QUERY_AUTH (Query Parameter Authentication) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_query_auth_name SET
    description = "Nom affiché du type d'authentification Query Parameter";

CREATE i18n_key:auth_type_query_auth_description SET
    description = "Description complète de Query Parameter Authentication";

CREATE i18n_key:auth_type_query_auth_tooltip SET
    description = "Tooltip d'avertissement pour Query Auth (sécurité faible)";

CREATE i18n_key:auth_type_query_auth_usecase_public SET
    description = "Cas d'usage : APIs publiques avec clés non sensibles";

CREATE i18n_key:auth_type_query_auth_usecase_embed SET
    description = "Cas d'usage : Widgets et embeds";

CREATE i18n_key:auth_type_query_auth_advantage_simple SET
    description = "Avantage : Très simple";

CREATE i18n_key:auth_type_query_auth_disadvantage_security SET
    description = "Inconvénient : Faible sécurité (visible dans URL)";

CREATE i18n_key:auth_type_query_auth_disadvantage_logs SET
    description = "Inconvénient : Exposé dans logs et historique";

-- =====================================================
-- CUSTOM (Custom Authentication) - 8 clés
-- =====================================================

CREATE i18n_key:auth_type_custom_name SET
    description = "Nom affiché du type d'authentification Custom";

CREATE i18n_key:auth_type_custom_description SET
    description = "Description complète de Custom Authentication";

CREATE i18n_key:auth_type_custom_tooltip SET
    description = "Tooltip d'aide pour Custom Auth";

CREATE i18n_key:auth_type_custom_usecase_proprietary SET
    description = "Cas d'usage : Protocoles propriétaires";

CREATE i18n_key:auth_type_custom_usecase_specialized SET
    description = "Cas d'usage : Systèmes spécialisés";

CREATE i18n_key:auth_type_custom_advantage_flexible SET
    description = "Avantage : Totalement flexible";

CREATE i18n_key:auth_type_custom_disadvantage_implementation SET
    description = "Inconvénient : Implémentation custom nécessaire";

CREATE i18n_key:auth_type_custom_disadvantage_maintenance SET
    description = "Inconvénient : Maintenance complexe";

-- =====================================================
-- VÉRIFICATION DES CLÉS CRÉÉES
-- =====================================================

/*
SELECT 
    id,
    description
FROM i18n_key
WHERE string::starts_with(meta::id(id), 'auth_type_')
ORDER BY id ASC;
*/

-- =====================================================
-- RÉSUMÉ DES CLÉS CRÉÉES
-- =====================================================
--
-- OAUTH2 (9 clés) : name, description, tooltip, 2 use cases, 2 advantages, 2 disadvantages
-- OAUTH1 (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
-- API_KEY (9 clés) : name, description, tooltip, 2 use cases, 2 advantages, 2 disadvantages
-- BASIC_AUTH (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
-- BEARER_TOKEN (9 clés) : name, description, tooltip, 2 use cases, 2 advantages, 2 disadvantages
-- DIGEST_AUTH (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
-- HEADER_AUTH (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
-- QUERY_AUTH (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
-- CUSTOM (8 clés) : name, description, tooltip, 2 use cases, 1 advantage, 2 disadvantages
--
-- TOTAL : 75 clés i18n
--
-- =============================================================================================

