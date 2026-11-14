-- ============================================================================
-- TABLE  : secrets_version
-- MODULE : lyxal_secrets
-- RÔLE   : Version d'un secret : numéro, enveloppe scellée, identifiant de clé, état
-- ============================================================================
-- L'enveloppe (enc:v2, scellée par lyxal_crypto) n'est lisible par aucun utilisateur : seule la
-- session système l'obtient, par un ticket de lecture (fn::secrets_read_envelope). Elle n'est
-- jamais modifiée, sauf rescellée par la session système après une rotation de clé
-- (fn::secrets_version_reseal) ou effacée à la destruction (garde secrets_version_update_guard).
-- Contexte de scellement : SecretContext::with_tenant(<organisation> ou "lyxal_installation",
-- "lyxal_secrets", "secrets_version", "<clé du secret>:<numéro>", "value").

DEFINE TABLE OVERWRITE secrets_version
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "list", tenant: tenant })
            OR fn::secrets_can({ action: "read_value", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create WHERE fn::secrets_can({ action: "write", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR update WHERE fn::secrets_can({ action: "write", tenant: tenant })
            OR fn::secrets_can({ action: "delete", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "purge", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Version d'un secret : numéro, enveloppe scellée (illisible pour tout utilisateur), identifiant de clé, état";

DEFINE FIELD OVERWRITE secret ON TABLE secrets_version
    TYPE record<secrets_secret>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Secret ; ses versions sont supprimées avec lui (purge)";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_version
    TYPE option<record<auth_organization>>
    READONLY
    COMMENT "Organisation du secret (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE secrets_version
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée";

DEFINE FIELD OVERWRITE number ON TABLE secrets_version
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Numéro de version (1, 2, 3…), lié au contexte de scellement";

DEFINE FIELD OVERWRITE envelope ON TABLE secrets_version
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 1398211)
    PERMISSIONS FOR select NONE
    COMMENT "Valeur scellée (enc:v2:<key_id>:<payload>) ; illisible pour tout utilisateur ; NONE après destruction";

DEFINE FIELD OVERWRITE key_id ON TABLE secrets_version
    TYPE option<string>
    ASSERT ($value IS NONE AND $this.envelope IS NONE)
        OR ($value IS NOT NONE AND $this.envelope IS NOT NONE AND string::split($this.envelope, ":")[2] == $value)
    COMMENT "Identifiant de la clé qui a scellé la version (celui de l'enveloppe)";

DEFINE FIELD OVERWRITE keys ON TABLE secrets_version
    TYPE option<array<string>>
    ASSERT $value IS NONE OR (array::len($value) <= 200 AND array::all($value, |$k| string::len($k) >= 1 AND string::len($k) <= 128))
    COMMENT "Noms des clés d'une valeur JSON, sans leurs valeurs (NONE : valeur non JSON)";

DEFINE FIELD OVERWRITE state ON TABLE secrets_version
    TYPE string
    DEFAULT "enabled"
    ASSERT $value IN ["enabled", "disabled", "destroyed"]
    COMMENT "État : enabled, disabled (réversible), destroyed (enveloppe effacée, irréversible)";

DEFINE FIELD OVERWRITE created_by ON TABLE secrets_version
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a écrit la version (NONE : session système, compte de service ou identité supprimée)";

DEFINE FIELD OVERWRITE created_by_application ON TABLE secrets_version
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE UNSET
    COMMENT "Application qui a écrit la version sans identité ; NONE sinon";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_version
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE destroyed_at ON TABLE secrets_version
    TYPE option<datetime>
    COMMENT "Destruction";

DEFINE FIELD OVERWRITE resealed_at ON TABLE secrets_version
    TYPE option<datetime>
    COMMENT "Dernier rescellement (rotation de clé)";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_version
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE secrets_version_number ON TABLE secrets_version FIELDS secret, number UNIQUE;
DEFINE INDEX OVERWRITE secrets_version_key ON TABLE secrets_version FIELDS scope_key, key_id;
