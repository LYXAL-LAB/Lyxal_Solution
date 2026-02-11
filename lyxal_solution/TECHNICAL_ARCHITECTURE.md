# Architecture Technique : Le Noyau Lyxal

## 1. La Couche de Persistance : Lyxalkv
Le remplacement de RocksDB et TiKV par **lyxalkv** est l'acte fondateur de l'indépendance de Lyxal.
- **Moteur LSM & VLog** : Optimisé pour des écritures massives et des lectures instantanées.
- **Atomicité des Flows** : Les automations sont persistées dans les mêmes segments que les données pour garantir qu'un workflow ne "perd" jamais son état.

## 2. Le Moteur de Flow Natif (Bye-Bye n8n)
Lyxal n'intègre pas n8n, il en **absorbe la substance**. 
- **Graph execution** : Un moteur de graphe asynchrone codé en Rust.
- **Zero-Copy Data** : Les données circulent entre les nœuds du flow sans sérialisation JSON inutile.
- **Intrinsics** : Les "nœuds" sont des fonctions Rust natives ou des modules WASM isolés.

## 3. L'Hyper-Convergence des Moteurs
Lyxal unifie les besoins backend en une seule adresse mémoire :
- **RTC Engine** : Gestion native des flux temps réel (Collaboration, Chat, Signaux).
- **Scheduler Engine** : Planification de tâches intégrée aux transactions.
- **WebDAV Engine** : Gestion des fichiers comme des objets de base de données.
- **Webhook Engine** : Points d'entrée sécurisés et mappés sur des Flows.

## 4. Stratégie "Core + Extensions"
Pour garantir la stabilité sans brider l'innovation :
- **Structure Figée (The Contract)** : Les tables critiques (CRM Core, Auth, Logs) ont des schémas contractuels pour garantir que les IAs et les intégrations externes ne cassent jamais.
- **Espaces Extensibles (The Flexibility)** : Chaque domaine peut étendre ces objets via des champs dynamiques gérés nativement par le moteur multi-modèle de Lyxal.
