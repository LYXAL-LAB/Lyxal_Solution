-- ============================================================================
-- TABLE  : infra_settings
-- MODULE : lyxal_infra
-- RÔLE   : Réglages du pilotage de l'hébergeur (fiche unique de l'installation)
-- ============================================================================
-- Une seule fiche, infra_settings:installation, créée par le seed seeds/infra_initial.surql et
-- modifiée par fn::infra_settings_update. Aucune donnée sensible : lisible des comptes qui lisent,
-- déclarent ou travaillent pour le module (valeurs par défaut des déclarations, seuils du plan).

DEFINE TABLE OVERWRITE infra_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "declare" }) OR fn::infra_can({ action: "worker" })
        FOR create, update WHERE fn::infra_can({ action: "manage" })
        FOR delete NONE
    COMMENT "Réglages du pilotage de l'hébergeur (fiche unique infra_settings:installation)";

DEFINE FIELD OVERWRITE reconcile_minutes ON TABLE infra_settings
    TYPE int DEFAULT 15
    ASSERT $value >= 1 AND $value <= 1440
    COMMENT "Intervalle entre deux passes de réconciliation d'une zone, en minutes";

DEFINE FIELD OVERWRITE default_ttl ON TABLE infra_settings
    TYPE int DEFAULT 3600
    ASSERT $value >= 60 AND $value <= 86400
    COMMENT "Durée de vie par défaut d'un enregistrement déclaré sans ttl, en secondes";

DEFINE FIELD OVERWRITE min_ttl ON TABLE infra_settings
    TYPE int DEFAULT 60
    ASSERT $value >= 60 AND $value <= 86400
    COMMENT "Durée de vie minimale acceptée à la déclaration, en secondes";

DEFINE FIELD OVERWRITE max_deletions ON TABLE infra_settings
    TYPE int DEFAULT 10
    ASSERT $value >= 0 AND $value <= 10000
    COMMENT "Suppressions au-delà desquelles un plan est bloqué jusqu'à son approbation";

DEFINE FIELD OVERWRITE max_deletion_percent ON TABLE infra_settings
    TYPE int DEFAULT 30
    ASSERT $value >= 0 AND $value <= 100
    COMMENT "Part des enregistrements de Lyxal dans la zone, en pour cent, au-delà de laquelle un plan est bloqué (zone de plus de max_deletions enregistrements de Lyxal)";

DEFINE FIELD OVERWRITE verify_timeout_hours ON TABLE infra_settings
    TYPE int DEFAULT 24
    ASSERT $value >= 1 AND $value <= 168
    COMMENT "Délai au-delà duquel un enregistrement écrit mais non servi passe en échec (INFRA_DNS_NOT_PUBLISHED), en heures";

DEFINE FIELD OVERWRITE requests_per_second ON TABLE infra_settings
    TYPE int DEFAULT 5
    ASSERT $value >= 1 AND $value <= 100
    COMMENT "Débit des appels à l'hébergeur, par compte (rafale du double)";

DEFINE FIELD OVERWRITE change_retention_days ON TABLE infra_settings
    TYPE int DEFAULT 400
    ASSERT $value >= 1 AND $value <= 3650
    COMMENT "Conservation du journal des changements, en jours (la dernière entrée de chaque zone est gardée)";

DEFINE FIELD OVERWRITE released_retention_days ON TABLE infra_settings
    TYPE int DEFAULT 30
    ASSERT $value >= 1 AND $value <= 3650
    COMMENT "Conservation d'un enregistrement retiré (released), en jours";

DEFINE FIELD OVERWRITE updated_at ON TABLE infra_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";
