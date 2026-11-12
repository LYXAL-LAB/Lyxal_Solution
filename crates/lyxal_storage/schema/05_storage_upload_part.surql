-- ============================================================================
-- TABLE  : storage_upload_part
-- MODULE : lyxal_storage
-- RÔLE   : Parties reçues d'un envoi reprenable
-- ============================================================================
-- Un envoi reprenable (storage_object.resumable, état pending) reçoit ses octets en plusieurs
-- requêtes. Chaque partie écrite sur le support est inscrite ici ; la position de l'envoi est la
-- somme des tailles. L'index unique (envoi, position) garantit qu'une position n'est inscrite
-- qu'une fois, même par deux requêtes simultanées. Une écriture directe est soumise aux mêmes
-- règles que fn::storage_upload_part_add (garde storage_upload_part_guard). Les lignes sont
-- retirées quand l'envoi n'est plus en cours (événement storage_object_upload_parts).

DEFINE TABLE OVERWRITE storage_upload_part
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::storage_can({ action: "read", tenant: object.tenant })
        FOR create WHERE fn::storage_can({ action: "write", tenant: object.tenant })
        FOR update NONE
        FOR delete WHERE fn::storage_can({ action: "worker" })
    COMMENT "Parties reçues d'un envoi reprenable";

DEFINE FIELD OVERWRITE object ON TABLE storage_upload_part
    TYPE record<storage_object>
    READONLY
    COMMENT "Envoi (fiche à l'état pending)";

DEFINE FIELD OVERWRITE offset ON TABLE storage_upload_part
    TYPE int
    READONLY
    ASSERT $value >= 0
    COMMENT "Position du premier octet de la partie dans le fichier";

DEFINE FIELD OVERWRITE size ON TABLE storage_upload_part
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Taille de la partie, en octets";

DEFINE FIELD OVERWRITE name ON TABLE storage_upload_part
    TYPE uuid
    READONLY
    COMMENT "Nom des octets de la partie sur le support : <emplacement du fichier>.parts/<name>";

DEFINE FIELD OVERWRITE created_at ON TABLE storage_upload_part
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Inscription";

DEFINE INDEX OVERWRITE storage_upload_part_offset ON TABLE storage_upload_part FIELDS object, offset UNIQUE;
