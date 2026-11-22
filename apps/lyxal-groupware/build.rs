//! Embarque dans le binaire le manifeste et les fichiers SurrealQL déclarés dans `[resources]` de
//! chaque module hébergé (`lyxal_host::build::embed_modules`). La compilation échoue si un
//! fichier déclaré manque.

use std::env;
use std::path::PathBuf;

/// Modules installés par l'hôte, dans l'ordre de leurs dépendances : le socle, `lyxal_event`,
/// les dépendances de `lyxal_mail` (`lyxal_auth`, `lyxal_secrets`, `lyxal_storage`) et le
/// planificateur qui exécute sa maintenance (`lyxal_scheduler`), ajoutés au lot 4 (écart E5,
/// décision M13), puis `lyxal_mail`.
const MODULES: &[(&str, Option<&str>)] = &[
    ("lyxal_core", None),
    ("lyxal_error", None),
    ("lyxal_event", None),
    ("lyxal_auth", None),
    ("lyxal_secrets", None),
    ("lyxal_storage", None),
    ("lyxal_scheduler", None),
    ("lyxal_mail", None),
];

fn main() {
    let crates = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"))
        .join("../../crates");
    lyxal_host::build::embed_modules(&crates, MODULES);
}
