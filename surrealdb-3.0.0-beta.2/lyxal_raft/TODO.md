# LyxalRaft Roadmap & Vision

Ce document récapitule les évolutions technologiques prévues pour transformer LyxalRaft en un protocole de consensus de nouvelle génération, optimisé pour le Cloud et la géo-réplication.

## 🚀 Priorité Haute : Performance & Scalabilité

### [ ] Séparation Log Index / Log Payload (Decoupled Data Plane)
- **Concept :** Le Leader ne réplique que l'ordre des commandes (Index/Metadata) via Raft. La donnée réelle (Payload) est transportée via un canal optimisé.
- **Intégration Lyxal :** Utiliser **Iggy** pour le streaming haute performance des payloads, laissant LyxalRaft agir comme le "Cerveau" de coordination.
- **Impact :** Augmentation massive du débit (throughput) et réduction de la charge sur le consensus.

### [ ] Support de la Sérialisation Zero-Copy (rkyv)
- **Problème :** À très haut débit (>20 000 msg/s), la sérialisation/désérialisation (même avec Bincode) devient un goulot d'étranglement à cause des allocations et copies mémoire.
- **Solution :** Intégrer `rkyv` pour permettre un accès aux données sans copie.
- **Spécification Technique (Issue #479) :**
    - **Le défi :** L'API `RaftNetworkV2::append_entries` actuelle exige des entrées (`Vec<C::Entry>`) déjà désérialisées, ce qui annule les gains de performance de `rkyv`.
    - **Modification proposée :**
        - Introduire `AppendEntriesMeta`, une structure contenant uniquement les métadonnées de la requête (vote, prev_log_id, etc.).
        - Étendre les traits `RaftNetworkV2` et `RaftLogReader` pour manipuler des flux d'octets bruts (`impl AsyncRead + Send`).
        - Le stockage pourra ainsi envoyer les données sérialisées directement à la couche réseau.
- **Impact :** Réduction drastique de la latence et de l'utilisation CPU à très haute charge.

## 🛠️ Optimisations du Protocole

### [ ] Communication RaftCore -> StateMachine via Flux (Stream API)
- **Problème (Issue #1336):** La communication actuelle par lots (`batch`) entre `RaftCore` et la `StateMachine` est bloquante. La lecture des logs et leur application s'interrompent mutuellement, limitant le parallélisme.
- **Solution :** Remplacer l'API de commande par lots par une API de flux unifiée.
- **Spécification :**
    - Toutes les requêtes (`Apply`, `BuildSnapshot`, etc.) transitent par un seul canal/flux.
    - `trait RaftStateMachine { async fn handle_request(Request); }`
- **Impact :** Permet le traitement superposé des I/O (`overlapped I/O`). La `StateMachine` peut effectuer des écritures disque en arrière-plan pendant que `RaftCore` continue de lire les logs, augmentant ainsi considérablement le débit global.

### [ ] Ordonnancement Assoupli des Requêtes (Relaxed Request Ordering)
- **Problème :** La latence des lectures linéarisables (`ReadIndex`) est élevée car une requête de lecture doit attendre que toutes les écritures précédentes soient appliquées à la machine à états.
- **Solution (Issue #1267) :** Ne plus attendre le `CommitIndex` mais le `NoopIndex` (le premier log du terme du leader).
- **Fonctionnement :**
    - Le `ReadIndex` est fixé au `NoopIndex`.
    - Le leader attend que son `AppliedIndex` atteigne ou dépasse le `NoopIndex`.
    - La lecture est alors effectuée immédiatement, sans attendre que toutes les écritures en cours (plus récentes que le `NoopIndex`) soient appliquées.
- **Impact :** Réduction drastique de la latence des lectures sans compromettre la linéarisabilité.

### [ ] Explorer le protocole LeaseGuard pour les lectures linéarisables
- **Contexte (Issue #1651):** Alternative à l'implémentation actuelle de lecture sur bail (basée sur les heartbeats). LeaseGuard est un protocole formellement prouvé (TLA+).
- **Concept:** Le commit d'une entrée de log agit comme un renouvellement de bail pour le leader. Aucun message de prolongation de bail n'est nécessaire.
- **Avantages Potentiels:**
    - **Sécurité:** Résout le problème du "faux leader" (un leader avec disque en panne qui continue de renouveler son bail).
    - **Performance:** Optimise la reprise après panne via des écritures à "validation différée" et des lectures sur "bail hérité".
- **Action:** Évaluer la faisabilité et les gains de performance par rapport à l'approche existante.

### [ ] Leader Stable (Stable Leader - Draft #253)
- **Problème :** Dans Raft, un leader qui détecte un terme supérieur redevient immédiatement suiveur, provoquant une micro-coupure de service.
- **Solution Lyxal :** "Élection Continue" (#167) et suppression de l'état "Candidate" (#252).
- **Fonctionnement :**
    - Le leader ne démissionne pas immédiatement. Il étend son `Vote` en une plage (`vote_span` [v1, v2]).
    - Il continue de répliquer avec l'ancien vote `v1` (qui a un quorum) tout en cherchant à établir un quorum pour le nouveau vote `v2`.
    - Le basculement vers `v2` ne se fait qu'une fois le nouveau quorum atteint.
- **Impact :** Élections sans interruption de service (Zero-downtime election).

### [ ] Suppression du Pre-vote RPC (via Ordre Partiel)
- **Problème :** Éviter les perturbations causées par des nœuds isolés incrémentant inutilement leur terme sans ajouter de RPC Pre-vote complexe.
- **Solution Lyxal :** Utiliser un ordre partiel sur la structure de Vote (Vector Order).
- **Spécification :** Un vote est rejeté si le `effective_leader` local n'a pas encore expiré (heartbeat récent).
- **Impact :** Stabilité accrue lors des partitions réseau avec un protocole plus simple.

## ✨ Améliorations de l'API

### [ ] Type `Batch` personnalisable dans `RaftTypeConfig`
- **Problème (Issue #1625) :** Le type `Batch<T>` est interne et non-personnalisable, ce qui empêche les stratégies d'allocation mémoire avancées (ex: arena allocators, pools).
- **Solution :**
    1. Définir un trait public `RaftBatch<T>`.
    2. Ajouter `type Batch<T>: RaftBatch<T>` à `RaftTypeConfig`.
    3. Fournir l'implémentation actuelle comme défaut via `crate::impls::Batch`.
- **Impact :** Permet aux applications à très haute performance de contrôler entièrement les allocations mémoire pour le traitement par lots.

### [ ] Rendre `ClientWriteResponse.data` Optionnel
- **Problème (Issue #1462) :** L'API actuelle force les implémentations de `StateMachine` à retourner des valeurs de réponse "factices" pour les entrées qui ne génèrent pas de données (ex: `Blank`, `Membership`).
- **Solution :** Changer le champ `data` de `ClientWriteResponse<C>` de `C::R` à `Option<C::R>`.
- **Impact :** Code plus propre et idiomatique en Rust. Les clients peuvent faire la distinction entre "aucune donnée de réponse" et "une donnée de réponse qui est `None`".

### [ ] Refonte de l'API de Gestion des Membres (EnhancedMembership)
- **Problème (Issue #1395):** L'API actuelle de changement de `Membership` a des comportements imprévisibles lors de modifications concurrentes (ex: `retain` s'écrase), et gère mal les opérations mixtes (voter/learner).
- **Solution :** Introduire une nouvelle structure `EnhancedMembership` avec des rôles de nœuds granulaires.
- **Spécification :**
    - **`NodeFunction` :** Définir des capacités atomiques (`Elect`, `Vote`, `AcceptLog`, `LearnLog`) au lieu des rôles monolithiques `Voter`/`Learner`. Un `Voter` standard devient `Elect|Vote|AcceptLog`.
    - **`Member` :** Associer un `NodeId` à un ensemble de `NodeFunction` et à ses informations de connexion (`C::Node`).
    - **`Config` :** Représenter un ensemble de `Member` à un instant T.
    - **`EnhancedMembership` :** Contenir une ou plusieurs `Config` pour gérer les états de transition (`joint-consensus`) de manière explicite et sûre.
- **Impact :** Sémantique claire, opérations atomiques et sûres, et flexibilité pour des configurations de cluster avancées (ex: nœuds dédiés au vote sans stockage de logs).

## 🌍 Cloud-Native & Géo-Distribution (Géo-Réplication)

### [ ] Détecteur de Défaillance Phi Accrual (Phi Failure Detector)
- **Problème :** Les timers Raft statiques sont inadaptés aux latences instables des réseaux mondiaux (WAN).
- **Concept :** Remplacer les timeouts fixes par un calcul de probabilité de défaillance basé sur l'historique des arrivées de signaux de présence (heartbeats).
- **Implémentation :** Définir un seuil de suspicion $\phi$ maximal acceptable pour déclencher une élection.
- **Impact :** Adaptation dynamique à la géo-latence, réduisant les fausses élections tout en restant réactif aux vraies pannes.

### [ ] Détection de Rupture de Connexion (Network Awareness)
- **Concept :** Ne plus dépendre uniquement de l'expiration du délai (timeout), mais détecter activement la perte de connexion TCP/QUIC.
- **Action :** Le leader doit continuer d'envoyer des journaux tant que la connexion est valide ou jusqu'à une erreur explicite, évitant les renvois inutiles de logs déjà appliqués.

### [ ] Quorums Hiérarchiques (Inspiré de ZooKeeper)
- **Concept :** Répartir les nœuds en groupes avec des poids pour assurer la résilience aux pannes de zones entières (Multi-AZ).
- **Quorum :** Majorité de votes dans une majorité de groupes à poids non-nuls.
- **Impact :** Indispensable pour la haute disponibilité à l'échelle d'un continent.

---

## 🧪 Fiabilité & Vérification Formelle

### [ ] Intégration de la Vérification de Modèle avec Stateright.rs
- **Problème :** Valider mathématiquement la correction de l'implémentation Raft au-delà des tests unitaires/d'intégration.
- **Solution (Issue #1598) :** Utiliser `Stateright.rs` pour explorer exhaustivement l'espace des états possibles.
- **Objectifs :**
    - Vérifier les propriétés de **sécurité** (ex: absence de split-brain, cohérence des logs).
    - Vérifier les propriétés de **vivacité** (ex: une élection finit toujours par aboutir).
- **Avantages :** Tests déterministes, reproductibles, et intégrés directement en Rust (plus rapide et plus simple à maintenir que Jepsen).

---

## ⚠️ Risques & Bonnes Pratiques

### Persistance du `committed_index` (Issue #1511)
- **Contexte :** LyxalRaft permet à un leader de conserver son rôle après un redémarrage rapide ("leader survival").
- **Risque :** Si la `StateMachine` est en mémoire et que l'application ne persiste pas l'index des logs commités, le leader peut redémarrer avec un état incomplet. Les lectures externes verront des données incohérentes (anciennes) sans aucune erreur.
- **Contrat d'API Obligatoire :** Toute implémentation de `RaftLogStorage` **DOIT** garantir que l'appel à `save_committed()` persiste l'index de manière durable sur disque **avant** de retourner une confirmation.

---

## ✅ État des Lieux (Audit Terminé)
- [x] **Nettoyage :** Suppression des modules legacy et documentations obsolètes.
- [x] **Rebranding :** Migration complète de `openraft` vers `lyxal_raft`.
- [x] **Modernisation :** Passage à l'édition Rust 2024 et support des dernières syntaxes.
- [x] **Stabilité :** Tous les tests logiques et de macros sont validés.
- [x] **Sécurité :** Correction des panics sur les métriques temporelles.
- [x] **Tests d'Intégration :** Compilation et exécution complètes validées (100% SUCCESS).