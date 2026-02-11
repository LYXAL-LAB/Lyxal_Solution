# Documentation du Module Bank - Lyxal Gateway

## Introduction

Le module Bank de Lyxal Gateway permet de gérer toutes les opérations bancaires : ordres de paiement, relevés, rapprochements, formats de fichiers, et automatisation IA. Il s'intègre au cœur de la suite LYXAL pour la gestion financière.

Fonctionnalités clés :

* Gestion des ordres de paiement
* Intégration multi-format (SEPA, AFB120, etc.)
* Rapprochement bancaire intelligent
* Fichiers import/export de relevés
* Analyse IA des mouvements
* Audit bancaire

## Architecture

Le module `lyxalbank` s'intègre avec :

* **Gateway** : API REST pour opérations bancaires
* **SDK Backend** : Clients Surreal + automatisation
* **SDK Frontend** : Composants React de gestion bancaire
* **SDK Agent** : Intégration avec les agents IA (analyse automatique)

## Installation

```bash
npm install lyxalbank
```

## Utilisation

### Backend

```ts
import { BankClient } from 'lyxalbank/sdk/backend';
import { HttpClient } from 'lyxalbase/sdk/httpClient';

const httpClient = new HttpClient('https://api.votredomaine.com');
const bankClient = new BankClient(httpClient);

// Création d'un ordre bancaire
const order = await bankClient.createBankOrder({
  partnerId: 'partner:123',
  amount: 2500,
  paymentMode: 'virement',
  companyId: 'company:1',
  status: 'draft'
});
```

### Frontend (React)

```tsx
import { useCreateBankOrder, useListBankStatements } from 'lyxalbank/sdk/frontend/hooks';
import { BankOrderForm, BankStatementList } from 'lyxalbank/sdk/frontend/components';

function BankPage() {
  const { createBankOrder } = useCreateBankOrder();
  const { statements } = useListBankStatements();

  return (
    <div>
      <h1>Module Bancaire</h1>
      <BankOrderForm onSubmit={createBankOrder} />
      <BankStatementList statements={statements} />
    </div>
  );
}
```

### Agent IA

```ts
import { createBankAgent } from 'lyxalbank/sdk/agent';
const bankAgent = createBankAgent('https://api.votredomaine.com');

const suspicious = await bankAgent.detectAnomalies();
const suggestions = await bankAgent.suggestReconciliations();
```

## Types de données

### BankOrder

* `amount` : Montant
* `partner` : Partenaire
* `status` : draft | confirmed | rejected

### BankStatement

* `lines[]` : opérations
* `fromDate` / `toDate`
* `statusSelect` : 1=Démarré, 2=Traité, etc.

### BankReconciliation

* `typeSelect` : client | fournisseur | autre
* `confidenceIndex` : vert | orange | rouge

## Sécurité et audit

* Auth obligatoire (token Logto)
* Tous les changements loggués (event Surreal)
* Accès filtrés par workspace

## Triggers intelligents

* Auto-calcul du fullName (ordre, relevé)
* Marquage automatique des lignes rapprochées
* Mise à jour automatique des dates de validation

## Export / Import

```bash
surrealdb import -e prod -u root -p password lyxalbank/model/bank_structure.surql
```

## Bonnes pratiques

1. Toujours utiliser les statuts définis (`statusSelect`, `typeSelect`)
2. Respecter les formats de fichiers lors des exports
3. Automatiser les rapprochements si possible via agent
4. Séparer les flux clients/fournisseurs

## Références

* [Documentation API Bank](https://docs.lyxal.com/api/bank)
* [SurrealDB Events](https://docs.surrealdb.com/docs/surrealql/statements/define/event)
* [SEPA Specs](https://www.europeanpaymentscouncil.eu/)
