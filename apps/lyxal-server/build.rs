//! Embarque dans le binaire le manifeste et les fichiers SurrealQL déclarés dans `[resources]` de
//! chaque module hébergé. La compilation échoue si un fichier déclaré manque.

use std::env;
use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};

/// Modules installés par l'hôte, dans l'ordre de leurs dépendances.
const MODULES: &[(&str, Option<&str>)] = &[
    ("lyxal_core", None),
    ("lyxal_error", None),
    ("lyxal_event", None),
    ("lyxal_base", None),
    (
        "lyxal_pipeline_ingestion",
        Some("CARGO_FEATURE_MODULE_INGESTION"),
    ),
];

const RESOURCE_KEYS: &[&str] = &[
    "schemas",
    "functions",
    "error_definitions",
    "events",
    "seeds",
    "migrations",
];

fn main() {
    let crates = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"))
        .join("../../crates");
    let mut out = String::from("pub const EMBEDDED_MODULES: &[EmbeddedModule] = &[\n");
    for (name, feature) in MODULES {
        if let Some(feature) = feature {
            if env::var_os(feature).is_none() {
                continue;
            }
        }
        let dir = crates.join(name);
        let manifest_path = dir.join("manifest.toml");
        println!("cargo:rerun-if-changed={}", manifest_path.display());
        let manifest = fs::read_to_string(&manifest_path)
            .unwrap_or_else(|e| panic!("{} : {e}", manifest_path.display()));
        let parsed: toml::Value = toml::from_str(&manifest)
            .unwrap_or_else(|e| panic!("{} : {e}", manifest_path.display()));
        writeln!(
            out,
            "    EmbeddedModule {{\n        id: {name:?},\n        manifest: include_str!({:?}),\n        files: &[",
            canonical(&manifest_path)
        )
        .expect("écriture");
        let resources = parsed.get("resources").and_then(toml::Value::as_table);
        for key in RESOURCE_KEYS {
            let files = resources
                .and_then(|r| r.get(*key))
                .and_then(toml::Value::as_array)
                .cloned()
                .unwrap_or_default();
            for file in files {
                let file = file.as_str().unwrap_or_else(|| {
                    panic!("{name} : [resources].{key} doit lister des chemins")
                });
                let path = dir.join(file);
                println!("cargo:rerun-if-changed={}", path.display());
                writeln!(
                    out,
                    "            ({file:?}, include_str!({:?})),",
                    canonical(&path)
                )
                .expect("écriture");
            }
        }
        out.push_str("        ],\n    },\n");
    }
    out.push_str("];\n");
    let dest = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR")).join("embedded_modules.rs");
    fs::write(&dest, out).unwrap_or_else(|e| panic!("{} : {e}", dest.display()));
}

fn canonical(path: &Path) -> String {
    path.canonicalize()
        .unwrap_or_else(|e| panic!("fichier déclaré introuvable {} : {e}", path.display()))
        .display()
        .to_string()
}
