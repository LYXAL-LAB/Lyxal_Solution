# LyxalAck: Système Souverain de Preuve de Lecture

## Vision
LyxalAck est le module de confiance native de l'écosystème Lyxal. Il transforme le moteur de base de données SurrealDB en un serveur de signature cryptographique irréfutable, éliminant tout middleware tiers.

## Objectifs
- **Souveraineté :** Maîtrise totale de la chaîne de signature (du code Rust à l'UI).
- **Intégrité :** Utilisation de signatures Ed25519 pour garantir la non-répudiation.
- **Intégration :** Module métier intégré directement dans Lyxal Studio (Surrealist).

## Composants
1. **Lyxal Engine (Rust) :** Fork de SurrealDB avec fonctions crypto natives.
2. **Lyxal Graph (SurrealQL) :** Modèle de données orienté graphe pour les relations de signature.
3. **Lyxal Studio Interface :** Version simplifiée de Surrealist pour l'expérience de signature.

