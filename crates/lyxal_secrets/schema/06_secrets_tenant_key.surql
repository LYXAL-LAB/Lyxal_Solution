-- ============================================================================
-- TABLE  : secrets_tenant_key
-- MODULE : lyxal_secrets
-- RÔLE   : Clé de chiffrement d'une organisation, scellée par la clé maîtresse de l'hôte
-- ============================================================================
-- Aucune écriture utilisateur et clé scellée illisible : seule la session système (service Rust) écrit cette table,
-- par les fonctions fn::secrets_tenant_key_*. Une clé est tirée par le service (rand_core::OsRng),
-- scellée par la clé maîtresse (contexte with_tenant(<organisation>, "lyxal_secrets",
-- "secrets_tenant_key", <key_id>, "key")) et rangée ici. États : active (scelle les nouvelles
-- versions, une seule par portée) → decrypt_only (relit seulement, après une rotation) →
-- destroyed (matière effacée, quand plus aucune version ne l'utilise). Les clés d'une
-- organisation partent avec elle : ses secrets ne s'ouvrent plus.

DEFINE TABLE OVERWRITE secrets_tenant_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Identifiant et état visibles de qui écrit ou lit dans la portée (contrôle de la clé active) ;
        -- la clé scellée reste illisible (champ wrapped) ; aucune écriture utilisateur
        FOR select WHERE fn::secrets_can({ action: "write", tenant: tenant })
            OR fn::secrets_can({ action: "list", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Clé de chiffrement d'une organisation, scellée par la clé maîtresse ; aucune écriture utilisateur, clé scellée illisible";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_tenant_key
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation) ; ses clés sont supprimées avec elle";

DEFINE FIELD OVERWRITE scope_key ON TABLE secrets_tenant_key
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE key_id ON TABLE secrets_tenant_key
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Identifiant de la clé (KeyId de lyxal_crypto), présent dans chaque enveloppe qu'elle scelle";

DEFINE FIELD OVERWRITE wrapped ON TABLE secrets_tenant_key
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 4096)
    PERMISSIONS FOR select NONE
    COMMENT "Clé scellée par la clé maîtresse (enc:v2) ; illisible pour tout utilisateur ; NONE après destruction";

DEFINE FIELD OVERWRITE master_key_id ON TABLE secrets_tenant_key
    TYPE option<string>
    VALUE IF $this.wrapped IS NONE { NONE } ELSE { string::split($this.wrapped, ":")[2] }
    COMMENT "Identifiant de la clé maîtresse qui a scellé cette clé";

DEFINE FIELD OVERWRITE state ON TABLE secrets_tenant_key
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "decrypt_only", "destroyed"]
    COMMENT "État : active, decrypt_only, destroyed";

DEFINE FIELD OVERWRITE active_slot ON TABLE secrets_tenant_key
    TYPE string
    VALUE IF $this.state = "active" { "active" } ELSE { <string> $this.id }
    COMMENT "Une seule clé active par portée (index unique)";

DEFINE FIELD OVERWRITE requested_by ON TABLE secrets_tenant_key
    TYPE option<string>
    READONLY
    COMMENT "Identité qui a demandé la rotation ayant créé cette clé (NONE : première clé)";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_tenant_key
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE retired_at ON TABLE secrets_tenant_key
    TYPE option<datetime>
    COMMENT "Passage en lecture seule (rotation)";

DEFINE FIELD OVERWRITE rewrapped_at ON TABLE secrets_tenant_key
    TYPE option<datetime>
    COMMENT "Dernier rescellement par une nouvelle clé maîtresse";

DEFINE FIELD OVERWRITE destroyed_at ON TABLE secrets_tenant_key
    TYPE option<datetime>
    COMMENT "Destruction";

DEFINE INDEX OVERWRITE secrets_tenant_key_active ON TABLE secrets_tenant_key FIELDS scope_key, active_slot UNIQUE;
DEFINE INDEX OVERWRITE secrets_tenant_key_id ON TABLE secrets_tenant_key FIELDS key_id UNIQUE;
DEFINE INDEX OVERWRITE secrets_tenant_key_master ON TABLE secrets_tenant_key FIELDS state, master_key_id;
