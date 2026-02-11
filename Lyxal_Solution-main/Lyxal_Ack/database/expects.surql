-- ============================================================
-- ENTITY: expects (Relation)
-- DESCRIPTION: Suivi des signataires attendus
-- ============================================================

DEFINE TABLE IF NOT EXISTS expects TYPE RELATION IN document OUT user SCHEMAFULL
    COMMENT "Relation de suivi des signataires attendus pour un document donné"
    PERMISSIONS
        FOR select WHERE $auth.id = out OR $auth.admin = true
        FOR create, update, delete WHERE $auth.admin = true;

DEFINE FIELD IF NOT EXISTS in                 ON TABLE expects TYPE record<document>
    COMMENT "Référence du document concerné (entrée de la relation)";
DEFINE FIELD IF NOT EXISTS out                ON TABLE expects TYPE record<user>
    COMMENT "Référence de l'utilisateur attendu (sortie de la relation)";
DEFINE FIELD IF NOT EXISTS added_by           ON TABLE expects TYPE record<user>
    COMMENT "Référence de l'administrateur ayant assigné cette obligation de signature";
DEFINE FIELD IF NOT EXISTS notes              ON TABLE expects TYPE option<string>
    COMMENT "Consignes ou notes spécifiques laissées par l'administrateur pour le signataire";
DEFINE FIELD IF NOT EXISTS due_date           ON TABLE expects TYPE option<datetime>
    COMMENT "Date limite optionnelle pour effectuer la signature";
DEFINE FIELD IF NOT EXISTS reminded_at        ON TABLE expects TYPE option<datetime>
    COMMENT "Horodatage du dernier rappel automatique envoyé";

