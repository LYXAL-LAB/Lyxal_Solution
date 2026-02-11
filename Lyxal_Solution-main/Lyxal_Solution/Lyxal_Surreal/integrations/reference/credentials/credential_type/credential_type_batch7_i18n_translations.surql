-- =============================================================================================
-- |
-- | Fichier : credential_type_batch7_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 7 des credential types.
-- |
-- | Batch 7 : Databases & Messaging (12 credentials)
-- | Providers : MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch, Kafka, RabbitMQ, etc.
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 180 traductions (36 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- MYSQL
-- =====================================================

-- =====================================================
-- POSTGRES
-- =====================================================

RELATE i18n_key:credential_type_postgres_name->translation->language:fr SET text = "PostgreSQL";
RELATE i18n_key:credential_type_postgres_name->translation->language:en SET text = "PostgreSQL";
RELATE i18n_key:credential_type_postgres_name->translation->language:it SET text = "PostgreSQL";
RELATE i18n_key:credential_type_postgres_name->translation->language:de SET text = "PostgreSQL";
RELATE i18n_key:credential_type_postgres_name->translation->language:es SET text = "PostgreSQL";

RELATE i18n_key:credential_type_postgres_description->translation->language:fr SET text = "Authentification pour PostgreSQL. Base de données relationnelle avancée open-source avec support JSON, transactions ACID et extensibilité.";
RELATE i18n_key:credential_type_postgres_description->translation->language:en SET text = "Authentication for PostgreSQL. Advanced open-source relational database with JSON support, ACID transactions, and extensibility.";
RELATE i18n_key:credential_type_postgres_description->translation->language:it SET text = "Autenticazione per PostgreSQL. Database relazionale open-source avanzato con supporto JSON, transazioni ACID ed estensibilità.";
RELATE i18n_key:credential_type_postgres_description->translation->language:de SET text = "Authentifizierung für PostgreSQL. Fortgeschrittene Open-Source-Relationale-Datenbank mit JSON-Unterstützung, ACID-Transaktionen und Erweiterbarkeit.";
RELATE i18n_key:credential_type_postgres_description->translation->language:es SET text = "Autenticación para PostgreSQL. Base datos relacional avanzada open-source con soporte JSON, transacciones ACID y extensibilidad.";

RELATE i18n_key:credential_type_postgres_tooltip->translation->language:fr SET text = "Pour connexion PostgreSQL et requêtes avancées";
RELATE i18n_key:credential_type_postgres_tooltip->translation->language:en SET text = "For PostgreSQL connection and advanced queries";
RELATE i18n_key:credential_type_postgres_tooltip->translation->language:it SET text = "Per connessione PostgreSQL e query avanzate";
RELATE i18n_key:credential_type_postgres_tooltip->translation->language:de SET text = "Für PostgreSQL-Verbindung und erweiterte Abfragen";
RELATE i18n_key:credential_type_postgres_tooltip->translation->language:es SET text = "Para conexión PostgreSQL y consultas avanzadas";

-- =====================================================
-- MONGODB
-- =====================================================

-- =====================================================
-- REDIS
-- =====================================================

RELATE i18n_key:credential_type_redis_name->translation->language:fr SET text = "Redis";
RELATE i18n_key:credential_type_redis_name->translation->language:en SET text = "Redis";
RELATE i18n_key:credential_type_redis_name->translation->language:it SET text = "Redis";
RELATE i18n_key:credential_type_redis_name->translation->language:de SET text = "Redis";
RELATE i18n_key:credential_type_redis_name->translation->language:es SET text = "Redis";

RELATE i18n_key:credential_type_redis_description->translation->language:fr SET text = "Authentification pour Redis. Store clé-valeur en mémoire ultra-rapide pour cache, sessions, files messages et données temps-réel.";
RELATE i18n_key:credential_type_redis_description->translation->language:en SET text = "Authentication for Redis. Ultra-fast in-memory key-value store for cache, sessions, message queues, and real-time data.";
RELATE i18n_key:credential_type_redis_description->translation->language:it SET text = "Autenticazione per Redis. Store chiave-valore in memoria ultra-veloce per cache, sessioni, code messaggi e dati real-time.";
RELATE i18n_key:credential_type_redis_description->translation->language:de SET text = "Authentifizierung für Redis. Ultra-schneller In-Memory-Key-Value-Store für Cache, Sessions, Nachrichtenwarteschlangen und Echtzeitdaten.";
RELATE i18n_key:credential_type_redis_description->translation->language:es SET text = "Autenticación para Redis. Store clave-valor en memoria ultra-rápido para cache, sesiones, colas mensajes y datos tiempo-real.";

RELATE i18n_key:credential_type_redis_tooltip->translation->language:fr SET text = "Pour cache Redis et données temps-réel";
RELATE i18n_key:credential_type_redis_tooltip->translation->language:en SET text = "For Redis cache and real-time data";
RELATE i18n_key:credential_type_redis_tooltip->translation->language:it SET text = "Per cache Redis e dati real-time";
RELATE i18n_key:credential_type_redis_tooltip->translation->language:de SET text = "Für Redis-Cache und Echtzeitdaten";
RELATE i18n_key:credential_type_redis_tooltip->translation->language:es SET text = "Para cache Redis y datos tiempo-real";

-- =====================================================
-- ELASTICSEARCH API
-- =====================================================

RELATE i18n_key:credential_type_elasticsearch_api_name->translation->language:fr SET text = "Elasticsearch";
RELATE i18n_key:credential_type_elasticsearch_api_name->translation->language:en SET text = "Elasticsearch";
RELATE i18n_key:credential_type_elasticsearch_api_name->translation->language:it SET text = "Elasticsearch";
RELATE i18n_key:credential_type_elasticsearch_api_name->translation->language:de SET text = "Elasticsearch";
RELATE i18n_key:credential_type_elasticsearch_api_name->translation->language:es SET text = "Elasticsearch";

RELATE i18n_key:credential_type_elasticsearch_api_description->translation->language:fr SET text = "Authentification pour Elasticsearch. Moteur recherche et analyse distribué pour recherche full-text, logs et analytics temps-réel.";
RELATE i18n_key:credential_type_elasticsearch_api_description->translation->language:en SET text = "Authentication for Elasticsearch. Distributed search and analytics engine for full-text search, logs, and real-time analytics.";
RELATE i18n_key:credential_type_elasticsearch_api_description->translation->language:it SET text = "Autenticazione per Elasticsearch. Motore ricerca e analisi distribuito per ricerca full-text, log e analytics real-time.";
RELATE i18n_key:credential_type_elasticsearch_api_description->translation->language:de SET text = "Authentifizierung für Elasticsearch. Verteilte Such- und Analyse-Engine für Volltextsuche, Logs und Echtzeit-Analysen.";
RELATE i18n_key:credential_type_elasticsearch_api_description->translation->language:es SET text = "Autenticación para Elasticsearch. Motor búsqueda y análisis distribuido para búsqueda full-text, logs y analytics tiempo-real.";

RELATE i18n_key:credential_type_elasticsearch_api_tooltip->translation->language:fr SET text = "Pour recherche Elasticsearch et analytics logs";
RELATE i18n_key:credential_type_elasticsearch_api_tooltip->translation->language:en SET text = "For Elasticsearch search and log analytics";
RELATE i18n_key:credential_type_elasticsearch_api_tooltip->translation->language:it SET text = "Per ricerca Elasticsearch e analytics log";
RELATE i18n_key:credential_type_elasticsearch_api_tooltip->translation->language:de SET text = "Für Elasticsearch-Suche und Log-Analysen";
RELATE i18n_key:credential_type_elasticsearch_api_tooltip->translation->language:es SET text = "Para búsqueda Elasticsearch y analytics logs";

-- =====================================================
-- KAFKA
-- =====================================================

RELATE i18n_key:credential_type_kafka_name->translation->language:fr SET text = "Apache Kafka";
RELATE i18n_key:credential_type_kafka_name->translation->language:en SET text = "Apache Kafka";
RELATE i18n_key:credential_type_kafka_name->translation->language:it SET text = "Apache Kafka";
RELATE i18n_key:credential_type_kafka_name->translation->language:de SET text = "Apache Kafka";
RELATE i18n_key:credential_type_kafka_name->translation->language:es SET text = "Apache Kafka";

RELATE i18n_key:credential_type_kafka_description->translation->language:fr SET text = "Authentification pour Apache Kafka. Plateforme streaming distribuée pour pipelines données temps-réel et architecture event-driven.";
RELATE i18n_key:credential_type_kafka_description->translation->language:en SET text = "Authentication for Apache Kafka. Distributed streaming platform for real-time data pipelines and event-driven architecture.";
RELATE i18n_key:credential_type_kafka_description->translation->language:it SET text = "Autenticazione per Apache Kafka. Piattaforma streaming distribuita per pipeline dati real-time e architettura event-driven.";
RELATE i18n_key:credential_type_kafka_description->translation->language:de SET text = "Authentifizierung für Apache Kafka. Verteilte Streaming-Plattform für Echtzeit-Datenpipelines und ereignisgesteuerte Architektur.";
RELATE i18n_key:credential_type_kafka_description->translation->language:es SET text = "Autenticación para Apache Kafka. Plataforma streaming distribuida para pipelines datos tiempo-real y arquitectura event-driven.";

RELATE i18n_key:credential_type_kafka_tooltip->translation->language:fr SET text = "Pour streaming Kafka et pipelines événements";
RELATE i18n_key:credential_type_kafka_tooltip->translation->language:en SET text = "For Kafka streaming and event pipelines";
RELATE i18n_key:credential_type_kafka_tooltip->translation->language:it SET text = "Per streaming Kafka e pipeline eventi";
RELATE i18n_key:credential_type_kafka_tooltip->translation->language:de SET text = "Für Kafka-Streaming und Event-Pipelines";
RELATE i18n_key:credential_type_kafka_tooltip->translation->language:es SET text = "Para streaming Kafka y pipelines eventos";

-- =====================================================
-- RABBITMQ
-- =====================================================

-- =====================================================
-- MQTT
-- =====================================================

RELATE i18n_key:credential_type_mqtt_name->translation->language:fr SET text = "MQTT";
RELATE i18n_key:credential_type_mqtt_name->translation->language:en SET text = "MQTT";
RELATE i18n_key:credential_type_mqtt_name->translation->language:it SET text = "MQTT";
RELATE i18n_key:credential_type_mqtt_name->translation->language:de SET text = "MQTT";
RELATE i18n_key:credential_type_mqtt_name->translation->language:es SET text = "MQTT";

RELATE i18n_key:credential_type_mqtt_description->translation->language:fr SET text = "Authentification pour MQTT. Protocole messaging léger IoT pour communication machine-to-machine et appareils connectés.";
RELATE i18n_key:credential_type_mqtt_description->translation->language:en SET text = "Authentication for MQTT. Lightweight IoT messaging protocol for machine-to-machine communication and connected devices.";
RELATE i18n_key:credential_type_mqtt_description->translation->language:it SET text = "Autenticazione per MQTT. Protocollo messaging IoT leggero per comunicazione machine-to-machine e dispositivi connessi.";
RELATE i18n_key:credential_type_mqtt_description->translation->language:de SET text = "Authentifizierung für MQTT. Leichtgewichtiges IoT-Messaging-Protokoll für Machine-to-Machine-Kommunikation und vernetzte Geräte.";
RELATE i18n_key:credential_type_mqtt_description->translation->language:es SET text = "Autenticación para MQTT. Protocolo messaging ligero IoT para comunicación machine-to-machine y dispositivos conectados.";

RELATE i18n_key:credential_type_mqtt_tooltip->translation->language:fr SET text = "Pour IoT MQTT et communication M2M";
RELATE i18n_key:credential_type_mqtt_tooltip->translation->language:en SET text = "For MQTT IoT and M2M communication";
RELATE i18n_key:credential_type_mqtt_tooltip->translation->language:it SET text = "Per IoT MQTT e comunicazione M2M";
RELATE i18n_key:credential_type_mqtt_tooltip->translation->language:de SET text = "Für MQTT IoT und M2M-Kommunikation";
RELATE i18n_key:credential_type_mqtt_tooltip->translation->language:es SET text = "Para IoT MQTT y comunicación M2M";

-- =====================================================
-- AMQP
-- =====================================================

RELATE i18n_key:credential_type_amqp_name->translation->language:fr SET text = "AMQP";
RELATE i18n_key:credential_type_amqp_name->translation->language:en SET text = "AMQP";
RELATE i18n_key:credential_type_amqp_name->translation->language:it SET text = "AMQP";
RELATE i18n_key:credential_type_amqp_name->translation->language:de SET text = "AMQP";
RELATE i18n_key:credential_type_amqp_name->translation->language:es SET text = "AMQP";

RELATE i18n_key:credential_type_amqp_description->translation->language:fr SET text = "Authentification pour AMQP. Protocole messaging standard pour communication fiable orientée messages entre applications.";
RELATE i18n_key:credential_type_amqp_description->translation->language:en SET text = "Authentication for AMQP. Standard messaging protocol for reliable message-oriented communication between applications.";
RELATE i18n_key:credential_type_amqp_description->translation->language:it SET text = "Autenticazione per AMQP. Protocollo messaging standard per comunicazione affidabile orientata messaggi tra applicazioni.";
RELATE i18n_key:credential_type_amqp_description->translation->language:de SET text = "Authentifizierung für AMQP. Standard-Messaging-Protokoll für zuverlässige nachrichtenorientierte Kommunikation zwischen Anwendungen.";
RELATE i18n_key:credential_type_amqp_description->translation->language:es SET text = "Autenticación para AMQP. Protocolo messaging estándar para comunicación fiable orientada mensajes entre aplicaciones.";

RELATE i18n_key:credential_type_amqp_tooltip->translation->language:fr SET text = "Pour messaging AMQP et communication fiable";
RELATE i18n_key:credential_type_amqp_tooltip->translation->language:en SET text = "For AMQP messaging and reliable communication";
RELATE i18n_key:credential_type_amqp_tooltip->translation->language:it SET text = "Per messaging AMQP e comunicazione affidabile";
RELATE i18n_key:credential_type_amqp_tooltip->translation->language:de SET text = "Für AMQP-Messaging und zuverlässige Kommunikation";
RELATE i18n_key:credential_type_amqp_tooltip->translation->language:es SET text = "Para messaging AMQP y comunicación fiable";

-- =====================================================
-- CRATEDB
-- =====================================================

-- =====================================================
-- QUESTDB
-- =====================================================

-- =====================================================
-- TIMESCALEDB
-- =====================================================

-- =============================================================================================

