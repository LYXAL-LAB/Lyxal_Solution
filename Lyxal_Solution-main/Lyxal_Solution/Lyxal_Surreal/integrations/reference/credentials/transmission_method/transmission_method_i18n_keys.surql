-- =============================================================================================
-- |
-- | Fichier : transmission_method_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > transmission_method
-- | Description : Clés i18n pour le module transmission_method.
-- |
-- | Ce fichier contient toutes les clés i18n nécessaires pour :
-- | • Noms des méthodes de transmission
-- | • Descriptions détaillées
-- | • Tooltips d'aide
-- | • Préoccupations de sécurité
-- | • Cas d'usage recommandés
-- | • Cas d'usage à éviter
-- |
-- | Total : 41 clés i18n
-- |
-- =============================================================================================

-- =====================================================
-- HEADER - Noms et descriptions (4 clés)
-- =====================================================

CREATE i18n_key:transmission_method_header_name SET
    description = "Nom affiché de la méthode de transmission HTTP Header";

CREATE i18n_key:transmission_method_header_description SET
    description = "Description complète de la méthode HTTP Header pour transmission de credentials";

CREATE i18n_key:transmission_method_header_tooltip SET
    description = "Tooltip d'aide pour la méthode HTTP Header (recommandée pour tokens sensibles)";

-- =====================================================
-- HEADER - Security Concerns (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_header_concern_proxy SET
    description = "Préoccupation : Les headers peuvent être modifiés par des proxies non sécurisés";

CREATE i18n_key:transmission_method_header_concern_logs SET
    description = "Préoccupation : Les headers sont visibles dans les logs serveur si non chiffrés";

CREATE i18n_key:transmission_method_header_concern_cache SET
    description = "Préoccupation : Les headers peuvent être mis en cache par des intermédiaires";

-- =====================================================
-- HEADER - Use Cases (4 clés)
-- =====================================================

CREATE i18n_key:transmission_method_header_usecase_bearer SET
    description = "Cas d'usage : Bearer tokens (OAuth2, JWT)";

CREATE i18n_key:transmission_method_header_usecase_apikey SET
    description = "Cas d'usage : Clés API secrètes";

CREATE i18n_key:transmission_method_header_usecase_oauth SET
    description = "Cas d'usage : Tokens d'accès OAuth";

CREATE i18n_key:transmission_method_header_usecase_sensitive SET
    description = "Cas d'usage : Credentials sensibles en général";

-- =====================================================
-- HEADER - Avoid Cases (1 clé)
-- =====================================================

CREATE i18n_key:transmission_method_header_avoid_large_payload SET
    description = "À éviter : Payloads très larges (préférer body)";

-- =====================================================
-- BODY - Noms et descriptions (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_body_name SET
    description = "Nom affiché de la méthode de transmission HTTP Body";

CREATE i18n_key:transmission_method_body_description SET
    description = "Description complète de la méthode HTTP Body pour transmission de credentials";

CREATE i18n_key:transmission_method_body_tooltip SET
    description = "Tooltip d'aide pour la méthode HTTP Body (pour données structurées)";

-- =====================================================
-- BODY - Security Concerns (2 clés)
-- =====================================================

CREATE i18n_key:transmission_method_body_concern_parsing SET
    description = "Préoccupation : Nécessite un parsing du body (coût performance)";

CREATE i18n_key:transmission_method_body_concern_content_type SET
    description = "Préoccupation : Nécessite un Content-Type spécifique";

-- =====================================================
-- BODY - Use Cases (4 clés)
-- =====================================================

CREATE i18n_key:transmission_method_body_usecase_complex SET
    description = "Cas d'usage : Payloads d'authentification complexes";

CREATE i18n_key:transmission_method_body_usecase_multipart SET
    description = "Cas d'usage : Credentials multi-parts";

CREATE i18n_key:transmission_method_body_usecase_certificate SET
    description = "Cas d'usage : Authentification par certificat";

CREATE i18n_key:transmission_method_body_usecase_login SET
    description = "Cas d'usage : Formulaires de login";

-- =====================================================
-- BODY - Avoid Cases (2 clés)
-- =====================================================

CREATE i18n_key:transmission_method_body_avoid_simple_key SET
    description = "À éviter : Clés API simples (préférer header)";

CREATE i18n_key:transmission_method_body_avoid_get_request SET
    description = "À éviter : Requêtes GET (body non-standard pour GET)";

-- =====================================================
-- QUERY - Noms et descriptions (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_query_name SET
    description = "Nom affiché de la méthode de transmission URL Query Parameters";

CREATE i18n_key:transmission_method_query_description SET
    description = "Description complète de la méthode Query Parameters pour transmission de credentials";

CREATE i18n_key:transmission_method_query_warning SET
    description = "Avertissement de sécurité pour Query Parameters (visible dans URL, logs, historique)";

-- =====================================================
-- QUERY - Security Concerns (6 clés)
-- =====================================================

CREATE i18n_key:transmission_method_query_concern_url_visible SET
    description = "Préoccupation CRITIQUE : Credentials visibles dans l'URL";

CREATE i18n_key:transmission_method_query_concern_browser_history SET
    description = "Préoccupation CRITIQUE : Credentials enregistrés dans l'historique du navigateur";

CREATE i18n_key:transmission_method_query_concern_server_logs SET
    description = "Préoccupation CRITIQUE : Credentials visibles dans les logs d'accès serveur";

CREATE i18n_key:transmission_method_query_concern_copy_paste SET
    description = "Préoccupation : Credentials peuvent être partagés accidentellement via copier-coller";

CREATE i18n_key:transmission_method_query_concern_referrer SET
    description = "Préoccupation : Credentials exposés via les headers Referrer";

CREATE i18n_key:transmission_method_query_concern_cdn_cache SET
    description = "Préoccupation : Credentials peuvent être mis en cache par CDN/proxies";

-- =====================================================
-- QUERY - Use Cases (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_query_usecase_public_key SET
    description = "Cas d'usage : Clés API publiques (non sensibles)";

CREATE i18n_key:transmission_method_query_usecase_temporary_token SET
    description = "Cas d'usage : Tokens temporaires avec TTL court";

CREATE i18n_key:transmission_method_query_usecase_webhook_signature SET
    description = "Cas d'usage : Signatures de webhooks";

-- =====================================================
-- QUERY - Avoid Cases (4 clés)
-- =====================================================

CREATE i18n_key:transmission_method_query_avoid_password SET
    description = "À ÉVITER ABSOLUMENT : Mots de passe en query parameters";

CREATE i18n_key:transmission_method_query_avoid_secret SET
    description = "À ÉVITER ABSOLUMENT : Tokens secrets en query parameters";

CREATE i18n_key:transmission_method_query_avoid_private_key SET
    description = "À ÉVITER ABSOLUMENT : Clés API privées en query parameters";

CREATE i18n_key:transmission_method_query_avoid_longlived SET
    description = "À ÉVITER : Credentials long-lived en query parameters";

-- =====================================================
-- CUSTOM - Noms et descriptions (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_custom_name SET
    description = "Nom affiché de la méthode de transmission Custom/Propriétaire";

CREATE i18n_key:transmission_method_custom_description SET
    description = "Description complète de la méthode Custom pour transmission de credentials";

CREATE i18n_key:transmission_method_custom_tooltip SET
    description = "Tooltip d'aide pour la méthode Custom (authentification propriétaire)";

-- =====================================================
-- CUSTOM - Security Concerns (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_custom_concern_nonstandard SET
    description = "Préoccupation : Implémentation non-standard (risque de bugs)";

CREATE i18n_key:transmission_method_custom_concern_validation SET
    description = "Préoccupation : Nécessite validation custom (complexité accrue)";

CREATE i18n_key:transmission_method_custom_concern_tooling SET
    description = "Préoccupation : Support limité par les outils et frameworks standards";

-- =====================================================
-- CUSTOM - Use Cases (3 clés)
-- =====================================================

CREATE i18n_key:transmission_method_custom_usecase_proprietary SET
    description = "Cas d'usage : Protocoles d'authentification propriétaires";

CREATE i18n_key:transmission_method_custom_usecase_legacy SET
    description = "Cas d'usage : Systèmes legacy avec authentification non-standard";

CREATE i18n_key:transmission_method_custom_usecase_specialized SET
    description = "Cas d'usage : Protocoles spécialisés (militaire, bancaire, etc.)";

-- =====================================================
-- CUSTOM - Avoid Cases (2 clés)
-- =====================================================

CREATE i18n_key:transmission_method_custom_avoid_rest SET
    description = "À éviter : APIs REST standards (préférer header ou body)";

CREATE i18n_key:transmission_method_custom_avoid_public SET
    description = "À éviter : APIs publiques standards (utiliser méthodes standards)";

-- =====================================================
-- VÉRIFICATION DES CLÉS CRÉÉES
-- =====================================================

/*
SELECT 
    id,
    description
FROM i18n_key
WHERE string::starts_with(meta::id(id), 'transmission_method_')
ORDER BY id ASC;
*/

-- =====================================================
-- RÉSUMÉ DES CLÉS CRÉÉES
-- =====================================================
--
-- HEADER (11 clés) :
--   • 4 : Noms, descriptions, tooltips
--   • 3 : Security concerns
--   • 4 : Use cases
--   • 1 : Avoid cases
--
-- BODY (11 clés) :
--   • 3 : Noms, descriptions, tooltips
--   • 2 : Security concerns
--   • 4 : Use cases
--   • 2 : Avoid cases
--
-- QUERY (16 clés) :
--   • 3 : Noms, descriptions, warnings
--   • 6 : Security concerns (CRITIQUES)
--   • 3 : Use cases
--   • 4 : Avoid cases (ABSOLUMENT)
--
-- CUSTOM (8 clés) :
--   • 3 : Noms, descriptions, tooltips
--   • 3 : Security concerns
--   • 3 : Use cases
--   • 2 : Avoid cases
--
-- TOTAL : 41 clés i18n
--
-- =====================================================
-- PROCHAINES ÉTAPES
-- =====================================================
--
-- 1. Créer les traductions dans i18n_translation :
--    - EN (English)
--    - FR (Français)
--    - ES (Español)
--    - DE (Deutsch)
--    - etc.
--
-- 2. Exemple de traduction pour transmission_method_header_name :
--    CREATE i18n_translation SET
--        key = i18n_key:transmission_method_header_name,
--        locale = i18n_locale:en,
--        value = "HTTP Header";
--
--    CREATE i18n_translation SET
--        key = i18n_key:transmission_method_header_name,
--        locale = i18n_locale:fr,
--        value = "En-tête HTTP";
--
-- =============================================================================================

