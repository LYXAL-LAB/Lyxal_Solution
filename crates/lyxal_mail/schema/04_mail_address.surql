-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_address
-- MODULE : lyxal_mail
-- RÔLE   : Adresses des comptes et alias
-- ============================================================================
-- Une adresse appartient à un domaine de courrier de l'organisation. Sorte account : elle remet
-- dans un compte ; sorte alias : dans 1 à 50 comptes de la même organisation (les alias vers des
-- adresses extérieures viennent au lot 6). Partie locale en ASCII et en minuscules (décision M10).
-- Le titulaire d'un compte lit ses propres adresses ; l'administrateur les gère.

DEFINE TABLE OVERWRITE mail_address
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant })
            OR (account IS NOT NONE AND fn::mail_can({ action: "mailbox", tenant: tenant, account: account }))
            OR fn::mail_can({ action: "worker" })
        FOR create, update, delete WHERE fn::mail_can({ action: "manage", tenant: tenant })
    COMMENT "Adresses des comptes et alias";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_address
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation";

DEFINE FIELD OVERWRITE domain ON TABLE mail_address
    TYPE record<mail_domain>
    REFERENCE ON DELETE THEN {
        IF record::exists($this.tenant) { THROW "MAIL_DOMAIN_NOT_EMPTY"; } ELSE { DELETE $this; };
    }
    READONLY
    COMMENT "Domaine de courrier : un domaine qui porte une adresse ne se supprime pas (MAIL_DOMAIN_NOT_EMPTY), sauf avec son organisation";

DEFINE FIELD OVERWRITE local_part ON TABLE mail_address
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64 AND $value == string::lowercase($value)
    COMMENT "Partie locale (ASCII, minuscules, 64 caractères au plus)";

DEFINE FIELD OVERWRITE address ON TABLE mail_address
    TYPE string
    READONLY
    ASSERT string::len($value) <= 254 AND $value == string::lowercase($value)
    COMMENT "Adresse complète (partie locale@domaine), unique";

DEFINE FIELD OVERWRITE kind ON TABLE mail_address
    TYPE string
    READONLY
    ASSERT $value IN ["account", "alias"]
    COMMENT "Sorte : account (adresse d'un compte) ou alias";

DEFINE FIELD OVERWRITE account ON TABLE mail_address
    TYPE option<record<mail_account>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte d'une adresse de sorte account ; NONE pour un alias";

DEFINE FIELD OVERWRITE targets ON TABLE mail_address
    TYPE array<record<mail_account>>
    DEFAULT []
    ASSERT array::len($value) <= 50
    COMMENT "Comptes d'un alias (1 à 50, de la même organisation) ; vide pour une adresse de compte";

DEFINE FIELD OVERWRITE state ON TABLE mail_address
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled"]
    COMMENT "État : active, ou disabled (non résolue)";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_address
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_address
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_address_address ON TABLE mail_address FIELDS address UNIQUE;
DEFINE INDEX OVERWRITE mail_address_account ON TABLE mail_address FIELDS account;
DEFINE INDEX OVERWRITE mail_address_domain ON TABLE mail_address FIELDS domain, local_part;
DEFINE INDEX OVERWRITE mail_address_targets ON TABLE mail_address FIELDS targets;
