# Intelligence Artificielle et Verticalisation Métier

## 1. Langages Uniques Métiers (Vertical LyxalQL)
Pour supprimer la complexité, Lyxal introduit des dialectes sémantiques.
- **Principe** : Créer des extensions de grammaire pour chaque métier (CRM, Finance, Logistique).
- **Exemple** : `CRM::CONVERT_LEAD` déclenche nativement une cascade d'actions (transaction, sync externe, notification RTC).
- **Avantage** : Réduction massive du code applicatif et facilitation de la génération de code par les IAs.

## 2. Le "Sync-Ghost" : Connectivité Totale
Pour ne pas couper les utilisateurs de l'extérieur tout en les rapatriant vers Lyxal :
- **Mapping Natif** : Lyxal propose des tables natives (ex: CRM) mappées sur des solutions externes (Salesforce, Zoho, HubSpot).
- **Back-Sync** : Les modifications faites dans Lyxal sont poussées en arrière-plan vers les outils tiers via le moteur de Flow.
- **Finalité** : Lyxal devient le "Single Source of Truth" (Source Unique de Vérité).

## 3. L'Interface IA : Le Serveur MCP Rust
Le Model Context Protocol (MCP) est l'interface par laquelle l'IA interagit avec Lyxal.
- **Tout-en-Un** : Le serveur MCP expose non seulement les données, mais aussi les capacités de chaque moteur (RTC, Flow, Scheduler).
- **Sémantique Métier** : L'IA ne manipule pas des tables brutes, mais des concepts métiers (Tools MCP) définis par les langages verticaux.
- **Performance** : Implémentation en Rust pour une latence minimale, cruciale pour les agents IA autonomes.
