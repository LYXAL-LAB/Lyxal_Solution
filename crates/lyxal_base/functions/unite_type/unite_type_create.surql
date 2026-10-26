-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_type_create                                              │
-- │  Création d'un nouveau type d'unité de mesure                           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_type_create($params: object) {
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle;
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    -- 1. Validation de présence du code
    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_CODE_REQUIRED", $language, { field: "code" });
    };

    LET $code = string::uppercase(string::trim($raw_code));

    -- 2. Validation de format du code (1-32 caractères alphanumériques)
    IF string::len($code) < 1 OR string::len($code) > 32 OR !string::is_alphanum($code) {
        RETURN fn::error_result("BASE_UNITE_TYPE_CODE_INVALID", $language, { field: "code", value: $code });
    };

    -- 3. Validation de présence et longueur du libellé
    IF $raw_libelle == NONE OR string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    LET $libelle = string::uppercase(string::trim($raw_libelle));
    IF string::len($libelle) < 1 OR string::len($libelle) > 128 {
        RETURN fn::error_result("BASE_UNITE_TYPE_LIBELLE_INVALID", $language, { field: "libelle", value: $libelle });
    };

    -- 4. Pré-vérification d'unicité
    LET $existing = SELECT VALUE id FROM base_unite_type WHERE code = $code LIMIT 1;
    IF array::len($existing) > 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_ALREADY_EXISTS", $language, { code: $code });
    };

    -- 5. Création déterministe
    LET $record_id = type::record("base_unite_type", $code);
    LET $created = CREATE ONLY $record_id CONTENT {
        code: $code,
        libelle: $libelle,
        enabled: true,
        created_at: time::now(),
        updated_at: time::now()
    };

    RETURN fn::result_ok($created);
} COMMENT "Crée un nouveau type d'unité de mesure dans le référentiel";
