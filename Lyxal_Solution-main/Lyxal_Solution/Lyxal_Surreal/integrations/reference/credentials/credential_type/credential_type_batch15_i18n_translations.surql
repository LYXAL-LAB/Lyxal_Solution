-- =============================================================================================
-- |
-- | Fichier : credential_type_batch15_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 15 des credential types.
-- |
-- | Batch 15 : CMS, ERP & Database Management (11 credentials)
-- | Providers : Contentful, Strapi, Storyblok, Odoo, ERPNext, Grist, SeaTable, QuickBase, Stackby
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- CONTENTFUL API
-- =====================================================

RELATE i18n_key:credential_type_contentful_api_name->translation->language:fr SET text = "Contentful API";
RELATE i18n_key:credential_type_contentful_api_name->translation->language:en SET text = "Contentful API";
RELATE i18n_key:credential_type_contentful_api_name->translation->language:it SET text = "Contentful API";
RELATE i18n_key:credential_type_contentful_api_name->translation->language:de SET text = "Contentful API";
RELATE i18n_key:credential_type_contentful_api_name->translation->language:es SET text = "Contentful API";

RELATE i18n_key:credential_type_contentful_api_description->translation->language:fr SET text = "Authentification par tokens API pour Contentful. Headless CMS enterprise avec Delivery API et Preview API pour contenu.";
RELATE i18n_key:credential_type_contentful_api_description->translation->language:en SET text = "API tokens authentication for Contentful. Enterprise headless CMS with Delivery API and Preview API for content.";
RELATE i18n_key:credential_type_contentful_api_description->translation->language:it SET text = "Autenticazione tramite token API per Contentful. Headless CMS enterprise con Delivery API e Preview API per contenuti.";
RELATE i18n_key:credential_type_contentful_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Contentful. Enterprise Headless CMS mit Delivery API und Preview API für Inhalte.";
RELATE i18n_key:credential_type_contentful_api_description->translation->language:es SET text = "Autenticación mediante tokens API para Contentful. Headless CMS enterprise con Delivery API y Preview API para contenido.";

RELATE i18n_key:credential_type_contentful_api_tooltip->translation->language:fr SET text = "Pour Contentful headless CMS";
RELATE i18n_key:credential_type_contentful_api_tooltip->translation->language:en SET text = "For Contentful headless CMS";
RELATE i18n_key:credential_type_contentful_api_tooltip->translation->language:it SET text = "Per Contentful headless CMS";
RELATE i18n_key:credential_type_contentful_api_tooltip->translation->language:de SET text = "Für Contentful Headless CMS";
RELATE i18n_key:credential_type_contentful_api_tooltip->translation->language:es SET text = "Para Contentful headless CMS";

-- =====================================================
-- STRAPI API
-- =====================================================

RELATE i18n_key:credential_type_strapi_api_name->translation->language:fr SET text = "Strapi API";
RELATE i18n_key:credential_type_strapi_api_name->translation->language:en SET text = "Strapi API";
RELATE i18n_key:credential_type_strapi_api_name->translation->language:it SET text = "Strapi API";
RELATE i18n_key:credential_type_strapi_api_name->translation->language:de SET text = "Strapi API";
RELATE i18n_key:credential_type_strapi_api_name->translation->language:es SET text = "Strapi API";

RELATE i18n_key:credential_type_strapi_api_description->translation->language:fr SET text = "Authentification par email et mot de passe pour Strapi. Headless CMS open-source auto-hébergé avec API v3 et v4.";
RELATE i18n_key:credential_type_strapi_api_description->translation->language:en SET text = "Email and password authentication for Strapi. Open-source self-hosted headless CMS with API v3 and v4.";
RELATE i18n_key:credential_type_strapi_api_description->translation->language:it SET text = "Autenticazione tramite email e password per Strapi. Headless CMS open-source self-hosted con API v3 e v4.";
RELATE i18n_key:credential_type_strapi_api_description->translation->language:de SET text = "E-Mail- und Passwort-Authentifizierung für Strapi. Open-Source-selbstgehostetes Headless CMS mit API v3 und v4.";
RELATE i18n_key:credential_type_strapi_api_description->translation->language:es SET text = "Autenticación mediante email y contraseña para Strapi. Headless CMS open-source auto-alojado con API v3 y v4.";

RELATE i18n_key:credential_type_strapi_api_tooltip->translation->language:fr SET text = "Pour Strapi CMS open-source";
RELATE i18n_key:credential_type_strapi_api_tooltip->translation->language:en SET text = "For Strapi open-source CMS";
RELATE i18n_key:credential_type_strapi_api_tooltip->translation->language:it SET text = "Per Strapi CMS open-source";
RELATE i18n_key:credential_type_strapi_api_tooltip->translation->language:de SET text = "Für Strapi Open-Source-CMS";
RELATE i18n_key:credential_type_strapi_api_tooltip->translation->language:es SET text = "Para Strapi CMS open-source";

-- =====================================================
-- STRAPI TOKEN API
-- =====================================================

RELATE i18n_key:credential_type_strapi_token_api_name->translation->language:fr SET text = "Strapi API Token";
RELATE i18n_key:credential_type_strapi_token_api_name->translation->language:en SET text = "Strapi API Token";
RELATE i18n_key:credential_type_strapi_token_api_name->translation->language:it SET text = "Strapi API Token";
RELATE i18n_key:credential_type_strapi_token_api_name->translation->language:de SET text = "Strapi API Token";
RELATE i18n_key:credential_type_strapi_token_api_name->translation->language:es SET text = "Strapi API Token";

RELATE i18n_key:credential_type_strapi_token_api_description->translation->language:fr SET text = "Authentification par token API pour Strapi. Méthode recommandée pour accès programmatique avec bearer token.";
RELATE i18n_key:credential_type_strapi_token_api_description->translation->language:en SET text = "API token authentication for Strapi. Recommended method for programmatic access with bearer token.";
RELATE i18n_key:credential_type_strapi_token_api_description->translation->language:it SET text = "Autenticazione tramite token API per Strapi. Metodo raccomandato per accesso programmatico con bearer token.";
RELATE i18n_key:credential_type_strapi_token_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Strapi. Empfohlene Methode für programmatischen Zugriff mit Bearer-Token.";
RELATE i18n_key:credential_type_strapi_token_api_description->translation->language:es SET text = "Autenticación mediante token API para Strapi. Método recomendado para acceso programático con bearer token.";

RELATE i18n_key:credential_type_strapi_token_api_tooltip->translation->language:fr SET text = "Pour Strapi accès API token";
RELATE i18n_key:credential_type_strapi_token_api_tooltip->translation->language:en SET text = "For Strapi API token access";
RELATE i18n_key:credential_type_strapi_token_api_tooltip->translation->language:it SET text = "Per Strapi accesso token API";
RELATE i18n_key:credential_type_strapi_token_api_tooltip->translation->language:de SET text = "Für Strapi API-Token-Zugriff";
RELATE i18n_key:credential_type_strapi_token_api_tooltip->translation->language:es SET text = "Para Strapi acceso token API";

-- =====================================================
-- STORYBLOK CONTENT API
-- =====================================================

RELATE i18n_key:credential_type_storyblok_content_api_name->translation->language:fr SET text = "Storyblok Content API";
RELATE i18n_key:credential_type_storyblok_content_api_name->translation->language:en SET text = "Storyblok Content API";
RELATE i18n_key:credential_type_storyblok_content_api_name->translation->language:it SET text = "Storyblok Content API";
RELATE i18n_key:credential_type_storyblok_content_api_name->translation->language:de SET text = "Storyblok Content API";
RELATE i18n_key:credential_type_storyblok_content_api_name->translation->language:es SET text = "Storyblok Content API";

RELATE i18n_key:credential_type_storyblok_content_api_description->translation->language:fr SET text = "Authentification par clé API publique pour Storyblok Content. Headless CMS avec éditeur visuel et accès lecture seule contenu.";
RELATE i18n_key:credential_type_storyblok_content_api_description->translation->language:en SET text = "Public API key authentication for Storyblok Content. Headless CMS with visual editor and read-only content access.";
RELATE i18n_key:credential_type_storyblok_content_api_description->translation->language:it SET text = "Autenticazione tramite chiave API pubblica per Storyblok Content. Headless CMS con editor visuale e accesso contenuti sola lettura.";
RELATE i18n_key:credential_type_storyblok_content_api_description->translation->language:de SET text = "Öffentliche API-Schlüssel-Authentifizierung für Storyblok Content. Headless CMS mit visuellem Editor und Nur-Lese-Inhaltszugriff.";
RELATE i18n_key:credential_type_storyblok_content_api_description->translation->language:es SET text = "Autenticación mediante clave API pública para Storyblok Content. Headless CMS con editor visual y acceso contenido solo lectura.";

RELATE i18n_key:credential_type_storyblok_content_api_tooltip->translation->language:fr SET text = "Pour Storyblok lecture contenu";
RELATE i18n_key:credential_type_storyblok_content_api_tooltip->translation->language:en SET text = "For Storyblok content reading";
RELATE i18n_key:credential_type_storyblok_content_api_tooltip->translation->language:it SET text = "Per Storyblok lettura contenuti";
RELATE i18n_key:credential_type_storyblok_content_api_tooltip->translation->language:de SET text = "Für Storyblok Inhaltslesen";
RELATE i18n_key:credential_type_storyblok_content_api_tooltip->translation->language:es SET text = "Para Storyblok lectura contenido";

-- =====================================================
-- STORYBLOK MANAGEMENT API
-- =====================================================

RELATE i18n_key:credential_type_storyblok_management_api_name->translation->language:fr SET text = "Storyblok Management API";
RELATE i18n_key:credential_type_storyblok_management_api_name->translation->language:en SET text = "Storyblok Management API";
RELATE i18n_key:credential_type_storyblok_management_api_name->translation->language:it SET text = "Storyblok Management API";
RELATE i18n_key:credential_type_storyblok_management_api_name->translation->language:de SET text = "Storyblok Management API";
RELATE i18n_key:credential_type_storyblok_management_api_name->translation->language:es SET text = "Storyblok Management API";

RELATE i18n_key:credential_type_storyblok_management_api_description->translation->language:fr SET text = "Authentification par token personnel pour Storyblok Management. Accès complet lecture/écriture pour gestion contenu et configuration.";
RELATE i18n_key:credential_type_storyblok_management_api_description->translation->language:en SET text = "Personal token authentication for Storyblok Management. Full read/write access for content management and configuration.";
RELATE i18n_key:credential_type_storyblok_management_api_description->translation->language:it SET text = "Autenticazione tramite token personale per Storyblok Management. Accesso completo lettura/scrittura per gestione contenuti e configurazione.";
RELATE i18n_key:credential_type_storyblok_management_api_description->translation->language:de SET text = "Persönliche Token-Authentifizierung für Storyblok Management. Vollständiger Lese-/Schreibzugriff für Inhaltsverwaltung und Konfiguration.";
RELATE i18n_key:credential_type_storyblok_management_api_description->translation->language:es SET text = "Autenticación mediante token personal para Storyblok Management. Acceso completo lectura/escritura para gestión contenido y configuración.";

RELATE i18n_key:credential_type_storyblok_management_api_tooltip->translation->language:fr SET text = "Pour Storyblok gestion complète";
RELATE i18n_key:credential_type_storyblok_management_api_tooltip->translation->language:en SET text = "For Storyblok full management";
RELATE i18n_key:credential_type_storyblok_management_api_tooltip->translation->language:it SET text = "Per Storyblok gestione completa";
RELATE i18n_key:credential_type_storyblok_management_api_tooltip->translation->language:de SET text = "Für Storyblok vollständige Verwaltung";
RELATE i18n_key:credential_type_storyblok_management_api_tooltip->translation->language:es SET text = "Para Storyblok gestión completa";

-- =====================================================
-- ODOO API
-- =====================================================

RELATE i18n_key:credential_type_odoo_api_name->translation->language:fr SET text = "Odoo API";
RELATE i18n_key:credential_type_odoo_api_name->translation->language:en SET text = "Odoo API";
RELATE i18n_key:credential_type_odoo_api_name->translation->language:it SET text = "Odoo API";
RELATE i18n_key:credential_type_odoo_api_name->translation->language:de SET text = "Odoo API";
RELATE i18n_key:credential_type_odoo_api_name->translation->language:es SET text = "Odoo API";

RELATE i18n_key:credential_type_odoo_api_description->translation->language:fr SET text = "Authentification par nom utilisateur et mot de passe pour Odoo. ERP open-source tout-en-un pour gestion entreprise complète.";
RELATE i18n_key:credential_type_odoo_api_description->translation->language:en SET text = "Username and password authentication for Odoo. Open-source all-in-one ERP for complete business management.";
RELATE i18n_key:credential_type_odoo_api_description->translation->language:it SET text = "Autenticazione tramite nome utente e password per Odoo. ERP open-source tutto-in-uno per gestione aziendale completa.";
RELATE i18n_key:credential_type_odoo_api_description->translation->language:de SET text = "Benutzername- und Passwort-Authentifizierung für Odoo. Open-Source-All-in-One-ERP für vollständiges Geschäftsmanagement.";
RELATE i18n_key:credential_type_odoo_api_description->translation->language:es SET text = "Autenticación mediante nombre usuario y contraseña para Odoo. ERP open-source todo-en-uno para gestión empresarial completa.";

RELATE i18n_key:credential_type_odoo_api_tooltip->translation->language:fr SET text = "Pour Odoo ERP open-source";
RELATE i18n_key:credential_type_odoo_api_tooltip->translation->language:en SET text = "For Odoo open-source ERP";
RELATE i18n_key:credential_type_odoo_api_tooltip->translation->language:it SET text = "Per Odoo ERP open-source";
RELATE i18n_key:credential_type_odoo_api_tooltip->translation->language:de SET text = "Für Odoo Open-Source-ERP";
RELATE i18n_key:credential_type_odoo_api_tooltip->translation->language:es SET text = "Para Odoo ERP open-source";

-- =====================================================
-- ERPNEXT API
-- =====================================================

RELATE i18n_key:credential_type_erpnext_api_name->translation->language:fr SET text = "ERPNext API";
RELATE i18n_key:credential_type_erpnext_api_name->translation->language:en SET text = "ERPNext API";
RELATE i18n_key:credential_type_erpnext_api_name->translation->language:it SET text = "ERPNext API";
RELATE i18n_key:credential_type_erpnext_api_name->translation->language:de SET text = "ERPNext API";
RELATE i18n_key:credential_type_erpnext_api_name->translation->language:es SET text = "ERPNext API";

RELATE i18n_key:credential_type_erpnext_api_description->translation->language:fr SET text = "Authentification par clés API pour ERPNext. ERP open-source basé Frappe Framework pour PME avec cloud ou auto-hébergement.";
RELATE i18n_key:credential_type_erpnext_api_description->translation->language:en SET text = "API keys authentication for ERPNext. Open-source ERP based on Frappe Framework for SMEs with cloud or self-hosting.";
RELATE i18n_key:credential_type_erpnext_api_description->translation->language:it SET text = "Autenticazione tramite chiavi API per ERPNext. ERP open-source basato su Frappe Framework per PMI con cloud o self-hosting.";
RELATE i18n_key:credential_type_erpnext_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für ERPNext. Open-Source-ERP basierend auf Frappe Framework für KMU mit Cloud oder Self-Hosting.";
RELATE i18n_key:credential_type_erpnext_api_description->translation->language:es SET text = "Autenticación mediante claves API para ERPNext. ERP open-source basado en Frappe Framework para PYMES con cloud o auto-alojamiento.";

RELATE i18n_key:credential_type_erpnext_api_tooltip->translation->language:fr SET text = "Pour ERPNext ERP Frappe";
RELATE i18n_key:credential_type_erpnext_api_tooltip->translation->language:en SET text = "For ERPNext Frappe ERP";
RELATE i18n_key:credential_type_erpnext_api_tooltip->translation->language:it SET text = "Per ERPNext ERP Frappe";
RELATE i18n_key:credential_type_erpnext_api_tooltip->translation->language:de SET text = "Für ERPNext Frappe ERP";
RELATE i18n_key:credential_type_erpnext_api_tooltip->translation->language:es SET text = "Para ERPNext ERP Frappe";

-- =====================================================
-- GRIST API
-- =====================================================

RELATE i18n_key:credential_type_grist_api_name->translation->language:fr SET text = "Grist API";
RELATE i18n_key:credential_type_grist_api_name->translation->language:en SET text = "Grist API";
RELATE i18n_key:credential_type_grist_api_name->translation->language:it SET text = "Grist API";
RELATE i18n_key:credential_type_grist_api_name->translation->language:de SET text = "Grist API";
RELATE i18n_key:credential_type_grist_api_name->translation->language:es SET text = "Grist API";

RELATE i18n_key:credential_type_grist_api_description->translation->language:fr SET text = "Authentification par clé API pour Grist. Spreadsheet-database open-source combinant spreadsheet et base données relationnelle.";
RELATE i18n_key:credential_type_grist_api_description->translation->language:en SET text = "API key authentication for Grist. Open-source spreadsheet-database combining spreadsheet and relational database.";
RELATE i18n_key:credential_type_grist_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Grist. Spreadsheet-database open-source combinando foglio calcolo e database relazionale.";
RELATE i18n_key:credential_type_grist_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Grist. Open-Source-Spreadsheet-Datenbank, die Spreadsheet und relationale Datenbank kombiniert.";
RELATE i18n_key:credential_type_grist_api_description->translation->language:es SET text = "Autenticación mediante clave API para Grist. Spreadsheet-database open-source combinando hoja cálculo y base datos relacional.";

RELATE i18n_key:credential_type_grist_api_tooltip->translation->language:fr SET text = "Pour Grist spreadsheet-database";
RELATE i18n_key:credential_type_grist_api_tooltip->translation->language:en SET text = "For Grist spreadsheet-database";
RELATE i18n_key:credential_type_grist_api_tooltip->translation->language:it SET text = "Per Grist spreadsheet-database";
RELATE i18n_key:credential_type_grist_api_tooltip->translation->language:de SET text = "Für Grist Spreadsheet-Datenbank";
RELATE i18n_key:credential_type_grist_api_tooltip->translation->language:es SET text = "Para Grist spreadsheet-database";

-- =====================================================
-- SEATABLE API
-- =====================================================

RELATE i18n_key:credential_type_seatable_api_name->translation->language:fr SET text = "SeaTable API";
RELATE i18n_key:credential_type_seatable_api_name->translation->language:en SET text = "SeaTable API";
RELATE i18n_key:credential_type_seatable_api_name->translation->language:it SET text = "SeaTable API";
RELATE i18n_key:credential_type_seatable_api_name->translation->language:de SET text = "SeaTable API";
RELATE i18n_key:credential_type_seatable_api_name->translation->language:es SET text = "SeaTable API";

RELATE i18n_key:credential_type_seatable_api_description->translation->language:fr SET text = "Authentification par token pour SeaTable. Spreadsheet-database collaborative pour organiser données et automatiser workflows.";
RELATE i18n_key:credential_type_seatable_api_description->translation->language:en SET text = "Token authentication for SeaTable. Collaborative spreadsheet-database to organize data and automate workflows.";
RELATE i18n_key:credential_type_seatable_api_description->translation->language:it SET text = "Autenticazione tramite token per SeaTable. Spreadsheet-database collaborativo per organizzare dati e automatizzare workflow.";
RELATE i18n_key:credential_type_seatable_api_description->translation->language:de SET text = "Token-Authentifizierung für SeaTable. Kollaborative Spreadsheet-Datenbank zum Organisieren von Daten und Automatisieren von Workflows.";
RELATE i18n_key:credential_type_seatable_api_description->translation->language:es SET text = "Autenticación mediante token para SeaTable. Spreadsheet-database colaborativa para organizar datos y automatizar workflows.";

RELATE i18n_key:credential_type_seatable_api_tooltip->translation->language:fr SET text = "Pour SeaTable collaborative database";
RELATE i18n_key:credential_type_seatable_api_tooltip->translation->language:en SET text = "For SeaTable collaborative database";
RELATE i18n_key:credential_type_seatable_api_tooltip->translation->language:it SET text = "Per SeaTable database collaborativo";
RELATE i18n_key:credential_type_seatable_api_tooltip->translation->language:de SET text = "Für SeaTable kollaborative Datenbank";
RELATE i18n_key:credential_type_seatable_api_tooltip->translation->language:es SET text = "Para SeaTable database colaborativa";

-- =====================================================
-- QUICKBASE API
-- =====================================================

RELATE i18n_key:credential_type_quickbase_api_name->translation->language:fr SET text = "QuickBase API";
RELATE i18n_key:credential_type_quickbase_api_name->translation->language:en SET text = "QuickBase API";
RELATE i18n_key:credential_type_quickbase_api_name->translation->language:it SET text = "QuickBase API";
RELATE i18n_key:credential_type_quickbase_api_name->translation->language:de SET text = "QuickBase API";
RELATE i18n_key:credential_type_quickbase_api_name->translation->language:es SET text = "QuickBase API";

RELATE i18n_key:credential_type_quickbase_api_description->translation->language:fr SET text = "Authentification par user token pour QuickBase. Plateforme no-code database enterprise pour applications métier personnalisées.";
RELATE i18n_key:credential_type_quickbase_api_description->translation->language:en SET text = "User token authentication for QuickBase. Enterprise no-code database platform for custom business applications.";
RELATE i18n_key:credential_type_quickbase_api_description->translation->language:it SET text = "Autenticazione tramite user token per QuickBase. Piattaforma no-code database enterprise per applicazioni business personalizzate.";
RELATE i18n_key:credential_type_quickbase_api_description->translation->language:de SET text = "Benutzertoken-Authentifizierung für QuickBase. Enterprise-No-Code-Datenbankplattform für benutzerdefinierte Geschäftsanwendungen.";
RELATE i18n_key:credential_type_quickbase_api_description->translation->language:es SET text = "Autenticación mediante user token para QuickBase. Plataforma no-code database enterprise para aplicaciones negocio personalizadas.";

RELATE i18n_key:credential_type_quickbase_api_tooltip->translation->language:fr SET text = "Pour QuickBase no-code database";
RELATE i18n_key:credential_type_quickbase_api_tooltip->translation->language:en SET text = "For QuickBase no-code database";
RELATE i18n_key:credential_type_quickbase_api_tooltip->translation->language:it SET text = "Per QuickBase no-code database";
RELATE i18n_key:credential_type_quickbase_api_tooltip->translation->language:de SET text = "Für QuickBase No-Code-Datenbank";
RELATE i18n_key:credential_type_quickbase_api_tooltip->translation->language:es SET text = "Para QuickBase no-code database";

-- =====================================================
-- STACKBY API
-- =====================================================

RELATE i18n_key:credential_type_stackby_api_name->translation->language:fr SET text = "Stackby API";
RELATE i18n_key:credential_type_stackby_api_name->translation->language:en SET text = "Stackby API";
RELATE i18n_key:credential_type_stackby_api_name->translation->language:it SET text = "Stackby API";
RELATE i18n_key:credential_type_stackby_api_name->translation->language:de SET text = "Stackby API";
RELATE i18n_key:credential_type_stackby_api_name->translation->language:es SET text = "Stackby API";

RELATE i18n_key:credential_type_stackby_api_description->translation->language:fr SET text = "Authentification par clé API pour Stackby. Spreadsheet-database avec automatisation workflows pour équipes collaboratives.";
RELATE i18n_key:credential_type_stackby_api_description->translation->language:en SET text = "API key authentication for Stackby. Spreadsheet-database with workflow automation for collaborative teams.";
RELATE i18n_key:credential_type_stackby_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Stackby. Spreadsheet-database con automazione workflow per team collaborativi.";
RELATE i18n_key:credential_type_stackby_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Stackby. Spreadsheet-Datenbank mit Workflow-Automatisierung für kollaborative Teams.";
RELATE i18n_key:credential_type_stackby_api_description->translation->language:es SET text = "Autenticación mediante clave API para Stackby. Spreadsheet-database con automatización workflows para equipos colaborativos.";

RELATE i18n_key:credential_type_stackby_api_tooltip->translation->language:fr SET text = "Pour Stackby database automation";
RELATE i18n_key:credential_type_stackby_api_tooltip->translation->language:en SET text = "For Stackby database automation";
RELATE i18n_key:credential_type_stackby_api_tooltip->translation->language:it SET text = "Per Stackby database automation";
RELATE i18n_key:credential_type_stackby_api_tooltip->translation->language:de SET text = "Für Stackby Datenbank-Automatisierung";
RELATE i18n_key:credential_type_stackby_api_tooltip->translation->language:es SET text = "Para Stackby database automation";

-- =============================================================================================

