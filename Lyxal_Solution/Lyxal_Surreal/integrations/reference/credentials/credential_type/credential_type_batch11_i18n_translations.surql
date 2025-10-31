-- =============================================================================================
-- |
-- | Fichier : credential_type_batch11_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 11 des credential types.
-- |
-- | Batch 11 : Customer Support, Analytics & Communication APIs (11 credentials)
-- | Providers : Drift, Freshdesk, HelpScout, Intercom, Segment, Zendesk, Mailgun, Postmark, SendGrid
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- DRIFT API
-- =====================================================

RELATE i18n_key:credential_type_drift_api_name->translation->language:fr SET text = "Drift API";
RELATE i18n_key:credential_type_drift_api_name->translation->language:en SET text = "Drift API";
RELATE i18n_key:credential_type_drift_api_name->translation->language:it SET text = "Drift API";
RELATE i18n_key:credential_type_drift_api_name->translation->language:de SET text = "Drift API";
RELATE i18n_key:credential_type_drift_api_name->translation->language:es SET text = "Drift API";

RELATE i18n_key:credential_type_drift_api_description->translation->language:fr SET text = "Authentification par Access Token pour Drift. Plateforme conversational marketing pour chatbots, live chat et automatisation conversations.";
RELATE i18n_key:credential_type_drift_api_description->translation->language:en SET text = "Access Token authentication for Drift. Conversational marketing platform for chatbots, live chat, and conversation automation.";
RELATE i18n_key:credential_type_drift_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Drift. Piattaforma marketing conversazionale per chatbot, live chat e automazione conversazioni.";
RELATE i18n_key:credential_type_drift_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Drift. Conversational Marketing-Plattform für Chatbots, Live-Chat und Gesprächsautomatisierung.";
RELATE i18n_key:credential_type_drift_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Drift. Plataforma marketing conversacional para chatbots, live chat y automatización conversaciones.";

RELATE i18n_key:credential_type_drift_api_tooltip->translation->language:fr SET text = "Pour Drift chatbot et live chat";
RELATE i18n_key:credential_type_drift_api_tooltip->translation->language:en SET text = "For Drift chatbot and live chat";
RELATE i18n_key:credential_type_drift_api_tooltip->translation->language:it SET text = "Per Drift chatbot e live chat";
RELATE i18n_key:credential_type_drift_api_tooltip->translation->language:de SET text = "Für Drift Chatbot und Live-Chat";
RELATE i18n_key:credential_type_drift_api_tooltip->translation->language:es SET text = "Para Drift chatbot y live chat";

-- =====================================================
-- DRIFT OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_drift_oauth2_api_name->translation->language:fr SET text = "Drift OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_name->translation->language:en SET text = "Drift OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_name->translation->language:it SET text = "Drift OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_name->translation->language:de SET text = "Drift OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_name->translation->language:es SET text = "Drift OAuth2";

RELATE i18n_key:credential_type_drift_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Drift. Pour applications tierces avec authentification utilisateur et accès multi-workspace.";
RELATE i18n_key:credential_type_drift_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Drift. For third-party applications with user authentication and multi-workspace access.";
RELATE i18n_key:credential_type_drift_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Drift. Per applicazioni terze con autenticazione utente e accesso multi-workspace.";
RELATE i18n_key:credential_type_drift_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Drift. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Workspace-Zugriff.";
RELATE i18n_key:credential_type_drift_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Drift. Para aplicaciones terceros con autenticación usuario y acceso multi-workspace.";

RELATE i18n_key:credential_type_drift_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Drift avec OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_tooltip->translation->language:en SET text = "For third-party Drift apps with OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Drift con OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Drift-Apps mit OAuth2";
RELATE i18n_key:credential_type_drift_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Drift con OAuth2";

-- =====================================================
-- FRESHDESK API
-- =====================================================

RELATE i18n_key:credential_type_freshdesk_api_name->translation->language:fr SET text = "Freshdesk API";
RELATE i18n_key:credential_type_freshdesk_api_name->translation->language:en SET text = "Freshdesk API";
RELATE i18n_key:credential_type_freshdesk_api_name->translation->language:it SET text = "Freshdesk API";
RELATE i18n_key:credential_type_freshdesk_api_name->translation->language:de SET text = "Freshdesk API";
RELATE i18n_key:credential_type_freshdesk_api_name->translation->language:es SET text = "Freshdesk API";

RELATE i18n_key:credential_type_freshdesk_api_description->translation->language:fr SET text = "Authentification par API Key pour Freshdesk. Plateforme support client cloud pour helpdesk, tickets et service client omnicanal.";
RELATE i18n_key:credential_type_freshdesk_api_description->translation->language:en SET text = "API Key authentication for Freshdesk. Cloud customer support platform for helpdesk, tickets, and omnichannel customer service.";
RELATE i18n_key:credential_type_freshdesk_api_description->translation->language:it SET text = "Autenticazione tramite API Key per Freshdesk. Piattaforma supporto clienti cloud per helpdesk, ticket e servizio clienti omnicanale.";
RELATE i18n_key:credential_type_freshdesk_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Freshdesk. Cloud-Kundensupport-Plattform für Helpdesk, Tickets und Omnichannel-Kundenservice.";
RELATE i18n_key:credential_type_freshdesk_api_description->translation->language:es SET text = "Autenticación mediante API Key para Freshdesk. Plataforma soporte cliente cloud para helpdesk, tickets y servicio cliente omnicanal.";

RELATE i18n_key:credential_type_freshdesk_api_tooltip->translation->language:fr SET text = "Pour Freshdesk helpdesk et support client";
RELATE i18n_key:credential_type_freshdesk_api_tooltip->translation->language:en SET text = "For Freshdesk helpdesk and customer support";
RELATE i18n_key:credential_type_freshdesk_api_tooltip->translation->language:it SET text = "Per Freshdesk helpdesk e supporto clienti";
RELATE i18n_key:credential_type_freshdesk_api_tooltip->translation->language:de SET text = "Für Freshdesk Helpdesk und Kundensupport";
RELATE i18n_key:credential_type_freshdesk_api_tooltip->translation->language:es SET text = "Para Freshdesk helpdesk y soporte cliente";

-- =====================================================
-- HELPSCOUT OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_helpscout_oauth2_api_name->translation->language:fr SET text = "Help Scout OAuth2";
RELATE i18n_key:credential_type_helpscout_oauth2_api_name->translation->language:en SET text = "Help Scout OAuth2";
RELATE i18n_key:credential_type_helpscout_oauth2_api_name->translation->language:it SET text = "Help Scout OAuth2";
RELATE i18n_key:credential_type_helpscout_oauth2_api_name->translation->language:de SET text = "Help Scout OAuth2";
RELATE i18n_key:credential_type_helpscout_oauth2_api_name->translation->language:es SET text = "Help Scout OAuth2";

RELATE i18n_key:credential_type_helpscout_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Help Scout. Plateforme support client avec boîte réception partagée, knowledge base et automatisation.";
RELATE i18n_key:credential_type_helpscout_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Help Scout. Customer support platform with shared inbox, knowledge base, and automation.";
RELATE i18n_key:credential_type_helpscout_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Help Scout. Piattaforma supporto clienti con inbox condivisa, knowledge base e automazione.";
RELATE i18n_key:credential_type_helpscout_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Help Scout. Kundensupport-Plattform mit gemeinsamer Inbox, Wissensdatenbank und Automatisierung.";
RELATE i18n_key:credential_type_helpscout_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Help Scout. Plataforma soporte cliente con bandeja entrada compartida, base conocimientos y automatización.";

RELATE i18n_key:credential_type_helpscout_oauth2_api_tooltip->translation->language:fr SET text = "Pour Help Scout support et inbox partagée";
RELATE i18n_key:credential_type_helpscout_oauth2_api_tooltip->translation->language:en SET text = "For Help Scout support and shared inbox";
RELATE i18n_key:credential_type_helpscout_oauth2_api_tooltip->translation->language:it SET text = "Per Help Scout supporto e inbox condivisa";
RELATE i18n_key:credential_type_helpscout_oauth2_api_tooltip->translation->language:de SET text = "Für Help Scout Support und gemeinsame Inbox";
RELATE i18n_key:credential_type_helpscout_oauth2_api_tooltip->translation->language:es SET text = "Para Help Scout soporte e inbox compartida";

-- =====================================================
-- INTERCOM API
-- =====================================================

RELATE i18n_key:credential_type_intercom_api_name->translation->language:fr SET text = "Intercom API";
RELATE i18n_key:credential_type_intercom_api_name->translation->language:en SET text = "Intercom API";
RELATE i18n_key:credential_type_intercom_api_name->translation->language:it SET text = "Intercom API";
RELATE i18n_key:credential_type_intercom_api_name->translation->language:de SET text = "Intercom API";
RELATE i18n_key:credential_type_intercom_api_name->translation->language:es SET text = "Intercom API";

RELATE i18n_key:credential_type_intercom_api_description->translation->language:fr SET text = "Authentification par Access Token pour Intercom. Plateforme messaging client pour chat, support, engagement et onboarding utilisateurs.";
RELATE i18n_key:credential_type_intercom_api_description->translation->language:en SET text = "Access Token authentication for Intercom. Customer messaging platform for chat, support, engagement, and user onboarding.";
RELATE i18n_key:credential_type_intercom_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Intercom. Piattaforma messaging clienti per chat, supporto, engagement e onboarding utenti.";
RELATE i18n_key:credential_type_intercom_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Intercom. Kundenmessaging-Plattform für Chat, Support, Engagement und User-Onboarding.";
RELATE i18n_key:credential_type_intercom_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Intercom. Plataforma messaging cliente para chat, soporte, engagement y onboarding usuarios.";

RELATE i18n_key:credential_type_intercom_api_tooltip->translation->language:fr SET text = "Pour Intercom messaging et support client";
RELATE i18n_key:credential_type_intercom_api_tooltip->translation->language:en SET text = "For Intercom messaging and customer support";
RELATE i18n_key:credential_type_intercom_api_tooltip->translation->language:it SET text = "Per Intercom messaging e supporto clienti";
RELATE i18n_key:credential_type_intercom_api_tooltip->translation->language:de SET text = "Für Intercom Messaging und Kundensupport";
RELATE i18n_key:credential_type_intercom_api_tooltip->translation->language:es SET text = "Para Intercom messaging y soporte cliente";

-- =====================================================
-- SEGMENT API
-- =====================================================

RELATE i18n_key:credential_type_segment_api_name->translation->language:fr SET text = "Segment API";
RELATE i18n_key:credential_type_segment_api_name->translation->language:en SET text = "Segment API";
RELATE i18n_key:credential_type_segment_api_name->translation->language:it SET text = "Segment API";
RELATE i18n_key:credential_type_segment_api_name->translation->language:de SET text = "Segment API";
RELATE i18n_key:credential_type_segment_api_name->translation->language:es SET text = "Segment API";

RELATE i18n_key:credential_type_segment_api_description->translation->language:fr SET text = "Authentification par Write Key pour Segment. Plateforme Customer Data Platform (CDP) pour collecter, unifier et router données analytics.";
RELATE i18n_key:credential_type_segment_api_description->translation->language:en SET text = "Write Key authentication for Segment. Customer Data Platform (CDP) for collecting, unifying, and routing analytics data.";
RELATE i18n_key:credential_type_segment_api_description->translation->language:it SET text = "Autenticazione tramite Write Key per Segment. Piattaforma Customer Data Platform (CDP) per raccogliere, unificare e indirizzare dati analytics.";
RELATE i18n_key:credential_type_segment_api_description->translation->language:de SET text = "Write Key-Authentifizierung für Segment. Customer Data Platform (CDP) zum Sammeln, Vereinheitlichen und Routen von Analytics-Daten.";
RELATE i18n_key:credential_type_segment_api_description->translation->language:es SET text = "Autenticación mediante Write Key para Segment. Plataforma Customer Data Platform (CDP) para recopilar, unificar y enrutar datos analytics.";

RELATE i18n_key:credential_type_segment_api_tooltip->translation->language:fr SET text = "Pour Segment CDP et tracking analytics";
RELATE i18n_key:credential_type_segment_api_tooltip->translation->language:en SET text = "For Segment CDP and analytics tracking";
RELATE i18n_key:credential_type_segment_api_tooltip->translation->language:it SET text = "Per Segment CDP e tracking analytics";
RELATE i18n_key:credential_type_segment_api_tooltip->translation->language:de SET text = "Für Segment CDP und Analytics-Tracking";
RELATE i18n_key:credential_type_segment_api_tooltip->translation->language:es SET text = "Para Segment CDP y tracking analytics";

-- =====================================================
-- ZENDESK API
-- =====================================================

RELATE i18n_key:credential_type_zendesk_api_name->translation->language:fr SET text = "Zendesk API";
RELATE i18n_key:credential_type_zendesk_api_name->translation->language:en SET text = "Zendesk API";
RELATE i18n_key:credential_type_zendesk_api_name->translation->language:it SET text = "Zendesk API";
RELATE i18n_key:credential_type_zendesk_api_name->translation->language:de SET text = "Zendesk API";
RELATE i18n_key:credential_type_zendesk_api_name->translation->language:es SET text = "Zendesk API";

RELATE i18n_key:credential_type_zendesk_api_description->translation->language:fr SET text = "Authentification par API Token pour Zendesk. Leader support client cloud pour ticketing, helpdesk et service client multicanal.";
RELATE i18n_key:credential_type_zendesk_api_description->translation->language:en SET text = "API Token authentication for Zendesk. Cloud customer support leader for ticketing, helpdesk, and multichannel customer service.";
RELATE i18n_key:credential_type_zendesk_api_description->translation->language:it SET text = "Autenticazione tramite API Token per Zendesk. Leader supporto clienti cloud per ticketing, helpdesk e servizio clienti multicanale.";
RELATE i18n_key:credential_type_zendesk_api_description->translation->language:de SET text = "API-Token-Authentifizierung für Zendesk. Cloud-Kundensupport-Marktführer für Ticketing, Helpdesk und Multichannel-Kundenservice.";
RELATE i18n_key:credential_type_zendesk_api_description->translation->language:es SET text = "Autenticación mediante API Token para Zendesk. Líder soporte cliente cloud para ticketing, helpdesk y servicio cliente multicanal.";

RELATE i18n_key:credential_type_zendesk_api_tooltip->translation->language:fr SET text = "Pour Zendesk ticketing et support client";
RELATE i18n_key:credential_type_zendesk_api_tooltip->translation->language:en SET text = "For Zendesk ticketing and customer support";
RELATE i18n_key:credential_type_zendesk_api_tooltip->translation->language:it SET text = "Per Zendesk ticketing e supporto clienti";
RELATE i18n_key:credential_type_zendesk_api_tooltip->translation->language:de SET text = "Für Zendesk Ticketing und Kundensupport";
RELATE i18n_key:credential_type_zendesk_api_tooltip->translation->language:es SET text = "Para Zendesk ticketing y soporte cliente";

-- =====================================================
-- ZENDESK OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_zendesk_oauth2_api_name->translation->language:fr SET text = "Zendesk OAuth2";
RELATE i18n_key:credential_type_zendesk_oauth2_api_name->translation->language:en SET text = "Zendesk OAuth2";
RELATE i18n_key:credential_type_zendesk_oauth2_api_name->translation->language:it SET text = "Zendesk OAuth2";
RELATE i18n_key:credential_type_zendesk_oauth2_api_name->translation->language:de SET text = "Zendesk OAuth2";
RELATE i18n_key:credential_type_zendesk_oauth2_api_name->translation->language:es SET text = "Zendesk OAuth2";

RELATE i18n_key:credential_type_zendesk_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Zendesk. Pour applications marketplace avec authentification utilisateur et accès multi-account.";
RELATE i18n_key:credential_type_zendesk_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Zendesk. For marketplace applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_zendesk_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Zendesk. Per applicazioni marketplace con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_zendesk_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Zendesk. Für Marketplace-Anwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_zendesk_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Zendesk. Para aplicaciones marketplace con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_zendesk_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps marketplace Zendesk";
RELATE i18n_key:credential_type_zendesk_oauth2_api_tooltip->translation->language:en SET text = "For Zendesk marketplace apps";
RELATE i18n_key:credential_type_zendesk_oauth2_api_tooltip->translation->language:it SET text = "Per app marketplace Zendesk";
RELATE i18n_key:credential_type_zendesk_oauth2_api_tooltip->translation->language:de SET text = "Für Zendesk-Marketplace-Apps";
RELATE i18n_key:credential_type_zendesk_oauth2_api_tooltip->translation->language:es SET text = "Para apps marketplace Zendesk";

-- =====================================================
-- MAILGUN API
-- =====================================================

RELATE i18n_key:credential_type_mailgun_api_name->translation->language:fr SET text = "Mailgun API";
RELATE i18n_key:credential_type_mailgun_api_name->translation->language:en SET text = "Mailgun API";
RELATE i18n_key:credential_type_mailgun_api_name->translation->language:it SET text = "Mailgun API";
RELATE i18n_key:credential_type_mailgun_api_name->translation->language:de SET text = "Mailgun API";
RELATE i18n_key:credential_type_mailgun_api_name->translation->language:es SET text = "Mailgun API";

RELATE i18n_key:credential_type_mailgun_api_description->translation->language:fr SET text = "Authentification par API Key pour Mailgun. Service email transactionnel pour envoi emails automatisés, newsletters et notifications.";
RELATE i18n_key:credential_type_mailgun_api_description->translation->language:en SET text = "API Key authentication for Mailgun. Transactional email service for sending automated emails, newsletters, and notifications.";
RELATE i18n_key:credential_type_mailgun_api_description->translation->language:it SET text = "Autenticazione tramite API Key per Mailgun. Servizio email transazionale per invio email automatiche, newsletter e notifiche.";
RELATE i18n_key:credential_type_mailgun_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Mailgun. Transaktionaler E-Mail-Service zum Senden automatisierter E-Mails, Newsletter und Benachrichtigungen.";
RELATE i18n_key:credential_type_mailgun_api_description->translation->language:es SET text = "Autenticación mediante API Key para Mailgun. Servicio email transaccional para envío emails automatizados, newsletters y notificaciones.";

RELATE i18n_key:credential_type_mailgun_api_tooltip->translation->language:fr SET text = "Pour Mailgun envoi emails transactionnels";
RELATE i18n_key:credential_type_mailgun_api_tooltip->translation->language:en SET text = "For Mailgun transactional email sending";
RELATE i18n_key:credential_type_mailgun_api_tooltip->translation->language:it SET text = "Per Mailgun invio email transazionali";
RELATE i18n_key:credential_type_mailgun_api_tooltip->translation->language:de SET text = "Für Mailgun transaktionale E-Mail-Versand";
RELATE i18n_key:credential_type_mailgun_api_tooltip->translation->language:es SET text = "Para Mailgun envío emails transaccionales";

-- =====================================================
-- POSTMARK API
-- =====================================================

RELATE i18n_key:credential_type_postmark_api_name->translation->language:fr SET text = "Postmark API";
RELATE i18n_key:credential_type_postmark_api_name->translation->language:en SET text = "Postmark API";
RELATE i18n_key:credential_type_postmark_api_name->translation->language:it SET text = "Postmark API";
RELATE i18n_key:credential_type_postmark_api_name->translation->language:de SET text = "Postmark API";
RELATE i18n_key:credential_type_postmark_api_name->translation->language:es SET text = "Postmark API";

RELATE i18n_key:credential_type_postmark_api_description->translation->language:fr SET text = "Authentification par Server Token pour Postmark. Service email transactionnel rapide pour délivrabilité optimale et tracking.";
RELATE i18n_key:credential_type_postmark_api_description->translation->language:en SET text = "Server Token authentication for Postmark. Fast transactional email service for optimal deliverability and tracking.";
RELATE i18n_key:credential_type_postmark_api_description->translation->language:it SET text = "Autenticazione tramite Server Token per Postmark. Servizio email transazionale veloce per deliverability ottimale e tracking.";
RELATE i18n_key:credential_type_postmark_api_description->translation->language:de SET text = "Server Token-Authentifizierung für Postmark. Schneller transaktionaler E-Mail-Service für optimale Zustellbarkeit und Tracking.";
RELATE i18n_key:credential_type_postmark_api_description->translation->language:es SET text = "Autenticación mediante Server Token para Postmark. Servicio email transaccional rápido para deliverability óptima y tracking.";

RELATE i18n_key:credential_type_postmark_api_tooltip->translation->language:fr SET text = "Pour Postmark emails rapides et délivrabilité";
RELATE i18n_key:credential_type_postmark_api_tooltip->translation->language:en SET text = "For Postmark fast emails and deliverability";
RELATE i18n_key:credential_type_postmark_api_tooltip->translation->language:it SET text = "Per Postmark email veloci e deliverability";
RELATE i18n_key:credential_type_postmark_api_tooltip->translation->language:de SET text = "Für Postmark schnelle E-Mails und Zustellbarkeit";
RELATE i18n_key:credential_type_postmark_api_tooltip->translation->language:es SET text = "Para Postmark emails rápidos y deliverability";

-- =====================================================
-- SENDGRID API
-- =====================================================

RELATE i18n_key:credential_type_sendgrid_api_name->translation->language:fr SET text = "SendGrid API";
RELATE i18n_key:credential_type_sendgrid_api_name->translation->language:en SET text = "SendGrid API";
RELATE i18n_key:credential_type_sendgrid_api_name->translation->language:it SET text = "SendGrid API";
RELATE i18n_key:credential_type_sendgrid_api_name->translation->language:de SET text = "SendGrid API";
RELATE i18n_key:credential_type_sendgrid_api_name->translation->language:es SET text = "SendGrid API";

RELATE i18n_key:credential_type_sendgrid_api_description->translation->language:fr SET text = "Authentification par API Key pour SendGrid. Leader email transactionnel Twilio pour envoi emails, campagnes et deliverability.";
RELATE i18n_key:credential_type_sendgrid_api_description->translation->language:en SET text = "API Key authentication for SendGrid. Twilio transactional email leader for email sending, campaigns, and deliverability.";
RELATE i18n_key:credential_type_sendgrid_api_description->translation->language:it SET text = "Autenticazione tramite API Key per SendGrid. Leader email transazionale Twilio per invio email, campagne e deliverability.";
RELATE i18n_key:credential_type_sendgrid_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für SendGrid. Twilio transaktionale E-Mail-Marktführer für E-Mail-Versand, Kampagnen und Zustellbarkeit.";
RELATE i18n_key:credential_type_sendgrid_api_description->translation->language:es SET text = "Autenticación mediante API Key para SendGrid. Líder email transaccional Twilio para envío emails, campañas y deliverability.";

RELATE i18n_key:credential_type_sendgrid_api_tooltip->translation->language:fr SET text = "Pour SendGrid envoi emails et campagnes";
RELATE i18n_key:credential_type_sendgrid_api_tooltip->translation->language:en SET text = "For SendGrid email sending and campaigns";
RELATE i18n_key:credential_type_sendgrid_api_tooltip->translation->language:it SET text = "Per SendGrid invio email e campagne";
RELATE i18n_key:credential_type_sendgrid_api_tooltip->translation->language:de SET text = "Für SendGrid E-Mail-Versand und Kampagnen";
RELATE i18n_key:credential_type_sendgrid_api_tooltip->translation->language:es SET text = "Para SendGrid envío emails y campañas";

-- =====================================================
-- =============================================================================================

