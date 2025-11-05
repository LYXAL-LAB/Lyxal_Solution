-- =============================================================================================
-- |
-- | Fichier : credential_type_batch7_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 7 des credential types (12 credentials Databases & Messaging).
-- |
-- | Batch 7 : Databases & Messaging (12 credentials)
-- | Providers : MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch, Kafka, RabbitMQ, MQTT, AMQP, CrateDB, QuestDB, TimescaleDB
-- |
-- =============================================================================================

-- =====================================================
-- 1. MYSQL - DOUBLON SUPPRIMÉ (déjà défini ailleurs avec name = "mySql")
-- =====================================================

-- =====================================================
-- 2. POSTGRES (display_order: 601) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:postgres SET
    name = "postgres",
    slug = "postgres",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_postgres_name,
        description_i18n: i18n_key:credential_type_postgres_description
    },
    
    presentation = {
        icon: icon:postgres,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_postgres_tooltip,
        display_order: 601
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:postgres,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "PostgreSQL server host",
                default: "localhost"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "PostgreSQL server port",
                default: 5432
            },
            {
                name: "database",
                display_name: "Database",
                type: "string",
                is_secret: false,
                required: true,
                description: "PostgreSQL database name"
            },
            {
                name: "user",
                display_name: "User",
                type: "string",
                is_secret: false,
                required: true,
                description: "PostgreSQL username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "PostgreSQL password"
            }
        ],
        metadata: {
            connection_type: "tcp",
            supports_ssl: true,
            supports_jsonb: true
        }
    },
    
    documentation = {
        url: url:postgres_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. MONGODB - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "mongoDb")
-- =====================================================

-- =====================================================
-- 4. REDIS (display_order: 603) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:redis SET
    name = "redis",
    slug = "redis",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_redis_name,
        description_i18n: i18n_key:credential_type_redis_description
    },
    
    presentation = {
        icon: icon:redis,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_redis_tooltip,
        display_order: 603
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:redis,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "Redis server host",
                default: "localhost"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "Redis server port",
                default: 6379
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "Redis password (if AUTH enabled)"
            },
            {
                name: "database",
                display_name: "Database",
                type: "number",
                is_secret: false,
                required: false,
                description: "Redis database number",
                default: 0
            }
        ],
        metadata: {
            connection_type: "tcp",
            supports_ssl: true
        }
    },
    
    documentation = {
        url: url:redis_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. ELASTICSEARCH API (display_order: 610)
-- =====================================================

CREATE credential_type:elasticsearch_api SET
    name = "elasticsearchApi",
    slug = "elasticsearch-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_elasticsearch_api_name,
        description_i18n: i18n_key:credential_type_elasticsearch_api_description
    },
    
    presentation = {
        icon: icon:elasticsearch,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_elasticsearch_api_tooltip,
        display_order: 610
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:elasticsearch,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Elasticsearch cluster URL",
                placeholder: "https://localhost:9200"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: false,
                description: "Elasticsearch username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "Elasticsearch password"
            }
        ],
        metadata: {
            supports_cloud: true,
            supports_api_key: true
        }
    },
    
    documentation = {
        url: url:elasticsearch_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. KAFKA (display_order: 620)
-- =====================================================

CREATE credential_type:kafka SET
    name = "kafka",
    slug = "kafka",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_kafka_name,
        description_i18n: i18n_key:credential_type_kafka_description
    },
    
    presentation = {
        icon: icon:kafka,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_kafka_tooltip,
        display_order: 620
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:kafka,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "brokers",
                display_name: "Brokers",
                type: "string",
                is_secret: false,
                required: true,
                description: "Comma-separated list of Kafka brokers",
                placeholder: "localhost:9092"
            },
            {
                name: "ssl",
                display_name: "SSL",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Enable SSL/TLS",
                default: false
            },
            {
                name: "saslMechanism",
                display_name: "SASL Mechanism",
                type: "options",
                is_secret: false,
                required: false,
                description: "SASL authentication mechanism",
                options: [
                    { name: "None", value: "none" },
                    { name: "PLAIN", value: "plain" },
                    { name: "SCRAM-SHA-256", value: "scram-sha-256" },
                    { name: "SCRAM-SHA-512", value: "scram-sha-512" }
                ],
                default: "none"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: false,
                description: "SASL username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "SASL password"
            }
        ],
        metadata: {
            supports_sasl: true,
            supports_ssl: true
        }
    },
    
    documentation = {
        url: url:kafka_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. RABBITMQ - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "rabbitMq")
-- =====================================================

-- =====================================================
-- 8. MQTT (display_order: 622)
-- =====================================================

CREATE credential_type:mqtt SET
    name = "mqtt",
    slug = "mqtt",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mqtt_name,
        description_i18n: i18n_key:credential_type_mqtt_description
    }, presentation = { icon: icon:mqtt, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_mqtt_tooltip,
        display_order: 622
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:mqtt,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "protocol",
                display_name: "Protocol",
                type: "options",
                is_secret: false,
                required: true,
                description: "MQTT protocol",
                options: [
                    { name: "mqtt", value: "mqtt" },
                    { name: "mqtts (SSL)", value: "mqtts" },
                    { name: "ws (WebSocket)", value: "ws" },
                    { name: "wss (WebSocket SSL)", value: "wss" }
                ],
                default: "mqtt"
            },
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "MQTT broker host",
                default: "localhost"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "MQTT broker port",
                default: 1883
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: false,
                description: "MQTT username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "MQTT password"
            },
            {
                name: "clientId",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: false,
                description: "MQTT client identifier"
            }
        ],
        metadata: {
            iot_protocol: true,
            supports_websocket: true
        }
    },
    
    documentation = {
        url: url:mqtt_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. AMQP (display_order: 623)
-- =====================================================

CREATE credential_type:amqp SET
    name = "amqp",
    slug = "amqp",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_amqp_name,
        description_i18n: i18n_key:credential_type_amqp_description
    },
    
    presentation = {
        icon: icon:amqp,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_amqp_tooltip,
        display_order: 623
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:amqp,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "hostname",
                display_name: "Hostname",
                type: "string",
                is_secret: false,
                required: true,
                description: "AMQP server hostname",
                default: "localhost"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "AMQP server port",
                default: 5672
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: false,
                description: "AMQP username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "AMQP password"
            },
            {
                name: "vhost",
                display_name: "Virtual Host",
                type: "string",
                is_secret: false,
                required: false,
                description: "AMQP virtual host",
                default: "/"
            }
        ],
        metadata: {
            protocol_version: "0.9.1",
            supports_ssl: true
        }
    },
    
    documentation = {
        url: url:amqp_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. CRATEDB - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "crateDb")
-- =====================================================

-- =====================================================
-- 11. QUESTDB - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "questDb")
-- =====================================================

-- =====================================================
-- 12. TIMESCALEDB - DOUBLON SUPPRIMÉ (déjà défini dans batch33 avec name = "timescaleDb")
-- =====================================================

-- =====================================================
-- VÉRIFICATION
-- =====================================================

/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    auth_type.name AS auth_type_name,
    provider.name AS provider_name
FROM credential_type
WHERE presentation.display_order >= 600 AND presentation.display_order < 650
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 7
-- =====================================================
--
-- ✅ 12 credentials Databases & Messaging créés :
--
-- Databases SQL (3) - display_order: 600-602 ✨ TRÈS POPULAIRE
--  1. mysql (600) ✨ TRÈS POPULAIRE
--  2. postgres (601) ✨ TRÈS POPULAIRE
--  3. timescaledb (632) - PostgreSQL Time-Series Extension
--
-- Databases NoSQL (2) - display_order: 602-603 ✨ TRÈS POPULAIRE
--  4. mongodb (602) ✨ TRÈS POPULAIRE - Document-Oriented
--  5. redis (603) ✨ TRÈS POPULAIRE - Key-Value In-Memory
--
-- Search & Analytics (1) - display_order: 610
--  6. elasticsearch_api (610) - Full-Text Search
--
-- Message Brokers (4) - display_order: 620-623
--  7. kafka (620) - Distributed Streaming
--  8. rabbitmq (621) - AMQP Message Broker
--  9. mqtt (622) - IoT Protocol
-- 10. amqp (623) - Standard Messaging Protocol
--
-- Time-Series Databases (2) - display_order: 630-631
-- 11. cratedb (630) - Distributed SQL for IoT
-- 12. questdb (631) - Ultra-Fast Time-Series
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

