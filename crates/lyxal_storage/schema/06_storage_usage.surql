-- ============================================================================
-- TABLE  : storage_usage
-- MODULE : lyxal_storage
-- RÔLE   : Volume tenu à jour par portée et par bucket (compteurs répartis)
-- ============================================================================
-- Compteurs répartis : 64 lignes au plus par portée (storage_usage:["scope", <portée>, <numéro>])
-- et 64 au plus par bucket (storage_usage:["bucket", <clé du bucket>, <numéro>]), numéros 0 à 63.
-- Le premier élément de l'identifiant sépare les deux familles : la plage d'identifiants d'une
-- portée ne contient aucune ligne de bucket, quelle que soit la clé d'un bucket. Chaque
-- écriture d'une fiche tire un numéro au sort et ajoute sa variation à la ligne de ce numéro de
-- la portée et à celle du bucket, créées à la première écriture : deux écritures simultanées ne
-- se heurtent que si elles tirent le même numéro. Le volume est la SOMME des lignes ; une ligne
-- seule ne veut rien dire et peut être négative (réservation ajoutée à une ligne, retirée d'une
-- autre). Tenus par l'événement storage_object_usage dans la transaction de chaque écriture
-- d'une fiche (ouverture, fin d'écriture, quarantaine, suppression, expiration, purge), y
-- compris une écriture directe : le quota additionne ces lignes au lieu de relire les fiches.
-- Les lignes partent avec leur bucket ou leur organisation (REFERENCE ON DELETE CASCADE).
-- Contrôle de cohérence : fn::storage_usage_verify. Aucune écriture directe.

DEFINE TABLE OVERWRITE storage_usage
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::storage_can({ action: "read", tenant: tenant })
        FOR create, update, delete NONE
    COMMENT "Volume tenu à jour par portée et par bucket, réparti sur 64 lignes au plus chacun ; le volume est la somme des lignes (fichiers disponibles ou en quarantaine, écritures en attente)";

DEFINE FIELD OVERWRITE tenant ON TABLE storage_usage
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE storage_usage
    TYPE string
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE bucket ON TABLE storage_usage
    TYPE option<record<storage_bucket>>
    REFERENCE ON DELETE CASCADE
    COMMENT "Bucket (NONE : ligne de la portée)";

DEFINE FIELD OVERWRITE shard ON TABLE storage_usage
    TYPE int
    ASSERT $value >= 0 AND $value <= 63
    COMMENT "Numéro de la ligne parmi celles de la portée ou du bucket (0 à 63)";

DEFINE FIELD OVERWRITE objects ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Part de cette ligne dans le nombre de fichiers disponibles ou en quarantaine (peut être négative)";

DEFINE FIELD OVERWRITE bytes ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Part de cette ligne dans leur volume (taille réelle), en octets (peut être négative)";

DEFINE FIELD OVERWRITE reserved ON TABLE storage_usage
    TYPE int
    DEFAULT 0
    COMMENT "Part de cette ligne dans les tailles annoncées des écritures en attente, en octets (peut être négative)";

DEFINE FIELD OVERWRITE updated_at ON TABLE storage_usage
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";
