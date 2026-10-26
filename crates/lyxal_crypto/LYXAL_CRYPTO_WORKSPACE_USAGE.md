# 🌐 Inventaire Complet des Dépendances & Usages Cryptographiques du Workspace Lyxal OS

**Date de l'audit** : 02 Septembre 2026  
**Auditeur** : Équipe Architecture & Sécurité Lyxal OS  
**Statut** : Validé CTO — Phase 3 Freeze

---

## 1. Catégorisation de la Cryptographie dans le Workspace

Pour préserver une architecture propre sans sur-couplage artificiel, les dépendances cryptographiques sont rigoureusement réparties en 3 catégories distinctes :

1. **CRYPTO APPLICATIVE (Socle Lyxal)** :
   - Hachage d'intégrité métier, checksums de migrations, node IDs, déduplication d'événements.
   - Hachage et vérification de mots de passe utilisateurs.
   - Chiffrement au repos de credentials et secrets applicatifs (AES-256-GCM enveloppé `enc:v1` avec AAD `lyxal:v1`).
   - Signatures HMAC de webhooks et tokens d'intégration.
   - **Règle** : **DOIT obligatoirement utiliser la façade `lyxal_crypto`.**

2. **CRYPTO PROTOCOLAIRE (Réseau / TLS / Standard IETF)** :
   - Chiffrement en transit TLS / HTTPS / WebSockets (`rustls`, `tokio-rustls`, `tungstenite`, `reqwest`).
   - Protocoles OAuth2 / OIDC tiers (`openidconnect`).
   - TOTP / Authentificateurs RFC 6238 (`totp-rs`).
   - **Règle** : **NE PAS migrer vers `lyxal_crypto`.** Ces bibliothèques gèrent nativement leurs couches cryptographiques internes.

3. **CRYPTO TRANSITIVE (Moteurs tiers & Moteur de données)** :
   - Moteur SurrealDB (`surrealdb-core` : internal crypto, bcrypt, scrypt, etc.).
   - Moteur de base de données embarqué / KV store.
   - **Règle** : **NE PAS toucher aux internals de SurrealDB.**

---

## 2. Inventaire Détaillé par Crate & Composant

| Crate / Module | Fichier / Emplacement | Primitive & Dépendance | Catégorie | Rôle & Justification | Statut / Recommandation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`lyxal_crypto`** | `src/*` | `aes-gcm`, `sha2`, `blake3`, `argon2`, `hmac`, `hkdf`, `rand_core` | **Socle Officiel** | Façade cryptographique centrale officielle de Lyxal OS. | ✅ **FROZEN (STABLE)** |
| **`lyxal_runtime`** | `src/migration/checksum.rs` | `lyxal_crypto::hash::sha256_hex` | **Applicative** | Calcul d'empreinte SHA-256 pour validation des migrations SurrealQL. | ✅ **MIGRÉ vers `lyxal_crypto`** |
| **`lyxal_runtime`** | `src/lock/node_id.rs` | `lyxal_crypto::hash::Sha256Hasher` | **Applicative** | Dérivation de Node ID déterministe via streaming SHA-256. | ✅ **MIGRÉ vers `lyxal_crypto`** |
| **`lyxal_runtime`** | `src/event/id.rs` | `lyxal_crypto::hash::Sha256Hasher` | **Applicative** | Calcul d'Event ID déterministe. | ✅ **MIGRÉ vers `lyxal_crypto`** |
| **`lyxal_booking`** | `engine/src/crypto_helpers.rs` | `lyxal_crypto::CryptoEngine`, `SecretContext` | **Applicative** | Chiffrement au repos des tokens OAuth, mots de passe CalDAV/SMTP, secrets webhooks. | ✅ **CONFORME `enc:v1` & AAD** |
| **`lyxal_booking`** | `engine/src/auth.rs` | `argon2` direct ➔ `lyxal_crypto::password` | **Applicative** | Hachage et vérification de mots de passe comptes utilisateurs. | 🔄 **En cours d'unification** |
| **`lyxal_booking`** | `engine/src/web/meeting.rs` | `hmac` direct ➔ `lyxal_crypto::hmac` | **Applicative** | Signature HMAC-SHA256 pour webhooks sortants de réunions. | 🔄 **En cours d'unification** |
| **`lyxal_booking`** | `engine/src/main.rs`, `oauth.rs` | `reqwest` (`rustls-tls`), `openidconnect` | **Protocolaire** | Transport HTTPS TLS pour synchronisation CalDAV et flux OAuth2 Google. | 🔒 **Maintenu protocolaire (Pas de migration)** |
| **`lyxal_scheduler`** | `crates/lyxal-auth` | `bcrypt`, `jsonwebtoken`, `totp-rs`, `aes-gcm` | **Applicative / Protocolaire** | Module auth standalone scheduler (JWT, TOTP 2FA, API Keys). | 📌 **Candidat Phase d'unification Scheduler** |
| **`lyxal_server`** | Process host / HTTP | `tokio-rustls`, `tungstenite` | **Protocolaire** | Terminaison TLS pour requêtes API et flux temps-réel WebSockets. | 🔒 **Maintenu protocolaire (Pas de migration)** |
| **`surrealdb`** | `surrealdb-core` | `surrealdb` internal crypto engines | **Transitive** | Gestion interne de la base de données SurrealDB. | 🔒 **Intouchable (Vendor Engine)** |

---

## 3. Cartographie du Stockage des Secrets Applicatifs (Secret Storage Policy)

Conformément aux directives de sécurité, tout secret stocké par les modules métiers Lyxal doit être catalogué selon son statut de persistance :

| Module | Ressource / Table | Champ | Type de Secret | Statut de Persistance | Format / AAD Contexte |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `lyxal_booking` | `booking_caldav_source` | `password` | Mot de passe compte CalDAV/CardDAV | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_caldav_source/.../password` |
| `lyxal_booking` | `booking_caldav_source` | `oauth_token` | Token OAuth2 d'accès/rafraîchissement | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_caldav_source/.../oauth_token` |
| `lyxal_booking` | `booking_oauth_token` | `access_token`, `refresh_token` | Jetons OAuth2 d'intégration | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_oauth_token/.../<field>` |
| `lyxal_booking` | `booking_setting` | `client_secret` | Secret client OAuth2 Google / Microsoft | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_setting/.../client_secret` |
| `lyxal_booking` | `booking_setting` | `smtp_password` | Mot de passe SMTP pour envois d'emails | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_setting/.../smtp_password` |
| `lyxal_booking` | `booking_setting` | `captcha_secret` | Clé secrète Turnstile / reCAPTCHA | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_setting/.../captcha_secret` |
| `lyxal_booking` | `booking_setting` | `meeting_webhook_secret`| Clé secrète HMAC des webhooks | **LYXAL ENVELOPE** | `enc:v1` avec AAD `booking/booking_setting/.../meeting_webhook_secret` |
| `lyxal_booking` | `booking_account` | `password_hash` | Hash mot de passe utilisateur | **HASHÉ (NON CHIFFRÉ)** | Format PHC Argon2id `$argon2id$v=19$m=65536,t=3,p=1$...` |

> 🛡️ **Constat de Sécurité** : **AUCUN credential persistant sensible n'est stocké en clair (PLAINTEXT) dans `lyxal_booking`.** Tous les secrets utilisent l'enveloppe `enc:v1` avec AAD multi-tenant strict, ou le hachage irréversible Argon2id pour les mots de passe.
