# Lyxal Runtime

> **Le moteur d'exécution des modules Lyxal OS**

---

# Présentation

Le **Lyxal Runtime** est le cœur de **Lyxal OS**.

Il est responsable de l'installation, de l'initialisation, de l'exécution, de la supervision et de la désinstallation de tous les modules de la plateforme.

Contrairement à un simple chargeur de plugins, le Runtime orchestre l'ensemble du cycle de vie d'un module :

* installation ;
* import des ressources SurrealDB ;
* exécution des migrations ;
* démarrage des services ;
* supervision des processus ;
* arrêt et suppression.

Chaque module est considéré comme une unité fonctionnelle autonome pouvant être installée, mise à jour ou supprimée sans affecter le reste du système.

---

# Philosophie

Lyxal OS est conçu comme un système d'exploitation applicatif.

Le Runtime remplit un rôle comparable à celui du noyau d'un système d'exploitation :

* il connaît les modules installés ;
* il gère leur état ;
* il contrôle leur cycle de vie ;
* il garantit leur compatibilité.

Un module n'interagit jamais directement avec le système d'installation.

Toutes les opérations passent par le Runtime.

---

# Objectifs

Le Runtime doit permettre :

* une installation entièrement automatisée ;
* une exécution fiable ;
* une mise à jour sans interruption ;
* une désinstallation propre ;
* une gestion centralisée des dépendances ;
* un contrôle précis des versions.

---

# Responsabilités

Le Runtime est responsable de :

* charger les modules installés ;
* lire leur manifeste ;
* vérifier leur compatibilité ;
* importer les fichiers `.surql` ;
* créer les tables ;
* créer les index ;
* créer les fonctions SurrealDB ;
* créer les permissions ;
* appliquer les migrations ;
* enregistrer les services ;
* démarrer les serveurs Rust ;
* enregistrer les routes HTTP ;
* lancer les tâches planifiées ;
* démarrer les workers ;
* superviser les processus ;
* arrêter proprement un module ;
* supprimer un module.

---

# Cycle de vie d'un module

Le Runtime applique toujours le même cycle.

```text
Téléchargement

↓

Vérification

↓

Extraction

↓

Lecture du manifeste

↓

Contrôle des dépendances

↓

Import des fichiers .surql

↓

Exécution des migrations

↓

Initialisation

↓

Démarrage

↓

Module actif
```

---

# Structure minimale d'un module

```text
lyxal_scheduler/

├── manifest.toml
├── backend/
├── frontend/
├── schema/
│   ├── tables.surql
│   ├── indexes.surql
│   ├── functions.surql
│   └── permissions.surql
├── migrations/
├── assets/
├── docs/
└── tests/
```

Le Runtime connaît cette structure et sait automatiquement où rechercher les différentes ressources.

---

# Manifest

Chaque module possède un manifeste décrivant son identité.

Exemple :

```toml
name = "scheduler"

version = "1.2.0"

author = "Lyxal"

description = "Gestionnaire de tâches"

rust = ">=1.90"

surrealdb = ">=3.0"

dependencies = [
    "notification",
    "storage"
]
```

Le manifeste constitue le point d'entrée du Runtime.

---

# Import des ressources SurrealDB

Le Runtime ne crée jamais les ressources directement.

Il importe les fichiers présents dans le dossier **schema**.

Exemple :

```text
schema/

tables.surql

indexes.surql

functions.surql

permissions.surql

events.surql
```

L'ordre d'import est toujours identique afin de garantir la cohérence de la base.

1. Tables
2. Champs
3. Index
4. Fonctions
5. Permissions
6. Événements
7. Données initiales (optionnelles)

---

# Gestion des migrations

Chaque évolution du schéma est stockée dans le dossier :

```text
migrations/
```

Exemple :

```text
001.surql

002.surql

003.surql
```

Le Runtime conserve la liste des migrations exécutées.

Lorsqu'un module est mis à jour, seules les migrations manquantes sont appliquées.

---

# États d'un module

Chaque module possède un état.

```text
Non installé

↓

Installation

↓

Initialisation

↓

Actif

↓

En pause

↓

Arrêté

↓

Mise à jour

↓

Erreur

↓

Désinstallé
```

Ces états sont utilisés par les interfaces d'administration.

---

# Dépendances

Un module peut dépendre d'autres modules.

Exemple :

```text
Calendar

↓

Scheduler

↓

Notification
```

Le Runtime vérifie que toutes les dépendances sont présentes avant de lancer l'installation.

En cas d'absence, l'installation est interrompue.

---

# Gestion des versions

Le Runtime vérifie :

* la version de Rust ;
* la version de SurrealDB ;
* la version du Runtime ;
* les versions minimales des dépendances.

Aucun module incompatible ne peut être exécuté.

---

# Supervision

Une fois démarré, le Runtime surveille chaque module.

Il contrôle notamment :

* les processus actifs ;
* la consommation mémoire ;
* les erreurs ;
* les redémarrages ;
* les workers ;
* les tâches planifiées.

Cette supervision permet d'améliorer la stabilité globale de Lyxal OS.

---

# Rollback

Si une mise à jour échoue :

* les migrations sont annulées lorsque cela est possible ;
* la version précédente est restaurée ;
* le module est redémarré.

L'objectif est qu'une mise à jour ne rende jamais le système inutilisable.

---

# Journalisation

Toutes les opérations importantes sont enregistrées.

Exemples :

```text
Installation

Mise à jour

Suppression

Erreur

Migration

Import SurrealDB

Démarrage

Arrêt
```

Les journaux permettent de diagnostiquer rapidement les incidents.

---

# Sécurité

Le Runtime ne lance jamais un module sans contrôles préalables.

Les vérifications comprennent notamment :

* intégrité du paquet ;
* signature numérique ;
* compatibilité des versions ;
* dépendances ;
* validité du manifeste.

---

# API internes

Le Runtime expose des services utilisés par les autres composants de Lyxal OS.

Exemples :

```text
Installer un module

Supprimer un module

Mettre à jour un module

Démarrer un module

Arrêter un module

Redémarrer un module

Lister les modules

Consulter leur état

Consulter les journaux
```

Ces API sont consommées par le **Lyxal Package Manager**, l'interface d'administration et les outils d'automatisation.

---

# Interactions avec les autres composants

Le Runtime travaille en collaboration avec :

* **Lyxal Repository** : récupération des métadonnées des modules.
* **Lyxal Package Manager** : téléchargement, installation et mise à jour des paquets.
* **Lyxal Storage** : accès aux archives, ressources statiques et fichiers associés.

Le Runtime ne télécharge jamais directement un module. Il reçoit un paquet déjà vérifié par le Package Manager, puis prend en charge son installation et son exécution.

---

# Évolutions prévues

À terme, le Runtime intégrera notamment :

* chargement dynamique des modules sans redémarrage ;
* exécution distribuée sur plusieurs nœuds ;
* supervision centralisée ;
* équilibrage de charge ;
* gestion des dépendances circulaires ;
* sandbox de sécurité ;
* surveillance en temps réel des performances ;
* installation atomique ;
* reprise automatique après incident.

---

# Conclusion

Le **Lyxal Runtime** est le moteur d'exécution de Lyxal OS.

Il garantit que chaque module est installé, exécuté et supervisé de manière fiable, tout en assurant la cohérence des ressources SurrealDB, la compatibilité des versions et la stabilité globale de la plateforme.

À lui seul, il constitue l'un des composants fondamentaux de l'architecture de Lyxal OS et sert de point d'entrée à tous les modules de l'écosystème.
