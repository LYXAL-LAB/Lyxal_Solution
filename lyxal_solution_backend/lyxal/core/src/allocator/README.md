# lyxal_core_allocator

## Rôle
Crate d'infrastructure bas-niveau responsable de la **sélection et du suivi de l'allocateur mémoire global** pour l'ensemble de Lyxal Solution.

## Pourquoi un crate séparé ?
Dans un projet Rust, le `#[global_allocator]` ne peut être défini **qu'une seule fois** dans tout le binaire. Si on le mettait dans `lyxal_db`, alors `lyxal_proxy` (Sōzu) et `lyxal_identity` (Logto) ne pourraient pas en bénéficier. En l'isolant ici, **toutes les applications de la suite Lyxal** utilisent le même allocateur haute performance.

## Fonctionnement
Le crate sélectionne automatiquement le meilleur allocateur selon la plateforme cible :

| Plateforme | Allocateur |
|---|---|
| Linux/macOS x86/x86_64 (non-MSVC) | **Jemalloc** (optimisé pour les serveurs haute charge) |
| Unix/Windows (autres architectures) | **MiMalloc** (allocateur ultra-rapide de Microsoft Research) |
| WASM / Plateformes exotiques | **System Allocator** (fallback standard Rust) |

## Feature Flags
- `allocator` : Active le remplacement du System Allocator par MiMalloc ou Jemalloc.
- `allocation-tracking` : Active le suivi détaillé de chaque allocation mémoire (utile pour le débogage et les métriques Prometheus). Implique `allocator`.

## Structure Interne
- `mem/mod.rs` : Point d'entrée, déclare le `static ALLOC` global.
- `mem/fake.rs` : Allocateur factice (quand la feature `allocator` est désactivée).
- `mem/track.rs` : Wrapper qui compte les octets alloués/libérés autour de l'allocateur réel.
- `mem/notrack.rs` : Wrapper transparent sans overhead de suivi.
- `mem/registry.rs` : Registre des `MemoryReporter` pour exposer les métriques de RAM par composant.

## Utilisé par
- `lyxal_server` (le binaire principal) active ce crate avec `features = ["allocator", "allocation-tracking"]`.
- Les autres crates de `lyxal_core` n'importent **pas** ce crate directement : seul le binaire final doit décider de l'allocateur.
