# 🛡️ Fiche de Travail Cursor — Module `auth` (LYXAL Suite)

> Ce document décrit avec une précision absolue les attentes concernant le module d'**authentification centralisée** de LYXAL. Cursor doit s’y référer à chaque étape. Aucun point ne doit être omis ou modifié arbitrairement. Toute variation nécessite une validation explicite.

---

## 📌 Objectif global

* Fournir un module d’**authentification central**, scalable, modulaire, sécurisé, exploité via **Gateway + SDK + UI**.
* Compatible avec les normes modernes (OAuth 2.1, JWT, 2FA, RBAC).
* Utilisé **à la fois par les humains (UI)** et **par des agents IA**.

Utilisation de Logto en version CLoud
---

## 🔐 Fonctionnalités obligatoires

### 🎯 Authentification / Sécurité

* ✅ Login par email + mot de passe
* ✅ Signup + validation email (token ou magic link)
* ✅ Login via lien magique (magic link)
* ✅ Reset mot de passe (token + sécurité)
* ✅ 2FA (TOTP)
* ✅ OAuth (Google, GitHub, etc.)
* ✅ Refresh Token / Access Token (JWT strictement contrôlé)
* ✅ Session sécurisée avec vérification expiration token + auto logout
* ✅ Rate limiting configurable (middleware)

### 🧑‍⚖️ Autorisation / Permissions

* ✅ RBAC (role-based access control) — scope `auth:*`
* ✅ Rôles dynamiques définis côté DB (viewer, user, admin...)
* ✅ Permissions intégrées dans le contexte utilisateur SDK

### 🔎 Audit / Journalisation

* ✅ Tous les événements critiques loggés (`auth:*`)
* ✅ Suivi des erreurs (login\_failed, otp\_invalid...)
* ✅ Audit trail stocké par utilisateur + action + date

---

## 🧩 Structure technique

### 📁 Dossiers à créer dans `lyxalsuite/lyxalauth`

pour lyxalauth on a deja beaucoup de choses faite à transferer dans lyxalauth C:\Users\Admin\Desktop\Lyxal_Gateway\gateway\microservices\auth 
C:\Users\Admin\Desktop\Lyxal_Gateway\gateway\core\middleware
C:\Users\Admin\Desktop\Lyxal_Gateway\packages\lyxal-sdk\microservices\auth

```
lyxalsuite/
└── lyxalauth/
    ├── gateway/
    │   ├── routes/
    │   ├── services/
    │   ├── middlewares/
    │   ├── validators/
    │   └── index.ts
    ├── model/
    ├── sdk/
    ├── ui/
    ├── interface/
    ├── constants/
    ├── config/
    ├── tests/
    └── README.md
```

### 🔁 Base de données (SurrealDB)

* Tables : `auth_user`, `auth_token`, `auth_audit`
* Génération automatique des `id`
* Relations normalisées (user ↔ org, user ↔ session)


je pense pas qu'il soit utile d'utiliser surrealdb car au final on utilise logto en version cloud
---

## 📦 Modèle utilisateur `auth_user`

| Champ        | Type     | Obligatoire | Description                   |
| ------------ | -------- | ----------- | ----------------------------- |
| id           | string   | ✅           | ID auto                       |
| email        | string   | ✅           | Email unique                  |
| passwordHash | string   | ✅           | Hash sécurisé du mot de passe |
| magicToken   | string   | ❌           | Token login magique           |
| magicExpiry  | datetime | ❌           | Expiration du token           |
| otpSecret    | string   | ❌           | Secret 2FA                    |
| role         | enum     | ✅           | viewer, user, admin...        |
| createdAt    | datetime | ✅           | Date de création              |
| lastLogin    | datetime | ❌           | Dernière connexion            |

---

## 🔌 SDK — méthodes attendues

* `login({ email, password })`
* `signup({ email, password })`
* `requestPasswordReset(email)`
* `resetPassword(token, newPassword)`
* `sendMagicLink(email)`
* `verifyMagicLink(token)`
* `enable2FA()` / `verifyOTP(code)`
* `getSession()` / `logout()`
* `getCurrentUser()`

---

## 🧠 UI Composants obligatoires

react + vite + tailwind pour tailwind suivre cette procedure officielle https://tailwindcss.com/docs/installation/using-vite


On utilise des components réutilibale, les composents seront centralisé dans un dossier séparé, on doit pouvoir utilisé nos composants de manière dynamique en production de saas un peu en mode preview et no code, shadcn
tout passer en variable de theme pour avoir une possibilité de personnalisation, avec theme se mettant à jour instantanément encore une fois j'ai un modele tu demande et je te le presente


* `LoginForm.tsx`
* `SignupForm.tsx`
* `MagicLinkForm.tsx`
* `ResetPasswordForm.tsx`
* `OtpVerification.tsx`
* `UserProfile.tsx` (affichage des infos + actions liées)
* `RoleBadge.tsx`

> Tous les composants doivent être désign-système friendly et exploitables via assistant IA. Aucun style inline.

---

## 📋 Tests

* ✅ Unitaires :

  * hash/password, validation tokens, SDK
* ✅ Fonctionnels :

  * toutes routes `gateway/routes/*`
* ✅ Audit trail :

  * Tous les cas de `auth:*` doivent être testés

---

## 📓 Documentation finale à livrer

* `README.md` dans `lyxalauth/` avec :

  * Description fonctionnelle
  * Diagrammes flux auth / refresh / 2FA
  * Schéma DB
  * Liste des routes
  * Exemple d'appel SDK pour chaque action
  * Checklist sécurité
  * Liens vers tests unitaires/fonctionnels

---

**⚠️ Aucun module auth ne sera considéré comme "fini" sans la remise de ce document rempli et validé.**
