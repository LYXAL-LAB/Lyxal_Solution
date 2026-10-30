> **ARCHIVE HISTORIQUE — NON PRIS EN CHARGE.** L’API actuelle rejette enc:v1 ; la spécification active est ENVELOPE_FORMAT_V2.md. Aucune migration automatique.

# 📜 Spécification du Format d'Enveloppe Persistante `enc:v1` & AAD `lyxal:v1`

Ce document formalise la spécification technique immuable du format persistant d'enveloppe chiffrée `enc:v1` et du contexte d'authentification AAD `lyxal:v1` de Lyxal OS.

---

## 1. Format d'Enveloppe Sérialisée `enc:v1`

### 1.1. Syntaxe de la Chaîne Sérialisée

Toute valeur persistée sous format enveloppé `enc:v1` respecte la grammaire suivante :

```text
enc:v1:<key_id>:<base64url_payload>
```

- **Préfixe** : Constante littérale `enc:`.
- **Version** : Constante littérale `v1`.
- **Key ID (`<key_id>`)** : Identifiant textuel de la clé cryptographique (ex: `key-prod-2026-01`, `main`, `k1`).
  - Caractères autorisés : alphanumériques minuscules, majuscules, chiffres, tirets (`-`) et underscores (`_`).
  - Ne doit pas être vide ni contenir le délimiteur `:`.
- **Payload (`<base64url_payload>`)** : Données binaires encodées en Base64 URL-Safe sans padding (`base64::engine::general_purpose::URL_SAFE_NO_PAD`).

### 1.2. Structure Binaire Interne du Payload

Le buffer binaire décodé à partir de `<base64url_payload>` possède la disposition canonique suivante :

```text
┌───────────────────────────┬──────────────────────────────────────────┬───────────────────────────┐
│       NONCE (12B)         │         CIPHERTEXT (N octets)            │         TAG (16B)         │
├───────────────────────────┼──────────────────────────────────────────┼───────────────────────────┤
│ Offset 0..12              │ Offset 12..(12 + N)                      │ Offset (12 + N)..(28 + N) │
└───────────────────────────┴──────────────────────────────────────────┴───────────────────────────┘
```

- **Taille minimale du payload** : `28 octets` (12 octets de Nonce + 0 octet de Ciphertext pour un message vide + 16 octets de Tag d'authentification GCM). Tout payload inférieur à 28 octets est rejeté avec `CryptoError::InvalidPayload`.
- **Algorithme AEAD** : AES-256-GCM (NIST SP 800-38D).
- **Génération du Nonce** : 12 octets (96 bits) générés de manière cryptographiquement imprédictible via le CSPRNG système (`rand_core::OsRng`).

---

## 2. Format du Contexte d'Authentification AAD `lyxal:v1`

Pour lier de façon cryptographique et indissociable une enveloppe chiffrée à son contexte métier (anti-confusion multi-tenant et anti-rejeu inter-enregistrements), des Données Associées Authentifiées (**AAD**) sont obligatoirement injectées lors du chiffrement et vérifiées lors du déchiffrement.

### 2.1. Structure Canonique Préfixée par Longueur

La chaîne AAD binaire `lyxal:v1` est construite de façon déterministe avec préfixe de longueur pour chaque composant afin de garantir l'absence absolue d'ambiguïté ou de collision :

```text
lyxal:v1:<len_tenant>:<tenant>:<len_module>:<module>:<len_resource>:<resource>:<len_record>:<record_id>:<len_field>:<field>
```

### 2.2. Champs Obligatoires et Normalisation

1. `tenant` : Identifiant du tenant (normalisé en minuscules, trimé, non vide).
2. `module` : Nom du module Lyxal (normalisé en minuscules, trimé, non vide, ex: `booking`, `auth`, `scheduler`).
3. `resource` : Table ou ressource cible (normalisé en minuscules, trimé, non vide, ex: `booking_setting`, `account`).
4. `record_id` : Identifiant de l'enregistrement (trimé, non vide, ex: `rec_01h7abc`, `booking_setting:smtp_config`).
5. `field` : Nom du champ chiffré (normalisé en minuscules, trimé, non vide, ex: `smtp_password`, `client_secret`).

### 2.3. Exemple Canonique

Pour :
- `tenant` = `"acme"`
- `module` = `"booking"`
- `resource` = `"setting"`
- `record_id` = `"rec_123"`
- `field` = `"password"`

Le flux AAD injecté dans AES-256-GCM est exactement :
```text
lyxal:v1:4:acme:7:booking:7:setting:7:rec_123:8:password
```

---

## 3. Règle d'Évolution & Rétro-Compatibilité

1. **Stabilité Immuable** : La sémantique de `enc:v1` et `lyxal:v1` est **DÉFINITIVEMENT FIGÉE**.
2. **Évolutions Futures** : Toute modification du schéma d'enveloppe ou de l'AAD (ex: changement d'algorithme vers ChaCha20-Poly1305 ou post-quantique) devra obligatoirement introduire une nouvelle version explicite (`enc:v2`, `lyxal:v2`).
3. **Garantie de Déchiffrement** : Toute enveloppe générée sous `enc:v1` pourra être déchiffrée par les futures versions de Lyxal OS tant que la clé correspondante est présente dans le `KeyResolver`.
