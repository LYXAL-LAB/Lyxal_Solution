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
