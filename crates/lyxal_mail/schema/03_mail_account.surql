-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_account
-- MODULE : lyxal_mail
-- RÔLE   : Compte de courrier d'un membre d'une organisation
-- ============================================================================
-- Un compte par identité et par organisation. Il porte les compteurs du compte, tenus par les
-- événements de lyxal_mail dans la transaction de chaque écriture (events/mail_guards.surql),
-- quelle qu'en soit l'origine : nombre de messages, volume, numéro de modification (un par compte,
-- décision M6, modèle de Mox), prochaine UIDVALIDITY, plancher des changements, nombre de dossiers
-- et d'adresses. Ces compteurs ne s'écrivent pas directement (permission du compte de service).
-- Le titulaire de la boîte ne modifie que la date du premier dépassement de quota (publication de
-- mail.quota.exceeded) ; l'administrateur, l'état, le quota et l'adresse principale. Identité
-- supprimée : le compte passe à deleting (événement), puis la maintenance le purge (M12).

DEFINE TABLE OVERWRITE mail_account
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "mailbox", tenant: tenant, identity: identity }) OR fn::mail_can({ action: "manage", tenant: tenant })
            OR fn::mail_can({ action: "sender", tenant: tenant, identity: identity })
        FOR create WHERE fn::mail_can({ action: "manage", tenant: tenant })
        FOR update WHERE fn::mail_can({ action: "mailbox", tenant: tenant, identity: identity }) OR fn::mail_can({ action: "manage", tenant: tenant })
        FOR delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Compte de courrier d'un membre d'une organisation";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_account
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation";

DEFINE FIELD OVERWRITE identity ON TABLE mail_account
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
    COMMENT "Identité titulaire ; retirée avec l'identité (le compte passe alors à deleting) ; jamais changée pour une autre (garde)";

DEFINE FIELD OVERWRITE state ON TABLE mail_account
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled", "deleting"]
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
    COMMENT "État : active, disabled (aucune écriture, aucune remise), deleting (adresses retirées, purge par la maintenance)";

DEFINE FIELD OVERWRITE primary_address ON TABLE mail_account
    TYPE option<record<mail_address>>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
    COMMENT "Adresse principale (ne se retire pas tant que le compte existe)";

DEFINE FIELD OVERWRITE quota_bytes ON TABLE mail_account
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
    COMMENT "Quota du compte, en octets (NONE : celui des réglages de l'organisation)";

DEFINE FIELD OVERWRITE quota_exceeded_at ON TABLE mail_account
    TYPE option<datetime>
    COMMENT "Premier dépôt refusé pour quota depuis le dernier passage sous le quota (publie mail.quota.exceeded) ; effacé quand le volume repasse sous le quota";

DEFINE FIELD OVERWRITE message_count ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre de messages (ressource MESSAGE), tenu par les événements";

DEFINE FIELD OVERWRITE used_bytes ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Volume des messages, en octets (ressource STORAGE ; une copie compte à nouveau), tenu par les événements";

DEFINE FIELD OVERWRITE modseq ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Dernier numéro de modification du compte (MODSEQ IMAP, état JMAP), avancé par les événements";

DEFINE FIELD OVERWRITE uid_validity_next ON TABLE mail_account
    TYPE int
    DEFAULT 1
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "UIDVALIDITY du prochain dossier créé (un dossier recréé sous un ancien nom en reçoit une plus grande)";

DEFINE FIELD OVERWRITE changes_floor ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Plus haut numéro de modification des effacements purgés : une synchronisation plus ancienne est refusée (MAIL_CHANGES_TOO_OLD)";

DEFINE FIELD OVERWRITE mailbox_count ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre de dossiers, tenu par les événements";

DEFINE FIELD OVERWRITE address_count ON TABLE mail_account
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre d'adresses du compte (hors alias), tenu par les événements";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_account
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_account
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_account_identity ON TABLE mail_account FIELDS tenant, identity UNIQUE;
DEFINE INDEX OVERWRITE mail_account_state ON TABLE mail_account FIELDS state;
