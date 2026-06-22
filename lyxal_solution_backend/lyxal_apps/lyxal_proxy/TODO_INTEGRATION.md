# TODO: Intégration Native Sōzu (lyxal_proxy) dans Lyxal

## 1. Préparation de la structure lyxal_proxy
- [ ] Nettoyer les fichiers obsolètes (Docker, CI/CD, scripts OS) pour ne garder que le moteur.
- [ ] Transformer la crate en bibliothèque pure (`[lib]`) dans `Cargo.toml`.
- [ ] Exposer les structures de données de `command_lib` pour qu'elles soient accessibles par le backend.
- [ ] Créer une interface de contrôle Rust (`fn`) pour manipuler le proxy en mémoire sans sockets Unix.

## 2. Implémentation du module de fonctions LyxalQL (`fnc/proxy.rs`)
- [ ] Créer le fichier `lyxal_db/core/src/fnc/proxy.rs` sur le modèle de `http.rs`.
- [ ] Définir la syntaxe conforme Lyxal pour les fonctions :
    - `proxy::ingress::add(host, { options })` : Ajouter un frontend.
    - `proxy::cluster::add(id, target)` : Lier un backend/cluster.
    - `proxy::metrics::get(id)` : Récupérer les stats filtrées via `to_filtered()`.
    - `proxy::ingress::del(id)` : Supprimer une route.
- [ ] Implémenter le "Casting" des types Lyxal (`Value`) vers les types Sōzu (`WorkerRequest`).

## 3. Enregistrement dans le moteur Lyxal
- [ ] Modifier `lyxal_db/core/src/fnc/mod.rs` pour enregistrer le nouveau module `proxy`.
- [ ] Mettre à jour `lyxal_db/core/src/sql/function.rs` pour que le parseur SQL reconnaisse la grammaire `proxy::*`.
- [ ] Intégrer les vérifications de capacités (`Capabilities`) pour sécuriser les appels réseau depuis le SQL.

## 4. Orchestration et Pilotage IA (MCP Server)
- [ ] Lancer le thread du worker Sōzu à l'initialisation du binaire Lyxal.
- [ ] Créer les "Tools" dans le serveur MCP qui mappent vers les requêtes SQL `proxy::*`.
- [ ] Valider le flux : IA -> MCP Tool -> SQL Query -> Sōzu Native Fn -> Réseau.

## 5. Tests et Validation
- [ ] Créer des tests unitaires Rust pour les fonctions natives `proxy::*`.
- [ ] Valider via Lyxalist que l'ajout d'une route en SQL modifie bien le trafic en temps réel.
- [ ] Vérifier la remontée des métriques filtrées dans la console SQL.