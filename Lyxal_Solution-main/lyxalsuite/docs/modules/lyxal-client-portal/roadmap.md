
---

## ✅ `feuille-route-clientportal.md`

```md
# ✅ Feuille de route LYXALCLIENTPORTAL – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Client Portal** (`lyxalclientportal`) dans la **Gateway LYXAL**, version **production-ready**.

---

## 📦 Objectif général

Permettre aux entreprises clientes de personnaliser leur portail client (vente, factures, projets, tickets...) via une interface centralisée.

---

## 📂 Module `lyxalclientportal`

Activation des fonctions client via entité `app_portal`, méthode de paiement via `online_payment_method`.

---

## ✅ Fonctionnalités couvertes

- Activer/désactiver les modules disponibles pour le portail
- Choisir les modes de paiement accessibles
- Définir des préférences visuelles (ex: afficher le catalogue)
- Lier à une entité `App`
- Contrôler les droits client en ligne

---

## 📁 Structure du module

lyxalclientportal/
├── gateway/
│      ├── routes/
│      │     └── portal.routes.ts
│      └── controllers/
│              └── portalController.ts
├── sdk/
│    ├── backend/
│    │      └── portalClient.ts
│    ├── frontend/
│    │      └── components/AppPortalSettings.tsx
├── model/
│    ├── client_portal_structure.surql
│    ├── client_portal_index.surql
│    ├── client_portal_triggers.surql
│    ├── referenceClientPortalData.surql
│    └── testClientPortalFlow.surql
└── docs/
     └── lyxalclientportal.md

     
---

## 🔐 Sécurité & conformité

- Auth Logto obligatoire
- Accès filtrés par `workspace`
- Possibilité d’activer audit sur modification des paramètres

---

## 🧰 Routes disponibles (`/portal`)

| Méthode | URL               | Description                        |
|--------|-------------------|------------------------------------|
| GET    | `/:id`            | Lire les paramètres portail        |
| PUT    | `/update/:id`     | Mettre à jour les options portail  |
| GET    | `/payments`       | Lister les méthodes de paiement    |
| POST   | `/activate`       | Activer un portail pour une app    |

---

## 💪 Statut

✅ Schéma complet SurrealDB  
✅ Données de référence `online_payment_method`  
✅ Test Flow validé  
🔄 Intégration API et UI en cours

---

> Ce module est neutre, activable ou non selon la stratégie de l’entreprise cliente.  
> Il est prévu pour fonctionner dans une instance SurrealDB isolée par workspace.

---
