-- ============================================================================
-- FONCTION : fn::catalogue_variante_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'une déclinaison physique/commerciale d'un item parent
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_variante_create($params: object) {
    LET $item_id = <record<catalogue_item>> $params.item_id;
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle;
    LET $ref_fabricant = IF $params.reference_fabricant != NONE { string::trim($params.reference_fabricant) } ELSE { NONE };
    LET $code_barre = IF $params.code_barre != NONE { string::trim($params.code_barre) } ELSE { NONE };
    LET $is_default = IF $params.is_default != NONE { <bool> $params.is_default } ELSE { false };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $item = (SELECT * FROM ONLY $item_id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $item_id });
    };

    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("CATALOGUE_VARIANTE_CODE_REQUIRED", $language, { field: "code" });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    LET $libelle = IF $raw_libelle != NONE { string::trim($raw_libelle) } ELSE { string::concat($item.libelle, " - ", $code) };

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
