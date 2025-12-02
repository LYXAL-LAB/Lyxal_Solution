-- =================================================================================================
-- TEMPLATE: MFA DEVICE
-- Namespace: NS_IDENTITY_{UUID} / Database: MAIN
-- Ce schéma est appliqué dans le namespace privé de chaque identité.
-- =================================================================================================

DEFINE TABLE IF NOT EXISTS mfadevice TYPE NORMAL SCHEMAFULL
    COMMENT 'Stocke les appareils pour l\'authentification multi-facteurs (MFA).'
    PERMISSIONS NONE; -- Sécurité maximale : Seul le Backend Identity manipule les secrets MFA

    DEFINE FIELD IF NOT EXISTS enabled ON mfadevice TYPE bool DEFAULT false
        COMMENT 'Appareil activé.';

    DEFINE FIELD IF NOT EXISTS title ON mfadevice TYPE string DEFAULT ''
        COMMENT 'Titre de l\'appareil (ex: "iPhone de Jean").';

    DEFINE FIELD IF NOT EXISTS secret ON mfadevice TYPE string
        COMMENT 'Secret TOTP (Chiffré idéalement).';

    DEFINE FIELD IF NOT EXISTS type ON mfadevice TYPE string DEFAULT 'totp'
        ASSERT $value INSIDE ['totp', 'sms', 'email']
        COMMENT 'Type de l\'appareil (totp, sms, email).';

    DEFINE FIELD IF NOT EXISTS created_at ON mfadevice TYPE datetime DEFAULT time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS last_timeslot ON mfadevice TYPE int
        COMMENT 'Dernier slot temporel utilisé (Replay attack protection).';
