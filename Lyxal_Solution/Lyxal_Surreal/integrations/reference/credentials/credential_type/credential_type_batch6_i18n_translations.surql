-- =============================================================================================
-- |
-- | Fichier : credential_type_batch6_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 6 des credential types.
-- |
-- | Batch 6 : Top Business/CRM (17 credentials)
-- | Providers : HubSpot, Salesforce, Stripe, Shopify, Pipedrive, Zoho, Copper, ActiveCampaign, Mailchimp
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 255 traductions (51 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- HUBSPOT API
-- =====================================================

RELATE i18n_key:credential_type_hubspot_api_name->translation->language:fr SET text = "HubSpot API";
RELATE i18n_key:credential_type_hubspot_api_name->translation->language:en SET text = "HubSpot API";
RELATE i18n_key:credential_type_hubspot_api_name->translation->language:it SET text = "HubSpot API";
RELATE i18n_key:credential_type_hubspot_api_name->translation->language:de SET text = "HubSpot API";
RELATE i18n_key:credential_type_hubspot_api_name->translation->language:es SET text = "HubSpot API";

RELATE i18n_key:credential_type_hubspot_api_description->translation->language:fr SET text = "Authentification par API key pour HubSpot. Plateforme CRM, marketing automation et sales pour gérer contacts, leads et automatiser campagnes.";
RELATE i18n_key:credential_type_hubspot_api_description->translation->language:en SET text = "API key authentication for HubSpot. CRM, marketing automation, and sales platform for managing contacts, leads, and automating campaigns.";
RELATE i18n_key:credential_type_hubspot_api_description->translation->language:it SET text = "Autenticazione tramite API key per HubSpot. Piattaforma CRM, marketing automation e vendite per gestire contatti, lead e automatizzare campagne.";
RELATE i18n_key:credential_type_hubspot_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für HubSpot. CRM-, Marketingautomatisierungs- und Vertriebsplattform zur Verwaltung von Kontakten, Leads und Automatisierung von Kampagnen.";
RELATE i18n_key:credential_type_hubspot_api_description->translation->language:es SET text = "Autenticación mediante API key para HubSpot. Plataforma CRM, automatización marketing y ventas para gestionar contactos, leads y automatizar campañas.";

RELATE i18n_key:credential_type_hubspot_api_tooltip->translation->language:fr SET text = "Pour CRM HubSpot et marketing automation";
RELATE i18n_key:credential_type_hubspot_api_tooltip->translation->language:en SET text = "For HubSpot CRM and marketing automation";
RELATE i18n_key:credential_type_hubspot_api_tooltip->translation->language:it SET text = "Per CRM HubSpot e marketing automation";
RELATE i18n_key:credential_type_hubspot_api_tooltip->translation->language:de SET text = "Für HubSpot CRM und Marketing-Automatisierung";
RELATE i18n_key:credential_type_hubspot_api_tooltip->translation->language:es SET text = "Para CRM HubSpot y automatización marketing";

-- =====================================================
-- HUBSPOT APP TOKEN
-- =====================================================

RELATE i18n_key:credential_type_hubspot_app_token_name->translation->language:fr SET text = "HubSpot App Token";
RELATE i18n_key:credential_type_hubspot_app_token_name->translation->language:en SET text = "HubSpot App Token";
RELATE i18n_key:credential_type_hubspot_app_token_name->translation->language:it SET text = "HubSpot App Token";
RELATE i18n_key:credential_type_hubspot_app_token_name->translation->language:de SET text = "HubSpot App Token";
RELATE i18n_key:credential_type_hubspot_app_token_name->translation->language:es SET text = "HubSpot App Token";

RELATE i18n_key:credential_type_hubspot_app_token_description->translation->language:fr SET text = "Authentification par App Token pour HubSpot. Méthode recommandée pour intégrations privées avec accès granulaire aux scopes.";
RELATE i18n_key:credential_type_hubspot_app_token_description->translation->language:en SET text = "App Token authentication for HubSpot. Recommended method for private integrations with granular scope access.";
RELATE i18n_key:credential_type_hubspot_app_token_description->translation->language:it SET text = "Autenticazione tramite App Token per HubSpot. Metodo consigliato per integrazioni private con accesso granulare agli scope.";
RELATE i18n_key:credential_type_hubspot_app_token_description->translation->language:de SET text = "App-Token-Authentifizierung für HubSpot. Empfohlene Methode für private Integrationen mit granularem Scope-Zugriff.";
RELATE i18n_key:credential_type_hubspot_app_token_description->translation->language:es SET text = "Autenticación mediante App Token para HubSpot. Método recomendado para integraciones privadas con acceso granular scopes.";

RELATE i18n_key:credential_type_hubspot_app_token_tooltip->translation->language:fr SET text = "Recommandé pour intégrations privées HubSpot";
RELATE i18n_key:credential_type_hubspot_app_token_tooltip->translation->language:en SET text = "Recommended for private HubSpot integrations";
RELATE i18n_key:credential_type_hubspot_app_token_tooltip->translation->language:it SET text = "Consigliato per integrazioni private HubSpot";
RELATE i18n_key:credential_type_hubspot_app_token_tooltip->translation->language:de SET text = "Empfohlen für private HubSpot-Integrationen";
RELATE i18n_key:credential_type_hubspot_app_token_tooltip->translation->language:es SET text = "Recomendado para integraciones privadas HubSpot";

-- =====================================================
-- HUBSPOT DEVELOPER API
-- =====================================================

RELATE i18n_key:credential_type_hubspot_developer_api_name->translation->language:fr SET text = "HubSpot Developer API";
RELATE i18n_key:credential_type_hubspot_developer_api_name->translation->language:en SET text = "HubSpot Developer API";
RELATE i18n_key:credential_type_hubspot_developer_api_name->translation->language:it SET text = "HubSpot Developer API";
RELATE i18n_key:credential_type_hubspot_developer_api_name->translation->language:de SET text = "HubSpot Developer API";
RELATE i18n_key:credential_type_hubspot_developer_api_name->translation->language:es SET text = "HubSpot Developer API";

RELATE i18n_key:credential_type_hubspot_developer_api_description->translation->language:fr SET text = "Authentification Developer API pour HubSpot. Pour applications marketplace HubSpot avec authentification développeur.";
RELATE i18n_key:credential_type_hubspot_developer_api_description->translation->language:en SET text = "Developer API authentication for HubSpot. For HubSpot marketplace applications with developer authentication.";
RELATE i18n_key:credential_type_hubspot_developer_api_description->translation->language:it SET text = "Autenticazione Developer API per HubSpot. Per applicazioni marketplace HubSpot con autenticazione sviluppatore.";
RELATE i18n_key:credential_type_hubspot_developer_api_description->translation->language:de SET text = "Developer API-Authentifizierung für HubSpot. Für HubSpot-Marketplace-Anwendungen mit Entwickler-Authentifizierung.";
RELATE i18n_key:credential_type_hubspot_developer_api_description->translation->language:es SET text = "Autenticación Developer API para HubSpot. Para aplicaciones marketplace HubSpot con autenticación desarrollador.";

RELATE i18n_key:credential_type_hubspot_developer_api_tooltip->translation->language:fr SET text = "Pour développeurs apps marketplace HubSpot";
RELATE i18n_key:credential_type_hubspot_developer_api_tooltip->translation->language:en SET text = "For HubSpot marketplace app developers";
RELATE i18n_key:credential_type_hubspot_developer_api_tooltip->translation->language:it SET text = "Per sviluppatori app marketplace HubSpot";
RELATE i18n_key:credential_type_hubspot_developer_api_tooltip->translation->language:de SET text = "Für HubSpot-Marketplace-App-Entwickler";
RELATE i18n_key:credential_type_hubspot_developer_api_tooltip->translation->language:es SET text = "Para desarrolladores apps marketplace HubSpot";

-- =====================================================
-- HUBSPOT OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_hubspot_oauth2_api_name->translation->language:fr SET text = "HubSpot OAuth2";
RELATE i18n_key:credential_type_hubspot_oauth2_api_name->translation->language:en SET text = "HubSpot OAuth2";
RELATE i18n_key:credential_type_hubspot_oauth2_api_name->translation->language:it SET text = "HubSpot OAuth2";
RELATE i18n_key:credential_type_hubspot_oauth2_api_name->translation->language:de SET text = "HubSpot OAuth2";
RELATE i18n_key:credential_type_hubspot_oauth2_api_name->translation->language:es SET text = "HubSpot OAuth2";

RELATE i18n_key:credential_type_hubspot_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour HubSpot. Pour applications publiques marketplace avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_hubspot_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for HubSpot. For public marketplace applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_hubspot_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per HubSpot. Per applicazioni marketplace pubbliche con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_hubspot_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für HubSpot. Für öffentliche Marketplace-Anwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_hubspot_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para HubSpot. Para aplicaciones marketplace públicas con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_hubspot_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps publiques marketplace HubSpot";
RELATE i18n_key:credential_type_hubspot_oauth2_api_tooltip->translation->language:en SET text = "For public HubSpot marketplace apps";
RELATE i18n_key:credential_type_hubspot_oauth2_api_tooltip->translation->language:it SET text = "Per app pubbliche marketplace HubSpot";
RELATE i18n_key:credential_type_hubspot_oauth2_api_tooltip->translation->language:de SET text = "Für öffentliche HubSpot-Marketplace-Apps";
RELATE i18n_key:credential_type_hubspot_oauth2_api_tooltip->translation->language:es SET text = "Para apps públicas marketplace HubSpot";

-- =====================================================
-- SALESFORCE JWT API
-- =====================================================

RELATE i18n_key:credential_type_salesforce_jwt_api_name->translation->language:fr SET text = "Salesforce JWT";
RELATE i18n_key:credential_type_salesforce_jwt_api_name->translation->language:en SET text = "Salesforce JWT";
RELATE i18n_key:credential_type_salesforce_jwt_api_name->translation->language:it SET text = "Salesforce JWT";
RELATE i18n_key:credential_type_salesforce_jwt_api_name->translation->language:de SET text = "Salesforce JWT";
RELATE i18n_key:credential_type_salesforce_jwt_api_name->translation->language:es SET text = "Salesforce JWT";

RELATE i18n_key:credential_type_salesforce_jwt_api_description->translation->language:fr SET text = "Authentification JWT Bearer pour Salesforce. Pour intégrations serveur-à-serveur sans interaction utilisateur avec certificats.";
RELATE i18n_key:credential_type_salesforce_jwt_api_description->translation->language:en SET text = "JWT Bearer authentication for Salesforce. For server-to-server integrations without user interaction with certificates.";
RELATE i18n_key:credential_type_salesforce_jwt_api_description->translation->language:it SET text = "Autenticazione JWT Bearer per Salesforce. Per integrazioni server-to-server senza interazione utente con certificati.";
RELATE i18n_key:credential_type_salesforce_jwt_api_description->translation->language:de SET text = "JWT Bearer-Authentifizierung für Salesforce. Für Server-zu-Server-Integrationen ohne Benutzerinteraktion mit Zertifikaten.";
RELATE i18n_key:credential_type_salesforce_jwt_api_description->translation->language:es SET text = "Autenticación JWT Bearer para Salesforce. Para integraciones servidor-a-servidor sin interacción usuario con certificados.";

RELATE i18n_key:credential_type_salesforce_jwt_api_tooltip->translation->language:fr SET text = "Pour intégrations serveur Salesforce sans utilisateur";
RELATE i18n_key:credential_type_salesforce_jwt_api_tooltip->translation->language:en SET text = "For Salesforce server integrations without user";
RELATE i18n_key:credential_type_salesforce_jwt_api_tooltip->translation->language:it SET text = "Per integrazioni server Salesforce senza utente";
RELATE i18n_key:credential_type_salesforce_jwt_api_tooltip->translation->language:de SET text = "Für Salesforce-Server-Integrationen ohne Benutzer";
RELATE i18n_key:credential_type_salesforce_jwt_api_tooltip->translation->language:es SET text = "Para integraciones servidor Salesforce sin usuario";

-- =====================================================
-- SALESFORCE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_salesforce_oauth2_api_name->translation->language:fr SET text = "Salesforce OAuth2";
RELATE i18n_key:credential_type_salesforce_oauth2_api_name->translation->language:en SET text = "Salesforce OAuth2";
RELATE i18n_key:credential_type_salesforce_oauth2_api_name->translation->language:it SET text = "Salesforce OAuth2";
RELATE i18n_key:credential_type_salesforce_oauth2_api_name->translation->language:de SET text = "Salesforce OAuth2";
RELATE i18n_key:credential_type_salesforce_oauth2_api_name->translation->language:es SET text = "Salesforce OAuth2";

RELATE i18n_key:credential_type_salesforce_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Salesforce CRM. Leader mondial CRM pour gérer ventes, service client, marketing et analytics.";
RELATE i18n_key:credential_type_salesforce_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Salesforce CRM. Global CRM leader for managing sales, customer service, marketing, and analytics.";
RELATE i18n_key:credential_type_salesforce_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Salesforce CRM. Leader mondiale CRM per gestire vendite, servizio clienti, marketing e analytics.";
RELATE i18n_key:credential_type_salesforce_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Salesforce CRM. Weltweiter CRM-Marktführer für Vertrieb, Kundenservice, Marketing und Analytics.";
RELATE i18n_key:credential_type_salesforce_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Salesforce CRM. Líder mundial CRM para gestionar ventas, servicio cliente, marketing y analytics.";

RELATE i18n_key:credential_type_salesforce_oauth2_api_tooltip->translation->language:fr SET text = "Pour CRM Salesforce et automatisation ventes";
RELATE i18n_key:credential_type_salesforce_oauth2_api_tooltip->translation->language:en SET text = "For Salesforce CRM and sales automation";
RELATE i18n_key:credential_type_salesforce_oauth2_api_tooltip->translation->language:it SET text = "Per CRM Salesforce e automazione vendite";
RELATE i18n_key:credential_type_salesforce_oauth2_api_tooltip->translation->language:de SET text = "Für Salesforce CRM und Vertriebsautomatisierung";
RELATE i18n_key:credential_type_salesforce_oauth2_api_tooltip->translation->language:es SET text = "Para CRM Salesforce y automatización ventas";

-- =====================================================
-- STRIPE API
-- =====================================================

RELATE i18n_key:credential_type_stripe_api_name->translation->language:fr SET text = "Stripe API";
RELATE i18n_key:credential_type_stripe_api_name->translation->language:en SET text = "Stripe API";
RELATE i18n_key:credential_type_stripe_api_name->translation->language:it SET text = "Stripe API";
RELATE i18n_key:credential_type_stripe_api_name->translation->language:de SET text = "Stripe API";
RELATE i18n_key:credential_type_stripe_api_name->translation->language:es SET text = "Stripe API";

RELATE i18n_key:credential_type_stripe_api_description->translation->language:fr SET text = "Authentification par API key pour Stripe. Plateforme de paiement pour accepter paiements en ligne, gérer abonnements et transactions.";
RELATE i18n_key:credential_type_stripe_api_description->translation->language:en SET text = "API key authentication for Stripe. Payment platform for accepting online payments, managing subscriptions and transactions.";
RELATE i18n_key:credential_type_stripe_api_description->translation->language:it SET text = "Autenticazione tramite API key per Stripe. Piattaforma pagamenti per accettare pagamenti online, gestire abbonamenti e transazioni.";
RELATE i18n_key:credential_type_stripe_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Stripe. Zahlungsplattform zum Akzeptieren von Online-Zahlungen, Verwalten von Abonnements und Transaktionen.";
RELATE i18n_key:credential_type_stripe_api_description->translation->language:es SET text = "Autenticación mediante API key para Stripe. Plataforma pagos para aceptar pagos online, gestionar suscripciones y transacciones.";

RELATE i18n_key:credential_type_stripe_api_tooltip->translation->language:fr SET text = "Pour paiements en ligne et abonnements";
RELATE i18n_key:credential_type_stripe_api_tooltip->translation->language:en SET text = "For online payments and subscriptions";
RELATE i18n_key:credential_type_stripe_api_tooltip->translation->language:it SET text = "Per pagamenti online e abbonamenti";
RELATE i18n_key:credential_type_stripe_api_tooltip->translation->language:de SET text = "Für Online-Zahlungen und Abonnements";
RELATE i18n_key:credential_type_stripe_api_tooltip->translation->language:es SET text = "Para pagos online y suscripciones";

-- =====================================================
-- SHOPIFY API
-- =====================================================

RELATE i18n_key:credential_type_shopify_api_name->translation->language:fr SET text = "Shopify API";
RELATE i18n_key:credential_type_shopify_api_name->translation->language:en SET text = "Shopify API";
RELATE i18n_key:credential_type_shopify_api_name->translation->language:it SET text = "Shopify API";
RELATE i18n_key:credential_type_shopify_api_name->translation->language:de SET text = "Shopify API";
RELATE i18n_key:credential_type_shopify_api_name->translation->language:es SET text = "Shopify API";

RELATE i18n_key:credential_type_shopify_api_description->translation->language:fr SET text = "Authentification par API Password pour Shopify. Plateforme e-commerce pour gérer boutiques en ligne, produits, commandes et inventaire.";
RELATE i18n_key:credential_type_shopify_api_description->translation->language:en SET text = "API Password authentication for Shopify. E-commerce platform for managing online stores, products, orders, and inventory.";
RELATE i18n_key:credential_type_shopify_api_description->translation->language:it SET text = "Autenticazione tramite API Password per Shopify. Piattaforma e-commerce per gestire negozi online, prodotti, ordini e inventario.";
RELATE i18n_key:credential_type_shopify_api_description->translation->language:de SET text = "API-Passwort-Authentifizierung für Shopify. E-Commerce-Plattform zur Verwaltung von Online-Shops, Produkten, Bestellungen und Inventar.";
RELATE i18n_key:credential_type_shopify_api_description->translation->language:es SET text = "Autenticación mediante API Password para Shopify. Plataforma e-commerce para gestionar tiendas online, productos, pedidos e inventario.";

RELATE i18n_key:credential_type_shopify_api_tooltip->translation->language:fr SET text = "Pour e-commerce Shopify et gestion boutique";
RELATE i18n_key:credential_type_shopify_api_tooltip->translation->language:en SET text = "For Shopify e-commerce and store management";
RELATE i18n_key:credential_type_shopify_api_tooltip->translation->language:it SET text = "Per e-commerce Shopify e gestione negozio";
RELATE i18n_key:credential_type_shopify_api_tooltip->translation->language:de SET text = "Für Shopify E-Commerce und Shop-Verwaltung";
RELATE i18n_key:credential_type_shopify_api_tooltip->translation->language:es SET text = "Para e-commerce Shopify y gestión tienda";

-- =====================================================
-- SHOPIFY ACCESS TOKEN API
-- =====================================================

RELATE i18n_key:credential_type_shopify_access_token_api_name->translation->language:fr SET text = "Shopify Access Token";
RELATE i18n_key:credential_type_shopify_access_token_api_name->translation->language:en SET text = "Shopify Access Token";
RELATE i18n_key:credential_type_shopify_access_token_api_name->translation->language:it SET text = "Shopify Access Token";
RELATE i18n_key:credential_type_shopify_access_token_api_name->translation->language:de SET text = "Shopify Access Token";
RELATE i18n_key:credential_type_shopify_access_token_api_name->translation->language:es SET text = "Shopify Access Token";

RELATE i18n_key:credential_type_shopify_access_token_api_description->translation->language:fr SET text = "Authentification par Access Token pour Shopify. Pour applications custom privées avec accès direct aux scopes.";
RELATE i18n_key:credential_type_shopify_access_token_api_description->translation->language:en SET text = "Access Token authentication for Shopify. For custom private applications with direct scope access.";
RELATE i18n_key:credential_type_shopify_access_token_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Shopify. Per applicazioni custom private con accesso diretto agli scope.";
RELATE i18n_key:credential_type_shopify_access_token_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Shopify. Für benutzerdefinierte private Anwendungen mit direktem Scope-Zugriff.";
RELATE i18n_key:credential_type_shopify_access_token_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Shopify. Para aplicaciones custom privadas con acceso directo scopes.";

RELATE i18n_key:credential_type_shopify_access_token_api_tooltip->translation->language:fr SET text = "Pour apps privées Shopify avec access token";
RELATE i18n_key:credential_type_shopify_access_token_api_tooltip->translation->language:en SET text = "For private Shopify apps with access token";
RELATE i18n_key:credential_type_shopify_access_token_api_tooltip->translation->language:it SET text = "Per app private Shopify con access token";
RELATE i18n_key:credential_type_shopify_access_token_api_tooltip->translation->language:de SET text = "Für private Shopify-Apps mit Access Token";
RELATE i18n_key:credential_type_shopify_access_token_api_tooltip->translation->language:es SET text = "Para apps privadas Shopify con access token";

-- =====================================================
-- SHOPIFY OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_shopify_oauth2_api_name->translation->language:fr SET text = "Shopify OAuth2";
RELATE i18n_key:credential_type_shopify_oauth2_api_name->translation->language:en SET text = "Shopify OAuth2";
RELATE i18n_key:credential_type_shopify_oauth2_api_name->translation->language:it SET text = "Shopify OAuth2";
RELATE i18n_key:credential_type_shopify_oauth2_api_name->translation->language:de SET text = "Shopify OAuth2";
RELATE i18n_key:credential_type_shopify_oauth2_api_name->translation->language:es SET text = "Shopify OAuth2";

RELATE i18n_key:credential_type_shopify_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Shopify. Pour applications publiques App Store avec authentification marchands et accès multi-boutique.";
RELATE i18n_key:credential_type_shopify_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Shopify. For public App Store applications with merchant authentication and multi-store access.";
RELATE i18n_key:credential_type_shopify_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Shopify. Per applicazioni pubbliche App Store con autenticazione commercianti e accesso multi-negozio.";
RELATE i18n_key:credential_type_shopify_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Shopify. Für öffentliche App Store-Anwendungen mit Händler-Authentifizierung und Multi-Shop-Zugriff.";
RELATE i18n_key:credential_type_shopify_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Shopify. Para aplicaciones públicas App Store con autenticación comerciantes y acceso multi-tienda.";

RELATE i18n_key:credential_type_shopify_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps publiques Shopify App Store";
RELATE i18n_key:credential_type_shopify_oauth2_api_tooltip->translation->language:en SET text = "For public Shopify App Store apps";
RELATE i18n_key:credential_type_shopify_oauth2_api_tooltip->translation->language:it SET text = "Per app pubbliche Shopify App Store";
RELATE i18n_key:credential_type_shopify_oauth2_api_tooltip->translation->language:de SET text = "Für öffentliche Shopify App Store-Apps";
RELATE i18n_key:credential_type_shopify_oauth2_api_tooltip->translation->language:es SET text = "Para apps públicas Shopify App Store";

-- =====================================================
-- PIPEDRIVE API
-- =====================================================

RELATE i18n_key:credential_type_pipedrive_api_name->translation->language:fr SET text = "Pipedrive API";
RELATE i18n_key:credential_type_pipedrive_api_name->translation->language:en SET text = "Pipedrive API";
RELATE i18n_key:credential_type_pipedrive_api_name->translation->language:it SET text = "Pipedrive API";
RELATE i18n_key:credential_type_pipedrive_api_name->translation->language:de SET text = "Pipedrive API";
RELATE i18n_key:credential_type_pipedrive_api_name->translation->language:es SET text = "Pipedrive API";

RELATE i18n_key:credential_type_pipedrive_api_description->translation->language:fr SET text = "Authentification par API token pour Pipedrive. CRM axé ventes pour gérer pipelines, deals, contacts et automatiser processus commerciaux.";
RELATE i18n_key:credential_type_pipedrive_api_description->translation->language:en SET text = "API token authentication for Pipedrive. Sales-focused CRM for managing pipelines, deals, contacts, and automating sales processes.";
RELATE i18n_key:credential_type_pipedrive_api_description->translation->language:it SET text = "Autenticazione tramite API token per Pipedrive. CRM focalizzato sulle vendite per gestire pipeline, trattative, contatti e automatizzare processi commerciali.";
RELATE i18n_key:credential_type_pipedrive_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Pipedrive. Vertriebsorientiertes CRM zur Verwaltung von Pipelines, Deals, Kontakten und Automatisierung von Vertriebsprozessen.";
RELATE i18n_key:credential_type_pipedrive_api_description->translation->language:es SET text = "Autenticación mediante API token para Pipedrive. CRM enfocado ventas para gestionar pipelines, deals, contactos y automatizar procesos comerciales.";

RELATE i18n_key:credential_type_pipedrive_api_tooltip->translation->language:fr SET text = "Pour CRM ventes et gestion pipeline";
RELATE i18n_key:credential_type_pipedrive_api_tooltip->translation->language:en SET text = "For sales CRM and pipeline management";
RELATE i18n_key:credential_type_pipedrive_api_tooltip->translation->language:it SET text = "Per CRM vendite e gestione pipeline";
RELATE i18n_key:credential_type_pipedrive_api_tooltip->translation->language:de SET text = "Für Vertriebs-CRM und Pipeline-Verwaltung";
RELATE i18n_key:credential_type_pipedrive_api_tooltip->translation->language:es SET text = "Para CRM ventas y gestión pipeline";

-- =====================================================
-- PIPEDRIVE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_pipedrive_oauth2_api_name->translation->language:fr SET text = "Pipedrive OAuth2";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_name->translation->language:en SET text = "Pipedrive OAuth2";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_name->translation->language:it SET text = "Pipedrive OAuth2";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_name->translation->language:de SET text = "Pipedrive OAuth2";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_name->translation->language:es SET text = "Pipedrive OAuth2";

RELATE i18n_key:credential_type_pipedrive_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Pipedrive. Pour applications marketplace avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Pipedrive. For marketplace applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Pipedrive. Per applicazioni marketplace con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Pipedrive. Für Marketplace-Anwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Pipedrive. Para aplicaciones marketplace con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_pipedrive_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps marketplace Pipedrive";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_tooltip->translation->language:en SET text = "For Pipedrive marketplace apps";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_tooltip->translation->language:it SET text = "Per app marketplace Pipedrive";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_tooltip->translation->language:de SET text = "Für Pipedrive-Marketplace-Apps";
RELATE i18n_key:credential_type_pipedrive_oauth2_api_tooltip->translation->language:es SET text = "Para apps marketplace Pipedrive";

-- =====================================================
-- ZOHO OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_zoho_oauth2_api_name->translation->language:fr SET text = "Zoho OAuth2";
RELATE i18n_key:credential_type_zoho_oauth2_api_name->translation->language:en SET text = "Zoho OAuth2";
RELATE i18n_key:credential_type_zoho_oauth2_api_name->translation->language:it SET text = "Zoho OAuth2";
RELATE i18n_key:credential_type_zoho_oauth2_api_name->translation->language:de SET text = "Zoho OAuth2";
RELATE i18n_key:credential_type_zoho_oauth2_api_name->translation->language:es SET text = "Zoho OAuth2";

RELATE i18n_key:credential_type_zoho_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Zoho CRM. Suite business complète pour CRM, comptabilité, helpdesk et productivité.";
RELATE i18n_key:credential_type_zoho_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Zoho CRM. Complete business suite for CRM, accounting, helpdesk, and productivity.";
RELATE i18n_key:credential_type_zoho_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Zoho CRM. Suite business completa per CRM, contabilità, helpdesk e produttività.";
RELATE i18n_key:credential_type_zoho_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Zoho CRM. Komplette Business-Suite für CRM, Buchhaltung, Helpdesk und Produktivität.";
RELATE i18n_key:credential_type_zoho_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Zoho CRM. Suite business completa para CRM, contabilidad, helpdesk y productividad.";

RELATE i18n_key:credential_type_zoho_oauth2_api_tooltip->translation->language:fr SET text = "Pour Zoho CRM et suite business";
RELATE i18n_key:credential_type_zoho_oauth2_api_tooltip->translation->language:en SET text = "For Zoho CRM and business suite";
RELATE i18n_key:credential_type_zoho_oauth2_api_tooltip->translation->language:it SET text = "Per Zoho CRM e suite business";
RELATE i18n_key:credential_type_zoho_oauth2_api_tooltip->translation->language:de SET text = "Für Zoho CRM und Business-Suite";
RELATE i18n_key:credential_type_zoho_oauth2_api_tooltip->translation->language:es SET text = "Para Zoho CRM y suite business";

-- =====================================================
-- COPPER API
-- =====================================================

RELATE i18n_key:credential_type_copper_api_name->translation->language:fr SET text = "Copper CRM API";
RELATE i18n_key:credential_type_copper_api_name->translation->language:en SET text = "Copper CRM API";
RELATE i18n_key:credential_type_copper_api_name->translation->language:it SET text = "Copper CRM API";
RELATE i18n_key:credential_type_copper_api_name->translation->language:de SET text = "Copper CRM API";
RELATE i18n_key:credential_type_copper_api_name->translation->language:es SET text = "Copper CRM API";

RELATE i18n_key:credential_type_copper_api_description->translation->language:fr SET text = "Authentification par API key pour Copper CRM (ex-ProsperWorks). CRM natif pour Google Workspace avec intégration Gmail profonde.";
RELATE i18n_key:credential_type_copper_api_description->translation->language:en SET text = "API key authentication for Copper CRM (formerly ProsperWorks). Native CRM for Google Workspace with deep Gmail integration.";
RELATE i18n_key:credential_type_copper_api_description->translation->language:it SET text = "Autenticazione tramite API key per Copper CRM (ex-ProsperWorks). CRM nativo per Google Workspace con integrazione Gmail profonda.";
RELATE i18n_key:credential_type_copper_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Copper CRM (ehemals ProsperWorks). Natives CRM für Google Workspace mit tiefer Gmail-Integration.";
RELATE i18n_key:credential_type_copper_api_description->translation->language:es SET text = "Autenticación mediante API key para Copper CRM (antes ProsperWorks). CRM nativo para Google Workspace con integración Gmail profunda.";

RELATE i18n_key:credential_type_copper_api_tooltip->translation->language:fr SET text = "Pour CRM Google Workspace et intégration Gmail";
RELATE i18n_key:credential_type_copper_api_tooltip->translation->language:en SET text = "For Google Workspace CRM and Gmail integration";
RELATE i18n_key:credential_type_copper_api_tooltip->translation->language:it SET text = "Per CRM Google Workspace e integrazione Gmail";
RELATE i18n_key:credential_type_copper_api_tooltip->translation->language:de SET text = "Für Google Workspace CRM und Gmail-Integration";
RELATE i18n_key:credential_type_copper_api_tooltip->translation->language:es SET text = "Para CRM Google Workspace e integración Gmail";

-- =====================================================
-- ACTIVECAMPAIGN API
-- =====================================================

RELATE i18n_key:credential_type_activecampaign_api_name->translation->language:fr SET text = "ActiveCampaign API";
RELATE i18n_key:credential_type_activecampaign_api_name->translation->language:en SET text = "ActiveCampaign API";
RELATE i18n_key:credential_type_activecampaign_api_name->translation->language:it SET text = "ActiveCampaign API";
RELATE i18n_key:credential_type_activecampaign_api_name->translation->language:de SET text = "ActiveCampaign API";
RELATE i18n_key:credential_type_activecampaign_api_name->translation->language:es SET text = "ActiveCampaign API";

RELATE i18n_key:credential_type_activecampaign_api_description->translation->language:fr SET text = "Authentification par API key pour ActiveCampaign. Plateforme marketing automation pour email marketing, CRM et automatisation campagnes.";
RELATE i18n_key:credential_type_activecampaign_api_description->translation->language:en SET text = "API key authentication for ActiveCampaign. Marketing automation platform for email marketing, CRM, and campaign automation.";
RELATE i18n_key:credential_type_activecampaign_api_description->translation->language:it SET text = "Autenticazione tramite API key per ActiveCampaign. Piattaforma marketing automation per email marketing, CRM e automazione campagne.";
RELATE i18n_key:credential_type_activecampaign_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für ActiveCampaign. Marketing-Automatisierungsplattform für E-Mail-Marketing, CRM und Kampagnenautomatisierung.";
RELATE i18n_key:credential_type_activecampaign_api_description->translation->language:es SET text = "Autenticación mediante API key para ActiveCampaign. Plataforma automatización marketing para email marketing, CRM y automatización campañas.";

RELATE i18n_key:credential_type_activecampaign_api_tooltip->translation->language:fr SET text = "Pour email marketing et automation campagnes";
RELATE i18n_key:credential_type_activecampaign_api_tooltip->translation->language:en SET text = "For email marketing and campaign automation";
RELATE i18n_key:credential_type_activecampaign_api_tooltip->translation->language:it SET text = "Per email marketing e automazione campagne";
RELATE i18n_key:credential_type_activecampaign_api_tooltip->translation->language:de SET text = "Für E-Mail-Marketing und Kampagnenautomatisierung";
RELATE i18n_key:credential_type_activecampaign_api_tooltip->translation->language:es SET text = "Para email marketing y automatización campañas";

-- =====================================================
-- MAILCHIMP API
-- =====================================================

RELATE i18n_key:credential_type_mailchimp_api_name->translation->language:fr SET text = "Mailchimp API";
RELATE i18n_key:credential_type_mailchimp_api_name->translation->language:en SET text = "Mailchimp API";
RELATE i18n_key:credential_type_mailchimp_api_name->translation->language:it SET text = "Mailchimp API";
RELATE i18n_key:credential_type_mailchimp_api_name->translation->language:de SET text = "Mailchimp API";
RELATE i18n_key:credential_type_mailchimp_api_name->translation->language:es SET text = "Mailchimp API";

RELATE i18n_key:credential_type_mailchimp_api_description->translation->language:fr SET text = "Authentification par API key pour Mailchimp. Leader email marketing pour gérer audiences, campagnes emails et automatisations marketing.";
RELATE i18n_key:credential_type_mailchimp_api_description->translation->language:en SET text = "API key authentication for Mailchimp. Email marketing leader for managing audiences, email campaigns, and marketing automations.";
RELATE i18n_key:credential_type_mailchimp_api_description->translation->language:it SET text = "Autenticazione tramite API key per Mailchimp. Leader email marketing per gestire audience, campagne email e automazioni marketing.";
RELATE i18n_key:credential_type_mailchimp_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Mailchimp. E-Mail-Marketing-Marktführer für die Verwaltung von Zielgruppen, E-Mail-Kampagnen und Marketing-Automatisierungen.";
RELATE i18n_key:credential_type_mailchimp_api_description->translation->language:es SET text = "Autenticación mediante API key para Mailchimp. Líder email marketing para gestionar audiencias, campañas email y automatizaciones marketing.";

RELATE i18n_key:credential_type_mailchimp_api_tooltip->translation->language:fr SET text = "Pour email marketing et gestion audiences";
RELATE i18n_key:credential_type_mailchimp_api_tooltip->translation->language:en SET text = "For email marketing and audience management";
RELATE i18n_key:credential_type_mailchimp_api_tooltip->translation->language:it SET text = "Per email marketing e gestione audience";
RELATE i18n_key:credential_type_mailchimp_api_tooltip->translation->language:de SET text = "Für E-Mail-Marketing und Zielgruppenverwaltung";
RELATE i18n_key:credential_type_mailchimp_api_tooltip->translation->language:es SET text = "Para email marketing y gestión audiencias";

-- =====================================================
-- MAILCHIMP OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_mailchimp_oauth2_api_name->translation->language:fr SET text = "Mailchimp OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_name->translation->language:en SET text = "Mailchimp OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_name->translation->language:it SET text = "Mailchimp OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_name->translation->language:de SET text = "Mailchimp OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_name->translation->language:es SET text = "Mailchimp OAuth2";

RELATE i18n_key:credential_type_mailchimp_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Mailchimp. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Mailchimp. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Mailchimp. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Mailchimp. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Mailchimp. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_mailchimp_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Mailchimp avec OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_tooltip->translation->language:en SET text = "For third-party Mailchimp apps with OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Mailchimp con OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Mailchimp-Apps mit OAuth2";
RELATE i18n_key:credential_type_mailchimp_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Mailchimp con OAuth2";

-- =============================================================================================

