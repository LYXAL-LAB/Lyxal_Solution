# Architecture du Cluster LyxalOS x SurrealDB

**Version :** 1.0 (Production Ready)  
**Date :** 26 Janvier 2026

Ce document décrit l'architecture technique de l'intégration du Kernel LyxalOS au sein de SurrealDB. Cette architecture transforme une base de données embarquée en une plateforme distribuée, résiliente et sécurisée ("Scale-Out").

---

## 1. Vue d'Ensemble

L'architecture repose sur trois piliers fondamentaux qui remplacent les dépendances externes historiques :

1.  **LyxalKV (Stockage)** : Moteur LSM-tree transactionnel natif, optimisé pour la persistance et la réplication.
2.  **LyxalNet (Réseau)** : Couche de communication P2P sécurisée (Zero Trust) avec gestion d'identité cryptographique.
3.  **LyxalOS Kernel (Orchestration)** : Cerveau du système gérant le consensus (Raft), la facturation et la synchronisation.

Le système est conçu pour fonctionner en **Single Binary** : tout est inclus dans l'exécutable `surreal`, sans dépendance externe (pas de TiKV ou FoundationDB requis).

---

## 2. Topologie du Cluster

Le cluster Lyxal adopte une architecture hybride **Consensus / Réplication** permettant de concilier cohérence forte et scalabilité massive.

### A. Le Noyau Dur (Core Nodes)
C'est le groupe de serveurs qui participent activement au consensus **Raft**.
*   **Rôle** : Élire le Leader, valider les écritures, garantir la cohérence des données.
*   **Nombre recommandé** : 3 ou 5 nœuds (toujours impair pour éviter les égalités).
*   **Tolérance aux pannes** : Un cluster de 3 nœuds survit à la perte d'un serveur.

### B. Les Nœuds d'Extension (Learner Nodes)
Ce sont des nœuds qui ne participent pas au vote mais reçoivent les données en temps réel.
*   **Rôle** : Servir les requêtes de lecture (SELECT) à très haute vitesse.
*   **Scalabilité** : Illimitée. Vous pouvez ajouter 10, 50 ou 100 nœuds Learners sans ralentir le consensus d'écriture.

---

## 3. Sécurité (Zero Trust)

La sécurité n'est pas une option, elle est native.

### Identité Cryptographique
Chaque nœud possède une paire de clés **Ed25519** persistante (`node.key`).
*   **Node ID** : Dérivé de la clé publique (ex: `946440af...`).
*   **Authentification** : Chaque message réseau est signé et chiffré (ChaCha20-Poly1305).

### Modèle de Confiance (Trust Store)
En production (`LYXAL_PROFILE=prod`), le mode **Strict** est activé.
*   Le fichier `trusted_peers.toml` agit comme une liste blanche.
*   Tout nœud tentant de se connecter sans y être déclaré est immédiatement rejeté.
*   **Outil CLI** : `surreal lyxal trust add <ID> <PUBKEY>` permet d'enrôler un nœud autorisé.

### Résilience Cryptographique
*   **Rotation des Clés** : Les clés de session sont rotatives avec support de transition fluide (Secret Précédent) pour éviter les coupures de connexion.
*   **Filtrage Réseau** : Le protocole ignore les paquets corrompus ou malformés (Bruit réseau) pour éviter les crashs (Self-Healing).

---

## 4. Résilience & Données (LyxalKV)

Le stockage est assuré par **LyxalKV**, un moteur LSM-tree conçu pour la performance.

### Isolation des Données
*   **Données Utilisateur** : Stockées dans le fichier `.db` classique.
*   **Données Système** : Stockées dans un dossier isolé `.lyxos/` (Logs Raft, Identités, Métriques). Cela évite les conflits de verrouillage et facilite les backups.

### Persistance & Recovery
*   **WAL (Write Ahead Log)** : Toutes les opérations sont écrites séquentiellement avant d'être appliquées.
*   **Crash Recovery** : En cas de panne électrique, le système rejoue automatiquement le WAL au redémarrage (testé avec > 90 000 transactions).
*   **Compaction Raft** : Un mécanisme automatique purge les logs de consensus obsolètes pour empêcher la saturation de l'espace disque.

---

## 5. Guide de Configuration

### Variables d'Environnement Clés

| Variable | Description | Valeur Recommandée (Prod) |
| :--- | :--- | :--- |
| `LYXAL_PROFILE` | Mode de fonctionnement | `prod` (Active la sécurité stricte) |
| `LYXAL_BIND_ADDR` | Adresse d'écoute P2P | `0.0.0.0:9000` |
| `LYXAL_SEEDS` | Liste des pairs initiaux | `ip_node1:9000,ip_node2:9000` |
| `LYXAL_DATA_DIR` | Dossier des données système | `path/to/db.lyxos` |

### Tuning Réseau (Latence)
Pour des environnements à latence variable (Cloud, WAN), ajustez les délais Raft pour éviter les élections intempestives :

```bash
export LYXAL_RAFT_ELECTION_MIN_MS=3000  # 3 secondes min
export LYXAL_RAFT_ELECTION_MAX_MS=6000  # 6 secondes max
export LYXAL_RAFT_HEARTBEAT_MS=1000     # Heartbeat chaque seconde
```

---

## 6. Commandes Utiles

L'outil CLI intégré facilite la gestion du cluster.

**Gestion d'Identité :**
```bash
surreal lyxal identity generate --path data/node.key
surreal lyxal identity show --path data/node.key
```

**Gestion de la Confiance :**
```bash
surreal lyxal trust add <NODE_ID> <BASE64_PUBKEY> --output config/trusted_peers.toml
surreal lyxal trust list --path config/trusted_peers.toml
```

**Lancement du Serveur :**
```bash
surreal start --log info --bind 0.0.0.0:8000 lyxalkv://my_database.db
```

---

## 7. Multi-Tenancy & Isolation

L'architecture LyxalOS est conçue pour supporter plusieurs modèles de déploiement multi-clients.

### Option 1 : Isolation Logique (Shared Cluster)
*   **Principe** : Un seul cluster physique partagé par plusieurs clients.
*   **Mise en œuvre** : Utilisation des `Namespaces` SurrealDB. Chaque client possède son espace de noms isolé par RBAC.
*   **Avantage** : Coûts mutualisés, administration centralisée.
*   **Inconvénient** : Isolation des performances non garantie (Noisy Neighbor).

### Option 2 : Isolation Physique (Dedicated Realm)
*   **Principe** : Déploiement d'un cluster dédié (3 nœuds) pour un client spécifique.
*   **Mise en œuvre** : Configuration d'un `LYXAL_REALM_ID` unique et d'un `trusted_peers.toml` spécifique ne contenant que les nœuds du client.
*   **Sécurité** : Totale. Le protocole réseau LyxalNet rejette tout paquet ne correspondant pas au Realm ID, assurant une étanchéité cryptographique même sur un réseau partagé.

### Option 3 : Hybride (Edge / Learner)
*   **Principe** : Un cluster central (Core) alimente des nœuds distants (Learners) installés chez le client.
*   **Mise en œuvre** : Le nœud client est ajouté comme pair de confiance mais ne participe pas au vote Raft. Il synchronise les données en temps réel.
*   **Avantage** : Latence de lecture nulle pour le client (données locales), souveraineté des données possible via filtres de réplication.
