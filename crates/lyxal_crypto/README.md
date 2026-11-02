# Lyxal Crypto — fondation cryptographique de Lyxal OS

Crate Rust unique pour la cryptographie de Lyxal OS (`.agents/rules/lyxal_standards_and_checklist.md`
§11.3) : secrets applicatifs chiffrés en AES-256-GCM (enveloppe `enc:v2`), Argon2id,
HMAC-SHA256, HKDF-SHA256, SHA-256 et BLAKE3. API figée, version Cargo 0.1.0.
Aucune dépendance Lyxal, base de données ou runtime. Bibliothèque non certifiée.

## Exemple exécutable

```rust
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse,
                  SecretBytes, SecretContext, StaticKeyResolver};
use std::sync::Arc;
# fn main() -> Result<(), lyxal_crypto::CryptoError> {
let mut builder = KeyRingBuilder::new();
builder.insert(KeyId::parse("key-2026")?, EncryptionKey::generate()?, KeyUse::Active)?;
let engine = CryptoEngine::new(StaticKeyResolver::new(Arc::new(builder.build()?)));
let context = SecretContext::with_tenant("Acme", "booking", "setting", "smtp_1", "password")?;
let secret = SecretBytes::new(b"fictitious example".to_vec())?;
let envelope = engine.seal(&secret, &context)?;
let persisted_ciphertext = envelope.encode();
let parsed = lyxal_crypto::EncryptedEnvelope::parse(&persisted_ciphertext)?;
let opened = engine.open(&parsed, &context)?;
assert_eq!(opened.expose_secret(), secret.expose_secret());
# Ok(())
# }
```

La génération de clé ici est éphémère. En production, provisionner et sauvegarder
les clés via l'hôte avant toute donnée dépendante ; ne pas générer une nouvelle clé
à chaque redémarrage. Les contenus exposés explicitement ne doivent pas être journalisés.

## Contrats

- [API publique](API_CONTRACT.md) : types opaques, snapshots, erreurs, limites.
- [Protocole V2](ENVELOPE_FORMAT_V2.md) : octets exacts, canonisation, fixtures indépendantes.
- [Sécurité](SECURITY.md) : menaces, quotas hôte, mémoire et stockage.

`enc:v2` est le seul format lu et produit. `SecretContext` ne réalise aucune autorisation
métier. Tenant et record sont exacts, sans normalisation implicite. Un secret global requiert
`SecretContext::global(purpose)` ; aucun chiffrement public à AAD vide. `parse` n'authentifie
pas une enveloppe. `Current` authentifie avant de constater la clé active du snapshot capturé.

## Vérification

### Automatique (CI)

```sh
cargo test -p lyxal_crypto --all-targets
cargo test -p lyxal_crypto --doc
cargo clippy -p lyxal_crypto --all-targets -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc -p lyxal_crypto --no-deps
```

MSRV du crate : Rust 1.85. Le test de fichiers spéciaux crée un socket Unix et une FIFO :
un bac à sable peut bloquer cette préparation, ce qui n'est pas un échec cryptographique.
Deux tests ignorés dans le lancement ordinaire sont des processus enfants exécutés par les
tests parents multiprocessus.

### Manuelle

Outils indépendants du crate, lancés à la demande (hors CI) :

| Outil | Vérifie | Prérequis |
| :- | :- | :- |
| `python3 tools/check_contracts.py` | bornes de traits réelles de l'API (banc isolé `tools/contracts/`) | dépendances du banc en cache (`--offline --locked`) |
| `python3 tools/check_fixtures.py` | vecteurs publiés recalculés par OpenSSL, sans passer par le crate | module Python `cryptography` |
| `python3 tools/run_fuzz.py --seconds 1800 --segments 3` | campagnes de fuzz `envelope`, `context`, `phc`, `rotation` | Rust nightly, `cargo-fuzz` 0.13.2 |

Fuzzing cible par cible (libfuzzer-sys 0.4.13) :

```sh
cd crates/lyxal_crypto
cargo +nightly fuzz build
cargo +nightly fuzz run envelope -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly fuzz run context -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly fuzz run phc -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
cargo +nightly fuzz run rotation -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
```

Les seeds versionnés sont dans `fuzz/seeds` ; copier ceux du domaine choisi vers
`fuzz/corpus/<cible>` pour reproduire la campagne ensemencée. Corpus générés, artefacts
et sorties de compilation sont ignorés. Le fuzzing PHC exerce le parsing et les budgets, pas un
calcul Argon2 coûteux pour chaque entrée. Les bancs fuzz et contrats possèdent leur propre
workspace et lockfile ; ils ne remplacent jamais le lockfile du workspace.
