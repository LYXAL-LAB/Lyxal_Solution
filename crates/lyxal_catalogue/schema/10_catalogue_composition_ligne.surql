-- ============================================================================
-- TABLE  : catalogue_composition_ligne
-- MODULE : lyxal_catalogue
-- RÔLE   : Lignes de composants détaillées avec protection moteur
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_composition_ligne
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::catalogue_access({ is_custom: composition.parent_item.is_custom, tenant: composition.parent_item.tenant, action: "read" })
        FOR create, update, delete WHERE fn::catalogue_access({ is_custom: composition.parent_item.is_custom, tenant: composition.parent_item.tenant, action: "write" })
    COMMENT "Composants détaillés d'une composition";


DEFINE FIELD OVERWRITE composition ON TABLE catalogue_composition_ligne
    TYPE record<catalogue_composition>
    REFERENCE ON DELETE CASCADE
    COMMENT "Composition parente propriétaire";

DEFINE FIELD OVERWRITE composant_item ON TABLE catalogue_composition_ligne
    TYPE record<catalogue_item>
    REFERENCE
    COMMENT "Item consommé en composant";

DEFINE FIELD OVERWRITE composant_variante ON TABLE catalogue_composition_ligne
    TYPE option<record<catalogue_variante>>
    REFERENCE
    COMMENT "Variante précise du composant";

DEFINE FIELD OVERWRITE quantite ON TABLE catalogue_composition_ligne
    TYPE decimal
    ASSERT $value > 0
    COMMENT "Quantité de composant par unité d'ouvrage/ensemble";

DEFINE FIELD OVERWRITE unite ON TABLE catalogue_composition_ligne
    TYPE record<base_unite>
    REFERENCE ON DELETE REJECT
    COMMENT "Unité de consommation";

DEFINE FIELD OVERWRITE coefficient_perte ON TABLE catalogue_composition_ligne
    TYPE decimal
    DEFAULT 1.0
    ASSERT $value >= 1.0
    COMMENT "Coefficient de perte/chute (1.0 = aucune perte, 1.05 = 5% de perte)";

DEFINE FIELD OVERWRITE ordre ON TABLE catalogue_composition_ligne
    TYPE int
    DEFAULT 0
    COMMENT "Ordre d'affichage des composants";

DEFINE FIELD OVERWRITE commentaire ON TABLE catalogue_composition_ligne
    TYPE option<string>
    COMMENT "Remarque technique ou condition de pose";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_composition_ligne
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date d'ajout";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_composition_ligne
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de modification";

-- Unicité d'un composant (item + variante) au sein d'une composition
DEFINE INDEX OVERWRITE idx_comp_ligne_unique ON TABLE catalogue_composition_ligne 
    FIELDS composition, composant_item, composant_variante UNIQUE;

-- ----------------------------------------------------------------------------
-- VERROU MOTEUR : Interdiction de modifier les lignes si la composition parente est scellée
-- Contrôle simultané de l'ancienne ($before.composition) et de la nouvelle ($after.composition)
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_comp_ligne_guard ON TABLE catalogue_composition_ligne
WHEN ($event = "CREATE" OR $event = "UPDATE" OR $event = "DELETE")
THEN {
    -- 1. Vérification de la composition cible lors de CREATE ou UPDATE
    IF $event = "CREATE" OR $event = "UPDATE" {
        LET $locked_after = (SELECT VALUE is_locked FROM ONLY $after.composition);
        IF $locked_after = true {
            THROW "CATALOGUE_COMPOSITION_IMMUTABLE: Impossible d'ajouter ou modifier une ligne sur une composition scellée.";
        };
    };
    -- 2. Vérification de la composition source lors de DELETE ou déplacement de ligne (UPDATE)
    IF $event = "DELETE" OR $event = "UPDATE" {
        LET $locked_before = (SELECT VALUE is_locked FROM ONLY $before.composition);
        -- Ligne supprimée avec sa composition (cascade) : la composition n'existe plus
        IF $locked_before = true AND record::exists($before.composition) {
            THROW "CATALOGUE_COMPOSITION_IMMUTABLE: Impossible de supprimer ou déplacer une ligne d'une composition scellée.";
        };
    };
};
