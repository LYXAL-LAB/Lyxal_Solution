-- =============================================================================================
-- |
-- | Fichier : credential_type_batch2_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 2 des credential types.
-- |
-- | Batch 2 : Google Ecosystem (22 credentials)
-- | Provider : Google (provider:google)
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 330 traductions (66 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- GOOGLE ADS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_ads_oauth2_api_name->translation->language:fr SET text = "Google Ads OAuth2";
RELATE i18n_key:credential_type_google_ads_oauth2_api_name->translation->language:en SET text = "Google Ads OAuth2";
RELATE i18n_key:credential_type_google_ads_oauth2_api_name->translation->language:it SET text = "Google Ads OAuth2";
RELATE i18n_key:credential_type_google_ads_oauth2_api_name->translation->language:de SET text = "Google Ads OAuth2";
RELATE i18n_key:credential_type_google_ads_oauth2_api_name->translation->language:es SET text = "Google Ads OAuth2";

RELATE i18n_key:credential_type_google_ads_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Ads API. Permet de gérer des campagnes publicitaires, d'analyser les performances et d'automatiser les opérations marketing.";
RELATE i18n_key:credential_type_google_ads_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Ads API. Allows managing advertising campaigns, analyzing performance, and automating marketing operations.";
RELATE i18n_key:credential_type_google_ads_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Ads API. Consente di gestire campagne pubblicitarie, analizzare le prestazioni e automatizzare le operazioni di marketing.";
RELATE i18n_key:credential_type_google_ads_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Ads API. Ermöglicht die Verwaltung von Werbekampagnen, Leistungsanalysen und Automatisierung von Marketingoperationen.";
RELATE i18n_key:credential_type_google_ads_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Ads API. Permite gestionar campañas publicitarias, analizar rendimiento y automatizar operaciones de marketing.";

RELATE i18n_key:credential_type_google_ads_oauth2_api_tooltip->translation->language:fr SET text = "Pour campagnes publicitaires et analytics marketing";
RELATE i18n_key:credential_type_google_ads_oauth2_api_tooltip->translation->language:en SET text = "For advertising campaigns and marketing analytics";
RELATE i18n_key:credential_type_google_ads_oauth2_api_tooltip->translation->language:it SET text = "Per campagne pubblicitarie e analytics marketing";
RELATE i18n_key:credential_type_google_ads_oauth2_api_tooltip->translation->language:de SET text = "Für Werbekampagnen und Marketing-Analytics";
RELATE i18n_key:credential_type_google_ads_oauth2_api_tooltip->translation->language:es SET text = "Para campañas publicitarias y analytics marketing";

-- =====================================================
-- GOOGLE ANALYTICS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_analytics_oauth2_api_name->translation->language:fr SET text = "Google Analytics OAuth2";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_name->translation->language:en SET text = "Google Analytics OAuth2";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_name->translation->language:it SET text = "Google Analytics OAuth2";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_name->translation->language:de SET text = "Google Analytics OAuth2";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_name->translation->language:es SET text = "Google Analytics OAuth2";

RELATE i18n_key:credential_type_google_analytics_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Analytics API. Permet d'accéder aux données analytics, de créer des rapports personnalisés et d'analyser le trafic web.";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Analytics API. Allows accessing analytics data, creating custom reports, and analyzing web traffic.";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Analytics API. Consente di accedere ai dati analytics, creare report personalizzati e analizzare il traffico web.";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Analytics API. Ermöglicht den Zugriff auf Analytics-Daten, das Erstellen benutzerdefinierter Berichte und die Analyse von Web-Traffic.";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Analytics API. Permite acceder a datos analytics, crear informes personalizados y analizar tráfico web.";

RELATE i18n_key:credential_type_google_analytics_oauth2_api_tooltip->translation->language:fr SET text = "Pour analytics web et rapports de trafic";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_tooltip->translation->language:en SET text = "For web analytics and traffic reports";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_tooltip->translation->language:it SET text = "Per analytics web e report sul traffico";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_tooltip->translation->language:de SET text = "Für Web-Analytics und Traffic-Berichte";
RELATE i18n_key:credential_type_google_analytics_oauth2_api_tooltip->translation->language:es SET text = "Para analytics web e informes de tráfico";

-- =====================================================
-- GOOGLE API (SERVICE ACCOUNT)
-- =====================================================

RELATE i18n_key:credential_type_google_api_name->translation->language:fr SET text = "Google Service Account";
RELATE i18n_key:credential_type_google_api_name->translation->language:en SET text = "Google Service Account";
RELATE i18n_key:credential_type_google_api_name->translation->language:it SET text = "Google Service Account";
RELATE i18n_key:credential_type_google_api_name->translation->language:de SET text = "Google Service Account";
RELATE i18n_key:credential_type_google_api_name->translation->language:es SET text = "Google Service Account";

RELATE i18n_key:credential_type_google_api_description->translation->language:fr SET text = "Authentification par Service Account Google (JSON Key). Pour intégrations serveur-à-serveur sans interaction utilisateur. Utilisé pour Google Cloud APIs.";
RELATE i18n_key:credential_type_google_api_description->translation->language:en SET text = "Google Service Account authentication (JSON Key). For server-to-server integrations without user interaction. Used for Google Cloud APIs.";
RELATE i18n_key:credential_type_google_api_description->translation->language:it SET text = "Autenticazione tramite Service Account Google (JSON Key). Per integrazioni server-to-server senza interazione utente. Utilizzato per Google Cloud APIs.";
RELATE i18n_key:credential_type_google_api_description->translation->language:de SET text = "Google Service Account-Authentifizierung (JSON Key). Für Server-zu-Server-Integrationen ohne Benutzerinteraktion. Verwendet für Google Cloud APIs.";
RELATE i18n_key:credential_type_google_api_description->translation->language:es SET text = "Autenticación mediante Service Account de Google (JSON Key). Para integraciones servidor-a-servidor sin interacción del usuario. Usado para Google Cloud APIs.";

RELATE i18n_key:credential_type_google_api_tooltip->translation->language:fr SET text = "Pour automations serveur sans interaction utilisateur";
RELATE i18n_key:credential_type_google_api_tooltip->translation->language:en SET text = "For server automations without user interaction";
RELATE i18n_key:credential_type_google_api_tooltip->translation->language:it SET text = "Per automazioni server senza interazione utente";
RELATE i18n_key:credential_type_google_api_tooltip->translation->language:de SET text = "Für Server-Automatisierungen ohne Benutzerinteraktion";
RELATE i18n_key:credential_type_google_api_tooltip->translation->language:es SET text = "Para automatizaciones servidor sin interacción usuario";

-- =====================================================
-- GOOGLE BIGQUERY OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_bigquery_oauth2_api_name->translation->language:fr SET text = "Google BigQuery OAuth2";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_name->translation->language:en SET text = "Google BigQuery OAuth2";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_name->translation->language:it SET text = "Google BigQuery OAuth2";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_name->translation->language:de SET text = "Google BigQuery OAuth2";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_name->translation->language:es SET text = "Google BigQuery OAuth2";

RELATE i18n_key:credential_type_google_bigquery_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google BigQuery. Permet d'exécuter des requêtes SQL sur des datasets massifs et d'analyser des données à grande échelle.";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google BigQuery. Allows executing SQL queries on massive datasets and analyzing data at scale.";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google BigQuery. Consente di eseguire query SQL su dataset massivi e analizzare dati su larga scala.";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google BigQuery. Ermöglicht das Ausführen von SQL-Abfragen auf massive Datensätze und die Analyse von Daten im großen Maßstab.";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google BigQuery. Permite ejecutar consultas SQL en datasets masivos y analizar datos a gran escala.";

RELATE i18n_key:credential_type_google_bigquery_oauth2_api_tooltip->translation->language:fr SET text = "Pour analytics Big Data et requêtes SQL massives";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_tooltip->translation->language:en SET text = "For Big Data analytics and massive SQL queries";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_tooltip->translation->language:it SET text = "Per analytics Big Data e query SQL massive";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_tooltip->translation->language:de SET text = "Für Big Data Analytics und massive SQL-Abfragen";
RELATE i18n_key:credential_type_google_bigquery_oauth2_api_tooltip->translation->language:es SET text = "Para analytics Big Data y consultas SQL masivas";

-- =====================================================
-- GOOGLE BOOKS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_books_oauth2_api_name->translation->language:fr SET text = "Google Books OAuth2";
RELATE i18n_key:credential_type_google_books_oauth2_api_name->translation->language:en SET text = "Google Books OAuth2";
RELATE i18n_key:credential_type_google_books_oauth2_api_name->translation->language:it SET text = "Google Books OAuth2";
RELATE i18n_key:credential_type_google_books_oauth2_api_name->translation->language:de SET text = "Google Books OAuth2";
RELATE i18n_key:credential_type_google_books_oauth2_api_name->translation->language:es SET text = "Google Books OAuth2";

RELATE i18n_key:credential_type_google_books_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Books API. Permet de rechercher des livres, d'accéder aux bibliothèques personnelles et de gérer des étagères.";
RELATE i18n_key:credential_type_google_books_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Books API. Allows searching books, accessing personal libraries, and managing bookshelves.";
RELATE i18n_key:credential_type_google_books_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Books API. Consente di cercare libri, accedere a biblioteche personali e gestire scaffali.";
RELATE i18n_key:credential_type_google_books_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Books API. Ermöglicht das Suchen von Büchern, den Zugriff auf persönliche Bibliotheken und die Verwaltung von Bücherregalen.";
RELATE i18n_key:credential_type_google_books_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Books API. Permite buscar libros, acceder a bibliotecas personales y gestionar estanterías.";

RELATE i18n_key:credential_type_google_books_oauth2_api_tooltip->translation->language:fr SET text = "Pour recherche de livres et bibliothèques personnelles";
RELATE i18n_key:credential_type_google_books_oauth2_api_tooltip->translation->language:en SET text = "For book search and personal libraries";
RELATE i18n_key:credential_type_google_books_oauth2_api_tooltip->translation->language:it SET text = "Per ricerca libri e biblioteche personali";
RELATE i18n_key:credential_type_google_books_oauth2_api_tooltip->translation->language:de SET text = "Für Buchsuche und persönliche Bibliotheken";
RELATE i18n_key:credential_type_google_books_oauth2_api_tooltip->translation->language:es SET text = "Para búsqueda de libros y bibliotecas personales";

-- =====================================================
-- GOOGLE BUSINESS PROFILE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_business_profile_oauth2_api_name->translation->language:fr SET text = "Google Business Profile OAuth2";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_name->translation->language:en SET text = "Google Business Profile OAuth2";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_name->translation->language:it SET text = "Google Business Profile OAuth2";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_name->translation->language:de SET text = "Google Business Profile OAuth2";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_name->translation->language:es SET text = "Google Business Profile OAuth2";

RELATE i18n_key:credential_type_google_business_profile_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Business Profile (ex-Google My Business). Permet de gérer des fiches d'entreprise, répondre aux avis et analyser les performances locales.";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Business Profile (formerly Google My Business). Allows managing business listings, responding to reviews, and analyzing local performance.";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Business Profile (ex-Google My Business). Consente di gestire schede aziendali, rispondere alle recensioni e analizzare le prestazioni locali.";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Business Profile (ehemals Google My Business). Ermöglicht die Verwaltung von Unternehmenseinträgen, das Beantworten von Bewertungen und die Analyse der lokalen Leistung.";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Business Profile (antes Google My Business). Permite gestionar fichas de empresa, responder a reseñas y analizar rendimiento local.";

RELATE i18n_key:credential_type_google_business_profile_oauth2_api_tooltip->translation->language:fr SET text = "Pour gestion de fiches entreprise et SEO local";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_tooltip->translation->language:en SET text = "For business listing management and local SEO";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_tooltip->translation->language:it SET text = "Per gestione schede aziendali e SEO locale";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_tooltip->translation->language:de SET text = "Für Unternehmenseinträge und lokales SEO";
RELATE i18n_key:credential_type_google_business_profile_oauth2_api_tooltip->translation->language:es SET text = "Para gestión de fichas empresa y SEO local";

-- =====================================================
-- GOOGLE CALENDAR OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_calendar_oauth2_api_name->translation->language:fr SET text = "Google Calendar OAuth2";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_name->translation->language:en SET text = "Google Calendar OAuth2";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_name->translation->language:it SET text = "Google Calendar OAuth2";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_name->translation->language:de SET text = "Google Calendar OAuth2";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_name->translation->language:es SET text = "Google Calendar OAuth2";

RELATE i18n_key:credential_type_google_calendar_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Calendar API. Permet de créer, lire, mettre à jour et supprimer des événements calendrier, ainsi que gérer des disponibilités.";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Calendar API. Allows creating, reading, updating, and deleting calendar events, as well as managing availability.";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Calendar API. Consente di creare, leggere, aggiornare ed eliminare eventi del calendario, nonché gestire la disponibilità.";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Calendar API. Ermöglicht das Erstellen, Lesen, Aktualisieren und Löschen von Kalender-Ereignissen sowie die Verwaltung der Verfügbarkeit.";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Calendar API. Permite crear, leer, actualizar y eliminar eventos de calendario, así como gestionar disponibilidad.";

RELATE i18n_key:credential_type_google_calendar_oauth2_api_tooltip->translation->language:fr SET text = "Pour gestion d'événements et synchronisation calendrier";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_tooltip->translation->language:en SET text = "For event management and calendar synchronization";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_tooltip->translation->language:it SET text = "Per gestione eventi e sincronizzazione calendario";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_tooltip->translation->language:de SET text = "Für Ereignisverwaltung und Kalender-Synchronisation";
RELATE i18n_key:credential_type_google_calendar_oauth2_api_tooltip->translation->language:es SET text = "Para gestión de eventos y sincronización calendario";

-- =====================================================
-- GOOGLE CHAT OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_chat_oauth2_api_name->translation->language:fr SET text = "Google Chat OAuth2";
RELATE i18n_key:credential_type_google_chat_oauth2_api_name->translation->language:en SET text = "Google Chat OAuth2";
RELATE i18n_key:credential_type_google_chat_oauth2_api_name->translation->language:it SET text = "Google Chat OAuth2";
RELATE i18n_key:credential_type_google_chat_oauth2_api_name->translation->language:de SET text = "Google Chat OAuth2";
RELATE i18n_key:credential_type_google_chat_oauth2_api_name->translation->language:es SET text = "Google Chat OAuth2";

RELATE i18n_key:credential_type_google_chat_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Chat API. Permet d'envoyer des messages, créer des espaces et automatiser la communication d'équipe dans Google Workspace.";
RELATE i18n_key:credential_type_google_chat_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Chat API. Allows sending messages, creating spaces, and automating team communication in Google Workspace.";
RELATE i18n_key:credential_type_google_chat_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Chat API. Consente di inviare messaggi, creare spazi e automatizzare la comunicazione di squadra in Google Workspace.";
RELATE i18n_key:credential_type_google_chat_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Chat API. Ermöglicht das Senden von Nachrichten, Erstellen von Räumen und Automatisieren der Teamkommunikation in Google Workspace.";
RELATE i18n_key:credential_type_google_chat_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Chat API. Permite enviar mensajes, crear espacios y automatizar comunicación de equipo en Google Workspace.";

RELATE i18n_key:credential_type_google_chat_oauth2_api_tooltip->translation->language:fr SET text = "Pour messagerie d'équipe et collaboration Workspace";
RELATE i18n_key:credential_type_google_chat_oauth2_api_tooltip->translation->language:en SET text = "For team messaging and Workspace collaboration";
RELATE i18n_key:credential_type_google_chat_oauth2_api_tooltip->translation->language:it SET text = "Per messaggistica di squadra e collaborazione Workspace";
RELATE i18n_key:credential_type_google_chat_oauth2_api_tooltip->translation->language:de SET text = "Für Team-Messaging und Workspace-Zusammenarbeit";
RELATE i18n_key:credential_type_google_chat_oauth2_api_tooltip->translation->language:es SET text = "Para mensajería de equipo y colaboración Workspace";

-- =====================================================
-- GOOGLE CLOUD NATURAL LANGUAGE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name->translation->language:fr SET text = "Google Cloud Natural Language OAuth2";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name->translation->language:en SET text = "Google Cloud Natural Language OAuth2";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name->translation->language:it SET text = "Google Cloud Natural Language OAuth2";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name->translation->language:de SET text = "Google Cloud Natural Language OAuth2";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name->translation->language:es SET text = "Google Cloud Natural Language OAuth2";

RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Cloud Natural Language API. Permet d'analyser des sentiments, extraire des entités et comprendre du texte avec l'IA Google.";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Cloud Natural Language API. Allows analyzing sentiment, extracting entities, and understanding text with Google AI.";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Cloud Natural Language API. Consente di analizzare sentimenti, estrarre entità e comprendere testo con l'IA Google.";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Cloud Natural Language API. Ermöglicht Sentimentanalyse, Entitätsextraktion und Textverständnis mit Google AI.";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Cloud Natural Language API. Permite analizar sentimientos, extraer entidades y comprender texto con IA Google.";

RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip->translation->language:fr SET text = "Pour analyse de texte et NLP avec IA Google";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip->translation->language:en SET text = "For text analysis and NLP with Google AI";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip->translation->language:it SET text = "Per analisi testo e NLP con IA Google";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip->translation->language:de SET text = "Für Textanalyse und NLP mit Google AI";
RELATE i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip->translation->language:es SET text = "Para análisis de texto y NLP con IA Google";

-- =====================================================
-- GOOGLE CLOUD STORAGE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_name->translation->language:fr SET text = "Google Cloud Storage OAuth2";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_name->translation->language:en SET text = "Google Cloud Storage OAuth2";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_name->translation->language:it SET text = "Google Cloud Storage OAuth2";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_name->translation->language:de SET text = "Google Cloud Storage OAuth2";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_name->translation->language:es SET text = "Google Cloud Storage OAuth2";

RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Cloud Storage. Permet de stocker, télécharger et gérer des fichiers dans des buckets GCS à grande échelle.";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Cloud Storage. Allows storing, downloading, and managing files in GCS buckets at scale.";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Cloud Storage. Consente di archiviare, scaricare e gestire file in bucket GCS su larga scala.";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Cloud Storage. Ermöglicht das Speichern, Herunterladen und Verwalten von Dateien in GCS-Buckets im großen Maßstab.";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Cloud Storage. Permite almacenar, descargar y gestionar archivos en buckets GCS a gran escala.";

RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip->translation->language:fr SET text = "Pour stockage cloud et gestion de fichiers massifs";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip->translation->language:en SET text = "For cloud storage and massive file management";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip->translation->language:it SET text = "Per cloud storage e gestione file massivi";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip->translation->language:de SET text = "Für Cloud-Speicher und massive Dateiverwaltung";
RELATE i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip->translation->language:es SET text = "Para almacenamiento cloud y gestión de archivos masivos";

-- =====================================================
-- GOOGLE CONTACTS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_contacts_oauth2_api_name->translation->language:fr SET text = "Google Contacts OAuth2";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_name->translation->language:en SET text = "Google Contacts OAuth2";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_name->translation->language:it SET text = "Google Contacts OAuth2";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_name->translation->language:de SET text = "Google Contacts OAuth2";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_name->translation->language:es SET text = "Google Contacts OAuth2";

RELATE i18n_key:credential_type_google_contacts_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Contacts API (People API). Permet de gérer des contacts, synchroniser des annuaires et automatiser la gestion CRM.";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Contacts API (People API). Allows managing contacts, synchronizing directories, and automating CRM management.";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Contacts API (People API). Consente di gestire contatti, sincronizzare directory e automatizzare la gestione CRM.";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Contacts API (People API). Ermöglicht die Verwaltung von Kontakten, Synchronisation von Verzeichnissen und Automatisierung der CRM-Verwaltung.";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Contacts API (People API). Permite gestionar contactos, sincronizar directorios y automatizar gestión CRM.";

RELATE i18n_key:credential_type_google_contacts_oauth2_api_tooltip->translation->language:fr SET text = "Pour gestion contacts et synchronisation CRM";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_tooltip->translation->language:en SET text = "For contact management and CRM synchronization";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_tooltip->translation->language:it SET text = "Per gestione contatti e sincronizzazione CRM";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_tooltip->translation->language:de SET text = "Für Kontaktverwaltung und CRM-Synchronisation";
RELATE i18n_key:credential_type_google_contacts_oauth2_api_tooltip->translation->language:es SET text = "Para gestión contactos y sincronización CRM";

-- =====================================================
-- GOOGLE DOCS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_docs_oauth2_api_name->translation->language:fr SET text = "Google Docs OAuth2";
RELATE i18n_key:credential_type_google_docs_oauth2_api_name->translation->language:en SET text = "Google Docs OAuth2";
RELATE i18n_key:credential_type_google_docs_oauth2_api_name->translation->language:it SET text = "Google Docs OAuth2";
RELATE i18n_key:credential_type_google_docs_oauth2_api_name->translation->language:de SET text = "Google Docs OAuth2";
RELATE i18n_key:credential_type_google_docs_oauth2_api_name->translation->language:es SET text = "Google Docs OAuth2";

RELATE i18n_key:credential_type_google_docs_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Docs API. Permet de créer, lire et modifier des documents texte collaboratifs dans Google Workspace.";
RELATE i18n_key:credential_type_google_docs_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Docs API. Allows creating, reading, and editing collaborative text documents in Google Workspace.";
RELATE i18n_key:credential_type_google_docs_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Docs API. Consente di creare, leggere e modificare documenti di testo collaborativi in Google Workspace.";
RELATE i18n_key:credential_type_google_docs_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Docs API. Ermöglicht das Erstellen, Lesen und Bearbeiten kollaborativer Textdokumente in Google Workspace.";
RELATE i18n_key:credential_type_google_docs_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Docs API. Permite crear, leer y editar documentos de texto colaborativos en Google Workspace.";

RELATE i18n_key:credential_type_google_docs_oauth2_api_tooltip->translation->language:fr SET text = "Pour édition documents et génération de rapports";
RELATE i18n_key:credential_type_google_docs_oauth2_api_tooltip->translation->language:en SET text = "For document editing and report generation";
RELATE i18n_key:credential_type_google_docs_oauth2_api_tooltip->translation->language:it SET text = "Per modifica documenti e generazione report";
RELATE i18n_key:credential_type_google_docs_oauth2_api_tooltip->translation->language:de SET text = "Für Dokumentenbearbeitung und Berichterstellung";
RELATE i18n_key:credential_type_google_docs_oauth2_api_tooltip->translation->language:es SET text = "Para edición documentos y generación informes";

-- =====================================================
-- GOOGLE DRIVE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_drive_oauth2_api_name->translation->language:fr SET text = "Google Drive OAuth2";
RELATE i18n_key:credential_type_google_drive_oauth2_api_name->translation->language:en SET text = "Google Drive OAuth2";
RELATE i18n_key:credential_type_google_drive_oauth2_api_name->translation->language:it SET text = "Google Drive OAuth2";
RELATE i18n_key:credential_type_google_drive_oauth2_api_name->translation->language:de SET text = "Google Drive OAuth2";
RELATE i18n_key:credential_type_google_drive_oauth2_api_name->translation->language:es SET text = "Google Drive OAuth2";

RELATE i18n_key:credential_type_google_drive_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Drive API. Permet de gérer des fichiers, dossiers et permissions dans Google Drive.";
RELATE i18n_key:credential_type_google_drive_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Drive API. Allows managing files, folders, and permissions in Google Drive.";
RELATE i18n_key:credential_type_google_drive_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Drive API. Consente di gestire file, cartelle e permessi in Google Drive.";
RELATE i18n_key:credential_type_google_drive_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Drive API. Ermöglicht die Verwaltung von Dateien, Ordnern und Berechtigungen in Google Drive.";
RELATE i18n_key:credential_type_google_drive_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Drive API. Permite gestionar archivos, carpetas y permisos en Google Drive.";

RELATE i18n_key:credential_type_google_drive_oauth2_api_tooltip->translation->language:fr SET text = "Pour stockage fichiers et collaboration cloud";
RELATE i18n_key:credential_type_google_drive_oauth2_api_tooltip->translation->language:en SET text = "For file storage and cloud collaboration";
RELATE i18n_key:credential_type_google_drive_oauth2_api_tooltip->translation->language:it SET text = "Per archiviazione file e collaborazione cloud";
RELATE i18n_key:credential_type_google_drive_oauth2_api_tooltip->translation->language:de SET text = "Für Dateispeicherung und Cloud-Zusammenarbeit";
RELATE i18n_key:credential_type_google_drive_oauth2_api_tooltip->translation->language:es SET text = "Para almacenamiento archivos y colaboración cloud";

-- =====================================================
-- GOOGLE FIREBASE CLOUD FIRESTORE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name->translation->language:fr SET text = "Firebase Cloud Firestore OAuth2";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name->translation->language:en SET text = "Firebase Cloud Firestore OAuth2";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name->translation->language:it SET text = "Firebase Cloud Firestore OAuth2";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name->translation->language:de SET text = "Firebase Cloud Firestore OAuth2";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name->translation->language:es SET text = "Firebase Cloud Firestore OAuth2";

RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Firebase Cloud Firestore. Base de données NoSQL en temps réel pour applications mobiles et web avec synchronisation offline.";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Firebase Cloud Firestore. Real-time NoSQL database for mobile and web apps with offline sync.";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Firebase Cloud Firestore. Database NoSQL in tempo reale per app mobili e web con sincronizzazione offline.";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Firebase Cloud Firestore. Echtzeit-NoSQL-Datenbank für mobile und Web-Apps mit Offline-Synchronisation.";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Firebase Cloud Firestore. Base de datos NoSQL en tiempo real para apps móviles y web con sincronización offline.";

RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip->translation->language:fr SET text = "Pour BDD NoSQL temps réel et sync mobile";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip->translation->language:en SET text = "For real-time NoSQL DB and mobile sync";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip->translation->language:it SET text = "Per DB NoSQL in tempo reale e sync mobile";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip->translation->language:de SET text = "Für Echtzeit-NoSQL-DB und mobile Synchronisation";
RELATE i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip->translation->language:es SET text = "Para BD NoSQL tiempo real y sync móvil";

-- =====================================================
-- GOOGLE FIREBASE REALTIME DATABASE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name->translation->language:fr SET text = "Firebase Realtime Database OAuth2";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name->translation->language:en SET text = "Firebase Realtime Database OAuth2";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name->translation->language:it SET text = "Firebase Realtime Database OAuth2";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name->translation->language:de SET text = "Firebase Realtime Database OAuth2";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name->translation->language:es SET text = "Firebase Realtime Database OAuth2";

RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Firebase Realtime Database. Base de données JSON en temps réel avec synchronisation instantanée sur tous les clients.";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Firebase Realtime Database. Real-time JSON database with instant synchronization across all clients.";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Firebase Realtime Database. Database JSON in tempo reale con sincronizzazione istantanea su tutti i client.";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Firebase Realtime Database. Echtzeit-JSON-Datenbank mit sofortiger Synchronisation auf allen Clients.";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Firebase Realtime Database. Base de datos JSON en tiempo real con sincronización instantánea en todos los clientes.";

RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip->translation->language:fr SET text = "Pour sync temps réel multi-client et apps chat";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip->translation->language:en SET text = "For real-time multi-client sync and chat apps";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip->translation->language:it SET text = "Per sync multi-client in tempo reale e app chat";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip->translation->language:de SET text = "Für Echtzeit-Multi-Client-Sync und Chat-Apps";
RELATE i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip->translation->language:es SET text = "Para sync tiempo real multi-cliente y apps chat";

-- =====================================================
-- GOOGLE OAUTH2 API (GÉNÉRIQUE)
-- =====================================================

RELATE i18n_key:credential_type_google_oauth2_api_name->translation->language:fr SET text = "Google OAuth2 (Générique)";
RELATE i18n_key:credential_type_google_oauth2_api_name->translation->language:en SET text = "Google OAuth2 (Generic)";
RELATE i18n_key:credential_type_google_oauth2_api_name->translation->language:it SET text = "Google OAuth2 (Generico)";
RELATE i18n_key:credential_type_google_oauth2_api_name->translation->language:de SET text = "Google OAuth2 (Generisch)";
RELATE i18n_key:credential_type_google_oauth2_api_name->translation->language:es SET text = "Google OAuth2 (Genérico)";

RELATE i18n_key:credential_type_google_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 générique pour toutes APIs Google. Utilisé pour services Google sans credential spécifique. Configurez manuellement les scopes nécessaires.";
RELATE i18n_key:credential_type_google_oauth2_api_description->translation->language:en SET text = "Generic OAuth2 authentication for all Google APIs. Used for Google services without specific credentials. Manually configure required scopes.";
RELATE i18n_key:credential_type_google_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 generica per tutte le API Google. Utilizzato per servizi Google senza credenziali specifiche. Configurare manualmente gli scope necessari.";
RELATE i18n_key:credential_type_google_oauth2_api_description->translation->language:de SET text = "Generische OAuth2-Authentifizierung für alle Google APIs. Verwendet für Google-Dienste ohne spezifische Anmeldeinformationen. Erforderliche Scopes manuell konfigurieren.";
RELATE i18n_key:credential_type_google_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 genérica para todas las APIs Google. Usado para servicios Google sin credenciales específicas. Configurar manualmente los scopes necesarios.";

RELATE i18n_key:credential_type_google_oauth2_api_tooltip->translation->language:fr SET text = "Pour toute API Google sans credential spécifique";
RELATE i18n_key:credential_type_google_oauth2_api_tooltip->translation->language:en SET text = "For any Google API without specific credential";
RELATE i18n_key:credential_type_google_oauth2_api_tooltip->translation->language:it SET text = "Per qualsiasi API Google senza credenziale specifica";
RELATE i18n_key:credential_type_google_oauth2_api_tooltip->translation->language:de SET text = "Für jede Google API ohne spezifische Anmeldeinformationen";
RELATE i18n_key:credential_type_google_oauth2_api_tooltip->translation->language:es SET text = "Para cualquier API Google sin credencial específica";

-- =====================================================
-- GOOGLE PERSPECTIVE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_perspective_oauth2_api_name->translation->language:fr SET text = "Google Perspective OAuth2";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_name->translation->language:en SET text = "Google Perspective OAuth2";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_name->translation->language:it SET text = "Google Perspective OAuth2";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_name->translation->language:de SET text = "Google Perspective OAuth2";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_name->translation->language:es SET text = "Google Perspective OAuth2";

RELATE i18n_key:credential_type_google_perspective_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Perspective API. Permet de détecter contenus toxiques, d'analyser la toxicité des commentaires avec IA.";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Perspective API. Allows detecting toxic content and analyzing comment toxicity with AI.";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Perspective API. Consente di rilevare contenuti tossici e analizzare la tossicità dei commenti con IA.";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Perspective API. Ermöglicht die Erkennung toxischer Inhalte und die Analyse der Toxizität von Kommentaren mit KI.";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Perspective API. Permite detectar contenido tóxico y analizar toxicidad de comentarios con IA.";

RELATE i18n_key:credential_type_google_perspective_oauth2_api_tooltip->translation->language:fr SET text = "Pour modération contenu et détection toxicité";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_tooltip->translation->language:en SET text = "For content moderation and toxicity detection";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_tooltip->translation->language:it SET text = "Per moderazione contenuti e rilevamento tossicità";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_tooltip->translation->language:de SET text = "Für Inhaltsmoderation und Toxizitätserkennung";
RELATE i18n_key:credential_type_google_perspective_oauth2_api_tooltip->translation->language:es SET text = "Para moderación contenido y detección toxicidad";

-- =====================================================
-- GOOGLE SHEETS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_sheets_oauth2_api_name->translation->language:fr SET text = "Google Sheets OAuth2";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_name->translation->language:en SET text = "Google Sheets OAuth2";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_name->translation->language:it SET text = "Google Sheets OAuth2";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_name->translation->language:de SET text = "Google Sheets OAuth2";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_name->translation->language:es SET text = "Google Sheets OAuth2";

RELATE i18n_key:credential_type_google_sheets_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Sheets API. Permet de créer, lire et modifier des feuilles de calcul, automatiser des workflows de données.";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Sheets API. Allows creating, reading, and editing spreadsheets, automating data workflows.";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Sheets API. Consente di creare, leggere e modificare fogli di calcolo, automatizzare flussi di lavoro dati.";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Sheets API. Ermöglicht das Erstellen, Lesen und Bearbeiten von Tabellenkalkulationen, Automatisierung von Datenworkflows.";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Sheets API. Permite crear, leer y editar hojas de cálculo, automatizar flujos de trabajo de datos.";

RELATE i18n_key:credential_type_google_sheets_oauth2_api_tooltip->translation->language:fr SET text = "Pour automatisation feuilles de calcul et ETL";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_tooltip->translation->language:en SET text = "For spreadsheet automation and ETL";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_tooltip->translation->language:it SET text = "Per automazione fogli calcolo e ETL";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_tooltip->translation->language:de SET text = "Für Tabellenkalkulations-Automatisierung und ETL";
RELATE i18n_key:credential_type_google_sheets_oauth2_api_tooltip->translation->language:es SET text = "Para automatización hojas cálculo y ETL";

-- =====================================================
-- GOOGLE SHEETS TRIGGER OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_name->translation->language:fr SET text = "Google Sheets Trigger OAuth2";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_name->translation->language:en SET text = "Google Sheets Trigger OAuth2";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_name->translation->language:it SET text = "Google Sheets Trigger OAuth2";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_name->translation->language:de SET text = "Google Sheets Trigger OAuth2";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_name->translation->language:es SET text = "Google Sheets Trigger OAuth2";

RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 spécifique pour déclencheurs Google Sheets. Permet de réagir automatiquement aux changements dans des feuilles de calcul (webhooks).";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_description->translation->language:en SET text = "Specific OAuth2 authentication for Google Sheets triggers. Allows automatically reacting to changes in spreadsheets (webhooks).";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 specifica per trigger Google Sheets. Consente di reagire automaticamente ai cambiamenti nei fogli di calcolo (webhook).";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_description->translation->language:de SET text = "Spezifische OAuth2-Authentifizierung für Google Sheets-Trigger. Ermöglicht automatische Reaktion auf Änderungen in Tabellenkalkulationen (Webhooks).";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 específica para triggers Google Sheets. Permite reaccionar automáticamente a cambios en hojas de cálculo (webhooks).";

RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip->translation->language:fr SET text = "Pour événements temps réel et webhooks Sheets";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip->translation->language:en SET text = "For real-time events and Sheets webhooks";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip->translation->language:it SET text = "Per eventi in tempo reale e webhook Sheets";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip->translation->language:de SET text = "Für Echtzeit-Events und Sheets-Webhooks";
RELATE i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip->translation->language:es SET text = "Para eventos tiempo real y webhooks Sheets";

-- =====================================================
-- GOOGLE SLIDES OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_slides_oauth2_api_name->translation->language:fr SET text = "Google Slides OAuth2";
RELATE i18n_key:credential_type_google_slides_oauth2_api_name->translation->language:en SET text = "Google Slides OAuth2";
RELATE i18n_key:credential_type_google_slides_oauth2_api_name->translation->language:it SET text = "Google Slides OAuth2";
RELATE i18n_key:credential_type_google_slides_oauth2_api_name->translation->language:de SET text = "Google Slides OAuth2";
RELATE i18n_key:credential_type_google_slides_oauth2_api_name->translation->language:es SET text = "Google Slides OAuth2";

RELATE i18n_key:credential_type_google_slides_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Slides API. Permet de créer, lire et modifier des présentations, automatiser la génération de slides.";
RELATE i18n_key:credential_type_google_slides_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Slides API. Allows creating, reading, and editing presentations, automating slide generation.";
RELATE i18n_key:credential_type_google_slides_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Slides API. Consente di creare, leggere e modificare presentazioni, automatizzare la generazione di slide.";
RELATE i18n_key:credential_type_google_slides_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Slides API. Ermöglicht das Erstellen, Lesen und Bearbeiten von Präsentationen, Automatisierung der Folien-Generierung.";
RELATE i18n_key:credential_type_google_slides_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Slides API. Permite crear, leer y editar presentaciones, automatizar generación de slides.";

RELATE i18n_key:credential_type_google_slides_oauth2_api_tooltip->translation->language:fr SET text = "Pour génération présentations et rapports visuels";
RELATE i18n_key:credential_type_google_slides_oauth2_api_tooltip->translation->language:en SET text = "For presentation generation and visual reports";
RELATE i18n_key:credential_type_google_slides_oauth2_api_tooltip->translation->language:it SET text = "Per generazione presentazioni e report visivi";
RELATE i18n_key:credential_type_google_slides_oauth2_api_tooltip->translation->language:de SET text = "Für Präsentationserstellung und visuelle Berichte";
RELATE i18n_key:credential_type_google_slides_oauth2_api_tooltip->translation->language:es SET text = "Para generación presentaciones e informes visuales";

-- =====================================================
-- GOOGLE TASKS OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_tasks_oauth2_api_name->translation->language:fr SET text = "Google Tasks OAuth2";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_name->translation->language:en SET text = "Google Tasks OAuth2";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_name->translation->language:it SET text = "Google Tasks OAuth2";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_name->translation->language:de SET text = "Google Tasks OAuth2";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_name->translation->language:es SET text = "Google Tasks OAuth2";

RELATE i18n_key:credential_type_google_tasks_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Tasks API. Permet de créer, lire et gérer des tâches et listes de tâches intégrées à Google Workspace.";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Tasks API. Allows creating, reading, and managing tasks and task lists integrated with Google Workspace.";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Tasks API. Consente di creare, leggere e gestire attività ed elenchi di attività integrati con Google Workspace.";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Tasks API. Ermöglicht das Erstellen, Lesen und Verwalten von Aufgaben und Aufgabenlisten integriert mit Google Workspace.";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Tasks API. Permite crear, leer y gestionar tareas y listas de tareas integradas con Google Workspace.";

RELATE i18n_key:credential_type_google_tasks_oauth2_api_tooltip->translation->language:fr SET text = "Pour gestion tâches et synchronisation TODO";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_tooltip->translation->language:en SET text = "For task management and TODO synchronization";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_tooltip->translation->language:it SET text = "Per gestione attività e sincronizzazione TODO";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_tooltip->translation->language:de SET text = "Für Aufgabenverwaltung und TODO-Synchronisation";
RELATE i18n_key:credential_type_google_tasks_oauth2_api_tooltip->translation->language:es SET text = "Para gestión tareas y sincronización TODO";

-- =====================================================
-- GOOGLE TRANSLATE OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_google_translate_oauth2_api_name->translation->language:fr SET text = "Google Translate OAuth2";
RELATE i18n_key:credential_type_google_translate_oauth2_api_name->translation->language:en SET text = "Google Translate OAuth2";
RELATE i18n_key:credential_type_google_translate_oauth2_api_name->translation->language:it SET text = "Google Translate OAuth2";
RELATE i18n_key:credential_type_google_translate_oauth2_api_name->translation->language:de SET text = "Google Translate OAuth2";
RELATE i18n_key:credential_type_google_translate_oauth2_api_name->translation->language:es SET text = "Google Translate OAuth2";

RELATE i18n_key:credential_type_google_translate_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Google Translate API. Permet de traduire du texte automatiquement dans 100+ langues avec l'IA Google.";
RELATE i18n_key:credential_type_google_translate_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Google Translate API. Allows automatically translating text into 100+ languages with Google AI.";
RELATE i18n_key:credential_type_google_translate_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Google Translate API. Consente di tradurre automaticamente testo in 100+ lingue con IA Google.";
RELATE i18n_key:credential_type_google_translate_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Google Translate API. Ermöglicht die automatische Übersetzung von Text in 100+ Sprachen mit Google AI.";
RELATE i18n_key:credential_type_google_translate_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Google Translate API. Permite traducir texto automáticamente en 100+ idiomas con IA Google.";

RELATE i18n_key:credential_type_google_translate_oauth2_api_tooltip->translation->language:fr SET text = "Pour traduction automatique et localisation contenu";
RELATE i18n_key:credential_type_google_translate_oauth2_api_tooltip->translation->language:en SET text = "For automatic translation and content localization";
RELATE i18n_key:credential_type_google_translate_oauth2_api_tooltip->translation->language:it SET text = "Per traduzione automatica e localizzazione contenuti";
RELATE i18n_key:credential_type_google_translate_oauth2_api_tooltip->translation->language:de SET text = "Für automatische Übersetzung und Content-Lokalisierung";
RELATE i18n_key:credential_type_google_translate_oauth2_api_tooltip->translation->language:es SET text = "Para traducción automática y localización contenido";

-- =============================================================================================

