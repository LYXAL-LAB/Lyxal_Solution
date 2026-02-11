### À compléter plus tard — Suppression complète d’un pattern (system_tag_pattern)

Objectif: lors de `fn::system_tag_pattern_delete`, supprimer aussi les ressources i18n liées au pattern (clés et traductions), de façon transactionnelle et idempotente.

Éléments à implémenter:
- Vérifier qu’aucun `system_tag` n’est rattaché (déjà fait dans la fn actuelle).
- Supprimer les clés i18n du pattern (générées à partir de `name`):
  - key.name = replace(name, '_' -> '.')
  - key.description = key.name + '.description'
- Supprimer les traductions associées aux 2 clés précédentes (toutes langues).
- Encapsuler dans une transaction: BEGIN → suppressions i18n → suppression pattern → COMMIT; CANCEL et retour structuré en cas d’échec.
- Journaliser via `fn::system_tag_pattern_log_helper` (start/done, success/failure/error) avec `messages.key` i18n.
- Respecter le format de retour standard (success, message, pattern: NONE, run_id, reason_code, messages{ key, vars, fallback }).
- Respecter `is_protected`: refuser la suppression si true (à ajouter si nécessaire).

Fonctions i18n à utiliser (quand disponibles):
- `fn::i18n_key_delete_record(key: string)` — suppression idempotente d’une clé i18n.
- (Option) une fonction utilitaire pour supprimer toutes les traductions d’une clé (si séparée de `i18n_key_delete_record`).

Clés i18n à prévoir (si manquantes):
- `system_tag_pattern.delete.keys_cleanup_failed`
- `system_tag_pattern.delete.translations_cleanup_failed`
- `system_tag_pattern.delete.protected`

Notes:
- En cas d’échec d’une étape i18n, CANCEL et retour d’erreur structuré (messages.key + vars { pattern_id, key }).
- Les tags de log doivent utiliser `table_system_tag_pattern`.

