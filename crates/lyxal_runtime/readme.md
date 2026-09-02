# Lyxal Runtime

> **Le moteur d'exécution, d'orchestration, de ressources SurrealQL, de migrations et de verrouillage distribué pour Lyxal OS**

---

## 🌟 Présentation

Le **Lyxal Runtime** est le noyau d'orchestration de **Lyxal OS**. Il est responsable de l'installation, de l'initialisation, de l'exécution, de la supervision, de la persistance et de la désinstallation de tous les modules de la plateforme.

Le Runtime sépare strictement les contrats déclaratifs du moteur d'exécution, des ressources et du stockage :
1. **Runtime Core** : Gestionnaire de cycle de vie (`LifecycleManager`), registre de modules (`ModuleRegistry`) et résolveur de graphe de dépendances (`DependencyResolver`).
2. **Manifest System** : Déclaration externe via `manifest.toml` convertie en `ModuleDescriptor`.
3. **Resource Architecture** : Abstraction portable (`ResourceProvider`, `ModuleResource`, `ResourceKind`) avec sécurité anti-traversal.
4. **Schema Importer** : Découverte et exécution ordonnée des ressources structurelles de base (`SchemaImportPlan`, `SchemaImporter`).
5. **Distributed Locking & Coordination** : Baux distribués temporaires (`MigrationLeaseManager`, `SurrealMigrationLeaseManager`), fencing tokens anti-zombies et réconciliation TOCTOU.
6. **Migration Engine** : Découverte (`MigrationDiscovery`), planification (`MigrationPlan`) et exécution transactionnelle déterministe (`MigrationRunner`).
7. **Runtime Persistence** : Couche d'abstraction `RuntimeStore` et implémentation officielle `SurrealRuntimeStore` (reposant sur `lyxal_surreal`).

---

## 🏛️ Architecture Globale & Diagramme

```text
Module Package
      │
      ├── manifest.toml ────► ManifestParser ────► ModuleDescriptor
      │
      ├── schema/ ──────────► ResourceDiscovery ──► SchemaImportPlan ──► SchemaImporter
      │                                                                        │
      └── migrations/ ──────► MigrationDiscovery ─► MigrationPlan ─────► MigrationRunner
                                                                               │
                                    ┌──────────────────────────────────────────┴────────┐
                                    ▼                                                   ▼
                         MigrationLeaseManager (lock)                          RuntimeStore (trait)
                                    │                                                   │
                        SurrealMigrationLeaseManager                           SurrealRuntimeStore
                                    │                                                   │
                                    └─────────────────────┬─────────────────────────────┘
                                                          ▼
                                                      SurrealDB
                                          ┌───────────────────────┐
                                          │ system_module         │
                                          │ system_module_release │
                                          │ system_migration      │
                                          │ system_migration_lock │
                                          └───────────────────────┘
```

---

## 📁 Différence fondamentale : `schema/` vs `migrations/`

Lyxal OS distingue formellement deux répertoires de ressources déclaratives :

| Répertoire | Rôle | Moment d'exécution | Idempotence |
| :--- | :--- | :--- | :--- |
| **`schema/`** | Définitions structurelles de base du module (Tables, Fields, Indexes, Functions, Permissions, Events, Seeds). | Installation initiale du module (`bootstrap`). | Doit être idempotent (`OVERWRITE`). |
| **`migrations/`** | Évolutions incrémentales versionnées (`NNN_description.surql`). | Cycle de migration du Runtime. | Exécuté une seule et unique fois, tracé dans `system_migration`. |

---

## 🏗️ Ordre Officiel des Ressources de Schéma

Lors de l'importation via `SchemaImporter`, l'ordre de priorité strict est garanti :

```text
1. Tables       (schema/tables.surql)
2. Fields       (schema/fields.surql)
3. Indexes      (schema/indexes.surql)
4. Functions    (schema/functions.surql)
5. Permissions  (schema/permissions.surql)
6. Events       (schema/events.surql)
7. Seeds        (schema/seeds.surql)
```

Les fichiers absents ou vides (espaces / commentaires) sont gérés de façon déterministe et ignorés sans générer de requêtes superflues.

---

## 🛡️ Sécurité & ResourceProvider

L'accès aux ressources est abstrait par le trait `ResourceProvider`.
L'implémentation `FilesystemResourceProvider` applique des garde-fous stricts :
* **Interdiction du Directory Traversal** : rejet immédiat des chemins contenant `..`.
* **Interdiction des chemins absolus** : rejet des chemins Unix (`/etc/...`) ou Windows (`C:\...`).
* **Plafond de taille configurable** : rejet des fichiers dépassant `DEFAULT_MAX_RESOURCE_SIZE` (10 Mo par défaut).
* **Validation UTF-8 stricte** : détection immédiate des corruptions d'encodage.

---

## 🔒 Coordination Distribuée des Migrations (V1.4)

Dans un environnement multi-instances où plusieurs nœuds de Lyxal OS démarrent en parallèle, `MigrationRunner` empêche formellement l'exécution concurrente d'une même migration.

### 1. Identité du Nœud (`NodeId`)
Chaque processus possède un `NodeId` fort (`NodeId::generate()` ou configuré explicitement), combinant PID, horodatage haute résolution et entropie SHA-256.

### 2. Clé et Modèle de Bail (`MigrationLockKey`, `MigrationLease`)
* **Clé logique** : `module_id + migration_id` (ex: `lyxal-booking:001_initial_schema`).
* **Bail** : `owner: NodeId`, `generation: u64` (fencing token), `acquired_at: u64`, `renewed_at: u64`, `expires_at: u64`.
* **Table dédiée** : `system_migration_lock` avec index d'unicité `idx_system_migration_lock_key`.

### 3. Jeton de Clôture (Fencing Token)
Chaque reprise de bail expiré incrémente de façon monotone `generation = generation + 1`. Un nœud "zombie" ralenti ne peut plus renouveler (`renew`) ni libérer (`release`) un bail dont la génération a changé.

### 4. Cycle de Vie du Bail
```text
Acquisition (acquire) ──► Revalidation TOCTOU ──► Exécution ──► Libération (release)
       ▲                                                              │
       │ (si échec/wait)                                              ▼
       └──────────────── Attente (retry/timeout) ──────────── Bail libéré
```

### 5. Réconciliation TOCTOU (Time-of-Check to Time-of-Use)
Le `MigrationPlan` initial est une vue à un instant $T$. Dès l'acquisition du verrou, `MigrationRunner` réinterroge immédiatement `RuntimeStore` :
- Si un autre nœud a complété la migration pendant l'attente du verrou (`Applied` avec même checksum) -> le nœud libère le verrou et marque la migration comme `Skip`.
- Si un checksum drift est détecté -> arrêt dur immédiat.

### 6. Détection de Crash & Politique de Récupération (`MigrationRecoveryPolicy`)
- **`RequireManualIntervention` (défaut)** : si une migration est trouvée en état `Applying` avec un bail expiré, le runner refuse l'exécution automatique pour éviter de réappliquer un script non idempotent et lève `RUNTIME_MIGRATION_RECOVERY_REQUIRED`.
- **`AllowRetryIfChecksumMatches`** : autorise la réapplication si le checksum est rigoureusement identique.

---

## 🧭 Architecture Déclarative du Runtime — DRA Reconciler Core (V1.6)

La version V1.6 introduit le moteur de réconciliation déclaratif officiel de Lyxal OS (**Declarative Runtime Architecture**).

### 1. Philosophie & Principe de Convergence

Au lieu d'exécuter des suites d'instructions impératives, le Runtime accepte un **état souhaité** (`DesiredRuntimeState`) et calcule automatiquement le chemin de convergence minimal vers cet état :

```text
DesiredRuntimeState
        │
        ▼
RuntimeObserver (Read-only observation) ──► ActualRuntimeState
        │
        ▼
RuntimeDiffer (Pure in-memory diffing) ───► ReconciliationPlan (Dry-Run)
        │
        ▼
RuntimeReconciler (Safe execution) ───────► Revalidation TOCTOU ──► Apply
        │
        ▼
ReconciliationReport (Convergence, Drift résiduel, Durée)
```

### 2. Piliers & Règles d'Or du Reconciler

1. **Zéro Upgrade Indésirable** : Si un module est déjà installé dans une version satisfaisant la contrainte déclarée (`VersionReq`), le Reconciler conserve la version en place (0 mutation).
2. **Version Drift vs Update** : Un drift n'existe que si l'état réel ne satisfait pas l'état souhaité. Une version plus récente disponible n'est pas un drift.
3. **Fermeture des Dépendances (Dependency Closure)** : Déclarer `booking: Running` propage automatiquement l'exigence `Running` sur ses dépendances (`calendar`, `scheduler`, `timezone`). Déclarer `Installed` propage `Installed` (sans démarrer les dépendances).
4. **Détection Préventive des Conflits** : Si une dépendance est explicitement déclarée `Absent` ou `Stopped` alors qu'un parent requiert son exécution, le Reconciler refuse immédiatement le plan avec `RUNTIME_DESIRED_STATE_CONFLICT`.
5. **Séparation Stricte Actions vs Bloqueurs** : Les blockers (`MissingPackage`, `UnsatisfiedVersion`, `UnsupportedDowngrade`) sont isolés et n'apparaissent jamais comme des actions mutationnelles exécutables.
6. **Revalidation TOCTOU** : Avant chaque action mutationnelle (`Install`, `Start`, `Stop`), l'état réel est réinterrogé pour détecter les convergences concurrentes (`SkippedRevalidationReason::AlreadyConverged`) ou les échecs de préconditions.
7. **One-Pass Idempotent** : Deux passes successives avec le même état souhaité produisent immédiatement `Converged` avec `planned_actions = 0`.

### 3. Sémantique Node-Local & Limitations V1.6

- **Node-Local** : Les états de processus `Running` et `Stopped` sont gérés localement par le `LifecycleManager` du nœud courant. Les installations et migrations bénéficient quant à elles des baux distribués certifiés V1.4–V1.5.
- **Absence de désinstallation destructive** : La cible `Absent` arrête le module et le marque inactif, mais n'effectue aucun `DROP TABLE` ni suppression de données métier.
- **Rétrogradations non supportées** : Tout downgrade automatique est bloqué avec `UnsupportedDowngrade` et nécessite une intervention administrative.

---

## 🩺 Health Engine & Boucle Continue de Réconciliation (V1.7)

La version V1.7 dote Lyxal Runtime de son moteur de santé proactif et de son contrôleur de réconciliation continue (**Continuous Reconciliation Controller**).

### 1. Découplage Santé vs Cycle de Vie

La santé d'un module est découplée de son cycle de vie :
* `ModuleState = Running` n'implique pas obligatoirement `Healthy`.
* Statuts fortement typés :
  * `Healthy` : Fonctionnement nominal.
  * `Degraded` : Dégradation partielle.
  * `Unhealthy` : Panne avérée ou timeout de check.
  * `Unknown` : Module `Running` sans vérificateur de santé enregistré.
  * `NotApplicable` : Module non en cours d'exécution (ex: `Stopped`, `Installed`) — **n'altère pas la santé globale du nœud**.

### 2. Contrat `ModuleHealthCheck` & `HealthEngine`

Les modules exposent leur diagnostic via le trait asynchrone `ModuleHealthCheck` :
```rust
#[async_trait]
pub trait ModuleHealthCheck: Send + Sync {
    fn module_id(&self) -> &ModuleId;
    async fn check(&self, ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError>;
}
```
* **Exécution Parallèle Bornée** : `HealthEngine` limite la concurrence (`max_concurrency`) et applique un timeout strict (`check_timeout`). Tout dépassement produit `HealthStatus::Unhealthy`.
* **Transitions Observées** : `HealthSnapshot::transitions_from()` détecte les transitions réelles entre états applicables (`Healthy` $\leftrightarrow$ `Degraded` $\leftrightarrow$ `Unhealthy` $\leftrightarrow$ `Unknown`).
* **Persistance Instantanée** : Stockage de l'état courant par nœud dans la table `system_health` (clé unique `node_id + module_id`).

### 3. Contrôleur Continu (`ContinuousReconciliationController`)

Le contrôleur orchestre l'observation, la réconciliation et le monitoring en continu :
```text
Cycle Start
    ↓
Observe Actual Initial
    ↓
Plan Desired vs Actual
    ↓
If actions: Apply -> Observe Final; Else: Final = Initial
    ↓
Run Health on Final Running Modules
    ↓
Persist Health Snapshot
    ↓
Build RuntimeStatusSnapshot
    ↓
Wait Backoff / Interval
```

* **Garantie Anti-Chevauchement (*No Overlapping Passes*)** : Un verrou atomique sync RAII empêche formellement deux passes simultanées sur le même contrôleur.
* **Repli Exponentiel Borné (*Exponential Backoff*)** : En cas d'erreur d'infrastructure, le délai s'ajuste selon `max(interval, base_backoff * factor^failures)` plafonné à `max_backoff`, puis se réinitialise immédiatement dès le premier cycle réussi.
* **Zéro Faux Drift** : Un module `Unhealthy` mais déjà `Running` n'entraîne aucune mutation de cycle de vie superflue (*DRA Lifecycle Converged*).
* **Arrêt Gracieux (*Graceful Shutdown*)** : La boucle s'arrête proprement dès résolution du signal d'interruption sans jamais maintenir de verrou pendant le sommeil.

---

## ⚖️ Garanties & Limitations

### Ce qui est garanti :
- **Unicité de l'exécuteur actif** (*Single active migration executor*) : Deux instances concurrentes ne peuvent jamais exécuter simultanément la même migration.
- **Récupération des baux orphelins** : Un crash d'instance ne bloque pas indéfiniment le système (expiration TTL).
- **Protection anti-zombies** : Les anciens propriétaires ne peuvent pas écraser les baux réattribués grâce au fencing token.
- **Détection des migrations interrompues** : Traçabilité des états `Applying` sans bail actif.
- **Réconciliation continue et supervision de santé locale** : Convergence déclarative continue sans chevauchement ni boucle agressive.

### Limitations connues :
- Une panne intervenant au milieu d'un script SurrealQL contenant des instructions non transactionnelles multiples peut laisser la base dans un état partiel. La politique conservatrice `RequireManualIntervention` protège contre les réexécutions aveugles.
- Cette version V1.7 est strictement node-locale pour la santé et la réconciliation continue. Elle n'introduit pas de cluster manager global, de supervision de workers distribués ni de restart automatique agressif.

---

## 🧪 Commandes de Validation

```bash
# Vérification du formatage
cargo fmt --all -- --check

# Analyse statique stricte
cargo clippy --workspace --all-targets -- -D warnings

# Exécution de l'ensemble des tests (y compris concurrence et multi-nœuds mem://)
cargo test --workspace
```
