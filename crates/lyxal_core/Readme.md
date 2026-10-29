# Lyxal Core

> Bibliothèque standard de Lyxal OS (SurrealDB 3.2.0)

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

```text
lyxal_core/
├── manifest.toml
├── README.md
├── CHANGELOG.md
└── functions/
    ├── validations/
    │   ├── functions/   (339 fonctions)
    │   └── test/        (339 fichiers de tests)
    ├── sanitize/
    │   ├── functions/   (170 fonctions)
    │   └── tests/       (170 fichiers de tests)
    ├── security/
    │   ├── functions/   (170 fonctions)
    │   └── tests/       (170 fichiers de tests)
    └── utils/
        ├── functions/   (120 fonctions)
        └── tests/       (120 fichiers de tests)
```

Chaque dossier représente une bibliothèque indépendante.

Aucune bibliothèque ne dépend d'un module métier.

Tous les modules Lyxal peuvent les utiliser.

---

# Validations (`functions/validations/`)

Le dossier **validations** regroupe les fonctions permettant de vérifier qu'une donnée respecte un contrat.

Exemples :

- validation des chaînes
- validation des nombres
- validation des UUID
- validation des e-mails
- validation des URL
- validation des tableaux
- validation des objets
- validation des dates
- validation des octets (`bytes`)

Ces fonctions ne modifient jamais les données.

Elles vérifient uniquement leur conformité.

---

# Sanitize (`functions/sanitize/`)

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

# Security (`functions/security/`)

Le dossier **security** fournit les fonctions de sécurité et les descripteurs de politiques.

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

Les opérations cryptographiques natives (AES-256-GCM, SHA-256, BLAKE3, Argon2id, HMAC-SHA256, HKDF-SHA256) sont réalisées par le crate Rust fondamental **`lyxal_crypto`**.

---

# Utils (`functions/utils/`)

Le dossier **utils** contient les fonctions techniques génériques.

Il comprend notamment :

- tableaux
- objets
- chaînes
- nombres
- dates
- collections
- comparaisons
- conversions (hexadécimal, URI RFC 3986)
- cache
- runtime
- pipelines
- helpers

Ces fonctions peuvent être utilisées dans tous les modules Lyxal.

---

# Modules utilisant Lyxal Core

Le Core est utilisé par tous les modules système et métiers :

- Lyxal Auth
- Lyxal Scheduler
- Lyxal Notification
- Lyxal Storage
- Lyxal Error
- Lyxal Webhook
- Lyxal Catalogue
- Lyxal Pipeline Ingestion
- Lyxal Booking
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

# Statistiques (Validées sur SurrealDB 3.2.0)

## Validations (`functions/validations/`)

- 339 fonctions
- 339 fichiers de tests

## Sanitize (`functions/sanitize/`)

- 170 fonctions
- 170 fichiers de tests

## Security (`functions/security/`)

- 170 fonctions
- 170 fichiers de tests

## Utils (`functions/utils/`)

- 120 fonctions
- 120 fichiers de tests

---

# Total

Le Core comprend actuellement :

- **799 fonctions SurrealQL** (100 % validées sur **SurrealDB 3.2.0**)
- **799 fichiers de tests** (parité stricte 1:1)

Chaque fonction est fournie avec :

- un fichier `.surql`
- un fichier de test `.surql` / `.test.surql`

---

# Convention

Toutes les fonctions de la bibliothèque standard `lyxal_core` sont déclarées sous la forme :

```surql
DEFINE FUNCTION OVERWRITE fn::<domaine>_<nom>(...) -> <type>
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
