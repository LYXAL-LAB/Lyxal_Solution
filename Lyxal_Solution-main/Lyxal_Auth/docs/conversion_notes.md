# Notes de Conversion SQL -> SurrealQL
Ce document recense les éléments du schéma Logto qui n'ont pas pu être convertis directement en définitions de table SurrealDB (Fonctions, Triggers, Contraintes complexes).

## Global
- Les clés primaires composites (ex: `tenant_id, id`) sont gérées via des `DEFINE INDEX ... UNIQUE` dans SurrealDB, car SurrealDB utilise un ID unique par enregistrement.
- Les types `varchar(n)` sont convertis en `string` (SurrealDB ne limite pas la taille par défaut, sauf assertion spécifique).

## Fichiers Traités

### application_secrets.surql
- **Contrainte ignorée** : `constraint application_type check (check_application_type(application_id, ...))`
  - *Raison* : Appel à une fonction PL/pgSQL `check_application_type`. Nécessite une réécriture en fonction SurrealDB ou une logique applicative.

### applications.surql
- **Index JSONB** : Les index sur les champs JSON (`protected_app_metadata->>'host'`) nécessitent une syntaxe spécifique SurrealDB.
- **Fonction** : `create function check_application_type` n'est pas convertie ici.

### applications_roles.surql
- **Contrainte ignorée** : `constraint applications_roles__role_type check (public.check_role_type(...))`
  - *Raison* : Appel à une fonction PL/pgSQL.

### custom_profile_fields.surql
- **Trigger ignoré** : `custom_profile_fields__increment_sie_order`
  - *Raison* : Logique procédurale SQL (PL/pgSQL) pour l'auto-incrément. Doit être géré par l'application ou un Event SurrealDB.

### oidc_session_extensions.surql
- **Trigger ignoré** : `set_updated_at`
  - *Raison* : Trigger standard de mise à jour de timestamp. Peut être géré par `DEFAULT ALWAYS time::now()` sur le champ `updated_at` (déjà fait).

### organization_application_relations.surql
- **Contrainte ignorée** : `check(check_application_type(...))`
  - *Raison* : Fonction SQL.

### organization_invitations.surql
- **Index Partiel ignoré** : `unique index ... where status = 'Pending'`
  - *Raison* : SurrealDB ne supporte pas les index partiels conditionnels. L'unicité doit être vérifiée par l'application avant insertion.

### organization_role_application_relations.surql
- **Contrainte ignorée** : `check(check_organization_role_type(...))`
  - *Raison* : Fonction SQL.

### organization_role_user_relations.surql
- **Contrainte ignorée** : `check(check_organization_role_type(...))`
  - *Raison* : Fonction SQL.

### organization_roles.surql
- **Fonction ignorée** : `create function check_organization_role_type`
  - *Raison* : Fonction PL/pgSQL.

### resources.surql
- **Index Partiel ignoré** : `unique index ... where is_default = true`
  - *Raison* : SurrealDB ne supporte pas les index partiels conditionnels.

### roles.surql
- **Fonction ignorée** : `create function check_role_type`
  - *Raison* : Fonction PL/pgSQL.

### saml_application_configs.surql
- **Contrainte ignorée** : `check(check_application_type(...))`
  - *Raison* : Fonction SQL.

### saml_application_secrets.surql
- **Contrainte ignorée** : `check(check_application_type(...))`
  - *Raison* : Fonction SQL.
- **Index Partiel ignoré** : `unique index ... where active`
  - *Raison* : SurrealDB ne supporte pas les index partiels conditionnels.

### saml_application_sessions.surql
- **Contrainte ignorée** : `check(check_application_type(...))`
  - *Raison* : Fonction SQL.

### secret_enterprise_sso_connector_relations.surql
- **Triggers ignorés** : `delete_secrets_on_sso_connector_delete`, `delete_secret_on_sso_identity_delete`
  - *Raison* : Logique procédurale complexe (Cascade Delete conditionnel). Doit être géré par l'application ou des Events SurrealDB.

### secret_social_connector_relations.surql
- **Triggers ignorés** : `delete_secrets_on_social_connector_delete`, `delete_secrets_on_social_identity_delete`
  - *Raison* : Logique procédurale complexe.

### secrets.surql
- **Trigger ignoré** : `set_updated_at`
  - *Raison* : Standard timestamp update.

### sso_connector_idp_initiated_auth_configs.surql
- **Contrainte ignorée** : `check(check_application_type(...))`
  - *Raison* : Fonction SQL.

### user_sso_identities.surql
- **Trigger ignoré** : `set_updated_at`
  - *Raison* : Standard timestamp update.

### users.surql
- **Trigger ignoré** : `set_updated_at`
  - *Raison* : Standard timestamp update.

### users_roles.surql
- **Contrainte ignorée** : `check(check_role_type(...))`
  - *Raison* : Fonction SQL.
