// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture du corpus de `mail-parser` 0.11.9 (`resources/eml/rfc` et `malformed`, copiés dans
//! `tests/corpus/mail-parser/`, licence MIT : voir `SOURCES.md`) : chaque message est lu sans
//! arrêt, sa structure respecte les invariants, et les messages des RFC sont tous acceptés.

mod support;

use std::fs;
use std::path::PathBuf;

use lyxal_mail_proto::mime::{parse, MimeError, MimeLimits};
use support::check_structure;

fn corpus(folder: &str) -> Vec<(PathBuf, Vec<u8>)> {
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/corpus/mail-parser")
        .join(folder);
    let mut files: Vec<_> = fs::read_dir(&directory)
        .expect("dossier du corpus")
        .map(|entry| entry.expect("entrée du corpus").path())
        .filter(|path| path.extension().is_some_and(|extension| extension == "eml"))
        .collect();
    files.sort();
    assert!(!files.is_empty(), "corpus vide : {}", directory.display());
    files
        .into_iter()
        .map(|path| {
            let bytes = fs::read(&path).expect("message du corpus");
            (path, bytes)
        })
        .collect()
}

#[test]
fn lit_tous_les_messages_des_rfc() {
    for (path, raw) in corpus("rfc") {
        let message = parse(&raw, &MimeLimits::default())
            .unwrap_or_else(|error| panic!("{} : {error}", path.display()));
        check_structure(&message.structure, raw.len() as u64);
    }
}

#[test]
fn lit_les_messages_mal_formes_sans_arret() {
    let mut accepted = 0;
    for (path, raw) in corpus("malformed") {
        match parse(&raw, &MimeLimits::default()) {
            Ok(message) => {
                check_structure(&message.structure, raw.len() as u64);
                accepted += 1;
            }
            // Seuls refus admis pour un message non vide sous les limites par défaut.
            Err(MimeError::NoHeader) => {}
            Err(error) => panic!("{} : {error}", path.display()),
        }
    }
    assert!(accepted > 0);
}

#[test]
fn lit_le_corpus_coupe_a_chaque_octet() {
    // Messages tronqués : chaque préfixe des messages des RFC est lu ou refusé proprement.
    for (path, raw) in corpus("rfc").into_iter().take(4) {
        for end in 1..raw.len().min(2_048) {
            let prefix = &raw[..end];
            match parse(prefix, &MimeLimits::default()) {
                Ok(message) => {
                    check_structure(&message.structure, prefix.len() as u64);
                }
                Err(MimeError::NoHeader) => {}
                Err(error) => panic!("{} coupé à {end} : {error}", path.display()),
            }
        }
    }
}
