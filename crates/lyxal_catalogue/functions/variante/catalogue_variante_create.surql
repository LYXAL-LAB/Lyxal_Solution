-- ============================================================================
-- FONCTION : fn::catalogue_variante_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'une déclinaison physique/commerciale d'un item parent
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_variante_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            libelle: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
            reference_fabricant: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            code_barre: { pipeline: [{ rule: "gtin" }] },
            is_default: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            code: { pipeline: [{ rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 40);
    LET $item_id = $p.item_id;
    LET $code = $p.code;
    LET $raw_libelle = $p.libelle;
    LET $ref_fabricant = $p.reference_fabricant;
    LET $code_barre = $p.code_barre;
    LET $is_default = $p.is_default;
    LET $language = $p.language;

    LET $item = (SELECT * FROM ONLY $item_id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $item_id });
    };

    LET $libelle = $raw_libelle ?? string::concat($item.libelle, " - ", $code);

    -- Contrôle d'unicité du code variante
    LET $existing = (SELECT id FROM catalogue_variante WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_VARIANTE_ALREADY_EXISTS", $language, { code: $code });
    };

    -- Initialisation avec empreinte temporaire unique
    LET $initial_fingerprint = crypto::sha256(string::concat(<string> $item_id, ":", $code, ":", <string> time::now()));

    LET $created = (CREATE catalogue_variante CONTENT {
        item: $item_id,
        code: $code,
        libelle: $libelle,
        reference_fabricant: $ref_fabricant,
        code_barre: $code_barre,
        empreinte_attributs: $initial_fingerprint,
        is_default: $is_default,
        enabled: true,
        created_at: time::now(),
        updated_at: time::now()
    });

    -- Si la variante est marquée par défaut, désactiver les autres
    IF $is_default == true {
        UPDATE catalogue_variante SET is_default = false WHERE item = $item_id AND id != $created[0].id;
    };

    -- Marquer has_variants sur l'item parent
    UPDATE ONLY $item_id SET has_variants = true;

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une nouvelle déclinaison de variante pour un item parent";
