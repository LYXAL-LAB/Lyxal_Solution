# Lyxal Crypto — API V1, protocole enc:v2

Fondation Rust autonome pour secrets applicatifs, AES-256-GCM, Argon2id,
HMAC-SHA256, HKDF-SHA256, SHA-256 et BLAKE3. Package Cargo 0.1.0 inchangé ;
API de première production implémentée, réception CTO et qualification de déploiement encore distinctes.
Aucune dépendance DB, runtime ou module métier. Aucun engagement de certification.

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
- [Migration](MIGRATION_GUIDE.md) : ruptures assumées ; aucun fallback V1.
- [Rapport de phase B](IMPLEMENTATION_REPORT.md) : preuves et validations non exécutées.

`SecretContext` ne réalise aucune autorisation métier. Tenant et record sont exacts,
sans normalisation implicite. Un secret global requiert `SecretContext::global(purpose)` ;
aucun chiffrement public à AAD vide. `parse` n'authentifie pas une enveloppe.
`Current` authentifie avant de constater la clé active du snapshot capturé.

## Développement et contrôles

MSRV local : Rust 1.85 ; Linux x86_64 constitue la cible initiale de qualification.
Les consommateurs de l'ancienne API ne sont pas adaptés par ce chantier.

```sh
cargo test --locked -p lyxal_crypto --all-targets
cargo test --locked -p lyxal_crypto --doc
cargo +1.85.0 test --locked -p lyxal_crypto --all-targets
cargo clippy --locked -p lyxal_crypto --all-targets -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc --locked -p lyxal_crypto --no-deps
python3 crates/lyxal_crypto/tools/check_contracts.py
```

Le test de fichiers spéciaux nécessite la création locale d'un socket Unix et d'une FIFO.
Un bac à sable peut bloquer cette préparation : ne pas confondre ce refus avec un échec
cryptographique et ne pas supprimer l'assertion. Deux tests ignorés dans le lancement
ordinaire sont des helpers explicitement exécutés par les tests parents multiprocessus.

Fuzzing isolé (libfuzzer-sys 0.4.13, cargo-fuzz 0.13.2, nightly nécessaire) :

```sh
cd crates/lyxal_crypto
cargo +nightly fuzz build
cargo +nightly fuzz run envelope -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly fuzz run context -- -max_total_time=1800 -max_len=1500000 -rss_limit_mb=2048
cargo +nightly fuzz run phc -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
cargo +nightly fuzz run rotation -- -max_total_time=1800 -max_len=8192 -rss_limit_mb=2048
```

Les seeds versionnés sont dans `fuzz/seeds` ; copier ceux du domaine choisi vers
`fuzz/corpus/<cible>` pour reproduire la campagne ensemencée. Corpus générés, artifacts
et sorties de compilation sont ignorés. Le fuzzing PHC exerce parsing/budgets, pas un
calcul Argon2 coûteux pour chaque entrée. Les bancs fuzz/contrats possèdent leur propre
workspace/lockfile ; ils ne remplacent jamais le lockfile officiel de construction.
