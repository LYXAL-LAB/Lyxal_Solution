# 🗺️ Roadmap — lyxal_crypto

> Statut : ✅ V1 VALIDÉE
>
> Dernière mise à jour : Juillet 2026

---

# 🎯 Objectif

`lyxal_crypto` est la crate du **Noyau Technique Lyxal OS** responsable de toute la cryptographie symétrique de la plateforme.

Elle fournit une API unique, fortement typée et indépendante des modules métiers pour :

- chiffrement des secrets
- déchiffrement
- rotation des clés
- migration des anciens formats
- gestion des clés maître

Tous les modules Lyxal utilisant des secrets (Booking, Notification, Scheduler, Mail, OAuth, API, etc.) devront exclusivement passer par cette crate.

---

# 🏛️ Architecture

```
                     lyxal_crypto
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
     Booking          Notification         Scheduler
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                  AES-256-GCM Engine
                            │
             KeyResolver / CryptoEngine
```

---

# ✅ V1 — Moteur Cryptographique (VALIDÉ)

## Chiffrement

- ✅ AES-256-GCM
- ✅ Nonce aléatoire 96 bits
- ✅ Tag d'authentification
- ✅ Support AAD

---

## SecretContext

- ✅ contexte encapsulé
- ✅ validation stricte
- ✅ tenant
- ✅ module
- ✅ resource
- ✅ record_id
- ✅ field

AAD canonique :

```
lyxal:v1:<len>:...
```

garantissant l'absence de collisions.

---

## Gestion des clés

### EncryptionKey

- ✅ Zeroizing
- ✅ non clonable
- ✅ Debug masqué
- ✅ pas de Serialize

### KeyId

- ✅ type fort
- ✅ validation ASCII

```
[A-Za-z0-9._-]{1,64}
```

---

## Providers

### EnvironmentKeyProvider

- ✅ Base64 uniquement
- ✅ clé en mémoire protégée

### FileKeyProvider

- ✅ création atomique
- ✅ permissions Unix 0600
- ✅ mode DEV
- ✅ mode Production Strict
- ✅ gestion des courses concurrentes

### CompositeKeyResolver

- ✅ clé active
- ✅ clés historiques
- ✅ rotation

---

## Format d'enveloppe

```
enc:v1:<key_id>:<payload>
```

---

## Migration Legacy

Compatibilité avec Cal.rs :

```
hex(plaintext UTF-8)
```

Migration :

```
legacy
      ↓
decode
      ↓
AES-256-GCM
      ↓
enc:v1:...
```

---

## Rotation

Support complet :

```
ancienne clé
      ↓
lecture
      ↓
déchiffrement
      ↓
rechiffrement
      ↓
nouvelle clé
```

---

## Sécurité

- ✅ Zeroizing
- ✅ AAD
- ✅ séparation clé / données
- ✅ clé jamais stockée dans SurrealDB
- ✅ validation KeyId
- ✅ création atomique des fichiers
- ✅ protections mémoire

---

## Tests

Couverture actuelle :

- ✅ chiffrement
- ✅ déchiffrement
- ✅ AAD
- ✅ nonce unique
- ✅ payload altéré
- ✅ version invalide
- ✅ validation KeyId
- ✅ provider fichier
- ✅ provider environnement
- ✅ rotation
- ✅ migration Cal.rs

---

# 🚧 V2 — Intégration Infrastructure

Objectif :

Faire de `lyxal_crypto` le moteur cryptographique partagé de tout Lyxal OS.

## Intégration

- ☐ lyxal_booking
- ☐ lyxal_notification
- ☐ lyxal_scheduler
- ☐ lyxal_auth
- ☐ lyxal_storage
- ☐ lyxal_mail

---

## Support OAuth

Chiffrement :

- refresh_token
- access_token
- client_secret

---

## Support SMTP

Chiffrement :

- password
- oauth_secret

---

## Support CalDAV

Chiffrement :

- mot de passe
- tokens

---

## Support API

Chiffrement :

- API Keys
- Secrets

---

## Helpers

Ajout d'API ergonomiques :

```
encrypt_string()

decrypt_string()

encrypt_json()

decrypt_json()
```

---

# 🚀 V3 — Enterprise

## Rotation automatique

- ☐ rotation programmée
- ☐ recryptage automatique

---

## Multi Key

Support :

```
main
backup
tenant
archive
```

---

## Multi Tenant

Possibilité d'utiliser une clé différente :

```
Tenant A

Tenant B

Tenant C
```

---

## KMS

Support optionnel :

- Hashicorp Vault

- AWS KMS

- Azure Key Vault

- Google Cloud KMS

---

## HSM

Support futur :

- PKCS#11

- YubiHSM

- Nitro Enclaves

---

## Audit

Journalisation :

- création de clé

- rotation

- suppression

- migration

---

## Politique

Expiration automatique des clés.

---

# 🔮 V4 — Écosystème Lyxal

Le moteur devient le fournisseur unique de secrets de Lyxal OS.

Tous les modules consommeront exclusivement :

```
CryptoEngine
```

sans implémenter leur propre logique cryptographique.

---

# 🎯 Statut

| Élément | Statut |
|----------|--------|
| Architecture | ✅ |
| API publique | ✅ |
| AES-256-GCM | ✅ |
| SecretContext | ✅ |
| AAD | ✅ |
| Rotation | ✅ |
| Migration Legacy | ✅ |
| Tests | ✅ |
| Documentation | ✅ |

---

# Validation CTO

**Version : V1**

**Statut : VALIDÉ**

Cette crate constitue désormais le **moteur cryptographique officiel du Noyau Technique Lyxal OS**.

---

## 🎯 Migration lyxal_booking — Terminée

- [x] OAuth / CalDAV
- [x] SMTP
- [x] Captcha
- [x] Meeting webhook
- [x] Workers
- [x] Handlers administratifs
- [x] Suppression de `engine/src/crypto.rs`
- [x] Suppression de `mod crypto;`
- [x] Audit zéro référence legacy
- [ ] Suppression de `legacy_secret_key` après migration complète des données historiques