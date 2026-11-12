-- ============================================================================
-- TABLE  : storage_reclaim
-- MODULE : lyxal_storage
-- RÔLE   : Préfixes d'octets à retirer du support
-- ============================================================================
-- Une ligne par bucket supprimé, écrite dans la transaction de la suppression par l'événement
-- storage_bucket_reclaim (y compris quand le bucket part avec son organisation, dont les fiches
-- sont supprimées en cascade), et une ligne par envoi reprenable qui n'est plus en cours (dossier
-- de ses parties, événement storage_object_upload_parts). Le worker retire les octets du
-- préfixe, puis la ligne (fn::storage_reclaim_list, fn::storage_reclaim_done). Aucune écriture
-- directe.

DEFINE TABLE OVERWRITE storage_reclaim
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, delete WHERE fn::storage_can({ action: "worker" })
        FOR create, update NONE
    COMMENT "Préfixes d'octets à retirer du support";

DEFINE FIELD OVERWRITE backend ON TABLE storage_reclaim
    TYPE string
    READONLY
    COMMENT "Support";

DEFINE FIELD OVERWRITE prefix ON TABLE storage_reclaim
    TYPE string
    READONLY
    COMMENT "Préfixe des octets à retirer : <portée>/<clé du bucket>, ou <emplacement d'un fichier>.parts";

DEFINE FIELD OVERWRITE created_at ON TABLE storage_reclaim
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Inscription";

DEFINE INDEX OVERWRITE storage_reclaim_created ON TABLE storage_reclaim FIELDS created_at;
