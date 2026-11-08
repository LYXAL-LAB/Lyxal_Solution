-- ============================================================================
-- TABLE  : notification_workflow
-- MODULE : lyxal_notification
-- RÔLE   : Parcours de notification (modèle Novu `notification-template`)
-- ============================================================================
-- Les étapes sont un tableau d'objets ordonnés ; V1-a : une étape `email`. Le déclencheur est un
-- type d'événement `lyxal_event`. `critical` : ignore les désabonnements (jamais les rejets
-- définitifs). `sensitive` : aucun contenu rendu n'est conservé.

DEFINE TABLE OVERWRITE notification_workflow
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
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
    COMMENT "Ignore les désabonnements (jamais les rejets définitifs)";

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
    COMMENT "Étapes ordonnées : [{ key, channel }]";

DEFINE FIELD OVERWRITE steps.* ON TABLE notification_workflow
    TYPE object;

DEFINE FIELD OVERWRITE steps.*.key ON TABLE notification_workflow
    TYPE string;

DEFINE FIELD OVERWRITE steps.*.channel ON TABLE notification_workflow
    TYPE string
    ASSERT $value IN ["email"];

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
