# Idées de Fonctionnalités SaaS pour Lyxal Calendar

Ce document a pour but de consigner des idées et des suggestions d'architecture pour des fonctionnalités qui pourraient être proposées par le propriétaire du SaaS aux utilisateurs finaux.

## 1. Abonnements de Calendrier Suggérés ou Globaux

### Contexte
La table `calendarsubscriptions` est conçue pour que chaque utilisateur puisse s'abonner individuellement à des calendriers externes (jours fériés, événements sportifs, etc.).

### Idée
Le propriétaire du SaaS pourrait vouloir proposer des calendriers "officiels" ou "suggérés" à tous ses utilisateurs ou à certains groupes d'utilisateurs.

**Cas d'usage :**
-   **Marketing :** Un calendrier des "Webinaires et Événements Lyxal".
-   **Support :** Un calendrier affichant les périodes de maintenance planifiée.
-   **Partenariats :** Un calendrier des événements d'un partenaire important.

### Implémentation Suggérée
Plutôt que de surcharger la table `calendarsubscriptions` de l'utilisateur, on pourrait créer une nouvelle table dans une base de données "globale" ou "admin" :

**Table `suggested_subscriptions`**
-   `identity.name`: Nom du calendrier suggéré.
-   `identity.source`: URL iCal source.
-   `metadata.target_audience`: Qui peut voir cette suggestion (tous, utilisateurs payants, etc.).
-   ... autres champs pertinents.

Le front-end de l'application pourrait ensuite lire cette table globale et présenter ces calendriers aux utilisateurs dans une section "Découvrir" ou "Suggestions". L'utilisateur pourrait alors choisir de s'y abonner en un clic, ce qui créerait une entrée correspondante dans sa propre table `calendarsubscriptions` personnelle.

**Avantages :**
-   **Séparation claire :** Les abonnements personnels de l'utilisateur restent distincts des suggestions du SaaS.
-   **Non intrusif :** L'utilisateur a le contrôle et choisit de s'abonner ou non.
-   **Marketing/Communication :** Ouvre un canal de communication direct et pertinent avec les utilisateurs.
