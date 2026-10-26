-- ============================================================================
-- FONCTION : fn::catalogue_composition_clone_version
-- MODULE   : lyxal_catalogue
-- RÔLE     : Duplication d'une composition scellée vers une nouvelle version DRAFT
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_clone_version($params: object) {
    LET $source_comp_id = <record<catalogue_composition>> $params.source_composition_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $source = (SELECT * FROM ONLY $source_comp_id);
    IF $source == NONE {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_NOT_FOUND", $language, { id: <string> $source_comp_id });
    };

    -- Calcul du numéro de version suivant
    LET $existing_versions = (SELECT version FROM catalogue_composition WHERE parent_item = $source.parent_item ORDER BY version DESC);
    LET $max_v = IF array::len($existing_versions) > 0 { $existing_versions[0].version } ELSE { 1 };
    LET $new_version = $max_v + 1;

    -- Création du nouvel en-tête en DRAFT
    LET $created_comp = (CREATE catalogue_composition CONTENT {
        parent_item: $source.parent_item,
        version: $new_version,
        statut: "DRAFT",
        libelle: string::concat($source.libelle, " (v", <string> $new_version, ")"),
        is_locked: false,
        published_at: NONE,
        date_effet: time::now(),
        created_at: time::now(),
        updated_at: time::now()
    });

    LET $new_comp_id = $created_comp[0].id;

    -- Duplication exacte des lignes sources vers la nouvelle version DRAFT
    LET $source_lignes = (SELECT * FROM catalogue_composition_ligne WHERE composition = $source_comp_id);
    FOR $l IN $source_lignes {
        CREATE catalogue_composition_ligne CONTENT {
            composition: $new_comp_id,
            composant_item: $l.composant_item,
            composant_variante: $l.composant_variante,
            quantite: $l.quantite,
            unite: $l.unite,
            coefficient_perte: $l.coefficient_perte,
            ordre: $l.ordre,
            commentaire: $l.commentaire,
            created_at: time::now(),
            updated_at: time::now()
        };
    };

    RETURN fn::result_ok({
        source_id: $source_comp_id,
        new_composition: $created_comp[0],
        lignes_cloned: array::len($source_lignes)
    });
} COMMENT "Clone une composition (scellée ou active) vers une nouvelle version DRAFT éditable";
