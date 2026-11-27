-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_dkim_key
-- MODULE : lyxal_mail
-- RÔLE   : Fiche publique d'une clé DKIM d'un domaine (décision E18)
-- ============================================================================
-- mail_dkim_key:⟨<clé du domaine>_<sélecteur>⟩. Deux clés par domaine (rsa-sha256, 2 048 bits ;
-- ed25519-sha256), créées par la tâche mail.dkim.provision : la clé privée est rangée dans
-- lyxal_secrets (chemin mail/dkim/<domaine>/<sélecteur>, organisation du domaine), jamais en base ;
-- la fiche garde la clé publique (valeur p= en Base64), à publier dans le DNS. États : pending
-- (en attente de publication) → active (enregistrement DNS trouvé, identique : la clé signe) ;
-- retiring et retired au lot 13 (rotation). Supprimée avec son domaine. Lecture : administrateur de
-- l'organisation (enregistrements à publier) et compte de service ; le chemin du secret, compte de
-- service seulement. Écritures : compte de service et session système.

DEFINE TABLE OVERWRITE mail_dkim_key
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" })
        FOR create, update, delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Fiche publique d'une clé DKIM d'un domaine de courrier";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_dkim_key TYPE record<auth_organization> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation du domaine";
DEFINE FIELD OVERWRITE domain ON TABLE mail_dkim_key TYPE record<mail_domain> REFERENCE ON DELETE CASCADE READONLY COMMENT "Domaine de courrier (la clé part avec lui)";
DEFINE FIELD OVERWRITE selector ON TABLE mail_dkim_key
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 63 AND $value == string::lowercase($value)
    COMMENT "Sélecteur (lyx<aaaamm>r ou lyx<aaaamm>e ; 63 caractères au plus)";
DEFINE FIELD OVERWRITE algorithm ON TABLE mail_dkim_key TYPE string READONLY ASSERT $value IN ["rsa-sha256", "ed25519-sha256"] COMMENT "Algorithme de signature";
DEFINE FIELD OVERWRITE bits ON TABLE mail_dkim_key TYPE option<int> READONLY ASSERT $value IS NONE OR ($value >= 2048 AND $value <= 4096) COMMENT "Taille de la clé RSA (2 048 au lot 6) ; NONE pour Ed25519";
DEFINE FIELD OVERWRITE public_key ON TABLE mail_dkim_key TYPE string READONLY ASSERT string::len($value) >= 1 AND string::len($value) <= 1024 COMMENT "Clé publique (valeur p= de l'enregistrement DNS, Base64)";
DEFINE FIELD OVERWRITE secret_path ON TABLE mail_dkim_key
    TYPE string
    READONLY
    PERMISSIONS FOR select WHERE fn::mail_can({ action: "worker" })
    COMMENT "Chemin de la clé privée dans lyxal_secrets (mail/dkim/<domaine>/<sélecteur>)";
DEFINE FIELD OVERWRITE state ON TABLE mail_dkim_key TYPE string DEFAULT "pending" ASSERT $value IN ["pending", "active", "retiring", "retired"] COMMENT "État : pending (à publier), active (signe) ; retiring, retired : lot 13";
DEFINE FIELD OVERWRITE dns_checked_at ON TABLE mail_dkim_key TYPE option<datetime> COMMENT "Dernier contrôle de l'enregistrement DNS";
DEFINE FIELD OVERWRITE activated_at ON TABLE mail_dkim_key TYPE option<datetime> COMMENT "Activation";
DEFINE FIELD OVERWRITE created_at ON TABLE mail_dkim_key TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE mail_dkim_key TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_dkim_key_domain ON TABLE mail_dkim_key FIELDS domain, state;
