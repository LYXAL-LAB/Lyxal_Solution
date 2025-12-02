DEFINE TABLE IF NOT EXISTS checksum_verifications TYPE NORMAL SCHEMAFULL
    COMMENT "Suit les tentatives de vérification des sommes de contrôle (checksums) des documents pour le contrôle d'intégrité"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE checksum_verifications 
    TYPE string
    COMMENT "Identifiant du document (clé étrangère vers la table documents)";

DEFINE FIELD IF NOT EXISTS verified_by ON TABLE checksum_verifications 
    TYPE string
    COMMENT "Email de l'utilisateur ayant effectué la vérification";

DEFINE FIELD IF NOT EXISTS verified_at ON TABLE checksum_verifications 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Horodatage de la vérification";

DEFINE FIELD IF NOT EXISTS stored_checksum ON TABLE checksum_verifications 
    TYPE string
    COMMENT "La somme de contrôle de référence stockée dans les métadonnées du document au moment de la vérification";

DEFINE FIELD IF NOT EXISTS calculated_checksum ON TABLE checksum_verifications 
    TYPE string
    COMMENT "La somme de contrôle calculée par l'utilisateur lors de la vérification";

DEFINE FIELD IF NOT EXISTS algorithm ON TABLE checksum_verifications 
    TYPE string 
    ASSERT $value INSIDE ['SHA-256', 'SHA-512', 'MD5']
    COMMENT "Algorithme utilisé pour le calcul de la somme de contrôle (SHA-256, SHA-512 ou MD5)";

DEFINE FIELD IF NOT EXISTS is_valid ON TABLE checksum_verifications 
    TYPE bool
    COMMENT "Vrai si la somme de contrôle calculée correspond à celle stockée";

DEFINE FIELD IF NOT EXISTS error_message ON TABLE checksum_verifications 
    TYPE string
    COMMENT "Message d'erreur optionnel si la vérification a échoué";

DEFINE INDEX IF NOT EXISTS idx_checksum_verifications_doc_id ON TABLE checksum_verifications 
    COLUMNS doc_id
    COMMENT "Index sur l'identifiant du document";

DEFINE INDEX IF NOT EXISTS idx_checksum_verifications_verified_at ON TABLE checksum_verifications 
    COLUMNS verified_at
    COMMENT "Index sur la date de vérification";
