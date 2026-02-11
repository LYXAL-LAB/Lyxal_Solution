-- ============================================================
-- ENTITY: signed (Relation Immuable)
-- DESCRIPTION: Preuves cryptographiques de lecture
-- ============================================================

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

