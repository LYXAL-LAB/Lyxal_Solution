-- ============================================================
-- ENTITY: document
-- DESCRIPTION: Référentiel des documents à signer
-- ============================================================

DEFINE TABLE IF NOT EXISTS document TYPE NORMAL SCHEMAFULL
    COMMENT "Référentiel des documents à signer"
    PERMISSIONS 
        FOR select FULL
        FOR create, update, delete WHERE $auth.admin = true;

DEFINE FIELD IF NOT EXISTS tenant_id          ON TABLE document TYPE string
    COMMENT "Identifiant de l'organisation ou de la partition de données";
DEFINE FIELD IF NOT EXISTS title              ON TABLE document TYPE string
    COMMENT "Titre public du document";
DEFINE FIELD IF NOT EXISTS description        ON TABLE document TYPE option<string>
    COMMENT "Description détaillée ou résumé du contenu du document";
DEFINE FIELD IF NOT EXISTS url                ON TABLE document TYPE string
    COMMENT "Lien vers le fichier source (PDF, Page web, etc.)";
DEFINE FIELD IF NOT EXISTS checksum           ON TABLE document TYPE string
    COMMENT "Empreinte numérique (hash) de référence du document original";
DEFINE FIELD IF NOT EXISTS checksum_algorithm  ON TABLE document TYPE string DEFAULT 'SHA-256' 
    ASSERT $value INSIDE ['SHA-256', 'SHA-512', 'MD5']
    COMMENT "Algorithme utilisé pour calculer l'empreinte numérique (ex: SHA-256)";
DEFINE FIELD IF NOT EXISTS metadata           ON TABLE document TYPE object DEFAULT {}
    COMMENT "Données additionnelles structurées (ex: tags, versioning)";
DEFINE FIELD IF NOT EXISTS created_by         ON TABLE document TYPE record<user>
    COMMENT "Référence de l'utilisateur administrateur ayant créé le document";
DEFINE FIELD IF NOT EXISTS created_at         ON TABLE document TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la création du document";
DEFINE FIELD IF NOT EXISTS updated_at         ON TABLE document TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la dernière modification des métadonnées";

DEFINE INDEX IF NOT EXISTS idx_document_tenant ON TABLE document FIELDS tenant_id
    COMMENT "Index de partitionnement par organisation pour les documents";

