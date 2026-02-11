use anyhow::Result;
use surrealdb_core::val::{Value, Bytes};
use surrealdb_core::err::Error;
use base_x;

pub mod base_x {
    use super::*;

    /// Résout un nom d'alphabet ou retourne l'alphabet brut s'il n'est pas reconnu.
    /// Cela permet d'utiliser des raccourcis comme "hex" ou "base58".
    fn resolve_alphabet(input: &str) -> &str {
        match input {
            "hex" | "base16" => "0123456789abcdef",
            "hex_upper" => "0123456789ABCDEF",
            "bitcoin" | "base58" => "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",
            "flickr" => "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ",
            "base62" => "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "base32" => "abcdefghijklmnopqrstuvwxyz234567",
            "z-base-32" => "ybndrfsktmcpqxot1uwisza345h7698j",
            // Si ce n'est pas un mot-clé, on utilise la chaîne brute (supporte UTF-8/Emojis)
            _ => input,
        }
    }

    /// SQL: encoding::base_x::encode(alphabet, data)
    pub fn encode((alph_input, data): (String, Bytes)) -> Result<Value> {
        let alph = resolve_alphabet(&alph_input);
        match base_x::encode(alph, &*data) {
            Ok(res) => Ok(Value::from(res)),
            Err(e) => Err(Error::InvalidArguments {
                name: "encoding::base_x::encode".into(),
                message: format!("Erreur d'encodage : {}", e),
            }.into()),
        }
    }

    /// SQL: encoding::base_x::decode(alphabet, string)
    pub fn decode((alph_input, input): (String, String)) -> Result<Value> {
        let alph = resolve_alphabet(&alph_input);
        match base_x::decode(alph, &input) {
            Ok(bin) => Ok(Value::from(Bytes::from(bin))),
            Err(e) => Err(Error::InvalidArguments {
                name: "encoding::base_x::decode".into(),
                message: format!("Erreur de décodage : {}", e),
            }.into()),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::base_x::*;
    use surrealdb_core::val::{Value, Bytes};

    #[test]
    fn test_resolve_shortcuts() {
        // Test resolution interne
        // Comme resolve_alphabet n'est pas pub, on teste via les fonctions publiques
        let alphabet = "hex".to_string();
        let data = Bytes::from(vec![1, 2, 3]);
        let encoded = encode((alphabet, data)).unwrap();
        assert_eq!(encoded, Value::from("010203"));
    }

    #[test]
    fn test_bitcoin_shortcut() {
        let alphabet = "bitcoin".to_string();
        let data = Bytes::from(vec![0, 0, 1]);
        let encoded = encode((alphabet, data)).unwrap();
        // Bitcoin base58 de [0, 0, 1] est "112" (deux zéros au début donnent deux '1')
        assert_eq!(encoded, Value::from("112"));
    }

    #[test]
    fn test_unicode_emoji() {
        let alphabet = "😐😀".to_string();
        let data = Bytes::from(vec![0x0F]); // 15 = 1111 en binaire -> "😀😀😀😀"
        let encoded = encode((alphabet.clone(), data)).unwrap();
        assert_eq!(encoded, Value::from("😀😀😀😀"));

        let decoded = decode((alphabet, "😀😀😀😀".to_string())).unwrap();
        if let Value::Bytes(bytes) = decoded {
            assert_eq!(&*bytes, &[0x0F]);
        }
    }
}
