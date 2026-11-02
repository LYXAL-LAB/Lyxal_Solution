# Audit de reprise — `lyxal_crypto`

Audit en lecture seule (skill `lyxal-audit`), état de `main` au 2026-11-02, après la reprise de
`lyxal_surreal` (#35 à #37). Supprimé à la clôture de la reprise (`AGENTS.md` §0.3.4).

## 1. Périmètre et position dans le graphe

* Crate `lyxal_crypto` `0.1.0` (version du workspace), **fondation cryptographique** (§5.2,
  §6, §11.3) : aucune dépendance Lyxal, aucun accès base de données, aucun `lyxal_runtime`.
* Dépendances : primitives RustCrypto épinglées (`aes-gcm`, `aes`, `ghash`, `polyval`,
  `argon2`), `sha2`, `blake3`, `hmac`, `hkdf`, `subtle`, `zeroize`, `rand_core` (`OsRng`),
  `base64`, `hex`, `thiserror`.
* Dépendants du workspace : `lyxal_surreal` (`SecretString`), `lyxal_runtime` et
  `lyxal_pipeline_ingestion` (hachage, types sensibles). Hors workspace : `lyxal_booking/engine`.
* Fichiers inspectés :
  * code : `src/*.rs`, `src/providers/*.rs`, `Cargo.toml`, intégralement ;
  * tests : la liste de `tests/it/` et les tests unitaires ;
  * documents et outils : `README.md`, `API_CONTRACT.md`, `ENVELOPE_FORMAT_V1.md`,
    `ENVELOPE_FORMAT_V2.md`, `SECURITY.md`, `MIGRATION_GUIDE.md`, `CHANGELOG.md`, `roadmap.md`,
    `fuzz/`, `tools/`, `validation/` (78 fichiers).
* Pas de SurrealQL ni de `manifest.toml` : sans objet (crate Rust pur, comme prévu au Contrôle 2).

## 2. Synthèse et verdict

**NON CONFORME** : 0 écart P0, 1 écart P1 (appelant hors workspace), 4 écarts P2.

Le code est de très bonne qualité et conforme au §11.3 :
* `#![forbid(unsafe_code)]` et `#![deny(missing_docs)]` ;
* types sensibles opaques (`SecretBytes`, `SecretString`, `EncryptionKey`, `HmacKey`), non
  clonables, sans `Deref`, effacés à la libération, `Debug` masqué ;
* AAD jamais vide, liant suite, version, `key_id`, domaine et identité ;
* AES-256-GCM avec nonce `OsRng` et aucune solution de repli en cas d'échec du générateur ;
* enveloppe `enc:v2` stricte (pas de lecture `enc:v1`) ;
* trousseaux immuables avec tombstones et validation de succession ;
* Argon2id borné, HMAC à comparaison en temps constant, HKDF borné ;
* aucun `unwrap`, `expect` ni `panic!` hors tests.

Les écarts portent :
* sur la dette documentaire d'une « phase B » passée : journaux de validation, guide de
  migration, changelog, archive `enc:v1`, statuts « réception CTO en attente » ;
* sur des outils de vérification que la CI ne lance pas ;
* sur `lyxal_booking`, qui utilise encore l'ancienne API supprimée.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier | Preuve | Correction recommandée |
| :- | :- | :- | :- | :- | :- |
| C-01 | P1 | Contrôle 7 bis (rupture non répercutée) | `lyxal_booking/engine/src/**` | L'engine de booking (hors workspace, non compilé par la CI) appelle l'ancienne API, absente du crate : `encrypt_secret` (22 appels), `decrypt_secret` (26), `EncryptionKey::from_bytes` (7), `lyxal_crypto::cipher::{encrypt_aes_gcm, decrypt_aes_gcm}` (module privé), `lyxal_crypto::Zeroizing`, `SecretString::from`. Le plan `lyxal_booking/implementation_plan.md` (helpers Cal.rs) s'appuie aussi sur `cipher::decrypt_aes_gcm`, qui n'est plus public. | Note de reprise dans `lyxal_booking/implementation_plan.md`, comme pour `lyxal_error` (décision CTO : traité à la reprise de booking). |
| C-02 | P2 | §0.2 (documents historiques), §0.3.4 | `CHANGELOG.md`, `MIGRATION_GUIDE.md`, `roadmap.md`, `ENVELOPE_FORMAT_V1.md`, `validation/` (78 fichiers, 972 Ko), `tools/validate.py` | Pas de changelog avant une version livrée. Guide de migration depuis une API jamais livrée. `roadmap.md` décrit l'état « après phase B ». `ENVELOPE_FORMAT_V1.md` se déclare lui-même « archive historique, non pris en charge ». `validation/` contient les journaux d'une exécution passée (fuzz, clippy, tests, empreintes) ; `tools/validate.py` produit ces journaux. | Supprimer (décision Q1 pour `ENVELOPE_FORMAT_V1.md`). |
| C-03 | P2 | §0.3.4 (état actuel) | `README.md`, `API_CONTRACT.md:3`, `ENVELOPE_FORMAT_V2.md:1`, `SECURITY.md:98`, `fuzz/README.md:21` | Statuts périmés : « phase B », « soumise à réception CTO », « réception CTO en attente ». Renvois vers `IMPLEMENTATION_REPORT.md`, absent du dépôt. | Décrire l'état actuel, retirer les renvois cassés. |
| C-04 | P2 | Contrôle 8 (preuves exécutées) | `tools/check_contracts.py`, `tools/check_fixtures.py`, `tools/contracts/`, `fuzz/` | Outils absents de la CI et des scripts `scripts/ci/` : vérification des bornes de traits, vecteurs vérifiés par OpenSSL (module Python `cryptography`), campagnes de fuzz (Rust nightly). | Décision Q2. |
| C-05 | P2 | Qualité | `src/hash.rs` | Documentation en français dans `hash.rs`, en anglais ailleurs. | Harmoniser avec le reste de `src/` (anglais). |

## 4. Correspondance DTO ↔ SurrealQL

Sans objet : aucune fonction SurrealQL, aucun `*Params`.

## 5. Preuves d'exécution et points non vérifiés

Exécuté (2026-11-02) :

| Commande | Résultat |
| :- | :- |
| `cargo test -p lyxal_crypto` | 16 tests unitaires, 52 tests d'intégration et 8 doctests réussis. 2 tests ignorés : des processus enfants lancés par d'autres tests (interruption simulée). |
| `cargo clippy -p lyxal_crypto --no-deps --all-targets --all-features -- -D warnings` | Aucune remarque. |
| `RUSTDOCFLAGS="-D warnings" cargo doc -p lyxal_crypto --no-deps` | Aucun avertissement. |

Non exécuté :
* `tools/check_contracts.py` et `tools/check_fixtures.py` (module Python `cryptography` absent) ;
* les campagnes de fuzz (Rust nightly et `cargo-fuzz` requis).

Leurs anciens résultats dans `validation/` ne sont pas des preuves actuelles.

## 6. Éléments conformes

* §11.3, règles 1 à 7 :
  * mots de passe : Argon2id v19 (`src/password.rs`) ;
  * HMAC : `HmacKey` de 32 octets, `verify_slice` en temps constant (`src/hmac.rs`) ;
  * hachage : `sha256`, `blake3` (`src/hash.rs`) ;
  * dérivation : HKDF vers `SecretBytes` (`src/kdf.rs`) ;
  * chiffrement : `seal`/`open` avec `SecretContext` (`src/lib.rs:45-79`) ;
  * types opaques (`src/secret.rs`, `src/key.rs`) ;
  * aléa : `OsRng` uniquement, erreur propagée (`src/cipher.rs:8-13`, `src/key.rs:38-43`).
* AAD exacte, vérifiée octet par octet (`src/context.rs:122-136`) ; domaine global à finalité
  explicite (`SecretContext::global`).
* Enveloppe : longueur bornée, ASCII, base64url canonique, version inconnue refusée sans
  repli (`src/envelope.rs:15-65`).
* Rotation : authentification systématique, y compris dans la branche `Current`
  (`src/lib.rs:81-95`). Substitution de clé détectée en temps constant
  (`src/key_resolver.rs:201-217`).
* Erreurs sans donnée sensible ni chemin (`src/error.rs`).
* Les autres crates du workspace n'importent aucune crate cryptographique en direct. `fastrand`,
  utilisé par `lyxal_event` et `lyxal_runtime` pour le tirage des délais de retry, ne produit
  pas de matériel cryptographique.

## 7. Plan correctif

Voir `implementation_plan.md` (soumis au CTO).
