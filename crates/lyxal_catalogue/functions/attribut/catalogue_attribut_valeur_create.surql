-- ============================================================================
-- FONCTION : fn::catalogue_attribut_valeur_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Définition d'une valeur autorisée pour un attribut typé
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_attribut_valeur_create($params: object) {
    LET $attribut_id = <record<catalogue_attribut>> $params.attribut;
    LET $raw_code = $params.code;
    LET $raw_libelle = $params.libelle_affichage;
    LET $valeur_texte = $params.valeur_texte;
    LET $valeur_nombre = $params.valeur_nombre;
    LET $valeur_booleen = $params.valeur_booleen;
    LET $valeur_date = $params.valeur_date;
    LET $ordre = IF $params.ordre != NONE { <int> $params.ordre } ELSE { 0 };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $attr = (SELECT * FROM ONLY $attribut_id);
    IF $attr == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_NOT_FOUND", $language, { attribut: <string> $attribut_id });
    };

    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_VALEUR_CODE_REQUIRED", $language, { field: "code" });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    LET $libelle = IF $raw_libelle != NONE { string::trim($raw_libelle) } ELSE { $code };

    -- Contrôle de cohérence avec le type de donnée
    IF $attr.type_donnee == "NUMBER" AND $valeur_nombre == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "NUMBER" });
    };
    IF $attr.type_donnee == "BOOLEAN" AND $valeur_booleen == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "BOOLEAN" });
    };
    IF $attr.type_donnee == "DATE" AND $valeur_date == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "DATE" });
    };

    LET $created = (CREATE catalogue_attribut_valeur CONTENT {
        attribut: $attribut_id,
        code: $code,
        valeur_texte: $valeur_texte,
        valeur_nombre: IF $valeur_nombre != NONE { <decimal> $valeur_nombre } ELSE { NONE },
        valeur_booleen: IF $valeur_booleen != NONE { <bool> $valeur_booleen } ELSE { NONE },
        valeur_date: IF $valeur_date != NONE { <datetime> $valeur_date } ELSE { NONE },
        libelle_affichage: $libelle,
        ordre: $ordre,
        enabled: true,
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Ajoute une valeur autorisée typée pour un attribut donné";
