-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_create                                                   │
-- │  Création d'une nouvelle unité de mesure avec contrôle hiérarchique     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_create($params: object) {
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle;
    LET $raw_abreviation = $params.abreviation;
    LET $type = $params.type;
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    -- 1. Validation de présence du code
    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("BASE_UNITE_CODE_REQUIRED", $language, { field: "code" });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    IF string::len($code) < 1 OR string::len($code) > 32 OR !string::is_alphanum($code) {
        RETURN fn::error_result("BASE_UNITE_CODE_INVALID", $language, { field: "code", value: $code });
    };

    -- 2. Validation du libellé
    IF $raw_libelle == NONE OR string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("BASE_UNITE_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    LET $libelle = string::uppercase(string::trim($raw_libelle));
    IF string::len($libelle) < 1 OR string::len($libelle) > 128 {
        RETURN fn::error_result("BASE_UNITE_LIBELLE_INVALID", $language, { field: "libelle", value: $libelle });
    };

    -- 3. Validation de l'abréviation
    IF $raw_abreviation == NONE OR string::len(string::trim($raw_abreviation)) == 0 {
        RETURN fn::error_result("BASE_UNITE_ABREVIATION_REQUIRED", $language, { field: "abreviation" });
    };

    LET $abreviation = string::trim($raw_abreviation);
    IF string::len($abreviation) < 1 OR string::len($abreviation) > 10 {
        RETURN fn::error_result("BASE_UNITE_ABREVIATION_INVALID", $language, { field: "abreviation", value: $abreviation });
    };

    -- 4. Validation du type d'unité référencé
    IF $type == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_REQUIRED", $language, { field: "type" });
    };

    -- Normalisation du Record ID si passé sous forme de string ou d'id
    LET $type_id = IF type::is_record($type) {
        $type
    } ELSE IF type::is_string($type) {
        IF string::starts_with($type, "base_unite_type:") {
            type::record($type)
        } ELSE {
            type::record("base_unite_type", $type)
        }
    } ELSE {
        $type
    };

    -- Vérification de l'existence effective et du statut actif du type parent
    LET $parent_type = SELECT id, enabled FROM ONLY $type_id;
    IF $parent_type == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_INVALID", $language, { type: $type_id });
    };

    -- Règle CTO : Interdire la création d'une unité active sur un type désactivé
    IF $parent_type.enabled != true {
        RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, { type: $type_id });
    };

    -- 5. Pré-vérification d'unicité du code
    LET $existing = SELECT VALUE id FROM base_unite WHERE code = $code LIMIT 1;
    IF array::len($existing) > 0 {
        RETURN fn::error_result("BASE_UNITE_ALREADY_EXISTS", $language, { code: $code });
    };

    -- 6. Création déterministe
    LET $record_id = type::record("base_unite", $code);
    LET $created = CREATE ONLY $record_id CONTENT {
        code: $code,
        libelle: $libelle,
        abreviation: $abreviation,
        type: $type_id,
        enabled: true,
        created_at: time::now(),
        updated_at: time::now()
    };

    RETURN fn::result_ok($created);
} COMMENT "Crée une nouvelle unité de mesure avec contrôle hiérarchique du type d'unité parent";
