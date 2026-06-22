# lyxal_core_rpc

## Rôle
Crate contenant la logique applicative RPC (Remote Procedure Call) de Lyxal. Il fait le pont entre les protocoles de transport (WebSocket, HTTP) et le moteur de base de données (`lyxal_core_db`).

## Ce qu'il contient
- **`mod.rs`** : Point d'entrée définissant les handlers de méthodes RPC.
- **`protocol.rs`** : Définition du trait `RpcProtocol` qui régit l'exécution des commandes.
- **`request.rs`** / **`response.rs`** : Structures de données pour les requêtes et réponses RPC (dont `DbResponse`).
- **`error.rs`** : Mapping des erreurs internes vers des codes d'erreur RPC.
- **`method/`** : Énumération des méthodes supportées (Ping, Query, Auth, etc.).

## Structure des sous-composants
- Dépend du moteur : `lyxal_core_db`
- Dépend de la couche de stockage : `lyxal_core_kvs`
- Utilise les types de base : `lyxal-types`

## Utilisé par
`lyxal_server` utilise ce crate pour traiter les messages arrivant via les interfaces réseau et les transformer en appels au moteur de base de données.
