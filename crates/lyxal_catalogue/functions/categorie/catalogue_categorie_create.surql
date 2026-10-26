-- ============================================================================
-- FONCTION : fn::catalogue_categorie_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'une catégorie dans la taxonomie arborescente
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_create($params: object) {
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle;
    LET $parent_id = IF $params.parent != NONE { <record<catalogue_categorie>> $params.parent } ELSE { NONE };
    LET $ordre = IF $params.ordre != NONE { <int> $params.ordre } ELSE { 0 };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_CODE_REQUIRED", $language, { field: "code" });
    };

    IF $raw_libelle == NONE OR string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    LET $libelle = string::trim($raw_libelle);

    -- Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_categorie WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_ALREADY_EXISTS", $language, { code: $code });
    };

    -- Contrôle du parent si spécifié
    IF $parent_id != NONE {
        LET $parent_rec = (SELECT * FROM ONLY $parent_id);
        IF $parent_rec == NONE {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { parent_id: <string> $parent_id });
        };
    };

    LET $created = (CREATE catalogue_categorie CONTENT {
        code: $code,
        libelle: $libelle,
        parent: $parent_id,
        ordre: $ordre,
        enabled: true,
        is_system: false,
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une nouvelle catégorie arborescente";
