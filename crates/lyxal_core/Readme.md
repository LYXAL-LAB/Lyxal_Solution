# Lyxal Core

> Bibliothèque standard de Lyxal OS

---

# Présentation

**Lyxal Core** est la bibliothèque fondamentale de **Lyxal OS**.

Elle regroupe l'ensemble des fonctions SurrealQL génériques utilisées par tous les modules de la plateforme.

Le Core ne contient **aucune logique métier**.

Son rôle est de fournir des briques techniques réutilisables afin d'éviter la duplication de code, de garantir des comportements homogènes et de simplifier le développement de tous les modules Lyxal.

---

# Objectifs

- Centraliser les fonctions communes
- Garantir un comportement identique dans tous les modules
- Réduire la duplication de code
- Faciliter les tests
- Simplifier la maintenance
- Fournir une bibliothèque standard pour SurrealQL

---

# Architecture

```
lyxal_core/

├── validation/
├── sanitize/
├── security/
└── utils/
```

Chaque dossier représente une bibliothèque indépendante.

Aucune bibliothèque ne dépend d'un module métier.

Tous les modules Lyxal peuvent les utiliser.

---

# Validation

Le dossier **validation** regroupe les fonctions permettant de vérifier qu'une donnée respecte un contrat.

Exemples :

- validation des chaînes
- validation des nombres
- validation des UUID
- validation des e-mails
- validation des URL
- validation des tableaux
- validation des objets
- validation des dates
- validation métier

Ces fonctions ne modifient jamais les données.

Elles vérifient uniquement leur conformité.

---

# Sanitize

Le dossier **sanitize** contient les fonctions de normalisation.

Exemples :

- trim
- lowercase
- uppercase
- slug
- nettoyage HTML
- suppression des caractères interdits
- normalisation Unicode
- normalisation téléphone
- normalisation email
- nettoyage des tableaux
- nettoyage des objets

Ces fonctions transforment une donnée afin qu'elle soit exploitable.

---

# Security

Le dossier **security** fournit les fonctions de sécurité.

Il comprend notamment :

- permissions
- contrôle d'accès
- masquage
- redaction
- signatures
- hash
- vérifications
- audit
- replay protection
- validation de politiques
- helpers de sécurité

Les opérations cryptographiques lourdes sont réalisées par le moteur Rust
**lyxal_security_native_rust**.

---

# Utils

Le dossier **utils** contient les fonctions techniques génériques.

Il comprend notamment :

- tableaux
- objets
- chaînes
- nombres
- dates
- collections
- comparaisons
- conversions
- cache
- runtime
- pipelines
- helpers

Ces fonctions peuvent être utilisées dans tous les modules Lyxal.

---

# Modules utilisant Lyxal Core

Le Core est utilisé par tous les modules système :

- Lyxal Auth
- Lyxal Scheduler
- Lyxal Notification
- Lyxal Storage
- Lyxal Error
- Lyxal Webhook
- Lyxal RTC
- Lyxal PDF
- Lyxal Image
- Lyxal Photo
- Lyxal Workflow
- ...

---

# Philosophie

Le Core ne contient jamais :

- de logique métier
- de tables métier
- de workflow
- de règles fonctionnelles propres à un module

Ces éléments appartiennent aux modules Lyxal.

Le Core ne fournit que des briques techniques génériques.

---

# Statistiques

## Validation

- 300 fonctions
- 300 fichiers de tests

## Sanitize

- 170 fonctions
- 170 fichiers de tests

## Security

- 170 fonctions
- 170 fichiers de tests

## Utils

- 120 fonctions
- 120 fichiers de tests

---

# Total

Le Core comprend actuellement :

- **760 fonctions SurrealQL**
- **760 fichiers de tests**
- **76 lots**

Chaque fonction est fournie avec :

- un fichier `.surql`
- un fichier `.test.surql`

---

# Convention

Toutes les fonctions sont déclarées sous la forme :

```surql
DEFINE FUNCTION fn::<nom>()
```

Chaque fonction :

- est documentée
- possède des tests unitaires
- suit les conventions Lyxal
- est indépendante
- est réutilisable

---

# Objectif

Faire de **Lyxal Core** la bibliothèque standard SurrealQL de l'ensemble de Lyxal OS, offrant des fonctions génériques, robustes et testées, réutilisées par tous les modules de la plateforme.