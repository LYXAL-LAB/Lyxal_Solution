# lyxal_core_db

## Rôle
Crate contenant le moteur de base de données Lyxal. C'est le composant principal du projet, responsable de l'analyse (parsing) du LyxalQL, de l'exécution des requêtes, de la gestion de l'état, de l'indexation et du stockage abstrait (KV).

## Ce qu'il contient
- **`syn/`** : Le parseur LyxalQL (Lexer, Parser, AST).
- **`sql/`** : L'arbre syntaxique abstrait (AST) complet.
- **`dbs/`** : L'environnement d'exécution, la gestion des transactions, des triggers et des événements.
- **`kvs/`** : La couche d'abstraction Key-Value (sur laquelle se pluggent les différents backends comme Mem, RocksDB, TiKV).
- **`val/`** : Représentation interne des valeurs Lyxal (Nombres, Chaînes, Géométrie, Objets).
- **`idx/`** : L'implémentation des algorithmes d'indexation (B-Tree, Full-Text, Vecteurs).
- **`iam/`** : Gestion des accès, rôles, utilisateurs, et authentification (Sign in/Sign up, Tokens).

## Structure des sous-composants
Pour alléger ce composant gargantuesque, plusieurs utilitaires ont été isolés :
- Configuration : `lyxal_core_config`
- Télémétrie : `lyxal_core_telemetry`
- Utilitaires purs : `lyxal_core_utils`
- Types contrats : `lyxal-types`
- Erreurs : `lyxal_core_error`

## Variables d'environnement supportées
Voir le module `lyxal_core_config`.

## Utilisé par
`lyxal_server` (l'exécutable) injecte ce moteur au cœur du système.
