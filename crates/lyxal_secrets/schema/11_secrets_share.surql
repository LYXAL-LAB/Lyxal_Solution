-- ============================================================================
-- TABLE  : secrets_share
-- MODULE : lyxal_secrets
-- RÔLE   : Partage à usage unique : copie scellée d'une valeur, ouverte par un lien
-- ============================================================================
-- La copie (valeur d'un secret ou texte saisi) est scellée par le service Rust avec une clé
-- aléatoire que la base ne voit jamais : seule son empreinte (SHA-256) est gardée, la clé
-- n'existe que dans le lien. Ouvertures limitées (max_views), échéance, mot de passe facultatif
-- (haché Argon2id par le service). États : active → consumed (dernière ouverture), expired
-- (échéance), revoked (retrait), destroyed (5 essais faux) ; l'enveloppe, l'empreinte et le
-- hachage sont effacés dès qu'un partage n'est plus actif. Écritures gardées par
-- secrets_share_guard. Jamais de valeur au journal ni sur le bus.

DEFINE TABLE OVERWRITE secrets_share
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (created_identity IS NOT NONE AND created_identity = $auth.identity)
            OR (created_application IS NOT NONE AND created_application = $auth.application)
            OR fn::secrets_can({ action: "share", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create WHERE fn::secrets_can({ action: "share", tenant: tenant })
        FOR update WHERE (created_identity IS NOT NONE AND created_identity = $auth.identity)
            OR (created_application IS NOT NONE AND created_application = $auth.application)
            OR fn::secrets_can({ action: "share", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR delete WHERE fn::secrets_can({ action: "worker", tenant: tenant })
    COMMENT "Partage à usage unique : copie scellée par une clé que seul le lien porte ; jamais de valeur lisible";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_share
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation) ; ses partages partent avec elle";

DEFINE FIELD OVERWRITE created_identity ON TABLE secrets_share
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    READONLY
    COMMENT "Auteur (identité)";

DEFINE FIELD OVERWRITE created_application ON TABLE secrets_share
    TYPE option<record<auth_application>>
    REFERENCE ON DELETE UNSET
    READONLY
    COMMENT "Auteur (application)";

DEFINE FIELD OVERWRITE secret ON TABLE secrets_share
    TYPE option<record<secrets_secret>>
    REFERENCE ON DELETE UNSET
    READONLY
    COMMENT "Secret copié (NONE : texte saisi) ; la copie ne suit pas les changements du secret";

DEFINE FIELD OVERWRITE number ON TABLE secrets_share
    TYPE option<int>
    READONLY
    ASSERT $value IS NONE OR $value >= 1
    COMMENT "Version copiée";

DEFINE FIELD OVERWRITE envelope ON TABLE secrets_share
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "enc:v2:") AND string::len($value) <= 1398211)
    PERMISSIONS FOR select NONE
    COMMENT "Copie scellée par la clé du lien (enc:v2) ; illisible pour tout utilisateur ; effacée à la fin";

DEFINE FIELD OVERWRITE key_fingerprint ON TABLE secrets_share
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) = 64
    PERMISSIONS FOR select NONE
    COMMENT "Empreinte SHA-256 (hexadécimal) de la clé du lien ; la clé n'est jamais gardée";

DEFINE FIELD OVERWRITE passphrase_hash ON TABLE secrets_share
    TYPE option<string>
    ASSERT $value IS NONE OR (string::starts_with($value, "$argon2id$") AND string::len($value) <= 512)
    PERMISSIONS FOR select NONE
    COMMENT "Hachage Argon2id du mot de passe facultatif";

DEFINE FIELD OVERWRITE protected ON TABLE secrets_share
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Vrai si un mot de passe est demandé à l'ouverture";

DEFINE FIELD OVERWRITE members_only ON TABLE secrets_share
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Ouverture réservée à un membre connecté de l'organisation";

DEFINE FIELD OVERWRITE note ON TABLE secrets_share
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    READONLY
    COMMENT "Note de l'auteur (destinataire, motif), jamais de valeur";

DEFINE FIELD OVERWRITE max_views ON TABLE secrets_share
    TYPE int
    DEFAULT 1
    READONLY
    ASSERT $value >= 1 AND $value <= 10
    COMMENT "Ouvertures permises (1 à 10)";

DEFINE FIELD OVERWRITE views ON TABLE secrets_share
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= 10
    COMMENT "Ouvertures faites";

DEFINE FIELD OVERWRITE failed_attempts ON TABLE secrets_share
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= 5
    COMMENT "Essais faux (clé ou mot de passe) ; au 5e, le partage est détruit";

DEFINE FIELD OVERWRITE state ON TABLE secrets_share
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "consumed", "expired", "revoked", "destroyed"]
    COMMENT "État : active, consumed, expired, revoked, destroyed";

DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_share
    TYPE datetime
    READONLY
    COMMENT "Échéance";

DEFINE FIELD OVERWRITE created_at ON TABLE secrets_share
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE last_opened_at ON TABLE secrets_share
    TYPE option<datetime>
    COMMENT "Dernière ouverture";

DEFINE FIELD OVERWRITE finished_at ON TABLE secrets_share
    TYPE option<datetime>
    COMMENT "Fin (épuisé, échu, retiré, détruit)";

DEFINE INDEX OVERWRITE secrets_share_tenant ON TABLE secrets_share FIELDS tenant, state;
DEFINE INDEX OVERWRITE secrets_share_expiry ON TABLE secrets_share FIELDS state, expires_at;
