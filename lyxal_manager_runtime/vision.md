# Lyxal Module Runtime (LMR)

## Architecture & Specification Proposal v1.0

---

# Vision

**Lyxal Module Runtime (LMR)** est le moteur central de Lyxal OS.

Son objectif n'est pas uniquement d'installer des modules, mais de gérer **l'intégralité de leur cycle de vie**.

Le Runtime garantit qu'à tout instant le système réel correspond à l'état désiré.

Le développeur décrit uniquement le résultat attendu.

Le Runtime décide des actions nécessaires.

---

# Philosophie

La philosophie de LMR repose sur une architecture déclarative.

Le développeur ne décrit jamais les opérations à effectuer.

Il décrit uniquement ce qui doit exister.

Le Runtime se charge automatiquement de :

* découvrir les modules
* installer
* migrer
* configurer
* démarrer
* superviser
* réparer
* mettre à jour
* supprimer

---

# Declarative Runtime Architecture (DRA)

Le cœur de LMR repose sur un principe unique :

```
Describe

↓

Compare

↓

Reconcile

↓

Monitor

↓

Repair
```

Le Runtime ne demande jamais :

> Que dois-je exécuter ?

Il demande :

> Quel est l'état désiré du système ?

---

# Desired State

Chaque module possède un état désiré.

Exemple :

```
Module

Scheduler

Version

1.5.0

Enabled

true
```

Le Runtime calcule automatiquement les actions nécessaires.

---

# Actual State

Le Runtime inspecte en permanence :

* version installée
* tables
* champs
* index
* fonctions
* workers
* API
* événements
* permissions
* stockage
* configuration
* état de santé

---

# Reconciliation Engine

Le moteur compare :

```
Desired State

↓

Actual State

↓

Difference

↓

Automatic Correction
```

Toutes les divergences sont corrigées automatiquement.

---

# Self-Healing

Le Runtime surveille continuellement tous les modules.

Exemples :

Une fonction SurrealDB est supprimée.

↓

Le Runtime la recrée.

---

Un worker tombe.

↓

Le Runtime le redémarre.

---

Un index disparaît.

↓

Le Runtime le recrée.

---

Une permission est modifiée.

↓

Le Runtime restaure la configuration attendue.

---

Une API n'est plus enregistrée.

↓

Le Runtime la republie.

---

Le système tend en permanence vers son état déclaré.

---

# Structure d'un module

```
scheduler/

Cargo.toml

manifest.toml

resources/

migrations/

src/

assets/
```

Tous les modules suivent exactement la même structure.

---

# Le Manifest

Le manifest devient le contrat officiel du module.

Il décrit complètement le module.

Exemple :

```
module

version

author

license

description

dependencies

capabilities

database

configuration

workers

events

permissions

storage

routes

healthchecks

upgrade

rollback

hooks
```

Le Runtime peut installer le module uniquement à partir du manifest.

---

# Les Capacités

Chaque module déclare les ressources qu'il utilise.

Exemple :

```
Database

Worker

API

Storage

Events

Scheduler

Notification

RTC

AI

Mail
```

Le Runtime active uniquement les composants nécessaires.

---

# Les Dépendances

Le Runtime construit automatiquement un graphe de dépendances.

Exemple :

```
Calendar

↓

Scheduler

↓

Notification

↓

Storage
```

Un module ne peut démarrer que lorsque toutes ses dépendances sont prêtes.

---

# Les Hooks

Chaque module peut fournir des hooks.

```
BeforeInstall

AfterInstall

BeforeMigration

AfterMigration

BeforeStart

AfterStart

BeforeUpdate

AfterUpdate

BeforeStop

AfterStop

BeforeRemove

AfterRemove
```

Ces hooks sont exécutés automatiquement.

---

# Les Resources

Au lieu d'avoir uniquement des migrations, LMR considère qu'un module est composé de ressources.

```
resources/

tables/

fields/

indexes/

functions/

events/

access/

params/

workers/

routes/

buckets/

permissions/

storage/

configuration/
```

Chaque ressource est indépendante.

Le Runtime peut ainsi mettre à jour uniquement la ressource concernée.

---

# Exemple de Resource

```
type: table

name: jobs

version: 2

checksum: ...

dependencies:

- scheduler
```

Le Runtime compare cette ressource avec la base.

Si elle diffère, elle est automatiquement mise à jour.

---

# Les Migrations

Les migrations restent disponibles.

```
migrations/

0001_init.surql

0002_jobs.surql

0003_retry.surql
```

Le Runtime :

* vérifie les checksums
* applique les migrations manquantes
* historise les exécutions
* prépare les futurs rollbacks

---

# Runtime Database

Le Runtime conserve son propre état.

Exemple de tables :

```
system_module

system_module_release

system_module_dependency

system_module_configuration

system_migration

system_health

system_worker

system_resource

system_capability
```

Ces tables représentent l'état réel du système.

---

# Cycle de vie

Chaque module suit exactement le même cycle.

```
Discovery

↓

Validation

↓

Dependency Resolution

↓

Installation

↓

Migration

↓

Configuration

↓

Startup

↓

Health Check

↓

Monitoring

↓

Reconciliation

↓

Update

↓

Shutdown

↓

Removal
```

Tous les modules utilisent ce pipeline.

---

# Health Engine

Chaque module expose un état complet.

```
Installed

Enabled

Healthy

Database

Workers

API

Storage

Functions

Events

Permissions

Latency

Memory

CPU
```

Ces informations sont disponibles dans l'interface Lyxal.

---

# Installation dynamique

Un module peut être installé pendant que Lyxal OS fonctionne.

Le Runtime détecte automatiquement :

* le nouveau module
* ses dépendances
* ses ressources
* ses migrations

Puis il procède à son installation.

Aucun redémarrage n'est nécessaire.

---

# Mise à jour

Une mise à jour consiste uniquement à modifier l'état désiré.

Exemple :

```
Version désirée

1.6.0
```

Le Runtime calcule automatiquement :

* les migrations
* les nouvelles ressources
* les ressources obsolètes
* les dépendances
* les hooks à exécuter

---

# Marketplace

À terme, LMR permettra la création d'un Marketplace.

Un développeur externe n'aura qu'à fournir :

```
manifest.toml

resources/

migrations/

src/
```

Le Runtime prendra automatiquement en charge :

* installation
* configuration
* mise à jour
* supervision
* suppression

Aucun installateur spécifique ne sera nécessaire.

---

# Évolutions futures

Le Runtime pourra intégrer :

* Marketplace officiel
* Modules signés
* Vérification cryptographique
* Rollback automatique
* Snapshots
* Déploiement distant
* Synchronisation multi-nœuds
* Cluster Runtime
* Feature Flags
* Progressive Rollout
* Version Channels
* Diagnostics assistés par IA
* Sauvegardes automatiques
* Réparation distribuée

---

# Vision finale

Lyxal Module Runtime ne doit pas être considéré comme un simple moteur de migration.

Il constitue le cœur de Lyxal OS.

Tous les modules, qu'ils soient développés par Lyxal ou par des tiers, suivent le même contrat.

Le Runtime devient responsable de leur cycle de vie complet.

Cette approche offre :

* une architecture uniforme ;
* une maintenance simplifiée ;
* des installations automatiques ;
* des mises à jour fiables ;
* une supervision centralisée ;
* une auto-réparation permanente ;
* une plateforme prête pour un écosystème de modules.

Le principe fondateur est le suivant :

> **Décrivez l'état souhaité une seule fois. Le Runtime se charge du reste.**
