# 🔐 Roadmap — Module Auth (`engine/src/auth.rs`)

> Statut : ✅ **V1 Terminée et Validée**
>
> Date de validation : Juillet 2026

---

# 🎯 Objectif

Le module `auth.rs` constitue le moteur d'authentification de **Lyxal Booking**.

Il assure l'ensemble des opérations d'authentification locales et OIDC en s'appuyant sur :

- SurrealDB
- lyxal_error
- lyxal_surreal
- les fonctions SurrealQL
- le pattern universel `store.call_fn(...)`

Le module est désormais considéré comme **fonctionnellement terminé**.

---

# ✅ Fonctionnalités Implémentées

## Comptes locaux

- Création de compte
- Premier utilisateur administrateur
- Génération de username
- Vérification d'unicité
- Changement de mot de passe
- Authentification locale
- Suppression utilisateur
- Gestion des avatars

---

## Sessions

- Création de session
- Lecture de session
- Expiration
- Suppression
- Déconnexion

---

## OIDC

- Connexion OIDC
- Liaison automatique
- Synchronisation des groupes
- Synchronisation des équipes
- Synchronisation du profil
- Synchronisation du titre
- Synchronisation de l'issuer
- Synchronisation du subject
- Protection contre les emails non vérifiés
- Désactivation de l'auto-register
- Gestion des comptes désactivés

---

## Sécurité

- Vérification Argon2
- Hash factice (Dummy Password Hash)
- Réduction des écarts temporels exploitables
- Réponse uniforme
- Protection contre l'énumération des comptes
- Utilisation de RecordId SurrealDB
- LyxalResult<T>
- LyxalCallError
- LyxalSurrealCall

---

# ✅ Architecture

Le module suit intégralement les standards Lyxal OS.

```
Axum Handler
        │
        ▼
engine/auth.rs
        │
        ▼
store.call_fn(...)
        │
        ▼
Fonction SurrealQL
        │
        ▼
SurrealDB
```

Aucun SQL manuel n'est présent dans `auth.rs`.

Toute la logique métier est déplacée dans les fonctions SurrealQL.

Rust ne conserve que :

- Argon2
- OAuth/OIDC
- génération des cookies
- protocoles réseau
- orchestration

---

# ✅ Couverture des Tests

Le module dispose d'une suite complète de tests d'intégration SurrealDB.

## Tests couverts

- création utilisateur
- authentification locale
- création de session
- suppression de session
- suppression utilisateur
- suppression avatar
- réservations futures
- invitations
- synchronisation OIDC
- synchronisation équipes
- synchronisation groupes
- synchronisation du profil
- synchronisation du titre
- synchronisation issuer
- synchronisation subject
- compte désactivé
- email non vérifié
- auto-register désactivé
- premier administrateur
- contraintes d'unicité

La suite comporte actuellement **30 tests d'intégration**.

---

# 🚧 Hors périmètre de auth.rs

Les éléments suivants ne relèvent pas du moteur `auth.rs`.

Ils seront testés dans les couches supérieures.

## Axum

À réaliser dans une suite dédiée.

Exemples :

- POST /login
- POST /logout
- GET /dashboard
- cookies
- redirections
- CSRF
- middleware
- permissions
- impersonation
- réponses HTTP
- headers

---

## Tests End-to-End

À réaliser ultérieurement.

Exemples :

- Playwright
- connexion navigateur
- OIDC complet
- navigation
- cookies navigateur
- parcours utilisateur

---

# 🗺️ Évolution du Module

## V1 ✅

- Tables
- Fonctions SurrealQL
- Wrappers Rust
- Auth locale
- OIDC
- Tests SurrealDB

---

## V2

Aucune évolution fonctionnelle prévue.

Seules des corrections de bugs pourront être apportées.

---

## V3

Les évolutions futures passeront par les modules spécialisés.

Exemples :

- lyxal_event
- lyxal_notification
- lyxal_scheduler
- lyxal_audit
- lyxal_error

Le moteur Auth restera consommateur de ces modules sans intégrer leur logique.

---

# 🔒 Décision d'Architecture

À compter de cette validation :

- le fichier `engine/src/auth.rs` est considéré comme **gelé** ;
- toute nouvelle fonctionnalité devra être implémentée dans un module dédié lorsque cela est possible ;
- seules les corrections de bugs ou les évolutions de sécurité pourront modifier directement ce fichier.

L'objectif est de garantir une base stable, réutilisable et maintenable pour l'ensemble de Lyxal OS.