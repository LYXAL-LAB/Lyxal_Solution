# Documentation du Module Trésorerie – Lyxal Gateway

## Introduction

Le module **Trésorerie** de Lyxal Gateway (`lyxalcashmanagement`) permet de gérer l’ensemble de la **trésorerie prévisionnelle** d’une entreprise. Il s’appuie sur les modèles d’Axelor enrichis, convertis pour **SurrealDB**, avec une architecture full API et multi-workspace.

Il convient aux TPE/PME, groupes multi-sociétés ou cabinets de gestion, souhaitant un outil cloud, sécurisé et prêt pour l’analyse.

---

## Fonctionnalités principales

* Création de prévisions de trésorerie (`Forecast`) par banque et raison
* Génération récurrente automatique avec `ForecastGenerator`
* Consolidation des flux dans des récapitulatifs `ForecastRecap`
* Personnalisation des types de lignes avec `ForecastRecapLineType`
* Gestion multi-devises, multi-sociétés, multi-utilisateurs
* Préparation des données pour rapports analytiques et IA

---

## Architecture du module

Le module `lyxalcashmanagement` est conçu dans une logique modulaire :

* **Gateway** : API REST typées avec Logto et audit
* **SDK** : fonctions backend/frontend pour `Forecast`, `Recap`, `Generator`
* **SurrealDB** : modèles structurés, index, triggers automatisés
* **UI kit (optionnel)** : widgets prévisionnels, calendrier trésorerie, recap board

---

## Exemple d’utilisation (Backend)

```ts
import { ForecastClient } from 'lyxalcashmanagement/sdk/backend';

await ForecastClient.createForecast({
  company: 'company:1',
  bankDetails: 'bank_details:5',
  forecastRecapLineType: 'forecast_recap_line_type:3',
  estimatedDate: '2025-06-15',
  amount: 4200,
  typeSelect: 2,
});
```

---

## Exemple d’utilisation (Frontend React)

```tsx
import { useCreateForecast } from 'lyxalcashmanagement/sdk/frontend';

function NewForecastButton() {
  const { createForecast } = useCreateForecast();
  return <button onClick={() => createForecast({ amount: 2500 })}>Ajouter</button>;
}
```

---

## Tables SurrealDB

* `forecast` : ligne prévisionnelle unitaire (date, montant, banque)
* `forecast_generator` : modèle de récurrence (ex: tous les mois)
* `forecast_recap` : synthèse par période, multi-banques
* `forecast_recap_line` : ligne prévisionnelle agrégée (facture, salaire...)
* `forecast_recap_line_type` : typage configuré (Facture, Salaire, etc.)

---

## Triggers principaux

* Génération automatique `forecastSeq`, `forecastRecapSeq`
* Marquage automatique de recap comme complété si solde dispo
* Attribution dynamique du `relatedToSelectName` dès lien identifié

---

## Sécurité et architecture SaaS

* Authentification obligatoire via `Logto`
* Audit des créations et modifications sensibles
* Isolation stricte des données par `workspace`
* Accès API étroitement contrôlé avec ratelimit

---

## Requêtes utiles

### Prévisions sur 30 jours :

```sql
SELECT * FROM forecast WHERE estimatedDate >= time::now() AND estimatedDate < time::now() + 30d;
```

### Solde prévisionnel par banque :

```sql
SELECT bankDetails, math::sum(amount) AS balance FROM forecast GROUP BY bankDetails;
```

### Lignes issues d’opportunités CRM :

```sql
SELECT * FROM forecast_recap_line WHERE relatedToSelect = 'opportunity';
```

---

## Bonnes pratiques

* Toujours lier un `Forecast` à une banque et un type
* Créer les `ForecastGenerator` pour les abonnements, loyers, etc.
* Consolider régulièrement avec `ForecastRecap` pour vision globale
* Utiliser les types `ForecastRecapLineType` pour enrichir l’analyse

---

## Références

* [Documentation SurrealDB](https://surrealdb.com/docs)
* [Documentation Logto](https://docs.logto.io)
* [LYXAL GitHub](https://github.com/lyxal-dev)

---

**Module cloud, trésorerie prête pour IA, 100% modulaire et SaaS native.**
