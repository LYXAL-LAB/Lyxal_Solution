-- ============================================================================
-- TABLE  : notification_template
-- MODULE : lyxal_notification
-- RÔLE   : Gabarit d'une étape
-- ============================================================================
-- Un seul gabarit par étape : il porte la structure (MiniJinja) ; ses phrases sont des clés
-- lyxal_i18n appelées par t("clé"), déclarées dans keys et rendues dans la langue de l'envoi.
-- E-mail : objet, HTML et texte. SMS, messagerie et adresse web (décision E5) : texte seul, avec
-- un objet (titre) facultatif ; ni HTML ni mise en page. Fil dans l'application (décision F3) :
-- titre (objet) et texte requis, avatar, lien de redirection, deux boutons au plus et données
-- (gabarits MiniJinja) ; liens contrôlés à l'enregistrement et au rendu (chemin de l'application
-- ou adresse HTTPS). Push (décision G4) : titre (objet) et texte requis, lien, icône et données
-- (gabarits MiniJinja), mêmes règles de liens ; 4 Kio au plus une fois chiffré, texte tronqué au
-- rendu.

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
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 998)
    COMMENT "Objet (gabarit MiniJinja) : requis pour un e-mail, titre facultatif pour les autres canaux";

DEFINE FIELD OVERWRITE html_body ON TABLE notification_template
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 200000)
    COMMENT "Corps HTML (gabarit MiniJinja, nettoyé à l'enregistrement) : e-mail seulement";

DEFINE FIELD OVERWRITE text_body ON TABLE notification_template
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 100000
    COMMENT "Corps texte (gabarit MiniJinja)";

DEFINE FIELD OVERWRITE avatar ON TABLE notification_template
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 2048)
    COMMENT "Fil : avatar (gabarit d'un chemin de l'application ou d'une adresse HTTPS)";

DEFINE FIELD OVERWRITE redirect ON TABLE notification_template
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 2048)
    COMMENT "Fil et push : lien de redirection (gabarit d'un chemin de l'application ou d'une adresse HTTPS)";

DEFINE FIELD OVERWRITE icon ON TABLE notification_template
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 2048)
    COMMENT "Push : icône (gabarit d'un chemin de l'application ou d'une adresse HTTPS)";

DEFINE FIELD OVERWRITE actions ON TABLE notification_template
    TYPE option<array<object>>
    ASSERT $value IS NONE OR array::len($value) <= 2
    COMMENT "Fil : boutons (deux au plus) [{ kind : primary ou secondary, label, url }] (gabarits)";

DEFINE FIELD OVERWRITE actions[*] ON TABLE notification_template TYPE object;
DEFINE FIELD OVERWRITE actions[*].kind ON TABLE notification_template TYPE string ASSERT $value IN ["primary", "secondary"];
DEFINE FIELD OVERWRITE actions[*].label ON TABLE notification_template TYPE string ASSERT string::len($value) >= 1 AND string::len($value) <= 512;
DEFINE FIELD OVERWRITE actions[*].url ON TABLE notification_template TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE data ON TABLE notification_template
    TYPE option<object>
    FLEXIBLE
    COMMENT "Fil et push : données libres { clé : gabarit } rendues à l'envoi (fil : 8 Kio au plus ; push : 2 Kio au plus)";

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
