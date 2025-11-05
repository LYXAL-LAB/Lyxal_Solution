-- =============================================================================================
-- |
-- | Fichier : credential_type_batch7_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Clés i18n pour le Batch 7 des credential types.
-- |
-- | Batch 7 : Databases & Messaging (12 credentials)
-- | Providers : MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch, Kafka, RabbitMQ, etc.
-- |
-- | Total : 36 clés i18n (12 credentials × 3 clés chacun)
-- |
-- =============================================================================================

-- =====================================================
-- MYSQL (3 clés)
-- =====================================================

    description = "Nom affiché du credential type MySQL";

    description = "Description complète de MySQL pour credentials";

    description = "Tooltip d'aide pour MySQL credentials";

-- =====================================================
-- POSTGRES (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_postgres_name SET
    description = "Nom affiché du credential type PostgreSQL";

CREATE i18n_key:credential_type_postgres_description SET
    description = "Description complète de PostgreSQL pour credentials";

CREATE i18n_key:credential_type_postgres_tooltip SET
    description = "Tooltip d'aide pour PostgreSQL credentials";

-- =====================================================
-- MONGODB (3 clés)
-- =====================================================

    description = "Nom affiché du credential type MongoDB";

    description = "Description complète de MongoDB pour credentials";

    description = "Tooltip d'aide pour MongoDB credentials";

-- =====================================================
-- REDIS (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_redis_name SET
    description = "Nom affiché du credential type Redis";

CREATE i18n_key:credential_type_redis_description SET
    description = "Description complète de Redis pour credentials";

CREATE i18n_key:credential_type_redis_tooltip SET
    description = "Tooltip d'aide pour Redis credentials";

-- =====================================================
-- ELASTICSEARCH API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_elasticsearch_api_name SET
    description = "Nom affiché du credential type Elasticsearch";

CREATE i18n_key:credential_type_elasticsearch_api_description SET
    description = "Description complète de Elasticsearch pour credentials";

CREATE i18n_key:credential_type_elasticsearch_api_tooltip SET
    description = "Tooltip d'aide pour Elasticsearch credentials";

-- =====================================================
-- KAFKA (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_kafka_name SET
    description = "Nom affiché du credential type Apache Kafka";

CREATE i18n_key:credential_type_kafka_description SET
    description = "Description complète de Apache Kafka pour credentials";

CREATE i18n_key:credential_type_kafka_tooltip SET
    description = "Tooltip d'aide pour Apache Kafka credentials";

-- =====================================================
-- RABBITMQ (3 clés)
-- =====================================================

    description = "Nom affiché du credential type RabbitMQ";

    description = "Description complète de RabbitMQ pour credentials";

    description = "Tooltip d'aide pour RabbitMQ credentials";

-- =====================================================
-- MQTT (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_mqtt_name SET
    description = "Nom affiché du credential type MQTT";

CREATE i18n_key:credential_type_mqtt_description SET
    description = "Description complète de MQTT pour credentials";

CREATE i18n_key:credential_type_mqtt_tooltip SET
    description = "Tooltip d'aide pour MQTT credentials";

-- =====================================================
-- AMQP (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_amqp_name SET
    description = "Nom affiché du credential type AMQP";

CREATE i18n_key:credential_type_amqp_description SET
    description = "Description complète de AMQP pour credentials";

CREATE i18n_key:credential_type_amqp_tooltip SET
    description = "Tooltip d'aide pour AMQP credentials";

-- =====================================================
-- CRATEDB (3 clés)
-- =====================================================

    description = "Nom affiché du credential type CrateDB";

    description = "Description complète de CrateDB pour credentials";

    description = "Tooltip d'aide pour CrateDB credentials";

-- =====================================================
-- QUESTDB (3 clés)
-- =====================================================

    description = "Nom affiché du credential type QuestDB";

    description = "Description complète de QuestDB pour credentials";

    description = "Tooltip d'aide pour QuestDB credentials";

-- =====================================================
-- TIMESCALEDB (3 clés)
-- =====================================================

    description = "Nom affiché du credential type TimescaleDB";

    description = "Description complète de TimescaleDB pour credentials";

    description = "Tooltip d'aide pour TimescaleDB credentials";

-- =============================================================================================

