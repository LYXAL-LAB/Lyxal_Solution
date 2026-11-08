-- ============================================================================
-- TABLE  : notification_layout
-- MODULE : lyxal_notification
-- RÔLE   : Mises en page communes des e-mails
-- ============================================================================

DEFINE TABLE OVERWRITE notification_layout
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Mises en page HTML et texte (contenu inséré par {{ content }})";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_layout
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_layout
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité";

DEFINE FIELD OVERWRITE key ON TABLE notification_layout
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Clé, unique dans sa portée";

DEFINE FIELD OVERWRITE name ON TABLE notification_layout
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom affiché";

DEFINE FIELD OVERWRITE html ON TABLE notification_layout
    TYPE string
    ASSERT string::contains($value, "{{ content }}") AND string::len($value) <= 200000
    COMMENT "HTML (gabarit MiniJinja) contenant {{ content }}";

DEFINE FIELD OVERWRITE text ON TABLE notification_layout
    TYPE string
    ASSERT string::contains($value, "{{ content }}") AND string::len($value) <= 100000
    COMMENT "Texte brut contenant {{ content }}";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_layout
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_layout_key ON TABLE notification_layout FIELDS scope_key, key UNIQUE;
