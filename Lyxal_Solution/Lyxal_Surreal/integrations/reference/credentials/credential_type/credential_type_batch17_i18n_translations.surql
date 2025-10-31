-- =============================================================================================
-- |
-- | Fichier : credential_type_batch17_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 17 des credential types.
-- |
-- | Batch 17 : Monitoring, Observability, Data Enrichment & Communication (11 credentials)
-- | Providers : Splunk, Sentry.io, PagerDuty, OpenWeatherMap, NASA, Hunter, Clearbit, Raindrop, Telegram, TheHive
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 150 traductions (30 clés × 5 langues)
-- |
-- =============================================================================================

-- SPLUNK API
RELATE i18n_key:credential_type_splunk_api_name->translation->language:fr SET text = "Splunk API";
RELATE i18n_key:credential_type_splunk_api_name->translation->language:en SET text = "Splunk API";
RELATE i18n_key:credential_type_splunk_api_name->translation->language:it SET text = "Splunk API";
RELATE i18n_key:credential_type_splunk_api_name->translation->language:de SET text = "Splunk API";
RELATE i18n_key:credential_type_splunk_api_name->translation->language:es SET text = "Splunk API";

RELATE i18n_key:credential_type_splunk_api_description->translation->language:fr SET text = "Authentification par token pour Splunk. Plateforme enterprise log management, SIEM et security analytics.";
RELATE i18n_key:credential_type_splunk_api_description->translation->language:en SET text = "Token authentication for Splunk. Enterprise log management, SIEM and security analytics platform.";
RELATE i18n_key:credential_type_splunk_api_description->translation->language:it SET text = "Autenticazione tramite token per Splunk. Piattaforma enterprise gestione log, SIEM e security analytics.";
RELATE i18n_key:credential_type_splunk_api_description->translation->language:de SET text = "Token-Authentifizierung für Splunk. Enterprise-Logverwaltung, SIEM und Security-Analytics-Plattform.";
RELATE i18n_key:credential_type_splunk_api_description->translation->language:es SET text = "Autenticación mediante token para Splunk. Plataforma enterprise gestión logs, SIEM y security analytics.";

RELATE i18n_key:credential_type_splunk_api_tooltip->translation->language:fr SET text = "Pour Splunk SIEM et log management";
RELATE i18n_key:credential_type_splunk_api_tooltip->translation->language:en SET text = "For Splunk SIEM and log management";
RELATE i18n_key:credential_type_splunk_api_tooltip->translation->language:it SET text = "Per Splunk SIEM e gestione log";
RELATE i18n_key:credential_type_splunk_api_tooltip->translation->language:de SET text = "Für Splunk SIEM und Logverwaltung";
RELATE i18n_key:credential_type_splunk_api_tooltip->translation->language:es SET text = "Para Splunk SIEM y gestión logs";

-- SENTRY.IO API
RELATE i18n_key:credential_type_sentry_io_api_name->translation->language:fr SET text = "Sentry.io API";
RELATE i18n_key:credential_type_sentry_io_api_name->translation->language:en SET text = "Sentry.io API";
RELATE i18n_key:credential_type_sentry_io_api_name->translation->language:it SET text = "Sentry.io API";
RELATE i18n_key:credential_type_sentry_io_api_name->translation->language:de SET text = "Sentry.io API";
RELATE i18n_key:credential_type_sentry_io_api_name->translation->language:es SET text = "Sentry.io API";

RELATE i18n_key:credential_type_sentry_io_api_description->translation->language:fr SET text = "Authentification par token pour Sentry.io. Error tracking, application monitoring et performance monitoring pour développeurs.";
RELATE i18n_key:credential_type_sentry_io_api_description->translation->language:en SET text = "Token authentication for Sentry.io. Error tracking, application monitoring and performance monitoring for developers.";
RELATE i18n_key:credential_type_sentry_io_api_description->translation->language:it SET text = "Autenticazione tramite token per Sentry.io. Error tracking, monitoraggio applicazioni e performance per sviluppatori.";
RELATE i18n_key:credential_type_sentry_io_api_description->translation->language:de SET text = "Token-Authentifizierung für Sentry.io. Fehler-Tracking, Anwendungsüberwachung und Leistungsüberwachung für Entwickler.";
RELATE i18n_key:credential_type_sentry_io_api_description->translation->language:es SET text = "Autenticación mediante token para Sentry.io. Error tracking, monitoreo aplicaciones y performance para desarrolladores.";

RELATE i18n_key:credential_type_sentry_io_api_tooltip->translation->language:fr SET text = "Pour Sentry error tracking";
RELATE i18n_key:credential_type_sentry_io_api_tooltip->translation->language:en SET text = "For Sentry error tracking";
RELATE i18n_key:credential_type_sentry_io_api_tooltip->translation->language:it SET text = "Per Sentry error tracking";
RELATE i18n_key:credential_type_sentry_io_api_tooltip->translation->language:de SET text = "Für Sentry Fehler-Tracking";
RELATE i18n_key:credential_type_sentry_io_api_tooltip->translation->language:es SET text = "Para Sentry error tracking";

-- PAGERDUTY API
RELATE i18n_key:credential_type_pagerduty_api_name->translation->language:fr SET text = "PagerDuty API";
RELATE i18n_key:credential_type_pagerduty_api_name->translation->language:en SET text = "PagerDuty API";
RELATE i18n_key:credential_type_pagerduty_api_name->translation->language:it SET text = "PagerDuty API";
RELATE i18n_key:credential_type_pagerduty_api_name->translation->language:de SET text = "PagerDuty API";
RELATE i18n_key:credential_type_pagerduty_api_name->translation->language:es SET text = "PagerDuty API";

RELATE i18n_key:credential_type_pagerduty_api_description->translation->language:fr SET text = "Authentification par token pour PagerDuty. Incident management, on-call scheduling et alerting pour DevOps.";
RELATE i18n_key:credential_type_pagerduty_api_description->translation->language:en SET text = "Token authentication for PagerDuty. Incident management, on-call scheduling and alerting for DevOps.";
RELATE i18n_key:credential_type_pagerduty_api_description->translation->language:it SET text = "Autenticazione tramite token per PagerDuty. Gestione incidenti, pianificazione reperibilità e alerting per DevOps.";
RELATE i18n_key:credential_type_pagerduty_api_description->translation->language:de SET text = "Token-Authentifizierung für PagerDuty. Incident-Management, Bereitschaftsplanung und Alarmierung für DevOps.";
RELATE i18n_key:credential_type_pagerduty_api_description->translation->language:es SET text = "Autenticación mediante token para PagerDuty. Gestión incidentes, programación guardia y alerting para DevOps.";

RELATE i18n_key:credential_type_pagerduty_api_tooltip->translation->language:fr SET text = "Pour PagerDuty incident management";
RELATE i18n_key:credential_type_pagerduty_api_tooltip->translation->language:en SET text = "For PagerDuty incident management";
RELATE i18n_key:credential_type_pagerduty_api_tooltip->translation->language:it SET text = "Per PagerDuty gestione incidenti";
RELATE i18n_key:credential_type_pagerduty_api_tooltip->translation->language:de SET text = "Für PagerDuty Incident-Management";
RELATE i18n_key:credential_type_pagerduty_api_tooltip->translation->language:es SET text = "Para PagerDuty gestión incidentes";

-- PAGERDUTY OAUTH2 API
RELATE i18n_key:credential_type_pagerduty_oauth2_api_name->translation->language:fr SET text = "PagerDuty OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_name->translation->language:en SET text = "PagerDuty OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_name->translation->language:it SET text = "PagerDuty OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_name->translation->language:de SET text = "PagerDuty OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_name->translation->language:es SET text = "PagerDuty OAuth2";

RELATE i18n_key:credential_type_pagerduty_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour PagerDuty. Version OAuth2 pour applications tierces avec scope write.";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for PagerDuty. OAuth2 version for third-party applications with write scope.";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per PagerDuty. Versione OAuth2 per applicazioni terze con scope write.";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für PagerDuty. OAuth2-Version für Drittanbieteranwendungen mit Write-Scope.";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para PagerDuty. Versión OAuth2 para aplicaciones terceros con scope write.";

RELATE i18n_key:credential_type_pagerduty_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces PagerDuty avec OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_tooltip->translation->language:en SET text = "For third-party PagerDuty apps with OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_tooltip->translation->language:it SET text = "Per app terze PagerDuty con OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-PagerDuty-Apps mit OAuth2";
RELATE i18n_key:credential_type_pagerduty_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros PagerDuty con OAuth2";

-- OPENWEATHERMAP API
RELATE i18n_key:credential_type_openweathermap_api_name->translation->language:fr SET text = "OpenWeatherMap API";
RELATE i18n_key:credential_type_openweathermap_api_name->translation->language:en SET text = "OpenWeatherMap API";
RELATE i18n_key:credential_type_openweathermap_api_name->translation->language:it SET text = "OpenWeatherMap API";
RELATE i18n_key:credential_type_openweathermap_api_name->translation->language:de SET text = "OpenWeatherMap API";
RELATE i18n_key:credential_type_openweathermap_api_name->translation->language:es SET text = "OpenWeatherMap API";

RELATE i18n_key:credential_type_openweathermap_api_description->translation->language:fr SET text = "Authentification par clé API pour OpenWeatherMap. API météo populaire avec free tier et données temps réel.";
RELATE i18n_key:credential_type_openweathermap_api_description->translation->language:en SET text = "API key authentication for OpenWeatherMap. Popular weather API with free tier and real-time data.";
RELATE i18n_key:credential_type_openweathermap_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per OpenWeatherMap. API meteo popolare con free tier e dati tempo reale.";
RELATE i18n_key:credential_type_openweathermap_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für OpenWeatherMap. Beliebte Wetter-API mit Free Tier und Echtzeitdaten.";
RELATE i18n_key:credential_type_openweathermap_api_description->translation->language:es SET text = "Autenticación mediante clave API para OpenWeatherMap. API clima popular con free tier y datos tiempo real.";

RELATE i18n_key:credential_type_openweathermap_api_tooltip->translation->language:fr SET text = "Pour OpenWeatherMap données météo";
RELATE i18n_key:credential_type_openweathermap_api_tooltip->translation->language:en SET text = "For OpenWeatherMap weather data";
RELATE i18n_key:credential_type_openweathermap_api_tooltip->translation->language:it SET text = "Per OpenWeatherMap dati meteo";
RELATE i18n_key:credential_type_openweathermap_api_tooltip->translation->language:de SET text = "Für OpenWeatherMap Wetterdaten";
RELATE i18n_key:credential_type_openweathermap_api_tooltip->translation->language:es SET text = "Para OpenWeatherMap datos clima";

-- NASA API
RELATE i18n_key:credential_type_nasa_api_name->translation->language:fr SET text = "NASA API";
RELATE i18n_key:credential_type_nasa_api_name->translation->language:en SET text = "NASA API";
RELATE i18n_key:credential_type_nasa_api_name->translation->language:it SET text = "NASA API";
RELATE i18n_key:credential_type_nasa_api_name->translation->language:de SET text = "NASA API";
RELATE i18n_key:credential_type_nasa_api_name->translation->language:es SET text = "NASA API";

RELATE i18n_key:credential_type_nasa_api_description->translation->language:fr SET text = "Authentification par clé API pour NASA. API gouvernementale open data gratuite avec données spatiales et astronomie.";
RELATE i18n_key:credential_type_nasa_api_description->translation->language:en SET text = "API key authentication for NASA. Free government open data API with space data and astronomy.";
RELATE i18n_key:credential_type_nasa_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per NASA. API open data governativa gratuita con dati spaziali e astronomia.";
RELATE i18n_key:credential_type_nasa_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für NASA. Kostenlose staatliche Open-Data-API mit Weltraumdaten und Astronomie.";
RELATE i18n_key:credential_type_nasa_api_description->translation->language:es SET text = "Autenticación mediante clave API para NASA. API open data gubernamental gratuita con datos espaciales y astronomía.";

RELATE i18n_key:credential_type_nasa_api_tooltip->translation->language:fr SET text = "Pour NASA données spatiales";
RELATE i18n_key:credential_type_nasa_api_tooltip->translation->language:en SET text = "For NASA space data";
RELATE i18n_key:credential_type_nasa_api_tooltip->translation->language:it SET text = "Per NASA dati spaziali";
RELATE i18n_key:credential_type_nasa_api_tooltip->translation->language:de SET text = "Für NASA Weltraumdaten";
RELATE i18n_key:credential_type_nasa_api_tooltip->translation->language:es SET text = "Para NASA datos espaciales";

-- HUNTER API
RELATE i18n_key:credential_type_hunter_api_name->translation->language:fr SET text = "Hunter API";
RELATE i18n_key:credential_type_hunter_api_name->translation->language:en SET text = "Hunter API";
RELATE i18n_key:credential_type_hunter_api_name->translation->language:it SET text = "Hunter API";
RELATE i18n_key:credential_type_hunter_api_name->translation->language:de SET text = "Hunter API";
RELATE i18n_key:credential_type_hunter_api_name->translation->language:es SET text = "Hunter API";

RELATE i18n_key:credential_type_hunter_api_description->translation->language:fr SET text = "Authentification par clé API pour Hunter.io. Email finder, vérification email et data enrichment pour sales teams.";
RELATE i18n_key:credential_type_hunter_api_description->translation->language:en SET text = "API key authentication for Hunter.io. Email finder, email verification and data enrichment for sales teams.";
RELATE i18n_key:credential_type_hunter_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Hunter.io. Email finder, verifica email e arricchimento dati per team vendite.";
RELATE i18n_key:credential_type_hunter_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Hunter.io. E-Mail-Finder, E-Mail-Verifizierung und Datenanreicherung für Vertriebsteams.";
RELATE i18n_key:credential_type_hunter_api_description->translation->language:es SET text = "Autenticación mediante clave API para Hunter.io. Email finder, verificación email y enriquecimiento datos para equipos ventas.";

RELATE i18n_key:credential_type_hunter_api_tooltip->translation->language:fr SET text = "Pour Hunter email finder";
RELATE i18n_key:credential_type_hunter_api_tooltip->translation->language:en SET text = "For Hunter email finder";
RELATE i18n_key:credential_type_hunter_api_tooltip->translation->language:it SET text = "Per Hunter email finder";
RELATE i18n_key:credential_type_hunter_api_tooltip->translation->language:de SET text = "Für Hunter E-Mail-Finder";
RELATE i18n_key:credential_type_hunter_api_tooltip->translation->language:es SET text = "Para Hunter email finder";

-- CLEARBIT API
RELATE i18n_key:credential_type_clearbit_api_name->translation->language:fr SET text = "Clearbit API";
RELATE i18n_key:credential_type_clearbit_api_name->translation->language:en SET text = "Clearbit API";
RELATE i18n_key:credential_type_clearbit_api_name->translation->language:it SET text = "Clearbit API";
RELATE i18n_key:credential_type_clearbit_api_name->translation->language:de SET text = "Clearbit API";
RELATE i18n_key:credential_type_clearbit_api_name->translation->language:es SET text = "Clearbit API";

RELATE i18n_key:credential_type_clearbit_api_description->translation->language:fr SET text = "Authentification par clé API pour Clearbit. Business intelligence, lead enrichment et company data enrichment.";
RELATE i18n_key:credential_type_clearbit_api_description->translation->language:en SET text = "API key authentication for Clearbit. Business intelligence, lead enrichment and company data enrichment.";
RELATE i18n_key:credential_type_clearbit_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Clearbit. Business intelligence, arricchimento lead e dati aziendali.";
RELATE i18n_key:credential_type_clearbit_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Clearbit. Business Intelligence, Lead-Anreicherung und Unternehmensdatenanreicherung.";
RELATE i18n_key:credential_type_clearbit_api_description->translation->language:es SET text = "Autenticación mediante clave API para Clearbit. Business intelligence, enriquecimiento leads y datos empresariales.";

RELATE i18n_key:credential_type_clearbit_api_tooltip->translation->language:fr SET text = "Pour Clearbit data enrichment";
RELATE i18n_key:credential_type_clearbit_api_tooltip->translation->language:en SET text = "For Clearbit data enrichment";
RELATE i18n_key:credential_type_clearbit_api_tooltip->translation->language:it SET text = "Per Clearbit arricchimento dati";
RELATE i18n_key:credential_type_clearbit_api_tooltip->translation->language:de SET text = "Für Clearbit Datenanreicherung";
RELATE i18n_key:credential_type_clearbit_api_tooltip->translation->language:es SET text = "Para Clearbit enriquecimiento datos";

-- RAINDROP OAUTH2 API
RELATE i18n_key:credential_type_raindrop_oauth2_api_name->translation->language:fr SET text = "Raindrop OAuth2";
RELATE i18n_key:credential_type_raindrop_oauth2_api_name->translation->language:en SET text = "Raindrop OAuth2";
RELATE i18n_key:credential_type_raindrop_oauth2_api_name->translation->language:it SET text = "Raindrop OAuth2";
RELATE i18n_key:credential_type_raindrop_oauth2_api_name->translation->language:de SET text = "Raindrop OAuth2";
RELATE i18n_key:credential_type_raindrop_oauth2_api_name->translation->language:es SET text = "Raindrop OAuth2";

RELATE i18n_key:credential_type_raindrop_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Raindrop.io. Bookmark manager et productivity tool pour sauvegarder liens.";
RELATE i18n_key:credential_type_raindrop_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Raindrop.io. Bookmark manager and productivity tool for saving links.";
RELATE i18n_key:credential_type_raindrop_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Raindrop.io. Gestore segnalibri e strumento produttività per salvare link.";
RELATE i18n_key:credential_type_raindrop_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Raindrop.io. Lesezeichen-Manager und Produktivitätstool zum Speichern von Links.";
RELATE i18n_key:credential_type_raindrop_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Raindrop.io. Gestor marcadores y herramienta productividad para guardar enlaces.";

RELATE i18n_key:credential_type_raindrop_oauth2_api_tooltip->translation->language:fr SET text = "Pour Raindrop bookmark manager";
RELATE i18n_key:credential_type_raindrop_oauth2_api_tooltip->translation->language:en SET text = "For Raindrop bookmark manager";
RELATE i18n_key:credential_type_raindrop_oauth2_api_tooltip->translation->language:it SET text = "Per Raindrop gestore segnalibri";
RELATE i18n_key:credential_type_raindrop_oauth2_api_tooltip->translation->language:de SET text = "Für Raindrop Lesezeichen-Manager";
RELATE i18n_key:credential_type_raindrop_oauth2_api_tooltip->translation->language:es SET text = "Para Raindrop gestor marcadores";

-- THEHIVE API
RELATE i18n_key:credential_type_thehive_api_name->translation->language:fr SET text = "TheHive API";
RELATE i18n_key:credential_type_thehive_api_name->translation->language:en SET text = "TheHive API";
RELATE i18n_key:credential_type_thehive_api_name->translation->language:it SET text = "TheHive API";
RELATE i18n_key:credential_type_thehive_api_name->translation->language:de SET text = "TheHive API";
RELATE i18n_key:credential_type_thehive_api_name->translation->language:es SET text = "TheHive API";

RELATE i18n_key:credential_type_thehive_api_description->translation->language:fr SET text = "Authentification par clé API pour TheHive. Plateforme open-source security incident response, threat intelligence et SOC avec support v3-v5.";
RELATE i18n_key:credential_type_thehive_api_description->translation->language:en SET text = "API key authentication for TheHive. Open-source security incident response, threat intelligence and SOC platform with v3-v5 support.";
RELATE i18n_key:credential_type_thehive_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per TheHive. Piattaforma open-source risposta incidenti sicurezza, threat intelligence e SOC con supporto v3-v5.";
RELATE i18n_key:credential_type_thehive_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für TheHive. Open-Source-Plattform für Sicherheitsvorfallreaktion, Threat Intelligence und SOC mit v3-v5-Unterstützung.";
RELATE i18n_key:credential_type_thehive_api_description->translation->language:es SET text = "Autenticación mediante clave API para TheHive. Plataforma open-source respuesta incidentes seguridad, threat intelligence y SOC con soporte v3-v5.";

RELATE i18n_key:credential_type_thehive_api_tooltip->translation->language:fr SET text = "Pour TheHive incident response SOC";
RELATE i18n_key:credential_type_thehive_api_tooltip->translation->language:en SET text = "For TheHive incident response SOC";
RELATE i18n_key:credential_type_thehive_api_tooltip->translation->language:it SET text = "Per TheHive risposta incidenti SOC";
RELATE i18n_key:credential_type_thehive_api_tooltip->translation->language:de SET text = "Für TheHive Incident Response SOC";
RELATE i18n_key:credential_type_thehive_api_tooltip->translation->language:es SET text = "Para TheHive respuesta incidentes SOC";

-- =============================================================================================

