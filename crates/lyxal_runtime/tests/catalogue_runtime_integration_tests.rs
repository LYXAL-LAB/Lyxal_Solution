use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{FilesystemResourceProvider, ModuleResource, ResourceDiscovery, ResourceKind};
use lyxal_runtime::schema::SchemaImportPlan;
use lyxal_runtime::types::ModuleId;
use std::fs;
use std::path::PathBuf;

#[test]
fn test_manifest_parser_supports_catalogue_manifest() {
    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("lyxal_catalogue")
        .join("manifest.toml");

    let manifest = ManifestParser::parse_file(&manifest_path).expect("Failed to parse catalogue manifest.toml");
    
    assert_eq!(manifest.id.as_str(), "lyxal_catalogue");
    assert_eq!(manifest.name, "Lyxal Catalogue");
    assert_eq!(manifest.version.to_string(), "1.0.0");
    assert_eq!(manifest.capabilities, vec!["database"]);
    assert_eq!(manifest.dependencies.len(), 2);
    assert_eq!(manifest.dependencies[0].id.as_str(), "lyxal_core");
    assert_eq!(manifest.dependencies[1].id.as_str(), "lyxal_base");
    assert!(manifest.runtime.is_some());
    assert_eq!(manifest.runtime.as_ref().unwrap().min_version.as_ref().unwrap().to_string(), ">=0.1.0");
}

#[tokio::test]
async fn test_resource_discovery_analysis_on_catalogue() {
    let catalogue_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("lyxal_catalogue");

    let provider = FilesystemResourceProvider::new(&catalogue_path);

    // 1. Découverte standard via ResourceDiscovery
    let discovered = ResourceDiscovery::discover_schema_resources(&provider)
        .await
        .expect("Resource discovery failed");

    println!("Discovered resources count: {}", discovered.len());
    for res in &discovered {
        println!(" - {} (kind: {:?}, order: {})", res.logical_path, res.kind, res.kind.execution_order());
    }

    // Analyse architecturale :
    // ResourceDiscovery liste les 12 fichiers de schema/*.surql, mais les classe comme Migration (ordre 8)
    // car leurs noms sont 01_... à 12_... et non pas tables.surql, fields.surql, etc.
    // De plus, functions/ et seeds/ sont situés hors de schema/ et ne sont donc pas découverts nativement.
    assert_eq!(discovered.len(), 12, "Les 12 fichiers de schema/ sont découverts par list_resources('schema')");
}

#[test]
fn test_catalogue_resources_loading_order_plan() {
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let catalogue_dir = manifest_dir
        .parent()
        .unwrap()
        .join("lyxal_catalogue");

    // 1. Schémas déclarés (12 tables dans l'ordre 01 à 12)
    let schema_files = [
        "schema/01_catalogue_type.surql",
        "schema/02_catalogue_item.surql",
        "schema/03_catalogue_categorie.surql",
        "schema/04_catalogue_item_categorie.surql",
        "schema/05_catalogue_attribut.surql",
        "schema/06_catalogue_attribut_valeur.surql",
        "schema/07_catalogue_variante.surql",
        "schema/08_catalogue_variante_attribut.surql",
        "schema/09_catalogue_composition.surql",
        "schema/10_catalogue_composition_ligne.surql",
        "schema/11_catalogue_relation_type.surql",
        "schema/12_catalogue_relation.surql",
    ];

    let mut resources = Vec::new();

    for s in schema_files {
        let path = catalogue_dir.join(s);
        assert!(path.exists(), "Fichier de schéma manquant: {}", s);
        let content = fs::read_to_string(&path).unwrap();
        resources.push(ModuleResource::new(s, ResourceKind::Tables, content));
    }

    // 2. Seeds (3 fichiers : error_definitions, type_initial, relation_type_initial)
    let seed_files = [
        "seeds/error_definitions.surql",
        "seeds/catalogue_type_initial.surql",
        "seeds/catalogue_relation_type_initial.surql",
    ];
    for s in seed_files {
        let path = catalogue_dir.join(s);
        assert!(path.exists(), "Fichier de seed manquant: {}", s);
        let content = fs::read_to_string(&path).unwrap();
        resources.push(ModuleResource::new(s, ResourceKind::Seeds, content));
    }

    // 3. Fonctions (22 fichiers)
    let func_files = [
        "functions/type/catalogue_type_list.surql",
        "functions/categorie/catalogue_categorie_create.surql",
        "functions/categorie/catalogue_categorie_tree.surql",
        "functions/categorie/catalogue_categorie_update.surql",
        "functions/categorie/catalogue_categorie_delete.surql",
        "functions/item/catalogue_item_create.surql",
        "functions/item/catalogue_item_get.surql",
        "functions/item/catalogue_item_list.surql",
        "functions/item/catalogue_item_update.surql",
        "functions/item/catalogue_item_delete.surql",
        "functions/attribut/catalogue_attribut_create.surql",
        "functions/attribut/catalogue_attribut_valeur_create.surql",
        "functions/attribut/catalogue_attribut_set_static.surql",
        "functions/variante/catalogue_variante_create.surql",
        "functions/variante/catalogue_variante_set_attributs.surql",
        "functions/composition/catalogue_composition_check_cycle.surql",
        "functions/composition/catalogue_composition_create.surql",
        "functions/composition/catalogue_composition_add_line.surql",
        "functions/composition/catalogue_composition_publish.surql",
        "functions/composition/catalogue_composition_clone_version.surql",
        "functions/relation/catalogue_relation_create.surql",
        "functions/relation/catalogue_relation_delete.surql",
    ];
    for f in func_files {
        let path = catalogue_dir.join(f);
        assert!(path.exists(), "Fichier de fonction manquant: {}", f);
        let content = fs::read_to_string(&path).unwrap();
        resources.push(ModuleResource::new(f, ResourceKind::Functions, content));
    }

    let plan = SchemaImportPlan::new(ModuleId::new("lyxal_catalogue"), resources);
    assert_eq!(plan.len(), 12 + 3 + 22, "Le plan doit contenir les 37 ressources");

    // Vérification de l'ordre officiel : Tables (ordre 1) -> Functions (ordre 4) -> Seeds (ordre 7)
    let ordered_resources = plan.resources();
    
    // Les 12 premières ressources doivent être les tables
    for i in 0..12 {
        assert_eq!(ordered_resources[i].kind, ResourceKind::Tables);
    }
    // Les 22 suivantes doivent être les fonctions
    for i in 12..34 {
        assert_eq!(ordered_resources[i].kind, ResourceKind::Functions);
    }
    // Les 3 dernières doivent être les seeds
    for i in 34..37 {
        assert_eq!(ordered_resources[i].kind, ResourceKind::Seeds);
    }

    println!("SchemaImportPlan successfully ordered 37 catalogue resources according to official Lyxal OS lifecycle order!");
}
