-- ============================================================================
-- Fichier : studio/reference/knowledge/knowledge_pack_content_seeds.surql
-- Module : studio/knowledge
-- Description : Seeds du contenu du Knowledge Pack SurrealDB pour DEFINE FIELD
-- 
-- Dépendances : knowledge_pack_topic (DEFINE_FIELD doit exister)
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

-- ============================================================================
-- SYNTAX : Syntaxe officielle de DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_content:syntax_define_field_basic {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "syntax",
        title: "Syntaxe de base DEFINE FIELD",
        description: "Syntaxe minimale pour définir un champ"
    },
    content: {
        surql_code: "DEFINE FIELD <field_name> ON TABLE <table_name>;",
        explanation: "Syntaxe de base pour définir un champ sur une table. Remplace <field_name> par le nom du champ et <table_name> par le nom de la table."
    },
    metadata: {
        priority: 10,
        tags: ["syntax", "basic", "fundamental"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:syntax_define_field_type {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "syntax",
        title: "Syntaxe DEFINE FIELD avec TYPE",
        description: "Syntaxe avec définition du type de données"
    },
    content: {
        surql_code: "DEFINE FIELD <field_name> ON TABLE <table_name> TYPE <type>;",
        explanation: "Syntaxe pour définir un champ avec un type spécifique. Les types courants incluent: string, int, float, bool, datetime, record, array, object."
    },
    metadata: {
        priority: 10,
        tags: ["syntax", "type", "fundamental"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:syntax_define_field_complete {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "syntax",
        title: "Syntaxe complète DEFINE FIELD",
        description: "Syntaxe avec tous les attributs possibles"
    },
    content: {
        surql_code: "DEFINE FIELD <field_name> ON TABLE <table_name>\n    TYPE <type>\n    DEFAULT <value>\n    VALUE <value>\n    ASSERT <condition>\n    PERMISSIONS <permissions>;",
        explanation: "Syntaxe complète avec tous les attributs optionnels: TYPE pour le type, DEFAULT pour une valeur par défaut, VALUE pour une valeur calculée, ASSERT pour une validation, PERMISSIONS pour les droits d'accès."
    },
    metadata: {
        priority: 9,
        tags: ["syntax", "complete", "advanced"],
        is_active: true,
        version: "1.0.0"
    }
};

-- ============================================================================
-- RULES : Bonnes pratiques pour DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_content:rule_always_define_type {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Toujours définir un TYPE",
        description: "Règle fondamentale : toujours spécifier le TYPE pour un champ"
    },
    content: {
        explanation: "Toujours définir explicitement un TYPE pour chaque champ. Cela garantit la cohérence des données, surtout en mode SCHEMAFULL. Sans TYPE, SurrealDB peut accepter n'importe quel type de données, ce qui peut causer des incohérences.",
        when_to_use: "Appliquer cette règle systématiquement pour tous les champs en mode SCHEMAFULL."
    },
    metadata: {
        priority: 10,
        tags: ["rule", "type", "schemafull", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:rule_alphabetical_order {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Classer les champs par ordre alphabétique",
        description: "Organiser les définitions de champs dans l'ordre alphabétique"
    },
    content: {
        explanation: "Classer les définitions de champs par ordre alphabétique améliore la lisibilité et la maintenabilité du schéma. Cela facilite la navigation et réduit les risques d'oubli de champs.",
        when_to_use: "Appliquer lors de la définition initiale d'une table et maintenir cet ordre lors des ajouts."
    },
    metadata: {
        priority: 7,
        tags: ["rule", "organization", "maintenance", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:rule_avoid_default_and_value {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Éviter de mélanger DEFAULT et VALUE",
        description: "Ne pas utiliser DEFAULT et VALUE en même temps"
    },
    content: {
        explanation: "DEFAULT et VALUE sont mutuellement exclusifs. DEFAULT définit une valeur par défaut si aucune valeur n'est fournie. VALUE définit une valeur calculée qui remplace toujours la valeur fournie. Les mélanger peut créer de la confusion.",
        when_to_use: "Utiliser DEFAULT pour des valeurs constantes par défaut. Utiliser VALUE pour des valeurs calculées dynamiquement."
    },
    metadata: {
        priority: 9,
        tags: ["rule", "default", "value", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:rule_use_assert_validation {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Utiliser ASSERT pour la validation",
        description: "Toujours valider les données avec ASSERT quand c'est pertinent"
    },
    content: {
        explanation: "ASSERT permet de valider les données avant insertion/modification. Utilisez ASSERT pour garantir l'intégrité des données, surtout pour les emails, les URLs, les formats spécifiques, les plages de valeurs, etc.",
        when_to_use: "Toujours ajouter ASSERT pour les champs critiques : emails, URLs, valeurs numériques avec plages, chaînes de caractères avec formats spécifiques."
    },
    metadata: {
        priority: 9,
        tags: ["rule", "assert", "validation", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:rule_if_not_exists {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Utiliser IF NOT EXISTS pour éviter les erreurs",
        description: "Utiliser IF NOT EXISTS pour les scripts d'initialisation"
    },
    content: {
        explanation: "Dans les scripts d'initialisation ou de migration, utilisez IF NOT EXISTS pour éviter les erreurs si le champ existe déjà. Cela rend les scripts idempotents et réexécutables.",
        when_to_use: "Utiliser dans les scripts SQL d'initialisation, de migration ou de déploiement."
    },
    metadata: {
        priority: 7,
        tags: ["rule", "if-not-exists", "migration", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

-- ============================================================================
-- EXAMPLES CORRECT : Exemples corrects de DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_content:example_correct_email_field {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_correct",
        title: "Exemple : Champ email avec validation",
        description: "Définition correcte d'un champ email avec validation"
    },
    content: {
        surql_code: "DEFINE FIELD email ON TABLE user TYPE string\n    ASSERT string::is_email($value);",
        explanation: "Exemple correct : définition d'un champ email avec TYPE string et ASSERT pour valider le format email. La fonction string::is_email($value) garantit que seule une adresse email valide peut être stockée."
    },
    metadata: {
        priority: 10,
        tags: ["example", "email", "validation", "assert"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_correct_datetime_with_default {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_correct",
        title: "Exemple : Champ datetime avec valeur par défaut",
        description: "Définition correcte d'un champ datetime avec DEFAULT"
    },
    content: {
        surql_code: "DEFINE FIELD created_at ON TABLE user TYPE datetime\n    DEFAULT time::now();",
        explanation: "Exemple correct : définition d'un champ created_at avec TYPE datetime et DEFAULT time::now(). Le champ sera automatiquement rempli avec la date/heure actuelle lors de la création du record."
    },
    metadata: {
        priority: 10,
        tags: ["example", "datetime", "default", "timestamp"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_correct_record_reference {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_correct",
        title: "Exemple : Champ avec référence vers un record",
        description: "Définition correcte d'un champ référence (foreign key)"
    },
    content: {
        surql_code: "DEFINE FIELD author_id ON TABLE post TYPE record<user>\n    ASSERT $value != NONE;",
        explanation: "Exemple correct : définition d'un champ author_id de type record<user> avec ASSERT pour garantir qu'une valeur est toujours fournie. Cela crée une référence vers la table user."
    },
    metadata: {
        priority: 10,
        tags: ["example", "record", "reference", "foreign-key"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_correct_computed_value {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_correct",
        title: "Exemple : Champ avec valeur calculée (VALUE)",
        description: "Définition correcte d'un champ avec valeur calculée"
    },
    content: {
        surql_code: "DEFINE FIELD full_name ON TABLE user TYPE string\n    VALUE string::concat($before.first_name, ' ', $before.last_name);",
        explanation: "Exemple correct : définition d'un champ full_name avec VALUE pour calculer automatiquement la valeur à partir d'autres champs. La valeur est toujours calculée, même si fournie lors de l'insertion."
    },
    metadata: {
        priority: 9,
        tags: ["example", "value", "computed", "derived"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_correct_array_with_assert {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_correct",
        title: "Exemple : Champ array avec validation",
        description: "Définition correcte d'un champ array avec validation"
    },
    content: {
        surql_code: "DEFINE FIELD tags ON TABLE post TYPE array<string>\n    ASSERT array::len($value) <= 10;",
        explanation: "Exemple correct : définition d'un champ tags de type array<string> avec ASSERT pour limiter le nombre d'éléments à 10 maximum."
    },
    metadata: {
        priority: 9,
        tags: ["example", "array", "validation", "assert"],
        is_active: true,
        version: "1.0.0"
    }
};

-- ============================================================================
-- EXAMPLES INCORRECT : Mauvais exemples (anti-patterns)
-- ============================================================================

CREATE knowledge_pack_content:example_incorrect_no_type {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_incorrect",
        title: "Mauvais exemple : Définition sans TYPE",
        description: "Ne pas définir un champ sans TYPE en mode SCHEMAFULL"
    },
    content: {
        surql_code: "DEFINE FIELD email ON TABLE user;",
        explanation: "Exemple incorrect : le champ est défini sans TYPE. En mode SCHEMAFULL, cela peut causer des incohérences car SurrealDB peut accepter n'importe quel type de données.",
        why_incorrect: "Sans TYPE, le champ peut accepter n'importe quel type de données (string, int, object, etc.), ce qui viole le principe SCHEMAFULL et peut causer des erreurs lors des requêtes ou de la validation."
    },
    metadata: {
        priority: 10,
        tags: ["anti-pattern", "type", "schemafull", "error"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_incorrect_default_and_value {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_incorrect",
        title: "Mauvais exemple : Mélanger DEFAULT et VALUE",
        description: "Ne pas utiliser DEFAULT et VALUE simultanément"
    },
    content: {
        surql_code: "DEFINE FIELD created_at ON TABLE user TYPE datetime\n    DEFAULT time::now()\n    VALUE time::now();",
        explanation: "Exemple incorrect : utilisation simultanée de DEFAULT et VALUE. Ces deux attributs sont mutuellement exclusifs.",
        why_incorrect: "VALUE remplace toujours la valeur fournie, donc DEFAULT ne sera jamais utilisé. Cela crée de la confusion et peut masquer des bugs. Choisissez l'un ou l'autre selon votre besoin."
    },
    metadata: {
        priority: 9,
        tags: ["anti-pattern", "default", "value", "conflict"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_incorrect_no_assert_email {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_incorrect",
        title: "Mauvais exemple : Email sans validation",
        description: "Ne pas définir un champ email sans ASSERT"
    },
    content: {
        surql_code: "DEFINE FIELD email ON TABLE user TYPE string;",
        explanation: "Exemple incorrect : un champ email devrait toujours avoir une validation avec ASSERT pour garantir l'intégrité des données.",
        why_incorrect: "Sans ASSERT, des valeurs invalides comme 'not-an-email' ou 'test@' peuvent être insérées, ce qui peut causer des problèmes dans l'application (envoi d'emails, authentification, etc.)."
    },
    metadata: {
        priority: 9,
        tags: ["anti-pattern", "email", "validation", "assert"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:example_incorrect_wrong_type {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "example_incorrect",
        title: "Mauvais exemple : TYPE incorrect pour l'usage",
        description: "Utiliser un TYPE inadapté à l'usage prévu"
    },
    content: {
        surql_code: "DEFINE FIELD age ON TABLE user TYPE string;",
        explanation: "Exemple incorrect : un champ age devrait être de type int ou number, pas string. Utiliser string pour des données numériques est une mauvaise pratique.",
        why_incorrect: "Utiliser string pour des données numériques empêche les opérations mathématiques, les comparaisons numériques et la validation des plages. Cela complique aussi les requêtes et peut causer des bugs subtils."
    },
    metadata: {
        priority: 8,
        tags: ["anti-pattern", "type", "data-type", "best-practice"],
        is_active: true,
        version: "1.0.0"
    }
};

-- ============================================================================
-- TIPS : Conseils et astuces pour DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_content:tip_use_if_not_exists {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "tip",
        title: "Astuce : Utiliser IF NOT EXISTS",
        description: "Rendre les scripts idempotents avec IF NOT EXISTS"
    },
    content: {
        explanation: "Utilisez IF NOT EXISTS dans vos scripts de définition pour les rendre idempotents. Cela permet de réexécuter le script sans erreur si le champ existe déjà.",
        when_to_use: "Dans tous les scripts d'initialisation, migration ou déploiement pour éviter les erreurs lors de réexécutions."
    },
    metadata: {
        priority: 8,
        tags: ["tip", "if-not-exists", "idempotent", "script"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:tip_nested_fields {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "tip",
        title: "Astuce : Définir les champs imbriqués",
        description: "Comment définir des champs dans des objets imbriqués"
    },
    content: {
        surql_code: "DEFINE FIELD address.street ON TABLE user TYPE string;",
        explanation: "Pour définir un champ dans un objet imbriqué, utilisez la notation pointée (ex: address.street). Cela permet de structurer les données de manière hiérarchique tout en gardant le contrôle du schéma.",
        when_to_use: "Lorsque vous avez des objets complexes (adresses, coordonnées, métadonnées) et que vous voulez un contrôle de schéma strict."
    },
    metadata: {
        priority: 7,
        tags: ["tip", "nested", "object", "hierarchy"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:tip_optional_fields {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "tip",
        title: "Astuce : Champs optionnels avec option<>",
        description: "Utiliser option<> pour les champs optionnels"
    },
    content: {
        surql_code: "DEFINE FIELD middle_name ON TABLE user TYPE option<string>;",
        explanation: "Utilisez option<string> pour les champs optionnels. Cela indique clairement que le champ peut être NONE (NULL). Sans option<>, SurrealDB attendra toujours une valeur.",
        when_to_use: "Pour tous les champs qui ne sont pas obligatoires : second prénom, numéro de téléphone secondaire, informations optionnelles, etc."
    },
    metadata: {
        priority: 8,
        tags: ["tip", "optional", "option", "nullable"],
        is_active: true,
        version: "1.0.0"
    }
};

-- ============================================================================
-- PATTERNS : Patterns réutilisables pour DEFINE FIELD
-- ============================================================================

CREATE knowledge_pack_content:pattern_email_field {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "pattern",
        title: "Pattern : Champ email standard",
        description: "Pattern réutilisable pour un champ email"
    },
    content: {
        surql_code: "DEFINE FIELD email ON TABLE <table_name> TYPE string\n    ASSERT string::is_email($value);",
        explanation: "Pattern standard pour un champ email. Remplacez <table_name> par le nom de votre table. Ce pattern garantit que seule une adresse email valide peut être stockée.",
        when_to_use: "Pour tous les champs de type email dans votre base de données : utilisateurs, contacts, notifications, etc."
    },
    metadata: {
        priority: 10,
        tags: ["pattern", "email", "validation", "reusable"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:pattern_timestamps {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "pattern",
        title: "Pattern : Champs de timestamp (created_at, updated_at)",
        description: "Pattern réutilisable pour les timestamps"
    },
    content: {
        surql_code: "DEFINE FIELD created_at ON TABLE <table_name> TYPE datetime\n    DEFAULT time::now();\n\nDEFINE FIELD updated_at ON TABLE <table_name> TYPE datetime\n    DEFAULT time::now();",
        explanation: "Pattern standard pour les champs de timestamp. created_at est défini une fois. updated_at devrait idéalement être mis à jour via un EVENT ou une fonction lors des modifications. Remplacez <table_name> par votre table.",
        when_to_use: "Pour toutes les tables qui nécessitent un suivi de création et modification. Pattern très commun dans les applications."
    },
    metadata: {
        priority: 10,
        tags: ["pattern", "timestamp", "datetime", "audit", "reusable"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:pattern_foreign_key {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "pattern",
        title: "Pattern : Référence vers un record (foreign key)",
        description: "Pattern réutilisable pour une référence vers un autre record"
    },
    content: {
        surql_code: "DEFINE FIELD <field_name>_id ON TABLE <table_name> TYPE record<<referenced_table>>\n    ASSERT $value != NONE;",
        explanation: "Pattern pour une référence vers un autre record. Remplacez <field_name> par le nom du champ, <table_name> par la table actuelle et <referenced_table> par la table référencée. L'ASSERT garantit qu'une valeur est toujours fournie.",
        when_to_use: "Pour tous les cas de foreign key : author_id, category_id, parent_id, owner_id, etc."
    },
    metadata: {
        priority: 10,
        tags: ["pattern", "foreign-key", "record", "reference", "reusable"],
        is_active: true,
        version: "1.0.0"
    }
};

CREATE knowledge_pack_content:pattern_status_enum {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "pattern",
        title: "Pattern : Champ status avec valeurs énumérées",
        description: "Pattern pour un champ status avec validation de valeurs"
    },
    content: {
        surql_code: "DEFINE FIELD status ON TABLE <table_name> TYPE string\n    ASSERT $value IN ['active', 'inactive', 'pending', 'archived'];",
        explanation: "Pattern pour un champ status avec validation des valeurs autorisées. Remplacez <table_name> et la liste des valeurs selon vos besoins. L'ASSERT garantit que seules les valeurs définies peuvent être utilisées.",
        when_to_use: "Pour tous les champs de statut, état, type, etc. où vous voulez limiter les valeurs possibles."
    },
    metadata: {
        priority: 9,
        tags: ["pattern", "enum", "status", "validation", "reusable"],
        is_active: true,
        version: "1.0.0"
    }
};

