-- ============================================================================
-- TABLE  : notification_inbox
-- MODULE : lyxal_notification
-- RÔLE   : Fil de notifications dans l'application (canal in_app, décisions F1 à F8)
-- ============================================================================
-- Un message du fil appartient à une personne : l'abonné auth:<identité> d'une portée
-- (organisation ou installation). Seule cette personne le lit et le modifie (décision F2) :
-- identité de sa session = identité de l'abonné, organisation active = organisation du message.
-- Un gestionnaire ne lit pas le fil d'autrui : il voit l'envoi dans le journal
-- (notification_message, sans contenu). Le message est écrit par le worker du canal in_app
-- (fn::notification_inbox_deliver) ; son contenu est figé (READONLY) : seuls les états (vu, lu,
-- archivé, sommeil) et l'état des boutons changent. Le compte de service du worker
-- (notification.worker, attribué à aucun rôle) le lit aussi : valeurs « vu » et « lu » des
-- conditions d'étape (décision F7) et purge. Supprimé par la personne, par la purge (réglage
-- retention_days_inbox), avec l'abonné, son compte ou son organisation.

DEFINE TABLE OVERWRITE notification_inbox
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "self", tenant: tenant, identity: identity })
            OR fn::notification_can({ action: "worker", tenant: tenant })
        FOR create WHERE fn::notification_can({ action: "worker", tenant: tenant })
        FOR update WHERE fn::notification_can({ action: "self", tenant: tenant, identity: identity })
        FOR delete WHERE fn::notification_can({ action: "self", tenant: tenant, identity: identity })
            OR fn::notification_can({ action: "worker", tenant: tenant })
    COMMENT "Fil de notifications d'une personne (canal in_app) : lu et modifié par elle seule, écrit par le worker";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_inbox
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du message (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_inbox
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_inbox
    TYPE record<notification_subscriber>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Abonné destinataire (auth:<identité>) ; le message est supprimé avec lui";

DEFINE FIELD OVERWRITE identity ON TABLE notification_inbox
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte lyxal_auth de l'abonné, copié à l'envoi : base des droits (seule cette personne lit et modifie le message)";

DEFINE FIELD OVERWRITE run ON TABLE notification_inbox
    TYPE option<record<notification_run>>
    REFERENCE ON DELETE UNSET
    READONLY
    COMMENT "Déclenchement d'origine (retiré à sa purge : le fil a sa propre conservation)";

DEFINE FIELD OVERWRITE job ON TABLE notification_inbox
    TYPE option<record<notification_job>>
    REFERENCE ON DELETE UNSET
    READONLY
    COMMENT "Étape d'origine (un message au plus par étape : livraison idempotente)";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_inbox
    TYPE string
    READONLY
    COMMENT "Clé de l'étape in_app du parcours";

DEFINE FIELD OVERWRITE workflow ON TABLE notification_inbox
    TYPE record<notification_workflow>
    READONLY
    COMMENT "Parcours (jamais supprimé)";

DEFINE FIELD OVERWRITE workflow_key ON TABLE notification_inbox
    TYPE string
    READONLY
    COMMENT "Clé du parcours (filtre de la console)";

DEFINE FIELD OVERWRITE tags ON TABLE notification_inbox
    TYPE array<string>
    DEFAULT []
    READONLY
    COMMENT "Étiquettes du parcours, copiées à l'envoi (onglets, décision F5)";

DEFINE FIELD OVERWRITE severity ON TABLE notification_inbox
    TYPE string
    DEFAULT "none"
    ASSERT $value IN ["high", "medium", "low", "none"]
    READONLY
    COMMENT "Gravité du parcours, copiée à l'envoi : high, medium, low, none";

DEFINE FIELD OVERWRITE title ON TABLE notification_inbox
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 512
    READONLY
    COMMENT "Titre rendu (variables échappées)";

DEFINE FIELD OVERWRITE text ON TABLE notification_inbox
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 20000
    READONLY
    COMMENT "Texte rendu (Markdown simple affiché tel quel par la console, variables échappées)";

DEFINE FIELD OVERWRITE avatar ON TABLE notification_inbox
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 2048
    READONLY
    COMMENT "Avatar (chemin de l'application ou adresse HTTPS, contrôlé par lyxal_core)";

DEFINE FIELD OVERWRITE redirect ON TABLE notification_inbox
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 2048
    READONLY
    COMMENT "Lien de redirection (chemin de l'application ou adresse HTTPS, contrôlé par lyxal_core)";

DEFINE FIELD OVERWRITE actions ON TABLE notification_inbox
    TYPE array<object>
    DEFAULT []
    ASSERT array::len($value) <= 2
    READONLY
    COMMENT "Boutons (deux au plus) : [{ kind : primary ou secondary, label, url }] ; leur état est dans action_status";

DEFINE FIELD OVERWRITE actions[*] ON TABLE notification_inbox TYPE object;
DEFINE FIELD OVERWRITE actions[*].kind ON TABLE notification_inbox TYPE string ASSERT $value IN ["primary", "secondary"];
DEFINE FIELD OVERWRITE actions[*].label ON TABLE notification_inbox TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128;
DEFINE FIELD OVERWRITE actions[*].url ON TABLE notification_inbox TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE action_status ON TABLE notification_inbox
    TYPE object
    DEFAULT {}
    COMMENT "État des boutons, seul élément modifiable avec les états : { primary, secondary : pending, done ou reverted }";

DEFINE FIELD OVERWRITE action_status.primary ON TABLE notification_inbox TYPE option<string> ASSERT $value IS NONE OR $value IN ["pending", "done", "reverted"];
DEFINE FIELD OVERWRITE action_status.secondary ON TABLE notification_inbox TYPE option<string> ASSERT $value IS NONE OR $value IN ["pending", "done", "reverted"];

DEFINE FIELD OVERWRITE data ON TABLE notification_inbox
    TYPE object
    FLEXIBLE
    DEFAULT {}
    READONLY
    COMMENT "Données libres rendues (8 Kio au plus) : filtres d'onglet de la console (décision F5)";

DEFINE FIELD OVERWRITE seen_at ON TABLE notification_inbox TYPE option<datetime> COMMENT "Vu (ouverture de la cloche)";
DEFINE FIELD OVERWRITE read_at ON TABLE notification_inbox TYPE option<datetime> COMMENT "Lu";
DEFINE FIELD OVERWRITE archived_at ON TABLE notification_inbox TYPE option<datetime> COMMENT "Archivé";
DEFINE FIELD OVERWRITE snoozed_until ON TABLE notification_inbox TYPE option<datetime> COMMENT "En sommeil jusqu'à cette date : caché jusque-là, puis de nouveau visible, non lu (calculé à la lecture)";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_inbox
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création (ordre du fil)";

DEFINE FIELD OVERWRITE purge_after ON TABLE notification_inbox
    TYPE datetime
    READONLY
    COMMENT "Date de purge (réglage retention_days_inbox, décision F8)";

DEFINE INDEX OVERWRITE notification_inbox_state ON TABLE notification_inbox FIELDS subscriber, archived_at, read_at;
DEFINE INDEX OVERWRITE notification_inbox_created ON TABLE notification_inbox FIELDS subscriber, created_at;
DEFINE INDEX OVERWRITE notification_inbox_job ON TABLE notification_inbox FIELDS job UNIQUE;
DEFINE INDEX OVERWRITE notification_inbox_run ON TABLE notification_inbox FIELDS run;
DEFINE INDEX OVERWRITE notification_inbox_purge ON TABLE notification_inbox FIELDS purge_after;
