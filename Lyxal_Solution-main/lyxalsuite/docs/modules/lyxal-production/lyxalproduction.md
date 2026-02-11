# Documentation du Module Production - Lyxal Gateway

## Introduction

Le module **Production** de Lyxal Gateway (`lyxalproduction`) permet de gérer tous les processus liés à la fabrication, aux ordres de production et à l’imputation des temps. Il est conçu pour les entreprises industrielles, les projets techniques ou les chantiers, avec des fonctionnalités prêtes pour l’automatisation via IA.

## Fonctionnalités principales

* Création et suivi des ordres de production (OP)
* Génération des ordres de fabrication (OF)
* Planification et exécution des opérations
* Imputation de temps par employé
* Rattachement à des projets, ventes, ou facturations
* Journalisation automatique des actions clés
* Prêt pour intégration avec agents IA

## Architecture du module

Le module s’intègre à l’écosystème LYXAL avec une structure claire :

* **Gateway** : routes REST sécurisées pour les opérations de production
* **SDK Backend/Frontend** : accès programmatique aux données de production
* **Agent IA** : déclenchement d’actions de production par un agent
* **SurrealDB** : stockage multi-tenant avec triggers intelligents

## Exemple d’utilisation (Backend)

```ts
import { ProductionClient } from 'lyxalproduction/sdk/backend';
const production = new ProductionClient(httpClient);

const order = await production.createProductionOrder({
  name: 'Chantier Maison',
  project: 'project:1',
  saleOrderLine: 'sale_order_line:1',
  status: 'planned'
});
```

## Exemple d’utilisation (Frontend React)

```tsx
import { useCreateProductionOrder } from 'lyxalproduction/sdk/frontend/hooks';

function ProductionPage() {
  const { createOrder } = useCreateProductionOrder();

  const handleSubmit = async () => {
    await createOrder({
      name: 'Nouveau chantier',
      project: 'project:1',
      saleOrderLine: 'sale_order_line:1'
    });
  };

  return <button onClick={handleSubmit}>Créer un ordre</button>;
}
```

## Exemple d’intégration Agent IA

```ts
import { createProductionAgent } from 'lyxalproduction/sdk/agent';
const agent = createProductionAgent('https://api.monapp.com');

await agent.createOrder({
  name: 'Mission IA',
  project: 'project:1',
  saleOrderLine: 'sale_order_line:1'
});
```

## Modèles SurrealDB

* `production_order` : Ordre de production
* `manuf_order` : Ordre de fabrication
* `operation_order` : Opérations de production
* `timesheet_line` : Imputations de temps
* `sale_order_line`, `sale_order_line_details` : Liens avec la vente
* `project_task`, `invoicing_project` : Liens avec les projets
* `employee`, `work_center` : Ressources humaines et techniques

## Sécurité

* 🔐 Authentification via Logto (token/session)
* 🧾 Logs d’audit automatiques
* 🚦 Rate limiting configurable
* 🧩 Isolation des données par workspace

## Bonnes pratiques

* Ne jamais exécuter d’ordre sans projet associé
* Ne pas dupliquer les lignes de commande dans plusieurs ordres
* Toujours imputer les temps avec un employé et une opération valide
* Utiliser les hooks IA pour automatiser la clôture ou la facturation

## Migration et déploiement

```bash
surreal import --conn wss://your.surreal.endpoint --user root --pass pass lyxalproduction/model/production_structure.surql
```

## Références

* [SurrealDB Documentation](https://surrealdb.com/docs)
* [Lyxal Gateway GitHub](https://github.com/lyxal-dev)

---

*Module 100% cloud, multitenant, IA-ready – conçu pour l’excellence opérationnelle.*
