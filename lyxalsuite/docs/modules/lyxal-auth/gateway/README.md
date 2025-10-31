# Documentation Lyxal Gateway

## Introduction

Bienvenue dans la documentation complète de Lyxal Gateway, un backend centralisé pour servir les SaaS Lyxal, exposant des routes REST pour la gestion des utilisateurs et l'authentification via l'API Logto.

## Table des matières

1. [Architecture du système](./Architecture.md)
2. [Installation et configuration](./Installation.md)
3. [API et endpoints](./API/README.md)
   - [Utilisateurs](./API/Users.md)
   - [Applications](./API/Applications.md)
   - [Organisations](./API/Organizations.md)
   - [Rôles et ressources](./API/Roles.md)
   - [Authentification](./API/Authentication.md)
   - [Well-Known](./API/WellKnown.md)
   - [Autres endpoints](./API/Others.md)
4. [Intégration avec d'autres SaaS](./Integration.md)
5. [Sécurité](./Security.md)
6. [FAQ et dépannage](./FAQ.md)

## Aperçu du projet

Lyxal Gateway est une interface centralisée entre plusieurs applications SaaS et l'API Logto pour la gestion d'authentification et d'autorisation. Il suit une architecture REST API modulaire utilisant Hono.js avec:

- **Services** (`/logic/*.ts`) - Gèrent la logique métier et les interactions avec l'API Logto
- **Validation** (`/middleware/*.ts`) - Valide les entrées avec Zod
- **Routes** (`/routes/*.ts`) - Expose les endpoints de l'API
- **Utilitaires** (`/utils/*.ts`) - Fournit des fonctionnalités communes comme la journalisation

## Modules principaux

Le système est composé de plusieurs modules:

1. **Utilisateurs** - Gestion des comptes utilisateurs et des identités
2. **Applications** - Gestion des applications clientes
3. **Organisations** - Gestion des organisations et de leurs membres
4. **Rôles et ressources** - Gestion des droits d'accès
5. **Authentification** - Flux d'authentification et autorisation
6. **Expérience de connexion** - Personnalisation de l'interface utilisateur
7. **Well-Known** - Endpoints de découverte et configuration
8. **Journalisation** - Audit et surveillance des activités

## Commencer

Pour commencer à utiliser Lyxal Gateway, consultez le guide d'[installation et configuration](./Installation.md), puis explorez les différentes API disponibles dans la section [API et endpoints](./API/README.md).

Pour l'intégration avec d'autres systèmes SaaS, référez-vous au guide d'[intégration](./Integration.md). 