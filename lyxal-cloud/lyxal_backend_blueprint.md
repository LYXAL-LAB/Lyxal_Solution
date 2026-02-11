# Rapport Technique : Modèle de Données Backend (Surrealist pour Lyxal)

Ce document détaille l'intégralité des structures de données (tables et colonnes) déduites de l'analyse exhaustive de l'interface Surrealist. Ce modèle est conçu pour être reproduit fidèlement dans le projet **Lyxal**.

---

## 1. Domaine : Catalogue de la Base de Données (Système)
Ces structures représentent ce que Surrealist gère directement via les commandes `INFO` et `DEFINE`.

| Table | Colonnes Clés | Types & Détails |
| :--- | :--- | :--- |
| **`namespace`** | `name`, `comment` | Gère l'isolation logique. |
| **`database`** | `name`, `comment`, `strict`, `changefeed` | `changefeed` contient `{ expiry: string, store_original: boolean }`. |
| **`table`** | `name`, `drop`, `full`, `permissions`, `kind`, `view` | `kind` est un objet `{ kind: "ANY" \| "NORMAL" \| "RELATION", in: [], out: [] }`. |
| **`field`** | `name`, `kind`, `flex`, `readonly`, `value`, `assert`, `default` | `kind` est le type SurrealQL (ex: `string`, `int`). |
| **`index`** | `name`, `cols`, `index_type` | `index_type` peut être `UNIQUE`, `SEARCH`, `HNSW`. |
| **`event`** | `name`, `when`, `then` | `then` est une liste de scripts SurrealQL. |
| **`function`** | `name`, `args`, `returns`, `block`, `permissions` | `args` est un tableau de tuples `[nom, type]`. |

---

## 2. Domaine : Gestion Cloud & Infrastructure
Ce domaine gère les ressources physiques et les organisations.

### 2.1 Instances (Serveurs Cloud)
D'après `CloudInstance` et les mocks API :
*   `id`, `name`, `host`, `region`, `version`.
*   `compute_units`, `storage_size`.
*   `state` : Enum (`creating`, `ready`, `paused`, `updating`, `deleting`).
*   **Capacités (`capabilities`)** : `allow_scripting`, `allow_graphql`, `allow_guests`, etc.

### 2.2 Organisations, Identité & Sessions
D'après `CloudOrganization`, `CloudProfile`, `CloudSignin` et `auth.tsx` :

*   **Identité Utilisateur** : `id`, `username`, `name`, `default_org`, `enabled_features`.
*   **Consentement et Légalité** : `terms_accepted_at` (Horodatage de l'acceptation des CGU lors du sign-in).
*   **Sessions & Sécurité** :
    *   `session_token` (JWT renvoyé par `/signin`).
    *   `access_token` / `refresh_token` (Gérés via OAuth2/PKCE).
    *   `auth_provider` (ex: "authkit").
*   **Organisation** : `id`, `name`, `state`, `billing_provider`, `member_count`, `resources_locked`.
*   **Accès & Invitations** : 
    *   **Membres** : `user_id`, `role`, `profile_picture`.
    *   **Invitations** : `code`, `email`, `role`, `status`.
    *   **Parrainages (Referrals)** : `referral_code` (capturé via `sessionStorage` lors de l'auth).

---

## 3. Domaine : Business & Facturation
Strictement déduit de `CloudBilling`, `CloudInvoice` et `CloudMeasurement`.

### 3.1 Facturation & Paiement
*   **Détails Facturation** : `LegalName`, `Email`, `AddressLine1`, `City`, `Country`, `TaxIdentificationNumber`.
*   **Factures** : `id`, `date`, `amount`, `status`, `url` (PDF).
*   **Paiement** : `card_brand`, `card_last4`.

### 3.2 Usage & Métriques
*   **Mesures** : `instance_id`, `compute_hours`, `disk_used_bytes`.
*   **Métriques Temps Réel** : `timestamps`, `metrics.values`.

---

## 4. Domaine : Support & Communication
Déduit des structures `IntercomTicket` et `IntercomConversation`.

*   **Tickets** : `id`, `title`, `description`, `state` (open/closed).
*   **Chat Sidekick** : `id`, `author_role` (user/assistant), `sent_at`, `content`.

---

## 5. Intelligence & Outils Avancés

### 5.1 Apprentissage Automatique (ML)
**Table : `ml_model`**
*   `name`, `version`, `hash`
*   `permissions` (booléen ou chaîne WHERE).

### 5.2 Migrations de Schéma
**Table : `migration`**
*   `id`, `origin`, `severity` (`might_break`, `will_break`).
*   `error_details`, `location` (ligne, colonne).

---

## 6. Domaine : État de l'Environnement (Persistence IDE)
Ce que Surrealist sauvegarde pour chaque utilisateur.

| Table | Champs Critiques |
| :--- | :--- |
| **`connection`** | `hostname`, `protocol`, `username`, `last_ns`, `last_db`, `pinned_tables`, `diagram_settings`. |
| **`query_tab`** | `query_string`, `variables_json`, `result_mode`, `format`, `show_variables`. |
| **`saved_query`** | `name`, `query`, `tags`. |
| **`query_history`** | `query`, `timestamp`, `origin`. |
| **`user_preference`** | `theme`, `scale`, `sidebar_mode`, `feature_flags`, `keyboard_bindings`. |

---

> [!IMPORTANT]
> Pour reproduire **Lyxal**, vous devez implémenter des API REST ou RPC qui manipulent ces tables. Le Frontend de Surrealist s'attend exactement à ces noms de champs pour fonctionner.
