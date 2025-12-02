DEFINE TABLE IF NOT EXISTS documents TYPE NORMAL SCHEMAFULL
    COMMENT "Stocke les métadonnées du document incluant l'URL, la somme de contrôle et la description"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE documents 
    TYPE string
    COMMENT "Identifiant du document (référence signatures.doc_id)";

DEFINE FIELD IF NOT EXISTS title ON TABLE documents 
    TYPE string 
    DEFAULT ''
    COMMENT "Titre optionnel du document";

DEFINE FIELD IF NOT EXISTS url ON TABLE documents 
    TYPE string 
    DEFAULT ''
    COMMENT "URL ou chemin vers le document";

DEFINE FIELD IF NOT EXISTS checksum ON TABLE documents 
    TYPE string 
    DEFAULT ''
    COMMENT "Somme de contrôle/hash du document pour la vérification d'intégrité";

DEFINE FIELD IF NOT EXISTS checksum_algorithm ON TABLE documents 
    TYPE string 
    DEFAULT 'SHA-256' 
    ASSERT $value INSIDE ['SHA-256', 'SHA-512', 'MD5']
    COMMENT "Algorithme utilisé pour la somme de contrôle (SHA-256, SHA-512 ou MD5)";

DEFINE FIELD IF NOT EXISTS description ON TABLE documents 
    TYPE string 
    DEFAULT ''
    COMMENT "Description optionnelle du document";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE documents 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Horodatage de la création des métadonnées";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE documents 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Horodatage de la dernière mise à jour";

DEFINE FIELD IF NOT EXISTS created_by ON TABLE documents 
    TYPE string 
    DEFAULT ''
    COMMENT "Email de l'utilisateur ayant créé le document";

DEFINE FIELD IF NOT EXISTS deleted_at ON TABLE documents 
    TYPE datetime
    COMMENT "Horodatage de la suppression logique du document. NULL signifie actif.";

DEFINE INDEX IF NOT EXISTS idx_documents_created_at ON TABLE documents 
    COLUMNS created_at
    COMMENT "Index sur la date de création";

DEFINE INDEX IF NOT EXISTS idx_documents_deleted_at ON TABLE documents 
    COLUMNS deleted_at
    COMMENT "Index sur la date de suppression";
