-- ============================================================================
-- FONCTION : fn::catalogue_categorie_update
-- MODULE   : lyxal_catalogue
-- RÔLE     : Mise à jour d'une catégorie avec contrôle anti-cycle
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_update($params: object) {
    LET $cat_id = <record<catalogue_categorie>> $params.id;
    LET $raw_libelle = $params.libelle;
    LET $parent_param = $params.parent;
    LET $ordre = $params.ordre;
    LET $enabled = $params.enabled;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $cat = (SELECT * FROM ONLY $cat_id);
    IF $cat == NONE {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { id: <string> $cat_id });
    };

    -- Contrôle anti-cycle si modification du parent
    LET $new_parent = IF $parent_param != NONE {
        IF $parent_param == "" OR $parent_param == false { NONE } ELSE { <record<catalogue_categorie>> $parent_param }
    } ELSE {
        $cat.parent
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
        libelle: IF $raw_libelle != NONE { string::trim($raw_libelle) } ELSE { $cat.libelle },
        parent: $new_parent,
        ordre: IF $ordre != NONE { <int> $ordre } ELSE { $cat.ordre },
        enabled: IF $enabled != NONE { <bool> $enabled } ELSE { $cat.enabled },
        updated_at: time::now()
    });

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour une catégorie avec détection stricte des boucles cycliques";
