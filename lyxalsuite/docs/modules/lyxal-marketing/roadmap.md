# 📘 LYXALMARKETING — Feuille de route **VERSION PRODUCTION**

Ce document est la feuille de route de référence pour l’implémentation du module **Marketing** en environnement **SaaS multi-tenant** avec SurrealDB, Logto, et le design LYXAL.

---

## 🎯 Objectif

Construire un **module Marketing complet**, 100 % **multi-tenant par datatable**, avec :

* des **entités marketing robustes** (campagnes, rappels, cibles…)
* un **provisionnement dynamique** via SurrealDB,
* une **intégration sécurisée avec Logto** (`lyxalauth`),
* des **routes API REST** testables et modulaires,
* un **SDK frontend** utilisable par UI/IA,
* des **composants UI** design-system friendly et réutilisables.

---

## 🧱 Architecture

```
lyxalsuite/
└── lyxalmarketing/
    ├── database/
    │   ├── schema.ts
    │   ├── referenceData.ts
    │   └── initMarketingDatabase.ts
    ├── gateway/
    │   └── marketing.routes.ts
    ├── sdk/
    │   └── marketingClient.ts
    ├── ui/
    │   └── (components TSX + CSS)
    └── README_lyxalmarketing_production.md
```

---

## ✅ 1. Fonctionnalités couvertes

| Domaine               | Fonctionnalité                          | Statut |
| --------------------- | --------------------------------------- | ------ |
| Campagnes             | création, type, sujet, dates, canal     | ✅      |
| Segmentation / cibles | `target_list`, `leadSet`, `partnerSet`  | ✅      |
| Rappels automatisés   | `campaign_reminder`, assignation, durée | ✅      |
| Participants          | `campaign_attendee`                     | ✅      |
| Lien CRM              | `crm_event` (campagne liée à événement) | ✅      |

---

## 🔐 2. Sécurité et conformité LYXAL

Toutes les routes doivent être **protégées par `lyxalauth` (Logto)**.

Chaque requête à la Gateway doit :

* inclure un token Logto (`Authorization: Bearer ...`)
* transmettre un `X-Workspace-ID` valide
* passer les middlewares suivants :

### 🔒 Middlewares obligatoires

* `requireAuth(logto)` — vérifie le token JWT
* `enforceWorkspaceContext()` — datatable correspondante au user
* `rateLimiter({ limit: X })`
* `logEvent("marketing:*")` — journalisation centrale
* `validateZod(schema)` — pour toute validation d’entrée

---

## 🧪 3. Testabilité et monitoring

* [ ] Tests unitaires du `sdk/`
* [ ] Tests d’intégration `gateway` avec Logto mocké
* [ ] Log des erreurs via `logger.ts` (lyxal-surreal)
* [ ] Audit par `logEvent()`
* [ ] Healthcheck `/marketing/healthz`

---

## 📦 4. Initialisation et provisioning

* `initMarketingDatabase(db)` est appelé **à la création du workspace**
* Aucun champ `user`, `account`, `workspace` dans les tables
* Multi-tenant garanti **100 % par datatable dédiée**

---

## 📡 5. Gateway

Chaque entité aura ses routes REST :

| Méthode | URL                        | Description            |
| ------- | -------------------------- | ---------------------- |
| GET     | `/marketing/campaigns`     | Liste des campagnes    |
| POST    | `/marketing/campaigns`     | Créer une campagne     |
| GET     | `/marketing/campaigns/:id` | Détails campagne       |
| PATCH   | `/marketing/campaigns/:id` | Modifier une campagne  |
| DELETE  | `/marketing/campaigns/:id` | Supprimer une campagne |

Même logique pour :

* `/target-lists`
* `/reminders`
* `/attendees`
* `/campaign-types`

---

## 🧠 6. SDK

Dans `sdk/marketingClient.ts` :

* Typage strict TypeScript
* Aucune logique métier
* Appel API via `fetchWithToken()`
* Export d’instances injectables (`useCampaigns`, `useTargetLists`, etc.)

---

## 🎨 7. UI

Les composants `ui/` doivent :

* être modulaires, exportables
* ne contenir **aucun style inline**
* utiliser les **variables CSS du thème global**
* être découpés (`.tsx` + `.css`)
* respecter accessibilité et UX standards

---

## 🧩 8. Règles strictes Cursor

| Règle                                        | Obligation                       |
| -------------------------------------------- | -------------------------------- |
| 🔁 Un module = son init, son SDK, sa gateway | ✅                                |
| 🔐 Toutes routes protégées par Logto         | ✅                                |
| 🔎 Aucune donnée ne sort sans contrôle       | ✅                                |
| 🧪 Tout input REST validé par Zod            | ✅                                |
| 🔍 Le datatable est obligatoire et dynamique | ✅                                |
| 📚 Documentation obligatoire dans README     | ✅                                |
| ❌ Aucune logique de rôle codée en dur        | RBAC externe via Logto / Gateway |
