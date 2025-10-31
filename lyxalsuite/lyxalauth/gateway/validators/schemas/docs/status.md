# Documentation des schémas de validation pour Status

Ce document décrit les schémas de validation utilisés pour la vérification de l'état de santé dans l'API Gateway.

## Schémas disponibles

### HealthCheckSchema

Ce schéma permet de valider les paramètres de requête pour la vérification de l'état de santé du service.

```typescript
export const healthCheckSchema = z.object({
  detailed: z.boolean().optional(),
  timeout: z.number().int().min(100).optional()
}).optional();
```

#### Exemple d'utilisation

```typescript
// Exemple de paramètres valides pour la vérification de l'état de santé
const validParams = {
  detailed: true,  // Demande des informations détaillées
  timeout: 5000    // Timeout de 5 secondes
};

// Validation
const result = validateHealthCheck(validParams);
```

## Intégration avec les routes

Ces schémas sont utilisés dans les middlewares de validation pour les routes liées à la vérification de l'état de santé :

```typescript
import { validateHealthCheck } from '../validators/statusValidation';

// Route pour la vérification de l'état de santé
app.get('/api/status', validateHealthCheck());
``` 