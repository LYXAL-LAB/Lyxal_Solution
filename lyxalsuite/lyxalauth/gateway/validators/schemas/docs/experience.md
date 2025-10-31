# Documentation des schémas de validation pour l'Expérience Utilisateur

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à l'expérience utilisateur dans l'API Gateway.

## initInteractionSchema

Ce schéma valide les données pour l'initialisation d'une interaction utilisateur.

### Structure

```typescript
{
  redirectUri: string,          // URI de redirection (obligatoire, doit être une URL valide)
  clientId?: string,            // ID du client (optionnel)
  state?: string,               // État (optionnel)
  scope?: string,               // Portée (optionnel)
  nonce?: string,               // Nonce (optionnel)
  responseType?: string,        // Type de réponse (optionnel)
  codeChallenge?: string,       // Challenge de code (optionnel)
  codeChallengeMethod?: string, // Méthode de challenge de code (optionnel)
  maxAge?: number,              // Âge maximum (optionnel)
  responseMode?: string,        // Mode de réponse (optionnel)
  idTokenHint?: string,         // Indice de jeton d'identité (optionnel)
  prompt?: string,              // Invite (optionnel)
  loginHint?: string,           // Indice de connexion (optionnel)
  acr?: string,                 // ACR (optionnel)
  connector?: string,           // Connecteur (optionnel)
  authorizationId?: string      // ID d'autorisation (optionnel)
}
```

### Type inféré

```typescript
type InitInteractionData = z.infer<typeof initInteractionSchema>;
```

## updateInteractionEventSchema

Ce schéma valide les données pour la mise à jour d'un événement d'interaction.

### Structure

```typescript
{
  event: string,     // Événement (obligatoire, non vide)
  params?: Record<string, unknown> // Paramètres (optionnel)
}
```

### Type inféré

```typescript
type UpdateInteractionEventData = z.infer<typeof updateInteractionEventSchema>;
```

## identifyUserSchema

Ce schéma valide les données pour l'identification d'un utilisateur.

### Structure

```typescript
{
  email?: string,        // Email (optionnel, doit être un email valide)
  phone?: string,        // Téléphone (optionnel)
  username?: string,     // Nom d'utilisateur (optionnel)
  connectorId?: string,  // ID du connecteur (optionnel)
  code?: string          // Code (optionnel)
}
```

### Règles de validation

- Au moins une des propriétés suivantes doit être fournie :
  - `email`
  - `phone`
  - `username`
  - OU la combinaison de `connectorId` et `code`

### Type inféré

```typescript
type IdentifyUserData = z.infer<typeof identifyUserSchema>;
```

## submitInteractionSchema

Ce schéma valide les données pour la soumission d'une interaction.

### Structure

```typescript
{
  verifierId?: string,        // ID du vérificateur (optionnel)
  interactionEvent?: string   // Événement d'interaction (optionnel)
}
```

### Type inféré

```typescript
type SubmitInteractionData = z.infer<typeof submitInteractionSchema>;
```

## createPasswordVerificationSchema

Ce schéma valide les données pour la création d'un enregistrement de vérification par mot de passe.

### Structure

```typescript
{
  password: string // Mot de passe (obligatoire, non vide)
}
```

### Type inféré

```typescript
type CreatePasswordVerificationData = z.infer<typeof createPasswordVerificationSchema>;
```

## createVerificationCodeSchema

Ce schéma valide les données pour la création et l'envoi d'un code de vérification.

### Structure

```typescript
{
  email?: string,   // Email (optionnel, doit être un email valide)
  phone?: string,   // Téléphone (optionnel)
  purpose: string   // But (obligatoire, non vide)
}
```

### Règles de validation

- Au moins une des propriétés suivantes doit être fournie :
  - `email`
  - `phone`
- La propriété `purpose` est obligatoire

### Type inféré

```typescript
type CreateVerificationCodeData = z.infer<typeof createVerificationCodeSchema>;
```

## verifyVerificationCodeSchema

Ce schéma valide les données pour la vérification d'un code.

### Structure

```typescript
{
  email?: string,   // Email (optionnel, doit être un email valide)
  phone?: string,   // Téléphone (optionnel)
  code: string,     // Code (obligatoire, non vide)
  purpose: string   // But (obligatoire, non vide)
}
```

### Règles de validation

- Au moins une des propriétés suivantes doit être fournie :
  - `email`
  - `phone`
- Les propriétés `code` et `purpose` sont obligatoires

### Type inféré

```typescript
type VerifyVerificationCodeData = z.infer<typeof verifyVerificationCodeSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { identifyUserSchema } from '../../validators/schemas/experienceSchemas';

// Dans une route Hono
router.post('/identify', validateZod({ body: identifyUserSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await experienceService.identifyUser(data);
    
    return c.json(result);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateIdentifyUser } from '../../validators/experienceValidation';

// Dans une fonction
try {
  const data = {
    email: 'user@example.com'
  };
  
  const validatedData = validateIdentifyUser(data);
  
  // Utilisation des données validées
  const result = await experienceService.identifyUser(validatedData);
  
  return { success: true, data: result };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Utiliser les types inférés pour typer les données validées
3. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
4. Pour les opérations d'identification, vérifier qu'au moins une méthode d'identification est fournie
5. Utiliser le logger structuré pour tracer les erreurs de validation 