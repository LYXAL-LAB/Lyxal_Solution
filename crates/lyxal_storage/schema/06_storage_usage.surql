-- ============================================================================
-- TABLE  : storage_usage
-- MODULE : lyxal_storage
-- RÔLE   : Volume tenu à jour par portée et par bucket
-- ============================================================================
-- Une ligne par portée (storage_usage:[<portée>]) et une par bucket
-- (storage_usage:[<portée>, <clé du bucket>]). Tenue par l'événement storage_object_usage dans la
-- transaction de chaque écriture d'une fiche (ouverture, fin d'écriture, quarantaine,
-- suppression, expiration, purge, suppression avec l'organisation), y compris une écriture
-- directe : le quota lit ces compteurs au lieu de relire les fiches. Contrôle de cohérence :
-- fn::storage_usage_verify. Aucune écriture directe.

DEFINE TABLE OVERWRITE storage_usage
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::storage_can({ action: "read", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Volume tenu à jour par portée et par bucket (fichiers disponibles ou en quarantaine, écritures en attente)";

DEFINE FIELD OVERWRITE tenant ON TABLE storage_usage
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE storage_usage
    TYPE string
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE bucket ON TABLE storage_usage
    TYPE option<record<storage_bucket>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Bucket (NONE : ligne de la portée)";

DEFINE FIELD OVERWRITE objects ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Fichiers disponibles ou en quarantaine";

DEFINE FIELD OVERWRITE bytes ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Leur volume (taille réelle), en octets";

DEFINE FIELD OVERWRITE reserved ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Tailles annoncées des écritures en attente, en octets";

DEFINE FIELD OVERWRITE updated_at ON TABLE storage_usage
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";
