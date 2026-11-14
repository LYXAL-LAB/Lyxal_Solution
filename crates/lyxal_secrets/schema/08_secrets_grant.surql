-- ============================================================================
-- TABLE  : secrets_grant
-- MODULE : lyxal_secrets
-- RÔLE   : Accès temporaire d'une identité ou d'une application à un secret ou un dossier
-- ============================================================================
-- Un accès donne un droit EN PLUS de ceux de lyxal_auth, limité à un chemin (secret exact, ou
-- dossier : path + folder, qui couvre les chemins <path>/…), à des opérations (list,
-- read_value, write, delete) et à une durée ; il ne retire jamais un droit. Créé, retiré et
-- expiré par les fonctions fn::secrets_grant_*, fn::secrets_access_emergency et l'approbation
-- d'une demande ; écritures directes gardées par secrets_grant_guard. Retiré ou échu, il reste
-- lisible jusqu'à son nettoyage par le worker (30 jours après la fin).

DEFINE TABLE OVERWRITE secrets_grant
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Le bénéficiaire voit ses accès (contrôle des droits) ; le gestionnaire des accès voit tout
        FOR select WHERE (subject_identity IS NOT NONE AND subject_identity = $auth.identity)
            OR (subject_application IS NOT NONE AND subject_application = $auth.application)
            OR fn::secrets_can({ action: "access", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create WHERE fn::secrets_can({ action: "access", tenant: tenant })
            OR (emergency AND fn::secrets_can({ action: "emergency", tenant: tenant }))
        FOR update WHERE fn::secrets_can({ action: "access", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Accès temporaire à un secret ou un dossier, en plus des droits lyxal_auth ; jamais de valeur";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_grant
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation ; ses accès partent avec elle";

DEFINE FIELD OVERWRITE subject_identity ON TABLE secrets_grant
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Bénéficiaire : identité membre de l'organisation (ou NONE)";

DEFINE FIELD OVERWRITE subject_application ON TABLE secrets_grant
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Bénéficiaire : application de l'organisation (ou NONE)";

DEFINE FIELD OVERWRITE path ON TABLE secrets_grant
    TYPE string
    READONLY
    ASSERT fn::validation_lyxal_storage_path($value, NONE, true, 256).value == $value
    COMMENT "Chemin d'un secret, ou d'un dossier si folder (sans / final)";

DEFINE FIELD OVERWRITE folder ON TABLE secrets_grant
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Vrai : dossier, couvre les chemins <path>/…";

DEFINE FIELD OVERWRITE actions ON TABLE secrets_grant
    TYPE array<string>
    READONLY
    ASSERT array::len($value) >= 1 AND array::all($value, |$a| $a IN ["list", "read_value", "write", "delete"])
    COMMENT "Opérations permises : list, read_value, write, delete";

DEFINE FIELD OVERWRITE starts_at ON TABLE secrets_grant
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Début";

DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_grant
    TYPE datetime
    READONLY
    COMMENT "Fin ; un accès n'est jamais permanent";

DEFINE FIELD OVERWRITE reason ON TABLE secrets_grant
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 512
    COMMENT "Motif";

DEFINE FIELD OVERWRITE granted_by ON TABLE secrets_grant
    TYPE option<string>
    READONLY
    COMMENT "Identité ou application qui a accordé l'accès (NONE : session système)";

DEFINE FIELD OVERWRITE request ON TABLE secrets_grant
    TYPE option<record<secrets_request>>
    READONLY
    COMMENT "Demande d'accès approuvée à l'origine de l'accès";

DEFINE FIELD OVERWRITE emergency ON TABLE secrets_grant
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Accès d'urgence que le bénéficiaire s'est accordé lui-même";

DEFINE FIELD OVERWRITE revoked_at ON TABLE secrets_grant
    TYPE option<datetime>
    COMMENT "Retrait";

DEFINE FIELD OVERWRITE revoked_by ON TABLE secrets_grant
    TYPE option<string>
    COMMENT "Identité ou application qui a retiré l'accès";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_grant
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE INDEX OVERWRITE secrets_grant_identity ON TABLE secrets_grant FIELDS tenant, subject_identity;
DEFINE INDEX OVERWRITE secrets_grant_application ON TABLE secrets_grant FIELDS tenant, subject_application;
DEFINE INDEX OVERWRITE secrets_grant_expiry ON TABLE secrets_grant FIELDS expires_at;
