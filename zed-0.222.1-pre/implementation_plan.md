# Plan d'Intégration Gemini 3 et d'Intelligence de Contexte (Révisé)

Ce plan vise à résoudre les problèmes d'intégration de Gemini 3 dans Zed tout en rendant le système de résumé (summarization) agnostique au fournisseur (provider-agnostic), comme suggéré par l'utilisateur.

## Problèmes Identifiés

1.  **Gestion du HTTP 429** : Zed rejette les codes 429 sans lire le body, manquant des informations cruciales (quatrième gate).
2.  **Parsing Hybride** : Gemini 3 Flash mélange texte et raisonnement (`thoughtSignature`). Le parseur de Zed est trop rigide.
3.  **Dépendance au Fournisseur (Registry)** : Zed force un modèle Google "fast" pour le résumé, même si l'utilisateur utilise Anthropic ou Qwen.
4.  **Boucles de Compaction** : La compaction d'urgence peut boucler sur des threads vides.

## Changements Proposés

### [Composant] google_ai
#### [MODIFIER] [google_ai.rs](file:///c:/Users/Administrator/Downloads/zed-0.222.1-pre/zed-0.222.1-pre/crates/google_ai/src/google_ai.rs)
- **Gestion flexible des erreurs (429/200)** : Tenter de parser le JSON même sur une erreur pour extraire le `retryDelay`.
- **Parsing Résilient** : Ajouter `thought_signature` à `TextPart` et rendre l'enum `Part` plus tolérant aux champs mixtes.

### [Composant] language_model (Agnosticisme Fournisseur)
#### [MODIFIER] [registry.rs](file:///c:/Users/Administrator/Downloads/zed-0.222.1-pre/zed-0.222.1-pre/crates/language_model/src/registry.rs)
- **Respect du Choix Utilisateur** : Supprimer le fallback forcé vers Google Flash Lite. Utiliser le modèle sélectionné pour le thread ou le modèle configuré globalement pour le résumé, quel que soit le fournisseur (Anthropic, Qwen, Google, etc.).

### [Composant] agent
#### [MODIFIER] [thread.rs](file:///c:/Users/Administrator/Downloads/zed-0.222.1-pre/zed-0.222.1-pre/crates/agent/src/thread.rs)
- **Gestion Avancée du Contexte** : Implémenter le résumé par paires d'outils (tool-pair summary) et les invites de continuation pour une meilleure stabilité.

## Plan de Vérification

### Tests Automatisés
- Vérifier que le résumé fonctionne avec un modèle non-Google (ex: Anthropic) si sélectionné.
- Tester le parsing Google avec des erreurs 429 simulées.

### Vérification Manuelle
- Utiliser un modèle non-Google et vérifier que Zed n'essaie pas de forcer Flash Lite pour le résumé.
- Vérifier la résilience de Gemini 3 Flash avec des blocs de raisonnement.
