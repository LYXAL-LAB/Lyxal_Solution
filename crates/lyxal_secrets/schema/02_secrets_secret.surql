-- ============================================================================
-- TABLE  : secrets_secret
-- MODULE : lyxal_secrets
-- RÔLE   : Fiche d'un secret : chemin, type, propriétaire, consommateurs, étiquettes, état
-- ============================================================================
-- Aucune valeur ici : les valeurs scellées sont dans secrets_version. Les transitions d'état et
-- les champs figés sont gardés par secrets_secret_update_guard (fn::secrets_secret_update_refusal),
-- qui vaut aussi pour une écriture directe dans la table.

DEFINE TABLE OVERWRITE secrets_secret
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "list", tenant: tenant })
            OR fn::secrets_can({ action: "read_value", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create WHERE fn::secrets_can({ action: "write", tenant: tenant })
        FOR update WHERE fn::secrets_can({ action: "write", tenant: tenant })
            OR fn::secrets_can({ action: "delete", tenant: tenant })
            OR fn::secrets_can({ action: "restore", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "purge", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Fiche d'un secret : chemin, type, propriétaire, consommateurs, étiquettes, état ; jamais de valeur";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_secret
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE secrets_secret
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité du chemin : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE path ON TABLE secrets_secret
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_storage_path($value, NONE, true, 256).value == $value
    COMMENT "Chemin du secret (notification/smtp/password), unique dans sa portée";

DEFINE FIELD OVERWRITE kind ON TABLE secrets_secret
    TYPE string
    ASSERT $value IN ["api_key", "password", "token", "oauth_client", "certificate", "private_key", "signing_key", "connection_string", "generic"]
    COMMENT "Type de secret (OWASP : métadonnées)";

DEFINE FIELD OVERWRITE description ON TABLE secrets_secret
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Usage du secret";

DEFINE FIELD OVERWRITE owner ON TABLE secrets_secret
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a créé le secret (NONE : session système, compte de service ou identité supprimée)";

DEFINE FIELD OVERWRITE owner_application ON TABLE secrets_secret
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE UNSET
    COMMENT "Application qui a créé le secret sans identité (compte de service) ; NONE sinon";

DEFINE FIELD OVERWRITE contact ON TABLE secrets_secret
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 254
    COMMENT "Personne ou équipe à prévenir (réponse à incident)";

DEFINE FIELD OVERWRITE consumers ON TABLE secrets_secret
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 20 AND array::all($value, |$c| string::len($c) >= 1 AND string::len($c) <= 128)
    COMMENT "Consommateurs prévus (modules ou client_id d'applications) ; vide : tout programme autorisé";

DEFINE FIELD OVERWRITE tags ON TABLE secrets_secret
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 20 AND array::all($value, |$t| fn::validation_slug($t, 64).valid)
    COMMENT "Étiquettes libres de classement";

DEFINE FIELD OVERWRITE metadata ON TABLE secrets_secret
    TYPE object
    FLEXIBLE
    DEFAULT {}
    ASSERT array::len(object::keys($value)) <= 32
    COMMENT "Métadonnées libres (32 clés au plus), jamais de valeur secrète";

DEFINE FIELD OVERWRITE visibility ON TABLE secrets_secret
    TYPE string
    ASSERT $value IN ["restricted", "revealable"]
    COMMENT "restricted : seuls les programmes lisent la valeur ; revealable : un humain la lit avec le double facteur";

DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_secret
    TYPE option<datetime>
    COMMENT "Échéance : un secret expiré est refusé à la lecture";

DEFINE FIELD OVERWRITE rotation_period ON TABLE secrets_secret
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1h AND $value <= 3650d)
    COMMENT "Période de rotation prévue";

DEFINE FIELD OVERWRITE next_rotation_at ON TABLE secrets_secret
    TYPE option<datetime>
    COMMENT "Prochaine rotation : date de la version courante plus la période";

DEFINE FIELD OVERWRITE state ON TABLE secrets_secret
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled", "deleted"]
    COMMENT "État : active, disabled, deleted (suppression douce, purge à purge_at)";

DEFINE FIELD OVERWRITE state_before_delete ON TABLE secrets_secret
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["active", "disabled"]
    COMMENT "État rendu par une restauration";

DEFINE FIELD OVERWRITE deleted_at ON TABLE secrets_secret
    TYPE option<datetime>
    COMMENT "Suppression douce";

DEFINE FIELD OVERWRITE purge_at ON TABLE secrets_secret
    TYPE option<datetime>
    COMMENT "Date de purge d'un secret supprimé";

DEFINE FIELD OVERWRITE labels ON TABLE secrets_secret
    TYPE object
    FLEXIBLE
    DEFAULT {}
    ASSERT array::len(object::keys($value)) <= 20
        AND array::all(object::entries($value), |$e| fn::validation_slug($e[0], 32).valid AND type::is_int($e[1]) AND $e[1] >= 1)
    COMMENT "Étiquettes de version ({ current: 3, previous: 2 }) : une étiquette sur une seule version, 20 au plus";

DEFINE FIELD OVERWRITE latest_version ON TABLE secrets_secret
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Numéro de la dernière version créée (0 : aucune)";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_secret
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_secret
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE secrets_secret_path ON TABLE secrets_secret FIELDS scope_key, path UNIQUE;
DEFINE INDEX OVERWRITE secrets_secret_state ON TABLE secrets_secret FIELDS state, purge_at;
