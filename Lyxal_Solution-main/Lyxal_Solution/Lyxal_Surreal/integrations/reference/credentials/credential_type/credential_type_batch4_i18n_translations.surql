-- =============================================================================================
-- |
-- | Fichier : credential_type_batch4_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 4 des credential types.
-- |
-- | Batch 4 : Top Communication (13 credentials)
-- | Providers : Slack, Discord, Telegram, Twilio, WhatsApp, Mattermost, RocketChat, Matrix, Twist
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 195 traductions (39 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- SLACK API
-- =====================================================

RELATE i18n_key:credential_type_slack_api_name->translation->language:fr SET text = "Slack API";
RELATE i18n_key:credential_type_slack_api_name->translation->language:en SET text = "Slack API";
RELATE i18n_key:credential_type_slack_api_name->translation->language:it SET text = "Slack API";
RELATE i18n_key:credential_type_slack_api_name->translation->language:de SET text = "Slack API";
RELATE i18n_key:credential_type_slack_api_name->translation->language:es SET text = "Slack API";

RELATE i18n_key:credential_type_slack_api_description->translation->language:fr SET text = "Authentification par token pour Slack API. Permet d'envoyer des messages, gérer des canaux et automatiser la communication d'équipe dans Slack.";
RELATE i18n_key:credential_type_slack_api_description->translation->language:en SET text = "Token-based authentication for Slack API. Allows sending messages, managing channels, and automating team communication in Slack.";
RELATE i18n_key:credential_type_slack_api_description->translation->language:it SET text = "Autenticazione basata su token per Slack API. Consente di inviare messaggi, gestire canali e automatizzare la comunicazione di squadra in Slack.";
RELATE i18n_key:credential_type_slack_api_description->translation->language:de SET text = "Token-basierte Authentifizierung für Slack API. Ermöglicht das Senden von Nachrichten, Verwalten von Kanälen und Automatisieren der Teamkommunikation in Slack.";
RELATE i18n_key:credential_type_slack_api_description->translation->language:es SET text = "Autenticación basada en token para Slack API. Permite enviar mensajes, gestionar canales y automatizar comunicación de equipo en Slack.";

RELATE i18n_key:credential_type_slack_api_tooltip->translation->language:fr SET text = "Pour messagerie d'équipe et notifications Slack";
RELATE i18n_key:credential_type_slack_api_tooltip->translation->language:en SET text = "For team messaging and Slack notifications";
RELATE i18n_key:credential_type_slack_api_tooltip->translation->language:it SET text = "Per messaggistica di squadra e notifiche Slack";
RELATE i18n_key:credential_type_slack_api_tooltip->translation->language:de SET text = "Für Team-Messaging und Slack-Benachrichtigungen";
RELATE i18n_key:credential_type_slack_api_tooltip->translation->language:es SET text = "Para mensajería equipo y notificaciones Slack";

-- =====================================================
-- SLACK OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_slack_oauth2_api_name->translation->language:fr SET text = "Slack OAuth2";
RELATE i18n_key:credential_type_slack_oauth2_api_name->translation->language:en SET text = "Slack OAuth2";
RELATE i18n_key:credential_type_slack_oauth2_api_name->translation->language:it SET text = "Slack OAuth2";
RELATE i18n_key:credential_type_slack_oauth2_api_name->translation->language:de SET text = "Slack OAuth2";
RELATE i18n_key:credential_type_slack_oauth2_api_name->translation->language:es SET text = "Slack OAuth2";

RELATE i18n_key:credential_type_slack_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Slack API. Permet des intégrations Slack avec authentification utilisateur pour accès complet aux workspaces.";
RELATE i18n_key:credential_type_slack_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Slack API. Enables Slack integrations with user authentication for full workspace access.";
RELATE i18n_key:credential_type_slack_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Slack API. Abilita integrazioni Slack con autenticazione utente per accesso completo ai workspace.";
RELATE i18n_key:credential_type_slack_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Slack API. Ermöglicht Slack-Integrationen mit Benutzerauthentifizierung für vollständigen Workspace-Zugriff.";
RELATE i18n_key:credential_type_slack_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Slack API. Habilita integraciones Slack con autenticación usuario para acceso completo workspaces.";

RELATE i18n_key:credential_type_slack_oauth2_api_tooltip->translation->language:fr SET text = "Pour applications Slack avec accès utilisateur";
RELATE i18n_key:credential_type_slack_oauth2_api_tooltip->translation->language:en SET text = "For Slack apps with user access";
RELATE i18n_key:credential_type_slack_oauth2_api_tooltip->translation->language:it SET text = "Per app Slack con accesso utente";
RELATE i18n_key:credential_type_slack_oauth2_api_tooltip->translation->language:de SET text = "Für Slack-Apps mit Benutzerzugriff";
RELATE i18n_key:credential_type_slack_oauth2_api_tooltip->translation->language:es SET text = "Para apps Slack con acceso usuario";

-- =====================================================
-- DISCORD BOT API
-- =====================================================

RELATE i18n_key:credential_type_discord_bot_api_name->translation->language:fr SET text = "Discord Bot";
RELATE i18n_key:credential_type_discord_bot_api_name->translation->language:en SET text = "Discord Bot";
RELATE i18n_key:credential_type_discord_bot_api_name->translation->language:it SET text = "Discord Bot";
RELATE i18n_key:credential_type_discord_bot_api_name->translation->language:de SET text = "Discord Bot";
RELATE i18n_key:credential_type_discord_bot_api_name->translation->language:es SET text = "Discord Bot";

RELATE i18n_key:credential_type_discord_bot_api_description->translation->language:fr SET text = "Authentification par token de bot pour Discord API. Permet de créer des bots Discord pour envoyer messages, gérer serveurs et réagir aux événements.";
RELATE i18n_key:credential_type_discord_bot_api_description->translation->language:en SET text = "Bot token authentication for Discord API. Allows creating Discord bots to send messages, manage servers, and respond to events.";
RELATE i18n_key:credential_type_discord_bot_api_description->translation->language:it SET text = "Autenticazione tramite token bot per Discord API. Consente di creare bot Discord per inviare messaggi, gestire server e rispondere agli eventi.";
RELATE i18n_key:credential_type_discord_bot_api_description->translation->language:de SET text = "Bot-Token-Authentifizierung für Discord API. Ermöglicht das Erstellen von Discord-Bots zum Senden von Nachrichten, Verwalten von Servern und Reagieren auf Ereignisse.";
RELATE i18n_key:credential_type_discord_bot_api_description->translation->language:es SET text = "Autenticación mediante token bot para Discord API. Permite crear bots Discord para enviar mensajes, gestionar servidores y responder eventos.";

RELATE i18n_key:credential_type_discord_bot_api_tooltip->translation->language:fr SET text = "Pour bots Discord et automatisation communauté";
RELATE i18n_key:credential_type_discord_bot_api_tooltip->translation->language:en SET text = "For Discord bots and community automation";
RELATE i18n_key:credential_type_discord_bot_api_tooltip->translation->language:it SET text = "Per bot Discord e automazione comunità";
RELATE i18n_key:credential_type_discord_bot_api_tooltip->translation->language:de SET text = "Für Discord-Bots und Community-Automatisierung";
RELATE i18n_key:credential_type_discord_bot_api_tooltip->translation->language:es SET text = "Para bots Discord y automatización comunidad";

-- =====================================================
-- DISCORD OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_discord_oauth2_api_name->translation->language:fr SET text = "Discord OAuth2";
RELATE i18n_key:credential_type_discord_oauth2_api_name->translation->language:en SET text = "Discord OAuth2";
RELATE i18n_key:credential_type_discord_oauth2_api_name->translation->language:it SET text = "Discord OAuth2";
RELATE i18n_key:credential_type_discord_oauth2_api_name->translation->language:de SET text = "Discord OAuth2";
RELATE i18n_key:credential_type_discord_oauth2_api_name->translation->language:es SET text = "Discord OAuth2";

RELATE i18n_key:credential_type_discord_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Discord API. Permet d'accéder aux données utilisateur Discord et d'intégrer l'authentification Discord dans applications.";
RELATE i18n_key:credential_type_discord_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Discord API. Allows accessing Discord user data and integrating Discord authentication into applications.";
RELATE i18n_key:credential_type_discord_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Discord API. Consente di accedere ai dati utente Discord e integrare l'autenticazione Discord nelle applicazioni.";
RELATE i18n_key:credential_type_discord_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Discord API. Ermöglicht den Zugriff auf Discord-Benutzerdaten und die Integration von Discord-Authentifizierung in Anwendungen.";
RELATE i18n_key:credential_type_discord_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Discord API. Permite acceder datos usuario Discord e integrar autenticación Discord en aplicaciones.";

RELATE i18n_key:credential_type_discord_oauth2_api_tooltip->translation->language:fr SET text = "Pour connexion Discord et accès profil utilisateur";
RELATE i18n_key:credential_type_discord_oauth2_api_tooltip->translation->language:en SET text = "For Discord login and user profile access";
RELATE i18n_key:credential_type_discord_oauth2_api_tooltip->translation->language:it SET text = "Per login Discord e accesso profilo utente";
RELATE i18n_key:credential_type_discord_oauth2_api_tooltip->translation->language:de SET text = "Für Discord-Login und Benutzerprofilzugriff";
RELATE i18n_key:credential_type_discord_oauth2_api_tooltip->translation->language:es SET text = "Para login Discord y acceso perfil usuario";

-- =====================================================
-- DISCORD WEBHOOK API
-- =====================================================

RELATE i18n_key:credential_type_discord_webhook_api_name->translation->language:fr SET text = "Discord Webhook";
RELATE i18n_key:credential_type_discord_webhook_api_name->translation->language:en SET text = "Discord Webhook";
RELATE i18n_key:credential_type_discord_webhook_api_name->translation->language:it SET text = "Discord Webhook";
RELATE i18n_key:credential_type_discord_webhook_api_name->translation->language:de SET text = "Discord Webhook";
RELATE i18n_key:credential_type_discord_webhook_api_name->translation->language:es SET text = "Discord Webhook";

RELATE i18n_key:credential_type_discord_webhook_api_description->translation->language:fr SET text = "Authentification par webhook Discord. Méthode simple pour envoyer des messages dans un canal Discord sans créer de bot complet.";
RELATE i18n_key:credential_type_discord_webhook_api_description->translation->language:en SET text = "Discord webhook authentication. Simple method to send messages to a Discord channel without creating a full bot.";
RELATE i18n_key:credential_type_discord_webhook_api_description->translation->language:it SET text = "Autenticazione tramite webhook Discord. Metodo semplice per inviare messaggi in un canale Discord senza creare un bot completo.";
RELATE i18n_key:credential_type_discord_webhook_api_description->translation->language:de SET text = "Discord-Webhook-Authentifizierung. Einfache Methode zum Senden von Nachrichten an einen Discord-Kanal ohne vollständigen Bot.";
RELATE i18n_key:credential_type_discord_webhook_api_description->translation->language:es SET text = "Autenticación mediante webhook Discord. Método simple para enviar mensajes canal Discord sin crear bot completo.";

RELATE i18n_key:credential_type_discord_webhook_api_tooltip->translation->language:fr SET text = "Simple pour notifications Discord sans bot";
RELATE i18n_key:credential_type_discord_webhook_api_tooltip->translation->language:en SET text = "Simple for Discord notifications without bot";
RELATE i18n_key:credential_type_discord_webhook_api_tooltip->translation->language:it SET text = "Semplice per notifiche Discord senza bot";
RELATE i18n_key:credential_type_discord_webhook_api_tooltip->translation->language:de SET text = "Einfach für Discord-Benachrichtigungen ohne Bot";
RELATE i18n_key:credential_type_discord_webhook_api_tooltip->translation->language:es SET text = "Simple para notificaciones Discord sin bot";

-- =====================================================
-- TELEGRAM API
-- =====================================================

RELATE i18n_key:credential_type_telegram_api_name->translation->language:fr SET text = "Telegram Bot";
RELATE i18n_key:credential_type_telegram_api_name->translation->language:en SET text = "Telegram Bot";
RELATE i18n_key:credential_type_telegram_api_name->translation->language:it SET text = "Telegram Bot";
RELATE i18n_key:credential_type_telegram_api_name->translation->language:de SET text = "Telegram Bot";
RELATE i18n_key:credential_type_telegram_api_name->translation->language:es SET text = "Telegram Bot";

RELATE i18n_key:credential_type_telegram_api_description->translation->language:fr SET text = "Authentification par token pour Telegram Bot API. Permet de créer des bots Telegram pour messagerie automatisée, notifications et interactions utilisateur.";
RELATE i18n_key:credential_type_telegram_api_description->translation->language:en SET text = "Token-based authentication for Telegram Bot API. Allows creating Telegram bots for automated messaging, notifications, and user interactions.";
RELATE i18n_key:credential_type_telegram_api_description->translation->language:it SET text = "Autenticazione basata su token per Telegram Bot API. Consente di creare bot Telegram per messaggistica automatizzata, notifiche e interazioni utente.";
RELATE i18n_key:credential_type_telegram_api_description->translation->language:de SET text = "Token-basierte Authentifizierung für Telegram Bot API. Ermöglicht das Erstellen von Telegram-Bots für automatisierte Nachrichten, Benachrichtigungen und Benutzerinteraktionen.";
RELATE i18n_key:credential_type_telegram_api_description->translation->language:es SET text = "Autenticación basada en token para Telegram Bot API. Permite crear bots Telegram para mensajería automatizada, notificaciones e interacciones usuario.";

RELATE i18n_key:credential_type_telegram_api_tooltip->translation->language:fr SET text = "Pour bots Telegram et notifications mobiles";
RELATE i18n_key:credential_type_telegram_api_tooltip->translation->language:en SET text = "For Telegram bots and mobile notifications";
RELATE i18n_key:credential_type_telegram_api_tooltip->translation->language:it SET text = "Per bot Telegram e notifiche mobili";
RELATE i18n_key:credential_type_telegram_api_tooltip->translation->language:de SET text = "Für Telegram-Bots und mobile Benachrichtigungen";
RELATE i18n_key:credential_type_telegram_api_tooltip->translation->language:es SET text = "Para bots Telegram y notificaciones móviles";

-- =====================================================
-- TWILIO API
-- =====================================================

RELATE i18n_key:credential_type_twilio_api_name->translation->language:fr SET text = "Twilio API";
RELATE i18n_key:credential_type_twilio_api_name->translation->language:en SET text = "Twilio API";
RELATE i18n_key:credential_type_twilio_api_name->translation->language:it SET text = "Twilio API";
RELATE i18n_key:credential_type_twilio_api_name->translation->language:de SET text = "Twilio API";
RELATE i18n_key:credential_type_twilio_api_name->translation->language:es SET text = "Twilio API";

RELATE i18n_key:credential_type_twilio_api_description->translation->language:fr SET text = "Authentification pour Twilio API. Plateforme de communication cloud pour envoyer SMS, passer appels vocaux et gérer communications programmables.";
RELATE i18n_key:credential_type_twilio_api_description->translation->language:en SET text = "Authentication for Twilio API. Cloud communication platform for sending SMS, making voice calls, and managing programmable communications.";
RELATE i18n_key:credential_type_twilio_api_description->translation->language:it SET text = "Autenticazione per Twilio API. Piattaforma di comunicazione cloud per inviare SMS, effettuare chiamate vocali e gestire comunicazioni programmabili.";
RELATE i18n_key:credential_type_twilio_api_description->translation->language:de SET text = "Authentifizierung für Twilio API. Cloud-Kommunikationsplattform zum Senden von SMS, Tätigen von Sprachanrufen und Verwalten programmierbarer Kommunikation.";
RELATE i18n_key:credential_type_twilio_api_description->translation->language:es SET text = "Autenticación para Twilio API. Plataforma comunicación cloud para enviar SMS, hacer llamadas voz y gestionar comunicaciones programables.";

RELATE i18n_key:credential_type_twilio_api_tooltip->translation->language:fr SET text = "Pour SMS, appels vocaux et communications cloud";
RELATE i18n_key:credential_type_twilio_api_tooltip->translation->language:en SET text = "For SMS, voice calls, and cloud communications";
RELATE i18n_key:credential_type_twilio_api_tooltip->translation->language:it SET text = "Per SMS, chiamate vocali e comunicazioni cloud";
RELATE i18n_key:credential_type_twilio_api_tooltip->translation->language:de SET text = "Für SMS, Sprachanrufe und Cloud-Kommunikation";
RELATE i18n_key:credential_type_twilio_api_tooltip->translation->language:es SET text = "Para SMS, llamadas voz y comunicaciones cloud";

-- =====================================================
-- WHATSAPP API
-- =====================================================

-- =====================================================
-- WHATSAPP TRIGGER API
-- =====================================================

-- =====================================================
-- MATTERMOST API
-- =====================================================

RELATE i18n_key:credential_type_mattermost_api_name->translation->language:fr SET text = "Mattermost API";
RELATE i18n_key:credential_type_mattermost_api_name->translation->language:en SET text = "Mattermost API";
RELATE i18n_key:credential_type_mattermost_api_name->translation->language:it SET text = "Mattermost API";
RELATE i18n_key:credential_type_mattermost_api_name->translation->language:de SET text = "Mattermost API";
RELATE i18n_key:credential_type_mattermost_api_name->translation->language:es SET text = "Mattermost API";

RELATE i18n_key:credential_type_mattermost_api_description->translation->language:fr SET text = "Authentification pour Mattermost API. Plateforme de messagerie d'équipe open-source et auto-hébergée, alternative à Slack pour entreprises.";
RELATE i18n_key:credential_type_mattermost_api_description->translation->language:en SET text = "Authentication for Mattermost API. Open-source, self-hosted team messaging platform, enterprise alternative to Slack.";
RELATE i18n_key:credential_type_mattermost_api_description->translation->language:it SET text = "Autenticazione per Mattermost API. Piattaforma di messaggistica di squadra open-source e self-hosted, alternativa aziendale a Slack.";
RELATE i18n_key:credential_type_mattermost_api_description->translation->language:de SET text = "Authentifizierung für Mattermost API. Open-Source, selbst gehostete Team-Messaging-Plattform, Enterprise-Alternative zu Slack.";
RELATE i18n_key:credential_type_mattermost_api_description->translation->language:es SET text = "Autenticación para Mattermost API. Plataforma mensajería equipo open-source y auto-alojada, alternativa empresarial a Slack.";

RELATE i18n_key:credential_type_mattermost_api_tooltip->translation->language:fr SET text = "Pour messagerie équipe open-source auto-hébergée";
RELATE i18n_key:credential_type_mattermost_api_tooltip->translation->language:en SET text = "For open-source self-hosted team messaging";
RELATE i18n_key:credential_type_mattermost_api_tooltip->translation->language:it SET text = "Per messaggistica squadra open-source self-hosted";
RELATE i18n_key:credential_type_mattermost_api_tooltip->translation->language:de SET text = "Für open-source selbst gehostetes Team-Messaging";
RELATE i18n_key:credential_type_mattermost_api_tooltip->translation->language:es SET text = "Para mensajería equipo open-source auto-alojada";

-- =====================================================
-- ROCKETCHAT API
-- =====================================================

RELATE i18n_key:credential_type_rocketchat_api_name->translation->language:fr SET text = "Rocket.Chat API";
RELATE i18n_key:credential_type_rocketchat_api_name->translation->language:en SET text = "Rocket.Chat API";
RELATE i18n_key:credential_type_rocketchat_api_name->translation->language:it SET text = "Rocket.Chat API";
RELATE i18n_key:credential_type_rocketchat_api_name->translation->language:de SET text = "Rocket.Chat API";
RELATE i18n_key:credential_type_rocketchat_api_name->translation->language:es SET text = "Rocket.Chat API";

RELATE i18n_key:credential_type_rocketchat_api_description->translation->language:fr SET text = "Authentification pour Rocket.Chat API. Plateforme de communication open-source avec chat, audio/vidéo et personnalisation complète.";
RELATE i18n_key:credential_type_rocketchat_api_description->translation->language:en SET text = "Authentication for Rocket.Chat API. Open-source communication platform with chat, audio/video, and full customization.";
RELATE i18n_key:credential_type_rocketchat_api_description->translation->language:it SET text = "Autenticazione per Rocket.Chat API. Piattaforma di comunicazione open-source con chat, audio/video e personalizzazione completa.";
RELATE i18n_key:credential_type_rocketchat_api_description->translation->language:de SET text = "Authentifizierung für Rocket.Chat API. Open-Source-Kommunikationsplattform mit Chat, Audio/Video und vollständiger Anpassung.";
RELATE i18n_key:credential_type_rocketchat_api_description->translation->language:es SET text = "Autenticación para Rocket.Chat API. Plataforma comunicación open-source con chat, audio/video y personalización completa.";

RELATE i18n_key:credential_type_rocketchat_api_tooltip->translation->language:fr SET text = "Pour chat open-source et communications d'équipe";
RELATE i18n_key:credential_type_rocketchat_api_tooltip->translation->language:en SET text = "For open-source chat and team communications";
RELATE i18n_key:credential_type_rocketchat_api_tooltip->translation->language:it SET text = "Per chat open-source e comunicazioni di squadra";
RELATE i18n_key:credential_type_rocketchat_api_tooltip->translation->language:de SET text = "Für open-source Chat und Teamkommunikation";
RELATE i18n_key:credential_type_rocketchat_api_tooltip->translation->language:es SET text = "Para chat open-source y comunicaciones equipo";

-- =====================================================
-- MATRIX API
-- =====================================================

RELATE i18n_key:credential_type_matrix_api_name->translation->language:fr SET text = "Matrix API";
RELATE i18n_key:credential_type_matrix_api_name->translation->language:en SET text = "Matrix API";
RELATE i18n_key:credential_type_matrix_api_name->translation->language:it SET text = "Matrix API";
RELATE i18n_key:credential_type_matrix_api_name->translation->language:de SET text = "Matrix API";
RELATE i18n_key:credential_type_matrix_api_name->translation->language:es SET text = "Matrix API";

RELATE i18n_key:credential_type_matrix_api_description->translation->language:fr SET text = "Authentification pour Matrix API. Protocole de communication décentralisé open-source pour messagerie sécurisée et chiffrée de bout en bout.";
RELATE i18n_key:credential_type_matrix_api_description->translation->language:en SET text = "Authentication for Matrix API. Decentralized open-source communication protocol for secure end-to-end encrypted messaging.";
RELATE i18n_key:credential_type_matrix_api_description->translation->language:it SET text = "Autenticazione per Matrix API. Protocollo di comunicazione decentralizzato open-source per messaggistica sicura e crittografata end-to-end.";
RELATE i18n_key:credential_type_matrix_api_description->translation->language:de SET text = "Authentifizierung für Matrix API. Dezentralisiertes Open-Source-Kommunikationsprotokoll für sichere Ende-zu-Ende-verschlüsselte Nachrichten.";
RELATE i18n_key:credential_type_matrix_api_description->translation->language:es SET text = "Autenticación para Matrix API. Protocolo comunicación descentralizado open-source para mensajería segura cifrada end-to-end.";

RELATE i18n_key:credential_type_matrix_api_tooltip->translation->language:fr SET text = "Pour messagerie décentralisée et chiffrée";
RELATE i18n_key:credential_type_matrix_api_tooltip->translation->language:en SET text = "For decentralized and encrypted messaging";
RELATE i18n_key:credential_type_matrix_api_tooltip->translation->language:it SET text = "Per messaggistica decentralizzata e crittografata";
RELATE i18n_key:credential_type_matrix_api_tooltip->translation->language:de SET text = "Für dezentralisierte und verschlüsselte Nachrichten";
RELATE i18n_key:credential_type_matrix_api_tooltip->translation->language:es SET text = "Para mensajería descentralizada y cifrada";

-- =====================================================
-- TWIST OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_twist_oauth2_api_name->translation->language:fr SET text = "Twist OAuth2";
RELATE i18n_key:credential_type_twist_oauth2_api_name->translation->language:en SET text = "Twist OAuth2";
RELATE i18n_key:credential_type_twist_oauth2_api_name->translation->language:it SET text = "Twist OAuth2";
RELATE i18n_key:credential_type_twist_oauth2_api_name->translation->language:de SET text = "Twist OAuth2";
RELATE i18n_key:credential_type_twist_oauth2_api_name->translation->language:es SET text = "Twist OAuth2";

RELATE i18n_key:credential_type_twist_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Twist API. Plateforme de communication asynchrone pour équipes, alternative calme et organisée à Slack.";
RELATE i18n_key:credential_type_twist_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Twist API. Asynchronous communication platform for teams, calm and organized alternative to Slack.";
RELATE i18n_key:credential_type_twist_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Twist API. Piattaforma di comunicazione asincrona per team, alternativa calma e organizzata a Slack.";
RELATE i18n_key:credential_type_twist_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Twist API. Asynchrone Kommunikationsplattform für Teams, ruhige und organisierte Alternative zu Slack.";
RELATE i18n_key:credential_type_twist_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Twist API. Plataforma comunicación asincrónica para equipos, alternativa tranquila y organizada a Slack.";

RELATE i18n_key:credential_type_twist_oauth2_api_tooltip->translation->language:fr SET text = "Pour communication équipe asynchrone et organisée";
RELATE i18n_key:credential_type_twist_oauth2_api_tooltip->translation->language:en SET text = "For asynchronous and organized team communication";
RELATE i18n_key:credential_type_twist_oauth2_api_tooltip->translation->language:it SET text = "Per comunicazione squadra asincrona e organizzata";
RELATE i18n_key:credential_type_twist_oauth2_api_tooltip->translation->language:de SET text = "Für asynchrone und organisierte Teamkommunikation";
RELATE i18n_key:credential_type_twist_oauth2_api_tooltip->translation->language:es SET text = "Para comunicación equipo asincrónica y organizada";

-- =============================================================================================

