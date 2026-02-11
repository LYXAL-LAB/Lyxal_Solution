# Modifications Core Engine (Rust Integration)

## Fichiers Cibles
1. `crates/core/src/fnc/mod.rs` : Enregistrement du nouveau module de fonctions.
2. `crates/core/src/fnc/crypto.rs` : Implémentation de `ed25519`.
3. `crates/core/src/fnc/http.rs` : Extension pour le streaming hash.

## Primitives Crypto
Utilisation de la crate `ed25519-dalek` :
- `signature_sign(message: string, secret: string) -> string`
- `signature_verify(message: string, sig: string, pubkey: string) -> bool`

## Automatisation SMTP
Utilisation d'un `DEFINE EVENT` sur la table `expects` pour déclencher une notification via une fonction `http::post` interne vers un service de mail souverain ou un worker interne.

