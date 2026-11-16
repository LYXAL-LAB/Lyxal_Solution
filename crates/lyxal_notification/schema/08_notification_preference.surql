-- ============================================================================
-- TABLES : notification_category, notification_preference
-- MODULE : lyxal_notification
-- RÔLE   : Catégories de désabonnement et préférences par canal
-- ============================================================================
-- Préférences, du plus général au plus précis (le dernier niveau qui s'exprime gagne, décision
-- B4) : défaut du parcours → `tenant_workflow` (réglage de l'organisation pour un parcours) →
-- `subscriber_global` → `subscriber_category` → `subscriber_workflow`. Un parcours critique
-- ignore les choix de l'abonné ; un canal imposé par le parcours aussi. Les heures calmes sont
-- portées par le niveau `subscriber_global`. Calcul unique : fn::notification_preference_resolve.

DEFINE TABLE OVERWRITE notification_category
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Les catégories de l'installation sont visibles de toutes les organisations
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
            OR fn::notification_can({ action: "member", tenant: tenant })
        FOR create, update, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
    COMMENT "Catégories de désabonnement des parcours";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_category TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation (NONE : installation)";
DEFINE FIELD OVERWRITE scope_key ON TABLE notification_category TYPE string VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) } COMMENT "Portée d'unicité";
DEFINE FIELD OVERWRITE key ON TABLE notification_category TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 64 READONLY COMMENT "Clé, unique dans sa portée";
DEFINE FIELD OVERWRITE name ON TABLE notification_category TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 128 COMMENT "Nom affiché";
DEFINE FIELD OVERWRITE description ON TABLE notification_category TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 COMMENT "Description";
DEFINE FIELD OVERWRITE created_at ON TABLE notification_category TYPE datetime DEFAULT time::now() READONLY COMMENT "Création";
DEFINE FIELD OVERWRITE updated_at ON TABLE notification_category TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_category_key ON TABLE notification_category FIELDS scope_key, key UNIQUE;

DEFINE TABLE OVERWRITE notification_preference
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        -- Lue au déclenchement et à l'envoi ; chaque personne lit et règle les siennes
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant })
            OR fn::notification_can({ action: "send", tenant: tenant })
            OR (subscriber IS NOT NONE AND fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity }))
        FOR create, update, delete WHERE fn::notification_can({ action: "manage", tenant: tenant })
            OR (level != "tenant_workflow" AND subscriber IS NOT NONE AND fn::notification_can({ action: "self", tenant: tenant, identity: subscriber.identity }))
    COMMENT "Préférences par canal : organisation pour un parcours, abonné (global, catégorie, parcours)";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_preference TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation (NONE : installation)";
DEFINE FIELD OVERWRITE scope_key ON TABLE notification_preference TYPE string VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) } COMMENT "Portée";

DEFINE FIELD OVERWRITE level ON TABLE notification_preference
    TYPE string
    ASSERT $value IN ["tenant_workflow", "subscriber_global", "subscriber_category", "subscriber_workflow"]
    READONLY
    COMMENT "Niveau : tenant_workflow, subscriber_global, subscriber_category, subscriber_workflow";

DEFINE FIELD OVERWRITE subscriber ON TABLE notification_preference TYPE option<record<notification_subscriber>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Abonné (niveaux subscriber_*)";
DEFINE FIELD OVERWRITE workflow ON TABLE notification_preference TYPE option<record<notification_workflow>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Parcours (tenant_workflow, subscriber_workflow)";
DEFINE FIELD OVERWRITE category ON TABLE notification_preference TYPE option<record<notification_category>> REFERENCE ON DELETE CASCADE READONLY COMMENT "Catégorie (subscriber_category)";

DEFINE FIELD OVERWRITE target_key ON TABLE notification_preference
    TYPE string
    VALUE fn::notification_preference_key({ level: $this.level, tenant: $this.tenant, subscriber: $this.subscriber, workflow: $this.workflow, category: $this.category })
    COMMENT "Cible unique (niveau, portée, abonné, parcours, catégorie)";

DEFINE FIELD OVERWRITE channels ON TABLE notification_preference TYPE object DEFAULT {} COMMENT "Choix par canal : true, false ou absent (le niveau ne s'exprime pas)";
DEFINE FIELD OVERWRITE channels.email ON TABLE notification_preference TYPE option<bool>;
DEFINE FIELD OVERWRITE channels.sms ON TABLE notification_preference TYPE option<bool>;
DEFINE FIELD OVERWRITE channels.chat ON TABLE notification_preference TYPE option<bool>;
DEFINE FIELD OVERWRITE channels.push ON TABLE notification_preference TYPE option<bool>;
DEFINE FIELD OVERWRITE channels.in_app ON TABLE notification_preference TYPE option<bool>;
DEFINE FIELD OVERWRITE channels.webhook ON TABLE notification_preference TYPE option<bool>;

DEFINE FIELD OVERWRITE quiet_hours ON TABLE notification_preference
    TYPE option<object>
    COMMENT "Heures calmes (niveau subscriber_global) : { ranges: [{ days: [1..7, lundi = 1], start, end }] }, minutes depuis minuit dans le fuseau de l'abonné ; end <= start : la plage passe minuit";
DEFINE FIELD OVERWRITE quiet_hours.ranges ON TABLE notification_preference TYPE array<object>;
DEFINE FIELD OVERWRITE quiet_hours.ranges[*] ON TABLE notification_preference TYPE object;
DEFINE FIELD OVERWRITE quiet_hours.ranges[*].days ON TABLE notification_preference TYPE array<int>;
DEFINE FIELD OVERWRITE quiet_hours.ranges[*].start ON TABLE notification_preference TYPE int ASSERT $value >= 0 AND $value <= 1439;
DEFINE FIELD OVERWRITE quiet_hours.ranges[*].end ON TABLE notification_preference TYPE int ASSERT $value >= 0 AND $value <= 1439;

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_preference TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_preference_target ON TABLE notification_preference FIELDS target_key UNIQUE;
DEFINE INDEX OVERWRITE notification_preference_subscriber ON TABLE notification_preference FIELDS subscriber;
