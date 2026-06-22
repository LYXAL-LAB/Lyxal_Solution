# Architecture Globale "Lyxal Solution" (Vision Cloud & NoCode)

## 1. La Vission Produit ("Le Bubble.io Auto-Hébergé")
`Lyxal Solution` n'est pas "juste" une base de données ou un proxy. Le but final est d'offrir une plateforme monolithique, auto-hébergeable et sans dépendances externes complexes. L'utilisateur final installe Lyxal, et il obtient un "Backend-As-A-Service" (BaaS / PaaS) complet : Base de Données, Reverse-Proxy haute performance, Identité (Auth) et Fonctionnel (WebAssembly).

L'utilisateur final n'a **pas** besoin de toucher au code de ces briques : il interagit avec elles via une interface ou des flux haut niveau.

## 2. Le Paradigme de Découpage ("Core" vs "Apps")
Pour rendre cette vision compilable en Rust sans que tout s'emmêle (Dependency Hell), on utilise un pattern de Cargo Workspace très strict, basé sur le niveau d'importance et la responsabilité métier du composant.

### A. Le Dossier `/core/` (L'Essentiel, le Moteur Intouchable)
C'est le "chef d'orchestre" de la plateforme. L'utilisateur final ne modifie jamais ce code. Ce sont les rouages profonds de Lyxal.
- `lyxal_server` : Le binaire maître qui coordonne tout. S'il plante, la plateforme est morte.
- `lyxal_db` : L'évaluateur SQL natif (ex-Lyxal purifié). C'est le cerveau des données.
- `lyxal_core_kvs` : L'arbre de stockage SSD/RAM brut en dessous de la base de données.
- `lyxal_function` : La librairie native (compilée avec la DB) qui contient les appels vitaux comme `proxy::ingress::add()` (dialogue avec Sōzu). Sans lui, le Server ne peut pas orchestrer l'infrastructure.

### B. Le Dossier `/apps/` (Les Services Métiers Optionnels)
Ce sont les "Applications cloud" qui font la richesse de l'écosystème. L'utilisateur peut choisir de les activer pour son projet SaaS ou non.
- `lyxal_proxy` : L'application pare-feu et routeur L4/L7 hyper-rapide (Basé sur Sōzu).
- `lyxal_identity` : L'application gestionnaire d'authentification complète (inspirée de Logto / Auth0).
- `lyxal_lism` : L'application Serveur Cloud Run (WASM). C'est le module qui permet aux utilisateurs de téléverser et d'exécuter leur **propre logique métier** (`.lyxli`) sans jamais pouvoir faire crasher le moteur SQL `core`. C'est le "Cloud Function".

### C. Le Dossier `/shared/` (L'Infrastructure Partagée)
Pour que l'intégralité des `/core/` et `/apps/` ressemblent à un produit unique aux yeux de l'utilisateur, ils *"boivent tous à la même fontaine"* technologique :
- `lyxal_telemetry` : Permet au Server, au Proxy et à Identity de générer des logs unifiés.
- `lyxal_config` : Permet au Server, au Proxy et à Identity de lire le même `.env` maître.
- `lyxal_allocator` : Gestions des allocations RAM (Jemalloc) forçant tout le binaire à utiliser les mêmes conventions.
- `lyxal_bucket` : Système commun de stockage de fichiers physiques (Local/S3).

### D. Le Dossier `/types/` (Les Contrats inter-services)
L'interface de politesse. Pour que des processus IPC ou WASM discutent sans recréer leurs structures.
- `lyxal-types` : Primitives d'objets, tableaux, et Records de Lyxal.
- `lyxal_types_proxy` : Fichiers `.proto` compilés permettant de communiquer avec Sōzu via Sockets.
- `lyxal_types_lism` : Pont mémoire FlatBuffers pour la transmission ultra-rapide en WASM.

### E. Le Dossier `/utils/` (La Boîte à Outils des Développeurs)
Crates servant uniquement d'aide à la compilation du reste du monorepo.
- `lyxal_macros` : Macros génératrices de code (ex: `#[lyxal_lism]`).
- `lyxal_errors` : Catalogue centralisant tous les types d'erreurs textuelles (`Cannot parse SQL`, etc.) pour tout Lyxal Solution. 

## 3. Règle d'Or des Dépendances
- Le niveau *Types* et *Utils* ne dépend de personne.
- Le niveau *Shared* dépend uniquement de *Types*.
- Le niveau *Core* dépend de tout le monde en dessous de lui, mais **JAMAIS** des *Apps*.
- Le niveau *Apps* **n'englobe JAMAIS** le *Core*. Il lui envoie simplement des paquets IPC ou réseaux.
