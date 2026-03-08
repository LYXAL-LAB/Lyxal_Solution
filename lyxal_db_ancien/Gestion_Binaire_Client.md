# Architecture Lyxal : Pilotage des Binaires Clients (Worker Mode)

Ce document définit comment le **Kernel Lyxal OS** orchestre et gère des instances clientes s'exécutant dans des binaires (processus) séparés.

---

## 1. Le Modèle d'Orchestration "Hyperviseur"

Lorsque Lyxal est configuré pour l'isolation maximale (Mode Enterprise), le Kernel ne se contente plus de gérer des threads. Il agit comme un hyperviseur de processus.

| Rôle | Entité | Responsabilité |
| :--- | :--- | :--- |
| **Maître** | `lyxal_os` (Kernel) | Sécurité globale, Identity Provider, Routage, Cycle de vie des binaires. |
| **Esclave** | `lyxal_worker` (Client) | Moteur SurrealDB dédié, protocoles (DAV/Email), stockage privé du Realm. |

---

## 2. Mécanisme de Lancement (Process Spawning)

Le Kernel utilise la gestion de processus native de l'OS (via `std::process::Command`) pour instancier un worker.

### Paramètres de lancement :
Lors du spawn, le Kernel transmet les identifiants critiques au binaire client :
* `--realm-id` : Identifiant unique de l'instance client.
* `--storage-path` : Chemin vers le dossier `lyxalkv` privé du client.
* `--ipc-path` : Chemin vers la socket ou le pipe de communication privée.

---

## 3. Communication Inter-Processus (IPC)

La liaison entre le Kernel et le binaire client est assurée par une couche de communication ultra-rapide (Internal Pipeline).

### Flux de contrôle :
1. **Routage** : Le Kernel reçoit une requête réseau (ex: port 443) et l'aiguille vers la socket IPC du binaire client concerné.
2. **Heartbeat** : Le binaire client envoie un signal régulier de "santé" au Kernel.
3. **Logs** : Les flux `stdout/stderr` du client sont capturés par le Kernel pour centraliser la télémétrie.

---

## 4. Transit d'Identité et Sécurité

C'est le point le plus important pour garantir l'intégrité du système.

1. **Validation Centrale** : L'utilisateur s'authentifie auprès du Kernel (Identity Provider Natif).
2. **Génération de Context** : Le Kernel génère un objet `SecurityContext` (Permissions, NS, DB).
3. **Injection IPC** : Ce contexte est "injecté" dans la commande envoyée au binaire client. 
4. **Exécution Isolée** : Le binaire client exécute la requête dans son propre espace mémoire, mais avec la garantie d'identité fournie par le Kernel.

---

## 5. Gestion des Pannes et Résilience

L'isolation par binaire permet une tolérance aux pannes supérieure :
* **Détection de Crash** : Si un binaire client subit une `panic!`, seul ce client est impacté.
* **Auto-Restart** : Le Kernel détecte la fin anormale du processus et peut relancer une nouvelle instance du binaire client instantanément.
* **Mises à jour à chaud** : Il est possible de redémarrer le binaire d'un seul client pour appliquer un patch sans couper le service pour les autres.

---

## 🎯 Conclusion

L'utilisation de binaires séparés transforme Lyxal en une plateforme **Cloud Native Multi-processus**. Cette architecture garantit qu'aucun client ne peut corrompre la mémoire ou les performances d'un autre, tout en conservant une gestion centralisée via le Kernel Rust.

---
*Document de référence généré pour la définition du pilotage processus de Lyxal Solution.*
