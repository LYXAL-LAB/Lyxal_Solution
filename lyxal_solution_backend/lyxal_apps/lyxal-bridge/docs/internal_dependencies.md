# Dépendances Internes - Lyxal Bridge

Ce document répertorie les dépendances critiques du module **Lyxal Bridge** vis-à-vis des autres modules du système Lyxal.

## Hiérarchie des Dépendances

Le module **Lyxal Bridge** s'appuie sur les modules de service transverses suivants :

1. **lyxal_error**
    - **Rôle :** Gestionnaire universel des exceptions et des codes d'erreur.
    - **Usage :** Bridge utilise ce module pour mapper les erreurs HTTP externes vers des types d'erreurs internes Lyxal standardisés.
    - **Lien BDD :** Utilisé par la table `bridge_errors` pour la définition des actions de remédiation.

2. **lyxal_log**
    - **Rôle :** Système centralisé de journalisation et d'audit.
    - **Usage :** Bridge enregistre chaque tentative d'invocation, succès ou échec dans ce module pour le monitoring et le debugging.
    - **Lien BDD :** Utilisé pour alimenter l'historique d'exécution des opérations (`bridge_operations`).

---
*Note : Ce module est conçu pour être "Stateless" (sans état), sa logique d'exécution dépendant entièrement des définitions injectées en base de données.*
