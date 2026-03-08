# Étude Technique : La Notion d'Instance dans SurrealDB (Source Audit)

Ce document synthétise la structure interne de SurrealDB concernant le concept d' "Instance", tel qu'identifié dans le code source du fork (v3.0.0-beta.2).

---

## 1. Définition Conceptuelle
Dans l'architecture native de SurrealDB, une "instance" est la représentation logique et physique d'un moteur de base de données en cours d'exécution. Techniquement, cela se matérialise par le binaire (`surreal.exe`) qui, une fois lancé, initialise un environnement de stockage et de calcul.

---

## 2. Les Trois Piliers de l'Instance (Niveau Code)

D'après l'audit du code source, la notion d'instance se décompose en trois structures majeures :

### A. L'Identité Cluster : Le `Node` (`dbs/node.rs`)
C'est le niveau le plus "physique". Un **Node** représente une instance de calcul unique au sein d'un cluster.
* **Attributs** : Uuid unique, Heartbeat (battement de cœur).
* **Rôle** : Identifier cette exécution précise parmi d'autres serveurs pour permettre la réplication (Raft) et la haute disponibilité.

### B. Le Moteur Logique : Le `Datastore` (`kvs/ds.rs`)
C'est ce que SurrealDB considère comme l'**Instance de base de données**.
* **Structure** : `pub struct Datastore { ... }`.
* **Rôle** : C'est le cerveau qui gère les transactions, les verrous (locks) et l'accès au Key-Value Store (`lyxalkv`). 
* **Unicité** : En usage standard, un binaire lancé = une instance de `Datastore`.

### C. Le Conteneur Suprême : Le `ROOT`
C'est le niveau logique le plus élevé. Dans SurrealDB, **le niveau ROOT englobe directement les Namespaces (NS)**.
* Il n'y a rien au-dessus des Namespaces, à l'exception de l'Instance elle-même.
* L'accès au niveau "Instance" est réservé aux **Root Users**, qui ont une visibilité totale sur tous les Namespaces.

---

## 3. Hiérarchie de l'Englobement (Conteneurs)

Le modèle de données suit cet emboîtement strict, où l'instance agit comme la racine de l'arbre :

1. **Instance (Datastore / Node)**
   └── **Namespace (NS)** : Conteneur logique de premier niveau.
       └── **Database (DB)** : Regroupement de données métier.
           └── **Table** : Structure de données.
               └── **Record** : Donnée finale.

---

## 4. Distinction entre Binaire et Instance

Il est crucial de différencier le fichier physique de son exécution :
* **Le Binaire** : C'est le programme compilé en Rust.
* **L'Instance** : C'est le binaire en état de marche, possédant son propre identifiant (`NodeID`) et ses propres ressources système (mémoire, descripteurs de fichiers).

---

## 🎯 Conclusion pour Lyxal
Comprendre que SurrealDB ne voit rien au-dessus du Namespace permet de valider la stratégie de Lyxal :
Le **LyxalOS (Kernel)** doit se situer au niveau du binaire pour orchestrer plusieurs "Instances" (Realms) de manière isolée, chacune gérant ses propres Namespaces.

---
*Document de référence généré suite à l'audit du code source de SurrealDB.*
