DEFINE TABLE IF NOT EXISTS expected_signers TYPE NORMAL SCHEMAFULL
    COMMENT "Suit les signataires attendus pour les documents afin de surveiller les taux de complétion"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE expected_signers 
    TYPE string
    COMMENT "Identifiant du document";

DEFINE FIELD IF NOT EXISTS email ON TABLE expected_signers 
    TYPE string
    COMMENT "Email du signataire attendu";

DEFINE FIELD IF NOT EXISTS added_at ON TABLE expected_signers 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date d'ajout du signataire";

DEFINE FIELD IF NOT EXISTS added_by ON TABLE expected_signers 
    TYPE string
    COMMENT "Utilisateur ayant ajouté ce signataire";

DEFINE FIELD IF NOT EXISTS notes ON TABLE expected_signers 
    TYPE string
    COMMENT "Notes internes optionnelles";

DEFINE FIELD IF NOT EXISTS name ON TABLE expected_signers 
    TYPE string 
    DEFAULT ''
    COMMENT "Nom d'affichage optionnel pour les emails de relance personnalisés";

DEFINE INDEX IF NOT EXISTS idx_expected_signers_doc_id ON TABLE expected_signers 
    COLUMNS doc_id
    COMMENT "Index sur l'identifiant du document";

DEFINE INDEX IF NOT EXISTS idx_expected_signers_email ON TABLE expected_signers 
    COLUMNS email
    COMMENT "Index sur l'email";

DEFINE INDEX IF NOT EXISTS unique_doc_email ON TABLE expected_signers 
    COLUMNS doc_id, email UNIQUE
    COMMENT "Unicité du couple document/email";
