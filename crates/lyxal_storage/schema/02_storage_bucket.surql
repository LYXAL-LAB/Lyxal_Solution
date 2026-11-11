-- ============================================================================
-- TABLE  : storage_bucket
-- MODULE : lyxal_storage
-- RÔLE   : Buckets : ensembles de fichiers et leurs règles
-- ============================================================================
-- Un bucket appartient à l'installation ou à une organisation. Son nom est unique dans sa
-- portée. Il n'est supprimé que vide, sauf avec son organisation (garde storage_object_bucket_guard).
-- Ses octets sont sur un support nommé, sous le préfixe <portée>/<clé du bucket>.

DEFINE TABLE OVERWRITE storage_bucket
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::storage_can({ action: "read", tenant: tenant })
        FOR create, update, delete WHERE fn::storage_can({ action: "manage", tenant: tenant })
    COMMENT "Buckets : ensembles de fichiers et leurs règles";

DEFINE FIELD OVERWRITE tenant ON TABLE storage_bucket
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE storage_bucket
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité du nom";

DEFINE FIELD OVERWRITE name ON TABLE storage_bucket
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_bucket_name($value, 3, 63).value == $value
    COMMENT "Nom ([a-z0-9-], 3 à 63 caractères), unique dans sa portée";

DEFINE FIELD OVERWRITE description ON TABLE storage_bucket
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Usage du bucket";

DEFINE FIELD OVERWRITE max_object_size ON TABLE storage_bucket
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 5368709120)
    COMMENT "Taille maximale d'un fichier, en octets (NONE : celle des réglages)";

DEFINE FIELD OVERWRITE allowed_types ON TABLE storage_bucket
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 100
    COMMENT "Types MIME acceptés (vide : tous)";

DEFINE FIELD OVERWRITE backend ON TABLE storage_bucket
    TYPE string
    DEFAULT "default"
    READONLY
    ASSERT fn::validation_snake_case_name($value, 1, 64).value == $value
    COMMENT "Nom du support qui porte les octets du bucket, fixé à la création";

DEFINE FIELD OVERWRITE readonly ON TABLE storage_bucket
    TYPE bool
    DEFAULT false
    COMMENT "Bucket en lecture seule : aucune écriture ni suppression de fichier";

DEFINE FIELD OVERWRITE created_at ON TABLE storage_bucket
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE storage_bucket
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE storage_bucket_name ON TABLE storage_bucket FIELDS scope_key, name UNIQUE;
