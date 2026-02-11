# Architecture & Hiérarchie Lyxal

Ce document détaille le fonctionnement interne et la hiérarchie des composants Lyxal intégrés dans ce fork de SurrealDB.

## 1. La Hiérarchie en Couches (The Layer Cake)

L'architecture est conçue comme une série de couches s'appuyant les unes sur les autres. Du plus bas niveau au plus haut :

### Niveau 0 : Les Fondations (`lyxal_sync` & `lyxal_revision`)
*   **`lyxal_sync`** : Contient les primitives de bas niveau pour la synchronisation (horloges logiques, enveloppes de messages protocolaire). C'est le "vocabulaire" commun de tous les composants distribués.
*   **`lyxal_revision`** : Une bibliothèque de gestion de versions sémantiques et chronologiques. Elle remplace la crate `revision` standard pour offrir des capacités de "Time Travel" plus fines.

### Niveau 1 : Le Stockage (`lyxalkv`)
*   **Rôle** : Moteur de stockage clé-valeur (KV Store) basé sur un LSM-Tree (Log Structured Merge Tree).
*   **Particularité** : Il est optimisé pour séparer les clés (index) des valeurs (données) via un **Value Log (VLog)**, ce qui améliore considérablement les performances pour les grosses valeurs (blobs, documents JSON).
*   **Intégration** : Il est "pluggé" dans SurrealDB comme une alternative à RocksDB ou TiKV.

### Niveau 2 : Le Réseau (`lyxal_net`)
*   **Rôle** : Gère la communication Peer-to-Peer (P2P) chiffrée.
*   **Fonctionnement** : Chaque nœud possède une identité cryptographique (`NodeIdentity`). `lyxal_net` établit des tunnels sécurisés entre les nœuds pour échanger des messages de consensus ou de réplication de données.

### Niveau 3 : Le Cerveau (`lyxal_os` - Kernel)
*   **Rôle** : C'est le système d'exploitation distribué. Il orchestre tout.
*   **Responsabilités** :
    *   **Consensus (Raft)** : Assure que tous les nœuds sont d'accord sur l'état du système (qui est leader ? qui a le droit d'écrire ?).
    *   **Multi-tenance (Realms)** : Isole les environnements clients (comme des machines virtuelles légères).
    *   **Facturation (Ledger)** : Enregistre chaque consommation de ressource de manière immuable et auditable.
    *   **Sécurité (Policies)** : Vérifie les droits avant toute action critique.

### Niveau 4 : L'Application (`surrealdb`)
*   **Rôle** : Le serveur de base de données que l'utilisateur interroge (SQL, WebSocket).
*   **Relation** : Dans l'architecture Lyxal complète, SurrealDB est une "application" qui tourne *au-dessus* du Kernel `lyxal_os`. Le Kernel fournit à SurrealDB son stockage (`lyxalkv`) et son réseau (`lyxal_net`).

---

## 2. Diagramme d'Architecture

```mermaid
graph TD
    subgraph User Space
        Client[Client SurrealQL/HTTP]
    end
    
    subgraph Admin Space
        AdminUI[Interface Admin / Dashboard]
    end

    subgraph "SurrealDB Process (The Body)"
        API[API Server]
        Query[Query Engine]
    end

    subgraph "LyxalOS Kernel (The Brain) - Actuellement Éteint"
        Consensus[Consensus Manager (Raft)]
        Ledger[Accounting & Billing]
        RealmMgr[Realm Manager]
        SyncService[Sync Service]
    end

    subgraph "Infrastructure Layer"
        LyxalKV[(LyxalKV Storage)]
        LyxalNet[LyxalNet P2P]
    end

    Client --> API
    API --> Query
    Query --> LyxalKV
    
    %% Admin Gestion
    AdminUI -.->|Gère| RealmMgr
    AdminUI -.->|Audite| Ledger
    
    %% Ce lien est manquant actuellement
    Consensus -.->|Contrôle| API
    Ledger -.->|Audite| Query
    SyncService --> LyxalNet
    LyxalNet -->|Replication| LyxalNetPeer[Autre Nœud]
    
    classDef inactive fill:#f9f,stroke:#333,stroke-dasharray: 5 5;
    class Consensus,Ledger,RealmMgr,SyncService,LyxalNet inactive
```

> **Note** : Les boîtes en pointillés (roses) représentent les composants présents dans le code mais actuellement inactifs (`lyxal_os` et `lyxal_net`).

---

## 3. Le Fonctionnement Prévu vs Actuel

### Flux de Données Prévu (Architecture Cible)
1.  **Boot** : Le `Kernel` démarre, charge son identité, rejoint le cluster via `lyxal_net`.
2.  **Requête** : Un client envoie une requête `CREATE account SET ...`.
3.  **Vérification** : Le `Kernel` intercepte l'action, vérifie le solde du client dans le `Ledger`.
4.  **Exécution** : Si autorisé, la requête est passée au moteur `surrealdb` qui écrit dans `lyxalkv`.
5.  **Audit** : L'écriture déclenche un événement de facturation enregistré dans le `Ledger` immuable.

### Flux de Données Actuel (Architecture Partielle)
1.  **Boot** : `CommunityComposer` démarre uniquement le serveur `surrealdb`. **Le Kernel ne s'allume pas**.
2.  **Requête** : Le client envoie une requête.
3.  **Exécution** : Le moteur écrit directement dans `lyxalkv` sans supervision du Kernel.
4.  **Absence** : Aucune facturation, aucun consensus distribué, aucune réplication P2P.

## 4. Glossaire & Concepts

*   **Nœud (Node)** : Une instance unique du programme `surrealdb` en cours d'exécution (ex: un serveur, un conteneur Docker). Chaque nœud possède :
    *   Une **Identité** (paire de clés cryptographiques) stockée dans `identity.pem`.
    *   Son propre stockage local sur disque (`lyxal_kernel.kv`).
    *   Une connexion réseau aux autres nœuds pour former un **Cluster**.

*   **Cluster** : Un ensemble de plusieurs **Nœuds** interconnectés qui travaillent ensemble. Grâce au protocole de consensus (Raft), ils agissent comme un système unique et cohérent. Si un nœud tombe en panne, le cluster continue de fonctionner.

*   **Realm (Royaume)** : L'unité d'isolation suprême. Un Realm contient ses propres données, utilisateurs et quotas. C'est l'équivalent d'un "Container" pour la base de données.

*   **Ledger (Grand Livre)** : Le journal comptable du système. Contrairement aux logs classiques, il est conçu pour être une preuve financière irréfutable.

*   **VLog (Value Log)** : Technique de stockage de `lyxalkv` où les grosses données sont écrites séquentiellement dans un fichier journal (log) plutôt que dans l'arbre d'index (LSM Tree), réduisant la fragmentation et augmentant la vitesse d'écriture.

## 5. Le Paradoxe du Kernel "Distribué"

Vous avez demandé : *"Comment les nœuds peuvent être gérés par LyxalOS si celui-ci est déployé partout ?"*

C'est là que réside la magie des **Systèmes Distribués** et de l'algorithme **Raft**.

1.  **Chaque nœud a le code** : Chaque instance de SurrealDB contient le code de `lyxal_os`. Tout le monde a la capacité d'être le chef.
2.  **L'Élection (Le Vote)** : Au démarrage, les nœuds discutent entre eux automatiquement. Ils votent pour élire un **Leader** (Chef).
3.  **Le Chef Décide (Leader)** : Un seul nœud devient le Leader. C'est "son" Kernel qui prend les décisions pour tout le monde (créer un utilisateur, valider une facture).
4.  **Les Autres Suivent (Followers)** : Les autres nœuds se mettent en mode "Suiveur". Leur Kernel est actif mais il ne fait qu'obéir aux ordres du Leader.

Si le Leader tombe en panne (crash serveur), les Suiveurs le détectent en quelques millisecondes et élisent un nouveau Leader automatiquement. Ainsi, le système se gère lui-même sans avoir besoin d'un "serveur maître" séparé.

## 6. Multi-Tenance : Le modèle "Surreal Cloud"

Pour répondre à votre question sur les "instances propres" (isolées) pour chaque client :

*   **Physique (Infrastructure)** : Vous avez un Cluster de N serveurs (identiques, partagés).
*   **Logique (Client)** : Quand un client veut une instance, LyxalOS crée un **Realm**.

Un **Realm** n'est **PAS** un nouveau serveur physique. C'est un espace virtuel isolé *à l'intérieur* de votre cluster existant.
*   Il a sa propre sécurité.
*   Il a ses propres données.
*   Il a ses propres quotas (CPU/RAM/Disque).

**Analogie :**
*   Le Cluster est un **Immeuble** (L'infrastructure, gérée par LyxalOS).
*   Le Realm est un **Appartement** (L'instance client).

Surreal Cloud fait exactement cela : ils ne construisent pas un nouvel immeuble pour chaque locataire. Ils attribuent simplement un nouvel appartement (Realm) dans l'immeuble existant. C'est ce qui permet d'avoir des milliers de clients sur quelques serveurs.

### Le Cas des "Instances Payantes"

Même pour une instance payante, il est très rare d'avoir un serveur physique exclusif (trop cher, difficile à gérer). Différencier une instance "Gratuite" d'une "Payante" se fait par **Plan de Service (Policy Plan)** :

1.  **Quota** : L'instance payante a le droit à 16Go RAM et 1M requêtes/sec, l'instance gratuite a 512Mo et 10 requêtes/sec.
2.  **Priorité** : Le "Kernel" LyxalOS traite les requêtes des Realms payants en priorité.
3.  **Placement (Optionnel)** : On peut configurer le système (Taints/Tolerations) pour dire "Ce groupe de 3 serveurs physiques est réservé aux clients VIP". LyxalOS placera alors les Realms "Payants" uniquement sur ces machines.

## 7. L'Interface d'Administration (Le Cockpit)

Pour gérer cette complexité, **il faut absolument une interface dédiée** (Control Plane).

*   **Surrealist (Client)** : C'est l'interface pour le *Locataire*. Il voit ses tables, ses requêtes, ses données. Il ne sait pas qu'il est dans un "Realm".
*   **Lyxal Dashboard (Admin)** : C'est l'interface pour le *Propriétaire de l'Immeuble* (l'équipe Surreal/Ops). Elle permet de :
    *   Créer/Supprimer des Realms.
    *   Voir l'état de santé du Cluster (qui est Leader ?).
    *   Vérifier la facturation globale (Ledger).
    *   Mettre à jour les politiques de sécurité (Policies).

Sans cette interface "Admin", LyxalOS est une boîte noire difficile à piloter.
