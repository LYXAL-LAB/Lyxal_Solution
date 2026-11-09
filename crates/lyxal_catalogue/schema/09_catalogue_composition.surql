-- ============================================================================
-- TABLE  : catalogue_composition
-- MODULE : lyxal_catalogue
-- RÔLE   : En-têtes de nomenclature avec protection moteur d'immuabilité
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_composition
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::catalogue_access({ is_custom: parent_item.is_custom, tenant: parent_item.tenant, action: "read" })
        FOR create, update, delete WHERE fn::catalogue_access({ is_custom: parent_item.is_custom, tenant: parent_item.tenant, action: "write" })
    COMMENT "En-têtes de nomenclature et compositions (Ouvrage ou Ensemble)";


DEFINE FIELD OVERWRITE parent_item ON TABLE catalogue_composition
    TYPE record<catalogue_item>
    REFERENCE ON DELETE CASCADE
    COMMENT "Élément parent composé";

DEFINE FIELD OVERWRITE version ON TABLE catalogue_composition
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Numéro de version incrémental";

DEFINE FIELD OVERWRITE statut ON TABLE catalogue_composition
    TYPE string
    DEFAULT "DRAFT"
    ASSERT $value IN ["DRAFT", "PUBLISHED", "ARCHIVED"]
    COMMENT "Cycle de vie : DRAFT -> PUBLISHED -> ARCHIVED";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_composition
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Désignation de la recette ou composition";

DEFINE FIELD OVERWRITE is_locked ON TABLE catalogue_composition
    TYPE bool
    DEFAULT false
    COMMENT "Verrou d'immuabilité activé lors de la publication";

DEFINE FIELD OVERWRITE published_at ON TABLE catalogue_composition
    TYPE option<datetime>
    COMMENT "Date de publication effective";

DEFINE FIELD OVERWRITE date_effet ON TABLE catalogue_composition
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date d'entrée en vigueur";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_composition
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_composition
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

DEFINE INDEX OVERWRITE idx_comp_parent_version ON TABLE catalogue_composition FIELDS parent_item, version UNIQUE;
DEFINE INDEX OVERWRITE idx_comp_parent_statut ON TABLE catalogue_composition FIELDS parent_item, statut;

-- ----------------------------------------------------------------------------
-- VERROU MOTEUR : Protection contre la modification frauduleuse d'une composition scellée
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_composition_protect ON TABLE catalogue_composition
WHEN $event = "UPDATE"
THEN {
    -- Si la composition était déjà verrouillée
    IF $before.is_locked = true {
        -- Seule transition autorisée : passage de PUBLISHED à ARCHIVED avec champs métier strictement inchangés
        IF !($before.statut = "PUBLISHED" AND $after.statut = "ARCHIVED" 
             AND $after.parent_item = $before.parent_item
             AND $after.version = $before.version
             AND $after.libelle = $before.libelle
             AND $after.is_locked = true) {
            THROW "CATALOGUE_COMPOSITION_IMMUTABLE: Une composition scellée ne peut pas être modifiée.";
        };
    };
    -- Si tentative de modifier directement is_locked en arrière (true -> false)
    IF $before.is_locked = true AND $after.is_locked = false {
        THROW "CATALOGUE_COMPOSITION_IMMUTABLE: Le verrou d'immuabilité ne peut être désactivé.";
    };
};

-- ----------------------------------------------------------------------------
-- VERROU MOTEUR : Interdiction de suppression d'une composition scellée
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_composition_no_del ON TABLE catalogue_composition
WHEN $event = "DELETE"
THEN {
    -- Suppression en cascade de l'article parent (article privé supprimé avec son organisation) :
    -- l'article n'existe plus, la composition part avec lui
    IF $before.is_locked = true AND record::exists($before.parent_item) {
        THROW "CATALOGUE_COMPOSITION_IMMUTABLE: Une composition scellée ne peut pas être supprimée.";
    };
};
