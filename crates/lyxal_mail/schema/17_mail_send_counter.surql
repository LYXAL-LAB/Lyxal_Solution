-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_send_counter
-- MODULE : lyxal_mail
-- RÔLE   : Compteurs des limites d'envoi (décision E16)
-- ============================================================================
-- mail_send_counter:⟨<sorte>_<clé de la portée>_<fenêtre>⟩ : messages et destinataires d'un compte
-- par jour UTC, messages des modules d'une organisation par heure UTC, transferts d'une
-- organisation par jour UTC. Pris par l'événement de création d'un envoi (refus au-delà de la
-- limite : MAIL_SEND_LIMIT_EXCEEDED, l'envoi n'est pas créé), rendus à l'abandon d'un dépôt ;
-- purgés par la maintenance après leur fenêtre. Aucune écriture directe (compte de service et
-- session système seulement) ; lus aussi par le titulaire du compte et par le relais des modules
-- (erreur lisible avant le dépôt).

DEFINE TABLE OVERWRITE mail_send_counter
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "worker" }) OR (account IS NOT NONE AND fn::mail_can({ action: "sender", tenant: tenant, account: account }))
            OR (account IS NONE AND fn::mail_can({ action: "relay" }))
        FOR create, update, delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Compteurs des limites d'envoi par compte et par organisation";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_send_counter TYPE record<auth_organization> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation";
DEFINE FIELD OVERWRITE account ON TABLE mail_send_counter TYPE option<record<mail_account>> READONLY COMMENT "Compte (compteurs d'un compte)";
DEFINE FIELD OVERWRITE kind ON TABLE mail_send_counter TYPE string READONLY ASSERT $value IN ["account_messages", "account_recipients", "module_messages", "forward_messages"] COMMENT "Sorte : messages ou destinataires d'un compte, messages des modules, transferts";
DEFINE FIELD OVERWRITE count ON TABLE mail_send_counter TYPE int DEFAULT 0 ASSERT $value >= 0 COMMENT "Valeur dans la fenêtre";
DEFINE FIELD OVERWRITE expires_at ON TABLE mail_send_counter TYPE datetime READONLY COMMENT "Fin de conservation (fin de la fenêtre + 1 jour)";

DEFINE INDEX OVERWRITE mail_send_counter_expires ON TABLE mail_send_counter FIELDS expires_at;
