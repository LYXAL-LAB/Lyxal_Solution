DEFINE TABLE IF NOT EXISTS signatures TYPE NORMAL SCHEMAFULL
    COMMENT "Table principale stockant les preuves de lecture signées cryptographiquement"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE signatures 
    TYPE string
    COMMENT "Identifiant du document signé";

DEFINE FIELD IF NOT EXISTS user_sub ON TABLE signatures 
    TYPE string
    COMMENT "Identifiant unique de l'utilisateur (Subject ID OAuth)";

DEFINE FIELD IF NOT EXISTS user_email ON TABLE signatures 
    TYPE string
    COMMENT "Email de l'utilisateur au moment de la signature";

DEFINE FIELD IF NOT EXISTS user_name ON TABLE signatures 
    TYPE string
    COMMENT "Nom de l'utilisateur au moment de la signature";

DEFINE FIELD IF NOT EXISTS signed_at ON TABLE signatures 
    TYPE datetime
    COMMENT "Horodatage précis de la signature";

DEFINE FIELD IF NOT EXISTS payload_hash ON TABLE signatures 
    TYPE string
    COMMENT "Hash du payload signé";

DEFINE FIELD IF NOT EXISTS signature ON TABLE signatures 
    TYPE string
    COMMENT "Signature cryptographique Ed25519 (encodée en base64)";

DEFINE FIELD IF NOT EXISTS nonce ON TABLE signatures 
    TYPE string
    COMMENT "Nonce cryptographique pour éviter les attaques par rejeu";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE signatures 
    TYPE datetime 
    DEFAULT time::now()
    -- Protection contre la modification (équivalent du trigger PostgreSQL)
    ASSERT $before == NONE OR $value == $before
    COMMENT "Date de création de l'enregistrement (Immutable)";

DEFINE FIELD IF NOT EXISTS referer ON TABLE signatures 
    TYPE string
    COMMENT "URL de la page où la signature a été effectuée";

DEFINE FIELD IF NOT EXISTS prev_hash ON TABLE signatures 
    TYPE string
    COMMENT "Hash de la signature précédente (pour la chaîne de blocs/audit)";

DEFINE FIELD IF NOT EXISTS doc_checksum ON TABLE signatures 
    TYPE string
    COMMENT "Somme de contrôle SHA-256 du document au moment de la signature";

DEFINE FIELD IF NOT EXISTS hash_version ON TABLE signatures 
    TYPE int 
    DEFAULT 1
    COMMENT "Version de l'algorithme de hachage utilisé (1=legacy, 2=canonical)";

DEFINE FIELD IF NOT EXISTS doc_deleted_at ON TABLE signatures 
    TYPE datetime
    COMMENT "Date de suppression du document original (permet de garder l'historique)";

DEFINE INDEX IF NOT EXISTS idx_signatures_user ON TABLE signatures 
    COLUMNS user_sub
    COMMENT "Index par utilisateur";

DEFINE INDEX IF NOT EXISTS idx_signatures_doc_id ON TABLE signatures 
    COLUMNS doc_id
    COMMENT "Index par document";

DEFINE INDEX IF NOT EXISTS idx_signatures_doc_checksum ON TABLE signatures 
    COLUMNS doc_checksum
    COMMENT "Index par version de document";

DEFINE INDEX IF NOT EXISTS idx_signatures_hash_version ON TABLE signatures 
    COLUMNS hash_version
    COMMENT "Index par version de hash";

DEFINE INDEX IF NOT EXISTS idx_signatures_doc_deleted_at ON TABLE signatures 
    COLUMNS doc_deleted_at
    COMMENT "Index pour filtrer les documents supprimés";

DEFINE INDEX IF NOT EXISTS unique_doc_user ON TABLE signatures 
    COLUMNS doc_id, user_sub UNIQUE
    COMMENT "Un utilisateur ne peut signer qu'une seule fois un document";
