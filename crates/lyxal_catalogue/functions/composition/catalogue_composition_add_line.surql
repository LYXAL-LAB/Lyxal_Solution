-- ============================================================================
-- FONCTION : fn::catalogue_composition_add_line
-- MODULE   : lyxal_catalogue
-- RÔLE     : Ajout d'une ligne de composant avec contrôle anti-cycle récursif et d'immuabilité
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_add_line($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            composition_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_composition" } }], required: true },
            composant_item: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            composant_variante: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_variante" } }] },
            quantite: { pipeline: [{ rule: "positive_number" }], required: true },
            unite: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }], required: true },
            coefficient_perte: { pipeline: [{ rule: "number", options: { min_value: 1 } }], default: 1 },
            ordre: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            commentaire: { pipeline: [{ rule: "optional_string", options: { max_length: 1000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $comp_id = $p.composition_id;
    LET $composant_item_id = $p.composant_item;
    LET $composant_variante_id = $p.composant_variante;
    LET $quantite = <decimal> $p.quantite;
    LET $unite_id = $p.unite;
    LET $coeff = <decimal> $p.coefficient_perte;
    LET $ordre = $p.ordre;
    LET $commentaire = $p.commentaire;
    LET $language = $p.language;

    -- 1. Contrôle d'existence et statut de la composition
    LET $comp = (SELECT * FROM ONLY $comp_id);
    IF $comp == NONE {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_NOT_FOUND", $language, { id: <string> $comp_id });
    };
    IF $comp.is_locked == true OR $comp.statut != "DRAFT" {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_IMMUTABLE", $language, { composition: <string> $comp_id });
    };

    -- 2. Contrôle anti-cycle récursif complet (Direct et Indirect A -> B -> C -> A)
    LET $has_cycle = fn::catalogue_composition_check_cycle({
        parent_item: $comp.parent_item,
        composant_item: $composant_item_id
    });
    IF $has_cycle == true {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_CYCLE_DETECTED", $language, { 
            parent: <string> $comp.parent_item, 
            composant: <string> $composant_item_id 
        });
    };

    -- 3. Contrôle du composant item
    LET $item_rec = (SELECT * FROM ONLY $composant_item_id);
    IF $item_rec == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $composant_item_id });
    };

    -- 4. Contrôle de variante si l'item a des déclinaisons
    IF $item_rec.has_variants == true AND $composant_variante_id == NONE {
        RETURN fn::error_result("CATALOGUE_VARIANTE_REQUIRES_SPECIFIC", $language, { item: <string> $composant_item_id });
    };
    IF $composant_variante_id != NONE {
        LET $var_rec = (SELECT * FROM ONLY $composant_variante_id);
        IF $var_rec == NONE OR $var_rec.item != $composant_item_id {
            RETURN fn::error_result("CATALOGUE_VARIANTE_ITEM_MISMATCH", $language, { variante: <string> $composant_variante_id, item: <string> $composant_item_id });
        };
    };

    -- 5. Contrôle de l'unité de consommation
    LET $unite_rec = (SELECT * FROM ONLY $unite_id);
    IF $unite_rec == NONE {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_UNITE_INCOMPATIBLE", $language, { unite: <string> $unite_id });
    };

    -- 6. Création de la ligne
    LET $created = (CREATE catalogue_composition_ligne CONTENT {
        composition: $comp_id,
        composant_item: $composant_item_id,
        composant_variante: $composant_variante_id,
        quantite: $quantite,
        unite: $unite_id,
        coefficient_perte: $coeff,
        ordre: $ordre,
        commentaire: $commentaire,
        created_at: time::now(),
        updated_at: time::now()
    });
    IF array::len($created) == 0 {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_composition_ligne" });
    };

    RETURN fn::result_ok($created[0]);
} COMMENT "Ajoute une ligne de composant avec détection récursive des cycles";
