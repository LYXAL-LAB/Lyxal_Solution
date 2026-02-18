# RESTE À FAIRE - Stabilisation lyxal_ui

Ce document répertorie les étapes nécessaires pour finaliser la migration vers Leptos 0.8 et compiler proprement le projet.

## 1. Nettoyage du Code Source
- [ ] Finaliser le nettoyage profond de tous les fichiers `.rs` dans `crates/core/lyx-core-leptos/`.
    - Supprimer les en-têtes `### ...`.
    - Supprimer les blocs markdown ` ```rust `.
    - Supprimer les numéros de ligne résiduels (`1: `, etc.).
- [ ] Vérifier particulièrement les fichiers `build.rs` qui bloquent actuellement la compilation.

## 2. Stabilisation des Manifestes (Vérification)
- [x] Correction des noms de paquets (`leptos_router`, `leptos_meta`, etc.).
- [x] Normalisation des chemins relatifs vers `crates/core` et `crates/logic`.
- [x] Restauration des versions `*` pour les dépendances externes.
- [ ] Lancer `cargo metadata` pour confirmer que le graphe de dépendances est 100% valide.

## 3. Compilation et Correction de Code
- [ ] Exécuter `cargo check -p leptonic --message-format=short`.
- [ ] Résoudre les erreurs de code dans `popover.rs` :
    - Conflits `SendWrapper` et `AttributeValue`.
    - Sécurité des threads pour `NodeRef`.
- [ ] Résoudre les erreurs de code dans `link.rs` :
    - Mise à jour des imports `leptos_router`.
    - Gestion du trait `ToHref`.
- [ ] Résoudre les erreurs de code dans `button.rs` :
    - Import du composant `A`.

## 4. Vérification Globale
- [ ] Exécuter `cargo check --workspace`.
- [ ] S'assurer que `leptos_theme` compile correctement sans avertissements majeurs.
- [ ] Vérifier la cohérence des fonctionnalités (features) entre les caisses.
