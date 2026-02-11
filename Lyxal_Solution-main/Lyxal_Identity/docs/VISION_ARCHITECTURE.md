# 🆔 Lyxal Identity — Vision & Architecture

## 1. La Philosophie : "L'Individu au Centre" (Souveraineté des Données)

Contrairement aux modèles SaaS classiques où un utilisateur est une ligne dans la base de données d'une entreprise, Lyxal renverse le paradigme.

**Le Concept : "Identity as a Platform"**
L'utilisateur n'appartient pas à Lyxal. Il utilise Lyxal pour gérer son identité numérique.

## 2. Architecture Technique : Le Modèle "Vault"

Nous adoptons une architecture distribuée radicale pour garantir la sécurité et la confidentialité.

### A. Le Registre Central (Lyxal_Identity)
C'est le "France Connect" de l'écosystème. Il est **léger** et **agnostique**.
*   **Ce qu'il contient** :
    *   `UUID` (Identifiant unique immuable).
    *   `Auth Methods` (Hash mot de passe, Liens OAuth, Clés Passkey).
    *   `Pointer` : L'adresse du Namespace Personnel de l'utilisateur.
*   **Ce qu'il NE contient PAS** :
    *   Pas de nom, pas d'adresse, pas d'historique, pas de données métier.

### B. Le Namespace Personnel (Personal Vault)
Chaque utilisateur dispose de son propre Namespace SurrealDB dédié (ex: `NS_USER_8374...`).
*   **Ce qu'il contient** :
    *   **Profil** : Nom, Email, Avatar, Préférences.
    *   **Credentials** : Tokens OAuth tiers (Google, Slack...) chiffrés.
    *   **Historique** : Logs d'activité, Conversations avec l'IA personnelle.
*   **Avantage** : Isolation totale. Si Lyxal est attaqué, les données personnelles sont cloisonnées dans des millions de bases séparées.

### C. L'Accès aux Services (Fédération)
Quand Monsieur Dupont rejoint le CRM de "Acme Corp", il n'y a pas de duplication de données.
*   Le Tenant `NS_ACME` crée une relation de confiance.
*   Il accorde des droits à l'UUID de Dupont.
*   Dupont "projette" son identité dans le contexte d'Acme sans jamais céder la propriété de ses données.

---

## 3. Flux d'Authentification

1.  **Login** : L'utilisateur s'authentifie auprès du Registre Central (`Lyxal_Identity`).
2.  **Token** : Il reçoit un JWT contenant son UUID et l'adresse de son Vault.
3.  **Accès** :
    *   Pour voir son profil -> Le client se connecte à son `Personal Vault`.
    *   Pour travailler -> Le client se connecte au `Tenant Workspace` en utilisant son Token comme preuve.

## 4. Valeur Ajoutée

*   **Sécurité par Design** : Pas de "Honeypot" centralisé contenant toutes les données de tout le monde.
*   **Portabilité** : L'utilisateur peut techniquement "exporter" son Vault.
*   **Écosystème** : Un utilisateur peut passer d'un SaaS Lyxal à un autre sans jamais recréer de compte ni perdre ses préférences.
