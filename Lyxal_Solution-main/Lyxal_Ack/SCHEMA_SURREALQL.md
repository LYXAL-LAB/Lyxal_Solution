# Schéma de Base de Données "Full Compliance" (SurrealQL)

-- ============================================================
-- MODULE: LyxalAck
-- VERSION: 2.2.1 (Parité Absolue & Rigueur CTO)
-- DESCRIPTION: Système de preuve de lecture souverain (Fields, Index et Access v3)
-- ============================================================

-- 1. Table des Documents (Entité)
DEFINE TABLE IF NOT EXISTS document TYPE NORMAL SCHEMAFULL
    COMMENT "Référentiel des documents à signer"
    PERMISSIONS 
        FOR select FULL
        FOR create, update, delete WHERE $auth.admin = true;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE document TYPE string
    COMMENT "Identifiant de l'organisation ou de la partition de données";
DEFINE FIELD IF NOT EXISTS title ON TABLE document TYPE string
    COMMENT "Titre public du document";
DEFINE FIELD IF NOT EXISTS description ON TABLE document TYPE option<string>
    COMMENT "Description détaillée ou résumé du contenu du document";
DEFINE FIELD IF NOT EXISTS url ON TABLE document TYPE string
    COMMENT "Lien vers le fichier source (PDF, Page web, etc.)";
DEFINE FIELD IF NOT EXISTS checksum ON TABLE document TYPE string
    COMMENT "Empreinte numérique (hash) de référence du document original";
DEFINE FIELD IF NOT EXISTS checksum_algorithm  ON TABLE document TYPE string DEFAULT 'SHA-256' 
    ASSERT $value INSIDE ['SHA-256', 'SHA-512', 'MD5']
    COMMENT "Algorithme utilisé pour calculer l'empreinte numérique (ex: SHA-256)";
DEFINE FIELD IF NOT EXISTS metadata ON TABLE document TYPE object DEFAULT {}
    COMMENT "Données additionnelles structurées (ex: tags, versioning)";
DEFINE FIELD IF NOT EXISTS created_by ON TABLE document TYPE record<user>
    COMMENT "Référence de l'utilisateur administrateur ayant créé le document";
DEFINE FIELD IF NOT EXISTS created_at         ON TABLE document TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la création du document";
DEFINE FIELD IF NOT EXISTS updated_at         ON TABLE document TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la dernière modification des métadonnées";

DEFINE INDEX IF NOT EXISTS idx_document_tenant ON TABLE document FIELDS tenant_id
    COMMENT "Index de partitionnement par organisation pour les documents";

-- 2. Relation: Attente de Signature (Graphe)
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

-- 3. Relation: Signatures Effectives (Graphe Immuable & Crypto-Rigoureux)
DEFINE TABLE IF NOT EXISTS signed TYPE RELATION IN user OUT document SCHEMAFULL
    COMMENT "Preuves cryptographiques de lecture et d'acceptation (Audit Trail)"
    PERMISSIONS
        FOR select WHERE $auth.id = in OR $auth.admin = true
        FOR create WHERE $auth.id = in
        FOR update, delete NONE;

DEFINE FIELD IF NOT EXISTS in                 ON TABLE signed TYPE record<user>
    COMMENT "Référence de l'utilisateur signataire (entrée de la relation)";
DEFINE FIELD IF NOT EXISTS out                ON TABLE signed TYPE record<document>
    COMMENT "Référence du document signé (sortie de la relation)";
DEFINE FIELD IF NOT EXISTS proof              ON TABLE signed TYPE string
    COMMENT "Preuve cryptographique Ed25519 encodée en hexadécimal";
DEFINE FIELD IF NOT EXISTS payload_hash       ON TABLE signed TYPE string
    COMMENT "Hachage (hash) des données ayant été signées, pour vérification rapide";
DEFINE FIELD IF NOT EXISTS nonce              ON TABLE signed TYPE string
    COMMENT "Valeur aléatoire unique utilisée pour prévenir les attaques par rejeu";
DEFINE FIELD IF NOT EXISTS doc_checksum       ON TABLE signed TYPE string
    COMMENT "Empreinte numérique du document telle que calculée à l'instant précis de la signature";
DEFINE FIELD IF NOT EXISTS prev_hash          ON TABLE signed TYPE option<string>
    COMMENT "Hachage de la signature précédente dans la chaîne d'audit pour garantir l'intégrité séquentielle";
DEFINE FIELD IF NOT EXISTS referer            ON TABLE signed TYPE option<string>
    COMMENT "URL source ou identifiant du service d'intégration (ex: Notion, Slack)";
DEFINE FIELD IF NOT EXISTS user_agent         ON TABLE signed TYPE option<string>
    COMMENT "Informations sur le navigateur et le système du signataire au moment de l'acte";
DEFINE FIELD IF NOT EXISTS signed_at          ON TABLE signed TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage précis de l'acte de signature";

DEFINE INDEX IF NOT EXISTS idx_signed_unique   ON TABLE signed   FIELDS in, out UNIQUE
    COMMENT "Contrainte d'unicité garantissant qu'un utilisateur ne peut signer un document qu'une seule fois";

-- 4. Table des Logs de Rappels (Audit de communication)
DEFINE TABLE IF NOT EXISTS reminder_log TYPE NORMAL SCHEMAFULL
    COMMENT "Historique et statut des notifications de rappel envoyées"
    PERMISSIONS
        FOR select WHERE $auth.id = recipient OR $auth.admin = true
        FOR create, update, delete WHERE $auth.admin = true;

DEFINE FIELD IF NOT EXISTS document           ON TABLE reminder_log TYPE record<document>
    COMMENT "Référence du document associé au rappel";
DEFINE FIELD IF NOT EXISTS recipient          ON TABLE reminder_log TYPE record<user>
    COMMENT "Référence de l'utilisateur destinataire du rappel";
DEFINE FIELD IF NOT EXISTS sent_by            ON TABLE reminder_log TYPE record<user>
    COMMENT "Référence de l'administrateur ou du système ayant déclenché l'envoi";
DEFINE FIELD IF NOT EXISTS template_used      ON TABLE reminder_log TYPE string
    COMMENT "Nom du modèle de message (template) utilisé pour cet envoi";
DEFINE FIELD IF NOT EXISTS status             ON TABLE reminder_log TYPE string 
    ASSERT $value INSIDE ['sent', 'failed', 'queued', 'bounced']
    COMMENT "État actuel de l'envoi du rappel (ex: envoyé, échec, en attente)";
DEFINE FIELD IF NOT EXISTS error_message      ON TABLE reminder_log TYPE option<string>
    COMMENT "Message d'erreur technique en cas d'échec de l'envoi";
DEFINE FIELD IF NOT EXISTS sent_at            ON TABLE reminder_log TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de l'envoi ou de la tentative d'envoi";

-- 5. Méthodes d'Accès (Authentification Native Lyxal v3.0)
DEFINE ACCESS IF NOT EXISTS ack_signer ON DATABASE
    TYPE RECORD
    USER user
    AUTHENTICATE {
        RETURN SELECT * FROM user WHERE email = $email AND pass::verify(password, $pass);
    }
    DURATION 
        FOR TOKEN 30d, 
        FOR SESSION 1d
    COMMENT "Portée d'authentification v3.0 pour les signataires Lyxal";
