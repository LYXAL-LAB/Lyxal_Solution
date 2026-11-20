//! Embarque dans le binaire le manifeste et les fichiers SurrealQL déclarés dans `[resources]` de
//! chaque module hébergé (`lyxal_host::build::embed_modules`). La compilation échoue si un
//! fichier déclaré manque.

use std::env;
use std::path::PathBuf;

/// Modules installés par l'hôte, dans l'ordre de leurs dépendances.
const MODULES: &[(&str, Option<&str>)] = &[
    ("lyxal_core", None),
    ("lyxal_error", None),
    ("lyxal_event", None),
    ("lyxal_auth", None),
    ("lyxal_i18n", None),
    ("lyxal_storage", None),
    ("lyxal_secrets", None),
    ("lyxal_scheduler", None),
    ("lyxal_notification", None),
    ("lyxal_base", None),
    ("lyxal_catalogue", None),
    (
        "lyxal_pipeline_ingestion",
        Some("CARGO_FEATURE_MODULE_INGESTION"),
    ),
];

fn main() {
    let crates = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"))
        .join("../../crates");
    lyxal_host::build::embed_modules(&crates, MODULES);
}
