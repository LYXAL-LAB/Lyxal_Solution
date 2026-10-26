# 🛡️ Politique de Sécurité Cryptographique (`SECURITY.md`) — Lyxal OS

Ce document formalise les règles strictes d'ingénierie de sécurité et les engagements cryptographiques du crate `lyxal_crypto`.

---

## 1. Modèle de Menace & Objectifs de Sécurité

`lyxal_crypto` a été conçu pour se prémunir contre les vecteurs d'attaques suivants :

1. **Compromission par Fuite Mémoire (Memory Scraping / Dumps)** :
   - Les clés secrètes (`EncryptionKey`), textes clairs (`Plaintext`) et clés dérivées (`Zeroizing<[u8; 32]>`) implémentent le trait `Zeroize` / `ZeroizeOnDrop` de la fondation RustCrypto.
   - Dès la libération de la mémoire (`drop`), les octets sont écrasés de façon déterministe avec des zéros.
   - Les traits `Debug` et `Display` de tous les conteneurs de secrets sont masqués (`[REDACTED]`).
   - L'interdiction du trait `Clone` sur `EncryptionKey` limite drastiquement le nombre de copies en mémoire.

2. **Attaques par Canal Auxiliaire (Timing Attacks)** :
   - Toutes les vérifications d'intégrité et de signature (HMAC-SHA256, vérification de mot de passe Argon2id) sont exécutées en **temps constant** (`Constant-Time`) en utilisant l'API `Mac::verify_slice` / `subtle` de RustCrypto.
   - Aucune comparaison d'octets naïve (`==` ou `memcmp`) n'est autorisée sur des données sensibles ou des condensats d'authentification.

3. **Confusion Multi-Tenant & Rejeu Inter-Domaine** :
   - Tout chiffrement AES-256-GCM intègre obligatoirement un contexte canonique de Données Associées Authentifiées (**AAD** - *Additional Authenticated Data*).
   - L'AAD lie de façon cryptographique et indissociable le chiffrement au `tenant_id`, au `purpose` et aux métadonnées contextuelles. Un ciphertext déplacé vers un autre tenant ou un autre usage métier échouera systématiquement lors du déchiffrement (`DecryptionFailed`).

4. **Attaques par Réutilisation de Nonce (Nonce Reuse Attacks)** :
   - Chaque opération de chiffrement génère un nonce aléatoire frais et unique de 96 bits (12 octets) issu directement du CSPRNG noyau (`rand_core::OsRng`).

---

## 2. Politiques et Paramètres des Primitives

### 2.1. Chiffrement Authentifié (AEAD)
- **Algorithme** : AES-256-GCM (NIST SP 800-38D).
- **Taille de Clé** : 256 bits (32 octets).
- **Nonce** : 96 bits (12 octets) cryptographiquement aléatoire via `OsRng`.
- **Tag d'Authentification** : 128 bits (16 octets).
- **Format d'Enveloppe** : `lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`.

### 2.2. Hachage de Mots de Passe
- **Algorithme** : Argon2id (RFC 9106, version 19 `0x13`).
- **Politique Lyxal v1** :
  - Mémoire (`m_cost`) : `65536 KiB` (64 MiB).
  - Itérations (`t_cost`) : `3`.
  - Parallélisme (`p_cost`) : `1` thread.
  - Salt : `16 octets` (128 bits) aléatoire via `OsRng`.
  - Format : PHC string (`$argon2id$v=19$m=65536,t=3,p=1$...`).
- **Évolution de la Politique** : Utilisation de `needs_rehash()` pour détecter et migrer à la volée tout hash antérieur ou non conforme.

### 2.3. Hachage & Condensats
- **SHA-256** : FIPS 180-4, standard universel pour identifiants, lock tokens et migrations.
- **BLAKE3** : Spécification officielle BLAKE3 pour hashing haute performance et structures d'arbres.

### 2.4. MAC & KDF
- **HMAC-SHA256** : RFC 2104 / RFC 4231 avec vérification native en temps constant (`verify_slice`).
- **HKDF-SHA256** : RFC 5869 avec support de dérivation 32 octets enveloppée dans `Zeroizing`.

---

## 3. Gestion des Clés & Découpage des Responsabilités

- **Rôle de `lyxal_crypto`** : Assurer la façade d'exécution, la validation, le parsing, le chiffrement, le déchiffrement, la ré-encryption et le zeroize.
- **Rôle du Runtime & Hôte** : Stockage persistant sécurisé des Master Keys, intégration avec les coffres-forts d'infrastructure (AWS KMS, HashiCorp Vault, Azure Key Vault, HSM).
- **Rotation de Clés** : Prise en charge native de la cohabitation multi-clés (`KeyResolver`) et ré-encryption transparente sans rupture de service.

---

## 4. Signalement des Vulnérabilités

Tout comportement suspect ou vulnérabilité de sécurité doit être rapporté directement à l'équipe Sécurité & Architecture Lyxal OS.
