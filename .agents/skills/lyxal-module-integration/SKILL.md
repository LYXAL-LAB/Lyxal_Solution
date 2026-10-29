---
name: lyxal-module-integration
description: >-
  Use this skill before creating, modifying, or reviewing interactions across multiple Lyxal OS modules to analyze the Cargo and manifest.toml dependency DAG, public SurrealQL/Rust/Event contracts, SemVer compatibility, implicit database couplings, and topological execution order.
---

# Lyxal OS — Intégration Multi-Modules & Contrats Transversaux (`lyxal-module-integration`)

> **Source normative** : Ce Skill applique la Charte d'Architecture définie dans [`.agents/AGENTS.md`](../../AGENTS.md) (§1, §2, §5.8.1, §6, §7, §8) et [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md), ainsi que les règles du résolveur de dépendances implémentées dans [`crates/lyxal_runtime/src/resolver.rs`](../../../crates/lyxal_runtime/src/resolver.rs) et [`crates/lyxal_runtime/src/manifest/`](../../../crates/lyxal_runtime/src/manifest/mod.rs).

---

## Quand déclencher ce Skill

Activer ce Skill dès qu'une mission implique :
- Une modification touchant **deux modules ou plus** de la suite Lyxal OS ;
- L'ajout ou la modification d'une dépendance dans `manifest.toml` (`[[dependencies]]`) ou `Cargo.toml` (`[dependencies]`) ;
- La modification d'un contrat public partagé : fonction SurrealQL `fn::<module>_<action>`, DTO Rust public (`*Params`, `*Result`), ou événement `lyxal_event` (`<module>.<entite>.<action>`) ;
- La préparation d'un plan d'implémentation (`implementation_plan.md`) transversal soumis à validation CTO.

---

## Contrôles Obligatoires vs Recommandations

> **Distinction Normative** : Les contrôles marqués **[OBLIGATOIRE]** protègent l'intégrité du graphe DAG et la non-rupture des contrats publics (tout écart est classé **P0** ou **P1**). Les points marqués **[RECOMMANDATION]** optimisent le séquencement de livraison (**P2**).

---

### 1. Construction & Validation du Graphe des Dépendances (`manifest.toml` & `Cargo.toml`)

#### Mécanismes réels du Runtime à vérifier
- Modèle [`ModuleManifest`](../../../crates/lyxal_runtime/src/manifest/model.rs) et [`ManifestValidator`](../../../crates/lyxal_runtime/src/manifest/validation.rs) :
  - Vérifie `manifest_version <= CURRENT_MANIFEST_VERSION` (`1`), la présence de `id` et `name`, l'absence d'auto-dépendance (`ManifestValidationError::SelfDependency`) et l'absence de dépendance dupliquée (`ManifestValidationError::DuplicateDependency`).
- Résolveur [`DependencyResolver`](../../../crates/lyxal_runtime/src/resolver.rs) (`resolve` / `resolve_descriptors`) :
  - Vérifie que chaque dépendance déclarée est enregistrée (`RuntimeError::MissingDependency`) ;
  - Construit le graphe orienté acyclique (DAG) et calcule un **ordre topologique déterministe** par l'algorithme de Kahn (file de priorité ordonnée par `(registration_index, ModuleId)`) ;
  - En cas de cycle, extrait le chemin exact du cycle par parcours DFS (`RuntimeError::DependencyCycle { cycle }`).

#### Règles de contrôle
1. **[OBLIGATOIRE] Respect de la Hiérarchie des Couches ([`AGENTS.md` §6](../../AGENTS.md))** :
   - **Couche 0 (Fondation SurrealQL)** : `lyxal_core` (`validation`, `sanitize`, `security`, `utils`) ;
   - **Couche 1 (Fondation Rust)** : `lyxal_error` $\rightarrow$ `lyxal_surreal`, `lyxal_crypto` ;
   - **Couche 2 (Noyau Technique & Moteur)** : `lyxal_event`, `lyxal_runtime`, `lyxal_auth`, `lyxal_notification`, `lyxal_scheduler` ;
   - **Couche 3 (Modules Métiers)** : `lyxal_booking`, `lyxal_catalogue`, `lyxal_pipeline_ingestion`, `lyxal_crm`, `lyxal_documents`, `lyxal_btp`, etc. ;
   - **Couche 4 (Hôtes & UI)** : `apps/lyxal-server`, Console Surrealist, CLI.
   - **Interdiction absolue (P0)** : Aucun composant d'une couche inférieure ne peut dépendre d'un composant d'une couche supérieure ou créer un cycle.
2. **[OBLIGATOIRE] Alignement Tripartite (`Cargo.toml` $\leftrightarrow$ `manifest.toml` $\leftrightarrow$ `ModuleDescriptor`)** :
   - Comparer les dépendances déclarées dans `<module>/Cargo.toml`, dans `<module>/manifest.toml` (`[[dependencies]]`) et dans `ModuleDescriptorBuilder` (`src/module.rs`).
   - Noter explicitement la distinction : `Cargo.toml` contient les dépendances de compilation Rust (y compris les crates de fondation `lyxal_error`, `lyxal_surreal`, `lyxal_crypto`, `lyxal_runtime`), tandis que `manifest.toml` et `ModuleDescriptor` déclarent les dépendances vers d'autres **modules gérés par le Runtime** (`LyxalModule`).
3. **[OBLIGATOIRE] Cohérence des `[resources]` et Capacités (`capabilities`)** :
   - Vérifier que la section `[resources]` de `manifest.toml` (utilisée par `ResourceDiscovery` / `FilesystemResourceProvider`) référence tous les fichiers `.surql` requis par les modules dépendants (notamment `schemas`, `migrations`, `functions`, `events`, `error_definitions`).

---

### 2. Contrôle des Contrats Publics Inter-Modules

Aucun module ne doit connaître l'implémentation interne d'un autre module ([`AGENTS.md` §1 & §2](../../AGENTS.md)). Toute interaction inter-modules passe exclusivement par l'un des 3 canaux suivants :

1. **[OBLIGATOIRE] Contrat SurrealQL Public (`fn::<module>_<action>($params: object)`)** :
   - Vérifier que tout appel d'un module $B$ vers une fonction d'un module $A$ cible uniquement une fonction publique documentée (`COMMENT "..."`) et respecte son contrat d'entrée `$params` et de sortie `fn::result_ok` / `fn::error_result`.
2. **[OBLIGATOIRE] Contrat Rust Public (`store.call_fn`, `*Params`, `*Result`)** :
   - Vérifier que les structures publiques exposées par un module ne fuient aucun détail de persistance interne (`pub(crate)`), aucun secret et aucun tuple anonyme.
3. **[OBLIGATOIRE] Contrat Événementiel (`lyxal_event`)** :
   - Vérifier que le producteur et le consommateur s'accordent sur le nom canonique `EVENT_TYPE` (`<module>.<entite>.<action>`) et sur le schéma JSON du `payload` sérialisé dans `event_outbox`, **sans** que le module producteur n'importe le module consommateur.

---

### 3. Détection des Dépendances Implicites Non Déclarées [OBLIGATOIRE]

Une dépendance implicite est une **violation P1** (ou **P0** si elle viole l'isolation métier) :
1. **Recherche dans les fichiers `.surql`** :
   - Scanner `functions/*.surql`, `schema/*.surql`, `events/*.surql` et `migrations/*.surql` du module analysé pour détecter :
     - Tout appel `fn::<autre_module>_*` (hors `lyxal_core` et `fn::result_ok` / `fn::error_result` / `fn::error_resolve` / `fn::event_publish`) dont le module propriétaire n'est **pas** déclaré dans `manifest.toml` ;
     - Tout accès direct (`SELECT`, `CREATE`, `UPDATE`, `DELETE`, `record::exists`) à une table préfixée par un autre module métier (`<autre_module>_*`) sans passer par l'API publique `fn::<autre_module>_*` de ce module (**violation P0 d'encapsulation**).
2. **Recherche dans les fichiers Rust (`src/**/*.rs`)** :
   - Détecter tout appel `store.call_fn("<autre_module>_*", ...)` ou abonnement à un `EVENT_TYPE` `<autre_module>.*` non reflété dans la documentation des dépendances ou l'ordre de démarrage.

---

### 4. Analyse d'Impact SemVer, Migrations & Non-Rupture d'API

Conformément à [`AGENTS.md` §8](../../AGENTS.md) (`V1 Architecture -> V2 Sans breaking change -> V3 Migration -> V4 Dépréciation`) :
1. **[OBLIGATOIRE] Détection des Breaking Changes** :
   - **SurrealQL** : suppression ou renommage d'une fonction `fn::<module>_*`, ajout d'un champ obligatoire dans `$params` sans valeur par défaut (`??` / `DEFAULT`), modification de la structure retournée dans `fn::result_ok($data)`, suppression d'un code d'erreur existant.
   - **Rust** : suppression ou changement de type d'un champ public dans `*Params` / `*Result`, modification de la représentation Serde (`rename`), changement de signature d'un wrapper public.
   - **Événements** : renommage de `EVENT_TYPE` ou suppression/changement de type d'un champ du `payload` consommé par un abonné actif.
   - **Schéma DB** : suppression d'une table/champ ou durcissement d'une `ASSERT` sans script de migration ordonné dans `migrations/XXXX_*.surql`.
2. **[RECOMMANDATION] Stratégie d'évolution sans rupture (Expand / Contract)** :
   - Privilégier l'ajout de champs optionnels avec valeur par défaut en V2, fournir une migration explicite en V3, et ne déprécier l'ancien champ/contrat qu'après migration de tous les consommateurs.

---

### 5. Tri-Partition Obligatoire des Changements & Ordre d'Exécution

Toute analyse `lyxal-module-integration` doit classer les interventions envisagées en **3 catégories strictement séparées** :

1. **Catégorie 1 — Modifications Compatibles (Sans Rupture)** :
   - Ajout de nouvelles fonctions `fn::<module>_*`, de nouveaux champs optionnels avec défaut, de nouveaux événements ou de nouveaux tests, sans impact cassant sur les modules existants.
2. **Catégorie 2 — Migrations Nécessaires** :
   - Évolutions de schémas SurrealDB (`migrations/XXXX_*.surql`), mises à jour coordonnées des DTOs `*Params` / `$params`, ou ajout d'abonnements `event_subscription` nécessitant un ordre de déploiement précis.
3. **Catégorie 3 — Décisions CTO Requises (Bloquantes avant exécution)** :
   - Ajout d'une nouvelle primitive dans `lyxal_core` ou `lyxal_crypto` ;
   - Création d'une table `TYPE RELATION` ;
   - Modification d'une dépendance entre modules dans `manifest.toml` / `Cargo.toml` ;
   - Tout *breaking change* d'un contrat public existant.

---

## Format Obligatoire du Rapport `lyxal-module-integration`

Lors de l'exécution de ce Skill, toujours produire un rapport structuré comportant :

1. **Graphe des Dépendances & Ordre Topologique** :
   - Représentation claire (tableau ou diagramme Mermaid `flowchart TD`) des modules impactés, alignement `Cargo.toml` / `manifest.toml` / `ModuleDescriptor`, et ordre topologique exact d'installation/démarrage calculé selon `DependencyResolver`.
2. **Matrice des Contrats Inter-Modules Impactés** :
   - Tableau listant : `Module Producteur`, `Module Consommateur`, `Type de Contrat (SurrealQL / Rust / Event)`, `Symbole ou Fonction`, `Statut (Compatible / Dépendance implicite / Rupture)`.
3. **Tri-Partition des Interventions** :
   - **1. Modifications compatibles** ;
   - **2. Migrations nécessaires** ;
   - **3. Décisions CTO requises**.
4. **Séquence d'Implémentation & de Validation Recommandée** :
   - Ordre étape par étape (du module le plus bas dans le DAG vers le plus haut) et liste exacte des suites de tests à exécuter pour chaque module traversé afin de prévenir toute régression transversale.

