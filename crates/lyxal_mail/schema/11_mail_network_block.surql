-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_network_block
-- MODULE : lyxal_mail
-- RÔLE   : Liste de blocage de l'installation (réseaux refusés à l'acceptation)
-- ============================================================================
-- À l'échelle de l'installation (décision S18) : chaque nœud lit les entrées en vigueur
-- (fn::mail_block_active) et refuse ces réseaux à l'acceptation, sans dialogue. Une entrée
-- manuelle (reason manual) est posée par l'administrateur de la plateforme, avec ou sans fin ; un
-- bannissement automatique (errors, harvest, smuggling) est posé par le service du courrier, pour
-- une durée qui double à chaque récidive (strikes), d'une heure à vingt-quatre. Le réseau est une
-- plage CIDR validée par lyxal_core (fn::validation_cidr), en minuscules, unique.

DEFINE TABLE OVERWRITE mail_network_block
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "manage" }) OR fn::mail_can({ action: "worker" })
        FOR create, update WHERE (reason = "manual" AND fn::mail_can({ action: "manage" })) OR (reason != "manual" AND fn::mail_can({ action: "worker" }))
        FOR delete WHERE fn::mail_can({ action: "manage" })
    COMMENT "Liste de blocage de l'installation : réseaux refusés à l'acceptation";

DEFINE FIELD OVERWRITE network ON TABLE mail_network_block
    TYPE string
    READONLY
    ASSERT string::len($value) >= 3 AND string::len($value) <= 64 AND $value == string::lowercase($value)
    COMMENT "Réseau bloqué (plage CIDR IPv4 ou IPv6, minuscules), unique";

DEFINE FIELD OVERWRITE reason ON TABLE mail_network_block
    TYPE string
    READONLY
    ASSERT $value IN ["manual", "errors", "harvest", "smuggling"]
    COMMENT "Motif : manual (administrateur), errors (trop d'erreurs), harvest (recherche d'adresses), smuggling (contrebande SMTP)";

DEFINE FIELD OVERWRITE strikes ON TABLE mail_network_block
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Nombre de bannissements du réseau (récidives comprises) : la durée double à chacun";

DEFINE FIELD OVERWRITE expires_at ON TABLE mail_network_block
    TYPE option<datetime>
    COMMENT "Fin du blocage ; NONE : entrée manuelle sans fin";

DEFINE FIELD OVERWRITE created_by ON TABLE mail_network_block
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Identité qui a posé une entrée manuelle (NONE : session système, bannissement automatique)";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_network_block
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_network_block
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_network_block_network ON TABLE mail_network_block FIELDS network UNIQUE;
DEFINE INDEX OVERWRITE mail_network_block_expires ON TABLE mail_network_block FIELDS expires_at;
