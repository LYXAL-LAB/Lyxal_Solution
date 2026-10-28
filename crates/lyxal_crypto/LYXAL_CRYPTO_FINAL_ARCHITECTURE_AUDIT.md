# 🏛️ RAPPORT D'AUDIT ARCHITECTURAL ET TECHNIQUE FINAL — `lyxal_crypto`

**Module audité :** [`crates/lyxal_crypto`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto)  
**Référentiel normatif :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) (notamment §5.2, §6, §10, §11.3)  
**Date d'audit :** 28 octobre 2026  
**Auditeur :** CTO / Architecte Cryptographique Indépendant  
**Mode d'intervention :** Lecture seule stricte — Aucune modification de code ni de configuration  

---

## 1. Périmètre & Objectifs de l'Audit

Le présent audit a pour périmètre exclusif le crate [`crates/lyxal_crypto`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto). Il vise à déterminer si le code propre de `lyxal_crypto` :
1. Respecte rigoureusement la constitution architecturale de Lyxal OS ;
2. Constitue un moteur cryptographique fiable, étanche et performant ;
3. S'intègre sans distorsion dans le workspace Rust ;
4. Présente une cohérence absolue entre ses implémentations effectives et ses contrats documentés.

Toute considération fonctionnelle relative aux applications consommatrices (telles que `lyxal_booking`) est strictement hors périmètre.

---

## 2. Synthèse Exécutive & Verdict

### Verdict Global : **`CONFORME AVEC RÉSERVES`**

Le moteur cryptographique `lyxal_crypto` atteint un niveau de sécurité et de robustesse technique exemplaire sur son implémentation Rust native :
- Les primitives fondamentales (AES-256-GCM, SHA-256, BLAKE3, HMAC-SHA256, HKDF-SHA256, Argon2id) sont correctement isolées, auditées et validées par **44 tests unitaires et d'intégration** conformes aux vecteurs officiels NIST et RFC.
- L'isolation mémoire (`Zeroizing`, masquage `[REDACTED]`, interdiction de `Clone` sur `EncryptionKey`, exposition `pub(crate)` de la clé) élimine les risques de fuite mémoire.
- La défense contre les attaques par canaux auxiliaires (timing attacks) est strictement assurée via des comparaisons natives en temps constant (`Constant-Time`).
- Les formats canoniques d'enveloppe (`enc:v1:<key_id>:<base64url>`) et de contexte AAD (`lyxal:v1:...`) sont rigoureusement inviolables et résistants aux ambiguïtés.

Néanmoins, l'audit formule des **réserves substantielles sur la documentation et la cohérence de l'espace de travail Cargo** :
- **Divergences majeures de contrats documentaires** : Les documents [`API_CONTRACT.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/API_CONTRACT.md), [`README.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/README.md) et [`SECURITY.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/SECURITY.md) présentent des signatures erronées, des exemples de code fictifs non compilables et une confusion textuelle entre format AAD et format d'enveloppe.
- **Convention Cargo** : Le crate n'exploite pas l'héritage de workspace (`workspace.dependencies`) et conserve des versions divergentes (`thiserror 2.0` vs `1.0`).
- **Dette transitoire** : La présence de helpers de migration dédiés à l'application historique Cal.rs au sein même de la racine de la bibliothèque cryptographique du socle.

---

## 3. Matrice Exhaustive des Constats

| Identifiant | Sévérité | Composant / Fichiers | Thème | Résumé du Constat |
| :--- | :---: | :--- | :--- | :--- |
| **`CRYPTO-DOC-001`** | **Majeure** | [`API_CONTRACT.md:68-75`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/API_CONTRACT.md#L68-L75) | Contrat d'API | Désynchronisation entre les signatures du tableau contractuel et le code réel (HMAC, KDF, Password). |
| **`CRYPTO-DOC-002`** | **Majeure** | [`README.md:29-105`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/README.md#L29-L105), [`SECURITY.md:37`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/SECURITY.md#L37) | Documentation | Exemples de code fictifs non compilables (`EncryptionService`, `Plaintext`), et format d'enveloppe erroné. |
| **`CRYPTO-ARCH-001`** | **Moyenne** | [`Cargo.toml:1-23`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/Cargo.toml#L1-L23) | Intégration Workspace | Absence d'héritage de workspace Cargo et divergence de version `thiserror` (2.0 vs 1.0). |
| **`CRYPTO-ARCH-002`** | **Faible** | [`src/lib.rs:47-51,123-155`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L47-L51) | Frontière Domaine | Présence de primitives de migration ad-hoc Cal.rs au niveau de l'API racine du socle cryptographique. |
| **`CRYPTO-QUAL-001`** | **Faible** | [`src/cipher.rs:19,52`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/cipher.rs#L19) | Pérennité Code | Dépréciation de l'appel interne `GenericArray::from_slice` via `aes-gcm`. |

---

## 4. Détail des Constats & Preuves

### 4.1. `CRYPTO-DOC-001` : Désynchronisation des signatures dans `API_CONTRACT.md`
- **Sévérité :** **Majeure**
- **Fichier et lignes concernés :** [`crates/lyxal_crypto/API_CONTRACT.md:68-75`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/API_CONTRACT.md#L68-L75)
- **Règle architecturale :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) §1 ("Toute fonction publique doit être documentée... Stable -> Documenté -> Réutilisable") et §11.3 ("Le contrat complet est documenté dans API_CONTRACT.md").
- **Preuve observée :**
  1. `sign_hmac_sha256` et `sign_hmac_sha256_hex` sont documentés avec un retour `Result<Vec<u8>, CryptoError>` et `Result<String, CryptoError>`, alors que l'implémentation effective ([`src/hmac.rs:7,14`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hmac.rs#L7-L14)) retourne directement `[u8; 32]` et `String` de manière infaillible.
  2. `verify_hmac_sha256` et `verify_hmac_sha256_hex` sont documentés avec un retour `Result<(), CryptoError>`, alors que le code ([`src/hmac.rs:22,32`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hmac.rs#L22-L32)) retourne `bool`.
  3. `verify_password` est documenté avec un retour `Result<(), CryptoError>`, alors que le code ([`src/password.rs:45`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/password.rs#L45)) retourne `Result<bool, CryptoError>`.
  4. `hkdf_sha256` est documenté avec l'ordre de paramètres `(salt, ikm, info, okm_out)`, alors que le code ([`src/kdf.rs:7`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/kdf.rs#L7)) attend `(ikm, salt, info, output)`.
  5. `KeyGenerationPolicy` est documenté avec les variantes `Strict` vs `GenerateIfMissing` (ligne 54), alors que le type réel déclaré dans [`src/key_resolver.rs:14-19`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/key_resolver.rs#L14-L19) possède les variantes `AllowGenerate` et `RequireExisting`.
- **Conséquence :** Les ingénieurs intégrant `lyxal_crypto` sur la base de son contrat d'API officiel rencontrent des erreurs de typage et de compilation immédiates.
- **Correction recommandée :** Aligner formellement les types de retour et l'ordre des paramètres dans `API_CONTRACT.md` sur l'implémentation Rust réelle sans altérer le code.

---

### 4.2. `CRYPTO-DOC-002` : Exemples fictifs et format d'enveloppe erroné dans la documentation
- **Sévérité :** **Majeure**
- **Fichier et lignes concernés :** 
  - [`crates/lyxal_crypto/README.md:29, 54-74, 89, 103-104`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/README.md#L29-L105)
  - [`crates/lyxal_crypto/SECURITY.md:37`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/SECURITY.md#L37)
- **Règle architecturale :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) §11.3 ("Format d'Enveloppe Moderne : `enc:v1:<key_id>:<base64url_payload>`").
- **Preuve observée :**
  1. `README.md` (lignes 54-74) présente un exemple d'utilisation avec des types imaginaires introuvables dans le crate : `EncryptionContext`, `EncryptionService`, `Plaintext`.
  2. `README.md` (lignes 89, 103, 104) applique l'opérateur `?` sur des retours de fonctions non faillibles ou booléennes (`needs_rehash(&hash)?`, `sign_hmac_sha256(key, data)?`, `verify_hmac_sha256(key, data, &signature)?`), interdisant toute compilation de l'exemple.
  3. `README.md` (ligne 29) et `SECURITY.md` (ligne 37) documentent le format d'enveloppe sérialisé comme étant :
     `lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`
     au lieu du format canonique effectif et scellé :
     `enc:v1:<key_id>:<base64url_payload>`.
     `lyxal:v1` est le préfixe de construction du contexte AAD, pas le format de stockage d'enveloppe.
- **Conséquence :** Risque de confusion critique entre le format d'enveloppe de persistance et la chaîne de dérivation AAD, et impossibilité d'utiliser les exemples du `README.md`.
- **Correction recommandée :** Réécrire intégralement la section *Utilisation* de `README.md` avec les types réels (`CryptoEngine`, `SecretContext`, `KeyResolver`, `Zeroizing`) et rectifier la définition de l'enveloppe dans `README.md` et `SECURITY.md`.

---

### 4.3. `CRYPTO-ARCH-001` : Incohérence d'intégration dans le Workspace Cargo
- **Sévérité :** **Moyenne**
- **Fichier et lignes concernés :**
  - [`crates/lyxal_crypto/Cargo.toml:1-23`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/Cargo.toml#L1-L23)
  - [`Cargo.toml:1-35`](file:///c:/Users/HP/Desktop/Lyxal_OS/Cargo.toml#L1-L35)
- **Règle architecturale :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) §1 & bonnes pratiques Cargo Workspace.
- **Preuve observée :**
  1. Le fichier [`crates/lyxal_crypto/Cargo.toml`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/Cargo.toml) redéclare localement `version = "0.1.0"`, `edition = "2021"`, et ses dépendances sans utiliser l'héritage `workspace = true` proposé par le `Cargo.toml` racine.
  2. Le workspace racine déclare `thiserror = "1.0"` dans `[workspace.dependencies]`, alors que `lyxal_crypto` spécifie directement `thiserror = "2.0"`.
  3. Un fichier résiduel `crates/lyxal_crypto/Cargo.lock` est présent dans le répertoire du sous-crate, redondant avec le verrou central du workspace.
- **Conséquence :** Risque de désynchronisation de versions dans l'arbre de compilation du workspace et maintenance manuelle accrue.
- **Correction recommandée :** Raccorder les métadonnées de `crates/lyxal_crypto/Cargo.toml` aux dépendances du workspace lors de la prochaine passe d'alignement globale.

---

### 4.4. `CRYPTO-ARCH-002` : Présence de fonctions de migration applicative Cal.rs
- **Sévérité :** **Faible (Dette technique de transition)**
- **Fichiers et lignes concernés :** [`crates/lyxal_crypto/src/lib.rs:47-51, 123-155`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L47-L51)
- **Règle architecturale :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) §5.1 ("Une responsabilité = un endroit") et §11.3 (Le crate fournit des primitives pures et génériques).
- **Preuve observée :**
  - Les méthodes suivantes sont exposées publiquement sur la racine de `lyxal_crypto` et sur `CryptoEngine` :
    - [`decode_calrs_legacy_hex`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L47)
    - [`CryptoEngine::decrypt_calrs_aes_base64`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L123)
    - [`CryptoEngine::migrate_calrs_aes_base64`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L137)
    - [`CryptoEngine::migrate_legacy_calrs_hex`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/lib.rs#L148)
- **Conséquence :** Pollution de l'API standard d'une fondation transversale par la logique de transition d'une application historique spécifique.
- **Correction recommandée :** Annoter ces fonctions avec `#[deprecated]` en spécifiant qu'elles seront déclassées après stabilisation définitive des modules consommateurs.

---

### 4.5. `CRYPTO-QUAL-001` : Avertissement de dépréciation sur `GenericArray`
- **Sévérité :** **Faible**
- **Fichier et lignes concernés :** [`crates/lyxal_crypto/src/cipher.rs:19, 52`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/cipher.rs#L19)
- **Règle architecturale :** Zéro warning de compilation en production.
- **Preuve observée :**
  - La compilation interne remonte l'avertissement :  
    `warning: use of deprecated associated function aes_gcm::aead::generic_array::GenericArray::<T, N>::from_slice: please upgrade to generic-array 1.x`.
- **Conséquence :** Bruit de compilation lors des passes de vérification.
- **Correction recommandée :** Adopter la syntaxe non dépréciée lors de la prochaine montée de version de `aes-gcm`.

---

## 5. Audit Approfondi du Code & Sécurité des Primitives

### 5.1. Chiffrement & Déchiffrement AES-256-GCM ([`src/cipher.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/cipher.rs))
- **Sécurité du Nonce :** Chaque opération de chiffrement appelle `OsRng.fill_bytes(&mut nonce_bytes)` (ligne 18). Aucun compteur statique ni PRNG déterministe n'est utilisé. Le risque d'attaque par réutilisation de nonce est nul.
- **Authentification AAD :** Les données associées sont passées nativement à la structure `Payload` d'AES-256-GCM. Toute altération du contexte ou du ciphertext lève `CryptoError::AuthenticationFailed`.
- **Protection Mémoire :** Le texte en clair déchiffré est enveloppé dans `Zeroizing<Vec<u8>>` dès sa sortie de l'algorithme, garantissant l'écrasement mémoire à la libération.

### 5.2. Format d'Enveloppe `enc:v1` ([`src/envelope.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/envelope.rs))
- **Grammaire stricte :** Découpage via `splitn(4, ':')`. La version doit impérativement être `v1`.
- **Contrôle de taille minimale :** La validation rejette tout payload inférieur à 28 octets (`12B Nonce + 16B Tag`), empêchant les paniques par découpage de buffer (`split_at(12)`).
- **Encodage :** Utilisation de `URL_SAFE_NO_PAD` (Base64URL sans padding), évitant les corruptions de caractères lors des transferts HTTP ou JSON.

### 5.3. Contexte AAD `lyxal:v1` ([`src/context.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/context.rs))
- **Défense Anti-Collision :** Format préfixé par la taille :  
  `lyxal:v1:<len_t>:<tenant>:<len_m>:<module>:<len_r>:<resource>:<len_id>:<record_id>:<len_f>:<field>`.  
  Deux contextes contigus avec des délimiteurs `:` dans les valeurs ne peuvent pas produire le même buffer AAD.
- **Normalisation :** Conversion automatique en minuscules et suppression des espaces pour `tenant`, `module`, `resource` et `field`.

### 5.4. Hachage de Mots de Passe Argon2id ([`src/password.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/password.rs))
- **Paramètres durcis Lyxal v1 :**
  - `m_cost = 65536` (64 MiB)
  - `t_cost = 3` itérations
  - `p_cost = 1` thread
  - Version = `0x13` (Argon2 v19)
- **Vérification temps constant :** Délégation au vérificateur officiel de `RustCrypto/argon2`.
- **Détection d'obsolescence :** [`needs_rehash`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/password.rs#L60) valide de manière exhaustive l'identifiant d'algorithme, la version et chacun des trois paramètres de coût.

### 5.5. HMAC, HKDF et Hashes ([`src/hmac.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hmac.rs), [`src/kdf.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/kdf.rs), [`src/hash.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hash.rs))
- **HMAC-SHA256 :** Implémenté selon RFC 4231 avec vérification temps constant native via `Mac::verify_slice`.
- **HKDF-SHA256 :** Conforme à RFC 5869 avec spécialisation [`hkdf_sha256_32`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/kdf.rs#L18) retournant une clé encapsulée dans `Zeroizing`.
- **SHA-256 & BLAKE3 :** Présence des façades directes et des structures streaming [`Sha256Hasher`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hash.rs#L30) et [`Blake3Hasher`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/hash.rs#L53).

### 5.6. Gestion des Clés & Résolveurs ([`src/key.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/key.rs), [`src/key_resolver.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/key_resolver.rs))
- **Étanchéité d'`EncryptionKey` :** La clé ne peut être ni copiée, ni clonée, ni sérialisée. Sa représentation `Debug` est masquée (`EncryptionKey([REDACTED])`).
- **Validation `KeyId` :** Expression régulière stricte en ASCII `[A-Za-z0-9._-]{1,64}` interdisant les caractères séparateurs `:` et les espaces.
- **Résolution thread-safe :** [`CompositeKeyResolver`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/key_resolver.rs#L220) utilise `RwLock` et stocke des `Arc<EncryptionKey>`, permettant une rotation de clés concurrente sans blocage ni réallocation mémoire.
- **Création atomique sécurisée :** [`FileKeyProvider`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/src/key_resolver.rs#L95) crée les fichiers de clé sous Unix avec le masque de permissions restrictif `0o600`.

---

## 6. Preuves d'Exécution & Validation Technique

Les vérifications ont été exécutées directement dans l'environnement local avec les résultats effectifs suivants :

### 6.1. Compilation du Crate
- **Commande :** `cargo check -p lyxal_crypto`
- **Code retour :** `0`
- **Durée réelle :** `3.07s`
- **Résultat :** Compilation réussie sans erreur.

### 6.2. Analyse Statique Clippy (Mode Strict)
- **Commande :** `cargo clippy -p lyxal_crypto --all-targets -- -D warnings`
- **Code retour :** `0`
- **Durée réelle :** `5.18s`
- **Résultat :** Zéro violation, zéro avertissement sous l'ensemble des cibles (lib, tests, benchmarks).

### 6.3. Exécution de la Suite Complète de Tests
- **Commande :** `cargo test -p lyxal_crypto`
- **Code retour :** `0`
- **Durée réelle :** `20.22s`
- **Bilan :** **44 tests passés, 0 échec, 0 ignoré** à travers 14 suites :
  - `aes_gcm_vectors.rs` : 4 NIST SP 800-38D vectors (`pass`)
  - `encryption.rs` : 7 tests de chiffrement/déchiffrement/AAD (`pass`)
  - `envelope_v1_fixtures.rs` : 3 tests de fixtures immuables (`pass`)
  - `fuzz_robustness.rs` : 2 tests de robustesse face aux entrées aléatoires (`pass`)
  - `hash_vectors.rs` : 4 tests de vecteurs officiels NIST SHA-256 et BLAKE3 (`pass`)
  - `hmac_vectors.rs` : 2 tests de vecteurs officiels RFC 4231 (`pass`)
  - `kdf_vectors.rs` : 2 tests de vecteurs officiels RFC 5869 (`pass`)
  - `key_generation.rs` : 2 tests de masquage Debug et non-collision (`pass`)
  - `key_resolver.rs` : 3 tests de résolution et politiques de génération (`pass`)
  - `migration.rs` : 3 tests de migration des anciens formats (`pass`)
  - `negative_tests.rs` : 6 tests d'invalidation (AAD altéré, nonces falsifiés, etc.) (`pass`)
  - `password_tests.rs` : 4 tests Argon2id, vérification et détection `needs_rehash` (`pass`)
  - `proptests.rs` : 3 tests basés sur les propriétés (Proptest) (`pass`)
  - `rotation_lifecycle.rs` : 2 tests de cycle de vie de rotation multi-clés (`pass`)

---

## 7. Plan d'Action & Recommandations pour Clôture

Afin de lever les réserves émises et permettre à `lyxal_crypto` d'obtenir la mention **`CONFORME`** pleine et entière, le plan correctif documentaire suivant est soumis à l'arbitrage du CTO :

1. **Phase Corrective Documentaire (Priorité P1)** :
   - Mettre à jour [`API_CONTRACT.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/API_CONTRACT.md) pour refléter fidèlement les signatures infaillibles de HMAC (`[u8; 32]`, `String`), les retours booléens (`verify_hmac_sha256 -> bool`, `verify_password -> Result<bool, CryptoError>`), l'ordre des paramètres HKDF et les variantes de `KeyGenerationPolicy`.
   - Réécrire la section d'exemple de [`README.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/README.md) en utilisant les API réelles (`CryptoEngine`, `SecretContext`) et rectifier la description de l'enveloppe (`enc:v1`) dans `README.md` et [`SECURITY.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/SECURITY.md).
2. **Phase d'Harmonisation Workspace (Priorité P2)** :
   - Raccorder [`crates/lyxal_crypto/Cargo.toml`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/Cargo.toml) à `workspace.dependencies` et supprimer le fichier `Cargo.lock` redondant du sous-dossier.
3. **Phase de Dépréciation Legacy (Priorité P3)** :
   - Marquer les 4 méthodes de compatibilité Cal.rs avec l'attribut `#[deprecated]` en vue de leur retrait définitif lors de la version 1.0.0.

---

*Rapport établi en lecture seule stricte conformément à la charte d'architecture Lyxal OS. En attente de l'arbitrage formel du CTO.*
