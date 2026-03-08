# TODO: Intégration TOTALE de Sōzu dans Lyxal (lyxal_proxy)

Ce document trace la route pour l'absorption complète du code source de Sōzu et sa transformation en un moteur réseau piloté par SurrealDB.

## ÉTAPE 1 : Restructuration du Code (Absorption)
- [ ] **Transformer Sōzu en bibliothèque interne** : Modifier le Cargo.toml de lyxal_proxy pour exposer une lib utilisable par le workspace Lyxal.
- [ ] **Détourner le point d'entrée** : Créer un module engine.rs dans lyxal_proxy/lib qui permet de lancer le Worker Sōzu (boucle mio) depuis un thread Rust standard sans passer par le binaire Sōzu original.
- [ ] **Nettoyage sélectif** : Supprimer les dossiers bin, os-build, e2e, et les scripts CI de Sōzu une fois que la bibliothèque est fonctionnelle.

## ÉTAPE 2 : Création des Fonctions SQL Natives (fnc/proxy.rs)
- [ ] **Implémenter proxy::ingress::*** :
    - add(host, options) -> Lie au moteur Sōzu pour ouvrir un port/domaine.
    - list() -> Retourne l'état de la RAM de Sōzu.
- [ ] **Implémenter proxy::cluster::*** :
    - add_backend(cluster, addr) -> Ajoute une cible de routage en temps réel.
    - set_load_balancing(cluster, policy) -> Change l'algorithme de répartition.
- [ ] **Implémenter proxy::metrics::*** :
    - get(id) -> Utilise la fonction to_filtered() pour renvoyer des stats propres en SQL.
- [ ] **Implémenter proxy::ssl::*** :
    - add_certificate(id, cert, key) -> Injection directe de certificats dans la RAM.

## ÉTAPE 3 : Persistance et Synchronisation (SurrealDB)
- [ ] **Définir les Tables Système** : Créer les schémas pour proxy_ingress, proxy_cluster, proxy_backend.
- [ ] **Mettre en place les Event Handlers** : Lier chaque action SQL sur ces tables à un appel vers le moteur lyxal_proxy (Sōzu).
- [ ] **Bootstrap au démarrage** : Au lancement du binaire Lyxal, lire toutes les tables proxy_* pour pré-charger la RAM de Sōzu.

## ÉTAPE 4 : Pilotage IA (MCP Server)
- [ ] **Définir les Tools MCP** : Créer des outils de haut niveau pour l'IA (ex: "Expose une nouvelle application", "Vérifie la santé du réseau").
- [ ] **Mapping Tool -> SQL** : Chaque outil MCP doit générer la requête SurrealQL correspondante pour garantir la sécurité et la validation.

## ÉTAPE 5 : Finalisation du Binaire Unique
- [ ] **Compilation statique** : S'assurer que toutes les dépendances de Sōzu (openssl/rustls, etc.) sont liées statiquement dans le binaire lyxal_solution_backend.
- [ ] **Interface Surrealist** : Pouvoir monitorer et configurer tout le proxy graphiquement via la base de données.

## ÉTAPE 6 : Refonte du Système de Métriques (Observabilité Native)
- [ ] **Désactiver les Drains Réseau** : Supprimer l'usage de `NetworkDrain` (UDP/Telegraf) au profit d'un stockage local.
- [ ] **Connecter l'Aggregator à SurrealDB** :
    - Modifier le trait `MetricDrain` pour inclure une méthode `to_surreal_value()`.
    - Créer un Background Worker Rust qui vide le `LocalDrain` périodiquement dans la table `proxy_metrics`.
- [ ] **Exploiter `to_filtered()`** : 
    - Mapper les types `Gauge`, `Count`, et `Time` (Histogrammes) vers les types natifs SurrealDB.
    - Permettre le requêtage en temps réel via `proxy::metrics::get(id)` sans attendre le flush en base de données.
- [ ] **IA Feedback Loop** : Permettre au serveur MCP d'analyser ces métriques pour suggérer des modifications de configuration SQL automatiques.

---
*Objectif final : Un seul fichier .exe capable de gérer le stockage, l'identité (Logto), le P2P (lyxal_network) et tout le routage web (lyxal_proxy) via une IA.*
