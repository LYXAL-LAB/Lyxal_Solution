-- =============================================================================================
-- |
-- | Fichier : uses_credential_i18n_translations.surql
-- | Module : integrations > reference > credentials > uses_credential
-- | Description : Traductions des clés i18n génériques pour uses_credential.
-- |
-- | Support de 5 langues : FR, EN, IT, DE, ES
-- | Total : 100 traductions (20 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- LABELS GÉNÉRIQUES
-- =====================================================

-- OAuth2 (Recommandé)
RELATE i18n_key:uses_cred_oauth2_recommended->translation->language:fr SET text = "OAuth2 (Recommandé)";
RELATE i18n_key:uses_cred_oauth2_recommended->translation->language:en SET text = "OAuth2 (Recommended)";
RELATE i18n_key:uses_cred_oauth2_recommended->translation->language:it SET text = "OAuth2 (Consigliato)";
RELATE i18n_key:uses_cred_oauth2_recommended->translation->language:de SET text = "OAuth2 (Empfohlen)";
RELATE i18n_key:uses_cred_oauth2_recommended->translation->language:es SET text = "OAuth2 (Recomendado)";

-- OAuth2 (Standard)
RELATE i18n_key:uses_cred_oauth2_standard->translation->language:fr SET text = "OAuth2 (Standard)";
RELATE i18n_key:uses_cred_oauth2_standard->translation->language:en SET text = "OAuth2 (Standard)";
RELATE i18n_key:uses_cred_oauth2_standard->translation->language:it SET text = "OAuth2 (Standard)";
RELATE i18n_key:uses_cred_oauth2_standard->translation->language:de SET text = "OAuth2 (Standard)";
RELATE i18n_key:uses_cred_oauth2_standard->translation->language:es SET text = "OAuth2 (Estándar)";

-- API Key (Développement uniquement)
RELATE i18n_key:uses_cred_api_dev_only->translation->language:fr SET text = "Clé API (Développement uniquement)";
RELATE i18n_key:uses_cred_api_dev_only->translation->language:en SET text = "API Key (Development only)";
RELATE i18n_key:uses_cred_api_dev_only->translation->language:it SET text = "Chiave API (Solo sviluppo)";
RELATE i18n_key:uses_cred_api_dev_only->translation->language:de SET text = "API-Schlüssel (Nur Entwicklung)";
RELATE i18n_key:uses_cred_api_dev_only->translation->language:es SET text = "Clave API (Solo desarrollo)";

-- API Key (Alternative)
RELATE i18n_key:uses_cred_api_alternative->translation->language:fr SET text = "Clé API (Alternative)";
RELATE i18n_key:uses_cred_api_alternative->translation->language:en SET text = "API Key (Alternative)";
RELATE i18n_key:uses_cred_api_alternative->translation->language:it SET text = "Chiave API (Alternativa)";
RELATE i18n_key:uses_cred_api_alternative->translation->language:de SET text = "API-Schlüssel (Alternative)";
RELATE i18n_key:uses_cred_api_alternative->translation->language:es SET text = "Clave API (Alternativa)";

-- Token (Legacy)
RELATE i18n_key:uses_cred_token_legacy->translation->language:fr SET text = "Token (Legacy)";
RELATE i18n_key:uses_cred_token_legacy->translation->language:en SET text = "Token (Legacy)";
RELATE i18n_key:uses_cred_token_legacy->translation->language:it SET text = "Token (Legacy)";
RELATE i18n_key:uses_cred_token_legacy->translation->language:de SET text = "Token (Legacy)";
RELATE i18n_key:uses_cred_token_legacy->translation->language:es SET text = "Token (Legacy)";

-- Token (Avancé)
RELATE i18n_key:uses_cred_token_advanced->translation->language:fr SET text = "Token (Avancé)";
RELATE i18n_key:uses_cred_token_advanced->translation->language:en SET text = "Token (Advanced)";
RELATE i18n_key:uses_cred_token_advanced->translation->language:it SET text = "Token (Avanzato)";
RELATE i18n_key:uses_cred_token_advanced->translation->language:de SET text = "Token (Erweitert)";
RELATE i18n_key:uses_cred_token_advanced->translation->language:es SET text = "Token (Avanzado)";

-- Basic Auth (Simple)
RELATE i18n_key:uses_cred_basic_auth_simple->translation->language:fr SET text = "Authentification Basic (Simple)";
RELATE i18n_key:uses_cred_basic_auth_simple->translation->language:en SET text = "Basic Auth (Simple)";
RELATE i18n_key:uses_cred_basic_auth_simple->translation->language:it SET text = "Autenticazione Basic (Semplice)";
RELATE i18n_key:uses_cred_basic_auth_simple->translation->language:de SET text = "Basic Auth (Einfach)";
RELATE i18n_key:uses_cred_basic_auth_simple->translation->language:es SET text = "Autenticación Basic (Simple)";

-- Service Account (Automation)
RELATE i18n_key:uses_cred_service_account_automation->translation->language:fr SET text = "Compte de service (Automation)";
RELATE i18n_key:uses_cred_service_account_automation->translation->language:en SET text = "Service Account (Automation)";
RELATE i18n_key:uses_cred_service_account_automation->translation->language:it SET text = "Account di servizio (Automazione)";
RELATE i18n_key:uses_cred_service_account_automation->translation->language:de SET text = "Dienstkonto (Automatisierung)";
RELATE i18n_key:uses_cred_service_account_automation->translation->language:es SET text = "Cuenta de servicio (Automatización)";

-- =====================================================
-- DESCRIPTIONS GÉNÉRIQUES
-- =====================================================

-- OAuth2 est recommandé pour la plupart des cas
RELATE i18n_key:uses_cred_desc_oauth2_recommended->translation->language:fr SET text = "OAuth2 est la méthode d'authentification recommandée pour la plupart des cas d'usage.";
RELATE i18n_key:uses_cred_desc_oauth2_recommended->translation->language:en SET text = "OAuth2 is the recommended authentication method for most use cases.";
RELATE i18n_key:uses_cred_desc_oauth2_recommended->translation->language:it SET text = "OAuth2 è il metodo di autenticazione consigliato per la maggior parte dei casi d'uso.";
RELATE i18n_key:uses_cred_desc_oauth2_recommended->translation->language:de SET text = "OAuth2 ist die empfohlene Authentifizierungsmethode für die meisten Anwendungsfälle.";
RELATE i18n_key:uses_cred_desc_oauth2_recommended->translation->language:es SET text = "OAuth2 es el método de autenticación recomendado para la mayoría de los casos de uso.";

-- OAuth2 offre une sécurité optimale
RELATE i18n_key:uses_cred_desc_oauth2_secure->translation->language:fr SET text = "OAuth2 offre une sécurité optimale et une expérience utilisateur fluide.";
RELATE i18n_key:uses_cred_desc_oauth2_secure->translation->language:en SET text = "OAuth2 provides optimal security and a seamless user experience.";
RELATE i18n_key:uses_cred_desc_oauth2_secure->translation->language:it SET text = "OAuth2 offre sicurezza ottimale e un'esperienza utente fluida.";
RELATE i18n_key:uses_cred_desc_oauth2_secure->translation->language:de SET text = "OAuth2 bietet optimale Sicherheit und ein nahtloses Benutzererlebnis.";
RELATE i18n_key:uses_cred_desc_oauth2_secure->translation->language:es SET text = "OAuth2 ofrece seguridad óptima y una experiencia de usuario fluida.";

-- API Key pour intégration rapide
RELATE i18n_key:uses_cred_desc_api_quick_integration->translation->language:fr SET text = "Utilisez une clé API pour une intégration rapide et directe.";
RELATE i18n_key:uses_cred_desc_api_quick_integration->translation->language:en SET text = "Use an API key for quick and direct integration.";
RELATE i18n_key:uses_cred_desc_api_quick_integration->translation->language:it SET text = "Utilizza una chiave API per un'integrazione rapida e diretta.";
RELATE i18n_key:uses_cred_desc_api_quick_integration->translation->language:de SET text = "Verwenden Sie einen API-Schlüssel für schnelle und direkte Integration.";
RELATE i18n_key:uses_cred_desc_api_quick_integration->translation->language:es SET text = "Use una clave API para una integración rápida y directa.";

-- API Key pour développement et tests
RELATE i18n_key:uses_cred_desc_api_dev_test->translation->language:fr SET text = "Utilisez une clé API pour le développement et les tests. OAuth2 est recommandé pour la production.";
RELATE i18n_key:uses_cred_desc_api_dev_test->translation->language:en SET text = "Use an API key for development and testing. OAuth2 is recommended for production.";
RELATE i18n_key:uses_cred_desc_api_dev_test->translation->language:it SET text = "Utilizza una chiave API per lo sviluppo e i test. OAuth2 è consigliato per la produzione.";
RELATE i18n_key:uses_cred_desc_api_dev_test->translation->language:de SET text = "Verwenden Sie einen API-Schlüssel für Entwicklung und Tests. OAuth2 wird für die Produktion empfohlen.";
RELATE i18n_key:uses_cred_desc_api_dev_test->translation->language:es SET text = "Use una clave API para desarrollo y pruebas. OAuth2 es recomendado para producción.";

-- Token legacy
RELATE i18n_key:uses_cred_desc_token_legacy_use->translation->language:fr SET text = "Méthode legacy. OAuth2 est fortement recommandé pour les nouvelles intégrations.";
RELATE i18n_key:uses_cred_desc_token_legacy_use->translation->language:en SET text = "Legacy method. OAuth2 is strongly recommended for new integrations.";
RELATE i18n_key:uses_cred_desc_token_legacy_use->translation->language:it SET text = "Metodo legacy. OAuth2 è fortemente consigliato per le nuove integrazioni.";
RELATE i18n_key:uses_cred_desc_token_legacy_use->translation->language:de SET text = "Legacy-Methode. OAuth2 wird für neue Integrationen dringend empfohlen.";
RELATE i18n_key:uses_cred_desc_token_legacy_use->translation->language:es SET text = "Método legacy. OAuth2 es fuertemente recomendado para nuevas integraciones.";

-- Basic Auth simple
RELATE i18n_key:uses_cred_desc_basic_auth_simple->translation->language:fr SET text = "Authentification Basic pour une configuration simple et rapide.";
RELATE i18n_key:uses_cred_desc_basic_auth_simple->translation->language:en SET text = "Basic authentication for simple and quick setup.";
RELATE i18n_key:uses_cred_desc_basic_auth_simple->translation->language:it SET text = "Autenticazione Basic per una configurazione semplice e rapida.";
RELATE i18n_key:uses_cred_desc_basic_auth_simple->translation->language:de SET text = "Basic-Authentifizierung für einfache und schnelle Einrichtung.";
RELATE i18n_key:uses_cred_desc_basic_auth_simple->translation->language:es SET text = "Autenticación Basic para una configuración simple y rápida.";

-- Service Account automation
RELATE i18n_key:uses_cred_desc_service_account_automation->translation->language:fr SET text = "Compte de service pour l'automatisation serveur sans interaction utilisateur.";
RELATE i18n_key:uses_cred_desc_service_account_automation->translation->language:en SET text = "Service account for server automation without user interaction.";
RELATE i18n_key:uses_cred_desc_service_account_automation->translation->language:it SET text = "Account di servizio per l'automazione server senza interazione utente.";
RELATE i18n_key:uses_cred_desc_service_account_automation->translation->language:de SET text = "Dienstkonto für Server-Automatisierung ohne Benutzerinteraktion.";
RELATE i18n_key:uses_cred_desc_service_account_automation->translation->language:es SET text = "Cuenta de servicio para automatización de servidor sin interacción del usuario.";

-- Production ready
RELATE i18n_key:uses_cred_desc_production_ready->translation->language:fr SET text = "Prêt pour un déploiement en production.";
RELATE i18n_key:uses_cred_desc_production_ready->translation->language:en SET text = "Ready for production deployment.";
RELATE i18n_key:uses_cred_desc_production_ready->translation->language:it SET text = "Pronto per il deployment in produzione.";
RELATE i18n_key:uses_cred_desc_production_ready->translation->language:de SET text = "Bereit für den Produktionseinsatz.";
RELATE i18n_key:uses_cred_desc_production_ready->translation->language:es SET text = "Listo para despliegue en producción.";

-- High security
RELATE i18n_key:uses_cred_desc_high_security->translation->language:fr SET text = "Configuration haute sécurité requise. Recommandé pour les données sensibles.";
RELATE i18n_key:uses_cred_desc_high_security->translation->language:en SET text = "High security configuration required. Recommended for sensitive data.";
RELATE i18n_key:uses_cred_desc_high_security->translation->language:it SET text = "Configurazione ad alta sicurezza richiesta. Consigliato per dati sensibili.";
RELATE i18n_key:uses_cred_desc_high_security->translation->language:de SET text = "Hochsicherheitskonfiguration erforderlich. Empfohlen für sensible Daten.";
RELATE i18n_key:uses_cred_desc_high_security->translation->language:es SET text = "Configuración de alta seguridad requerida. Recomendado para datos sensibles.";

-- Enterprise only
RELATE i18n_key:uses_cred_desc_enterprise_only->translation->language:fr SET text = "Disponible uniquement pour les comptes entreprise.";
RELATE i18n_key:uses_cred_desc_enterprise_only->translation->language:en SET text = "Available only for enterprise accounts.";
RELATE i18n_key:uses_cred_desc_enterprise_only->translation->language:it SET text = "Disponibile solo per account enterprise.";
RELATE i18n_key:uses_cred_desc_enterprise_only->translation->language:de SET text = "Nur für Enterprise-Konten verfügbar.";
RELATE i18n_key:uses_cred_desc_enterprise_only->translation->language:es SET text = "Disponible solo para cuentas empresariales.";

-- Deprecated warning
RELATE i18n_key:uses_cred_desc_deprecated_warning->translation->language:fr SET text = "⚠️ Cette méthode est dépréciée. Migrez vers OAuth2 dès que possible.";
RELATE i18n_key:uses_cred_desc_deprecated_warning->translation->language:en SET text = "⚠️ This method is deprecated. Migrate to OAuth2 as soon as possible.";
RELATE i18n_key:uses_cred_desc_deprecated_warning->translation->language:it SET text = "⚠️ Questo metodo è deprecato. Migra a OAuth2 il prima possibile.";
RELATE i18n_key:uses_cred_desc_deprecated_warning->translation->language:de SET text = "⚠️ Diese Methode ist veraltet. Migrieren Sie so bald wie möglich zu OAuth2.";
RELATE i18n_key:uses_cred_desc_deprecated_warning->translation->language:es SET text = "⚠️ Este método está obsoleto. Migre a OAuth2 lo antes posible.";

-- Free tier compatible
RELATE i18n_key:uses_cred_desc_free_tier_compatible->translation->language:fr SET text = "Compatible avec le plan gratuit.";
RELATE i18n_key:uses_cred_desc_free_tier_compatible->translation->language:en SET text = "Compatible with the free plan.";
RELATE i18n_key:uses_cred_desc_free_tier_compatible->translation->language:it SET text = "Compatibile con il piano gratuito.";
RELATE i18n_key:uses_cred_desc_free_tier_compatible->translation->language:de SET text = "Kompatibel mit dem kostenlosen Plan.";
RELATE i18n_key:uses_cred_desc_free_tier_compatible->translation->language:es SET text = "Compatible con el plan gratuito.";
