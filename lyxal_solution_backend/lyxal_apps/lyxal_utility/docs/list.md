# Module : List
Lieu : `core/src/function/list.rs`

Ce module fournit des primitives de haut niveau pour la manipulation, l'agrégation et la comparaison de collections de données (tableaux d'objets).

| Fonction Lyxal | Arguments | Retour | Description |
| :--- | :--- | :--- | :--- |
| **`list::dedupe`** | `(array, field)` | `array` | Supprime les doublons basés sur la valeur d'un champ spécifique. |
| **`list::aggregate`** | `(array, field, op)` | `any` | Effectue une opération ("sum", "avg", "min", "max", "collect") sur un champ. |
| **`list::split_out`** | `(array, field)` | `array` | Éclate un sous-tableau en plusieurs lignes en clonant l'objet parent. |
| **`list::diff`** | `(base, new, key)` | `object` | Compare deux listes et retourne les ajouts, suppressions et modifications détaillées. |

## Détails des structures de retour

### list::diff
Retourne un objet structuré pour piloter des automatisations basées sur le changement :
```json
{
  "added": [...],
  "removed": [...],
  "modified": [
    {
      "key": "valeur_cle",
      "before": { ... },
      "after": { ... },
      "changes": ["champ1", "champ2"]
    }
  ]
}
```

### list::aggregate
Les opérations supportées sont :
- `sum` : Somme numérique des valeurs.
- `avg` : Moyenne numérique.
- `min` / `max` : Valeurs extrêmes.
- `collect` : Extrait toutes les valeurs du champ dans un tableau simple.
