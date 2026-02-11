# Plan d'Implémentation - LyxalAck

## Phase 1 : Design & Schéma (Priorité : Haute)
- [ ] Définition complète du schéma SurrealQL (`Lyxal_Ack/database/schema.surql`).
- [ ] Configuration des Scopes d'authentification.
- [ ] Tests de montée en charge sur les relations de graphe.

## Phase 2 : Développement du Bridge Rust (Priorité : Moyenne)
- [ ] Création d'un module Rust indépendant pour valider les fonctions `ed25519-dalek`.
- [ ] Implémentation du worker SMTP pour les relances.
- [ ] Tests d'intégration avec le binaire SurrealDB existant.

## Phase 3 : Intégration Core Engine (Priorité : Critique)
- [ ] Injection des fonctions Rust dans `crates/core/src/fnc`.
- [ ] Recompilation du moteur SurrealDB.
- [ ] Validation des fonctions via SurrealQL (`RETURN crypto::ed25519::sign(...)`).

## Phase 4 : Interface Lyxal Studio (Priorité : Moyenne)
- [ ] Fork de Surrealist.
- [ ] Suppression des modules d'édition pour ne garder que le moteur de rendu.
- [ ] Création du composant de signature sécurisé.

