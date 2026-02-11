# 🔌 Lyxal Connect (Module)

**Le Hub d'Intégration Universel & Souverain.**

## 🎯 Vision
`Lyxal_Connect` est le module qui permet à Lyxal de parler au reste du monde (Google, Slack, Zoho, Salesforce...).
L'objectif est de reproduire la puissance de plateformes comme **Composio** ou **Zapier**, mais en gardant le contrôle total des données et des tokens.

**Concept Clé : "Zero-Knowledge Central"**
Lyxal Central ne stocke PAS les tokens OAuth de vos clients. Ils sont chiffrés et stockés *dans* le namespace SurrealDB du client.

## 🏗 Architecture

### 1. Le Gestionnaire d'Identité Tierce (OAuth Manager)
Gère le flux OAuth (Redirect, Callback, Refresh Token).
Stocke les secrets clients (Client ID/Secret) de manière sécurisée.

### 2. Le Moteur de Connecteurs (OpenAPI Engine)
Au lieu de coder chaque API à la main, ce moteur ingère des fichiers **OpenAPI (Swagger)** et génère dynamiquement les interfaces d'action.
*   *Exemple* : On importe `zoho-crm.yaml` -> L'IA peut instantanément faire `zoho.create_lead()`.

### 3. Le Serveur MCP Dynamique
Un serveur MCP spécial qui expose ces connecteurs aux Agents IA à la volée.

## 📚 Inspirations & Références
*   **Composio** : Pour l'architecture "Agent-First" et la gestion des Toolsets.
*   **Nango** : Pour la gestion unifiée de l'OAuth (Sync, Refresh).
*   **ActivePieces** : Pour la logique de "Pièces" (Connecteurs) Open Source.

## 🛠 Stack Technique
*   **Langage** : TypeScript (Bun).
*   **Database** : SurrealDB (Distribué dans les namespaces clients).
*   **Standard** : OpenAPI 3.0 / OAuth 2.0.

