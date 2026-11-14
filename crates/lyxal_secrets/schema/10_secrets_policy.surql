-- ============================================================================
-- TABLE  : secrets_policy
-- MODULE : lyxal_secrets
-- RÔLE   : Protection d'un secret ou d'un dossier : changements soumis à approbation
-- ============================================================================
-- Sur un chemin protégé, les opérations listées (value, rollback, disable, delete, destroy)
-- passent par une demande de changement approuvée ; required_approvals vaut aussi pour les
-- demandes d'accès au chemin, et max_grant_duration borne leur durée. Plusieurs protections
-- couvrant un chemin : la plus exigeante s'applique. La session système et le worker (rotation
-- automatique) ne sont pas soumis aux protections.

DEFINE TABLE OVERWRITE secrets_policy
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Les protections ne sont pas secrètes : visibles des membres de l'organisation
        FOR select WHERE tenant = $auth.organization OR fn::secrets_can({ action: "access", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create, update, delete WHERE fn::secrets_can({ action: "access", tenant: tenant })
    COMMENT "Protection d'un secret ou d'un dossier : changements approuvés, accès demandés bornés";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_policy
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation";

DEFINE FIELD OVERWRITE path ON TABLE secrets_policy
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_storage_path($value, NONE, true, 256).value == $value
    COMMENT "Chemin d'un secret, ou d'un dossier si folder";

DEFINE FIELD OVERWRITE folder ON TABLE secrets_policy
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Vrai : dossier, couvre les chemins <path>/…";

DEFINE FIELD OVERWRITE scope ON TABLE secrets_policy
    TYPE string
    VALUE <string> record::id($this.tenant) + ":" + (IF $this.folder { "d:" } ELSE { "s:" }) + $this.path
    COMMENT "Une protection par chemin et organisation (index unique)";

DEFINE FIELD OVERWRITE required_approvals ON TABLE secrets_policy
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1 AND $value <= 5
    COMMENT "Approbations requises (1 à 5)";

DEFINE FIELD OVERWRITE operations ON TABLE secrets_policy
    TYPE array<string>
    DEFAULT ["value", "rollback", "disable", "delete", "destroy"]
    ASSERT array::all($value, |$o| $o IN ["value", "rollback", "disable", "delete", "destroy"])
    COMMENT "Opérations protégées";

DEFINE FIELD OVERWRITE max_grant_duration ON TABLE secrets_policy
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 5m AND $value <= 90d)
    COMMENT "Durée maximale d'un accès demandé sur ce chemin";

DEFINE FIELD OVERWRITE updated_by ON TABLE secrets_policy
    TYPE option<string>
    COMMENT "Identité ou application qui a posé la protection";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_policy
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE secrets_policy_scope ON TABLE secrets_policy FIELDS scope UNIQUE;
DEFINE INDEX OVERWRITE secrets_policy_tenant ON TABLE secrets_policy FIELDS tenant;
