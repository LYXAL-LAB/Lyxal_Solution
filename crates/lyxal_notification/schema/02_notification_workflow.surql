-- ============================================================================
-- TABLE  : notification_workflow
-- MODULE : lyxal_notification
-- RÔLE   : Parcours de notification (modèle Novu `notification-template`)
-- ============================================================================
-- Les étapes sont un tableau d'objets exécutés dans l'ordre : canal (`email`, `sms`, `chat`,
-- `webhook`, `in_app`), attente (`delay`),
-- regroupement (`digest`), limitation (`throttle`). Le déclencheur est un
-- type d'événement `lyxal_event`. `critical` : ignore les choix de l'abonné, sa liste de
-- désabonnements et ses heures calmes (jamais les rejets définitifs). `sensitive` : aucun
-- contenu rendu n'est conservé (une étape in_app y est refusée). `category` : catégorie de
-- désabonnement ; `preferences` : canaux par défaut et canaux imposés (que l'abonné ne peut pas
-- changer). `severity` : gravité copiée sur les messages du fil (onglets, décision F5).

DEFINE TABLE OVERWRITE notification_workflow
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Lus aussi par chaque personne de la portée, pour régler ses préférences
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
            OR fn::notification_can({ action: "member", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Parcours de notification déclenchés par événement ou par appel direct";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_workflow
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : parcours de l'installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_workflow
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité";

DEFINE FIELD OVERWRITE key ON TABLE notification_workflow
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Clé du parcours, unique dans sa portée";

DEFINE FIELD OVERWRITE name ON TABLE notification_workflow
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE trigger_event ON TABLE notification_workflow
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Type d'événement lyxal_event déclencheur";

DEFINE FIELD OVERWRITE status ON TABLE notification_workflow
    TYPE string
    DEFAULT "draft"
    ASSERT $value IN ["draft", "active", "inactive"]
    COMMENT "État : brouillon, actif, inactif";

DEFINE FIELD OVERWRITE critical ON TABLE notification_workflow
    TYPE bool
    DEFAULT false
    COMMENT "Ignore les choix de l'abonné, les désabonnements et les heures calmes (jamais les rejets définitifs)";

DEFINE FIELD OVERWRITE category ON TABLE notification_workflow
    TYPE option<record<notification_category>>
    REFERENCE ON DELETE UNSET
    COMMENT "Catégorie de désabonnement (de la portée du parcours ou de l'installation)";

DEFINE FIELD OVERWRITE preferences ON TABLE notification_workflow
    TYPE object
    DEFAULT { channels: {}, enforced: [] }
    COMMENT "Préférences du parcours : { channels : défaut par canal (true si absent), enforced : canaux imposés }";

DEFINE FIELD OVERWRITE preferences.channels ON TABLE notification_workflow TYPE object DEFAULT {};
DEFINE FIELD OVERWRITE preferences.channels.email ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.channels.sms ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.channels.chat ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.channels.push ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.channels.in_app ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.channels.webhook ON TABLE notification_workflow TYPE option<bool>;
DEFINE FIELD OVERWRITE preferences.enforced ON TABLE notification_workflow TYPE array<string> DEFAULT [];

DEFINE FIELD OVERWRITE sensitive ON TABLE notification_workflow
    TYPE bool
    DEFAULT false
    COMMENT "Aucun contenu rendu conservé (codes, liens)";

DEFINE FIELD OVERWRITE payload_schema ON TABLE notification_workflow
    TYPE option<object>
    COMMENT "Schéma lyxal_core des variables non sensibles";

DEFINE FIELD OVERWRITE payload_schema.* ON TABLE notification_workflow
    TYPE any;

DEFINE FIELD OVERWRITE steps ON TABLE notification_workflow
    TYPE array<object>
    DEFAULT []
    COMMENT "Étapes exécutées dans l'ordre : [{ key, type, condition, … }] (forme contrôlée par fn::notification_step_check)";

DEFINE FIELD OVERWRITE steps.* ON TABLE notification_workflow
    TYPE object;

DEFINE FIELD OVERWRITE steps.*.key ON TABLE notification_workflow
    TYPE string
    COMMENT "Clé de l'étape, unique dans le parcours";

DEFINE FIELD OVERWRITE steps.*.type ON TABLE notification_workflow
    TYPE string
    ASSERT $value IN ["email", "sms", "chat", "webhook", "in_app", "delay", "digest", "throttle"]
    COMMENT "Type : canal (email, sms, chat, webhook, in_app) ou étape d'enchaînement (delay, digest, throttle)";

DEFINE FIELD OVERWRITE steps.*.condition ON TABLE notification_workflow
    TYPE option<object>
    FLEXIBLE
    COMMENT "Condition lyxal_core sur { payload, subscriber, steps } : fausse, l'étape est sautée";

-- Attente (delay) : amount + unit, ou until (chemin d'une date dans les données) et offset
DEFINE FIELD OVERWRITE steps.*.amount ON TABLE notification_workflow TYPE option<int>;
DEFINE FIELD OVERWRITE steps.*.unit ON TABLE notification_workflow TYPE option<string>;
DEFINE FIELD OVERWRITE steps.*.until ON TABLE notification_workflow TYPE option<string>;
DEFINE FIELD OVERWRITE steps.*.offset ON TABLE notification_workflow TYPE option<object>;
DEFINE FIELD OVERWRITE steps.*.offset.amount ON TABLE notification_workflow TYPE int;
DEFINE FIELD OVERWRITE steps.*.offset.unit ON TABLE notification_workflow TYPE string;

-- Regroupement (digest) et limitation (throttle) : fenêtre, clé lue dans les données
DEFINE FIELD OVERWRITE steps.*.window ON TABLE notification_workflow TYPE option<object>;
DEFINE FIELD OVERWRITE steps.*.window.amount ON TABLE notification_workflow TYPE int;
DEFINE FIELD OVERWRITE steps.*.window.unit ON TABLE notification_workflow TYPE string;
DEFINE FIELD OVERWRITE steps.*.group_by ON TABLE notification_workflow TYPE option<string>;
DEFINE FIELD OVERWRITE steps.*.lookback ON TABLE notification_workflow TYPE option<object>;
DEFINE FIELD OVERWRITE steps.*.lookback.amount ON TABLE notification_workflow TYPE int;
DEFINE FIELD OVERWRITE steps.*.lookback.unit ON TABLE notification_workflow TYPE string;
DEFINE FIELD OVERWRITE steps.*.limit ON TABLE notification_workflow TYPE option<int>;

DEFINE FIELD OVERWRITE severity ON TABLE notification_workflow
    TYPE string
    DEFAULT "none"
    ASSERT $value IN ["high", "medium", "low", "none"]
    COMMENT "Gravité (high, medium, low, none), copiée sur les messages du fil";

DEFINE FIELD OVERWRITE tags ON TABLE notification_workflow
    TYPE array<string>
    DEFAULT []
    COMMENT "Étiquettes";

DEFINE FIELD OVERWRITE created_at ON TABLE notification_workflow
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_workflow
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_workflow_key ON TABLE notification_workflow FIELDS scope_key, key UNIQUE;
DEFINE INDEX OVERWRITE notification_workflow_trigger ON TABLE notification_workflow FIELDS trigger_event, status;
