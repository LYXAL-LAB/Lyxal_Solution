# Documentation du Module Client Portal - Lyxal Gateway

## Introduction

Le module **Client Portal** permet d’activer ou non des fonctionnalités côté client (accès en ligne, commandes, paiements, tickets, etc.). Il s’intègre aux modules `App`, `Partner`, `SaleOrder`, et `OnlinePaymentMethod`.

Fonctionnalités clés :

- Activation ou non de modules visibles depuis le portail client
- Gestion des options comme le paiement en ligne ou la confirmation directe
- Choix des méthodes de paiement disponibles
- Couplage avec une entité `App`

## Architecture

Le module `lyxalclientportal` s’intègre avec :

- **Gateway** : logique d’activation/désactivation des portails
- **SDK Frontend** : visibilité des options client en React
- **SDK Agent** : aide à l’activation automatique des services selon le contexte

## Installation

```bash
npm install lyxalclientportal


Utilisation
Backend

import { PortalClient } from 'lyxalclientportal/sdk/backend';
const portalClient = new PortalClient(api);

await portalClient.enableCustomerPortal({
  appId: 'app:1',
  onlinePaymentMethodSet: ['online_payment_method:1'],
  canPayOnline: true
});


Types de données
AppPortal
app : référence à l’application

manageSaleOrders, manageInvoices, ... : booléens d’activation

canPayOnline : autorise le paiement

portalSelect : 1 = portail natif, 2 = externe

onlinePaymentMethodSet[] : liste de méthodes liées

Sécurité et audit
Authentification requise (Logto)

Données isolées par workspace

Possibilité d’ajouter des logs personnalisés

Bonnes pratiques
Ne jamais activer canPayOnline sans méthode liée

Utiliser portalSelect = 2 uniquement pour portail externe

Afficher les options dynamiquement selon app_portal

Exemple de données
sql
Copier
Modifier
CREATE app_portal SET
  app = app:1,
  manageSaleOrders = true,
  canPayOnline = true,
  onlinePaymentMethodSet = [online_payment_method:1, online_payment_method:2];