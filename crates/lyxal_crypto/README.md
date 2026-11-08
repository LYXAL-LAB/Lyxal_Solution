# Lyxal Crypto — fondation cryptographique de Lyxal OS

Crate Rust unique pour la cryptographie de Lyxal OS (`.agents/rules/lyxal_standards_and_checklist.md`
§11.3) : secrets applicatifs chiffrés en AES-256-GCM (enveloppe `enc:v2`), Argon2id,
HMAC-SHA256, HKDF-SHA256, SHA-256, BLAKE3 et TOTP (RFC 6238). API figée, version Cargo 0.1.0.
Aucune dépendance Lyxal, base de données ou runtime. Bibliothèque non certifiée.
Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

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

| Contrôle | Où | Quand |
| :- | :- | :- |
| tests unitaires, d'intégration et de documentation | job « Tests » (`scripts/ci/test_all.sh`) | chaque PR |
| `cargo clippy -p lyxal_crypto --all-targets --all-features -- -D warnings` | job « Clippy » (`scripts/ci/clippy.sh`) | chaque PR |
| `tools/check_contracts.py` : bornes de traits réelles de l'API (banc isolé `tools/contracts/`, compilé hors ligne avec son verrou) | job « Cryptographie » (`scripts/ci/crypto_checks.sh`) | chaque PR |
| `tools/check_fixtures.py` : vecteurs `enc:v2` publiés recalculés par OpenSSL (`cryptography` 50.0.1, épinglée dans un environnement virtuel dédié), sans passer par le crate | job « Cryptographie » | chaque PR |
| `tools/run_fuzz.py` : fuzzing `envelope`, `context`, `phc`, `rotation`, LeakSanitizer actif ; Rust `nightly-2026-10-20` et `cargo-fuzz` 0.13.2 épinglés dans `scripts/ci/crypto_fuzz.sh` | workflow « Fuzzing lyxal_crypto » (`.github/workflows/crypto-fuzz.yml`) ; journaux, corpus et artefacts conservés 30 jours | 60 s par cible sur toute PR qui modifie le crate ; 600 s par cible chaque lundi et à la demande |

`scripts/ci/ci_local.sh` rejoue ces contrôles ; `scripts/ci/ci_local.sh --fuzz` y ajoute la
campagne courte (installe au besoin le nightly et `cargo-fuzz` épinglés).

MSRV du crate : Rust 1.85. Le test de fichiers spéciaux crée un socket Unix et une FIFO :
un bac à sable peut bloquer cette préparation, ce qui n'est pas un échec cryptographique.
Deux tests ignorés dans le lancement ordinaire sont des processus enfants exécutés par les
tests parents multiprocessus.

### Manuelle

Campagne longue locale : `python3 tools/run_fuzz.py --seconds 1800 --segments 3
--toolchain nightly-2026-10-20` (Linux x86_64).

Fuzzing cible par cible (libfuzzer-sys 0.4.13) :

```sh
cd crates/lyxal_crypto
cargo +nightly-2026-10-20 fuzz build
cargo +nightly-2026-10-20 fuzz run envelope -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly-2026-10-20 fuzz run context -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly-2026-10-20 fuzz run phc -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
cargo +nightly-2026-10-20 fuzz run rotation -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
```

Les seeds versionnés sont dans `fuzz/seeds` ; copier ceux du domaine choisi vers
`fuzz/corpus/<cible>` pour reproduire la campagne ensemencée. Corpus générés, artefacts
et sorties de compilation sont ignorés. Le fuzzing PHC exerce le parsing et les budgets, pas un
calcul Argon2 coûteux pour chaque entrée. Les bancs fuzz et contrats possèdent leur propre
workspace et lockfile ; ils ne remplacent jamais le lockfile du workspace.
