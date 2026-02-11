-- =============================================================================================
-- |
-- | Fichier : credential_type_batch14_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 14 des credential types.
-- |
-- | Batch 14 : No-Code, Analytics & Security Tools (11 credentials)
-- | Providers : Baserow, NocoDB, Grafana, Metabase, PostHog, Coda, Gong, Okta, Auth0
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- BASEROW API
-- =====================================================

RELATE i18n_key:credential_type_baserow_api_name->translation->language:fr SET text = "Baserow API";
RELATE i18n_key:credential_type_baserow_api_name->translation->language:en SET text = "Baserow API";
RELATE i18n_key:credential_type_baserow_api_name->translation->language:it SET text = "Baserow API";
RELATE i18n_key:credential_type_baserow_api_name->translation->language:de SET text = "Baserow API";
RELATE i18n_key:credential_type_baserow_api_name->translation->language:es SET text = "Baserow API";

RELATE i18n_key:credential_type_baserow_api_description->translation->language:fr SET text = "Authentification par nom utilisateur et mot de passe pour Baserow. Base de données no-code open-source alternative à Airtable.";
RELATE i18n_key:credential_type_baserow_api_description->translation->language:en SET text = "Username and password authentication for Baserow. Open-source no-code database alternative to Airtable.";
RELATE i18n_key:credential_type_baserow_api_description->translation->language:it SET text = "Autenticazione tramite nome utente e password per Baserow. Database no-code open-source alternativa ad Airtable.";
RELATE i18n_key:credential_type_baserow_api_description->translation->language:de SET text = "Benutzername- und Passwort-Authentifizierung für Baserow. Open-Source-No-Code-Datenbank-Alternative zu Airtable.";
RELATE i18n_key:credential_type_baserow_api_description->translation->language:es SET text = "Autenticación mediante nombre usuario y contraseña para Baserow. Base de datos no-code open-source alternativa a Airtable.";

RELATE i18n_key:credential_type_baserow_api_tooltip->translation->language:fr SET text = "Pour Baserow base données no-code";
RELATE i18n_key:credential_type_baserow_api_tooltip->translation->language:en SET text = "For Baserow no-code database";
RELATE i18n_key:credential_type_baserow_api_tooltip->translation->language:it SET text = "Per Baserow database no-code";
RELATE i18n_key:credential_type_baserow_api_tooltip->translation->language:de SET text = "Für Baserow No-Code-Datenbank";
RELATE i18n_key:credential_type_baserow_api_tooltip->translation->language:es SET text = "Para Baserow base datos no-code";

-- =====================================================
-- NOCODB
-- =====================================================

RELATE i18n_key:credential_type_nocodb_name->translation->language:fr SET text = "NocoDB";
RELATE i18n_key:credential_type_nocodb_name->translation->language:en SET text = "NocoDB";
RELATE i18n_key:credential_type_nocodb_name->translation->language:it SET text = "NocoDB";
RELATE i18n_key:credential_type_nocodb_name->translation->language:de SET text = "NocoDB";
RELATE i18n_key:credential_type_nocodb_name->translation->language:es SET text = "NocoDB";

RELATE i18n_key:credential_type_nocodb_description->translation->language:fr SET text = "Authentification par token utilisateur pour NocoDB. Transforme bases de données MySQL, PostgreSQL, SQL Server en interface no-code.";
RELATE i18n_key:credential_type_nocodb_description->translation->language:en SET text = "User token authentication for NocoDB. Transforms MySQL, PostgreSQL, SQL Server databases into no-code interface.";
RELATE i18n_key:credential_type_nocodb_description->translation->language:it SET text = "Autenticazione tramite token utente per NocoDB. Trasforma database MySQL, PostgreSQL, SQL Server in interfaccia no-code.";
RELATE i18n_key:credential_type_nocodb_description->translation->language:de SET text = "Benutzertoken-Authentifizierung für NocoDB. Verwandelt MySQL-, PostgreSQL-, SQL Server-Datenbanken in No-Code-Schnittstelle.";
RELATE i18n_key:credential_type_nocodb_description->translation->language:es SET text = "Autenticación mediante token usuario para NocoDB. Transforma bases de datos MySQL, PostgreSQL, SQL Server en interfaz no-code.";

RELATE i18n_key:credential_type_nocodb_tooltip->translation->language:fr SET text = "Pour NocoDB base données no-code";
RELATE i18n_key:credential_type_nocodb_tooltip->translation->language:en SET text = "For NocoDB no-code database";
RELATE i18n_key:credential_type_nocodb_tooltip->translation->language:it SET text = "Per NocoDB database no-code";
RELATE i18n_key:credential_type_nocodb_tooltip->translation->language:de SET text = "Für NocoDB No-Code-Datenbank";
RELATE i18n_key:credential_type_nocodb_tooltip->translation->language:es SET text = "Para NocoDB base datos no-code";

-- =====================================================
-- NOCODB API TOKEN
-- =====================================================

RELATE i18n_key:credential_type_nocodb_api_token_name->translation->language:fr SET text = "NocoDB API Token";
RELATE i18n_key:credential_type_nocodb_api_token_name->translation->language:en SET text = "NocoDB API Token";
RELATE i18n_key:credential_type_nocodb_api_token_name->translation->language:it SET text = "NocoDB API Token";
RELATE i18n_key:credential_type_nocodb_api_token_name->translation->language:de SET text = "NocoDB API Token";
RELATE i18n_key:credential_type_nocodb_api_token_name->translation->language:es SET text = "NocoDB API Token";

RELATE i18n_key:credential_type_nocodb_api_token_description->translation->language:fr SET text = "Authentification par token API pour NocoDB. Accès limité au projet spécifique associé au token (project-scoped).";
RELATE i18n_key:credential_type_nocodb_api_token_description->translation->language:en SET text = "API token authentication for NocoDB. Access limited to specific project associated with token (project-scoped).";
RELATE i18n_key:credential_type_nocodb_api_token_description->translation->language:it SET text = "Autenticazione tramite token API per NocoDB. Accesso limitato al progetto specifico associato al token (project-scoped).";
RELATE i18n_key:credential_type_nocodb_api_token_description->translation->language:de SET text = "API-Token-Authentifizierung für NocoDB. Zugriff auf das mit dem Token verbundene spezifische Projekt begrenzt (project-scoped).";
RELATE i18n_key:credential_type_nocodb_api_token_description->translation->language:es SET text = "Autenticación mediante token API para NocoDB. Acceso limitado al proyecto específico asociado al token (project-scoped).";

RELATE i18n_key:credential_type_nocodb_api_token_tooltip->translation->language:fr SET text = "Pour NocoDB accès projet spécifique";
RELATE i18n_key:credential_type_nocodb_api_token_tooltip->translation->language:en SET text = "For NocoDB specific project access";
RELATE i18n_key:credential_type_nocodb_api_token_tooltip->translation->language:it SET text = "Per NocoDB accesso progetto specifico";
RELATE i18n_key:credential_type_nocodb_api_token_tooltip->translation->language:de SET text = "Für NocoDB spezifischen Projektzugriff";
RELATE i18n_key:credential_type_nocodb_api_token_tooltip->translation->language:es SET text = "Para NocoDB acceso proyecto específico";

-- =====================================================
-- GRAFANA API
-- =====================================================

RELATE i18n_key:credential_type_grafana_api_name->translation->language:fr SET text = "Grafana API";
RELATE i18n_key:credential_type_grafana_api_name->translation->language:en SET text = "Grafana API";
RELATE i18n_key:credential_type_grafana_api_name->translation->language:it SET text = "Grafana API";
RELATE i18n_key:credential_type_grafana_api_name->translation->language:de SET text = "Grafana API";
RELATE i18n_key:credential_type_grafana_api_name->translation->language:es SET text = "Grafana API";

RELATE i18n_key:credential_type_grafana_api_description->translation->language:fr SET text = "Authentification par clé API pour Grafana. Plateforme monitoring et visualisation pour dashboards métriques et observabilité.";
RELATE i18n_key:credential_type_grafana_api_description->translation->language:en SET text = "API key authentication for Grafana. Monitoring and visualization platform for metrics dashboards and observability.";
RELATE i18n_key:credential_type_grafana_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Grafana. Piattaforma monitoring e visualizzazione per dashboard metriche e osservabilità.";
RELATE i18n_key:credential_type_grafana_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Grafana. Monitoring- und Visualisierungsplattform für Metriken-Dashboards und Observability.";
RELATE i18n_key:credential_type_grafana_api_description->translation->language:es SET text = "Autenticación mediante clave API para Grafana. Plataforma monitoring y visualización para dashboards métricas y observabilidad.";

RELATE i18n_key:credential_type_grafana_api_tooltip->translation->language:fr SET text = "Pour Grafana dashboards monitoring";
RELATE i18n_key:credential_type_grafana_api_tooltip->translation->language:en SET text = "For Grafana monitoring dashboards";
RELATE i18n_key:credential_type_grafana_api_tooltip->translation->language:it SET text = "Per Grafana dashboard monitoring";
RELATE i18n_key:credential_type_grafana_api_tooltip->translation->language:de SET text = "Für Grafana Monitoring-Dashboards";
RELATE i18n_key:credential_type_grafana_api_tooltip->translation->language:es SET text = "Para Grafana dashboards monitoring";

-- =====================================================
-- METABASE API
-- =====================================================

RELATE i18n_key:credential_type_metabase_api_name->translation->language:fr SET text = "Metabase API";
RELATE i18n_key:credential_type_metabase_api_name->translation->language:en SET text = "Metabase API";
RELATE i18n_key:credential_type_metabase_api_name->translation->language:it SET text = "Metabase API";
RELATE i18n_key:credential_type_metabase_api_name->translation->language:de SET text = "Metabase API";
RELATE i18n_key:credential_type_metabase_api_name->translation->language:es SET text = "Metabase API";

RELATE i18n_key:credential_type_metabase_api_description->translation->language:fr SET text = "Authentification par session pour Metabase. Plateforme Business Intelligence open-source pour analyse données et visualisations.";
RELATE i18n_key:credential_type_metabase_api_description->translation->language:en SET text = "Session authentication for Metabase. Open-source Business Intelligence platform for data analytics and visualizations.";
RELATE i18n_key:credential_type_metabase_api_description->translation->language:it SET text = "Autenticazione tramite sessione per Metabase. Piattaforma Business Intelligence open-source per analisi dati e visualizzazioni.";
RELATE i18n_key:credential_type_metabase_api_description->translation->language:de SET text = "Sitzungsauthentifizierung für Metabase. Open-Source-Business-Intelligence-Plattform für Datenanalyse und Visualisierungen.";
RELATE i18n_key:credential_type_metabase_api_description->translation->language:es SET text = "Autenticación mediante sesión para Metabase. Plataforma Business Intelligence open-source para análisis datos y visualizaciones.";

RELATE i18n_key:credential_type_metabase_api_tooltip->translation->language:fr SET text = "Pour Metabase BI analytics";
RELATE i18n_key:credential_type_metabase_api_tooltip->translation->language:en SET text = "For Metabase BI analytics";
RELATE i18n_key:credential_type_metabase_api_tooltip->translation->language:it SET text = "Per Metabase BI analytics";
RELATE i18n_key:credential_type_metabase_api_tooltip->translation->language:de SET text = "Für Metabase BI-Analytics";
RELATE i18n_key:credential_type_metabase_api_tooltip->translation->language:es SET text = "Para Metabase BI analytics";

-- =====================================================
-- POSTHOG API
-- =====================================================

RELATE i18n_key:credential_type_posthog_api_name->translation->language:fr SET text = "PostHog API";
RELATE i18n_key:credential_type_posthog_api_name->translation->language:en SET text = "PostHog API";
RELATE i18n_key:credential_type_posthog_api_name->translation->language:it SET text = "PostHog API";
RELATE i18n_key:credential_type_posthog_api_name->translation->language:de SET text = "PostHog API";
RELATE i18n_key:credential_type_posthog_api_name->translation->language:es SET text = "PostHog API";

RELATE i18n_key:credential_type_posthog_api_description->translation->language:fr SET text = "Authentification par clé API pour PostHog. Plateforme product analytics open-source avec feature flags et enregistrement sessions.";
RELATE i18n_key:credential_type_posthog_api_description->translation->language:en SET text = "API key authentication for PostHog. Open-source product analytics platform with feature flags and session recording.";
RELATE i18n_key:credential_type_posthog_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per PostHog. Piattaforma product analytics open-source con feature flags e registrazione sessioni.";
RELATE i18n_key:credential_type_posthog_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für PostHog. Open-Source-Produktanalyseplattform mit Feature Flags und Sitzungsaufzeichnung.";
RELATE i18n_key:credential_type_posthog_api_description->translation->language:es SET text = "Autenticación mediante clave API para PostHog. Plataforma product analytics open-source con feature flags y grabación sesiones.";

RELATE i18n_key:credential_type_posthog_api_tooltip->translation->language:fr SET text = "Pour PostHog analytics produit";
RELATE i18n_key:credential_type_posthog_api_tooltip->translation->language:en SET text = "For PostHog product analytics";
RELATE i18n_key:credential_type_posthog_api_tooltip->translation->language:it SET text = "Per PostHog product analytics";
RELATE i18n_key:credential_type_posthog_api_tooltip->translation->language:de SET text = "Für PostHog Produktanalyse";
RELATE i18n_key:credential_type_posthog_api_tooltip->translation->language:es SET text = "Para PostHog analytics producto";

-- =====================================================
-- CODA API
-- =====================================================

RELATE i18n_key:credential_type_coda_api_name->translation->language:fr SET text = "Coda API";
RELATE i18n_key:credential_type_coda_api_name->translation->language:en SET text = "Coda API";
RELATE i18n_key:credential_type_coda_api_name->translation->language:it SET text = "Coda API";
RELATE i18n_key:credential_type_coda_api_name->translation->language:de SET text = "Coda API";
RELATE i18n_key:credential_type_coda_api_name->translation->language:es SET text = "Coda API";

RELATE i18n_key:credential_type_coda_api_description->translation->language:fr SET text = "Authentification par token d'accès pour Coda. Plateforme documents collaboratifs tout-en-un combinant docs, spreadsheets et apps.";
RELATE i18n_key:credential_type_coda_api_description->translation->language:en SET text = "Access token authentication for Coda. All-in-one collaborative documents platform combining docs, spreadsheets and apps.";
RELATE i18n_key:credential_type_coda_api_description->translation->language:it SET text = "Autenticazione tramite token accesso per Coda. Piattaforma documenti collaborativi tutto-in-uno combinando doc, spreadsheet e app.";
RELATE i18n_key:credential_type_coda_api_description->translation->language:de SET text = "Access-Token-Authentifizierung für Coda. All-in-One-Plattform für kollaborative Dokumente, die Docs, Spreadsheets und Apps kombiniert.";
RELATE i18n_key:credential_type_coda_api_description->translation->language:es SET text = "Autenticación mediante token acceso para Coda. Plataforma documentos colaborativos todo-en-uno combinando docs, spreadsheets y apps.";

RELATE i18n_key:credential_type_coda_api_tooltip->translation->language:fr SET text = "Pour Coda documents collaboratifs";
RELATE i18n_key:credential_type_coda_api_tooltip->translation->language:en SET text = "For Coda collaborative documents";
RELATE i18n_key:credential_type_coda_api_tooltip->translation->language:it SET text = "Per Coda documenti collaborativi";
RELATE i18n_key:credential_type_coda_api_tooltip->translation->language:de SET text = "Für Coda kollaborative Dokumente";
RELATE i18n_key:credential_type_coda_api_tooltip->translation->language:es SET text = "Para Coda documentos colaborativos";

-- =====================================================
-- GONG API
-- =====================================================

RELATE i18n_key:credential_type_gong_api_name->translation->language:fr SET text = "Gong API";
RELATE i18n_key:credential_type_gong_api_name->translation->language:en SET text = "Gong API";
RELATE i18n_key:credential_type_gong_api_name->translation->language:it SET text = "Gong API";
RELATE i18n_key:credential_type_gong_api_name->translation->language:de SET text = "Gong API";
RELATE i18n_key:credential_type_gong_api_name->translation->language:es SET text = "Gong API";

RELATE i18n_key:credential_type_gong_api_description->translation->language:fr SET text = "Authentification par clés d'accès pour Gong. Plateforme revenue intelligence et analyse conversations commerciales pour ventes.";
RELATE i18n_key:credential_type_gong_api_description->translation->language:en SET text = "Access keys authentication for Gong. Revenue intelligence and sales conversation analytics platform.";
RELATE i18n_key:credential_type_gong_api_description->translation->language:it SET text = "Autenticazione tramite chiavi accesso per Gong. Piattaforma revenue intelligence e analisi conversazioni commerciali per vendite.";
RELATE i18n_key:credential_type_gong_api_description->translation->language:de SET text = "Zugriffsschlüssel-Authentifizierung für Gong. Revenue-Intelligence- und Vertriebsgesprächs-Analyseplattform.";
RELATE i18n_key:credential_type_gong_api_description->translation->language:es SET text = "Autenticación mediante claves acceso para Gong. Plataforma revenue intelligence y análisis conversaciones comerciales para ventas.";

RELATE i18n_key:credential_type_gong_api_tooltip->translation->language:fr SET text = "Pour Gong revenue intelligence";
RELATE i18n_key:credential_type_gong_api_tooltip->translation->language:en SET text = "For Gong revenue intelligence";
RELATE i18n_key:credential_type_gong_api_tooltip->translation->language:it SET text = "Per Gong revenue intelligence";
RELATE i18n_key:credential_type_gong_api_tooltip->translation->language:de SET text = "Für Gong Revenue Intelligence";
RELATE i18n_key:credential_type_gong_api_tooltip->translation->language:es SET text = "Para Gong revenue intelligence";

-- =====================================================
-- GONG OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_gong_oauth2_api_name->translation->language:fr SET text = "Gong OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_name->translation->language:en SET text = "Gong OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_name->translation->language:it SET text = "Gong OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_name->translation->language:de SET text = "Gong OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_name->translation->language:es SET text = "Gong OAuth2";

RELATE i18n_key:credential_type_gong_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Gong. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_gong_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Gong. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_gong_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Gong. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_gong_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Gong. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_gong_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Gong. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_gong_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Gong avec OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_tooltip->translation->language:en SET text = "For third-party Gong apps with OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Gong con OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Gong-Apps mit OAuth2";
RELATE i18n_key:credential_type_gong_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Gong con OAuth2";

-- =====================================================
-- OKTA API
-- =====================================================

RELATE i18n_key:credential_type_okta_api_name->translation->language:fr SET text = "Okta API";
RELATE i18n_key:credential_type_okta_api_name->translation->language:en SET text = "Okta API";
RELATE i18n_key:credential_type_okta_api_name->translation->language:it SET text = "Okta API";
RELATE i18n_key:credential_type_okta_api_name->translation->language:de SET text = "Okta API";
RELATE i18n_key:credential_type_okta_api_name->translation->language:es SET text = "Okta API";

RELATE i18n_key:credential_type_okta_api_description->translation->language:fr SET text = "Authentification SSWS pour Okta. Plateforme leader gestion identité et Single Sign-On (SSO) pour entreprises.";
RELATE i18n_key:credential_type_okta_api_description->translation->language:en SET text = "SSWS authentication for Okta. Leading identity management and Single Sign-On (SSO) platform for enterprises.";
RELATE i18n_key:credential_type_okta_api_description->translation->language:it SET text = "Autenticazione SSWS per Okta. Piattaforma leader gestione identità e Single Sign-On (SSO) per aziende.";
RELATE i18n_key:credential_type_okta_api_description->translation->language:de SET text = "SSWS-Authentifizierung für Okta. Führende Identitätsmanagement- und Single-Sign-On (SSO)-Plattform für Unternehmen.";
RELATE i18n_key:credential_type_okta_api_description->translation->language:es SET text = "Autenticación SSWS para Okta. Plataforma líder gestión identidad y Single Sign-On (SSO) para empresas.";

RELATE i18n_key:credential_type_okta_api_tooltip->translation->language:fr SET text = "Pour Okta IAM et SSO";
RELATE i18n_key:credential_type_okta_api_tooltip->translation->language:en SET text = "For Okta IAM and SSO";
RELATE i18n_key:credential_type_okta_api_tooltip->translation->language:it SET text = "Per Okta IAM e SSO";
RELATE i18n_key:credential_type_okta_api_tooltip->translation->language:de SET text = "Für Okta IAM und SSO";
RELATE i18n_key:credential_type_okta_api_tooltip->translation->language:es SET text = "Para Okta IAM y SSO";

-- =====================================================
-- AUTH0 MANAGEMENT API
-- =====================================================

RELATE i18n_key:credential_type_auth0_management_api_name->translation->language:fr SET text = "Auth0 Management API";
RELATE i18n_key:credential_type_auth0_management_api_name->translation->language:en SET text = "Auth0 Management API";
RELATE i18n_key:credential_type_auth0_management_api_name->translation->language:it SET text = "Auth0 Management API";
RELATE i18n_key:credential_type_auth0_management_api_name->translation->language:de SET text = "Auth0 Management API";
RELATE i18n_key:credential_type_auth0_management_api_name->translation->language:es SET text = "Auth0 Management API";

RELATE i18n_key:credential_type_auth0_management_api_description->translation->language:fr SET text = "Authentification Client Credentials pour Auth0. Plateforme moderne authentification et gestion identité avec OAuth2.";
RELATE i18n_key:credential_type_auth0_management_api_description->translation->language:en SET text = "Client Credentials authentication for Auth0. Modern authentication and identity management platform with OAuth2.";
RELATE i18n_key:credential_type_auth0_management_api_description->translation->language:it SET text = "Autenticazione Client Credentials per Auth0. Piattaforma moderna autenticazione e gestione identità con OAuth2.";
RELATE i18n_key:credential_type_auth0_management_api_description->translation->language:de SET text = "Client-Credentials-Authentifizierung für Auth0. Moderne Authentifizierungs- und Identitätsmanagementplattform mit OAuth2.";
RELATE i18n_key:credential_type_auth0_management_api_description->translation->language:es SET text = "Autenticación Client Credentials para Auth0. Plataforma moderna autenticación y gestión identidad con OAuth2.";

RELATE i18n_key:credential_type_auth0_management_api_tooltip->translation->language:fr SET text = "Pour Auth0 gestion identité";
RELATE i18n_key:credential_type_auth0_management_api_tooltip->translation->language:en SET text = "For Auth0 identity management";
RELATE i18n_key:credential_type_auth0_management_api_tooltip->translation->language:it SET text = "Per Auth0 gestione identità";
RELATE i18n_key:credential_type_auth0_management_api_tooltip->translation->language:de SET text = "Für Auth0 Identitätsmanagement";
RELATE i18n_key:credential_type_auth0_management_api_tooltip->translation->language:es SET text = "Para Auth0 gestión identidad";

-- =============================================================================================
