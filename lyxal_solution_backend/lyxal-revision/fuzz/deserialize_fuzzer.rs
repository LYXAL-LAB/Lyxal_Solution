#![no_main]
use libfuzzer_sys::fuzz_target;
use revision::{revisioned, from_slice};

#[revisioned(revision = 1)]
#[derive(Debug, PartialEq)]
struct FuzzStruct {
    a: u32,
    b: String,
    c: Vec<u64>,
}

fuzz_target!(|data: &[u8]| {
    // Le fuzzer va injecter des données aléatoires ici.
    // L'objectif est de vérifier que from_slice renvoie une Err(..) 
    // proprement sans jamais faire de Panic ou d'OOM.
    let _ = from_slice::<FuzzStruct>(data);
});