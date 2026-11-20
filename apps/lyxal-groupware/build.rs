//! Embarque dans le binaire le manifeste et les fichiers SurrealQL déclarés dans `[resources]` de
//! chaque module hébergé (`lyxal_host::build::embed_modules`). La compilation échoue si un
//! fichier déclaré manque.

use std::env;
use std::path::PathBuf;

/// Modules installés par l'hôte, dans l'ordre de leurs dépendances (écart E6 du lot 3 : le
/// socle, `lyxal_event` et `lyxal_mail` seulement).
const MODULES: &[(&str, Option<&str>)] = &[
    ("lyxal_core", None),
    ("lyxal_error", None),
    ("lyxal_event", None),
    ("lyxal_mail", None),
];

fn main() {
    let crates = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"))
        .join("../../crates");
    lyxal_host::build::embed_modules(&crates, MODULES);
}
