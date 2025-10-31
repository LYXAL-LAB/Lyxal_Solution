# Schémas de Validation Sentinel

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à Sentinel dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `bulkDeleteSentinelActivitiesSchema`

Schéma pour la validation des demandes de suppression en masse d'activités Sentinel.

**Champs requis:**
- `ids` (array): Tableau d'identifiants des activités à supprimer.

**Contraintes:**
- Le tableau `ids` doit contenir au moins un élément.

**Exemple d'utilisation:**

```typescript
import { validateBulkDeleteSentinelActivities } from '../validators/sentinelValidation';

// Données à valider
const requestData = {
  ids: ['activity1', 'activity2', 'activity3']
};

// Validation
try {
  const validatedData = validateBulkDeleteSentinelActivities(requestData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `BulkDeleteSentinelActivitiesData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/sentinelValidation.ts`:

- `validateBulkDeleteSentinelActivities(data: unknown): BulkDeleteSentinelActivitiesData` 