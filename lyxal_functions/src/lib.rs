//! Le Dispatcher Central du Hub de Fonctions Lyxal.
//! Contrairement à SurrealDB, nous gardons ce fichier court et modulaire.

pub mod encoding;

/// Macro simplifiée pour l'enregistrement futur dans le moteur SQL
#[macro_export]
macro_rules! lyxal_dispatch {
    ($name:expr, $args:expr) => {
        match $name {
            "encoding::base_x::encode" => $crate::encoding::base_x::encode,
            "encoding::base_x::decode" => $crate::encoding::base_x::decode,
            _ => return None,
        }
    };
}
