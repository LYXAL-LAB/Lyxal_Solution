# Analyse DB : Migration PostgreSQL/MariaDB → SurrealQL

> **Date** : 2026-04-26
> **Objectif** : Comprendre l'écart entre le schéma SQL actuel et le schéma SurrealQL en cours, pour basculer lyxal_captcha sur le Lyxal Core (SurrealDB).

---

## 1. État actuel : Deux mondes séparés

### Schéma SQL original (PostgreSQL / MariaDB)

Le schéma SQL est réparti dans les migrations SQLx. Voici les **10 tables** utilisées :

| Table PostgreSQL | Rôle | Clé primaire |
|:---|:---|:---|
| `mcaptcha_users` | Utilisateurs (name, email, password, secret) | `ID SERIAL` |
| `mcaptcha_config` | Configuration captcha (key, duration, name) | `config_id SERIAL` |
| `mcaptcha_levels` | Niveaux de difficulté (difficulty_factor, visitor_threshold) | `level_id SERIAL` |
| `mcaptcha_notifications` | Notifications inter-utilisateurs | `id SERIAL` |
| `mcaptcha_pow_fetched_stats` | Stats : config récupérées | FK config_id |
| `mcaptcha_pow_solved_stats` | Stats : PoW résolus | FK config_id |
| `mcaptcha_pow_confirmed_stats` | Stats : tokens confirmés | FK config_id |
| `mcaptcha_sitekey_user_provided_avg_traffic` | Patterns de trafic (avg, peak, broke) | FK config_id |
| `mcaptcha_pow_analytics` | Analytics PoW détaillés (time, difficulty, worker_type) | `ID SERIAL` |
| `mcaptcha_psuedo_campaign_id` | Alias pseudo pour les campagnes analytics | `id SERIAL` |
| `mcaptcha_track_nonce` | Suivi des nonces max par niveau | FK level_id |

### Relations SQL (clés étrangères)

```
mcaptcha_users (1) ──── (N) mcaptcha_config
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    mcaptcha_levels    mcaptcha_pow_*_stats   mcaptcha_sitekey_*_traffic
          │
    mcaptcha_track_nonce
```

---

## 2. Ton schéma SurrealQL (en cours)

Tu as créé **7 fichiers** dans `database/` :

### ✅ Ce qui est fait

| Fichier | Table SurrealQL | Correspondance SQL | État |
|:---|:---|:---|:---|
| `iam/users.surql` | `user` | `mcaptcha_users` | ✅ Complet (9 lignes) |
| `iam/notifications.surql` | `notification` | `mcaptcha_notifications` | ✅ Complet, amélioré (record links) |
| `captcha/captcha.surql` | `captcha` | `mcaptcha_config` | ✅ Complet, enrichi (levels inline, Privacy Pass) |
| `captcha/levels.surql` | `level` | `mcaptcha_levels` | ⚠️ Basique (4 lignes, doublon avec levels inline dans captcha.surql) |
| `analytics/stats.surql` | `pow_stat` | `mcaptcha_pow_*_stats` (×3) | ✅ Fusionné (3 tables → 1 avec field `type`) |
| `analytics/traffic.surql` | `traffic_estimate` | `mcaptcha_sitekey_user_provided_avg_traffic` | ⚠️ Incomplet (manque `broke_my_site_traffic`) |
| `security/nonces.surql` | `nonce` | `mcaptcha_track_nonce` | ⚠️ Redesigné (valeur string au lieu d'int, expiration) |

### ❌ Ce qui manque

| Table SQL | SurrealQL | Statut |
|:---|:---|:---|
| `mcaptcha_pow_analytics` | Aucune | 🔴 Manquante |
| `mcaptcha_psuedo_campaign_id` | Aucune | 🔴 Manquante |

---

## 3. Comparaison détaillée table par table

### 3.1 Users

```diff
-- SQL (PostgreSQL) : mcaptcha_users
  ID SERIAL PRIMARY KEY
  name VARCHAR(100) NOT NULL UNIQUE
  email VARCHAR(100)                    -- nullable
  password TEXT NOT NULL
  secret VARCHAR(50) NOT NULL UNIQUE

-- SurrealQL : user
+ DEFINE TABLE user SCHEMAFULL;
+ DEFINE FIELD name TYPE string;
+ DEFINE FIELD email TYPE string ASSERT is::email($value);   -- ⚠️ Non nullable (SQL l'est)
+ DEFINE FIELD email_verified TYPE bool DEFAULT false;        -- ★ AJOUT Lyxal
+ DEFINE FIELD secret TYPE string;
+ DEFINE FIELD password TYPE string;
+ DEFINE INDEX user_name COLUMNS name UNIQUE;
+ DEFINE INDEX user_email COLUMNS email UNIQUE;
+ DEFINE INDEX user_secret COLUMNS secret UNIQUE;
```

**Issues** :
- `email` devrait être `option<string>` (nullable dans SQL)
- `email_verified` est un bon ajout Lyxal

### 3.2 Captcha config

```diff
-- SQL : mcaptcha_config
  config_id SERIAL PRIMARY KEY
  user_id INTEGER FK → mcaptcha_users(ID) ON DELETE CASCADE
  key VARCHAR(100) NOT NULL UNIQUE
  duration INTEGER NOT NULL DEFAULT 30
  name VARCHAR(100) NOT NULL

-- SurrealQL : captcha (enrichi)
+ DEFINE TABLE captcha SCHEMAFULL;
+ DEFINE FIELD lyxal_identity TYPE record(lyxal_identity)     -- ★ Remplace user_id
+ DEFINE FIELD config.sitekey TYPE string                      -- = key
+ DEFINE FIELD config.name TYPE string                         -- = name
+ DEFINE FIELD config.duration TYPE numbers DEFAULT 30         -- = duration (⚠️ TYPE numbers ≠ int)
+ DEFINE FIELD status.is_enabled TYPE bool DEFAULT false       -- ★ AJOUT
+ DEFINE FIELD level TYPE array<object> DEFAULT []             -- ★ Levels INLINE (pas de table séparée)
+ DEFINE FIELD timestamp.created_at/updated_at TYPE datetime   -- ★ AJOUT
+ -- Privacy Pass tables ajoutées en fin de fichier
```

**Choix d'architecture** :
- Les levels sont **inline** dans le document captcha (array d'objets) → plus simple, plus performant en lecture
- Mais tu as aussi `captcha/levels.surql` (table séparée `level`) → **doublon à résoudre**
- `lyxal_identity` remplace `user_id` → logique car le captcha est lié à une app Lyxal, pas un simple user
- `TYPE numbers` devrait être `TYPE int` (SurrealDB utilise `int` pas `numbers`)

### 3.3 Stats (3 tables → 1 avec discriminant)

```diff
-- SQL : 3 tables identiques
  mcaptcha_pow_fetched_stats (config_id FK, time timestamptz)
  mcaptcha_pow_solved_stats  (config_id FK, time timestamptz)
  mcaptcha_pow_confirmed_stats (config_id FK, time timestamptz)

-- SurrealQL : 1 table avec ASSERT
+ DEFINE TABLE pow_stat SCHEMAFULL;
+ DEFINE FIELD parent_config TYPE record(config);    -- ⚠️ Devrait être record(captcha)
+ DEFINE FIELD type TYPE string ASSERT $value IN ['fetched', 'solved', 'confirmed'];
+ DEFINE FIELD timestamp TYPE datetime DEFAULT time::now();
```

**Bon choix** — fusionner 3 tables identiques en 1 avec discriminant. Mais `record(config)` devrait être `record(captcha)`.

### 3.4 Traffic Pattern

```diff
-- SQL : mcaptcha_sitekey_user_provided_avg_traffic
  config_id INTEGER PK FK → mcaptcha_config
  avg_traffic INTEGER NOT NULL
  peak_sustainable_traffic INTEGER NOT NULL
  broke_my_site_traffic INTEGER           -- nullable

-- SurrealQL : traffic_estimate
+ DEFINE TABLE traffic_estimate SCHEMAFULL;
+ DEFINE FIELD parent_config TYPE record(config);    -- ⚠️ record(captcha)
+ DEFINE FIELD avg_traffic TYPE int;
+ DEFINE FIELD peak_traffic TYPE int;
- MANQUE : broke_my_site_traffic
```

**Issue** : `broke_my_site_traffic` est **manquant** — c'est utilisé par le trait `MCDatabase` et le mode "easy captcha".

### 3.5 Notifications

```diff
-- SQL : mcaptcha_notifications
  id SERIAL PK
  tx INTEGER FK → mcaptcha_users(ID)   -- sender
  rx INTEGER FK → mcaptcha_users(ID)   -- receiver
  heading VARCHAR(100) NOT NULL
  message VARCHAR(250) NOT NULL
  read BOOLEAN DEFAULT NULL
  received TIMESTAMPTZ DEFAULT now()

-- SurrealQL : notification (amélioré)
+ DEFINE TABLE notification SCHEMAFULL;
+ DEFINE FIELD sender TYPE record(user);     -- ★ record link (mieux que FK integer)
+ DEFINE FIELD receiver TYPE record(user);   -- ★ record link
+ DEFINE FIELD heading TYPE string;
+ DEFINE FIELD message TYPE string;
+ DEFINE FIELD read TYPE bool DEFAULT false;  -- ★ bool au lieu de nullable
+ DEFINE FIELD created_at TYPE datetime DEFAULT time::now();
```

**Bon travail** — les record links sont la bonne approche SurrealDB.

### 3.6 Analytics (MANQUANTE)

```diff
-- SQL : mcaptcha_pow_analytics
  ID SERIAL PK
  config_id FK → mcaptcha_config
  time INTEGER NOT NULL           -- durée de calcul PoW (ms)
  difficulty_factor INTEGER NOT NULL
  worker_type VARCHAR(100) NOT NULL

-- SurrealQL : AUCUNE TABLE CRÉÉE
```

**Impact** : Les méthodes `analysis_save`, `analytics_fetch`, `stats_get_num_logs_under_time`, `stats_get_entry_at_location_for_time_limit_asc` du trait `MCDatabase` ne pourront pas fonctionner.

### 3.7 Pseudo Campaign ID (MANQUANTE)

```diff
-- SQL : mcaptcha_psuedo_campaign_id
  id SERIAL PK
  config_id FK → mcaptcha_config
  psuedo_id VARCHAR(100) NOT NULL UNIQUE

-- SurrealQL : AUCUNE TABLE CRÉÉE
```

**Impact** : Les méthodes `analytics_create_psuedo_id_if_not_exists`, `analytics_get_psuedo_id_from_capmaign_id`, `analytics_get_capmaign_id_from_psuedo_id`, `analytics_get_all_psuedo_ids` ne pourront pas fonctionner.

### 3.8 Nonces (redesigné)

```diff
-- SQL : mcaptcha_track_nonce
  ID SERIAL PK
  nonce INTEGER NOT NULL DEFAULT 0
  level_id FK → mcaptcha_levels

-- SurrealQL : nonce (redesigné)
+ DEFINE TABLE nonce SCHEMAFULL;
+ DEFINE FIELD value TYPE string;           -- ⚠️ String au lieu d'int
+ DEFINE FIELD expires_at TYPE datetime;    -- ★ AJOUT (expiration)
+ DEFINE INDEX nonce_value COLUMNS value UNIQUE;
```

**Attention** — Le schéma SurrealQL a un **sens différent** du SQL. En SQL, `mcaptcha_track_nonce` suit le nonce maximum par niveau de difficulté (anti-replay). En SurrealQL, `nonce` semble être un token jetable avec expiration. Ce sont deux concepts différents.

---

## 4. Le trait Rust MCDatabase (46 méthodes)

Le trait `MCDatabase` dans `db-core/src/lib.rs` définit **46 méthodes async**. Voici la couverture par le schéma SurrealQL actuel :

### IAM (10 méthodes) — ✅ Schéma prêt

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `register` | ✅ table `user` |
| `delete_user` | ✅ |
| `username_exists` | ✅ |
| `get_email` | ✅ (mais email devrait être option) |
| `email_exists` | ✅ |
| `update_email` | ✅ |
| `get_password` | ✅ |
| `update_password` | ✅ |
| `update_username` | ✅ |
| `get_secret` / `get_secret_from_captcha` / `update_secret` | ✅ |

### Captcha CRUD (12 méthodes) — ✅ Schéma prêt

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `create_captcha` | ✅ |
| `get_captcha_config` | ✅ |
| `get_all_user_captchas` | ✅ |
| `update_captcha_metadata` | ✅ |
| `update_captcha_key` | ✅ |
| `captcha_exists` | ✅ |
| `delete_captcha` | ✅ |
| `add_captcha_levels` | ⚠️ À décider : inline array ou table séparée |
| `delete_captcha_levels` | ⚠️ Idem |
| `get_captcha_levels` | ⚠️ Idem |
| `get_captcha_cooldown` | ✅ |

### Stats / Traffic (9 méthodes) — ⚠️ Partiellement prêt

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `record_fetch/solve/confirm` | ✅ table `pow_stat` |
| `fetch_config_fetched/solve/confirm` | ✅ |
| `add_traffic_pattern` | ⚠️ Manque `broke_my_site_traffic` |
| `get_traffic_pattern` | ⚠️ Idem |
| `delete_traffic_pattern` | ⚠️ Idem |
| `get_all_easy_captchas` | ⚠️ Idem |

### Analytics (8 méthodes) — 🔴 Schéma MANQUANT

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `analysis_save` | 🔴 Table manquante |
| `analytics_fetch` | 🔴 |
| `analytics_create_psuedo_id_if_not_exists` | 🔴 |
| `analytics_get_psuedo_id_from_capmaign_id` | 🔴 |
| `analytics_get_capmaign_id_from_psuedo_id` | 🔴 |
| `analytics_delete_all_records_for_campaign` | 🔴 |
| `analytics_get_all_psuedo_ids` | 🔴 |

### Notifications (3 méthodes) — ✅ Schéma prêt

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `create_notification` | ✅ |
| `get_all_unread_notifications` | ✅ |
| `mark_notification_read` | ✅ |

### Nonces (2 méthodes) — ⚠️ Redesigné différemment

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `update_max_nonce_for_level` | ⚠️ Schéma incompatible |
| `get_max_nonce_for_level` | ⚠️ Schéma incompatible |

### Stats avancées (2 méthodes) — 🔴 Schéma MANQUANT

| Méthode | SurrealQL prêt ? |
|:---|:---|
| `stats_get_num_logs_under_time` | 🔴 Dépend de `pow_analytics` |
| `stats_get_entry_at_location_for_time_limit_asc` | 🔴 |

---

## 5. Résumé des actions

### 🔴 À créer (tables manquantes)

1. **`pow_analytics`** — Analytics PoW détaillés
2. **`campaign_alias`** — Alias pseudo pour campagnes

### ⚠️ À corriger (schéma existant)

3. **`traffic_estimate`** — Ajouter `broke_my_site_traffic`
4. **`user`** — `email` devrait être `option<string>`
5. **`captcha`** — `config.duration` → `TYPE int` (pas `TYPE numbers`)
6. **`pow_stat`** — `parent_config` → `record(captcha)` (pas `record(config)`)
7. **`level`** — Décider : supprimer la table et garder levels inline dans `captcha`, ou l'inverse
8. **`nonce`** — Redesigner pour correspondre au trait `update_max_nonce_for_level`

### ✅ OK tel quel

9. **`notification`** — Bien conçue avec record links
10. **`privacy_pass_keys` / `privacy_pass_spent_tokens`** — Ajouts Lyxal, corrects
