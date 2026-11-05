-- ============================================================================
-- FONCTION : fn::catalogue_variante_set_attributs
-- MODULE   : lyxal_catalogue
-- RÔLE     : Synchronisation atomique et canonique des attributs d'une variante
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_variante_set_attributs($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            variante_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_variante" } }], required: true },
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            attributs: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $var_id = $p.variante_id;
    LET $item_id = $p.item_id;
    LET $language = $p.language;
    -- Couples { attribut, valeur } : identifiants convertis par lyxal_core, erreur par position.
    LET $checked = array::map($p.attributs, |$pair, $index| {
        LET $attribut = fn::validation_record($pair.attribut, "catalogue_attribut");
        LET $valeur = fn::validation_record($pair.valeur, "catalogue_attribut_valeur");
        RETURN { index: $index, attribut: $attribut, valeur: $valeur };
    });
    LET $invalid = array::filter($checked, |$c| !$c.attribut.valid OR !$c.valeur.valid);
    IF array::len($invalid) > 0 {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $language, {
            fields: { attributs: array::map($invalid, |$c| { index: $c.index, attribut: $c.attribut.code, valeur: $c.valeur.code }) }
        });
    };
    LET $pairs = array::map($checked, |$c| { attribut: $c.attribut.value, valeur: $c.valeur.value });

    -- 1. Contrôle d'existence de la variante
    LET $var = (SELECT * FROM ONLY $var_id);
    IF $var = NONE {
        RETURN fn::error_result("CATALOGUE_VARIANTE_NOT_FOUND", $language, { id: <string> $var_id });
    };

    -- 2. Contrôle de rattachement de la variante à l'item
    IF $var.item != $item_id {
        RETURN fn::error_result("CATALOGUE_VARIANTE_ITEM_MISMATCH", $language, { variante_id: <string> $var_id, item_id: <string> $item_id });
    };

    -- 3. Validation de chaque couple attribut / valeur
    FOR $pair IN $pairs {
        LET $attr_id = $pair.attribut;
        LET $val_id = $pair.valeur;
        LET $attr_rec = (SELECT * FROM ONLY $attr_id);
        LET $val_rec = (SELECT * FROM ONLY $val_id);

        IF $attr_rec = NONE {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_NOT_FOUND", $language, { attribut: <string> $attr_id });
        };
        IF $val_rec = NONE {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND", $language, { valeur: <string> $val_id });
        };
        -- Contrôle d'appartenance de la valeur à l'attribut
        IF $val_rec.attribut != $attr_id {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_VALEUR_INVALID", $language, { attribut: <string> $attr_id, valeur: <string> $val_id });
        };
        -- Contrôle que l'attribut est bien un pilote de déclinaison
        IF $attr_rec.is_variant_driver != true {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_NOT_VARIANT_DRIVER", $language, { attribut: <string> $attr_id });
        };
    };

    -- 4. Suppression des anciennes lignes
    DELETE catalogue_variante_attribut WHERE variante = $var_id;

    -- 5. Création des nouvelles lignes (l'événement moteur evt_cva_recalc_fingerprint recalculera et synchronisera l'empreinte)
    FOR $pair IN $pairs {
        CREATE catalogue_variante_attribut CONTENT {
            item: $item_id,
            variante: $var_id,
            attribut: $pair.attribut,
            attribut_valeur: $pair.valeur
        };
    };

    LET $updated_var = (SELECT empreinte_attributs FROM ONLY $var_id);

    RETURN fn::result_ok({
        variante_id: $var_id,
        empreinte: $updated_var.empreinte_attributs,
        attributs_count: array::len($pairs)
    });
} COMMENT "Remplace les couples attribut / valeur pilotes d'une variante ; l'empreinte est recalculée par l'événement du schéma.";
