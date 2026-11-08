-- ============================================================================
-- TABLES : notification_template, notification_template_locale
-- MODULE : lyxal_notification
-- RÔLE   : Gabarit d'une étape et ses versions par langue
-- ============================================================================
-- V1 : une version par langue, langue par défaut en repli ; V2 : clés de traduction lyxal_i18n.

DEFINE TABLE OVERWRITE notification_template
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Gabarit d'une étape de parcours";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_template
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du parcours (NONE : installation)";

DEFINE FIELD OVERWRITE workflow ON TABLE notification_template
    TYPE record<notification_workflow>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Parcours";

DEFINE FIELD OVERWRITE step_key ON TABLE notification_template
    TYPE string
    READONLY
    COMMENT "Étape du parcours";

DEFINE FIELD OVERWRITE default_locale ON TABLE notification_template
    TYPE string
    COMMENT "Langue de repli (BCP 47)";

DEFINE FIELD OVERWRITE layout ON TABLE notification_template
    TYPE option<record<notification_layout>>
    COMMENT "Mise en page";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_template
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_template_step ON TABLE notification_template FIELDS workflow, step_key UNIQUE;

DEFINE TABLE OVERWRITE notification_template_locale
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: template.tenant })
        FOR create, update, delete WHERE fn::notification_can({ action: "manage", tenant: template.tenant })
    COMMENT "Version d'un gabarit dans une langue";

DEFINE FIELD OVERWRITE template ON TABLE notification_template_locale
    TYPE record<notification_template>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Gabarit";

DEFINE FIELD OVERWRITE locale ON TABLE notification_template_locale
    TYPE string
    READONLY
    COMMENT "Langue (BCP 47)";

DEFINE FIELD OVERWRITE subject ON TABLE notification_template_locale
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 998
    COMMENT "Objet (gabarit MiniJinja)";

DEFINE FIELD OVERWRITE html_body ON TABLE notification_template_locale
    TYPE string
    ASSERT string::len($value) <= 200000
    COMMENT "Corps HTML (gabarit MiniJinja, nettoyé à l'enregistrement)";

DEFINE FIELD OVERWRITE text_body ON TABLE notification_template_locale
    TYPE string
    ASSERT string::len($value) <= 100000
    COMMENT "Corps texte (gabarit MiniJinja)";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_template_locale
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_template_locale_unique ON TABLE notification_template_locale FIELDS template, locale UNIQUE;
