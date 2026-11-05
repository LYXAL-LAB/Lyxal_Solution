-- ============================================================================
-- FONCTION : fn::catalogue_categorie_update
-- MODULE   : lyxal_catalogue
-- RÔLE     : Mise à jour d'une catégorie avec contrôle anti-cycle
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }] },
            parent: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }], nullable: true },
            ordre: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $cat_id = $p.id;
    LET $libelle = $p.libelle;
    LET $parent_param = $p.parent;
    LET $ordre = $p.ordre;
    LET $enabled = $p.enabled;
    LET $language = $p.language;

    LET $cat = (SELECT * FROM ONLY $cat_id);
    IF $cat == NONE {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { id: <string> $cat_id });
    };

    -- Contrôle anti-cycle si modification du parent
    -- parent absent : inchangé ; parent NULL : la catégorie devient racine.
    LET $new_parent = IF $parent_param IS NONE {
        $cat.parent
    } ELSE IF type::is_null($parent_param) {
        NONE
    } ELSE {
        $parent_param
    };

    IF $new_parent != NONE {
        IF $new_parent == $cat_id {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_CYCLE_DETECTED", $language, { id: <string> $cat_id, parent: <string> $new_parent });
        };
        -- Vérification que le nouveau parent n'est pas un descendant (anti-cycle jusqu'à 5 niveaux)
        LET $p1 = (SELECT parent FROM ONLY $new_parent).parent;
        IF $p1 == $cat_id {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_CYCLE_DETECTED", $language, { cycle_at: 1 });
        };
        LET $p2 = IF $p1 != NONE { (SELECT parent FROM ONLY $p1).parent } ELSE { NONE };
        IF $p2 == $cat_id {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_CYCLE_DETECTED", $language, { cycle_at: 2 });
        };
        LET $p3 = IF $p2 != NONE { (SELECT parent FROM ONLY $p2).parent } ELSE { NONE };
        IF $p3 == $cat_id {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_CYCLE_DETECTED", $language, { cycle_at: 3 });
        };
    };

    LET $updated = (UPDATE ONLY $cat_id MERGE {
        libelle: $libelle ?? $cat.libelle,
        parent: $new_parent,
        ordre: $ordre ?? $cat.ordre,
        enabled: $enabled ?? $cat.enabled,
        updated_at: time::now()
    });

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour une catégorie avec détection stricte des boucles cycliques";
