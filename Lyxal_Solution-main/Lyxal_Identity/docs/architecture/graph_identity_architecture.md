# Architecture Décentralisée de l'Identité (Graph)

## Philosophie : Zero-Knowledge Identity

L'architecture de **Lyxal Identity** repose sur un principe fondamental :
> **Une identité ne doit pas pouvoir être reconstituée à partir d'une seule table.**

Contrairement aux systèmes classiques (Logto, Auth0, Keycloak) qui centralisent toutes les données dans une table `users`, nous utilisons une architecture en **graphe décorrélé** où l'information est atomisée et liée par des relations de graphe.

### Objectifs

1. **Confidentialité Maximale** : Si un attaquant accède à une table, il n'obtient qu'un fragment inutilisable.
2. **Souveraineté des Données** : Chaque utilisateur possède son propre namespace privé (Vault).
3. **Flexibilité** : Ajout facile de nouveaux identifiants (téléphone, SSO) sans toucher aux tables existantes.
4. **Traçabilité Fine** : Métadonnées sur les relations (vérification, date de création).

---

## Structure : 5 Tables (3 Nœuds + 2 Relations)

### 1️⃣ Nœud : `identity` (L'Ancre Abstraite)

**Fichier** : `database/schemas/identity.surql`

**Rôle** : Représente l'existence d'une identité, sans aucune donnée personnelle.

| Champ | Type | Description |
|---|---|---|
| `id` | record | Identifiant unique (ex: `identity:01J8...`) |
| `status` | record<identity_status> | Statut (créé, actif, suspendu) |
| `created_at` | datetime | Date de création |
| `updated_at` | datetime | Dernière modification |

**Permissions** : `SELECT NONE` (Pas de lecture publique).

**Exemple** :
```sql
identity:01J8ABCDEF123456
{
  status: identity_status:active,
  created_at: "2025-11-21T14:00:00Z",
  updated_at: "2025-11-21T14:00:00Z"
}
```

---

### 2️⃣ Nœud : `email_hash` (Identifiant de Connexion)

**Fichier** : `database/schemas/email_hash.surql`

**Rôle** : Stocke le hash de l'email pour garantir l'unicité et permettre la recherche sans exposer l'email original.

| Champ | Type | Description |
|---|---|---|
| `id` | record | ID auto-généré |
| `hash` | string | `SHA256(email + sel_système)` |
| `created_at` | datetime | Date de création |

**Index** : `idx_hash UNIQUE` → Empêche les doublons.

**Permissions** : `SELECT NONE` (Seules les fonctions système peuvent lire).

**Exemple** :
```sql
email_hash:xyz123
{
  hash: "a3f8b9c2d1e4...",
  created_at: "2025-11-21T14:00:00Z"
}
```

---

### 3️⃣ Nœud : `vault_location` (Localisation du Coffre-Fort)

**Fichier** : `database/schemas/vault_location.surql`

**Rôle** : Indique où sont physiquement stockées les données privées de l'utilisateur (Namespace SurrealDB).

| Champ | Type | Description |
|---|---|---|
| `id` | record | ID auto-généré |
| `namespace_name` | string | Nom du namespace (ex: `NS_IDENTITY_01J8...`) |
| `region` | string | Région (ex: `eu-west-1`) pour souveraineté |
| `created_at` | datetime | Date de création |

**Index** : `idx_namespace UNIQUE`.

**Permissions** : `SELECT NONE`.

**Exemple** :
```sql
vault_location:abc456
{
  namespace_name: "NS_IDENTITY_01J8ABCDEF",
  region: "eu-west-1",
  created_at: "2025-11-21T14:00:00Z"
}
```

---

### 4️⃣ Relation : `identifies` (Email → Identité)

**Fichier** : `database/schemas/identifies.surql`

**Rôle** : Lie un hash d'email à une identité. Permet le login.

**Structure** : `email_hash -> identifies -> identity`

| Champ | Type | Description |
|---|---|---|
| `in` | record<email_hash> | Depuis le hash |
| `out` | record<identity> | Vers l'identité |
| `verified` | bool | Email vérifié ? |
| `verified_at` | datetime | Date de vérification |
| `created_at` | datetime | Création du lien |

**Permissions** : `SELECT NONE`.

**Exemple** :
```sql
email_hash:xyz123 -> identifies -> identity:01J8ABCDEF
{
  verified: true,
  verified_at: "2025-11-21T14:05:00Z",
  created_at: "2025-11-21T14:00:00Z"
}
```

**Requête Login** :
```sql
-- L'utilisateur tape son email
LET $hash = crypto::sha256('user@example.com' + $SEL_SYSTEME);

-- On trouve l'identité
SELECT ->identifies->identity 
FROM email_hash 
WHERE hash = $hash;
```

---

### 5️⃣ Relation : `stores_data_in` (Identité → Vault)

**Fichier** : `database/schemas/stores_data_in.surql`

**Rôle** : Lie une identité à son vault (namespace privé).

**Structure** : `identity -> stores_data_in -> vault_location`

| Champ | Type | Description |
|---|---|---|
| `in` | record<identity> | L'identité |
| `out` | record<vault_location> | Le vault |
| `is_primary` | bool | Vault principal (multi-vault futur) |
| `created_at` | datetime | Création du lien |

**Permissions** : `SELECT NONE`.

**Exemple** :
```sql
identity:01J8ABCDEF -> stores_data_in -> vault_location:abc456
{
  is_primary: true,
  created_at: "2025-11-21T14:00:00Z"
}
```

**Requête pour trouver le Vault** :
```sql
SELECT ->stores_data_in->vault_location.namespace_name 
FROM identity:01J8ABCDEF;
```

---

## Flux Complet : Création d'un Compte

```sql
-- 1. Créer l'ancre d'identité
CREATE identity SET status = identity_status:created;
-- Retourne: identity:01J8ABCDEF

-- 2. Créer le vault
CREATE vault_location SET 
  namespace_name = 'NS_IDENTITY_01J8ABCDEF',
  region = 'eu-west-1';
-- Retourne: vault_location:abc456

-- 3. Créer le hash d'email
LET $hash = crypto::sha256('user@example.com' + $SEL);
CREATE email_hash SET hash = $hash;
-- Retourne: email_hash:xyz123

-- 4. Lier Email → Identité
RELATE email_hash:xyz123->identifies->identity:01J8ABCDEF 
SET verified = false;

-- 5. Lier Identité → Vault
RELATE identity:01J8ABCDEF->stores_data_in->vault_location:abc456 
SET is_primary = true;
```

---

## Flux Complet : Login

```sql
-- 1. L'utilisateur entre son email
LET $email = 'user@example.com';
LET $hash = crypto::sha256($email + $SEL_SYSTEME);

-- 2. Trouver l'identité
LET $identity = (
  SELECT VALUE ->identifies->identity.id 
  FROM email_hash 
  WHERE hash = $hash
)[0];

-- 3. Trouver le vault
LET $vault = (
  SELECT VALUE ->stores_data_in->vault_location.namespace_name 
  FROM $identity
)[0];

-- 4. Se connecter au namespace et vérifier le mot de passe
-- (Logique dans le vault, non visible ici)
```

---

## Diagramme de Relations

```mermaid
graph LR
    A[email_hash] -->|identifies| B[identity]
    B -->|stores_data_in| C[vault_location]
    
    style A fill:#ff9999
    style B fill:#99ccff
    style C fill:#99ff99
```

---

## Avantages vs Architecture Classique

| Critère | Classique (Logto) | Lyxal Graph |
|---|---|---|
| **Centralisation** | Une table `users` | 5 tables décorrélées |
| **Exposition** | Email en clair dans la table | Hash uniquement |
| **Requête directe** | `SELECT * FROM users WHERE email=?` | Traversée de graphe |
| **Flexibilité** | Ajout de colonnes | Ajout de nœuds/relations |
| **Sécurité** | Vol de table = Brèche totale | Vol d'une table = Fragment inutile |

---

## Prochaines Étapes

1. [ ] Définir le contenu du **Vault** (tables dans le namespace privé).
2. [ ] Créer les fonctions système (`fn::login`, `fn::create_identity`).
3. [ ] Ajouter le support du téléphone (nœud `phone_hash` + relation `identifies`).
4. [ ] Implémenter la vérification d'email (événement sur la relation `identifies`).
