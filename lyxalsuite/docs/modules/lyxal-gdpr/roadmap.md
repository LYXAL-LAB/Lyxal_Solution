# ✅ Feuille de route LYXALGDRP – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **GDPR** (lyxalgdpr) dans la **Gateway LYXAL**, en version **production-ready**. Elle suit la structure officielle validée de LYXAL (gateway, sdk, ui).

---

## 📦 Objectif général

Créer un **gateway backend GDPR** modulaire, sécurisé et conforme à l’architecture LYXAL. Il exposera des routes REST permettant :

* la gestion des requêtes RGPD (création, consultation, modification, suppression)
* la génération de réponse
* l’accès aux logs de traitement / effacement

# 📦 Module `lyxalgdpr`

Gestion complète des demandes RGPD (accès, suppression), conforme aux exigences européennes et intégrée à l'écosystème LYXAL.

---

## ✅ Fonctionnalités couvertes

* Création, modification, suppression de demandes RGPD
* Génération de réponses associées à une demande
* Log complet dans la table `gdpr_audit_log`
* Protection via `Logto` (token/session)
* Middleware production : auth, ratelimit, errorHandler
* Validation Zod strict sur toutes les entrées

---

## 📂 Structure du module

```
lyxalgdpr/
├──── gateway/
│       ├── index.ts
│       ├── routes/
│       │   ├── gdpr.request.ts # Types RGPD côté demande
│       │   ├── gdpr.response.ts # Types RGPD côté réponse
│       │   └── gdpr.routes.ts   # Toutes les routes RGPD (requests, responses, logs)
│       ├── controllers/
│       │   └── gdprController.ts # Contrôleur central, gestion erreurs + validation
│       ├── services/
│       │   └── gdprService.ts # Couche métier, appels SurrealDB, audit intégré
│       ├── validators/
│       │   └── gdprSchemas.ts # Zod schemas (request, update, response)
│       ├── utils/
│       │   └── logAuditEvent.ts
│       └── middlewares/
│           ├── errorsHandler.ts
│           ├── rateLimit.ts
│           └── requireRole.ts 
├──── sdk/ 
│      ├── backend/
│      │      └── gdprClient.ts
│      ├── frontend/
│      │      └── gdprClient.ts
│      └── types/
│            └── types.ts
├──── model/ 
│        ├── gdpr_index.surql
│        ├── gdpr_structure.surql
│        ├── referenceGdprData.surql
│        ├── gdpr_triggers.surql
│        └── testGdprFlow.surql
└───── docs/
        └── lyxalgdpr.md


## 🛡️ Sécurité

* 🔐 Auth via `requireAuth()` de LyxalAuth (Logto)
* 📉 Ratelimit de 5 requêtes/min/IP avec mémoire en RAM
* 🧾 Logs automatiques via `logAuditEvent()` à chaque action critique
* ❌ Aucune route exposée sans middleware

---

## 🧪 Routes disponibles (`/gdpr`)

| Méthode | URL                    | Description                  |
| ------- | ---------------------- | ---------------------------- |
| POST    | `/request`             | Créer une nouvelle requête   |
| GET     | `/request/:id`         | Lire une requête RGPD        |
| GET     | `/request`             | Lister toutes les requêtes   |
| PUT     | `/request/:id`         | Modifier une requête         |
| DELETE  | `/request/:id`         | Supprimer une requête        |
| POST    | `/response/:requestId` | Générer une réponse RGPD     |
| GET     | `/logs`                | Lister les logs RGPD (admin) |

---

## ✅ Table SurrealDB à ajouter

```sql
DEFINE TABLE gdpr_audit_log SCHEMAFULL;
DEFINE FIELD event      ON gdpr_audit_log TYPE string;
DEFINE FIELD user       ON gdpr_audit_log TYPE string;
DEFINE FIELD workspace  ON gdpr_audit_log TYPE string;
DEFINE FIELD payload    ON gdpr_audit_log TYPE object;
DEFINE FIELD timestamp  ON gdpr_audit_log TYPE datetime;
```

---

## 🏁 Statut

🟢 **Prêt pour la production** (complet, sécurisé, structuré)

Dernière vérification : routes, sécurité, audit, validations, types OK.

---

*Fait pour fonctionner avec une base SurrealDB indépendante par workspace.*
