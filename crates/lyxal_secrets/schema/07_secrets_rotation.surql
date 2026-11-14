-- ============================================================================
-- TABLE  : secrets_rotation
-- MODULE : lyxal_secrets
-- RÔLE   : Rotation d'un secret en quatre étapes (création, installation, test, bascule)
-- ============================================================================
-- Une rotation en cours au plus par secret (index unique sur active_slot). États : started →
-- created (nouvelle valeur écrite en version pending) → installed (activée chez le service) →
-- tested (vérifiée) → succeeded (current passe sur la nouvelle version) ; failed ou cancelled à
-- toute étape (la version courante reste en service). Le worker réserve une rotation
-- (jeton lease, échéance locked_until) avant d'y travailler ; seul le détenteur d'une réservation
-- valide la fait avancer, et chaque étape la renouvelle. Transitions gardées par secrets_rotation_guard
-- (fn::secrets_rotation_refusal), qui vaut aussi pour une écriture directe. Jamais de valeur.

DEFINE TABLE OVERWRITE secrets_rotation
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::secrets_can({ action: "list", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create, update WHERE fn::secrets_can({ action: "write", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "purge", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Rotation d'un secret en quatre étapes ; une seule en cours par secret ; jamais de valeur";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_rotation
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du secret (NONE : installation)";

DEFINE FIELD OVERWRITE secret ON TABLE secrets_rotation
    TYPE record<secrets_secret>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Secret en rotation ; ses rotations partent avec lui";

DEFINE FIELD OVERWRITE state ON TABLE secrets_rotation
    TYPE string
    DEFAULT "started"
    ASSERT $value IN ["started", "created", "installed", "tested", "succeeded", "failed", "cancelled"]
    COMMENT "État : started, created, installed, tested, succeeded, failed, cancelled";

DEFINE FIELD OVERWRITE active_slot ON TABLE secrets_rotation
    TYPE string
    VALUE IF $this.state IN ["started", "created", "installed", "tested"] { "active" } ELSE { <string> $this.id }
    COMMENT "Une seule rotation en cours par secret (index unique)";

DEFINE FIELD OVERWRITE emergency ON TABLE secrets_rotation
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Rotation d'urgence : la version courante a été désactivée au démarrage";

DEFINE FIELD OVERWRITE reason ON TABLE secrets_rotation
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 512
    READONLY
    COMMENT "Motif donné au démarrage";

DEFINE FIELD OVERWRITE pending_number ON TABLE secrets_rotation
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 1
    COMMENT "Numéro de la nouvelle version (étiquette pending), posé à l'étape created";

DEFINE FIELD OVERWRITE previous_number ON TABLE secrets_rotation
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 1
    READONLY
    COMMENT "Version courante au démarrage (NONE : aucune)";

DEFINE FIELD OVERWRITE attempts ON TABLE secrets_rotation
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= 4
    COMMENT "Échecs constatés (3 nouveaux essais au plus)";

DEFINE FIELD OVERWRITE next_attempt_at ON TABLE secrets_rotation
    TYPE option<datetime>
    COMMENT "Prochain essai après un échec (NONE : tout de suite)";

DEFINE FIELD OVERWRITE locked_until ON TABLE secrets_rotation
    TYPE option<datetime>
    COMMENT "Réservée par un worker jusqu'à cette date";

DEFINE FIELD OVERWRITE lease ON TABLE secrets_rotation
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 64)
    COMMENT "Jeton de la réservation en cours : seul son détenteur fait avancer la rotation";

DEFINE FIELD OVERWRITE lease_ttl ON TABLE secrets_rotation
    TYPE option<duration>
    COMMENT "Durée de la réservation, renouvelée à chaque étape franchie";

DEFINE FIELD OVERWRITE last_error ON TABLE secrets_rotation
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Code de la dernière erreur, jamais de valeur";

DEFINE FIELD OVERWRITE started_by ON TABLE secrets_rotation
    TYPE option<string>
    READONLY
    COMMENT "Identité ou application qui a demandé la rotation (NONE : worker ou session système)";

DEFINE FIELD OVERWRITE started_at ON TABLE secrets_rotation
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Démarrage";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_rotation
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE FIELD OVERWRITE finished_at ON TABLE secrets_rotation
    TYPE option<datetime>
    COMMENT "Fin (succeeded, failed, cancelled)";

DEFINE INDEX OVERWRITE secrets_rotation_active ON TABLE secrets_rotation FIELDS secret, active_slot UNIQUE;
DEFINE INDEX OVERWRITE secrets_rotation_due ON TABLE secrets_rotation FIELDS active_slot, next_attempt_at;
