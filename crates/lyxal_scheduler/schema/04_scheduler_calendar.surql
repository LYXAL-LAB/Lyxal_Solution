-- ============================================================================
-- TABLE  : scheduler_calendar
-- MODULE : lyxal_scheduler
-- RÔLE   : Calendriers d'exceptions nommés, par organisation
-- ============================================================================
-- Règles { mode: include | exclude, kind, values } contrôlées ici (fn::scheduler_calendar_rules_check),
-- évaluées par le calcul des dates en Rust (lot 2) :
--   dates      : "AAAA-MM-JJ" (jours précis, ex. jours fériés d'une année) ;
--   annual     : "MM-JJ" (chaque année) ;
--   weekdays   : 1 (lundi) à 7 (dimanche) ;
--   monthdays  : 1 à 31 ;
--   time_range : "HH:MM-HH:MM" (plage horaire, fin exclue ; une plage qui passe minuit est admise).
-- Nom unique dans la portée ; suppression refusée tant qu'une planification l'utilise
-- (garde scheduler_calendar_guard).

DEFINE TABLE OVERWRITE scheduler_calendar
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR create, update, delete WHERE fn::scheduler_can({ action: "calendar", tenant: tenant })
    COMMENT "Calendriers d'exceptions nommés (inclusion ou exclusion de dates, jours et plages horaires)";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_calendar
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_calendar
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité du nom : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE name ON TABLE scheduler_calendar
    TYPE string
    READONLY
    ASSERT fn::validation_slug($value, 64).valid
    COMMENT "Nom du calendrier (slug), unique dans sa portée";

DEFINE FIELD OVERWRITE description ON TABLE scheduler_calendar
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Usage du calendrier";

DEFINE FIELD OVERWRITE rules ON TABLE scheduler_calendar
    TYPE array<object>
    ASSERT array::len($value) >= 1 AND array::len($value) <= 100
    COMMENT "Règles { mode, kind, values } (1 à 100)";

DEFINE FIELD OVERWRITE rules[*].mode ON TABLE scheduler_calendar
    TYPE string
    ASSERT $value IN ["include", "exclude"];

DEFINE FIELD OVERWRITE rules[*].kind ON TABLE scheduler_calendar
    TYPE string
    ASSERT $value IN ["dates", "annual", "weekdays", "monthdays", "time_range"];

DEFINE FIELD OVERWRITE rules[*].values ON TABLE scheduler_calendar
    TYPE array<string | int>
    ASSERT array::len($value) >= 1 AND array::len($value) <= 400;

DEFINE FIELD OVERWRITE created_by ON TABLE scheduler_calendar
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a créé le calendrier (NONE : session système, compte de service ou identité supprimée)";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_calendar
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_calendar
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_calendar_name ON TABLE scheduler_calendar FIELDS scope_key, name UNIQUE;
