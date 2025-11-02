-- ============================================================================
-- Fichier : studio/reference/knowledge/knowledge_pack_topic_seeds.surql
-- Module : studio/knowledge
-- Description : Seeds des topics du Knowledge Pack SurrealDB
-- 
-- Dépendances : knowledge_pack_topic
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

-- ============================================================================
-- TOPIC : DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_topic:define_field {
    identity: {
        code: "DEFINE_FIELD",
        name: "DEFINE FIELD",
        description: "Définition de champs (fields) dans SurrealDB. Permet de définir la structure, le type, les validations et les contraintes d'un champ sur une table."
    },
    metadata: {
        category: "DEFINE",
        priority: 10,
        version: "1.0.0",
        is_active: true
    }
};

-- ============================================================================
-- PLACEHOLDERS pour futurs topics (prêts pour insertion)
-- ============================================================================

-- CREATE knowledge_pack_topic:define_table {
--     identity: {
--         code: "DEFINE_TABLE",
--         name: "DEFINE TABLE",
--         description: "Définition de tables dans SurrealDB"
--     },
--     metadata: {
--         category: "DEFINE",
--         priority: 10,
--         version: "1.0.0",
--         is_active: true
--     }
-- };

-- CREATE knowledge_pack_topic:define_index {
--     identity: {
--         code: "DEFINE_INDEX",
--         name: "DEFINE INDEX",
--         description: "Définition d'index dans SurrealDB"
--     },
--     metadata: {
--         category: "INDEX",
--         priority: 10,
--         version: "1.0.0",
--         is_active: true
--     }
-- };

-- CREATE knowledge_pack_topic:relate {
--     identity: {
--         code: "RELATE",
--         name: "RELATE",
--         description: "Création de relations entre records dans SurrealDB"
--     },
--     metadata: {
--         category: "RELATE",
--         priority: 10,
--         version: "1.0.0",
--         is_active: true
--     }
-- };

-- CREATE knowledge_pack_topic:permissions {
--     identity: {
--         code: "PERMISSIONS",
--         name: "PERMISSIONS",
--         description: "Définition de permissions dans SurrealDB"
--     },
--     metadata: {
--         category: "PERMISSIONS",
--         priority: 10,
--         version: "1.0.0",
--         is_active: true
--     }
-- };

