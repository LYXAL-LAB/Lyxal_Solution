-- =============================================================================================
-- |
-- | Fichier : credential_type_batch18_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 18 des credential types.
-- |
-- | Batch 18 : Email Marketing & Communication (11 credentials)
-- | Providers : Brevo, GetResponse, MailerLite, ConvertKit, Automizy, Customer.io, E-goi, Sendy, Lemlist, SMTP
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- BREVO API (formerly SendInBlue)
RELATE i18n_key:credential_type_brevo_api_name->translation->language:fr SET text = "Brevo API";
RELATE i18n_key:credential_type_brevo_api_name->translation->language:en SET text = "Brevo API";
RELATE i18n_key:credential_type_brevo_api_name->translation->language:it SET text = "Brevo API";
RELATE i18n_key:credential_type_brevo_api_name->translation->language:de SET text = "Brevo API";
RELATE i18n_key:credential_type_brevo_api_name->translation->language:es SET text = "Brevo API";

RELATE i18n_key:credential_type_brevo_api_description->translation->language:fr SET text = "Authentification par clé API pour Brevo (ex-SendInBlue). Email marketing, emails transactionnels et campagnes automatisées.";
RELATE i18n_key:credential_type_brevo_api_description->translation->language:en SET text = "API key authentication for Brevo (formerly SendInBlue). Email marketing, transactional emails and automated campaigns.";
RELATE i18n_key:credential_type_brevo_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Brevo (ex-SendInBlue). Email marketing, email transazionali e campagne automatizzate.";
RELATE i18n_key:credential_type_brevo_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Brevo (ehemals SendInBlue). E-Mail-Marketing, Transaktions-E-Mails und automatisierte Kampagnen.";
RELATE i18n_key:credential_type_brevo_api_description->translation->language:es SET text = "Autenticación mediante clave API para Brevo (ex-SendInBlue). Email marketing, emails transaccionales y campañas automatizadas.";

RELATE i18n_key:credential_type_brevo_api_tooltip->translation->language:fr SET text = "Pour Brevo email marketing";
RELATE i18n_key:credential_type_brevo_api_tooltip->translation->language:en SET text = "For Brevo email marketing";
RELATE i18n_key:credential_type_brevo_api_tooltip->translation->language:it SET text = "Per Brevo email marketing";
RELATE i18n_key:credential_type_brevo_api_tooltip->translation->language:de SET text = "Für Brevo E-Mail-Marketing";
RELATE i18n_key:credential_type_brevo_api_tooltip->translation->language:es SET text = "Para Brevo email marketing";

-- GETRESPONSE API
RELATE i18n_key:credential_type_getresponse_api_name->translation->language:fr SET text = "GetResponse API";
RELATE i18n_key:credential_type_getresponse_api_name->translation->language:en SET text = "GetResponse API";
RELATE i18n_key:credential_type_getresponse_api_name->translation->language:it SET text = "GetResponse API";
RELATE i18n_key:credential_type_getresponse_api_name->translation->language:de SET text = "GetResponse API";
RELATE i18n_key:credential_type_getresponse_api_name->translation->language:es SET text = "GetResponse API";

RELATE i18n_key:credential_type_getresponse_api_description->translation->language:fr SET text = "Authentification par clé API pour GetResponse. Plateforme marketing automation avec email, landing pages et webinaires.";
RELATE i18n_key:credential_type_getresponse_api_description->translation->language:en SET text = "API key authentication for GetResponse. Marketing automation platform with email, landing pages and webinars.";
RELATE i18n_key:credential_type_getresponse_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per GetResponse. Piattaforma marketing automation con email, landing page e webinar.";
RELATE i18n_key:credential_type_getresponse_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für GetResponse. Marketing-Automation-Plattform mit E-Mail, Landingpages und Webinaren.";
RELATE i18n_key:credential_type_getresponse_api_description->translation->language:es SET text = "Autenticación mediante clave API para GetResponse. Plataforma marketing automation con email, landing pages y webinars.";

RELATE i18n_key:credential_type_getresponse_api_tooltip->translation->language:fr SET text = "Pour GetResponse marketing automation";
RELATE i18n_key:credential_type_getresponse_api_tooltip->translation->language:en SET text = "For GetResponse marketing automation";
RELATE i18n_key:credential_type_getresponse_api_tooltip->translation->language:it SET text = "Per GetResponse marketing automation";
RELATE i18n_key:credential_type_getresponse_api_tooltip->translation->language:de SET text = "Für GetResponse Marketing-Automation";
RELATE i18n_key:credential_type_getresponse_api_tooltip->translation->language:es SET text = "Para GetResponse marketing automation";

-- GETRESPONSE OAUTH2 API
RELATE i18n_key:credential_type_getresponse_oauth2_api_name->translation->language:fr SET text = "GetResponse OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_name->translation->language:en SET text = "GetResponse OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_name->translation->language:it SET text = "GetResponse OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_name->translation->language:de SET text = "GetResponse OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_name->translation->language:es SET text = "GetResponse OAuth2";

RELATE i18n_key:credential_type_getresponse_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour GetResponse. Version OAuth2 recommandée pour applications tierces.";
RELATE i18n_key:credential_type_getresponse_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for GetResponse. Recommended OAuth2 version for third-party applications.";
RELATE i18n_key:credential_type_getresponse_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per GetResponse. Versione OAuth2 consigliata per applicazioni terze.";
RELATE i18n_key:credential_type_getresponse_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für GetResponse. Empfohlene OAuth2-Version für Drittanbieteranwendungen.";
RELATE i18n_key:credential_type_getresponse_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para GetResponse. Versión OAuth2 recomendada para aplicaciones terceros.";

RELATE i18n_key:credential_type_getresponse_oauth2_api_tooltip->translation->language:fr SET text = "Pour GetResponse avec OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_tooltip->translation->language:en SET text = "For GetResponse with OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_tooltip->translation->language:it SET text = "Per GetResponse con OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_tooltip->translation->language:de SET text = "Für GetResponse mit OAuth2";
RELATE i18n_key:credential_type_getresponse_oauth2_api_tooltip->translation->language:es SET text = "Para GetResponse con OAuth2";

-- MAILERLITE API
RELATE i18n_key:credential_type_mailerlite_api_name->translation->language:fr SET text = "MailerLite API";
RELATE i18n_key:credential_type_mailerlite_api_name->translation->language:en SET text = "MailerLite API";
RELATE i18n_key:credential_type_mailerlite_api_name->translation->language:it SET text = "MailerLite API";
RELATE i18n_key:credential_type_mailerlite_api_name->translation->language:de SET text = "MailerLite API";
RELATE i18n_key:credential_type_mailerlite_api_name->translation->language:es SET text = "MailerLite API";

RELATE i18n_key:credential_type_mailerlite_api_description->translation->language:fr SET text = "Authentification par token pour MailerLite. Email marketing avec landing pages, support API Classic et nouvelle API.";
RELATE i18n_key:credential_type_mailerlite_api_description->translation->language:en SET text = "Token authentication for MailerLite. Email marketing with landing pages, supports Classic and new API.";
RELATE i18n_key:credential_type_mailerlite_api_description->translation->language:it SET text = "Autenticazione tramite token per MailerLite. Email marketing con landing page, supporta API Classic e nuova API.";
RELATE i18n_key:credential_type_mailerlite_api_description->translation->language:de SET text = "Token-Authentifizierung für MailerLite. E-Mail-Marketing mit Landingpages, unterstützt Classic und neue API.";
RELATE i18n_key:credential_type_mailerlite_api_description->translation->language:es SET text = "Autenticación mediante token para MailerLite. Email marketing con landing pages, soporta API Classic y nueva API.";

RELATE i18n_key:credential_type_mailerlite_api_tooltip->translation->language:fr SET text = "Pour MailerLite email marketing";
RELATE i18n_key:credential_type_mailerlite_api_tooltip->translation->language:en SET text = "For MailerLite email marketing";
RELATE i18n_key:credential_type_mailerlite_api_tooltip->translation->language:it SET text = "Per MailerLite email marketing";
RELATE i18n_key:credential_type_mailerlite_api_tooltip->translation->language:de SET text = "Für MailerLite E-Mail-Marketing";
RELATE i18n_key:credential_type_mailerlite_api_tooltip->translation->language:es SET text = "Para MailerLite email marketing";

-- CONVERTKIT API
RELATE i18n_key:credential_type_convertkit_api_name->translation->language:fr SET text = "ConvertKit API";
RELATE i18n_key:credential_type_convertkit_api_name->translation->language:en SET text = "ConvertKit API";
RELATE i18n_key:credential_type_convertkit_api_name->translation->language:it SET text = "ConvertKit API";
RELATE i18n_key:credential_type_convertkit_api_name->translation->language:de SET text = "ConvertKit API";
RELATE i18n_key:credential_type_convertkit_api_name->translation->language:es SET text = "ConvertKit API";

RELATE i18n_key:credential_type_convertkit_api_description->translation->language:fr SET text = "Authentification par API secret pour ConvertKit. Email marketing pour créateurs, newsletters et creator economy.";
RELATE i18n_key:credential_type_convertkit_api_description->translation->language:en SET text = "API secret authentication for ConvertKit. Email marketing for creators, newsletters and creator economy.";
RELATE i18n_key:credential_type_convertkit_api_description->translation->language:it SET text = "Autenticazione tramite API secret per ConvertKit. Email marketing per creatori, newsletter e creator economy.";
RELATE i18n_key:credential_type_convertkit_api_description->translation->language:de SET text = "API-Secret-Authentifizierung für ConvertKit. E-Mail-Marketing für Creators, Newsletter und Creator Economy.";
RELATE i18n_key:credential_type_convertkit_api_description->translation->language:es SET text = "Autenticación mediante API secret para ConvertKit. Email marketing para creadores, newsletters y creator economy.";

RELATE i18n_key:credential_type_convertkit_api_tooltip->translation->language:fr SET text = "Pour ConvertKit newsletters créateurs";
RELATE i18n_key:credential_type_convertkit_api_tooltip->translation->language:en SET text = "For ConvertKit creator newsletters";
RELATE i18n_key:credential_type_convertkit_api_tooltip->translation->language:it SET text = "Per ConvertKit newsletter creatori";
RELATE i18n_key:credential_type_convertkit_api_tooltip->translation->language:de SET text = "Für ConvertKit Creator-Newsletter";
RELATE i18n_key:credential_type_convertkit_api_tooltip->translation->language:es SET text = "Para ConvertKit newsletters creadores";

-- AUTOMIZY API (DEPRECATED)
RELATE i18n_key:credential_type_automizy_api_name->translation->language:fr SET text = "Automizy API [OBSOLÈTE]";
RELATE i18n_key:credential_type_automizy_api_name->translation->language:en SET text = "Automizy API [DEPRECATED]";
RELATE i18n_key:credential_type_automizy_api_name->translation->language:it SET text = "Automizy API [OBSOLETO]";
RELATE i18n_key:credential_type_automizy_api_name->translation->language:de SET text = "Automizy API [VERALTET]";
RELATE i18n_key:credential_type_automizy_api_name->translation->language:es SET text = "Automizy API [OBSOLETO]";

RELATE i18n_key:credential_type_automizy_api_description->translation->language:fr SET text = "Authentification par token pour Automizy. Service discontinué, email marketing automation (deprecated).";
RELATE i18n_key:credential_type_automizy_api_description->translation->language:en SET text = "Token authentication for Automizy. Service discontinued, email marketing automation (deprecated).";
RELATE i18n_key:credential_type_automizy_api_description->translation->language:it SET text = "Autenticazione tramite token per Automizy. Servizio interrotto, email marketing automation (deprecato).";
RELATE i18n_key:credential_type_automizy_api_description->translation->language:de SET text = "Token-Authentifizierung für Automizy. Service eingestellt, E-Mail-Marketing-Automation (veraltet).";
RELATE i18n_key:credential_type_automizy_api_description->translation->language:es SET text = "Autenticación mediante token para Automizy. Servicio discontinuado, email marketing automation (obsoleto).";

RELATE i18n_key:credential_type_automizy_api_tooltip->translation->language:fr SET text = "Pour Automizy (service discontinué)";
RELATE i18n_key:credential_type_automizy_api_tooltip->translation->language:en SET text = "For Automizy (discontinued service)";
RELATE i18n_key:credential_type_automizy_api_tooltip->translation->language:it SET text = "Per Automizy (servizio interrotto)";
RELATE i18n_key:credential_type_automizy_api_tooltip->translation->language:de SET text = "Für Automizy (eingestellter Service)";
RELATE i18n_key:credential_type_automizy_api_tooltip->translation->language:es SET text = "Para Automizy (servicio discontinuado)";

-- CUSTOMER.IO API
RELATE i18n_key:credential_type_customer_io_api_name->translation->language:fr SET text = "Customer.io API";
RELATE i18n_key:credential_type_customer_io_api_name->translation->language:en SET text = "Customer.io API";
RELATE i18n_key:credential_type_customer_io_api_name->translation->language:it SET text = "Customer.io API";
RELATE i18n_key:credential_type_customer_io_api_name->translation->language:de SET text = "Customer.io API";
RELATE i18n_key:credential_type_customer_io_api_name->translation->language:es SET text = "Customer.io API";

RELATE i18n_key:credential_type_customer_io_api_description->translation->language:fr SET text = "Authentification tracking/app pour Customer.io. Customer messaging automation avec régions EU/Global, tracking et app API.";
RELATE i18n_key:credential_type_customer_io_api_description->translation->language:en SET text = "Tracking/app authentication for Customer.io. Customer messaging automation with EU/Global regions, tracking and app API.";
RELATE i18n_key:credential_type_customer_io_api_description->translation->language:it SET text = "Autenticazione tracking/app per Customer.io. Customer messaging automation con regioni EU/Global, tracking e app API.";
RELATE i18n_key:credential_type_customer_io_api_description->translation->language:de SET text = "Tracking/App-Authentifizierung für Customer.io. Customer-Messaging-Automation mit EU/Global-Regionen, Tracking und App-API.";
RELATE i18n_key:credential_type_customer_io_api_description->translation->language:es SET text = "Autenticación tracking/app para Customer.io. Customer messaging automation con regiones EU/Global, tracking y app API.";

RELATE i18n_key:credential_type_customer_io_api_tooltip->translation->language:fr SET text = "Pour Customer.io messaging automation";
RELATE i18n_key:credential_type_customer_io_api_tooltip->translation->language:en SET text = "For Customer.io messaging automation";
RELATE i18n_key:credential_type_customer_io_api_tooltip->translation->language:it SET text = "Per Customer.io messaging automation";
RELATE i18n_key:credential_type_customer_io_api_tooltip->translation->language:de SET text = "Für Customer.io Messaging-Automation";
RELATE i18n_key:credential_type_customer_io_api_tooltip->translation->language:es SET text = "Para Customer.io messaging automation";

-- E-GOI API
RELATE i18n_key:credential_type_egoi_api_name->translation->language:fr SET text = "E-goi API";
RELATE i18n_key:credential_type_egoi_api_name->translation->language:en SET text = "E-goi API";
RELATE i18n_key:credential_type_egoi_api_name->translation->language:it SET text = "E-goi API";
RELATE i18n_key:credential_type_egoi_api_name->translation->language:de SET text = "E-goi API";
RELATE i18n_key:credential_type_egoi_api_name->translation->language:es SET text = "E-goi API";

RELATE i18n_key:credential_type_egoi_api_description->translation->language:fr SET text = "Authentification par clé API pour E-goi. Marketing multi-canal avec email, SMS et push notifications.";
RELATE i18n_key:credential_type_egoi_api_description->translation->language:en SET text = "API key authentication for E-goi. Multi-channel marketing with email, SMS and push notifications.";
RELATE i18n_key:credential_type_egoi_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per E-goi. Marketing multi-canale con email, SMS e push notifications.";
RELATE i18n_key:credential_type_egoi_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für E-goi. Multi-Channel-Marketing mit E-Mail, SMS und Push-Benachrichtigungen.";
RELATE i18n_key:credential_type_egoi_api_description->translation->language:es SET text = "Autenticación mediante clave API para E-goi. Marketing multi-canal con email, SMS y push notifications.";

RELATE i18n_key:credential_type_egoi_api_tooltip->translation->language:fr SET text = "Pour E-goi marketing multi-canal";
RELATE i18n_key:credential_type_egoi_api_tooltip->translation->language:en SET text = "For E-goi multi-channel marketing";
RELATE i18n_key:credential_type_egoi_api_tooltip->translation->language:it SET text = "Per E-goi marketing multi-canale";
RELATE i18n_key:credential_type_egoi_api_tooltip->translation->language:de SET text = "Für E-goi Multi-Channel-Marketing";
RELATE i18n_key:credential_type_egoi_api_tooltip->translation->language:es SET text = "Para E-goi marketing multi-canal";

-- SENDY API
RELATE i18n_key:credential_type_sendy_api_name->translation->language:fr SET text = "Sendy API";
RELATE i18n_key:credential_type_sendy_api_name->translation->language:en SET text = "Sendy API";
RELATE i18n_key:credential_type_sendy_api_name->translation->language:it SET text = "Sendy API";
RELATE i18n_key:credential_type_sendy_api_name->translation->language:de SET text = "Sendy API";
RELATE i18n_key:credential_type_sendy_api_name->translation->language:es SET text = "Sendy API";

RELATE i18n_key:credential_type_sendy_api_description->translation->language:fr SET text = "Authentification par clé API pour Sendy. Email marketing auto-hébergé économique utilisant Amazon SES.";
RELATE i18n_key:credential_type_sendy_api_description->translation->language:en SET text = "API key authentication for Sendy. Cost-effective self-hosted email marketing using Amazon SES.";
RELATE i18n_key:credential_type_sendy_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Sendy. Email marketing self-hosted economico utilizzando Amazon SES.";
RELATE i18n_key:credential_type_sendy_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Sendy. Kosteneffektives selbstgehostetes E-Mail-Marketing mit Amazon SES.";
RELATE i18n_key:credential_type_sendy_api_description->translation->language:es SET text = "Autenticación mediante clave API para Sendy. Email marketing auto-alojado económico utilizando Amazon SES.";

RELATE i18n_key:credential_type_sendy_api_tooltip->translation->language:fr SET text = "Pour Sendy email auto-hébergé";
RELATE i18n_key:credential_type_sendy_api_tooltip->translation->language:en SET text = "For Sendy self-hosted email";
RELATE i18n_key:credential_type_sendy_api_tooltip->translation->language:it SET text = "Per Sendy email self-hosted";
RELATE i18n_key:credential_type_sendy_api_tooltip->translation->language:de SET text = "Für Sendy selbstgehostete E-Mail";
RELATE i18n_key:credential_type_sendy_api_tooltip->translation->language:es SET text = "Para Sendy email auto-alojado";

-- LEMLIST API
RELATE i18n_key:credential_type_lemlist_api_name->translation->language:fr SET text = "Lemlist API";
RELATE i18n_key:credential_type_lemlist_api_name->translation->language:en SET text = "Lemlist API";
RELATE i18n_key:credential_type_lemlist_api_name->translation->language:it SET text = "Lemlist API";
RELATE i18n_key:credential_type_lemlist_api_name->translation->language:de SET text = "Lemlist API";
RELATE i18n_key:credential_type_lemlist_api_name->translation->language:es SET text = "Lemlist API";

RELATE i18n_key:credential_type_lemlist_api_description->translation->language:fr SET text = "Authentification basic pour Lemlist. Cold outreach automation avec personnalisation email et sales automation.";
RELATE i18n_key:credential_type_lemlist_api_description->translation->language:en SET text = "Basic authentication for Lemlist. Cold outreach automation with email personalization and sales automation.";
RELATE i18n_key:credential_type_lemlist_api_description->translation->language:it SET text = "Autenticazione basic per Lemlist. Cold outreach automation con personalizzazione email e sales automation.";
RELATE i18n_key:credential_type_lemlist_api_description->translation->language:de SET text = "Basic-Authentifizierung für Lemlist. Cold-Outreach-Automation mit E-Mail-Personalisierung und Sales-Automation.";
RELATE i18n_key:credential_type_lemlist_api_description->translation->language:es SET text = "Autenticación basic para Lemlist. Cold outreach automation con personalización email y sales automation.";

RELATE i18n_key:credential_type_lemlist_api_tooltip->translation->language:fr SET text = "Pour Lemlist cold outreach";
RELATE i18n_key:credential_type_lemlist_api_tooltip->translation->language:en SET text = "For Lemlist cold outreach";
RELATE i18n_key:credential_type_lemlist_api_tooltip->translation->language:it SET text = "Per Lemlist cold outreach";
RELATE i18n_key:credential_type_lemlist_api_tooltip->translation->language:de SET text = "Für Lemlist Cold Outreach";
RELATE i18n_key:credential_type_lemlist_api_tooltip->translation->language:es SET text = "Para Lemlist cold outreach";

-- SMTP
RELATE i18n_key:credential_type_smtp_name->translation->language:fr SET text = "SMTP";
RELATE i18n_key:credential_type_smtp_name->translation->language:en SET text = "SMTP";
RELATE i18n_key:credential_type_smtp_name->translation->language:it SET text = "SMTP";
RELATE i18n_key:credential_type_smtp_name->translation->language:de SET text = "SMTP";
RELATE i18n_key:credential_type_smtp_name->translation->language:es SET text = "SMTP";

RELATE i18n_key:credential_type_smtp_description->translation->language:fr SET text = "Authentification SMTP standard. Protocole universel envoi emails avec SSL/TLS, configuration host/port.";
RELATE i18n_key:credential_type_smtp_description->translation->language:en SET text = "Standard SMTP authentication. Universal email sending protocol with SSL/TLS, host/port configuration.";
RELATE i18n_key:credential_type_smtp_description->translation->language:it SET text = "Autenticazione SMTP standard. Protocollo universale invio email con SSL/TLS, configurazione host/port.";
RELATE i18n_key:credential_type_smtp_description->translation->language:de SET text = "Standard-SMTP-Authentifizierung. Universelles E-Mail-Versandprotokoll mit SSL/TLS, Host/Port-Konfiguration.";
RELATE i18n_key:credential_type_smtp_description->translation->language:es SET text = "Autenticación SMTP estándar. Protocolo universal envío emails con SSL/TLS, configuración host/port.";

RELATE i18n_key:credential_type_smtp_tooltip->translation->language:fr SET text = "Pour envoi emails via SMTP";
RELATE i18n_key:credential_type_smtp_tooltip->translation->language:en SET text = "For sending emails via SMTP";
RELATE i18n_key:credential_type_smtp_tooltip->translation->language:it SET text = "Per invio email tramite SMTP";
RELATE i18n_key:credential_type_smtp_tooltip->translation->language:de SET text = "Zum Senden von E-Mails via SMTP";
RELATE i18n_key:credential_type_smtp_tooltip->translation->language:es SET text = "Para envío emails vía SMTP";

-- =============================================================================================

