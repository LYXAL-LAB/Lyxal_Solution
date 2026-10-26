-- ============================================================================
-- FONCTION : fn::catalogue_composition_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Initialisation d'une nouvelle composition en statut DRAFT
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_create($params: object) {
    LET $parent_item_id = <record<catalogue_item>> $params.parent_item;
    LET $raw_libelle = $params.libelle;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $item = (SELECT * FROM ONLY $parent_item_id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $parent_item_id });
    };

    -- Détermine le numéro de version (max version existante + 1)
    LET $existing_versions = (SELECT version FROM catalogue_composition WHERE parent_item = $parent_item_id ORDER BY version DESC);
    LET $max_version = IF array::len($existing_versions) > 0 { $existing_versions[0].version } ELSE { 0 };
    LET $next_version = $max_version + 1;

    LET $libelle = IF $raw_libelle != NONE AND string::len(string::trim($raw_libelle)) > 0 {
        string::trim($raw_libelle)
    } ELSE {
        string::concat("Composition ", $item.libelle, " v", <string> $next_version)
    };

    LET $created = (CREATE catalogue_composition CONTENT {
        parent_item: $parent_item_id,
        version: $next_version,
        statut: "DRAFT",
        libelle: $libelle,
        is_locked: false,
        published_at: NONE,
        date_effet: time::now(),
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Initialise une nouvelle version de composition en statut DRAFT";
