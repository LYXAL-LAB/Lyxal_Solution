# Plan d'implémentation — programme courrier, agendas et contacts, lot 2 (cryptographie, vague 1)

Plan détaillé du lot 2 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §5 et décisions **P6** (a), (b), (c), (d), (i) et **P15**, niveau A) : extensions de
`lyxal_crypto` nécessaires aux lots suivants.

| Extension (P6) | Ce que c'est, en clair | Premier lot qui s'en sert |
| :--- | :--- | :--- |
| (a) TLS côté serveur | Le cadenas des connexions entrantes (SMTP, IMAP, POP3, ManageSieve, HTTPS de CalDAV et JMAP) | lot 3 (hôte) |
| (b) Vérification RSA-SHA256 et Ed25519 | Contrôler une signature faite par un autre serveur | lot 5 (réception) |
| (c) DKIM | Signer le courrier qui part et vérifier la signature du courrier qui arrive | lots 5 et 6 |
| (d) Génération de clés RSA et Ed25519 | Créer les clés DKIM d'un domaine | lots 6 et 13 |
| (i) Chiffrement de fichiers en flux | Chiffrer au repos des messages et pièces jointes de toute taille (aujourd'hui : 1 Mio au plus) | lot 4 (puis 16 et 19) |

Ce lot ne crée **aucune écoute réseau**, aucune table, aucune fonction SurrealQL : il ajoute des
types et des fonctions Rust à `lyxal_crypto`. Les lots 3 à 19 les appellent.

Touche : `crates/lyxal_crypto` (code, documents, bancs de contrats, fuzzing, outils de contrôle),
`.agents/rules/lyxal_standards_and_checklist.md` §11.3 et `.agents/AGENTS.md` §6 (liste des
primitives), `scripts/ci/` et `.github/workflows/ci.yml` (nouveau garde-fou des dépendances
cryptographiques), documents du programme. Aucune ligne de code avant la validation de ce plan
par le CTO (`.agents/AGENTS.md` §3, `.agents/rules/lyxal_standards_and_checklist.md` §11.3 :
« toute fonctionnalité cryptographique supplémentaire … validation explicite du CTO »).

Méthode : constats faits **par lecture** du dépôt (`crates/lyxal_crypto`, `Cargo.toml`,
`Cargo.lock`, `deny.toml`, `scripts/ci/`), de `cargo tree --offline`, de `cargo audit --no-fetch`
(base d'avis RustSec locale, synchronisée le 9 novembre 2026), du cache local de l'index
crates.io (9 novembre 2026), des sources des crates en cache (`ring` 0.17.14, `aws-lc-rs`
1.19.0, `rustls` 0.23.46, `rustls-pki-types` 1.15.1) et des clones de `mail-auth` (commit
`c862df2`, 17 novembre 2026) et de Mox. Rien n'a été compilé ni exécuté pour ce plan, hormis
`cargo tree` et `cargo audit` en lecture. Ce qui n'est pas vérifié est marqué « non vérifié »
(liste au §17).

**Règle de provenance du programme (§4.1)** : `lyxal_crypto` ne reçoit aucun code AGPL ni GPL.
Ce lot reprend seulement du code `Apache-2.0 OR MIT` (`mail-auth`, canonicalisation DKIM) et des
vecteurs de test sous licence permissive (Wycheproof, Apache-2.0), notés dans un nouveau
`crates/lyxal_crypto/SOURCES.md`. Aucun fichier de Stalwart n'est repris (ni AGPL, ni
`LicenseRef-SEL`) ; le module TLS de Stalwart (`common/src/config/server/tls.rs`, AGPL) a été lu
pour la liste des fonctions, pas copié.

**Bilan de réutilisation (§3 de `AGENTS.md`)** : `lyxal_core` — aucune fonction (crate Rust pur,
sans base de données) ; `lyxal_crypto` existant — `SecretBytes`, `SecretContext` (son encodage
d'identité), `CryptoEngine::seal` / `open` (enveloppe `enc:v2`, pour sceller la clé de chaque
fichier), `hkdf_sha256`, `Sha256Hasher`, `RsaSigningKey`, AES-256-GCM de RustCrypto ; codes
d'erreurs master data, `XxxParams` / `XxxResult`, `manifest.toml` : **sans objet** (aucune
fonction SurrealQL ; les erreurs sont celles de l'énumération Rust `CryptoError`). Besoin
`lyxal_core` manquant : aucun.

## 0. Écarts au plan du programme

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | Bibliothèque des signatures, des clés et de TLS : **`aws-lc-rs`** (déjà dans l'arbre des dépendances) au lieu de `ring` cité au §5 du programme ; les fonctions K8 existantes (ES256, RS256, Web Push, HMAC-SHA1) y passent aussi (C1) | `ring` ne génère pas de clés RSA (constaté dans ses sources) ; garder deux bibliothèques asymétriques dans le même crate ferait deux propriétaires d'une même responsabilité (§5.1) |
| E2 | `mail-auth` n'est **pas** une dépendance de `lyxal_crypto` : sa canonicalisation DKIM (`Apache-2.0 OR MIT`) est **portée** ; la lecture des balises DKIM, le DNS et les règles restent aux crates du courrier (C4) | La crypto de `mail-auth` est choisie à la compilation (`aws-lc-rs` ou `rsa` / `ed25519-dalek`) et ses clés publiques DKIM ne passent par aucune interface publique : l'utiliser telle quelle ferait faire la vérification par `mail-auth`, hors `lyxal_crypto`. Version constatée : **0.16.0** (le programme indique 0.15) |
| E3 | Le lot touche aussi `.agents/rules` (§11.3), `.agents/AGENTS.md` (§6), `scripts/ci/` et `.github/workflows/ci.yml` | La liste des primitives et des interdictions est dans les règles ; **aucun contrôle automatique** n'interdit aujourd'hui une crate cryptographique dans un module (constat : `scripts/ci/crypto_checks.sh` ne contrôle que les contrats et les vecteurs de `lyxal_crypto`) |
| E4 | Le TLS du lot 2 sait déjà servir **plusieurs certificats selon le nom demandé** (SNI) et les **remplacer à chaud** | Besoin du lot 13 (certificats automatiques, plusieurs domaines) ; peu coûteux maintenant, et évite de changer le contrat au lot 13 |
| E5 | Livraison en **deux demandes de fusion** dans ce même plan : 2a (TLS, chiffrement en flux), 2b (signatures, clés, DKIM) — C13 | 2a débloque les lots 3 et 4, 2b les lots 5 et 6 ; deux relectures plus petites d'un crate sensible |

## 1. Périmètre

**Dans le lot 2** :

* **signatures** : vérification RSA PKCS#1 v1.5 SHA-256 et Ed25519 (clés publiques), signature
  Ed25519, génération de clés RSA (2048, 3072, 4096 bits) et Ed25519, export PKCS#8 des clés
  privées pour leur rangement dans `lyxal_secrets` ;
* **DKIM** (RFC 6376, 8301, 8463) : canonicalisation `simple` et `relaxed` des en-têtes et du
  corps, empreinte du corps en flux, assemblage des données signées (avec retrait de la valeur
  `b=`), signature et vérification `rsa-sha256` et `ed25519-sha256`, lecture de la clé publique
  publiée dans le DNS (valeur décodée de `p=`), production de la valeur `p=` d'une clé ;
* **TLS côté serveur** : configuration `rustls` (TLS 1.2 et 1.3), chargement d'un certificat et
  de sa clé (PEM ou DER), choix du certificat par nom (SNI) avec certificat par défaut,
  remplacement à chaud, ALPN ;
* **chiffrement de fichiers en flux** : format `STREAM_FORMAT_V1.md` (segments AES-256-GCM de
  64 Kio), clé propre à chaque fichier scellée par `enc:v2`, lecture d'une plage d'octets sans
  tout déchiffrer ;
* migration des fonctions K8 de `ring` vers `aws-lc-rs` (API inchangée) ;
* garde-fou CI des dépendances cryptographiques ; règles §11.3 et §6 mises à jour ; contrats,
  vecteurs, fuzzing, documents.

**Hors lot 2** (lot prévu entre parenthèses) :

* lecture des balises `DKIM-Signature`, sélection des en-têtes selon `h=`, requête et lecture de
  l'enregistrement DNS (`v=DKIM1; k=; p=; t=`), règles d'expiration `x=` et `t=`, alignement
  `i=` / `d=`, résultats `pass` / `fail` / `permerror` / `temperror`, `Authentication-Results`
  (lot 5, `lyxal_mail_proto`) ; signature sortante, clé par domaine dans `lyxal_secrets`, rotation
  (lots 6 et 13) ;
* **ARC** — P6(e) (lot 7 : il réutilise les primitives DKIM de ce lot) ; **DANE** — P6(f) et
  vérificateur de certificat sur mesure pour MTA-STS (lot 7) ;
* **TLS côté client** (envoi vers les MX : TLS opportuniste, lot 6 ; MTA-STS et DANE, lot 7) —
  P6 ne le liste pas : il sera demandé par le plan du lot 6 (C8) ;
* lecture des dates et des noms d'un certificat (alerte d'expiration), ACME, `rcgen` — P6(g)
  (lot 13) ; agrafage OCSP (lot 13, si retenu) ;
* SCRAM-SHA-256 — P6(h) (lot 8) ; OpenPGP — P6(j) (lot 12 bis) ; niveau C (sans lot) ;
* `rsa-sha1` (interdit par la RFC 8301), DKIM2 et ML-DSA (hors programme, §9) ;
* branchement du chiffrement en flux dans `lyxal_storage` ou `lyxal_mail` (lot 4, C11).

## 2. Point de départ (constats)

### 2.1. `lyxal_crypto` aujourd'hui

3 770 lignes de Rust (`src/`), API figée (`API_CONTRACT.md`), `#![forbid(unsafe_code)]`, MSRV
1.85. Dépendances : RustCrypto (`aes-gcm`, `sha2`, `hmac`, `hkdf`, `argon2`, `sha1`), `blake3`,
`ring` 0.17 (extension K8 : `src/signing.rs`, `src/webpush.rs`, `verify_external_hmac_sha1`).
`SecretBytes` refuse plus de 1 Mio (`MAX_SECRET_BYTES`), donc `CryptoEngine::seal` aussi.
Bancs : `tools/check_contracts.py` (traits interdits sur les types sensibles, espace de travail
isolé avec son verrou), `tools/check_fixtures.py` (vecteurs `enc:v2` recalculés par la
bibliothèque Python `cryptography` 50.0.1), fuzzing (`envelope`, `context`, `phc`, `rotation`),
tous lancés par le job « Cryptographie » et le workflow « Fuzzing lyxal_crypto ».

Utilisateurs : `lyxal_secrets` (clé maîtresse → une clé AES par organisation, tirée par `OsRng`,
scellée par la clé maîtresse dans `secrets_tenant_key` ; trousseau reconstruit à chaque
opération par `KeyRingBuilder` / `StaticKeyResolver` / `CryptoEngine`) ; `lyxal_storage`
(seulement `Blake3Hasher` : **aucun chiffrement des fichiers**, « chiffrement des fichiers au
repos » est dans sa feuille de route) ; `lyxal_notification` (`EcdsaP256SigningKey`,
`RsaSigningKey`, `webpush_encrypt`, HMAC) ; `lyxal_auth`, `lyxal_surreal`, `lyxal_runtime`,
`lyxal_pipeline_ingestion`.

### 2.2. Bibliothèques déjà dans l'arbre (`Cargo.lock`, `cargo tree --offline`)

| Crate | Version | Amenée par | Licence |
| :--- | :--- | :--- | :--- |
| `ring` | 0.17.14 | `lyxal_crypto` (direct), `rustls`, `rustls-webpki`, `object_store` | Apache-2.0 AND ISC |
| `aws-lc-rs` / `aws-lc-sys` | 1.19.0 / 0.47.0 | `rustls`, `jsonwebtoken` (← `surrealdb-core`), `reqwest` 0.13 (← `surrealdb`) | ISC AND (Apache-2.0 OR ISC) / ISC, Apache-2.0, MIT, BSD-3-Clause (expressions combinées) |
| `rustls` | 0.23.46 (fonctionnalités `ring` **et** `aws_lc_rs` actives) | `surrealdb`, `reqwest`, `lettre` | Apache-2.0 OR ISC OR MIT |
| `tokio-rustls` | 0.26.4 | `reqwest`, `lettre`, `tokio-tungstenite` | MIT OR Apache-2.0 |
| `rustls-pki-types` / `rustls-webpki` | 1.15.1 / 0.103.16 | `rustls` | MIT OR Apache-2.0 / ISC |
| `rsa` | 0.9.10 et 0.10.0-rc.19 | `jsonwebtoken` (← `surrealdb-core`) ; `crypto-glue` (← `webauthn-rs`, `lyxal_auth`) | MIT OR Apache-2.0 |

Conséquences : (1) **aucune crate nouvelle** n'entre dans `Cargo.lock` avec ce lot ; aucune
licence nouvelle, `deny.toml` inchangé (les licences d'`aws-lc-*` passent déjà le contrôle C4 du
lot 0) ; (2) `aws-lc-sys` (code C compilé) est déjà construit par chaque compilation du
workspace, via `surrealdb` ; (3) `rustls` ayant ses deux fournisseurs actifs, son constructeur
par défaut `ServerConfig::builder()` **s'arrête par un `panic!`** (« no process-level
CryptoProvider available », `rustls-0.23.46/src/crypto/mod.rs` l. 243-285) : `lyxal_crypto`
devra toujours passer son fournisseur explicitement (`builder_with_provider`).

### 2.3. Avis de sécurité (RustSec, base locale du 9 novembre 2026)

| Avis | Ce qu'il dit | Effet sur ce lot |
| :--- | :--- | :--- |
| **RUSTSEC-2023-0071** (`rsa`, « Marvin ») | Calcul en temps variable : la durée des opérations **avec la clé privée** fuit des informations sur la clé, mesurables par le réseau ; corrigé à partir de `rsa` 0.10.0 (`patched = [">= 0.10.0"]`) | **Signature et génération** avec `rsa` 0.9 : concernées (opérations sur la clé privée ; la génération ne se mesure pas par le réseau, mais la clé est calculée en temps variable et l'outil d'audit signale la crate quoi qu'il arrive). **Vérification seule** : non concernée (aucun secret, clé publique seulement). `cargo audit` signale déjà `rsa` 0.9.10 et 0.10.0-rc.19 (une pré-version est inférieure à 0.10.0) dans l'arbre actuel, hors de `lyxal_crypto`. `rsa` 0.10.0 finale apparaît dans l'index local (9 novembre 2026), mais demande Rust 1.87 (MSRV de `lyxal_crypto` : 1.85), `rand_core` 0.10 (le crate est en 0.6) et une arithmétique (`crypto-bigint` 0.7) toute neuve. **Proposition : aucune utilisation de la crate `rsa`** ; RSA par `aws-lc-rs` (C2) |
| RUSTSEC-2026-0285, -0346 à -0349 (`rustls`) | Corrigés en 0.23.46 | Exiger `rustls >= 0.23.46` |
| RUSTSEC-2026-0044 à -0048 (`aws-lc-sys`) | Corrigés en 0.38 / 0.39 | 0.47.0 dans l'arbre : non concerné |
| RUSTSEC-2025-0009 (`ring`) | Corrigé en 0.17.12 | 0.17.14 : non concerné ; l'avis « ring n'est plus maintenu » (RUSTSEC-2025-0007) a été **retiré** |
| RUSTSEC-2026-0387 (`crypto-bigint` 0.5.5), RUSTSEC-2026-0454 (`surrealdb-core`) | Temps variable ; course de données | Hors de ce lot ; signalés pour information |

## 3. Choix des bibliothèques

| Besoin | Proposition | Autres choix écartés | Licence, entretien |
| :--- | :--- | :--- | :--- |
| Signatures Ed25519 (signer, vérifier, générer) | `aws-lc-rs` (`signature::Ed25519KeyPair`, `ED25519`) | `ring` (sait le faire, mais voir RSA) ; `ed25519-dalek` 2.2 / 3.0 (nouvelle crate, `rand_core` 0.10 pour la 3.0) | ISC / Apache-2.0 ; publié par AWS, version 1.19.0 la plus récente de l'index local |
| RSA : vérifier, signer, **générer** | `aws-lc-rs` (`rsa::KeyPair::generate(KeySize)`, `RSA_PKCS1_1024_8192_SHA256_FOR_LEGACY_USE_ONLY` pour DKIM, `RSA_PKCS1_2048_8192_SHA256` sinon) | `ring` (ne génère pas) ; `rsa` 0.9 (Marvin) ; `rsa` 0.10 (MSRV, jeunesse) ; génération par `openssl` en ligne de commande (pas d'API pour l'administration du lot 13) | idem ; arithmétique en temps constant héritée de BoringSSL |
| Fournisseur de `rustls` côté serveur | `rustls::crypto::aws_lc_rs` passé explicitement | fournisseur `ring` (pas d'échange de clés hybride post-quantique) | — |
| TLS | `rustls` 0.23 (`>= 0.23.46`), `default-features = false`, fonctionnalités `std`, `tls12`, `aws_lc_rs` ; `rustls-pki-types` 1.15 (lecture PEM) | `openssl`, `native-tls` (code système variable) ; `rustls-pemfile` (remplacée par `rustls-pki-types`) | Apache-2.0 OR ISC OR MIT ; projet très actif (correctifs d'octobre 2026) |
| Canonicalisation DKIM | **Portage** de `mail-auth` 0.16.0, `src/dkim/canonicalize.rs` (916 lignes avec tests) | dépendance `mail-auth` dans `lyxal_crypto` (amène DNS `hickory`, `mail-parser`, SPF, DMARC, sa propre crypto) ; écrire de zéro ; Mox `dkim` (Go, MIT) — gardé comme référence de comportement et source de cas de test | `Apache-2.0 OR MIT` (vérifié : `Cargo.toml`, 78 en-têtes SPDX, dossier `LICENSES/`) ; avis Apache conservé dans `SOURCES.md` |
| Chiffrement en flux | AES-256-GCM et HKDF-SHA256 **déjà présents** (RustCrypto) ; format écrit pour Lyxal | Tink, `age` (formats d'autres projets, autre suite pour `age`) | aucune dépendance nouvelle |

Dépendances directes de `lyxal_crypto` après le lot : **ajoutées** `aws-lc-rs = "1.19"`,
`rustls = { version = "0.23.46", default-features = false, features = ["std", "tls12",
"aws_lc_rs"] }`, `rustls-pki-types = { version = "1.15", features = ["std"] }` ; **retirée**
`ring` (C1 ; elle reste dans l'arbre par `rustls`, `lettre` et `reqwest`). Aucune
fonctionnalité Cargo optionnelle dans `lyxal_crypto` : `rustls` et `aws-lc-rs` sont déjà
compilés dans chaque binaire du dépôt par `surrealdb`.

## 4. Signatures et clés (`src/signing.rs`, étendu)

```rust
/// Taille d'une clé RSA générée.
pub enum RsaModulusBits { Rsa2048, Rsa3072, Rsa4096 }

impl RsaSigningKey {                                     // type existant
    pub fn generate(bits: RsaModulusBits) -> Result<Self, CryptoError>;          // nouveau
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError>;      // inchangé : 2048..=4096 bits
    pub fn sign_rs256(&self, data: &[u8]) -> Result<Vec<u8>, CryptoError>;      // inchangé
    pub fn public_key(&self) -> RsaPublicKey;                                    // nouveau
    pub fn modulus_bits(&self) -> u32;                                           // nouveau
    pub fn export_pkcs8(&self) -> SecretBytes;                                   // nouveau (C6)
}

/// Clé publique RSA (donnée publique : Clone, PartialEq, Debug lisible permis).
pub struct RsaPublicKey { /* RSAPublicKey DER (PKCS#1), taille en bits */ }
impl RsaPublicKey {
    pub fn from_spki_der(der: &[u8]) -> Result<Self, CryptoError>;     // SubjectPublicKeyInfo (RFC 5280)
    pub fn from_pkcs1_der(der: &[u8]) -> Result<Self, CryptoError>;    // RSAPublicKey (RFC 8017)
    pub fn to_spki_der(&self) -> Vec<u8>;
    pub fn modulus_bits(&self) -> u32;
    /// RSASSA-PKCS1-v1_5 SHA-256 ; clé de 2048 à 8192 bits (sinon KeyTooWeak / InvalidKeyEncoding).
    pub fn verify_rs256(&self, data: &[u8], signature: &[u8]) -> Result<bool, CryptoError>;
}

/// Clé privée Ed25519 (RFC 8032), gardée en PKCS#8 effacé à la libération.
pub struct Ed25519SigningKey { /* Zeroizing<Vec<u8>> PKCS#8 v2, clé publique */ }
impl Ed25519SigningKey {
    pub fn generate() -> Result<Self, CryptoError>;
    /// PKCS#8 v1 (forme d'`openssl genpkey`) ou v2, DER ou PEM `PRIVATE KEY`, 16 Kio au plus.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError>;
    pub fn export_pkcs8(&self) -> SecretBytes;                         // C6
    pub fn public_key(&self) -> Ed25519PublicKey;
    pub fn sign(&self, data: &[u8]) -> Result<[u8; 64], CryptoError>;  // Ed25519 « pur »
}

/// Clé publique Ed25519 : 32 octets (donnée publique).
pub struct Ed25519PublicKey([u8; 32]);
impl Ed25519PublicKey {
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, CryptoError>;      // exactement 32 octets
    pub fn as_bytes(&self) -> &[u8; 32];
    pub fn verify(&self, data: &[u8], signature: &[u8]) -> Result<bool, CryptoError>;
}
```

Règles communes :

* **Résultat d'une vérification** : `Ok(true)` signature valide ; `Ok(false)` signature fausse ;
  `Err(InvalidSignatureEncoding)` signature de mauvaise longueur (64 octets pour Ed25519, taille
  du module pour RSA) ; `Err(InvalidKeyEncoding)` clé illisible ; `Err(KeyTooWeak)` clé RSA trop
  courte. Même découpage que `verify_hmac_sha256` (format invalide = erreur, mauvaise valeur =
  `false`) : il permet au lot 5 de distinguer `fail` de `permerror`.
* **Clé privée en mémoire** : PKCS#8 dans `Zeroizing<Vec<u8>>`, relue par `aws-lc-rs` à chaque
  signature, comme les clés K8 aujourd'hui ; l'objet `aws-lc-rs` transitoire vit en mémoire C,
  libérée par `EVP_PKEY_free` (effacement de cette mémoire par AWS-LC : non vérifié, §17) ;
  aucune clé privée en champ public, `Debug` = `<Type>([REDACTED])`, ni `Clone`, ni `Default`,
  ni sérialisation (banc `check_contracts.py` étendu à `Ed25519SigningKey` et `StreamKey`).
* **Génération** : aléa du système (`aws-lc-rs`, `RAND_bytes` d'AWS-LC sur `getrandom`) ; échec
  → `RandomUnavailable`. Une clé RSA de 4096 bits peut prendre plus d'une seconde (non mesuré) :
  l'appelant l'exécute hors de la boucle asynchrone (`spawn_blocking`), comme Argon2id.
* **Export** : `export_pkcs8` existe seulement pour ranger la clé dans `lyxal_secrets` (comme
  `EcdsaP256SigningKey::export_pkcs8` pour VAPID) ; la copie appartient à l'appelant.

## 5. DKIM (`src/dkim.rs`, nouveau)

### 5.1. Qui fait quoi (C4)

| `lyxal_crypto` (ce lot, MIT OR Apache-2.0) | `lyxal_mail_proto` / `lyxal_mail` (lots 5, 6, 7 ; AGPL) |
| :--- | :--- |
| Canonicalisation `simple` / `relaxed` des en-têtes et du corps (portée de `mail-auth`) ; empreinte SHA-256 du corps en flux, avec limite `l=` ; assemblage des données signées (en-têtes choisis + en-tête de signature dont la valeur `b=` est vidée, sans CRLF final) ; signature et vérification `rsa-sha256`, `ed25519-sha256` ; lecture de la clé publique depuis les octets décodés de `p=` ; valeur `p=` d'une clé ; génération | Découpage du message en en-têtes et corps ; lecture des balises `DKIM-Signature` (`v a b bh c d h i l q s t x z`) ; choix des en-têtes selon `h=` (du bas vers le haut, en-têtes absents sur-signés) ; requête DNS et lecture de `v=DKIM1; k=; p=; t=` ; dates `t=` / `x=` ; `i=` / `d=` ; politique (`l=` plus court que le corps, taille minimale) ; résultats et `Authentication-Results` ; choix de la clé et du domaine à la signature ; ARC (lot 7) |

Raisons : la canonicalisation et l'assemblage déterminent **exactement** les octets signés ;
une erreur d'un octet casse toutes les signatures ou, pire, en accepte de fausses. Ils restent
donc à côté de la signature, dans le crate relu, fuzzé et audité (`ROADMAP.md` : audit externe).
La lecture des balises, le DNS et la politique sont du protocole de courrier : ils changent avec
les lots du courrier et n'ont rien de cryptographique. `lyxal_crypto` ne lit pas un message.

### 5.2. Contrat

```rust
/// Algorithme de la balise a=. rsa-sha1 n'existe pas (RFC 8301).
pub enum DkimAlgorithm { RsaSha256, Ed25519Sha256 }
impl DkimAlgorithm { pub fn as_tag(&self) -> &'static str; pub fn from_tag(tag: &str) -> Option<Self>; }

pub enum DkimCanonicalization { Simple, Relaxed }

/// Empreinte du corps en flux (RFC 6376 §3.4.3 à 3.4.5, §3.7).
pub struct DkimBodyHasher { /* état de canonicalisation, Sha256Hasher, compteurs */ }
impl DkimBodyHasher {
    /// length_limit : valeur de l=, pour la vérification seulement.
    pub fn new(canonicalization: DkimCanonicalization, length_limit: Option<u64>) -> Self;
    pub fn update(&mut self, chunk: &[u8]);
    pub fn finish(self) -> DkimBodyHash;
}
pub struct DkimBodyHash {
    pub digest: [u8; 32],          // valeur de bh= (après Base64 par l'appelant)
    pub canonical_length: u64,     // octets canonicalisés vus, pour comparer à l=
}

/// Données signées (RFC 6376 §3.7), bornées à 256 Kio.
pub struct DkimSignedData { /* octets canonicalisés */ }
pub struct DkimHeaderCanonicalizer { /* tampon borné */ }
impl DkimHeaderCanonicalizer {
    pub fn new(canonicalization: DkimCanonicalization) -> Self;
    /// En-tête choisi par h= : nom et valeur bruts (repliements compris), sans CRLF final.
    pub fn push_header(&mut self, name: &[u8], raw_value: &[u8]) -> Result<(), CryptoError>;
    /// En-tête de signature (DKIM-Signature, ou ARC-Message-Signature / ARC-Seal au lot 7) :
    /// la valeur de la balise b= est vidée ici (pas bh=), le reste est gardé à l'octet.
    pub fn finish(self, signature_name: &[u8], signature_raw_value: &[u8])
        -> Result<DkimSignedData, CryptoError>;
}

/// Clé de signature d'un domaine.
pub enum DkimSigningKey { Rsa(RsaSigningKey), Ed25519(Ed25519SigningKey) }
impl DkimSigningKey {
    pub fn algorithm(&self) -> DkimAlgorithm;
    /// RSA : RSASSA-PKCS1-v1_5 SHA-256 des données ; Ed25519 : Ed25519 de SHA-256(données) (RFC 8463 §3).
    pub fn sign(&self, data: &DkimSignedData) -> Result<Vec<u8>, CryptoError>;
    /// Octets de p= (avant Base64) : SubjectPublicKeyInfo pour RSA, 32 octets pour Ed25519.
    pub fn public_key_record_bytes(&self) -> Vec<u8>;
}

pub enum DkimKeyType { Rsa, Ed25519 }        // balise k= de l'enregistrement DNS
/// Clé publique lue dans le DNS (donnée publique).
pub struct DkimPublicKey { /* RsaPublicKey ou Ed25519PublicKey */ }
impl DkimPublicKey {
    /// p= décodé : RSA en SubjectPublicKeyInfo ou RSAPublicKey nu, 1024 à 4096 bits ;
    /// Ed25519 : exactement 32 octets.
    pub fn from_record(key_type: DkimKeyType, p: &[u8]) -> Result<Self, CryptoError>;
    pub fn key_type(&self) -> DkimKeyType;
    /// AlgorithmMismatch si a= ne correspond pas à k=.
    pub fn verify(&self, algorithm: DkimAlgorithm, data: &DkimSignedData, signature: &[u8])
        -> Result<bool, CryptoError>;
}
```

Règles (C5) :

* **RSA** : vérification de 1024 à 4096 bits (RFC 8301 §3.2 : un vérificateur DOIT accepter
  1024 à 4096 bits et NE DOIT PAS tenir pour valide une clé plus courte) — c'est la seule place
  où une clé de 1024 bits est acceptée ; signature avec une clé de 2048 bits au moins.
* **`rsa-sha1`** : refusé (RFC 8301 : ne doit plus être utilisé ni pour signer ni pour
  vérifier). `mail-auth` le vérifie encore ; ce port ne le reprend pas.
* **`l=`** : supporté à la vérification seulement (les messages reçus en portent) ; jamais
  produit. Le refus éventuel d'un `l=` plus court que le corps est une règle du lot 5.
* **Fins de ligne** : comportement de `mail-auth` repris tel quel (un LF isolé compte comme fin
  de ligne, un CR isolé est ignoré) et documenté ; le lot 5 refuse en amont les fins de ligne
  isolées dans `DATA` (attaques de « contrebande » SMTP).
* **Découpage indifférent** : l'empreinte du corps est la même quel que soit le découpage des
  morceaux passés à `update` (propriété testée, §11).
* Portage : `slice::as_chunks` (Rust 1.88) et `memchr` de `mail-auth` remplacés par du code
  simple compatible avec la MSRV 1.85 de `lyxal_crypto`, sans dépendance nouvelle ; en-têtes
  SPDX et avis de licence conservés dans le fichier porté et dans `SOURCES.md`.

## 6. TLS côté serveur (`src/tls.rs`, nouveau)

```rust
/// Certificat (chaîne) et clé privée d'un serveur, vérifiés ensemble.
pub struct TlsCertifiedKey { /* Arc<rustls::sign::CertifiedKey> */ }
impl TlsCertifiedKey {
    /// Chaîne PEM (CERTIFICATE, feuille d'abord, 10 au plus, 64 Kio au plus) et clé privée PEM :
    /// PRIVATE KEY (PKCS#8), RSA PRIVATE KEY (PKCS#1) ou EC PRIVATE KEY (SEC1), 16 Kio au plus.
    /// Clé RSA 2048 bits ou plus, ECDSA P-256 / P-384, Ed25519. Clé chiffrée refusée.
    pub fn from_pem(chain_pem: &[u8], private_key_pem: SecretBytes) -> Result<Self, CryptoError>;
    pub fn from_der(chain: Vec<Vec<u8>>, private_key_pkcs8_der: SecretBytes) -> Result<Self, CryptoError>;
}

/// Certificats d'un serveur : un par nom (SNI, joker « *.domaine » sur un niveau) et un par
/// défaut (client sans SNI, adresse IP). Remplacement atomique : les nouvelles poignées de
/// main voient le nouveau certificat, les connexions ouvertes gardent l'ancien.
pub struct TlsCertificateStore { /* RwLock<Arc<table>> ; implémente rustls::server::ResolvesServerCert */ }
impl TlsCertificateStore {
    pub fn new(default: Option<TlsCertifiedKey>) -> Arc<Self>;
    pub fn set_default(&self, key: Option<TlsCertifiedKey>);
    /// Refus (InvalidCertificate) si le certificat ne couvre pas ce nom.
    pub fn insert(&self, server_name: &str, key: TlsCertifiedKey) -> Result<(), CryptoError>;
    pub fn remove(&self, server_name: &str) -> bool;
}

pub enum TlsMinVersion { Tls12, Tls13 }
pub struct TlsServerOptions {
    pub min_version: TlsMinVersion,           // défaut Tls12
    pub alpn_protocols: Vec<Vec<u8>>,         // 0 à 8 noms de 1 à 255 octets (ex. "imap", "h2", "acme-tls/1")
    pub session_cache_entries: usize,         // 0 à 65 536, défaut 4 096
}

/// Configuration rustls prête pour tokio_rustls::TlsAcceptor (côté hôte).
pub fn tls_server_config(store: Arc<TlsCertificateStore>, options: &TlsServerOptions)
    -> Result<Arc<rustls::ServerConfig>, CryptoError>;
pub use rustls;   // version exacte utilisée, pour que l'hôte construise TlsAcceptor
```

Réglages fixes (C7) :

* fournisseur `aws_lc_rs` passé à `ServerConfig::builder_with_provider` (jamais `builder()`,
  §2.2) ; TLS 1.2 et 1.3 (rustls n'offre ni TLS 1.0 / 1.1 ni suites CBC ni échange de clés RSA) ;
  suites et groupes du fournisseur (AES-GCM, ChaCha20-Poly1305 ; X25519MLKEM768, X25519,
  P-256, P-384 : C3) ;
* pas de 0-RTT (`max_early_data_size = 0` : rejouable) ; pas de certificat client ; jamais de
  journal des clés de session (`key_log` laissé à « aucun ») ;
* certificat demandé absent et aucun certificat par défaut : la poignée de main échoue (alerte
  TLS), sans `panic!`.

Les octets du certificat et de la clé sont **fournis par l'hôte** (fichiers de certbot, qui sont
des liens symboliques, ou `lyxal_secrets`) : `lyxal_crypto` ne lit aucun fichier TLS. Le
rechargement (périodique ou sur signal) est une tâche de l'hôte (lot 3) qui appelle `insert` /
`set_default`. Les `PrivateKeyDer` de `rustls-pki-types` implémentent `Zeroize` mais pas
`ZeroizeOnDrop` (constaté dans ses sources) : chaque copie intermédiaire est effacée
explicitement ; la clé gardée par `rustls` / `aws-lc-rs` vit en mémoire C (§17).

Les hôtes (`apps/lyxal-groupware` au lot 3) peuvent dépendre de `tokio-rustls` pour le seul
transport (`TlsAcceptor`, `STARTTLS`) ; aucune configuration TLS n'est construite hors de
`lyxal_crypto` (C7, garde-fou §12).

## 7. Chiffrement de fichiers en flux (`src/stream.rs`, `STREAM_FORMAT_V1.md`, nouveaux)

### 7.1. Principe, en clair (C9)

```text
clé maîtresse (lyxal_secrets)
   └── clé de l'organisation (EncryptionKey, existante)
          └── clé du fichier (StreamKey, 32 octets tirés au hasard, une par fichier)
                 scellée par enc:v2 (CryptoEngine::seal, existant) et rangée dans la fiche du fichier
                 └── contenu découpé en segments de 64 Kio, chacun chiffré et authentifié (AES-256-GCM)
```

* Une clé **par fichier**, tirée au hasard, rangée **scellée** dans la fiche (SurrealDB), jamais
  dans le fichier : changer la clé d'une organisation revient à resceller ces petites valeurs
  avec `reencrypt_if_needed` (existant), **sans réécrire les fichiers** ; effacer la clé scellée
  rend le fichier illisible même dans les sauvegardes (effacement définitif d'un message) ; le
  niveau B ou C pourra un jour sceller la même clé pour un utilisateur.
* Lecture d'une plage (« octets 1 000 000 à 1 010 000 », lecture partielle IMAP, plage HTTP) :
  seuls les segments concernés sont lus et déchiffrés.

### 7.2. Format v1 (résumé ; spécification complète dans `STREAM_FORMAT_V1.md`)

| Élément | Valeur |
| :--- | :--- |
| En-tête (47 octets, en clair) | `"LXS1"` (4) · version `0x01` · suite `0x01` (AES-256-GCM) · exposant de segment `0x10` (2^16 = 65 536) · indicateurs `0x00` · sel (32 octets aléatoires) · préfixe de nonce (7 octets aléatoires) |
| Clé des segments | `HKDF-SHA256(IKM = clé du fichier, sel = sel de l'en-tête, info = "lyxal:crypto:stream:v1:aes-256-gcm" 0x00, 32 octets)` |
| Nonce du segment `i` | préfixe (7) ‖ `i` en U32 gros-boutiste (4) ‖ `0x01` si dernier segment, sinon `0x00` (1) |
| Données associées (AAD) | `"lyxal:crypto:stream:v1:aes-256-gcm" 0x00` ‖ en-tête (47) ‖ identité du `SecretContext` (octet de mode puis champs `LP(...)`, même encodage que `enc:v2` §3, sans `key_id`) — jamais vide (§11.3) |
| Segments | Tous de 65 536 octets en clair sauf le dernier (1 à 65 536 ; 0 seulement pour un fichier vide), chacun suivi de son tag de 16 octets |
| Tailles | chiffré = 47 + Σ (segment + 16) ; fichier vide = 63 octets ; 2^32 segments au plus (256 Tio) ; surcoût 0,024 % |

Garanties : segment modifié, déplacé, dupliqué ou pris dans un autre fichier → échec
d'authentification ; fichier **tronqué** (même pile à une frontière de segment) → échec, car
l'ancien avant-dernier segment n'a pas l'indicateur « dernier » ; en-tête modifié → échec dès le
premier segment ; contexte différent (autre organisation, autre fiche) → échec. Comme `enc:v2`,
une **ancienne version complète** du même fichier sous le même contexte n'est pas détectée
(rejeu) : l'hôte s'en charge (les messages sont immuables).

Lecture en flux : un segment n'est rendu qu'après vérification de son tag, mais les segments
suivants ne sont pas encore vérifiés. Une altération plus loin est détectée **au segment
concerné** : l'appelant doit alors interrompre la réponse (fermer la connexion IMAP ou HTTP),
jamais la terminer comme réussie. C'est le fonctionnement de tous les chiffrements en flux
(Tink, `age`) ; écrit dans `SECURITY.md` et dans le contrat.

### 7.3. Contrat

```rust
pub const STREAM_HEADER_BYTES: usize = 47;
pub const STREAM_SEGMENT_BYTES: usize = 65_536;
pub const STREAM_TAG_BYTES: usize = 16;

/// Clé d'un fichier (32 octets), effacée à la libération, Debug masqué, sans Clone.
pub struct StreamKey { /* Zeroizing<[u8; 32]> */ }
impl StreamKey {
    pub fn generate() -> Result<Self, CryptoError>;                    // OsRng
    /// Scelle la clé par enc:v2 sous la clé active du moteur (une invocation du budget §SECURITY).
    pub fn seal<R: KeyResolver>(&self, engine: &CryptoEngine<R>, context: &SecretContext)
        -> Result<EncryptedEnvelope, CryptoError>;
    pub fn open<R: KeyResolver>(engine: &CryptoEngine<R>, envelope: &EncryptedEnvelope,
        context: &SecretContext) -> Result<Self, CryptoError>;        // exige 32 octets
}

/// Chiffrement d'un fichier, de bout en bout, en une passe.
pub struct StreamEncryptor { /* clé de segments, AAD, tampon < 64 Kio, compteur */ }
impl StreamEncryptor {
    /// Rend aussi l'en-tête à écrire en premier.
    pub fn new(key: &StreamKey, context: &SecretContext)
        -> Result<(Self, [u8; STREAM_HEADER_BYTES]), CryptoError>;
    /// Ajoute du clair ; écrit dans `out` chaque segment complet chiffré.
    pub fn update(&mut self, plaintext: &[u8], out: &mut Vec<u8>) -> Result<(), CryptoError>;
    /// Chiffre le dernier segment ; rend la taille du clair.
    pub fn finish(self, out: &mut Vec<u8>) -> Result<u64, CryptoError>;
}

/// Lecture d'un fichier chiffré dont la taille totale est connue (fiche lyxal_storage).
pub struct StreamDecryptor { /* clé de segments, AAD, nombre de segments */ }
impl StreamDecryptor {
    pub fn new(key: &StreamKey, context: &SecretContext, header: &[u8], ciphertext_len: u64)
        -> Result<Self, CryptoError>;          // InvalidStreamHeader, UnsupportedVersion, taille incohérente
    pub fn plaintext_len(&self) -> u64;
    pub fn segment_count(&self) -> u64;
    /// Segments et octets chiffrés à lire pour une plage du clair (fin exclue).
    pub fn plan_range(&self, plaintext: Range<u64>) -> Result<StreamSpan, CryptoError>;
    /// Déchiffre le segment `index` (le dernier est reconnu à son rang).
    pub fn decrypt_segment(&self, index: u64, ciphertext: &[u8]) -> Result<SecretBytes, CryptoError>;
}
pub struct StreamSpan { pub first_segment: u64, pub last_segment: u64,
                        pub ciphertext: Range<u64>, pub skip_in_first: usize, pub take: u64 }

pub fn stream_ciphertext_len(plaintext_len: u64) -> Result<u64, CryptoError>;
```

Le module reste **synchrone** (aucune dépendance `tokio` ni `futures` dans `lyxal_crypto`) :
l'adaptateur `Stream<Bytes>` → `Stream<Bytes>` qui l'appelle est écrit par le consommateur
(lot 4 : `lyxal_storage` ou `lyxal_mail`, C11). Chaque segment de clair rendu est un
`SecretBytes` (64 Kio, sous la borne de 1 Mio) effacé à la libération.

**Budget de la clé d'organisation** : chaque fichier consomme **un** scellement `enc:v2` (sa
clé). `SECURITY.md` recommande au plus 2^24 (≈ 16,7 millions) scellements par clé avant
rotation : une organisation de 100 comptes recevant 50 000 messages par an et par compte (5
millions par an) devrait changer de clé environ tous les trois ans. La rotation est celle de
`lyxal_secrets` (existante) ; le compteur reste à l'hôte, comme aujourd'hui.

### 7.4. Ce que le niveau A protège, et ce qu'il ne protège pas (C10)

* Protège : les **octets rangés par `lyxal_storage`** (disque, sauvegarde, compartiment S3
  volés ou mal ouverts).
* Ne protège pas : ce qui est dans **SurrealDB** (objet, expéditeur, destinataires, dates,
  drapeaux, index de recherche plein texte, structure MIME mise en cache), le serveur en marche,
  un administrateur de la machine. Chiffrer ces champs serait un autre chantier.
* Effets de bord : la **déduplication** des fichiers par empreinte (feuille de route de
  `lyxal_storage`) devient impossible pour les fichiers chiffrés (une clé par fichier) ;
  l'antivirus et l'index lisent le clair **avant** chiffrement (ordre fixé au lot 5) ; une
  clé maîtresse ou d'organisation perdue rend tous les fichiers concernés illisibles (sauvegarde
  des clés de `lyxal_secrets`).

## 8. Erreurs (`CryptoError`, `#[non_exhaustive]`, ajouts seulement)

| Variante nouvelle | Quand |
| :--- | :--- |
| `InvalidSignatureEncoding` | Signature de mauvaise longueur ou mal formée |
| `KeyTooWeak` | Clé RSA plus courte que le minimum de l'usage (1024 pour DKIM, 2048 sinon) |
| `AlgorithmMismatch` | `a=` DKIM incompatible avec `k=` |
| `InvalidCertificate` | Chaîne PEM / DER illisible, vide, trop longue, ou nom non couvert |
| `CertificateKeyMismatch` | La clé privée ne correspond pas au certificat |
| `InvalidStreamHeader` | En-tête de flux mal formé, ou taille du chiffré incohérente |

Réutilisées : `InvalidKeyEncoding`, `InputTooLarge`, `RandomUnavailable`, `AuthenticationFailed`
(segment altéré), `UnsupportedVersion` (version de flux inconnue), `EncryptionFailed`. Aucune
variante ne porte une entrée, une clé, un nom de fichier ou un message de `rustls` /
`aws-lc-rs` (règle actuelle de `error.rs`).

## 9. Secrets en mémoire

| Type | Contenu sensible | Protection |
| :--- | :--- | :--- |
| `Ed25519SigningKey`, `RsaSigningKey` | PKCS#8 | `Zeroizing`, `ZeroizeOnDrop`, `Debug` masqué, ni `Clone` ni sérialisation ; export nommé seulement |
| `DkimSigningKey` | enveloppe des deux précédentes | idem |
| `StreamKey` | 32 octets | idem ; scellement et ouverture par `enc:v2` seulement |
| `StreamEncryptor` / `StreamDecryptor` | clé de segments dérivée, tampon de clair | `Zeroizing` ; `Debug` masqué |
| `TlsCertifiedKey` | clé privée dans `rustls` / `aws-lc-rs` | entrée `SecretBytes` ; copies intermédiaires effacées ; `Debug` masqué ; mémoire C : §17 |
| Clés publiques, `DkimSignedData`, en-têtes | aucun | types ordinaires |

## 10. Consommateurs (programme, §5)

| Lot | Ce qu'il utilise de ce lot | Ce qu'il devra encore demander |
| :- | :--- | :--- |
| 3 — Hôte et socle réseau | `TlsCertifiedKey`, `TlsCertificateStore`, `tls_server_config` ; `tokio-rustls` dans l'hôte | lecture des fichiers et rechargement (hôte) |
| 4 — Socle courrier | `StreamKey`, `StreamEncryptor`, `StreamDecryptor` (contenu des messages et pièces jointes) | où chiffrer (C11) ; adaptateur asynchrone |
| 5 — Réception SMTP | `DkimBodyHasher`, `DkimHeaderCanonicalizer`, `DkimPublicKey::verify` ; TLS (`STARTTLS`) | lecture des balises, DNS, politique (`lyxal_mail_proto`) |
| 6 — Envoi | `DkimSigningKey::sign`, génération et export des clés | **TLS client** (opportuniste) : C8 |
| 7 — Transport sûr et rapports | DKIM pour ARC (`ARC-Message-Signature`, `ARC-Seal` : mêmes primitives, autre nom d'en-tête) | ARC — P6(e) ; DANE et MTA-STS — P6(f) |
| 13 — Administration | génération RSA / Ed25519, `public_key_record_bytes` (enregistrement DNS) ; `TlsCertificateStore` multi-noms | ACME, lecture des dates des certificats — P6(g) |
| 16, 19 — CalDAV, CardDAV | chiffrement en flux (niveau A) | — |

Aucune rupture pour les utilisateurs actuels : `lyxal_notification` garde exactement les mêmes
signatures (`EcdsaP256SigningKey`, `RsaSigningKey::sign_rs256`, `webpush_encrypt`,
`verify_external_hmac_sha1`) ; seul le moteur interne change (C1), vérifié par leurs vecteurs
actuels (RFC 8291 annexe A, signature RS256 égale à OpenSSL).

## 11. Tests

* **Vecteurs publiés** (copiés littéralement, jamais recalculés pour faire passer un test) :
  * Ed25519 : RFC 8032 §7.1 (TEST 1, 2, 3, 1024, SHA(abc)) ;
  * DKIM : RFC 8463 annexe A (même message signé en `ed25519-sha256` et en `rsa-sha256`, clé
    RSA de 1024 bits) ; empreintes de corps vide (`simple` : SHA-256 de CRLF ; `relaxed` :
    SHA-256 de la chaîne vide) ; l'exemple de l'annexe A de la RFC 6376 est réputé ne pas
    vérifier (à revérifier, §17) et n'est pas utilisé comme oracle ;
  * Wycheproof (Apache-2.0, copiés dans `tests/fixtures/wycheproof/` avec leur licence) :
    `rsa_signature_2048_sha256_test.json`, `..._3072_...`, `..._4096_...`,
    `ed25519_test.json`, `aes_gcm_test.json` (contrôle du chemin AES utilisé par le flux).
* **Oracles indépendants** :
  * `tools/check_stream_fixtures.py` (nouveau, même environnement virtuel que
    `check_fixtures.py`, bibliothèque `cryptography` 50.0.1 épinglée) : recalcule par OpenSSL les
    vecteurs littéraux de `STREAM_FORMAT_V1.md` (fichier vide, 1 octet, 65 535, 65 536, 65 537 et
    200 000 octets ; sel et préfixe imposés par une fonction de test privée) et vérifie les
    signatures Ed25519 et RS256 produites par le crate sur des données fixes ;
  * `tools/dkim_oracle/` (nouveau, espace de travail isolé avec son verrou, comme
    `tools/contracts/`) : comparaison différentielle avec `mail-auth` 0.16.0 (canonicalisation,
    empreinte du corps et des en-têtes) sur le corpus `resources/dkim` de `mail-auth` et les cas
    de Mox `dkim_test.go` (MIT) transposés ; `mail-auth` n'est jamais une dépendance du crate.
* **Propriétés** (`proptest`, déjà en dépendance de test) : aller-retour du flux pour des
  tailles autour des frontières de segment ; toute plage lue égale la tranche du clair ;
  troncature à chaque frontière, échange de deux segments, bit modifié dans l'en-tête ou un tag,
  autre contexte → échec ; empreinte DKIM du corps indépendante du découpage des morceaux (CR et
  LF coupés entre deux morceaux) ; signature puis vérification DKIM pour les deux algorithmes et
  les quatre combinaisons de canonicalisation ; clé RSA générée → import → signature → vérif.
* **TLS** (sans réseau, poignée de main en mémoire entre `rustls::ServerConnection` et un client
  `rustls` de test) : TLS 1.2 et 1.3 ; option `Tls13` refuse un client 1.2 ; ALPN négocié ;
  choix par SNI, joker, défaut sans SNI ; échec propre sans certificat ; remplacement à chaud
  visible à la poignée de main suivante ; clé ne correspondant pas au certificat, PEM chiffré,
  PEM tronqué, chaîne vide refusés ; RSA, ECDSA P-256 et Ed25519 ; **non-régression du
  `panic!` du §2.2** (les deux fournisseurs de `rustls` sont actifs dans le workspace).
  Certificats de test générés une fois par `openssl` (commandes notées dans
  `tests/fixtures/README.md`), réservés aux tests, comme `rsa2048_test_only.*` aujourd'hui.
* **Contrats** : `tools/check_contracts.py` étendu à `Ed25519SigningKey`, `DkimSigningKey`,
  `StreamKey`, `StreamEncryptor`, `StreamDecryptor`, `TlsCertifiedKey` (traits interdits :
  `Clone`, `Default`, `Display`, `PartialEq`, `Serialize`, `Deref`, conversions brutes) ; tests
  `compile_fail` comme pour les types existants.
* **Fuzzing** (`fuzz/`, nouvelles cibles, ajoutées à `tools/run_fuzz.py` et au workflow) :
  `stream_open` (en-tête et segments hostiles : aucun `panic!`, aucune allocation non bornée),
  `dkim_canonicalize` (aucun `panic!` ; découpage indifférent), `dkim_public_key` (`p=`
  hostile), `tls_pem` (chaînes et clés PEM hostiles).
* `cargo clippy -p lyxal_crypto --all-targets --all-features -D warnings`,
  `scripts/ci/ci_local.sh` complet (avec `--fuzz` avant chaque fusion).

## 12. CI et contrôles

* **Nouveau garde-fou** `scripts/ci/check_crypto_dependencies.py` (job « Cryptographie » de
  `.github/workflows/ci.yml` et `scripts/ci/ci_local.sh`) : lit `cargo metadata --no-deps` et
  échoue si un paquet du workspace **autre que `lyxal_crypto`** déclare une dépendance directe
  (normale, de test ou de compilation) vers : `aes-gcm`, `aes`, `argon2`, `aws-lc-rs`,
  `aws-lc-sys`, `blake3`, `chacha20poly1305`, `ece`, `ed25519-dalek`, `hkdf`, `hmac`,
  `jsonwebtoken`, `mail-auth`, `openssl`, `p256`, `ring`, `rsa`, `rustls`, `sha1`, `sha2`,
  `totp-rs`. Exceptions nommées dans le script : `tokio-rustls` permis aux **hôtes**
  (`apps/*`) pour le transport (C7) ; `sha2` de `[workspace.dependencies]` à vérifier paquet par
  paquet (aucun paquet hors `lyxal_crypto` ne l'utilise aujourd'hui, constaté). Il contrôle aussi
  qu'aucun fichier `.rs` hors `crates/lyxal_crypto` n'écrit `use ring::`, `aws_lc_rs::` ou
  `rustls::ServerConfig` / `ClientConfig::builder`. Le cas des crates de protocole qui amènent
  leur propre TLS (`lettre`, `reqwest` dans `lyxal_notification`) est noté : elles restent
  permises (dépendance indirecte, existant validé K10 / N4).
* Les espaces de travail isolés `tools/contracts` et `fuzz` reçoivent leur verrou mis à jour
  (ils compileront `aws-lc-sys` : CI plus longue d'une à deux minutes, non mesuré).
* `deny.toml` : inchangé (aucune licence nouvelle, §2.2). Les alertes de sécurité ne sont pas
  contrôlées par `cargo deny` aujourd'hui (choix du lot 0) ; ce plan ne change pas ce choix mais
  le garde-fou vérifie que l'arbre normal de `lyxal_crypto` ne contient ni `rsa` ni
  `ed25519-dalek` (`cargo tree -p lyxal_crypto -e normal`).

## 13. Documents

| Document | Changement |
| :--- | :--- |
| `crates/lyxal_crypto/API_CONTRACT.md` | Nouvelles sections « Signatures RSA et Ed25519 (P6 b, d) », « DKIM (P6 c) », « TLS serveur (P6 a) », « Chiffrement de fichiers en flux (P6 i) » ; tableau des types sensibles complété ; **une seule modification d'une phrase existante** : `RsaSigningKey` « jamais générée ; aucun export » devient « générée par `generate`, export PKCS#8 pour le coffre-fort seulement » (C6) ; section K8 : « calculée par `aws-lc-rs` » (C1) |
| `crates/lyxal_crypto/STREAM_FORMAT_V1.md` (nouveau) | Spécification suffisante pour une implémentation indépendante (comme `ENVELOPE_FORMAT_V2.md`) : octets exacts, dérivation, nonces, AAD, règles de rejet, vecteurs littéraux |
| `crates/lyxal_crypto/SECURITY.md` | Code C d'AWS-LC dans les dépendances (FFI, distinct du `forbid(unsafe_code)` du crate) ; budget d'un scellement par fichier ; lecture en flux (§7.2) ; TLS (clé en mémoire C, rechargement par l'hôte) ; RSA 1024 bits accepté pour la vérification DKIM seulement |
| `crates/lyxal_crypto/README.md`, `Cargo.toml` (description) | Liste des primitives ; tableau « Vérification » (nouveaux contrôles et cibles de fuzzing) |
| `crates/lyxal_crypto/ROADMAP.md` | Audit externe : périmètre étendu à TLS, DKIM et au format de flux ; extensions P6 (e) à (h) et (j) inscrites avec leur lot |
| `crates/lyxal_crypto/SOURCES.md` (nouveau) | `mail-auth` 0.16.0, commit `c862df2`, `src/dkim/canonicalize.rs` porté, `Apache-2.0 OR MIT`, avis conservé ; Wycheproof (commit à figer à l'exécution), Apache-2.0 ; RFC 8032 et 8463 (vecteurs) ; Mox `dkim` (MIT), cas de test transposés |
| `.agents/rules/lyxal_standards_and_checklist.md` §11.3 et §13 | Lignes du tableau des primitives (signatures RSA / Ed25519, DKIM, TLS serveur, flux) ; règles d'usage 10 à 12 (DKIM, TLS, flux) ; liste « hors scope » : Ed25519 retiré, X25519 / ChaCha20-Poly1305 / post-quantique gardés comme primitives exposées, permis à l'intérieur de TLS (C3) ; crates interdites complétées (`aws-lc-rs`, `ed25519-dalek`, `rsa`, `rustls` pour la configuration, `mail-auth`) ; checklist « Cryptographie » complétée |
| `.agents/AGENTS.md` §6 | Ligne `lyxal_crypto` : ajout de RSA / Ed25519, DKIM, TLS serveur, chiffrement en flux |
| `implementation_plan.md` (racine) | Lot 2 noté réalisé ; §3.1 et §6 : `mail-auth` 0.16.0 ; §5 lot 2 : source `aws-lc-rs` |
| `crates/lyxal_mail/ROADMAP.md`, `crates/lyxal_storage/ROADMAP.md` | Niveau A : primitive disponible, branchement au lot 4 ; déduplication incompatible avec les fichiers chiffrés |

Ce plan est supprimé une fois exécuté (§0.4 de `AGENTS.md`).

## 14. Fichiers

`crates/lyxal_crypto/` :

* `Cargo.toml` (dépendances §3, description) ; `src/lib.rs` (modules et réexportations) ;
* `src/signing.rs` (étendu : RSA généré, clés publiques, Ed25519 ; passage à `aws-lc-rs`),
  `src/signing_vectors.rs` (étendu) ; `src/webpush.rs`, `src/hmac.rs` (passage à `aws-lc-rs`) ;
* `src/dkim.rs` et `src/dkim/canonicalize.rs` (porté) (nouveaux) ;
* `src/tls.rs` (nouveau) ; `src/stream.rs` (nouveau) ; `src/context.rs` (encodage d'identité
  partagé avec le flux, sans changer `enc:v2`) ; `src/error.rs` (§8) ;
* `tests/it/` : `signatures.rs`, `dkim_vectors.rs`, `tls_server.rs`, `stream_v1.rs`,
  `stream_proptests.rs` (nouveaux) ; `tests/fixtures/` : Wycheproof, RFC 8463, certificats de
  test, `README.md` (provenance et commandes) ;
* `tools/check_contracts.py`, `tools/check_stream_fixtures.py` (nouveau),
  `tools/dkim_oracle/` (nouveau), `tools/run_fuzz.py` ; `fuzz/fuzz_targets/` (quatre cibles),
  `fuzz/seeds/`, `fuzz/Cargo.toml`, verrous de `fuzz/` et `tools/contracts/` ;
* `API_CONTRACT.md`, `STREAM_FORMAT_V1.md` (nouveau), `SECURITY.md`, `README.md`,
  `ROADMAP.md`, `SOURCES.md` (nouveau).

Ailleurs : `scripts/ci/check_crypto_dependencies.py` (nouveau), `scripts/ci/crypto_checks.sh`,
`scripts/ci/ci_local.sh`, `.github/workflows/ci.yml`, `.github/workflows/crypto-fuzz.yml` ;
`.agents/rules/lyxal_standards_and_checklist.md`, `.agents/AGENTS.md` ; `implementation_plan.md`
(racine), `crates/lyxal_mail/ROADMAP.md`, `crates/lyxal_storage/ROADMAP.md`.

**Taille estimée : M** — environ 2 600 lignes de Rust (signatures et clés 450, DKIM 1 000 dont
≈ 700 portées, TLS 450, flux 550, migration K8 et erreurs 150) et 2 400 lignes de tests, outils et
cibles de fuzzing ; plus environ 600 lignes de documents (dont `STREAM_FORMAT_V1.md`). Découpage
proposé (C13) : **2a** TLS + flux (≈ 2 600 lignes, tests compris), **2b** signatures + DKIM
(≈ 2 400 lignes).

## 15. Décisions du CTO

Décisions C1 à C14 et écarts E1 à E5 **validés par le CTO** le 20 novembre 2026, tels que proposés ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **C1** | Quelle bibliothèque fait les signatures, les clés et le TLS ? | **`aws-lc-rs`**, la bibliothèque d'Amazon déjà présente dans le projet (amenée par SurrealDB). Elle sait tout faire, y compris créer des clés RSA, ce que `ring` ne sait pas. Pour n'avoir qu'**un seul** moteur, les fonctions des notifications push (validées en K8) passent aussi de `ring` à `aws-lc-rs`, sans rien changer pour `lyxal_notification`. `ring` reste présent dans le projet, amené par d'autres bibliothèques, mais `lyxal_crypto` ne l'utilise plus. Autre choix possible : garder `ring` et n'utiliser `aws-lc-rs` que pour créer les clés RSA (deux moteurs à suivre au lieu d'un). |
| **C2** | Comment éviter la faille « Marvin » de la bibliothèque `rsa` ? | **Ne pas utiliser la crate `rsa` du tout.** La faille touche les opérations faites avec la clé secrète (signer, et la création de la clé) ; vérifier une signature n'est pas touché. Une version corrigée (0.10.0) vient de sortir mais demande une version de Rust plus récente que celle exigée par `lyxal_crypto` et repose sur du code tout neuf. `aws-lc-rs` (C1) fait le RSA en temps constant. Les copies de `rsa` déjà amenées par SurrealDB et par la bibliothèque des clés d'accès (`webauthn-rs`) ne sont pas utilisées par nos signatures ; elles sont signalées pour information. |
| **C3** | Ed25519, X25519, ChaCha20 et le post-quantique étaient « hors scope » : que change-t-on ? | **Ed25519 entre** dans la liste des primitives (signer, vérifier, créer des clés), comme P6(b) l'a accepté. **X25519, ChaCha20-Poly1305 et l'échange de clés post-quantique hybride (X25519MLKEM768) restent hors scope comme fonctions offertes aux modules**, mais sont **permis à l'intérieur de TLS** : ce sont les réglages standard des navigateurs et des logiciels de courrier, que la bibliothèque TLS négocie elle-même. Les retirer rendrait certains clients plus lents (téléphones sans accélération AES) et perdrait la protection contre « enregistrer aujourd'hui, déchiffrer demain ». |
| **C4** | Où mettre DKIM ? | **Partagé en deux.** Dans `lyxal_crypto` : tout ce qui décide des octets signés et le calcul de la signature (mise en forme standard des en-têtes et du corps, empreintes, signature, vérification, clés). Dans les crates du courrier (lots 5 à 7) : la lecture de l'en-tête `DKIM-Signature`, la recherche DNS, les règles (dates, alignement des domaines) et le résultat affiché. La mise en forme est **reprise de `mail-auth`** (licence libre MIT / Apache, compatible avec `lyxal_crypto`), pas réécrite ; `mail-auth` n'est pas ajouté comme dépendance de `lyxal_crypto`, car il ferait lui-même sa cryptographie hors de notre crate. |
| **C5** | Quelles règles DKIM ? | Signer en **RSA 2048 bits et en Ed25519** (double signature, comme Stalwart et Mox : RSA est compris partout, Ed25519 est plus moderne). Accepter à la vérification les clés RSA de **1024 à 4096 bits** (la norme RFC 8301 l'impose : beaucoup de domaines ont encore des clés de 1024 bits) ; c'est le seul endroit où 1024 bits est accepté. Refuser les signatures `rsa-sha1` (interdites par la même norme). Lire la limite de longueur `l=` des messages reçus, ne jamais la produire. |
| **C6** | Peut-on sortir une clé privée de `lyxal_crypto` ? | Oui, **seulement pour la ranger dans le coffre-fort `lyxal_secrets`** (export PKCS#8), pour les clés DKIM RSA et Ed25519, comme c'est déjà le cas pour la clé VAPID. Le contrat de `RsaSigningKey` change donc d'une phrase (« jamais générée ; aucun export » devient « générée, exportable pour le coffre-fort ») ; c'est la seule modification d'une promesse existante, permise en pré-production (§0). |
| **C7** | Comment le TLS est-il réglé et qui y touche ? | `lyxal_crypto` fabrique la configuration TLS complète ; les hôtes (`lyxal-groupware`) ne font que brancher les connexions (bibliothèque `tokio-rustls`, permise aux hôtes seulement). Réglages : TLS 1.2 minimum (1.3 de préférence), pas de « 0-RTT » (rejouable), pas de certificat client, plusieurs certificats choisis selon le nom demandé, remplacement à chaud sans couper les connexions. Les fichiers de certificat sont lus par l'hôte (ou pris dans le coffre-fort), pas par `lyxal_crypto`. La lecture des dates d'expiration d'un certificat attend le lot 13 (certificats automatiques). |
| **C8** | Et le TLS des connexions **sortantes** (envoi vers les autres serveurs) ? | **Pas dans ce lot** : P6 ne le prévoit pas. Le plan du lot 6 le demandera (TLS « opportuniste » des serveurs de courrier, qui accepte un certificat non vérifié faute de mieux), puis le lot 7 (MTA-STS, DANE). Même règle qu'au C7 : configuration fabriquée par `lyxal_crypto`. |
| **C9** | Comment chiffrer un fichier de n'importe quelle taille ? | **Une clé par fichier, tirée au hasard, elle-même scellée par la clé de l'organisation** et rangée dans la fiche du fichier (en base), jamais dans le fichier. Le fichier est découpé en morceaux de 64 Kio, chacun verrouillé et numéroté, le dernier marqué « dernier » : on détecte un morceau modifié, déplacé, retiré ou un fichier coupé, et on peut lire un passage sans tout déchiffrer. Avantages : changer la clé d'une organisation ne réécrit aucun fichier ; supprimer la clé d'un message le rend illisible même dans les sauvegardes. Format écrit pour Lyxal, sur des briques déjà validées (AES-256-GCM, HKDF), décrit dans `STREAM_FORMAT_V1.md` et vérifié par OpenSSL. Autre choix possible : clé du fichier **dérivée** de la clé de l'organisation (rien à ranger en base, mais changer la clé oblige à réécrire tous les fichiers). |
| **C10** | Le niveau A suffit-il à « chiffrer les boîtes » ? | Il protège les **fichiers** (disques, sauvegardes, stockage S3 volés). Il **ne chiffre pas** ce qui est dans la base : objet, expéditeur, dates, index de recherche. Il rend impossible la déduplication des fichiers chiffrés. Une clé d'organisation perdue rend ses fichiers illisibles : la sauvegarde des clés du coffre-fort devient vitale. Proposition : accepter ces limites pour le niveau A ; chiffrer des champs de la base serait un autre chantier, à décider plus tard. |
| **C11** | Qui branche le chiffrement sur les fichiers ? | **Décidé au lot 4.** Proposition à confirmer alors : une option « compartiment chiffré » dans `lyxal_storage` (un seul endroit, réutilisé par le courrier, les agendas et les contacts), qui garde la clé scellée de chaque fichier dans sa fiche. `lyxal_crypto` reste sans `tokio`. |
| **C12** | Faut-il un contrôle automatique des bibliothèques cryptographiques ? | **Oui.** Il n'en existe aucun aujourd'hui (la règle n'est vérifiée qu'à la relecture). Un script de CI refusera toute bibliothèque cryptographique (liste au §12) ajoutée directement à un autre crate que `lyxal_crypto` ; `tokio-rustls` est permis aux hôtes pour le transport. |
| **C13** | Livrer en une fois ou en deux ? | **Deux demandes de fusion**, sous ce même plan : **2a** (TLS serveur et chiffrement en flux, nécessaires aux lots 3 et 4), puis **2b** (signatures, clés, DKIM, nécessaires aux lots 5 et 6). Deux relectures plus courtes d'un crate sensible ; le lot 3 peut commencer plus tôt. |
| **C14** | Faut-il une relecture externe de ces ajouts ? | Oui, **avant la première mise en production**, dans l'audit externe déjà prévu (`ROADMAP.md` de `lyxal_crypto`), dont le périmètre est étendu à TLS, DKIM et au format de flux. Rien ne bloque les lots suivants d'ici là. |

## 16. Risques

| Risque | Ce qu'il faut savoir | Réponse |
| :--- | :--- | :--- |
| Code C dans la chaîne crypto | `aws-lc-rs` appelle AWS-LC (C et assembleur, issu de BoringSSL) : une faille mémoire y est possible, hors du `forbid(unsafe_code)` du crate | Bibliothèque très suivie (correctifs RustSec 2026 appliqués) ; déjà compilée dans tous nos binaires ; veille des avis ; C14 |
| Couplage à `rustls` | Le contrat expose `rustls::ServerConfig` (réexporté) : une montée en 0.24 changera ce contrat | Version épinglée `>= 0.23.46` ; montée planifiée comme tout changement (pré-production : rupture permise, appelants mis à jour) |
| Panne au démarrage TLS | `ServerConfig::builder()` s'arrête par `panic!` quand les deux fournisseurs sont actifs (cas du workspace) | Fournisseur toujours explicite ; test de non-régression ; garde-fou §12 |
| Canonicalisation DKIM | Un écart d'un octet avec les autres serveurs fait échouer des signatures (ou en accepte de fausses) | Code porté d'une bibliothèque éprouvée ; oracle différentiel `mail-auth` ; vecteurs RFC 8463 ; fuzzing ; essais réels des lots 5, 6 et 22 |
| Attaque `l=` | Un message signé avec `l=` peut recevoir du texte ajouté après la partie signée | Primitive neutre ; refus ou marquage décidé au lot 5 |
| Lecture en flux | Un segment rendu est authentique, mais la fin du fichier n'est pas encore vérifiée | Contrat et `SECURITY.md` : l'appelant interrompt la réponse sur erreur ; tests |
| Budget des scellements | Un scellement par fichier sous la clé d'organisation (≈ 16,7 millions recommandés par clé) | Rotation de `lyxal_secrets` ; compteur à l'hôte (comme aujourd'hui) |
| Perte de clés | Clé maîtresse ou d'organisation perdue = fichiers chiffrés perdus | Sauvegarde du coffre-fort (exploitation) ; rappelé dans `SECURITY.md` et le `README.md` du lot 4 |
| Effacement de la mémoire | Les clés tenues par `rustls` / `aws-lc-rs` sont en mémoire C ; `PrivateKeyDer` n'est pas effacé seul | Effacement explicite des copies Rust ; limite écrite dans `SECURITY.md` |
| Interopérabilité TLS | Rustls n'offre pas TLS 1.0 / 1.1 : de vieux serveurs de courrier ne pourront pas chiffrer vers nous et enverront en clair sur le port 25 | Conforme aux RFC 8996 et 9325 ; constaté par les essais réels (P11) |
| Durée de la CI | `aws-lc-sys` compilé aussi dans les bancs isolés (contrats, fuzzing) | Caches de la CI ; mesuré au premier passage |

## 17. Faits non vérifiés

* Date de publication et maturité de `rsa` 0.10.0 (vue seulement dans l'index local) ;
  `ed25519-dalek` 3.0.0 (idem) — sans effet si C1 / C2 sont validés.
* Effacement par AWS-LC de la mémoire d'une clé libérée (`EVP_PKEY_free`) : connu pour
  BoringSSL, à confirmer pour AWS-LC.
* Fonctionnalité exacte de `rustls-pki-types` 1.15 pour la lecture PEM (`PemObject`, sous
  `alloc` / `std`) ; existence de `CertifiedKey::keys_match` constatée, comportement à tester.
* Compilation d'`aws-lc-sys` sous Windows dans les bancs isolés (le workspace la compile déjà ;
  l'outil `nasm` fourni par la fonctionnalité `prebuilt-nasm` par défaut, à vérifier).
* L'exemple de l'annexe A de la RFC 6376 ne vérifie pas (mémoire, errata à retrouver).
* Prise en charge d'Ed25519 DKIM par les grands fournisseurs (Gmail, Outlook.com) : à constater
  aux essais réels (P11) ; d'où la double signature RSA + Ed25519 (C5).
* Débit du chiffrement en flux et durée d'une génération RSA 4096 sur le matériel cible : non
  mesurés (mesures notées au `README.md` à l'exécution).
* Compilation de `mail-auth` sans fonctionnalité cryptographique (pour SPF / DMARC au lot 5) :
  question du lot 5, sans effet ici.
* Numéros et sections de RFC cités (6376, 8301, 8463, 8032, 8017, 5280, 5208, 8446, 5246, 9325,
  8996, 8314, 7301, 6066) : de mémoire, à revérifier en écrivant les documents.

## 18. Checklist (§13)

* [ ] **Architecture** : responsabilités dans `lyxal_crypto` (P6) ; DKIM partagé avec les crates
  du courrier (C4) ; aucun lien vers un module ; aucun cycle ; aucune dépendance Lyxal, base ou
  runtime asynchrone ajoutée à `lyxal_crypto`.
* [ ] **Core** : sans objet (aucune fonction SurrealQL) ; aucune primitive dupliquée.
* [ ] **SurrealQL** : sans objet.
* [ ] **Rust** : aucun `panic!` (dont `ServerConfig::builder()`), aucun `unwrap` hors tests,
  entrées bornées avant allocation, erreurs sans donnée reflétée ; `#![forbid(unsafe_code)]`
  et `#![deny(missing_docs)]` gardés.
* [ ] **Erreurs** : six variantes ajoutées à `CryptoError` (§8) ; aucune erreur masquée
  (vérification : `Err` pour un format invalide, `Ok(false)` pour une signature fausse).
* [ ] **Événements** : sans objet.
* [ ] **Cryptographie** : extensions P6 (a), (b), (c), (d), (i) seulement ; `aws-lc-rs` seul
  moteur asymétrique (C1) ; aucune crate `rsa` (C2) ; types sensibles opaques, `ZeroizeOnDrop`,
  `Debug` masqué ; `OsRng` / aléa du système ; aucun AAD vide (flux : AAD = en-tête + contexte) ;
  vecteurs publiés et oracles indépendants ; garde-fou CI (C12).
* [ ] **Zéro dette** (§0) : `ring` retiré de `lyxal_crypto` (pas de double moteur) ; aucun alias
  ni ancien chemin conservé ; version 0.1.0 ; `ROADMAP.md` tenue ; plan supprimé une fois
  exécuté.
* [ ] **Provenance** (F4, F5) : `SOURCES.md` créé ; seul code repris : `mail-auth`
  (`Apache-2.0 OR MIT`) ; aucun code AGPL, GPL ou `LicenseRef-SEL`.
* [ ] **Validation CTO** : écarts E1 à E5, décisions C1 à C14.
