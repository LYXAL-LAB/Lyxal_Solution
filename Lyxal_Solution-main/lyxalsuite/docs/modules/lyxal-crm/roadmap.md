# 📘 LYXALCRM — Feuille de route **VERSION PRODUCTION**

Ce document remplace la version précédente pour une implémentation **sûre, modulaire, et sécurisée en environnement production**.

---

## 🎯 Objectif

Construire un **module CRM complet**, 100 % **multi-tenant par datatable**, avec :
- des **tables CRM robustes**,
- un **provisionnement dynamique**,
- une **intégration sécurisée avec Logto** via `lyxalauth`,
- des **routes API REST sécurisées**,
- un **SDK frontend propre**,
- des **composants UI réutilisables**.

---

## 🧱 Architecture

```
lyxalsuite/
└── lyxalcrm/
    ├── database/
    │   ├── schema.ts
    │   ├── referenceData.ts
    │   └── initCRMDatabase.ts
    ├── gateway/
    │   └── crm.routes.ts
    ├── sdk/
    │   └── crmClient.ts
    ├── ui/
    │   └── (components TSX + CSS)
    └── README_lyxalcrm_production.md
```

---

## ✅ 1. Fonctionnalités couvertes

| Domaine               | Fonctionnalité                         | Statut |
|-----------------------|----------------------------------------|--------|
| Gestion des leads     | lead, status, source, log              | ✅     |
| Opportunités          | type, status, montant, closingDate     | ✅     |
| Partenaires           | statut, agency, domain                 | ✅     |
| Événements            | agenda, rappels, récurrence            | ✅     |
| Tournées              | tour, tour_line                        | ✅     |
| Config & catalogue    | config par défaut, catalog, batchs     | ✅     |
| SaaS avancé           | distribution, accès, scoring           | ✅     |

---

## 🔐 2. Sécurité et conformité LYXAL

Toutes les routes doivent être **protégées via `lyxalauth` (Logto)**.  
Les appels à SurrealDB doivent toujours passer par :

- un token Logto valide (`Authorization: Bearer`)
- un contrôle d’accès sur le **workspace courant** (`X-Workspace-ID`)
- des vérifications **role-based** côté gateway

### Middleware de sécurité requis dans `gateway/crm.routes.ts` :

- `requireAuth(logto)` — via Logto
- `enforceWorkspaceContext()` — compare namespace/db contre l’utilisateur
- `rateLimiter({ limit: X req/min })` — par IP/utilisateur
- `logEvent("crm:*")` — audit des actions importantes
- `validateZod(schema)` — toute route doit valider l’input

---

## 🧪 3. Testabilité et monitoring

- [ ] Tests unitaires du `sdk/`
- [ ] Tests d’intégration `gateway` avec Logto mocké
- [ ] Ajout d’un `audit_log` commun à tous les modules (si besoin)
- [ ] Log des erreurs via `logger.ts` de `lyxal-surreal`
- [ ] Healthcheck CRM API

---

## 📦 4. Initialisation et provisioning

- `initCRMDatabase(db)` doit être appelé à chaque **création de workspace**
- Aucun champ `user`, `account`, `workspace` ne doit figurer dans les tables
- La logique multi-tenant est **100 % assurée par la datatable indépendante**

---

## 📡 5. Gateway

Chaque entité CRM aura ses routes REST standard :

| Méthode | URL                     | Description                    |
|--------|--------------------------|--------------------------------|
| GET    | `/crm/leads`             | Liste des leads                |
| POST   | `/crm/leads`             | Créer un lead                  |
| GET    | `/crm/leads/:id`         | Récupérer un lead              |
| PATCH  | `/crm/leads/:id`         | Modifier un lead               |
| DELETE | `/crm/leads/:id`         | Supprimer un lead              |

Même logique pour :
- `/opportunities`
- `/partners`
- `/events`
- `/catalogs`
- `/crm-config`

---

## 🧠 6. SDK

Dans `sdk/crmClient.ts` :
- Typage strict TypeScript
- Pas de logique métier (ex: scoring)
- Doit appeler l’API via `fetchWithToken(...)`
- Inclut une instance injectable (pour IA ou UI)

---

## 🎨 7. UI

Les composants `ui/` doivent :
- être 100 % réutilisables
- ne contenir **aucun style inline**
- exploiter les variables CSS du thème
- respecter les conventions LYXAL (accessibilité, performance, découpages CSS/TSX)

---

## 🧩 8. Règles strictes Cursor

| Règle | Obligation |
|-------|------------|
| 🔁 Chaque module a sa base, son init, ses routes, son SDK |
| 🧪 Toute route REST passe par Zod + middleware |
| 🔐 Aucune donnée sensible ne transite sans token Logto |
| 🧱 Le namespace/datatable est **dynamique** et obligatoire |
| 📚 Tout ajout doit être documenté dans `README_lyxalcrm_production.md` |
| ⛔ Aucun `if (user.role === "admin")` dans le code CRM (RBAC = externe) |
