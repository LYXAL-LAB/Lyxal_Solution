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

RELATE i18n_key:credential_type_mysql_name->translation->language:fr SET text = "MySQL";
RELATE i18n_key:credential_type_mysql_name->translation->language:en SET text = "MySQL";
RELATE i18n_key:credential_type_mysql_name->translation->language:it SET text = "MySQL";
RELATE i18n_key:credential_type_mysql_name->translation->language:de SET text = "MySQL";
RELATE i18n_key:credential_type_mysql_name->translation->language:es SET text = "MySQL";

RELATE i18n_key:credential_type_mysql_description->translation->language:fr SET text = "Authentification pour MySQL. Base de données relationnelle open-source populaire pour applications web et stockage structuré.";
RELATE i18n_key:credential_type_mysql_description->translation->language:en SET text = "Authentication for MySQL. Popular open-source relational database for web applications and structured storage.";
RELATE i18n_key:credential_type_mysql_description->translation->language:it SET text = "Autenticazione per MySQL. Database relazionale open-source popolare per applicazioni web e archiviazione strutturata.";
RELATE i18n_key:credential_type_mysql_description->translation->language:de SET text = "Authentifizierung für MySQL. Beliebte Open-Source-Relationale-Datenbank für Webanwendungen und strukturierte Speicherung.";
RELATE i18n_key:credential_type_mysql_description->translation->language:es SET text = "Autenticación para MySQL. Base datos relacional open-source popular para aplicaciones web y almacenamiento estructurado.";

RELATE i18n_key:credential_type_mysql_tooltip->translation->language:fr SET text = "Pour connexion MySQL et requêtes SQL";
RELATE i18n_key:credential_type_mysql_tooltip->translation->language:en SET text = "For MySQL connection and SQL queries";
RELATE i18n_key:credential_type_mysql_tooltip->translation->language:it SET text = "Per connessione MySQL e query SQL";
RELATE i18n_key:credential_type_mysql_tooltip->translation->language:de SET text = "Für MySQL-Verbindung und SQL-Abfragen";
RELATE i18n_key:credential_type_mysql_tooltip->translation->language:es SET text = "Para conexión MySQL y consultas SQL";

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

RELATE i18n_key:credential_type_mongodb_name->translation->language:fr SET text = "MongoDB";
RELATE i18n_key:credential_type_mongodb_name->translation->language:en SET text = "MongoDB";
RELATE i18n_key:credential_type_mongodb_name->translation->language:it SET text = "MongoDB";
RELATE i18n_key:credential_type_mongodb_name->translation->language:de SET text = "MongoDB";
RELATE i18n_key:credential_type_mongodb_name->translation->language:es SET text = "MongoDB";

RELATE i18n_key:credential_type_mongodb_description->translation->language:fr SET text = "Authentification pour MongoDB. Base de données NoSQL orientée documents pour données flexibles JSON/BSON et scalabilité horizontale.";
RELATE i18n_key:credential_type_mongodb_description->translation->language:en SET text = "Authentication for MongoDB. Document-oriented NoSQL database for flexible JSON/BSON data and horizontal scalability.";
RELATE i18n_key:credential_type_mongodb_description->translation->language:it SET text = "Autenticazione per MongoDB. Database NoSQL orientato documenti per dati JSON/BSON flessibili e scalabilità orizzontale.";
RELATE i18n_key:credential_type_mongodb_description->translation->language:de SET text = "Authentifizierung für MongoDB. Dokumentenorientierte NoSQL-Datenbank für flexible JSON/BSON-Daten und horizontale Skalierbarkeit.";
RELATE i18n_key:credential_type_mongodb_description->translation->language:es SET text = "Autenticación para MongoDB. Base datos NoSQL orientada documentos para datos flexibles JSON/BSON y escalabilidad horizontal.";

RELATE i18n_key:credential_type_mongodb_tooltip->translation->language:fr SET text = "Pour connexion MongoDB et requêtes NoSQL";
RELATE i18n_key:credential_type_mongodb_tooltip->translation->language:en SET text = "For MongoDB connection and NoSQL queries";
RELATE i18n_key:credential_type_mongodb_tooltip->translation->language:it SET text = "Per connessione MongoDB e query NoSQL";
RELATE i18n_key:credential_type_mongodb_tooltip->translation->language:de SET text = "Für MongoDB-Verbindung und NoSQL-Abfragen";
RELATE i18n_key:credential_type_mongodb_tooltip->translation->language:es SET text = "Para conexión MongoDB y consultas NoSQL";

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

RELATE i18n_key:credential_type_rabbitmq_name->translation->language:fr SET text = "RabbitMQ";
RELATE i18n_key:credential_type_rabbitmq_name->translation->language:en SET text = "RabbitMQ";
RELATE i18n_key:credential_type_rabbitmq_name->translation->language:it SET text = "RabbitMQ";
RELATE i18n_key:credential_type_rabbitmq_name->translation->language:de SET text = "RabbitMQ";
RELATE i18n_key:credential_type_rabbitmq_name->translation->language:es SET text = "RabbitMQ";

RELATE i18n_key:credential_type_rabbitmq_description->translation->language:fr SET text = "Authentification pour RabbitMQ. Message broker open-source pour communication asynchrone microservices via protocole AMQP.";
RELATE i18n_key:credential_type_rabbitmq_description->translation->language:en SET text = "Authentication for RabbitMQ. Open-source message broker for asynchronous microservices communication via AMQP protocol.";
RELATE i18n_key:credential_type_rabbitmq_description->translation->language:it SET text = "Autenticazione per RabbitMQ. Message broker open-source per comunicazione asincrona microservizi tramite protocollo AMQP.";
RELATE i18n_key:credential_type_rabbitmq_description->translation->language:de SET text = "Authentifizierung für RabbitMQ. Open-Source-Message-Broker für asynchrone Microservices-Kommunikation über AMQP-Protokoll.";
RELATE i18n_key:credential_type_rabbitmq_description->translation->language:es SET text = "Autenticación para RabbitMQ. Message broker open-source para comunicación asíncrona microservicios vía protocolo AMQP.";

RELATE i18n_key:credential_type_rabbitmq_tooltip->translation->language:fr SET text = "Pour messaging RabbitMQ et files AMQP";
RELATE i18n_key:credential_type_rabbitmq_tooltip->translation->language:en SET text = "For RabbitMQ messaging and AMQP queues";
RELATE i18n_key:credential_type_rabbitmq_tooltip->translation->language:it SET text = "Per messaging RabbitMQ e code AMQP";
RELATE i18n_key:credential_type_rabbitmq_tooltip->translation->language:de SET text = "Für RabbitMQ-Messaging und AMQP-Warteschlangen";
RELATE i18n_key:credential_type_rabbitmq_tooltip->translation->language:es SET text = "Para messaging RabbitMQ y colas AMQP";

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

RELATE i18n_key:credential_type_cratedb_name->translation->language:fr SET text = "CrateDB";
RELATE i18n_key:credential_type_cratedb_name->translation->language:en SET text = "CrateDB";
RELATE i18n_key:credential_type_cratedb_name->translation->language:it SET text = "CrateDB";
RELATE i18n_key:credential_type_cratedb_name->translation->language:de SET text = "CrateDB";
RELATE i18n_key:credential_type_cratedb_name->translation->language:es SET text = "CrateDB";

RELATE i18n_key:credential_type_cratedb_description->translation->language:fr SET text = "Authentification pour CrateDB. Base de données SQL distribuée pour données machine IoT temps-réel et analytics massivement scalable.";
RELATE i18n_key:credential_type_cratedb_description->translation->language:en SET text = "Authentication for CrateDB. Distributed SQL database for real-time IoT machine data and massively scalable analytics.";
RELATE i18n_key:credential_type_cratedb_description->translation->language:it SET text = "Autenticazione per CrateDB. Database SQL distribuito per dati macchina IoT real-time e analytics massivamente scalabile.";
RELATE i18n_key:credential_type_cratedb_description->translation->language:de SET text = "Authentifizierung für CrateDB. Verteilte SQL-Datenbank für Echtzeit-IoT-Maschinendaten und massiv skalierbare Analysen.";
RELATE i18n_key:credential_type_cratedb_description->translation->language:es SET text = "Autenticación para CrateDB. Base datos SQL distribuida para datos máquina IoT tiempo-real y analytics masivamente escalable.";

RELATE i18n_key:credential_type_cratedb_tooltip->translation->language:fr SET text = "Pour CrateDB IoT et analytics distribuées";
RELATE i18n_key:credential_type_cratedb_tooltip->translation->language:en SET text = "For CrateDB IoT and distributed analytics";
RELATE i18n_key:credential_type_cratedb_tooltip->translation->language:it SET text = "Per CrateDB IoT e analytics distribuite";
RELATE i18n_key:credential_type_cratedb_tooltip->translation->language:de SET text = "Für CrateDB IoT und verteilte Analysen";
RELATE i18n_key:credential_type_cratedb_tooltip->translation->language:es SET text = "Para CrateDB IoT y analytics distribuidas";

-- =====================================================
-- QUESTDB
-- =====================================================

RELATE i18n_key:credential_type_questdb_name->translation->language:fr SET text = "QuestDB";
RELATE i18n_key:credential_type_questdb_name->translation->language:en SET text = "QuestDB";
RELATE i18n_key:credential_type_questdb_name->translation->language:it SET text = "QuestDB";
RELATE i18n_key:credential_type_questdb_name->translation->language:de SET text = "QuestDB";
RELATE i18n_key:credential_type_questdb_name->translation->language:es SET text = "QuestDB";

RELATE i18n_key:credential_type_questdb_description->translation->language:fr SET text = "Authentification pour QuestDB. Base de données time-series ultra-rapide pour données IoT, métriques financières et monitoring haute-fréquence.";
RELATE i18n_key:credential_type_questdb_description->translation->language:en SET text = "Authentication for QuestDB. Ultra-fast time-series database for IoT data, financial metrics, and high-frequency monitoring.";
RELATE i18n_key:credential_type_questdb_description->translation->language:it SET text = "Autenticazione per QuestDB. Database time-series ultra-veloce per dati IoT, metriche finanziarie e monitoring alta-frequenza.";
RELATE i18n_key:credential_type_questdb_description->translation->language:de SET text = "Authentifizierung für QuestDB. Ultra-schnelle Time-Series-Datenbank für IoT-Daten, Finanzmetriken und Hochfrequenz-Monitoring.";
RELATE i18n_key:credential_type_questdb_description->translation->language:es SET text = "Autenticación para QuestDB. Base datos time-series ultra-rápida para datos IoT, métricas financieras y monitoreo alta-frecuencia.";

RELATE i18n_key:credential_type_questdb_tooltip->translation->language:fr SET text = "Pour time-series QuestDB et données IoT";
RELATE i18n_key:credential_type_questdb_tooltip->translation->language:en SET text = "For QuestDB time-series and IoT data";
RELATE i18n_key:credential_type_questdb_tooltip->translation->language:it SET text = "Per time-series QuestDB e dati IoT";
RELATE i18n_key:credential_type_questdb_tooltip->translation->language:de SET text = "Für QuestDB Time-Series und IoT-Daten";
RELATE i18n_key:credential_type_questdb_tooltip->translation->language:es SET text = "Para time-series QuestDB y datos IoT";

-- =====================================================
-- TIMESCALEDB
-- =====================================================

RELATE i18n_key:credential_type_timescaledb_name->translation->language:fr SET text = "TimescaleDB";
RELATE i18n_key:credential_type_timescaledb_name->translation->language:en SET text = "TimescaleDB";
RELATE i18n_key:credential_type_timescaledb_name->translation->language:it SET text = "TimescaleDB";
RELATE i18n_key:credential_type_timescaledb_name->translation->language:de SET text = "TimescaleDB";
RELATE i18n_key:credential_type_timescaledb_name->translation->language:es SET text = "TimescaleDB";

RELATE i18n_key:credential_type_timescaledb_description->translation->language:fr SET text = "Authentification pour TimescaleDB. Extension PostgreSQL time-series pour données temporelles IoT, métriques et analytics historiques.";
RELATE i18n_key:credential_type_timescaledb_description->translation->language:en SET text = "Authentication for TimescaleDB. PostgreSQL time-series extension for temporal IoT data, metrics, and historical analytics.";
RELATE i18n_key:credential_type_timescaledb_description->translation->language:it SET text = "Autenticazione per TimescaleDB. Estensione PostgreSQL time-series per dati temporali IoT, metriche e analytics storici.";
RELATE i18n_key:credential_type_timescaledb_description->translation->language:de SET text = "Authentifizierung für TimescaleDB. PostgreSQL Time-Series-Erweiterung für zeitliche IoT-Daten, Metriken und historische Analysen.";
RELATE i18n_key:credential_type_timescaledb_description->translation->language:es SET text = "Autenticación para TimescaleDB. Extensión PostgreSQL time-series para datos temporales IoT, métricas y analytics históricos.";

RELATE i18n_key:credential_type_timescaledb_tooltip->translation->language:fr SET text = "Pour time-series TimescaleDB et métriques IoT";
RELATE i18n_key:credential_type_timescaledb_tooltip->translation->language:en SET text = "For TimescaleDB time-series and IoT metrics";
RELATE i18n_key:credential_type_timescaledb_tooltip->translation->language:it SET text = "Per time-series TimescaleDB e metriche IoT";
RELATE i18n_key:credential_type_timescaledb_tooltip->translation->language:de SET text = "Für TimescaleDB Time-Series und IoT-Metriken";
RELATE i18n_key:credential_type_timescaledb_tooltip->translation->language:es SET text = "Para time-series TimescaleDB y métricas IoT";

-- =============================================================================================

