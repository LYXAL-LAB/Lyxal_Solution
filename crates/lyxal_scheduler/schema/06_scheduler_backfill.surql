-- ============================================================================
-- TABLE  : scheduler_backfill
-- MODULE : lyxal_scheduler
-- RÔLE   : Demandes de rejeu d'une période passée d'une planification
-- ============================================================================
-- Créée par fn::scheduler_schedule_backfill ; le moteur calcule les échéances de la période et
-- les passe à fn::scheduler_backfill_fire. Un seul rejeu en cours (pending ou running) par
-- planification ; période passée, from < to, un an au plus ; demande avec la permission propre
-- de la tâche de la planification, aussi par écriture directe (garde scheduler_backfill_guard).

DEFINE TABLE OVERWRITE scheduler_backfill
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR create, delete WHERE fn::scheduler_can({ action: "write", tenant: tenant })
        FOR update WHERE fn::scheduler_can({ action: "worker" })
    COMMENT "Demandes de rejeu d'une période passée d'une planification";

DEFINE FIELD OVERWRITE schedule ON TABLE scheduler_backfill
    TYPE record<scheduler_schedule>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Planification rejouée";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_backfill
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation de la planification (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_backfill
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE from ON TABLE scheduler_backfill
    TYPE datetime
    READONLY
    COMMENT "Début de la période (inclus)";

DEFINE FIELD OVERWRITE to ON TABLE scheduler_backfill
    TYPE datetime
    READONLY
    COMMENT "Fin de la période (incluse), passée";

DEFINE FIELD OVERWRITE overlap ON TABLE scheduler_backfill
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"]
    COMMENT "Chevauchement des exécutions rejouées (NONE : celui de la planification)";

DEFINE FIELD OVERWRITE state ON TABLE scheduler_backfill
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "running", "done", "cancelled"]
    COMMENT "État : pending, running (échéances en cours de création), done, cancelled";

DEFINE FIELD OVERWRITE runs_created ON TABLE scheduler_backfill
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Exécutions créées par le rejeu";

DEFINE FIELD OVERWRITE requested_by ON TABLE scheduler_backfill
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a demandé le rejeu";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_backfill
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Demande";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_backfill
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_backfill_schedule ON TABLE scheduler_backfill FIELDS schedule, state;
