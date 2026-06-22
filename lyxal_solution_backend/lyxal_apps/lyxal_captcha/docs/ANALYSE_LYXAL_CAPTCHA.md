# Analyse : lyxal_captcha

> **Date** : 2026-04-26

---

## 1. Origine

C'est un **fork de [mCaptcha](https://github.com/mCaptcha/mCaptcha)** — un système CAPTCHA open source basé sur le Proof-of-Work (PoW) SHA-256, sous licence AGPL-3.0.

| Attribut | Valeur |
|:---|:---|
| **Projet upstream** | mCaptcha (https://github.com/mCaptcha/mCaptcha) |
| **Auteur original** | Aravinth Manivannan (realaravinth) |
| **Licence** | AGPL-3.0-or-later |
| **Version** | 0.1.0 (unreleased) |
| **Rust edition** | 2021 |
| **Framework web** | Actix-web 4 |
| **Base de données** | PostgreSQL ou MariaDB (via SQLx) |
| **Cache** | Redis (optionnel, fallback en mémoire) |

---

## 2. Comment ça fonctionne

```
                        Utilisateur
                            │
                      ┌─────▼─────┐
                      │  Widget JS │  ← SHA-256 Proof-of-Work (côté client)
                      └─────┬─────┘
                            │ soumet le PoW
                      ┌─────▼─────────────────┐
                      │  mCaptcha Server (Rust) │
                      │  Actix-web + libmcaptcha │
                      └─────┬─────────────────┘
                            │
               ┌────────────┼────────────────┐
               │            │                │
        ┌──────▼──────┐ ┌───▼────┐  ┌────────▼────────┐
        │ Vérif PoW   │ │ Token  │  │ Site Verify API  │
        │ (difficulté │ │ émis   │  │ /pow/siteverify   │
        │  variable)  │ │ au user│  │ (pour le backend) │
        └─────────────┘ └────────┘  └──────────────────┘
```

**Principe** : Au lieu d'images à reconnaître (reCAPTCHA), l'utilisateur doit résoudre un problème de calcul SHA-256. La difficulté est **dynamique** (adapte automatiquement selon le trafic).

---

## 3. Structure des fichiers

### Backend Rust (Actix-web)

```
src/
  main.rs              ← Point d'entrée, initialisation Actix-web
  data.rs              ← State applicatif (DB, Redis, mCaptcha system, mailer)
  settings.rs          ← Configuration (644 lignes, 32 env vars)
  db.rs                ← Abstraction base de données
  errors.rs            ← Gestion d'erreurs
  routes.rs            ← Déclaration des routes
  demo.rs              ← Mode démo (utilisateur auto-créé)
  easy.rs              ← Mode captcha simplifié (auto-calibrage)
  stats.rs             ← Statistiques
  survey.rs            ← Système de survey (NLnet)
  
  api/
    mod.rs             ← Module API
    lyxal_privacy_pass.rs  ← ★ AJOUT LYXAL : Privacy Pass (stub)
    v1/
      account/         ← CRUD comptes utilisateur
      auth.rs          ← Login/Logout/Register
      mcaptcha/        ← Gestion des captchas (CRUD + difficulté)
      notifications/   ← Notifications internes
      pow/             ← Coeur du PoW (get_config, verify, siteverify)
      meta.rs          ← Métadonnées serveur
      stats.rs         ← Stats API
      survey.rs        ← Survey API

  middleware/
    lyxal_privacy_pass_verifier.rs  ← ★ AJOUT LYXAL : Middleware Privacy Pass (stub)
    lyxal_rate_limiter.rs           ← ★ AJOUT LYXAL : Rate limiter (actix-governor)
    mod.rs
    
  email/               ← Templates email
  pages/               ← Pages HTML (dashboard, login, etc.)
  widget/              ← Widget captcha embeddable
  static_assets/       ← Fichiers statiques
```

### Frontend (TypeScript + Webpack + SCSS)

```
templates/
  index.ts             ← Entry point frontend
  router.ts            ← Router client-side
  logger.ts            ← Logging
  main.scss            ← Styles principaux
  mobile.scss          ← Styles mobile
  
  api/v1/routes.ts     ← Définition des routes API frontend
  auth/                ← Pages login/register/forgot password
  panel/               ← Dashboard admin (captchas, notifications, settings)
  components/          ← Composants UI
  widget/              ← Widget captcha JS
  views/               ← Templates de pages
  utils/               ← Utilitaires
```

### Base de données

```
db/
  db-core/src/         ← Trait abstrait MCDatabase (interface)
  db-sqlx-postgres/    ← Implémentation PostgreSQL
  db-sqlx-maria/       ← Implémentation MariaDB
  db-migrations/       ← Migrations SQL
```

---

## 4. Modifications Lyxal (par rapport à mCaptcha upstream)

### ★ Ajouts spécifiques Lyxal

| Fichier | Statut | Description |
|:---|:---|:---|
| `src/api/lyxal_privacy_pass.rs` | **Stub** (28 lignes) | 2 endpoints `/api/v1/issue-tokens` et `/api/v1/redeem-token` — retournent OK sans logique |
| `src/middleware/lyxal_privacy_pass_verifier.rs` | **Stub** (58 lignes) | Middleware Actix qui passe tout sans vérification. Commentaire : "For now, it passes everything through" |
| `src/middleware/lyxal_rate_limiter.rs` | **Fonctionnel** (13 lignes) | Rate limiter via `actix-governor` : 10 req/s, burst 10 |
| Dépendance `blind-rsa-signatures = "0.17.1"` | **Ajoutée** au Cargo.toml | Pour le Privacy Pass (non utilisée encore) |
| Dépendance `governor + actix-governor` | **Ajoutée** | Pour le rate limiting |
| Dépendance `dashmap` | **Ajoutée** | Utilisée par le rate limiter |

### Intégration dans main.rs

```rust
// Ligne 148-149 — wrapping Actix middlewares Lyxal
.wrap(crate::middleware::lyxal_privacy_pass_verifier::PrivacyPassVerifier)
.wrap(crate::middleware::lyxal_rate_limiter::get_rate_limiter())
```

---

## 5. État de maturité

| Composant | État |
|:---|:---|
| Serveur mCaptcha (PoW, auth, CRUD) | ✅ Complet (hérité de mCaptcha upstream) |
| Base de données (PostgreSQL/MariaDB) | ✅ Complet |
| Widget JavaScript (PoW client) | ✅ Complet |
| Frontend dashboard | ✅ Complet |
| Privacy Pass (Lyxal) | 🔴 **Stub** — aucune logique, retourne toujours OK |
| Rate Limiter (Lyxal) | ✅ Fonctionnel (basique : 10 req/s) |
| Intégration avec Lyxal Core | 🔴 **Aucune** — c'est un service standalone Actix |

---

## 6. Points d'attention

### Architecture : Service standalone, pas intégré au Core

`lyxal_captcha` est un **service Actix-web indépendant** avec sa propre base PostgreSQL/MariaDB. Il n'a **aucune connexion** avec le Lyxal Core (SurrealDB, LyxalKV).

```
Lyxal Core (SurrealDB)  ← AUCUN LIEN →  lyxal_captcha (Actix + PostgreSQL)
```

### Privacy Pass : à implémenter

Le crate `blind-rsa-signatures` est importé mais **jamais utilisé**. Les endpoints issue/redeem sont des stubs. Le middleware vérifie rien. C'est le chantier principal.

### Pas dans le workspace root

`lyxal_captcha` a son **propre Cargo.toml workspace** (ligne 17-19 du Cargo.toml), il n'est **pas** dans le workspace root du backend Lyxal. C'est un projet Rust séparé qui vit dans `lyxal_apps/` mais se compile indépendamment.

### Licence AGPL-3.0

Le projet upstream mCaptcha est sous **AGPL-3.0**, ce qui impose de distribuer le code source de toute modification. Les ajouts Lyxal (Privacy Pass, rate limiter) sont donc soumis à cette licence.

### Versions des dépendances

Certaines dépendances sont **datées** (Rust edition 2021, actix-identity 0.4 qui est obsolète). La `argon2-creds` pointe vers une branche `master` d'un fork personnel.

---

## 7. Résumé

| Question | Réponse |
|:---|:---|
| **Qu'est-ce que c'est ?** | Fork de mCaptcha — CAPTCHA basé sur le Proof-of-Work SHA-256 |
| **C'est fonctionnel ?** | ✅ Le core mCaptcha oui, les ajouts Lyxal sont des stubs |
| **C'est intégré à Lyxal ?** | 🔴 Non — service standalone avec sa propre DB |
| **Quoi de spécifique Lyxal ?** | Privacy Pass (stub), rate limiter, 3 fichiers ajoutés |
| **Priorité ?** | Faible pour les connecteurs API, utile pour la sécurité web |
