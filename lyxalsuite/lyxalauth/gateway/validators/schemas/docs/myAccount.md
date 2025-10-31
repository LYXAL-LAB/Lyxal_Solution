# Documentation des schémas de validation pour My Account

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion du compte utilisateur dans l'API Gateway.

## updateProfileSchema

Ce schéma valide les données pour la mise à jour du profil utilisateur.

### Structure

```typescript
{
  name?: string,           // Nom de l'utilisateur (optionnel)
  avatar?: string,         // URL de l'avatar (optionnel, doit être une URL valide)
  customData?: Record<string, unknown> // Données personnalisées (optionnel)
}
```

### Type inféré

```typescript
type UpdateProfileData = z.infer<typeof updateProfileSchema>;
```

## updateOtherProfileSchema

Ce schéma étend `updateProfileSchema` et valide les données pour la mise à jour d'un autre profil utilisateur.

### Structure

```typescript
{
  name?: string,           // Nom de l'utilisateur (optionnel)
  avatar?: string,         // URL de l'avatar (optionnel, doit être une URL valide)
  customData?: Record<string, unknown>, // Données personnalisées (optionnel)
  userId: string           // ID de l'utilisateur à mettre à jour (obligatoire, non vide)
}
```

### Type inféré

```typescript
type UpdateOtherProfileData = z.infer<typeof updateOtherProfileSchema>;
```

## updatePasswordSchema

Ce schéma valide les données pour la mise à jour du mot de passe.

### Structure

```typescript
{
  oldPassword: string,     // Ancien mot de passe (obligatoire, non vide)
  newPassword: string      // Nouveau mot de passe (obligatoire, minimum 8 caractères)
}
```

### Type inféré

```typescript
type UpdatePasswordData = z.infer<typeof updatePasswordSchema>;
```

## updatePrimaryEmailSchema

Ce schéma valide les données pour la mise à jour de l'email primaire.

### Structure

```typescript
{
  email: string,           // Email (obligatoire, format d'email valide)
  verificationCode: string // Code de vérification (obligatoire, non vide)
}
```

### Type inféré

```typescript
type UpdatePrimaryEmailData = z.infer<typeof updatePrimaryEmailSchema>;
```

## updatePrimaryPhoneSchema

Ce schéma valide les données pour la mise à jour du téléphone primaire.

### Structure

```typescript
{
  phone: string,           // Numéro de téléphone (obligatoire, non vide)
  verificationCode: string // Code de vérification (obligatoire, non vide)
}
```

### Type inféré

```typescript
type UpdatePrimaryPhoneData = z.infer<typeof updatePrimaryPhoneSchema>;
```

## addUserIdentitySchema

Ce schéma valide les données pour l'ajout d'une identité utilisateur.

### Structure

```typescript
{
  target: string,          // Cible (obligatoire, non vide)
  connectorId: string      // ID du connecteur (obligatoire, non vide)
}
```

### Type inféré

```typescript
type AddUserIdentityData = z.infer<typeof addUserIdentitySchema>;
```

## deleteUserIdentitySchema

Ce schéma valide les données pour la suppression d'une identité utilisateur.

### Structure

```typescript
{
  target: string,          // Cible (obligatoire, non vide)
  connectorId: string      // ID du connecteur (obligatoire, non vide)
}
```

### Type inféré

```typescript
type DeleteUserIdentityData = z.infer<typeof deleteUserIdentitySchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { updateProfileSchema } from '../../validators/schemas/myAccountSchemas';

// Dans une route Hono
router.patch('/', validateZod({ body: updateProfileSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await myAccountService.updateProfile(data);
    
    return c.json({ data: result, success: true });
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation directe des schémas

```typescript
import { deleteUserIdentitySchema } from '../../validators/schemas/myAccountSchemas';

// Dans une fonction ou route
try {
  const data = { 
    target: 'example@mail.com',
    connectorId: 'google'
  };
  
  // Valider les données avec le schéma
  const validatedData = deleteUserIdentitySchema.parse(data);
  
  // Utilisation des données validées
  const result = await myAccountService.deleteUserIdentity(validatedData);
  
  return { success: true };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Utiliser les types inférés pour typer les données validées
3. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
4. Valider les données avant de les traiter pour éviter les erreurs en aval
5. Utiliser le logger structuré pour tracer les erreurs de validation 