# Stratégie RBAC (Role-Based Access Control)

## Contexte Logto
Dans Logto, le RBAC est structuré autour de 3 entités :
1. **Resources** (API) : Ce qu'on protège (ex: `https://api.mysaas.com`).
2. **Scopes** (Permissions) : Actions possibles sur une ressource (ex: `read:items`, `write:items`).
3. **Roles** : Groupes de scopes (ex: `Admin` = `read:items` + `write:items`).

## Défi Lyxal : Global vs Local
Les rôles peuvent exister à deux niveaux :

### 1. Niveau Système (Global)
- Définis par l'administrateur de l'instance Lyxal.
- Accessibles par tout le monde ou réservés.
- **Exemple** : Un rôle "User Standard" qui donne accès au profil de base.
- **Stockage** : Namespace `LYXAL_IDENTITY` (Core) ou un Vault Système partagé ?

### 2. Niveau Organisation (Local)
- Définis par l'admin d'une Organisation spécifique.
- N'existent que DANS cette organisation.
- **Exemple** : Le rôle "Comptable" de l'entreprise Acme Corp.
- **Stockage** : Namespace `NS_ORG_{UUID}` (Vault Org).

## Architecture Proposée

### A. Ressources & Scopes (Définitions)
Les ressources (APIs) sont souvent liées à des Applications.
- **Stratégie** : Stocker les définitions de ressources et scopes dans le **Vault de l'Application** concernée (`vault_app`).
- Si c'est une API globale système, elle aura son propre Vault Système.

### B. Rôles (Assemblages)
- **Rôles Globaux** : Table `role` dans `database/schemas/core/` (ou un vault système).
- **Rôles Locaux** : Table `role` dans `database/schemas/vault_org/`.

### C. Assignation (Le "Qui a quoi")
- L'assignation se fait via le graphe ou dans les tables de membres.
- **Utilisateur** -> `has_role` -> **Rôle**.

## Plan d'Implémentation (1:1 Logto)

1. **`resource.surql`** & **`scope.surql`**
   - À placer dans `vault_app` (car une Ressource est souvent une API/App).

2. **`role.surql`**
   - À placer dans `vault_org` (pour les rôles d'org).
   - ET dans `core` (pour les rôles système) ? *À décider.*

3. **Relations**
   - `role_has_scope` (Table de relation).
