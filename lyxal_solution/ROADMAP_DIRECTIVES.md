# Directives de Conception et Roadmap

## 1. Principes Directeurs pour les Développeurs
- **Performance First** : Tout ce qui peut être fait en Rust natif doit l'être. Pas de JS/Node.js dans le kernel.
- **Isolation Stricte** : Chaque moteur (RTC, Flow, etc.) doit avoir son propre pool de threads pour ne jamais faire planter le moteur de stockage.
- **Zero-Dependency** : Réduire au maximum les dépendances externes pour garantir la souveraineté et la facilité de maintenance.

## 2. Stratégie UI : Le "Control Center" Surrealist
Surrealist (reforké pour Lyxal) ne mélange pas les genres.
- **Vues Dédiées** : Chaque métier/moteur a son onglet dédié (Automation, Photo, Doc, CRM).
- **Consistance Visuelle** : Une identité forte "Souveraineté Européenne" (propre, efficace, robuste).
- **Real-Time Feedback** : Utilisation du moteur RTC pour afficher l'exécution des flows et la vie du système en temps réel.

## 3. Jalons Stratégiques
1. **Stabilisation du Kernel** : Finalisation de `lyxalkv` et des hooks transactionnels.
2. **Flow Engine** : Implémentation du moteur de graphe et des premiers Intrinsics (HTTP, Logic).
3. **Verticalisation** : Création du module CRM avec Mapping externe.
4. **AI-Ready** : Extension du serveur MCP pour couvrir 100% des capacités de Lyxal.
