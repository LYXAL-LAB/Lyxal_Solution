# Module GDPR pour Lyxal Gateway

Ce module permet de gérer les demandes liées aux droits des utilisateurs concernant leurs données personnelles, conformément au RGPD (Règlement Général sur la Protection des Données).

## Fonctionnalités

- Création et gestion des demandes d'accès aux données
- Création et gestion des demandes d'effacement des données
- Génération de réponses aux demandes GDPR
- Suivi des activités d'audit
- Gestion des processus d'anonymisation

## Architecture

Le module lyxalgdpr s'intègre avec les autres composants de Lyxal Gateway :

- **Gateway** : API REST pour la gestion des demandes GDPR
- **SDK Backend** : Hooks pour les applications backend
- **SDK Frontend** : Hooks React pour les applications frontend
- **SDK Agent** : Interface spécifique pour les agents IA

## Installation

```bash
npm install lyxalgdpr
```

## Développement

### Prérequis

- Node.js >= 14
- npm >= 7

### Installation des dépendances

```bash
npm install
```

### Lancer les tests

Pour exécuter tous les tests :

```bash
npm test
```

Pour exécuter uniquement les tests unitaires :

```bash
npm run test:unit
```

Pour exécuter uniquement les tests d'intégration :

```bash
npm run test:integration
```

Pour générer un rapport de couverture :

```bash
npm run test:coverage
```

### Linting

Pour vérifier la qualité du code :

```bash
npm run lint
```

### Build

Pour compiler le projet :

```bash
npm run build
```

## Documentation

Pour plus d'informations sur l'utilisation du module, consultez la [documentation complète](docs/lyxalgdpr.md).

## Exemples

Des exemples d'utilisation de l'agent IA sont disponibles dans [sdk/agent/examples.md](sdk/agent/examples.md).

## Licence

Ce projet est sous licence propriétaire. Tous droits réservés à Lyxal Team. 