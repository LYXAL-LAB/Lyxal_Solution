# ✅ TODO CURSOR — FINALISATION AUTH (LYXAL)

Ce fichier décrit toutes les tâches obligatoires pour stabiliser **définitivement** le module `lyxalauth`, incluant :

- ✅ Gateway 
- ✅ SDK backend
- ✅ SDK frontend
- ✅ SDK core partagé
- ✅ Structure sans redondance
- ✅ Rapports de traçabilité obligatoires

---

## 🎯 Objectif global

- Architecture hexagonale claire
- Séparation stricte des responsabilités
- Aucune duplication de logique ou type
- Préparation de composants UI + génération SaaS dynamique
- Traçabilité par étape via fichiers `rapport.md`

---

## 1. 🔐 `gateway/` — Point d’entrée unique sécurisé

### ✅ À faire :
- Toutes les routes vers Logto doivent **rester ici**
- Chaque route :
  - Valide l’entrée avec Zod
  - Utilise `LOGTO_ADMIN_TOKEN` si nécessaire
  - Loggue les actions dans `auth_audit` (SurrealDB)
  - Retourne un JSON typé (pas de `text/plain`, pas de HTML)

### 🚫 Ne jamais :
- exposer les tokens dans le client
- gérer des sessions directement ici
- faire de la logique UI dans la Gateway

---

## 2. 🧠 `sdk/core/` — logique partagée

### ✅ Contenu :
- `types.ts` → User, Session, Role, etc.
- `auth.ts` → `parseJwt()`, `isTokenExpired()`, etc.
- `utils.ts` → `buildQueryParams()`, `mapError()`

👉 Tous les SDK (frontend/backend) doivent consommer **exclusivement** ces helpers.

---

## 3. 🌐 `sdk/frontend/` — appels navigateur vers Gateway

### ✅ Règles :
- Pointent uniquement vers `/api/auth/*`
- Ne contiennent **aucun appel direct à Logto**
- Ne gèrent pas de token manuellement (cookies uniquement si besoin)
- Utilisent `fetch()` avec headers JSON

---

## 4. 🧩 `sdk/backend/` — appels serveur vers Gateway

### ✅ Règles :
- Utilise aussi `/api/auth/*`
- Peut injecter un `Bearer` admin si besoin (ex : pour des workers ou hooks)
- Ne gère jamais de logique UI
- Peut lire des cookies (`req.headers.cookie`) si appel Edge

---

## 5. 📁 Structure de fichiers attendue

```
lyxalauth/
├── gateway/
│   ├── routes/
│   ├── middlewares/
│   ├── validators/
│   └── services/
├── sdk/
│   ├── core/
│   ├── frontend/
│   └── backend/
├── ui/
├── tests/
└── README.md
```

---

## ✅ Étapes de travail & livrables

### 🧾 Étape 1 — Mise en place `sdk/core/`
- Créer `types.ts`, `auth.ts`, `utils.ts`
- Supprimer tous les doublons `type` dans frontend/backend
- 📄 **Créer `rapport.md` dans `sdk/core/` avec :**
  - Liste des types
  - Liste des helpers
  - Justification de chaque fonction

---

### 🧾 Étape 2 — Refactor `sdk/frontend/`
- Rediriger tous les appels vers `/api/auth/*`
- Ne plus appeler Logto directement
- 📄 **Créer `rapport.md` dans `sdk/frontend/` avec :**
  - Liste des fonctions modifiées
  - Validation des appels API
  - Tokens gérés (cookies)

---

### 🧾 Étape 3 — Refactor `sdk/backend/`
- Même logique que frontend
- Peut gérer `LOGTO_ADMIN_TOKEN`
- 📄 **Créer `rapport.md` dans `sdk/backend/` avec :**
  - Liste des appels
  - Justification du contexte backend
  - Cas spécifiques autorisés

---

### 🧾 Étape 4 — Vérification `gateway/`
- Vérifier que chaque route respecte :
  - Zod ✅
  - audit SurrealDB ✅
  - statut HTTP clair ✅
- 📄 **Créer `rapport.md` dans `gateway/` avec :**
  - Routes analysées
  - Validations appliquées
  - Logs et audit intégrés

---

## ✅ Vérifications obligatoires avant clôture

| Contrôle                                                  | OK |
|------------------------------------------------------------|----|
| Toutes les routes Gateway sont validées Zod               | 🔲 |
| Aucun `fetch` vers Logto Cloud depuis le navigateur       | 🔲 |
| Tous les types centralisés dans `sdk/core/types.ts`       | 🔲 |
| Tous les SDK utilisent `core/utils.ts` pour helpers       | 🔲 |
| Aucun token Logto exposé côté client                      | 🔲 |

---

## 🛑 Interdictions strictes

- ❌ Appeler Logto Cloud directement en frontend
- ❌ Stocker manuellement les tokens dans `localStorage`
- ❌ Répliquer les types entre SDK frontend et backend
- ❌ Mettre de la logique métier dans Gateway

---

## ✅ But final

- Gateway = seul point d’entrée
- SDK = modulaire, propre, typé
- UI = branchable dynamiquement
- Architecture = scalable + traçable