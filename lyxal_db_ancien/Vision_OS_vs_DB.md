# Lyxal Architecture : De la Base de Données au Cloud OS (Vision Google)

Ce document définit le changement de paradigme nécessaire lors du développement du **Lyxal_Core**. Il explique pourquoi des dossiers qui semblent "purement DB" dans SurrealDB sont en réalité les piliers d'un Système d'Exploitation distribué.

---

## 🚀 Le Concept : Logiciel vs Infrastructure

Un logiciel de base de données stocke des données. Un **Cloud OS** (comme ce que Google a bâti avec Spanner/Borg) gère des **capacités**. Lyxal transforme SurrealDB en ce moteur de capacités universel.

---

## 🔍 Analyse des Composants : Perspective OS

### 1. `ctx` (Context) — Le "Passeport" de l'OS
*   **Vision DB Classique** : Gérer le timeout d'une requête SQL.
*   **Vision Lyxal (Google-like)** : C'est le **Propagateur d'Identité et de Tracing**.
    *   Le contexte transporte l'identité native Lyxal, les permissions du Realm et le traçage à travers tous les modules (DAV, Email, IA).
    *   *Utilité* : Une action initiée sur mobile (DAV) est reconnue par l'Agent IA comme appartenant au même contexte utilisateur, sans latence ni ré-authentification.

### 2. `cf` (Change Feed) — Le "Système Nerveux"
*   **Vision DB Classique** : Lister les lignes modifiées dans une table.
*   **Vision Lyxal (Google-like)** : C'est le **Distributed Event Bus**.
    *   Ce n'est plus une option de log, c'est le déclencheur d'actions.
    *   *Utilité* : Si l'IA écrit une donnée dans SurrealDB, le module `lyxal_email` "réagit" instantanément via le Change Feed pour notifier l'utilisateur. C'est la base de la réactivité de l'OS.

### 3. `dbs` (Datastore) — L'Orchestrateur de Ressources
*   **Vision DB Classique** : Gérer les fichiers sur le disque local.
*   **Vision Lyxal (Google-like)** : C'est le **Cerveau des Realms**.
    *   Il ne gère pas des fichiers, mais des **Nœuds** et des **Silos**.
    *   *Utilité* : C'est ici que l'OS décide sur quelle machine physique se trouve le Realm d'un client sensible et route l'opération en conséquence (Hybrid Multi-tenancy).

### 4. `doc` (Document) — Le "Gestionnaire de Cycle de Vie"
*   **Vision DB Classique** : Valider les types de colonnes (String, Int).
*   **Vision Lyxal (Google-like)** : C'est le **Garant de la Logique Métier (Vibe Coding)**.
    *   Il ne valide pas seulement des données, il valide l'état d'une application "sans code".
    *   *Utilité* : Si un utilisateur "vibe-code" une application de RH, c'est le module `doc` qui garantit nativement (au niveau du Kernel) qu'un contrat ne peut pas exister sans employé.

---

## 🏛️ Pourquoi ces briques doivent rester dans le "CORE" ?

Google garde ces briques au plus bas niveau pour éviter les **silos**. En intégrant ces fonctions dans le noyau Lyxal :
1.  **L'Identité (IAM)** est omniprésente.
2.  **Le Temps Réel (CF)** est une garantie système.
3.  **L'Isolation (DBS/Realms)** est physique et indiscutable.

## 🎯 Conclusion : Lyxal comme "Object Execution Engine"

Lyxal_Core ne doit pas être perçu comme un endroit où l'on range des tables, mais comme un moteur qui exécute des **Objets Intelligents**.
*   Le **DAV** et l'**Email** ne sont que des protocoles d'accès (interfaces).
*   L'**IA** est le manipulateur.
*   Le **Core** est la seule source de vérité, de sécurité et de persistance.

---
*Document de vision stratégique pour Lyxal Solution.*
