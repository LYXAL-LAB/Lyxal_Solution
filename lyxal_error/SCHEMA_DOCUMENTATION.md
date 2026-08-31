# 📐 Documentation Technique des Schémas — `lyxal_error`

Ce document présente la structure détaillée des tables, contraintes, index et conventions du module **`lyxal_error`**.

---

## 1. 🏷️ Convention de Nommage des Codes d'Erreurs

Tous les codes d'erreurs canoniques doivent respecter la structure stricte suivante :

```text
<MODULE>_<DOMAINE>_<CAUSE>
```

### Exemples Canoniques :
- `BOOKING_USERNAME_EMAIL_REQUIRED`
- `BOOKING_USERNAME_EMAIL_INVALID`
- `BOOKING_SLOT_ALREADY_TAKEN`
- `AUTH_TOKEN_EXPIRED`
- `CORE_ERROR_DEFINITION_NOT_FOUND`
- `NOTIFICATION_PROVIDER_TIMEOUT`

---

## 2. 📋 Table `error_definition`

Catalogue canonique des codes d'erreurs master data, messages techniques, catégories, statuts HTTP et dictionnaire de traductions.

```surrealql
DEFINE TABLE IF NOT EXISTS error_definition TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;
```

### Champs & Contraintes :
| Champ | Type | Validation / Par Défaut | Description |
| :--- | :--- | :--- | :--- |
| `code` | `string` | `UPPERCASE`, regex `^[A-Z][A-Z0-9_]{2,127}$` | Code canonique unique |
| `module` | `string` | `LOWERCASE`, regex `^[a-z][a-z0-9_-]{1,63}$` | Module propriétaire (`booking`, `auth`, etc.) |
| `domain` | `option<string>` | `LOWERCASE` | Sous-domaine fonctionnel (`username`, `slot`, etc.) |
| `category` | `string` | `"business"` (dans `validation`, `business`, `authentication`, `authorization`, `not_found`, `conflict`, `rate_limit`, `dependency`, `network`, `timeout`, `internal`) | Catégorie normalisée |
| `severity` | `string` | `"error"` (dans `info`, `warning`, `error`, `critical`) | Niveau de gravité |
| `message` | `string` | Longueur 1-1000 | Message technique anglais canonique |
| `translations` | `object FLEXIBLE` | `{}` | Dictionnaire par code langue (`fr`, `en`) |
| `default_language` | `string` | `"en"`, regex `^[a-z]{2}(-[a-z]{2})?$` | Langue de repli linguistique |
| `http_status` | `option<int>` | Dans la plage `400-599` | Statut HTTP recommandé pour les APIs REST |
| `retryable` | `bool` | `false` | Indique si l'opération peut être retentée |
| `log_occurrence` | `bool` | `true` | Indique si l'occurrence doit être loguée |
| `enabled` | `bool` | `true` | Désactivation logique (*soft delete*) |
| `created_at` | `datetime` | `time::now()` | Date de création immuable |
| `updated_at` | `datetime` | `time::now()` | Date de dernière modification |

### Index :
- `error_definition_code_unique` ON `code` `UNIQUE`
- `error_definition_module_index` ON `module`
- `error_definition_module_domain_index` ON `module, domain`
- `error_definition_category_index` ON `category`
- `error_definition_enabled_index` ON `enabled`

---

## 3. 📜 Table `error_occurrence`

Journal technique *append-only* enregistrant chaque apparition d'erreur pour la traçabilité, le debugging et l'auditabilité.

```surrealql
DEFINE TABLE IF NOT EXISTS error_occurrence TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;
```

### Champs & Contraintes :
| Champ | Type | Description |
| :--- | :--- | :--- |
| `definition` | `option<record<error_definition>>` | Référence facultative au catalogue |
| `code` | `string` | Copie immuable du code au moment de l'erreur |
| `source_module` | `string` | Module ayant produit l'erreur |
| `operation` | `option<string>` | Nom de l'opération/fonction |
| `source` | `option<record>` | Enregistrement métier concerné (ex: `booking:xyz`) |
| `actor` | `option<record>` | Identité/Compte ayant déclenché l'opération |
| `technical_message` | `option<string>` | Message d'erreur technique brut (traceback/stack) |
| `context` | `object FLEXIBLE` | Contexte structuré nettoyé (**ZÉRO SECRET**) |
| `trace_id` | `option<string>` | Identifiant de trace distribuée |
| `correlation_id` | `option<string>` | Identifiant de corrélation |
| `environment` | `string` | `"production"` (ou `development`, `test`, `staging`) |
| `severity` | `string` | Copie immuable de la sévérité |
| `occurred_at` | `datetime` | Horodatage immuable de survenance |

> [!CAUTION]
> **Sécurité du Contexte (`context`)** : Ne jamais stocker de jetons OAuth, mots de passe, clés d'API, cookies de session ou données personnelles identifiables dans le champ `context`.

---

## 4. 🔌 Table `error_external_mapping`

Mapping des erreurs retournées par les fournisseurs ou protocoles externes (Google, CalDAV, SMTP, Stripe) vers les codes canoniques Lyxal.

```surrealql
DEFINE TABLE IF NOT EXISTS error_external_mapping TYPE NORMAL SCHEMAFULL PERMISSIONS NONE;
```

### Champs & Contraintes :
| Champ | Type | Validation | Description |
| :--- | :--- | :--- | :--- |
| `provider` | `string` | `LOWERCASE` | Fournisseur (`google`, `smtp`, `caldav`, `stripe`) |
| `service` | `option<string>` | `LOWERCASE` | Sous-service (`oauth`, `calendar`, `drive`) |
| `external_code` | `string` | Code externe (ex: `invalid_grant`, `401`, `535`) |
| `matcher` | `string` | Dans `["exact", "prefix", "contains", "http_status"]` | Méthode de correspondance |
| `definition` | `record<error_definition>` | Code canonique Lyxal cible |
| `priority` | `int` | `>= 0` (Par défaut `100`) | Priorité d'évaluation (ordre croissant) |
| `retryable_override` | `option<bool>` | Surcharge facultative du caractère retentable |
| `enabled` | `bool` | `true` | Activation de la règle de mapping |

---

## 5. 🌐 Algorithme de Repli Linguistique (`fn::error_resolve`)

Lorsqu'un utilisateur demande un message traduit dans la langue `$lang` :

```text
1. Rechercher $translations[$lang] (Ex: "fr")
      │ (Non trouvé)
      ▼
2. Rechercher $translations[$default_language] (Ex: "en")
      │ (Non trouvé)
      ▼
3. Utiliser $definition.message (Message canonique technique)
```
