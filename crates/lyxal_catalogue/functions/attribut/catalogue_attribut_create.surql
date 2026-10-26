-- ============================================================================
-- FONCTION : fn::catalogue_attribut_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Définition d'une caractéristique typée au dictionnaire
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_attribut_create($params: object) {
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle;
    LET $type_donnee = $params.type_donnee;
    LET $unite_id = IF $params.unite != NONE { <record<base_unite>> $params.unite } ELSE { NONE };
    LET $is_variant_driver = IF $params.is_variant_driver != NONE { <bool> $params.is_variant_driver } ELSE { false };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_CODE_REQUIRED", $language, { field: "code" });
    };
    IF $raw_libelle == NONE OR string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };
    IF $type_donnee == NONE OR !($type_donnee IN ["STRING", "NUMBER", "BOOLEAN", "DATE", "COLOR"]) {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_INVALID", $language, { type_donnee: $type_donnee });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    LET $libelle = string::trim($raw_libelle);

    -- Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_attribut WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_ALREADY_EXISTS", $language, { code: $code });
    };

    -- Contrôle d'unité si spécifiée
    IF $unite_id != NONE {
        LET $unite_rec = (SELECT * FROM ONLY $unite_id);
        IF $unite_rec == NONE OR $unite_rec.enabled != true {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_UNITE_INVALID", $language, { unite: <string> $unite_id });
        };
    };

    LET $created = (CREATE catalogue_attribut CONTENT {
        code: $code,
        libelle: $libelle,
        type_donnee: $type_donnee,
        unite: $unite_id,
        is_variant_driver: $is_variant_driver,
        enabled: true,
        is_system: false,
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une caractéristique typée dans le dictionnaire des attributs";
