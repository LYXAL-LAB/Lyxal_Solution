# Schémas de Validation Swagger

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la documentation Swagger dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `swaggerFilterSchema`

Schéma pour la validation des filtres appliqués à la documentation Swagger. Ce schéma est principalement utilisé pour filtrer les opérations d'API dans des cas spécifiques.

**Champs optionnels:**
- `tags` (string[]): Filtrer par les tags OpenAPI/Swagger.
- `paths` (string[]): Filtrer par les chemins d'API.
- `operations` (string[]): Filtrer par les types d'opérations (get, post, etc.).

**Exemple d'utilisation:**

```typescript
import { swaggerFilterSchema } from '../validators/schemas/swaggerSchemas';

// Données à valider
const filterData = {
  tags: ['users', 'auth'],
  paths: ['/users', '/auth'],
  operations: ['get', 'post']
};

// Validation
try {
  const validatedData = swaggerFilterSchema.parse(filterData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `SwaggerFilterData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/swaggerValidation.ts`:

- `validateSwaggerFilter(data: unknown): SwaggerFilterData`

## Notes spécifiques

Les routes Swagger actuelles ne nécessitent généralement pas de validation d'entrée utilisateur car elles sont principalement des endpoints GET qui servent la documentation OpenAPI. Les schémas et validateurs fournis ici sont conçus pour maintenir la cohérence de l'architecture et pour prendre en charge d'éventuelles fonctionnalités futures. 