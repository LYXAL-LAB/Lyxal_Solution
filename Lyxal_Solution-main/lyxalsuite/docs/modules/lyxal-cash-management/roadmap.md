# ✅ Feuille de route LYXALCASHMANAGEMENT – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Cash Management** dans la **Gateway LYXAL**, version **production-ready**. Elle suit les standards officiels (gateway/sdk/ui).

---

## 📦 Objectif général

Créer un backend de **gestion de trésorerie prévisionnelle**, compatible multi-workspace, sécurisé et extensible. Il permet :

* la gestion des prévisions de trésorerie (`Forecast`)
* la génération automatique de flux récurrents (`ForecastGenerator`)
* l’agrégation et analyse via `ForecastRecap`
* la personnalisation des types via `ForecastRecapLineType`
* le lien avec les banques, utilisateurs, opportunités

---

# 📦 Module `lyxalcashmanagement`

Module de pilotage prévisionnel de trésorerie pour entreprises multi-banques et multi-utilisateurs.

---

## ✅ Fonctionnalités couvertes

* CRUD sur `Forecast`, `ForecastRecap`, `ForecastRecapLine`, `ForecastGenerator`
* Sélection et génération des flux selon périodicité (mensuel, hebdo, etc.)
* Typage des lignes (Facture, Commande, Salaire, etc.) via `ForecastRecapLineType`
* Consolidation par période, banque, utilisateur
* Intégration avec opportunités CRM, banques, utilisateurs
* Données prêtes à l’emploi pour IA et dashboards
* Full SurrealDB avec triggers et relations complexes

---

## 📂 Structure du module

```
lyxalcashmanagement/
├── gateway/
│   ├── routes/
│   │   ├── forecast.routes.ts
│   │   ├── forecast-recap.routes.ts
│   │   ├── generator.routes.ts
│   │   └── line-type.routes.ts
│   ├── services/
│   │   └── forecastService.ts
│   ├── validators/
│   │   └── forecastSchemas.ts
├── sdk/
│   ├── backend/
│   │   └── forecastClient.ts
│   ├── frontend/
│   │   └── forecastHooks.ts
│   └── types/
│       └── types.ts
├── model/
│   ├── cash-management_structure.surql
│   ├── referenceCashManagementData.surql
│   ├── cash-management_triggers.surql
│   └── cash-management_indexes.surql
└── docs/
    └── lyxalcashmanagement.md
```

---

## 🛡️ Sécurité

* Auth via `requireAuth()` Logto
* Rate Limit 5 req/min
* Audit activé sur `Forecast`, `ForecastRecap`, `ForecastGenerator`
* Aucune route publique

---

## 🔀 Relations clés

* `Forecast` ➞ `Company`, `BankDetails`, `ForecastRecapLineType`, `ForecastGenerator`
* `ForecastRecap` ➞ `ForecastRecapLine[]`, `User`, `Currency`, `Company`, `BankDetails[]`
* `ForecastRecapLine` ➞ `ForecastRecap`, `ForecastRecapLineType`, élément source (opportunité, etc.)
* `ForecastGenerator` ➞ génération automatique de `Forecast`

---

## ✅ Tables SurrealDB à créer

```surql
DEFINE TABLE forecast SCHEMAFULL;
DEFINE TABLE forecast_recap SCHEMAFULL;
DEFINE TABLE forecast_recap_line SCHEMAFULL;
DEFINE TABLE forecast_recap_line_type SCHEMAFULL;
DEFINE TABLE forecast_generator SCHEMAFULL;
```

---

## 🔹 Routes disponibles (`/forecast`)

| Méthode | URL                            | Description                     |
| ------- | ------------------------------ | ------------------------------- |
| GET     | `/forecast`                    | Liste des prévisions            |
| POST    | `/forecast`                    | Créer une prévision             |
| GET     | `/forecast/:id`                | Détail d’une prévision          |
| PUT     | `/forecast/:id`                | Modifier une prévision          |
| DELETE  | `/forecast/:id`                | Supprimer une prévision         |
| POST    | `/generator`                   | Créer une récurrence de flux    |
| POST    | `/forecast-recap`              | Créer un récapitulatif          |
| GET     | `/forecast-recap/:id/lines`    | Voir les lignes de recap        |
| POST    | `/forecast-recap/:id/complete` | Marquer un recap comme complété |

---

## 📊 Champs calculés & triggers

* `DEFINE EVENT` pour :

  * `forecast.forecastSeq` automatique
  * `forecast_recap.forecastRecapSeq` automatique
  * `forecast_recap_line.relatedToSelectName` auto selon lien
  * complétion automatique de `isComplete`, `calculationDate`

---

## 🚧 Indexes à définir

```surql
DEFINE INDEX forecast_seq_idx ON forecast FIELDS forecastSeq UNIQUE;
DEFINE INDEX forecast_recap_seq_idx ON forecast_recap FIELDS forecastRecapSeq, company UNIQUE;
DEFINE INDEX forecast_recap_line_type_idx ON forecast_recap_line_type FIELDS name;
```

---

## 🏁 Statut

✅ **Complet et prêt à être implémenté** dans la Gateway LYXAL.
