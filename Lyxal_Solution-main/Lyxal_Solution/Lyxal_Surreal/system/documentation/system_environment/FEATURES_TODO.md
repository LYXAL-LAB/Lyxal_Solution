# System Environment - Fonctionnalités futures

> **Note** : Ces fonctionnalités sont documentées pour une implémentation future potentielle. Certaines pourraient devenir obsolètes ou natives au fur et à mesure du développement du système.

## 1. Métadonnées et configuration

### Configuration par environment
- **Description** : Stockage de paramètres spécifiques (limits, quotas, features)
- **Implémentation suggérée** :
  ```sql
  DEFINE FIELD IF NOT EXISTS config ON system_environment 
  FLEXIBLE TYPE object DEFAULT {}
  COMMENT "Configuration spécifique de l'environment";
  ```
- **Cas d'usage** : Limites de ressources, features activées/désactivées, quotas utilisateurs

### Métadonnées personnalisées
- **Description** : Champs JSON pour données spécifiques au client
- **Implémentation suggérée** :
  ```sql
  DEFINE FIELD IF NOT EXISTS metadata ON system_environment 
  FLEXIBLE TYPE object DEFAULT {}
  COMMENT "Métadonnées personnalisées client";
  ```
- **Cas d'usage** : Tags personnalisés, informations business, références externes

## 2. Gestion avancée

### Clone/Duplicate
- **Description** : Dupliquer un environment avec ses configurations
- **Fonction suggérée** : `fn::system_environment_clone($source_id, $new_name, $new_parent?)`
- **Points d'attention** :
  - Copier les configurations mais pas les données
  - Générer de nouveaux IDs
  - Conserver les relations de tags pertinentes

### Archive
- **Description** : État supplémentaire pour archivage long terme
- **Implémentation** : Ajouter tag `system_environment_archived`
- **Comportement** : 
  - Lecture seule
  - Exclus des requêtes par défaut
  - Conservation longue durée

### Expiration
- **Description** : Date d'expiration automatique pour trials
- **Implémentation suggérée** :
  ```sql
  DEFINE FIELD IF NOT EXISTS expires_at ON system_environment 
  TYPE option<datetime>
  COMMENT "Date d'expiration de l'environment";
  ```
- **Automatisation** : Job schedulé pour passer en état `suspended` à expiration

## 3. Relations et intégrations

### Owner/Contact
- **Description** : Lien vers utilisateur responsable
- **Implémentation** : 
  ```sql
  DEFINE FIELD IF NOT EXISTS owner ON system_environment 
  TYPE option<record<system_user>>
  COMMENT "Utilisateur propriétaire";
  ```
- **Alternative** : Utiliser une relation `system_environment_owner`

### Billing
- **Description** : Lien vers informations de facturation
- **Note** : Pourrait être géré via module `system_billing` séparé
- **Relation suggérée** : `system_environment_billing_plan`

### Resources
- **Description** : Tracking des ressources utilisées
- **Implémentation potentielle** :
  - Table `system_environment_resources` pour historique
  - Métriques : storage, compute, bandwidth
  - Agrégations périodiques

## 4. Audit et sécurité

### History/Audit trail
- **Description** : Historique des modifications
- **Note** : Pourrait être natif via `system_log` étendu
- **Alternatives** :
  - Event sourcing sur les changements
  - Table dédiée `system_environment_history`
  - Triggers sur UPDATE

### Permissions spécifiques
- **Description** : Au-delà du FULL actuel
- **Granularité suggérée** :
  - READ : Consultation uniquement
  - WRITE : Modifications autorisées
  - DELETE : Suppression autorisée
  - ADMIN : Gestion complète
- **Note** : Attendre l'évolution du système de permissions SurrealDB

### Backup state
- **Description** : État et métadonnées de sauvegarde
- **Champs suggérés** :
  ```sql
  DEFINE FIELD IF NOT EXISTS last_backup_at ON system_environment 
  TYPE option<datetime>;
  DEFINE FIELD IF NOT EXISTS backup_status ON system_environment 
  TYPE option<string>;
  ```
- **Intégration** : Avec système de backup externe

## Notes d'implémentation

1. **Priorité** : Évaluer le besoin réel avant implémentation
2. **Modularité** : Certaines features pourraient être des modules séparés
3. **Performance** : Attention aux champs FLEXIBLE pour les requêtes
4. **Migration** : Prévoir les scripts de migration pour ajout de champs

## Révisions

- **Date création** : [Date du jour]
- **Dernière mise à jour** : [À maintenir]
- **Statut** : En attente d'évaluation des besoins
