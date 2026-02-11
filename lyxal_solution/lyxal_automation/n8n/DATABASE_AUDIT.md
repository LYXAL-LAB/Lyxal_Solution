# 📊 Audit Complet de la Base de Données n8n

> **Date de l'audit**: Janvier 2026  
> **Version analysée**: n8n-master (repository Lyxal_Solution)  
> **ORM utilisé**: TypeORM  
> **Bases supportées**: SQLite, PostgreSQL, MySQL/MariaDB

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture des données](#architecture-des-données)
3. [Tables par catégorie](#tables-par-catégorie)
   - [Identité & Authentification](#1-identité--authentification)
   - [Workflows](#2-workflows)
   - [Exécutions](#3-exécutions)
   - [Projets & Partage](#4-projets--partage)
   - [Credentials (Identifiants)](#5-credentials-identifiants)
   - [Tags & Organisation](#6-tags--organisation)
   - [Variables & Paramètres](#7-variables--paramètres)
   - [Données Binaires](#8-données-binaires)
   - [Tests (Enterprise)](#9-tests-enterprise)
   - [OAuth/MCP](#10-oauthmcp)
   - [ChatHub (IA)](#11-chathub-ia)
   - [DataTables](#12-datatables)
   - [Packages Communautaires](#13-packages-communautaires)
   - [Log Streaming (Enterprise)](#14-log-streaming-enterprise)
4. [Résumé statistique](#résumé-statistique)
5. [Notes techniques](#notes-techniques)

---

## Vue d'ensemble

n8n utilise une architecture de base de données relationnelle avec **50 tables** organisées en **14 catégories fonctionnelles**. Chaque table correspond à un domaine métier spécifique de la plateforme d'automatisation.

### Objectifs de chaque catégorie

| Catégorie | Objectif Principal |
|-----------|-------------------|
| **Identité** | Gérer les utilisateurs, rôles et permissions |
| **Workflows** | Stocker les définitions d'automatisations |
| **Exécutions** | Historiser les lancements de workflows |
| **Projets** | Organiser et partager les ressources |
| **Credentials** | Sécuriser les accès aux services tiers |
| **Tags** | Catégoriser et filtrer les ressources |
| **Variables** | Centraliser les configurations |
| **Binary Data** | Stocker les fichiers et médias |
| **Tests** | Valider les workflows (Enterprise) |
| **OAuth** | Authentification pour MCP/API |
| **ChatHub** | Conversations avec agents IA |
| **DataTables** | Stockage de données structurées |
| **Packages** | Extensions communautaires |
| **Logs** | Streaming d'événements (Enterprise) |

---

## Architecture des données

```
┌─────────────────────────────────────────────────────────────────────┐
│                           UTILISATEURS                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐                   │
│  │   user   │───▶│   role   │───▶│    scope     │                   │
│  └────┬─────┘    └──────────┘    └──────────────┘                   │
│       │                                                              │
│       ├──────────────────┬───────────────────────────┐              │
│       ▼                  ▼                           ▼              │
│  ┌──────────┐     ┌─────────────────┐      ┌──────────────┐         │
│  │ api_key  │     │ project_relation│      │ auth_identity│         │
│  └──────────┘     └────────┬────────┘      └──────────────┘         │
│                            │                                         │
│                            ▼                                         │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                        PROJETS                               │    │
│  │  ┌─────────┐    ┌─────────────────┐    ┌──────────────────┐ │    │
│  │  │ project │───▶│ shared_workflow │◀───│ workflow_entity  │ │    │
│  │  └────┬────┘    └─────────────────┘    └────────┬─────────┘ │    │
│  │       │                                         │            │    │
│  │       ▼                                         ▼            │    │
│  │  ┌─────────────────────┐            ┌───────────────────┐   │    │
│  │  │ shared_credentials  │            │ execution_entity  │   │    │
│  │  └─────────────────────┘            └───────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Tables par catégorie

---

# 1. Identité & Authentification

Ces tables gèrent tout ce qui concerne les utilisateurs, leurs rôles, permissions et méthodes d'authentification.

---

## 📌 Table: `user`

**Objectif**: Stocke les informations de chaque utilisateur de n8n.

**Cas d'usage**:
- Connexion et authentification
- Affichage du profil utilisateur
- Gestion des permissions via le rôle assigné
- Suivi de l'activité utilisateur

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | uuid | ❌ | **Identifiant unique** - Généré automatiquement, utilisé pour toutes les références à l'utilisateur |
| `email` | varchar(254) | ✅ | **Email** - Sert d'identifiant de connexion, converti automatiquement en minuscules, indexé pour recherche rapide |
| `firstName` | varchar(32) | ✅ | **Prénom** - Affiché dans l'interface et les notifications |
| `lastName` | varchar(32) | ✅ | **Nom** - Complète l'identité pour l'affichage |
| `password` | varchar | ✅ | **Mot de passe hashé** - NULL si l'utilisateur n'a pas encore défini de mot de passe (invitation en attente) |
| `personalizationAnswers` | json | ✅ | **Sondage d'onboarding** - Réponses au questionnaire de personnalisation (secteur, taille entreprise, etc.) |
| `settings` | json | ✅ | **Préférences utilisateur** - Langue, thème, notifications, etc. |
| `roleSlug` | varchar | ❌ | **Rôle global** - Référence vers `role.slug` (ex: `global:owner`, `global:member`) |
| `disabled` | boolean | ❌ | **Compte désactivé** - Si `true`, l'utilisateur ne peut plus se connecter |
| `mfaEnabled` | boolean | ❌ | **MFA activé** - Authentification à deux facteurs |
| `mfaSecret` | varchar | ✅ | **Secret TOTP** - Clé secrète pour générer les codes MFA |
| `mfaRecoveryCodes` | array | ❌ | **Codes de récupération** - Codes à usage unique si perte du device MFA |
| `lastActiveAt` | date | ✅ | **Dernière activité** - Pour statistiques et détection de comptes inactifs |
| `createdAt` | datetime | ❌ | **Date de création** - Historique du compte |
| `updatedAt` | datetime | ❌ | **Dernière modification** - Suivi des changements |

**Relations**:
- `role` → Détermine les permissions globales
- `projectRelations` → Appartenance aux projets
- `apiKeys` → Clés API associées
- `authIdentities` → Connexions SSO/LDAP

---

## 📌 Table: `role`

**Objectif**: Définit les rôles et leurs types dans le système de permissions.

**Cas d'usage**:
- Définir les niveaux d'accès (owner, admin, member)
- Créer des rôles personnalisés
- Distinguer les rôles globaux vs projet

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `slug` | varchar | ❌ | **Clé unique** - Identifiant lisible (ex: `global:owner`, `project:editor`), sert de clé primaire |
| `displayName` | varchar | ❌ | **Nom affiché** - Montré dans l'UI (ex: "Propriétaire", "Éditeur") |
| `description` | varchar | ✅ | **Description** - Explique les capacités du rôle pour l'utilisateur |
| `systemRole` | boolean | ❌ | **Rôle système** - Si `true`, ne peut pas être modifié/supprimé (rôles par défaut de n8n) |
| `roleType` | varchar | ❌ | **Type de rôle** - `global` (niveau plateforme), `project` (niveau projet), `workflow`, `credential` |
| `createdAt` | datetime | ❌ | **Date création** |
| `updatedAt` | datetime | ❌ | **Dernière modification** |

**Valeurs typiques**:
- `global:owner` - Super admin, tous les droits
- `global:admin` - Administrateur
- `global:member` - Utilisateur standard
- `project:admin` - Admin d'un projet
- `project:editor` - Peut modifier les workflows d'un projet

---

## 📌 Table: `scope`

**Objectif**: Liste toutes les permissions atomiques disponibles dans le système.

**Cas d'usage**:
- Définir finement ce qu'un rôle peut faire
- Vérifier les autorisations lors des actions utilisateur

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `slug` | varchar | ❌ | **Permission** - Identifiant unique (ex: `workflow:create`, `credential:read`) |
| `displayName` | varchar | ✅ | **Nom affiché** - Pour l'interface d'administration |
| `description` | varchar | ✅ | **Description** - Explique ce que la permission autorise |

**Exemples de scopes**:
- `workflow:create` - Créer des workflows
- `workflow:execute` - Exécuter des workflows
- `credential:share` - Partager des credentials
- `project:delete` - Supprimer un projet

---

## 📌 Table: `role_scope` (jonction)

**Objectif**: Associe les rôles aux permissions (Many-to-Many).

| Colonne | Type | Description |
|---------|------|-------------|
| `roleSlug` | varchar | Référence au rôle |
| `scopeSlug` | varchar | Référence à la permission |

---

## 📌 Table: `auth_identity`

**Objectif**: Lie un utilisateur à une identité externe (SSO, LDAP, etc.).

**Cas d'usage**:
- Connexion via LDAP d'entreprise
- Authentification SAML
- Multiples méthodes de connexion pour un même utilisateur

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `providerId` | varchar | ❌ | **ID externe** - Identifiant chez le provider (ex: DN LDAP, subject SAML) |
| `providerType` | varchar | ❌ | **Type de provider** - `ldap`, `saml`, `email` |
| `userId` | uuid | ❌ | **Utilisateur lié** - Référence vers `user.id` |
| `createdAt` | datetime | ❌ | **Date de liaison** |
| `updatedAt` | datetime | ❌ | **Dernière synchro** |

---

## 📌 Table: `user_api_keys`

**Objectif**: Stocke les clés API pour accès programmatique.

**Cas d'usage**:
- Intégration CI/CD
- Accès API REST externe
- Automatisation de déploiement de workflows

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **Identifiant** - NanoId généré automatiquement |
| `userId` | uuid | ❌ | **Propriétaire** - Utilisateur qui a créé la clé |
| `label` | varchar | ❌ | **Label** - Nom donné par l'utilisateur (ex: "CI/CD Pipeline") |
| `scopes` | json | ❌ | **Permissions** - Liste des scopes autorisés pour cette clé |
| `apiKey` | varchar | ❌ | **Clé hashée** - La vraie clé n'est visible qu'une fois à la création |
| `audience` | varchar | ❌ | **Audience** - Type d'API: `public-api` (REST), `mcp` |
| `createdAt` | datetime | ❌ | **Date création** |
| `updatedAt` | datetime | ❌ | **Dernière modification** |

---

## 📌 Table: `auth_provider_sync_history`

**Objectif**: Historise les synchronisations avec les providers d'authentification.

**Cas d'usage**:
- Audit des synchros LDAP
- Débogage des problèmes de provisioning
- Statistiques sur les utilisateurs importés

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `providerType` | text | ❌ | **Type** - `ldap` ou `saml` |
| `runMode` | text | ❌ | **Mode** - `live` ou `dry-run` |
| `status` | text | ❌ | **Statut** - `success`, `error`, `partial` |
| `startedAt` | datetime | ❌ | **Début** - Heure de début de synchro |
| `endedAt` | datetime | ❌ | **Fin** - Heure de fin |
| `scanned` | int | ❌ | **Scannés** - Nombre d'utilisateurs trouvés dans le provider |
| `created` | int | ❌ | **Créés** - Nouveaux utilisateurs créés |
| `updated` | int | ❌ | **Mis à jour** - Utilisateurs modifiés |
| `disabled` | int | ❌ | **Désactivés** - Utilisateurs désactivés car absents |
| `error` | varchar | ❌ | **Erreur** - Message d'erreur si échec |

---

## 📌 Table: `invalid_auth_token`

**Objectif**: Liste noire des tokens invalidés avant expiration.

**Cas d'usage**:
- Déconnexion forcée
- Révocation de session compromise
- Rotation de tokens

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `token` | varchar | ❌ | **Token invalidé** - Hash du JWT révoqué |
| `expiresAt` | datetime | ❌ | **Expiration** - Date après laquelle l'entrée peut être supprimée |

---

# 2. Workflows

Les workflows sont le cœur de n8n - ce sont les automatisations créées par les utilisateurs.

---

## 📌 Table: `workflow_entity`

**Objectif**: Stocke la définition complète de chaque workflow.

**Cas d'usage**:
- Sauvegarde du design des automatisations
- Activation/désactivation des workflows
- Versioning des configurations

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **Identifiant** - NanoId unique du workflow |
| `name` | varchar(128) | ❌ | **Nom** - Titre affiché dans l'interface (1-128 caractères, unique) |
| `description` | text | ✅ | **Description** - Documentation du workflow |
| `active` | boolean | ❌ | ⚠️ **[DEPRECATED]** - Utiliser `activeVersionId` à la place |
| `isArchived` | boolean | ❌ | **Archivé** - Soft-delete, workflow ne peut plus être modifié mais peut être restauré |
| `nodes` | json | ❌ | **Nœuds** - Configuration complète de tous les nœuds (INode[]) |
| `connections` | json | ❌ | **Connexions** - Comment les nœuds sont reliés entre eux |
| `settings` | json | ✅ | **Paramètres** - Timezone, error workflow, save execution data, etc. |
| `staticData` | json | ✅ | **Données statiques** - Données persistantes entre exécutions (ex: dernier ID traité) |
| `meta` | json | ✅ | **Métadonnées** - Infos pour le frontend (position canvas, zoom, etc.) |
| `pinData` | json | ✅ | **Données épinglées** - Données de test fixées pour le debug |
| `versionId` | varchar(36) | ❌ | **Version actuelle** - UUID de la version en cours d'édition |
| `activeVersionId` | varchar(36) | ✅ | **Version active** - Version qui s'exécute (null = inactif) |
| `versionCounter` | int | ❌ | **Compteur** - Incrémenté à chaque modification |
| `triggerCount` | int | ❌ | **Triggers** - Nombre de triggers actifs (pour facturation cloud) |
| `parentFolderId` | varchar | ✅ | **Dossier parent** - Organisation dans l'arborescence |
| `createdAt` | datetime | ❌ | **Date création** |
| `updatedAt` | datetime | ❌ | **Dernière modification** |

---

## 📌 Table: `workflow_history`

**Objectif**: Historique de toutes les versions d'un workflow.

**Cas d'usage**:
- Revenir à une version précédente
- Voir qui a modifié quoi
- Audit des changements

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `versionId` | varchar | ❌ | **ID version** - UUID unique de cette version |
| `workflowId` | varchar | ❌ | **Workflow parent** - Référence au workflow |
| `nodes` | json | ❌ | **Nœuds** - Snapshot des nœuds à cette version |
| `connections` | json | ❌ | **Connexions** - Snapshot des connexions |
| `authors` | varchar | ❌ | **Auteurs** - Noms des utilisateurs ayant contribué |
| `name` | text | ✅ | **Nom** - Le nom du workflow à cette version |
| `description` | text | ✅ | **Description** - Description à cette version |
| `autosaved` | boolean | ❌ | **Auto-save** - Sauvegarde automatique vs manuelle |
| `createdAt` | datetime | ❌ | **Date** - Quand cette version a été créée |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `workflow_publish_history`

**Objectif**: Journal des activations/désactivations de workflows.

**Cas d'usage**:
- Savoir qui a activé un workflow et quand
- Audit de production
- Débogage des problèmes d'activation

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `workflowId` | varchar | ❌ | **Workflow** - Lequel a été modifié |
| `versionId` | varchar | ❌ | **Version** - Quelle version a été activée/désactivée |
| `event` | varchar | ❌ | **Action** - `activated` ou `deactivated` |
| `userId` | uuid | ✅ | **Utilisateur** - Qui a fait l'action (null si automatique) |
| `createdAt` | datetime | ❌ | **Date** - Quand l'action a eu lieu |

---

## 📌 Table: `workflow_statistics`

**Objectif**: Statistiques d'exécution agrégées par workflow.

**Cas d'usage**:
- Dashboard de performance
- Facturation basée sur l'usage
- Identification des workflows les plus utilisés

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `count` | bigint | ❌ | **Total exécutions** - Nombre cumulé d'exécutions |
| `rootCount` | bigint | ❌ | **Exécutions racines** - Exécutions déclenchées directement (pas sous-workflow) |
| `latestEvent` | datetime | ❌ | **Dernière exécution** - Date du dernier run |
| `name` | varchar(128) | ❌ | **Type de stat** - Ex: `manual_success`, `trigger_error` |
| `workflowId` | varchar(36) | ❌ | **Workflow** - ⚠️ Orphan ref (pas de FK car stats conservées après suppression) |
| `workflowName` | varchar(128) | ✅ | **Nom (cache)** - Copie du nom pour affichage même après suppression |

---

## 📌 Table: `workflow_dependency`

**Objectif**: Index des dépendances de chaque workflow.

**Cas d'usage**:
- Trouver tous les workflows qui utilisent un credential
- Impact analysis avant suppression d'un nœud
- Recherche rapide par type de nœud

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `workflowId` | varchar(36) | ❌ | **Workflow** - Workflow qui a cette dépendance |
| `workflowVersionId` | int | ❌ | **Version** - Pour vérifier la cohérence |
| `dependencyType` | varchar(32) | ❌ | **Type** - `credentialId`, `nodeType`, `webhookPath`, `workflowCall`, `workflowIndexed` |
| `dependencyKey` | varchar(255) | ❌ | **Clé** - ID du credential, type du nœud, etc. |
| `dependencyInfo` | json | ✅ | **Détails** - Infos supplémentaires (ID du nœud, etc.) |
| `indexVersionId` | smallint | ❌ | **Version index** - Pour migrations de l'index |
| `createdAt` | datetime | ❌ | **Date** |

---

## 📌 Table: `webhook_entity`

**Objectif**: Enregistre les webhooks actifs des workflows.

**Cas d'usage**:
- Routage des requêtes HTTP entrantes
- Vérification de conflits de chemins
- Gestion cache des webhooks

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `webhookPath` | varchar | ❌ | **Chemin** - URL relative du webhook (clé primaire partielle) |
| `method` | text | ❌ | **Méthode HTTP** - GET, POST, etc. (clé primaire partielle) |
| `workflowId` | varchar | ❌ | **Workflow** - Qui traite ce webhook |
| `node` | varchar | ❌ | **Nœud** - Quel nœud Webhook dans le workflow |
| `webhookId` | varchar | ✅ | **ID unique** - Pour les webhooks avec paramètres dynamiques |
| `pathLength` | int | ✅ | **Longueur** - Nombre de segments, pour le tri de priorité |

---

# 3. Exécutions

Chaque fois qu'un workflow s'exécute, les détails sont enregistrés ici.

---

## 📌 Table: `execution_entity`

**Objectif**: Enregistrement de chaque exécution de workflow.

**Cas d'usage**:
- Historique des exécutions
- Debugging des erreurs
- Retry des exécutions échouées
- Statistiques de performance

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | bigint | ❌ | **ID** - Auto-généré, converti en string pour l'API |
| `finished` | boolean | ❌ | ⚠️ **[DEPRECATED]** - Utiliser `status` |
| `mode` | varchar | ❌ | **Mode** - `trigger` (auto), `manual`, `webhook`, `cli`, `retry`, `internal` |
| `retryOf` | varchar | ✅ | **Retry de** - ID de l'exécution originale si c'est un retry |
| `retrySuccessId` | varchar | ✅ | **Retry réussi** - ID du retry qui a réussi |
| `status` | varchar | ❌ | **Statut** - `new`, `running`, `success`, `error`, `waiting`, `canceled` |
| `createdAt` | datetime | ❌ | **Création** - Quand l'exécution a été créée |
| `startedAt` | datetime | ✅ | **Démarrage** - Quand le traitement a vraiment commencé (null si en queue) |
| `stoppedAt` | datetime | ✅ | **Fin** - Quand l'exécution s'est terminée |
| `deletedAt` | datetime | ✅ | **Suppression** - Soft-delete pour archivage |
| `workflowId` | varchar | ✅ | **Workflow** - Référence (null si workflow supprimé) |
| `waitTill` | datetime | ✅ | **Attente jusqu'à** - Pour les nœuds Wait (ex: attendre 1 heure) |
| `storedAt` | varchar(2) | ❌ | **Stockage données** - `db` (base), `fs` (fichier), `s3` |

---

## 📌 Table: `execution_data`

**Objectif**: Stocke les données volumineuses d'une exécution (séparé pour performance).

**Cas d'usage**:
- Voir les entrées/sorties de chaque nœud
- Rejouer une exécution
- Debug détaillé

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `executionId` | bigint | ❌ | **Exécution** - Référence vers `execution_entity` |
| `data` | text | ❌ | **Données** - Données JSON compressées de tous les nœuds |
| `workflowData` | json | ❌ | **Snapshot workflow** - Copie du workflow au moment de l'exécution |
| `workflowVersionId` | varchar(36) | ✅ | **Version** - Quelle version était active |

---

## 📌 Table: `execution_metadata`

**Objectif**: Métadonnées key-value pour les exécutions.

**Cas d'usage**:
- Tags personnalisés sur les exécutions
- Données de contexte externe
- Filtrage avancé

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `executionId` | varchar | ❌ | **Exécution** - Référence |
| `key` | text | ❌ | **Clé** - Nom de la métadonnée |
| `value` | text | ❌ | **Valeur** - Contenu |

---

## 📌 Table: `execution_annotations` (Enterprise)

**Objectif**: Annotations manuelles sur les exécutions pour l'amélioration des AI agents.

**Cas d'usage**:
- Marquer les bonnes/mauvaises exécutions (👍/👎)
- Ajouter des notes pour l'équipe
- Entraînement des modèles

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | int | ❌ | **ID** - Auto-incrémenté |
| `vote` | varchar | ✅ | **Vote** - `up` (bon), `down` (mauvais), null (pas voté) |
| `note` | varchar | ✅ | **Note** - Commentaire textuel libre |
| `executionId` | varchar | ❌ | **Exécution** - Unique par exécution |

---

# 4. Projets & Partage

Organisent les workflows/credentials en espaces de travail partageables.

---

## 📌 Table: `project`

**Objectif**: Espace de travail regroupant workflows et credentials.

**Cas d'usage**:
- Séparer les environnements (dev/prod)
- Collaboration d'équipe
- Organisation par département

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar(255) | ❌ | **Nom** - Titre du projet |
| `type` | varchar(36) | ❌ | **Type** - `personal` (1 user) ou `team` (multi-users) |
| `icon` | json | ✅ | **Icône** - `{type: 'emoji'/'icon', value: '🚀'}` |
| `description` | varchar(512) | ✅ | **Description** - But du projet |
| `creatorId` | uuid | ✅ | **Créateur** - Utilisateur qui a créé (null si supprimé) |
| `createdAt` | datetime | ❌ | **Date création** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `project_relation`

**Objectif**: Lie les utilisateurs aux projets avec un rôle.

**Cas d'usage**:
- Gérer les membres d'un projet
- Attribuer des rôles par projet

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `userId` | uuid | ❌ | **Utilisateur** - Membre du projet |
| `projectId` | varchar | ❌ | **Projet** - Projet concerné |
| `role` | varchar | ❌ | **Rôle** - Référence vers `role.slug` (projet-level) |
| `createdAt` | datetime | ❌ | **Date ajout** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `shared_workflow`

**Objectif**: Partage d'un workflow avec un projet.

**Cas d'usage**:
- Donner accès à un workflow aux membres d'un projet
- Définir les droits (owner = tout, editor = modifier)

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `workflowId` | varchar | ❌ | **Workflow** - Lequel est partagé |
| `projectId` | varchar | ❌ | **Projet** - Avec qui |
| `role` | varchar | ❌ | **Rôle** - `workflow:owner` ou `workflow:editor` |
| `createdAt` | datetime | ❌ | **Date partage** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `shared_credentials`

**Objectif**: Partage d'un credential avec un projet.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `credentialsId` | varchar | ❌ | **Credential** - Lequel |
| `projectId` | varchar | ❌ | **Projet** - Avec qui |
| `role` | varchar | ❌ | **Rôle** - `credential:owner` ou `credential:user` |
| `createdAt` | datetime | ❌ | **Date partage** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `folder`

**Objectif**: Dossiers pour organiser les workflows.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar | ❌ | **Nom** - Titre du dossier |
| `parentFolderId` | varchar | ✅ | **Parent** - Dossier parent (null = racine) |
| `projectId` | varchar | ❌ | **Projet** - À quel projet appartient le dossier |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 5. Credentials (Identifiants)

Stockage sécurisé des accès aux services externes.

---

## 📌 Table: `credentials_entity`

**Objectif**: Stocke les credentials chiffrés (clés API, mots de passe, tokens).

**Cas d'usage**:
- Connexion à des API tierces (Slack, Google, etc.)
- Authentification base de données
- Accès SFTP, SSH, etc.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar(128) | ❌ | **Nom** - Identifiant lisible (ex: "Prod Slack Bot") |
| `data` | text | ❌ | **Données chiffrées** - Contenu crypté avec la clé d'instance |
| `type` | varchar(128) | ❌ | **Type** - Ex: `slackApi`, `googleOAuth2Api`, `mySql` |
| `isManaged` | boolean | ❌ | **Géré par n8n** - Credentials cloud provisionés automatiquement |
| `isGlobal` | boolean | ❌ | **Global** - Accessible par tous sans partage explicite |
| `isResolvable` | boolean | ❌ | **Résolvable** - Peut être résolu dynamiquement (ex: vault) |
| `resolvableAllowFallback` | boolean | ❌ | **Fallback** - Autoriser fallback si résolution échoue |
| `resolverId` | varchar | ✅ | **Resolver** - ID du resolver dynamique |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 6. Tags & Organisation

Système de tags pour catégoriser les ressources.

---

## 📌 Table: `tag_entity`

**Objectif**: Définition des tags disponibles.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar(24) | ❌ | **Nom** - Unique, max 24 caractères |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `workflows_tags` (jonction)

| Colonne | Type |
|---------|------|
| `workflowId` | varchar |
| `tagId` | varchar |

---

## 📌 Table: `folder_tag` (jonction)

| Colonne | Type |
|---------|------|
| `folderId` | varchar |
| `tagId` | varchar |

---

## 📌 Table: `annotation_tag_entity` (Enterprise)

**Objectif**: Tags spécifiques pour les annotations d'exécution.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar(24) | ❌ | **Nom** - Max 24 caractères, unique |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `execution_annotation_tags` (jonction)

| Colonne | Type |
|---------|------|
| `annotationId` | int |
| `tagId` | varchar |

---

# 7. Variables & Paramètres

Configuration centralisée.

---

## 📌 Table: `variables`

**Objectif**: Variables d'environnement accessibles dans les workflows.

**Cas d'usage**:
- URLs d'environnement (dev/staging/prod)
- Clés de configuration partagées
- Valeurs changeantes sans modifier les workflows

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `key` | text | ❌ | **Clé** - Nom de la variable (ex: `API_BASE_URL`) |
| `type` | text | ❌ | **Type** - `string` (seul supporté actuellement) |
| `value` | text | ❌ | **Valeur** - Contenu de la variable |
| `projectId` | varchar | ✅ | **Projet** - null = variable globale |

---

## 📌 Table: `settings`

**Objectif**: Paramètres système de l'instance n8n.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `key` | varchar | ❌ | **Clé** - Nom du paramètre |
| `value` | varchar | ❌ | **Valeur** - JSON stringifié |
| `loadOnStartup` | boolean | ❌ | **Charger au boot** - Si true, chargé en mémoire au démarrage |

---

## 📌 Table: `processed_data`

**Objectif**: Données traitées par les nœuds de déduplication.

**Cas d'usage**:
- Éviter de retraiter les mêmes items
- Nœud "Remove Duplicates" avec mode "Database"

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `context` | varchar | ❌ | **Contexte** - ID du nœud |
| `workflowId` | varchar | ❌ | **Workflow** |
| `value` | json | ✅ | **Données** - IDs ou hashes des items déjà traités |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 8. Données Binaires

Stockage de fichiers.

---

## 📌 Table: `binary_data`

**Objectif**: Stocke les fichiers binaires en base de données.

**Cas d'usage**:
- Pièces jointes d'exécutions
- Fichiers uploadés via webhooks
- Mode de stockage "database"

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `fileId` | uuid | ❌ | **ID fichier** - Unique |
| `sourceType` | varchar(50) | ❌ | **Source** - `execution` ou `chat_message_attachment` |
| `sourceId` | varchar(255) | ❌ | **ID source** - ID de l'exécution ou message |
| `data` | blob | ❌ | **Contenu** - Données binaires brutes |
| `mimeType` | varchar(255) | ✅ | **Type MIME** - `application/pdf`, `image/png`, etc. |
| `fileName` | varchar(255) | ✅ | **Nom fichier** - Nom original |
| `fileSize` | int | ❌ | **Taille** - En bytes |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 9. Tests (Enterprise)

Validation automatisée des workflows.

---

## 📌 Table: `test_run`

**Objectif**: Représente une session de test d'un workflow.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `status` | varchar | ❌ | **Statut** - `new`, `running`, `completed`, `error`, `cancelled` |
| `runAt` | datetime | ✅ | **Démarrage** - Quand le test a commencé |
| `completedAt` | datetime | ✅ | **Fin** - Quand le test s'est terminé |
| `metrics` | json | ✅ | **Métriques** - Résultats agrégés (succès, échecs, temps, etc.) |
| `errorCode` | varchar(255) | ✅ | **Code erreur** - Si le test global a échoué |
| `errorDetails` | json | ✅ | **Détails erreur** |
| `workflowId` | varchar(255) | ❌ | **Workflow** - Lequel a été testé |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `test_case_execution`

**Objectif**: Résultat d'un cas de test individuel.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `testRunId` | varchar | ❌ | **Test Run** - Appartient à quel run |
| `executionId` | varchar | ✅ | **Exécution** - Exécution créée (null si SET NULL) |
| `status` | varchar | ❌ | **Statut** - `new`, `running`, `evaluation_running`, `success`, `error`, `warning`, `cancelled` |
| `runAt` | datetime | ✅ | **Démarrage** |
| `completedAt` | datetime | ✅ | **Fin** |
| `errorCode` | varchar | ✅ | **Code erreur** |
| `errorDetails` | json | ✅ | **Détails** |
| `metrics` | json | ✅ | **Métriques** - Spécifiques à ce test |
| `inputs` | json | ✅ | **Entrées** - Données injectées |
| `outputs` | json | ✅ | **Sorties** - Résultats obtenus |

---

# 10. OAuth/MCP

Authentification pour le protocole MCP (Model Context Protocol).

---

## 📌 Table: `oauth_clients`

**Objectif**: Clients OAuth enregistrés.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **Client ID** |
| `name` | varchar | ❌ | **Nom** - Affiché sur l'écran de consentement |
| `redirectUris` | json | ❌ | **URIs** - Redirections autorisées |
| `grantTypes` | json | ❌ | **Grants** - Types autorisés (`authorization_code`, `refresh_token`) |
| `tokenEndpointAuthMethod` | varchar | ❌ | **Auth méthode** - `none`, `client_secret_post`, etc. |
| `clientSecret` | varchar | ✅ | **Secret** - Hash du secret client |
| `clientSecretExpiresAt` | int | ✅ | **Expiration** - Timestamp |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `oauth_access_tokens`

| Colonne | Type | Null | Description |
|---------|------|------|-------------|
| `token` | varchar | ❌ | Token d'accès |
| `clientId` | varchar | ❌ | Client OAuth |
| `userId` | uuid | ❌ | Utilisateur |

---

## 📌 Table: `oauth_refresh_tokens`

| Colonne | Type | Null | Description |
|---------|------|------|-------------|
| `token` | varchar | ❌ | Refresh token |
| `clientId` | varchar | ❌ | Client OAuth |
| `userId` | uuid | ❌ | Utilisateur |
| `expiresAt` | int | ❌ | Timestamp expiration |
| `createdAt` | datetime | ❌ | Date |
| `updatedAt` | datetime | ❌ | Modification |

---

## 📌 Table: `oauth_authorization_codes`

| Colonne | Type | Null | Description |
|---------|------|------|-------------|
| `code` | varchar | ❌ | Code d'autorisation |
| `clientId` | varchar | ❌ | Client OAuth |
| `userId` | uuid | ❌ | Utilisateur |
| `redirectUri` | varchar | ❌ | URI de redirection |
| `codeChallenge` | varchar | ❌ | PKCE challenge |
| `codeChallengeMethod` | varchar | ❌ | PKCE méthode |
| `state` | varchar | ✅ | State parameter |
| `expiresAt` | int | ❌ | Expiration |
| `used` | boolean | ❌ | Déjà utilisé |
| `createdAt` | datetime | ❌ | Date |
| `updatedAt` | datetime | ❌ | Modification |

---

## 📌 Table: `oauth_user_consents`

| Colonne | Type | Null | Description |
|---------|------|------|-------------|
| `id` | int | ❌ | ID auto |
| `userId` | uuid | ❌ | Utilisateur |
| `clientId` | varchar | ❌ | Client |
| `grantedAt` | bigint | ❌ | Timestamp consentement |

---

# 11. ChatHub (IA)

Conversations avec agents LLM intégrés.

---

## 📌 Table: `chat_hub_agents`

**Objectif**: Configuration des agents IA personnalisés.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | uuid | ❌ | **ID** |
| `name` | varchar(128) | ❌ | **Nom** - Affiché dans l'interface |
| `description` | varchar(512) | ✅ | **Description** |
| `icon` | json | ✅ | **Icône** - Emoji ou icône |
| `systemPrompt` | text | ❌ | **System prompt** - Instructions pour l'agent |
| `ownerId` | uuid | ❌ | **Propriétaire** |
| `credentialId` | varchar(36) | ✅ | **Credential LLM** - Clé API OpenAI/Anthropic/etc. |
| `provider` | varchar(16) | ✅ | **Provider** - `openai`, `anthropic`, `google` |
| `model` | varchar(64) | ✅ | **Modèle** - `gpt-4o`, `claude-3.5-sonnet`, etc. |
| `tools` | json | ❌ | **Outils** - Nœuds n8n disponibles pour l'agent |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `chat_hub_sessions`

**Objectif**: Conversations/sessions de chat.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | uuid | ❌ | **ID** |
| `title` | varchar(256) | ❌ | **Titre** - Généré automatiquement ou défini |
| `ownerId` | uuid | ❌ | **Propriétaire** |
| `lastMessageAt` | datetime | ❌ | **Dernier message** - Pour tri par activité |
| `credentialId` | varchar(36) | ✅ | **Credential** |
| `provider` | varchar(16) | ✅ | **Provider** |
| `model` | varchar(256) | ✅ | **Modèle** |
| `workflowId` | varchar(36) | ✅ | **Workflow agent** - Si agent basé sur workflow |
| `agentId` | uuid | ✅ | **Agent ChatHub** |
| `agentName` | varchar(128) | ✅ | **Nom agent (cache)** |
| `tools` | json | ❌ | **Outils** |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `chat_hub_messages`

**Objectif**: Messages individuels dans une session.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | uuid | ❌ | **ID** |
| `sessionId` | uuid | ❌ | **Session** |
| `type` | varchar(16) | ❌ | **Type** - `human`, `ai`, `system`, `tool` |
| `name` | varchar(128) | ❌ | **Expéditeur** - Nom affiché |
| `content` | text | ❌ | **Contenu** - Texte du message |
| `provider` | varchar(16) | ✅ | **Provider** - Null pour messages humains |
| `model` | varchar(256) | ✅ | **Modèle** |
| `workflowId` | varchar(36) | ✅ | **Workflow source** |
| `agentId` | uuid | ✅ | **Agent source** |
| `executionId` | int | ✅ | **Exécution** - Liée au message |
| `previousMessageId` | varchar | ✅ | **Message précédent** |
| `retryOfMessageId` | varchar | ✅ | **Retry de** |
| `revisionOfMessageId` | varchar | ✅ | **Révision de** |
| `status` | varchar(16) | ❌ | **Statut** - `running`, `success`, `error` |
| `attachments` | json | ✅ | **Pièces jointes** |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 12. DataTables

Stockage de données structurées.

---

## 📌 Table: `data_table`

**Objectif**: Tables de données utilisateur.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `name` | varchar | ❌ | **Nom** |
| `projectId` | varchar | ❌ | **Projet** |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `data_table_column`

**Objectif**: Colonnes d'une DataTable.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | varchar | ❌ | **ID** - NanoId |
| `dataTableId` | varchar | ❌ | **Table parente** |
| `name` | varchar | ❌ | **Nom colonne** |
| `type` | varchar | ❌ | **Type** - `string`, `number`, `boolean`, `date` |
| `index` | int | ❌ | **Position** - Ordre d'affichage |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# 13. Packages Communautaires

Nœuds installés depuis npm.

---

## 📌 Table: `installed_packages`

**Objectif**: Packages npm installés.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `packageName` | varchar | ❌ | **Nom npm** - Ex: `n8n-nodes-google-drive` |
| `installedVersion` | varchar | ❌ | **Version** |
| `authorName` | varchar | ✅ | **Auteur** |
| `authorEmail` | varchar | ✅ | **Email auteur** |
| `createdAt` | datetime | ❌ | **Date installation** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

## 📌 Table: `installed_nodes`

**Objectif**: Nœuds fournis par les packages.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `type` | varchar | ❌ | **Type nœud** - Identifiant technique |
| `name` | varchar | ❌ | **Nom affiché** |
| `latestVersion` | int | ❌ | **Version** |
| `package` | varchar | ❌ | **Package** - Référence npm |

---

# 14. Log Streaming (Enterprise)

Export des événements vers des destinations externes.

---

## 📌 Table: `event_destinations`

**Objectif**: Configuration des destinations de logs.

| Colonne | Type | Null | Description & Utilité |
|---------|------|------|----------------------|
| `id` | uuid | ❌ | **ID** |
| `destination` | json | ❌ | **Configuration** - Type, URL, auth, filtres, etc. |
| `createdAt` | datetime | ❌ | **Date** |
| `updatedAt` | datetime | ❌ | **Modification** |

---

# Résumé statistique

| Catégorie | Nombre de tables |
|-----------|-----------------|
| Identité & Auth | 8 |
| Workflows | 6 |
| Exécutions | 6 |
| Projets & Partage | 6 |
| Credentials | 1 |
| Tags | 4 |
| Variables | 3 |
| Binary Data | 1 |
| Tests | 2 |
| OAuth/MCP | 5 |
| ChatHub | 3 |
| DataTables | 2 |
| Community Packages | 2 |
| Log Streaming | 1 |
| **TOTAL** | **50** |

---

# Notes techniques

## Types de colonnes par base de données

| TypeORM | SQLite | PostgreSQL | MySQL |
|---------|--------|------------|-------|
| `json` | simple-json | json | json |
| `datetime` | datetime | timestamptz | datetime |
| `binary` | blob | bytea | longblob |

## Classes de base (Mixins)

- **`WithStringId`**: Ajoute `id` (varchar, NanoId auto-généré)
- **`WithCreatedAt`**: Ajoute `createdAt`
- **`WithUpdatedAt`**: Ajoute `updatedAt` (auto-update)
- **`WithTimestamps`**: Combine les deux timestamps
- **`WithTimestampsAndStringId`**: Tout combiné

## Fichiers sources

- **Entités core**: `packages/@n8n/db/src/entities/`
- **Entités OAuth**: `packages/cli/src/modules/mcp/database/entities/`
- **Entités ChatHub**: `packages/cli/src/modules/chat-hub/`
- **Migrations**: `packages/@n8n/db/src/migrations/{sqlite,postgresdb,mysqldb}/`
