-- ============================================================================
-- TABLE  : notification_template
-- MODULE : lyxal_notification
-- RÔLE   : Gabarit d'une étape
-- ============================================================================
-- Un seul gabarit par étape : il porte la structure (MiniJinja) ; ses phrases sont des clés
-- lyxal_i18n appelées par t("clé"), déclarées dans keys et rendues dans la langue de l'envoi.

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

DEFINE FIELD OVERWRITE subject ON TABLE notification_template
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 998
    COMMENT "Objet (gabarit MiniJinja)";

DEFINE FIELD OVERWRITE html_body ON TABLE notification_template
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 200000
    COMMENT "Corps HTML (gabarit MiniJinja, nettoyé à l'enregistrement)";

DEFINE FIELD OVERWRITE text_body ON TABLE notification_template
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 100000
    COMMENT "Corps texte (gabarit MiniJinja)";

DEFINE FIELD OVERWRITE keys ON TABLE notification_template
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 100
    COMMENT "Clés lyxal_i18n que le gabarit appelle par t(\"clé\")";

DEFINE FIELD OVERWRITE layout ON TABLE notification_template
    TYPE option<record<notification_layout>>
    COMMENT "Mise en page";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_template
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_template_step ON TABLE notification_template FIELDS workflow, step_key UNIQUE;
