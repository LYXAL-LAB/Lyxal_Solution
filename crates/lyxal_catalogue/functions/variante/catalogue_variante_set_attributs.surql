-- ============================================================================
-- FONCTION : fn::catalogue_variante_set_attributs
-- MODULE   : lyxal_catalogue
-- RÔLE     : Synchronisation atomique et canonique des attributs d'une variante
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_variante_set_attributs($params: object) {
    LET $var_id = <record<catalogue_variante>> $params.variante_id;
    LET $item_id = <record<catalogue_item>> $params.item_id;
    LET $pairs = $params.attributs; -- Tableau de couples [{ attribut: "catalogue_attribut:...", valeur: "catalogue_attribut_valeur:..." }, ...]
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

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
    FOR $p IN $pairs {
        LET $attr_id = <record<catalogue_attribut>> $p.attribut;
        LET $val_id = <record<catalogue_attribut_valeur>> $p.valeur;
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
    FOR $p IN $pairs {
        CREATE catalogue_variante_attribut CONTENT {
            item: $item_id,
            variante: $var_id,
            attribut: <record<catalogue_attribut>> $p.attribut,
            attribut_valeur: <record<catalogue_attribut_valeur>> $p.valeur
        };
    };

    LET $updated_var = (SELECT empreinte_attributs FROM ONLY $var_id);

    RETURN fn::result_ok({
        variante_id: $var_id,
        empreinte: $updated_var.empreinte_attributs,
        attributs_count: array::len($pairs)
    });
};
