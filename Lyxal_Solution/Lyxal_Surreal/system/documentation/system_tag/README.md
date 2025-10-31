## Clés i18n pour system_tag (UI)

Ce module expose des clés i18n utilisées pour traduire les messages liés aux opérations sur les tags (suppression, etc.).

### Clés et messages (FR)

- system_tag.delete.success: "Tag supprimé avec succès."
  - vars: { id, name }
- system_tag.delete.protected: "Le tag {name} est protégé et ne peut pas être supprimé."
  - vars: { id, name }
- system_tag.delete.not_found: "Le tag {id} n'existe pas."
  - vars: { id }
- system_tag.delete.not_applied: "La suppression n’a pas été appliquée."
  - vars: { id, name }
 - system_tag.delete.start: "Suppression du tag en cours..."
   - vars: { id, name }

- system_tag.create.start: "Création du tag en cours..."
  - vars: { name }
- system_tag.create.name_required: "Le nom est requis."
  - vars: { }
- system_tag.create.description_required: "La description est requise."
  - vars: { }
- system_tag.create.user_required: "L'utilisateur est requis."
  - vars: { }
- system_tag.create.pattern_required: "Le pattern de tag est requis."
  - vars: { }
- system_tag.create.name_invalid: "Le nom n'est pas valide."
  - vars: { name }
- system_tag.create.uniqueness_violated: "Unicité violée: un tag avec ce nom existe déjà."
  - vars: { name }
- system_tag.create.description_invalid: "La description n'est pas valide."
  - vars: { description }
- system_tag.create.color_invalid: "La couleur n'est pas valide."
  - vars: { color }
- system_tag.create.success: "Tag '{name}' créé avec succès."
  - vars: { name }
 
## Clés i18n pour system_tag_pattern (UI)

### Clés et messages (FR)

- system_tag_pattern.create.name_required: "Le nom du pattern est requis"
  - vars: { name }
- system_tag_pattern.create.format_invalid: "Le nom doit être en snake_case [a-z0-9_]"
  - vars: { name }
- system_tag_pattern.create.uniqueness_violated: "Un pattern avec ce nom existe déjà"
  - vars: { name }
- system_tag_pattern.create.parent_not_found: "Le parent indiqué est introuvable"
  - vars: { parent_id, name }
- system_tag_pattern.create.not_applied: "Création non appliquée"
  - vars: { name }
- system_tag_pattern.create.success: "Pattern '{name}' créé avec succès"
  - vars: { name }

- system_tag_pattern.not_implemented: "Fonction non implémentée"
  - vars: { fn, action }

### Clés i18n techniques (retours imbriqués)

- i18n_key.create.error: "Erreur lors de la création de la clé i18n {key}"
  - vars: { key, pattern_id, name }
- i18n_translation.upsert.error: "Erreur lors de l'upsert de traduction {key}"
  - vars: { key, pattern_id, name }

### Clés génériques d'erreur (réutilisables pour create/update/delete)

- system_tag.error.not_found: "Le tag {id} n'existe pas."
  - vars: { id, name }
- system_tag.error.protected: "Le tag {name} est protégé et ne peut pas être modifié."
  - vars: { id, name }
- system_tag.error.version_mismatch: "Le tag {id} a une version différente et ne peut pas être mis à jour."
  - vars: { id, name }
- system_tag.error.order_mismatch: "La position du tag {id} est différente et ne peut pas être mise à jour."
  - vars: { id, name }
- system_tag.error.order_invalid: "La position doit être un nombre."
  - vars: { id, name }
- system_tag.error.color_invalid: "La couleur n'est pas valide."
  - vars: { color }
- system_tag.error.at_least_one_field_required: "Au moins un champ est requis."
  - vars: { id, name }
 - system_tag.error.not_applied: "La mise à jour n’a pas été appliquée."
  - vars: { id, name }

### Clés spécifiques update

- system_tag.update.start: "Mise à jour du tag en cours..."
  - vars: { id, name }
- system_tag.update.success: "Le tag {id} a été mis à jour avec succès."
  - vars: { id, name }
 - system_tag.create.label_required: "Le libellé est requis."
   - vars: { }
 - system_tag.create.lang_required: "La langue par défaut est requise."
   - vars: { }
 - system_tag.create.lang_unknown: "Langue par défaut inconnue: {lang}."
   - vars: { lang }

### Notes d'intégration UI

- Utiliser `messages.key` et `messages.vars` renvoyés par la fonction pour résoudre la traduction côté client.
- En cas d'absence de traduction, afficher `messages.fallback` (message français fourni par le backend).
- `reason_code` peut être utilisé pour des comportements spécifiques (ex: TAG_NOT_FOUND, TAG_PROTECTED, DELETE_NOT_APPLIED).

### Exemple d'affichage (pseudo-code)

```ts
const { key, vars, fallback } = response.messages;
const text = i18n.t(key, vars) ?? fallback;
```
