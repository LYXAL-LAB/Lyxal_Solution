# Architecture Lyxal : Isolation et Performance (Threads vs Processus)

Ce document traite de l'évolution du modèle d'exécution de Lyxal : du partage de binaire vers la segmentation par processus isolés.

---

## 1. Comparaison Technique : Threads vs Processus

| Critère | Modèle Binaire Unique (Threads) | Modèle Binaires Séparés (Processus) |
| :--- | :--- | :--- |
| **Isolation Système** | Faible. Une panique (`panic!`) Rust ou une fuite mémoire impacte tout le serveur. | Maximale. Un crash dans un Realm n'affecte pas les autres. |
| **Performance CPU** | Risque de "Noisy Neighbor" : un client lourd ralentit les autres. | Puissance garantie via le scheduling de l'OS (cgroups, affinité CPU). |
| **Gestion Mémoire** | Partagée. Risque de fragmentation et de saturation globale. | Dédiée. Chaque processus a son propre espace d'adressage virtuel. |
| **Sûreté** | Un pirate peut potentiellement lire la RAM globale de l'instance. | Barrière physique. Impossible de lire la mémoire d'un processus tiers. |

---

## 2. Le Modèle "Worker" pour Lyxal OS

Pour offrir une isolation de grade industriel tout en gardant une orchestration centrale, Lyxal doit évoluer vers une architecture à deux binaires :

### A. Le Kernel (Binaire Maître)
* **Rôle** : Orchestrateur, Gestionnaire d'Identité globale, Consensus Raft.
* **Tâche** : Surveille la santé des processus enfants et gère le routage réseau.

### B. Le Worker (Binaire d'Exécution)
* **Rôle** : Instance légère contenant uniquement le moteur SurrealDB et les modules de protocole (DAV, Email).
* **Tâche** : Se lance à la demande pour un Realm spécifique (`lyxal_worker --realm-id 123`).

---

## 3. Stratégie de Déploiement Hybride

Pour concilier rentabilité et performance, Lyxal adopte une approche à deux vitesses :

1. **Lyxal Standard (Vibe Coding / PME)** :
   * Plusieurs Realms tournent sous forme de threads dans un même processus.
   * C'est le modèle le plus économique en ressources (consommation RAM optimisée).

2. **Lyxal Enterprise / Sovereign (Grands Comptes / Secteur Sensible)** :
   * Chaque Realm est "spawné" dans un processus (binaire) totalement indépendant.
   * Permet de garantir des SLAs (Service Level Agreements) de performance et une sécurité "Air-Gap" logicielle.

---

## 4. Conclusion Stratégique

Le passage au multi-processus transforme Lyxal d'une application distribuée en un véritable **Hyperviseur de Données**. 

Cela permet de vendre la même technologie sous deux formes :
* Un **SaaS Mutualisé** performant.
* Un **Cloud Privé** avec isolation physique garantie, répondant aux exigences de souveraineté les plus strictes en France.

---
*Document de référence généré pour la définition technique du Lyxal_Core.*
