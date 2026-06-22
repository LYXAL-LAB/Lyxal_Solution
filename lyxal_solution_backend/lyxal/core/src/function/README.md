# lyxal_core_functions

## Rôle
Crate contenant **toutes les fonctions natives LyxalQL** fournies avec la base de données Lyxal Solution. 

Ce crate étend le moteur central (`lyxal_core_db`) avec des bibliothèques de traitement de données (mathématiques, cryptographie, chaînes de caractères, géomatique, etc.) pour éviter d'alourdir le cœur d'exécution SQL avec du code métier.

## Ce qu'il contient
Chaque fichier dans `src/` correspond à un namespace de fonction LyxalQL :
- `math.rs` : Fonctions `math::*` (abs, ceil, floor, pi, sin, cos).
- `string.rs` : Fonctions `string::*` (concat, len, lowercase, split, replace).
- `crypto.rs` : Fonctions `crypto::*` (md5, sha256, bcrypt, argon2).
- `time.rs` : Fonctions `time::*` (now, format, group, timezone).
- `geo.rs` : Fonctions spatiales `geo::*` (distance, area, point).
- `array.rs` : Opérations sur les tableaux (append, len, sort, distinct).
- `http.rs` : Requêtes web sortantes via `reqwest` (get, post, patch).

## Pourquoi un crate séparé ?
Dans l'architecture Bubble.io-like de Lyxal Solution, c'est ce crate qui implémente **les "Actions" standards accessibles à l'utilisateur**. En les sortant de `lyxal_core_db`, le binaire `lyxal_server` peut injecter ce registre de fonctions au moment du démarrage, gardant la base de données agnostique des fonctions de haut-niveau.

## Utilisé par
Ce crate est consommé par `lyxal_server` pour enregistrer les fonctions dans le contexte d'exécution de `lyxal_core_db` (`dbs::Context`).
