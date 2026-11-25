-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_domain
-- MODULE : lyxal_mail
-- RÔLE   : Domaines de courrier d'une organisation
-- ============================================================================
-- Un domaine de courrier reprend un domaine vérifié de lyxal_auth (auth_organization_domain,
-- décision M9) : aucune vérification propre au courrier. Nom en forme ASCII et en minuscules
-- (décision M10 : pas de domaine international au lot 4). Le retrait du domaine de lyxal_auth
-- est refusé tant qu'un domaine de courrier le référence (MAIL_DOMAIN_EXISTS), sauf avec son
-- organisation : la clause ON DELETE THEN laisse passer la purge de l'organisation, que
-- ON DELETE REJECT bloquerait (essayé sur SurrealDB 3.3.4). Réception (lot 5) : un compte
-- attrape-tout (catch_all, aucun par défaut, décision S17) reçoit les adresses inconnues du
-- domaine ; un compte postmaster reçoit postmaster@<domaine> quand aucune adresse postmaster
-- n'est inscrite. Tous deux sont des comptes actifs de la même organisation (garde).

DEFINE TABLE OVERWRITE mail_domain
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
        FOR create, update, delete WHERE fn::mail_can({ action: "manage", tenant: tenant })
    COMMENT "Domaines de courrier d'une organisation";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_domain
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation propriétaire";

DEFINE FIELD OVERWRITE auth_domain ON TABLE mail_domain
    TYPE record<auth_organization_domain>
    REFERENCE ON DELETE THEN {
        IF record::exists($this.tenant) { THROW "MAIL_DOMAIN_EXISTS"; } ELSE { DELETE $this; };
    }
    READONLY
    COMMENT "Domaine vérifié de lyxal_auth ; son retrait est refusé tant que ce domaine de courrier existe, sauf avec l'organisation";

DEFINE FIELD OVERWRITE name ON TABLE mail_domain
    TYPE string
    READONLY
    ASSERT string::len($value) >= 3 AND string::len($value) <= 253 AND $value == string::lowercase($value)
    COMMENT "Nom du domaine (forme ASCII, minuscules), égal à celui du domaine de lyxal_auth";

DEFINE FIELD OVERWRITE state ON TABLE mail_domain
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "disabled"]
    COMMENT "État : active, ou disabled (aucune adresse du domaine n'est résolue)";

DEFINE FIELD OVERWRITE subaddress_separator ON TABLE mail_domain
    TYPE option<string>
    ASSERT $value IS NONE OR $value = "+"
    COMMENT "Séparateur des sous-adresses (jean+factures → jean) ; NONE : aucune sous-adresse";

DEFINE FIELD OVERWRITE catch_all ON TABLE mail_domain
    TYPE option<record<mail_account>>
    REFERENCE ON DELETE UNSET
    COMMENT "Compte attrape-tout : reçoit les adresses inconnues du domaine (aucun par défaut, décision S17) ; compte actif de la même organisation (garde) ; effacé quand le compte part en suppression";

DEFINE FIELD OVERWRITE postmaster ON TABLE mail_domain
    TYPE option<record<mail_account>>
    REFERENCE ON DELETE UNSET
    COMMENT "Compte qui reçoit postmaster@<domaine> quand aucune adresse postmaster n'est inscrite (RFC 5321 §4.5.1) ; compte actif de la même organisation (garde) ; effacé quand le compte part en suppression";

DEFINE FIELD OVERWRITE address_count ON TABLE mail_domain
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre d'adresses et d'alias du domaine, tenu par l'événement des adresses";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_domain
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_domain
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_domain_name ON TABLE mail_domain FIELDS name UNIQUE;
DEFINE INDEX OVERWRITE mail_domain_tenant ON TABLE mail_domain FIELDS tenant, name;
DEFINE INDEX OVERWRITE mail_domain_catch_all ON TABLE mail_domain FIELDS catch_all;
DEFINE INDEX OVERWRITE mail_domain_postmaster ON TABLE mail_domain FIELDS postmaster;
