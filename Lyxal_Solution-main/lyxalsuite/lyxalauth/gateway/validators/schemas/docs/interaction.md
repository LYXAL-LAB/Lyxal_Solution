# Documentation des schémas de validation pour les Interactions

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux interactions dans l'API Gateway.

## updateIdentifiersSchema

Ce schéma valide les données pour la mise à jour des identifiants d'un utilisateur dans une interaction.

### Structure

```typescript
{
  username?: string,       // Nom d'utilisateur (optionnel)
  email?: string,          // Email (optionnel, doit être un format d'email valide)
  phone?: string,          // Téléphone (optionnel)
  connectorId?: string,    // ID du connecteur social (optionnel)
  code?: string            // Code du connecteur social (optionnel)
}
```

### Règles de validation

- Au moins une des propriétés suivantes doit être fournie :
  - `username`
  - `email`
  - `phone`
  - OU la combinaison de `connectorId` et `code`

### Type inféré

```typescript
type UpdateIdentifiersData = z.infer<typeof updateIdentifiersSchema>;
```

## updateProfileSchema

Ce schéma valide les données pour la mise à jour du profil utilisateur.

### Structure

```typescript
{
  username?: string,       // Nom d'utilisateur (optionnel)
  primaryEmail?: string,   // Email principal (optionnel, doit être un format d'email valide)
  primaryPhone?: string,   // Téléphone principal (optionnel)
  name?: string,           // Nom complet (optionnel)
  avatar?: string,         // URL de l'avatar (optionnel, doit être une URL valide)
  customData?: Record<string, unknown> // Données personnalisées (optionnel)
}
```

### Type inféré

```typescript
type UpdateProfileData = z.infer<typeof updateProfileSchema>;
```

## patchProfileSchema

Ce schéma est identique à `updateProfileSchema` et valide les données pour la mise à jour partielle du profil.

### Type inféré

```typescript
type PatchProfileData = z.infer<typeof patchProfileSchema>;
```

## consentSchema

Ce schéma valide les données pour le consentement utilisateur.

### Structure

```typescript
{
  consent: boolean // Décision de consentement (obligatoire)
}
```

### Type inféré

```typescript
type ConsentData = z.infer<typeof consentSchema>;
```

## socialAuthorizationUriSchema

Ce schéma valide les données pour générer une URL d'autorisation sociale.

### Structure

```typescript
{
  connectorId: string,    // ID du connecteur social (obligatoire, non vide)
  state?: string,         // État de la requête (optionnel)
  redirectUri: string     // URI de redirection (obligatoire, doit être une URL valide)
}
```

### Type inféré

```typescript
type SocialAuthorizationUriData = z.infer<typeof socialAuthorizationUriSchema>;
```

## updateMfaSchema

Ce schéma valide les données pour la mise à jour de la configuration MFA.

### Structure

```typescript
{
  enabled: boolean // Activation/désactivation MFA (obligatoire)
}
```

### Type inféré

```typescript
type UpdateMfaData = z.infer<typeof updateMfaSchema>;
```

## singleSignOnAuthorizationUrlSchema

Ce schéma valide les données pour générer une URL d'autorisation SSO.

### Structure

```typescript
{
  redirectUri: string // URI de redirection (obligatoire, doit être une URL valide)
}
```

### Type inféré

```typescript
type SingleSignOnAuthorizationUrlData = z.infer<typeof singleSignOnAuthorizationUrlSchema>;
```

## singleSignOnAuthenticationSchema

Ce schéma valide les données pour l'authentification SSO.

### Structure

```typescript
{
  data: Record<string, unknown> // Données d'authentification (obligatoire)
}
```

### Type inféré

```typescript
type SingleSignOnAuthenticationData = z.infer<typeof singleSignOnAuthenticationSchema>;
```

## singleSignOnRegistrationSchema

Ce schéma valide les données pour l'enregistrement SSO.

### Structure

```typescript
{
  data: Record<string, unknown> // Données d'enregistrement (obligatoire)
}
```

### Type inféré

```typescript
type SingleSignOnRegistrationData = z.infer<typeof singleSignOnRegistrationSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { updateProfileSchema } from '../../validators/schemas/interactionSchemas';

// Dans une route Hono
router.put('/profile', validateZod({ body: updateProfileSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await interactionService.updateProfile(data);
    
    return c.json({ data: result, success: true });
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateUpdateIdentifiers } from '../../validators/interactionValidation';

// Dans une fonction
try {
  const data = {
    email: 'user@example.com'
  };
  
  const validatedData = validateUpdateIdentifiers(data);
  
  // Utilisation des données validées
  const result = await interactionService.updateIdentifiers(validatedData);
  
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