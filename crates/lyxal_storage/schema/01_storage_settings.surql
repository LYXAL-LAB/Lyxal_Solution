-- ============================================================================
-- TABLE  : storage_settings
-- MODULE : lyxal_storage
-- RÔLE   : Réglages du stockage (installation, surcharge par organisation)
-- ============================================================================
-- Une ligne par portée. Un champ absent prend la valeur de l'installation, sinon la valeur par
-- défaut du module (fn::storage_settings_effective). Les réglages de l'installation (limites, sans
-- donnée sensible) sont lisibles de toute session : ils servent de repli à chaque organisation.

DEFINE TABLE OVERWRITE storage_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE OR fn::storage_can({ action: "read", tenant: tenant })
        FOR create, update WHERE fn::storage_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Réglages du stockage (installation, surcharge par organisation)";

DEFINE FIELD OVERWRITE tenant ON TABLE storage_settings
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE storage_settings
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE max_object_size ON TABLE storage_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 5368709120)
    COMMENT "Taille maximale d'un fichier, en octets (5 Go au plus)";

DEFINE FIELD OVERWRITE quota_bytes ON TABLE storage_settings
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    COMMENT "Volume maximal de la portée, en octets (NONE : sans quota)";

DEFINE FIELD OVERWRITE pending_ttl_seconds ON TABLE storage_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 60 AND $value <= 604800)
    COMMENT "Délai d'une écriture en attente, en secondes";

DEFINE FIELD OVERWRITE upload_ttl_seconds ON TABLE storage_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 60 AND $value <= 604800)
    COMMENT "Délai d'un envoi reprenable inachevé, en secondes";

DEFINE FIELD OVERWRITE deleted_retention_days ON TABLE storage_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 3650)
    COMMENT "Conservation d'un fichier supprimé avant le retrait de ses octets, en jours";

DEFINE FIELD OVERWRITE blocked_types ON TABLE storage_settings
    TYPE option<array<string>>
    ASSERT $value IS NONE OR array::len($value) <= 100
    COMMENT "Types MIME refusés, quel que soit le bucket (NONE : ceux de l'installation, sinon du module)";

DEFINE FIELD OVERWRITE updated_at ON TABLE storage_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE storage_settings_scope ON TABLE storage_settings FIELDS scope_key UNIQUE;
