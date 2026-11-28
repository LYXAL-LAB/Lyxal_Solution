-- ============================================================================
-- TABLE  : infra_zone_record
-- MODULE : lyxal_infra
-- RÔLE   : Photo de la zone chez le fournisseur (écrite par le worker seulement)
-- ============================================================================
-- Une ligne par valeur publiée chez le fournisseur : infra_zone_record:⟨<clé de zone>_<identifiant
-- du fournisseur>⟩. Écrite par différence (fn::infra_zone_observe : seules les lignes changées
-- sont écrites). record : l'enregistrement voulu de Lyxal à qui la ligne appartient (marque
-- lyxal:<clé> du commentaire ou identifiant noté à l'écriture), NONE pour une ligne humaine.

DEFINE TABLE OVERWRITE infra_zone_record
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::infra_can({ action: "read" }) OR fn::infra_can({ action: "worker" })
        FOR create, update WHERE fn::infra_can({ action: "worker" })
        FOR delete WHERE fn::infra_can({ action: "worker" }) OR fn::infra_can({ action: "manage" })
    COMMENT "Photo d'une zone chez le fournisseur : une ligne par valeur, rattachée à son enregistrement de Lyxal s'il y en a un";

DEFINE FIELD OVERWRITE zone ON TABLE infra_zone_record
    TYPE record<infra_zone>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Zone";

DEFINE FIELD OVERWRITE provider_id ON TABLE infra_zone_record
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Identifiant de l'enregistrement chez le fournisseur";

DEFINE FIELD OVERWRITE fqdn ON TABLE infra_zone_record
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 253
    COMMENT "Nom complet (minuscules, sans point final)";

DEFINE FIELD OVERWRITE type ON TABLE infra_zone_record
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 16
    COMMENT "Type (tous les types de la zone, y compris ceux que Lyxal ne déclare pas : NS, SOA…)";

DEFINE FIELD OVERWRITE value ON TABLE infra_zone_record
    TYPE string
    ASSERT string::len($value) <= 4096
    COMMENT "Valeur en forme canonique (traduite par l'adaptateur du fournisseur)";

DEFINE FIELD OVERWRITE ttl ON TABLE infra_zone_record
    TYPE int
    ASSERT $value >= 0 AND $value <= 2147483647
    COMMENT "Durée de vie, en secondes";

DEFINE FIELD OVERWRITE comment ON TABLE infra_zone_record
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    COMMENT "Commentaire du fournisseur (marque lyxal:<clé> des écritures de Lyxal)";

DEFINE FIELD OVERWRITE record ON TABLE infra_zone_record
    TYPE option<record<infra_record>>
    COMMENT "Enregistrement de Lyxal à qui la ligne appartient (NONE : ligne humaine ou d'un autre outil)";

DEFINE FIELD OVERWRITE seen_at ON TABLE infra_zone_record
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Dernière écriture de la ligne (première observation ou dernier changement)";

DEFINE INDEX OVERWRITE infra_zone_record_name ON TABLE infra_zone_record FIELDS zone, fqdn, type;
DEFINE INDEX OVERWRITE infra_zone_record_owner ON TABLE infra_zone_record FIELDS record;
