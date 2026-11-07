-- ============================================================================
-- FONCTION : fn::ingestion_manifest_content
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Contenu exact qu'un manifeste publie : un élément par article VERIFIED du lot,
--            ordonné par référence (identifiant maître du catalogue)
-- APPEL    : interne (scellement par fn::ingestion_manifest_save, contrôle par
--            fn::ingestion_manifest_get_detail), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================
-- Élément : { item_ref, publication_action, commercial_proof, catalogue }, où catalogue est la
-- charge utile de fn::catalogue_item_create. C'est la seule correspondance staging → catalogue ;
-- la publication l'envoie telle quelle. item_ref = « ING- » suivi des 32 premiers caractères
-- (majuscules) du BLAKE3 de [fabricant, référence fabricant].

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_content($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $batch = $report.value.batch_id;

    LET $content = (SELECT * FROM ingestion_staged_item WHERE batch = $batch AND qualification = "VERIFIED").map(|$i| {
        LET $ref = string::concat("ING-", string::uppercase(string::slice(crypto::blake3(<string> [$i.fabricant, $i.reference_fabricant]), 0, 32)));
        LET $packaging = $i.conditionnement;
        RETURN {
            item_ref: $ref,
            publication_action: $i.publication_action,
            commercial_proof: $i.commercial_proof,
            catalogue: {
                code: $ref,
                type: $i.type_item,
                libelle: $i.libelle_commercial,
                unite_reference: $i.unite_reference,
                description: $i.description_technique,
                nature_reference: "COMMERCIALE",
                fabricant: $i.fabricant,
                marque: $i.marque,
                reference_fabricant: $i.reference_fabricant,
                code_barre: $i.code_barre_gtin,
                conditionnement: {
                    quantite: $packaging.quantite_par_colis ?? 1,
                    poids_kg: $packaging.poids_brut_kg,
                    dimensions: IF $packaging.dimensions == NONE { NONE } ELSE {
                        {
                            longueur: $packaging.dimensions.longueur_mm,
                            largeur: $packaging.dimensions.largeur_mm,
                            epaisseur: $packaging.dimensions.epaisseur_mm
                        }
                    }
                },
                unite_conditionnement: IF $packaging.unite_vente == NONE { NONE } ELSE {
                    string::concat("base_unite:", string::uppercase(string::trim($packaging.unite_vente)))
                },
                master_id: $ref
            }
        };
    });
    RETURN fn::result_ok(SELECT * FROM $content ORDER BY item_ref);
} COMMENT "Contenu exact publié par un manifeste : un élément { item_ref, publication_action, commercial_proof, catalogue } par article VERIFIED du lot, ordonné par référence ; catalogue est la charge utile de fn::catalogue_item_create";
