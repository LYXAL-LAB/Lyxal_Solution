# Preuves de la phase B

Ces fichiers consignent une exécution réelle dans l'environnement cloud, sans constituer
une certification ni une qualification de stockage. Les chemins absolus des commandes
désignent cet environnement ; le conducteur `../tools/validate.py` les recalcule ailleurs.

- `checks.json` : commandes, durées, codes de sortie ; logs correspondants pour chaque contrôle.
- `source-sha256.json` : empreintes des sources Rust et manifests/verrous concernés.
- `dependency-features.txt` : fonctionnalités résolues du crate, avec les dépendances de test.
- `Cargo.lock.diff` : seules arêtes autorisées du verrouillage racine.
- `rustsec*.json` : sorties JSON cargo-audit ; aucun ignore ni avertissement accepté.
- `rustsec-projection.lock` : projection d'audit uniquement, jamais utilisée pour compiler.
  Sa liste de packages et l'empreinte du verrou d'origine figurent dans le JSON associé.
- `fuzz-*.json` et `fuzz-*.log` : campagnes finales et leurs véritables sorties.
  Les premiers essais bloqués par l'environnement sont nommés `fuzz-initial-sandbox-*`.

Outils : Rust courant 1.99.1 ; MSRV 1.85.0 ; cargo-fuzz 0.13.2 ; libfuzzer-sys 0.4.13 ;
nightly 1.101.0 (92b5b8c87, 2026-10-29) ; cargo-audit 0.22.2.
Le commit de base RustSec figure dans le rapport de clôture.

Reproduction : préparer les dépendances, puis lancer les conducteurs documentés dans
`../tools/validate.py` et `../fuzz/README.md`. Le contexte doit permettre l'IPC Unix et
la terminaison LeakSanitizer ; une restriction de l'environnement reste un échec déclaré.
Ne jamais remplacer un résultat manquant par un succès supposé.

Les qualifications ext4/XFS, panne électrique et autres plateformes restent non exécutées.
Les fixtures, clés et chemins temporaires des tests sont fictifs.
