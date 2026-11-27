-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_settings
-- MODULE : lyxal_mail
-- RÔLE   : Réglages du courrier (installation, surcharge par organisation)
-- ============================================================================
-- Une ligne par portée. Un champ absent prend la valeur de l'installation, sinon la valeur par
-- défaut du module (fn::mail_settings_effective). Les réglages de l'installation (limites, sans
-- donnée sensible) sont lisibles de toute session ; ceux d'une organisation, de ses
-- administrateurs, de ses membres qui ont une boîte (limites appliquées à leurs écritures) et du
-- compte de service. Le réglage postmaster n'existe qu'à la portée de l'installation : adresse
-- inscrite qui reçoit RCPT TO:<postmaster> écrit sans domaine (RFC 5321 §4.5.1, décision S17).

DEFINE TABLE OVERWRITE mail_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE OR fn::mail_can({ action: "settings", tenant: tenant })
        FOR create, update WHERE fn::mail_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Réglages du courrier (installation, surcharge par organisation)";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_settings
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE mail_settings
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE max_message_bytes ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1024 AND $value <= 5368709120)
    COMMENT "Taille maximale d'un message, en octets (de 1 Kio à 5 Gio, taille maximale d'un fichier de lyxal_storage)";

DEFINE FIELD OVERWRITE default_quota_bytes ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    COMMENT "Quota d'un compte qui n'a pas le sien, en octets (NONE : sans quota)";

DEFINE FIELD OVERWRITE tombstone_retention_days ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 7 AND $value <= 365)
    COMMENT "Conservation des effacements pour la synchronisation, en jours (7 à 365)";

DEFINE FIELD OVERWRITE max_mailboxes_per_account ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 6 AND $value <= 10000)
    COMMENT "Nombre maximal de dossiers d'un compte (6 à 10 000)";

DEFINE FIELD OVERWRITE max_addresses_per_account ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1000)
    COMMENT "Nombre maximal d'adresses d'un compte (1 à 1 000)";

DEFINE FIELD OVERWRITE max_keywords_per_message ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1000)
    COMMENT "Nombre maximal de mots-clés d'un message (1 à 1 000)";

DEFINE FIELD OVERWRITE postmaster ON TABLE mail_settings
    TYPE option<string>
    ASSERT $value IS NONE OR ($this.tenant IS NONE AND string::len($value) >= 3 AND string::len($value) <= 254 AND $value == string::lowercase($value))
    COMMENT "Installation seulement : adresse inscrite (minuscules) qui reçoit le destinataire postmaster écrit sans domaine ; NONE : ce destinataire est inconnu";

-- Envoi (lot 6, décisions E6, E16) : limites d'une organisation, plafonnées par celles de
-- l'installation (fn::mail_settings_effective rend la plus petite) ; tentatives et expiration de
-- la file réglées par l'installation seulement.

DEFINE FIELD OVERWRITE send_recipients_per_message ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1000)
    COMMENT "Destinataires d'un message déposé par un compte, au plus (1 à 1 000)";

DEFINE FIELD OVERWRITE send_messages_per_day ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1000000)
    COMMENT "Messages déposés par un compte et par jour UTC, au plus (1 à 1 000 000)";

DEFINE FIELD OVERWRITE send_recipients_per_day ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10000000)
    COMMENT "Destinataires des messages d'un compte par jour UTC, au plus (1 à 10 000 000)";

DEFINE FIELD OVERWRITE module_messages_per_hour ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10000000)
    COMMENT "Messages déposés par les modules pour l'organisation, par heure UTC, au plus (1 à 10 000 000)";

DEFINE FIELD OVERWRITE forward_messages_per_day ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 10000000)
    COMMENT "Transferts d'alias vers l'extérieur de l'organisation par jour UTC, au plus (0 à 10 000 000 ; 0 : aucun transfert)";

DEFINE FIELD OVERWRITE retry_intervals ON TABLE mail_settings
    TYPE option<array<int>>
    ASSERT $value IS NONE OR ($this.tenant IS NONE AND array::len($value) >= 1 AND array::len($value) <= 16 AND array::all($value, |$m| $m >= 1 AND $m <= 1440))
    COMMENT "Installation seulement : délais entre deux essais d'un destinataire, en minutes (1 à 1 440 chacun, 16 au plus ; le dernier se répète)";

DEFINE FIELD OVERWRITE retry_jitter_percent ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($this.tenant IS NONE AND $value >= 0 AND $value <= 50)
    COMMENT "Installation seulement : décalage aléatoire de chaque délai, en pour cent (0 à 50)";

DEFINE FIELD OVERWRITE delay_notice_hours ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($this.tenant IS NONE AND $value >= 1 AND $value <= 72)
    COMMENT "Installation seulement : âge d'un envoi encore en file qui donne l'avis de retard, en heures (1 à 72)";

DEFINE FIELD OVERWRITE expire_hours ON TABLE mail_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($this.tenant IS NONE AND $value >= 1 AND $value <= 720)
    COMMENT "Installation seulement : durée de vie d'un envoi en file, en heures (1 à 720) ; au-delà, ses destinataires expirent";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_settings
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_settings_scope ON TABLE mail_settings FIELDS scope_key UNIQUE;
