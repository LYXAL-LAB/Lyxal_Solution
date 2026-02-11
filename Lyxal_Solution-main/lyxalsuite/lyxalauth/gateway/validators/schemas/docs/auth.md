# Documentation des schémas de validation pour l'authentification

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à l'authentification dans l'API Gateway.

## loginSchema

Ce schéma valide les données de connexion d'un utilisateur.

### Structure

```typescript
{
  username?: string,
  email?: string, // Format email valide
  phone?: string,
  password: string // Non vide
}
```

### Règles de validation

- Au moins l'un des champs d'identification (`username`, `email` ou `phone`) doit être fourni
- Si `email` est fourni, il doit avoir un format valide
- `password` est obligatoire et ne peut pas être vide

### Type inféré

```typescript
type Login = z.infer<typeof loginSchema>;
```

## verifyTokenSchema

Ce schéma valide les données pour la vérification d'un token.

### Structure

```typescript
{
  token: string // Non vide
}
```

### Règles de validation

- `token` est obligatoire et ne peut pas être vide

### Type inféré

```typescript
type VerifyToken = z.infer<typeof verifyTokenSchema>;
```

## refreshTokenSchema

Ce schéma valide les données pour le rafraîchissement d'un token.

### Structure

```typescript
{
  refreshToken: string // Non vide
}
```

### Règles de validation

- `refreshToken` est obligatoire et ne peut pas être vide

### Type inféré

```typescript
type RefreshToken = z.infer<typeof refreshTokenSchema>;
```

## registerSchema

Ce schéma valide les données d'inscription d'un nouvel utilisateur.

### Structure

```typescript
{
  username: string, // Min 3 caractères
  email: string, // Format email valide
  password: string, // Règles complexes
  name?: string,
  phone?: string,
  customData?: Record<string, unknown>
}
```

### Règles de validation

- `username` doit contenir au moins 3 caractères
- `email` doit avoir un format valide
- `password` doit :
  - Contenir au moins 8 caractères
  - Contenir au moins une majuscule
  - Contenir au moins une minuscule
  - Contenir au moins un chiffre
  - Contenir au moins un caractère spécial

### Type inféré

```typescript
type Register = z.infer<typeof registerSchema>;
```

## resetPasswordRequestSchema

Ce schéma valide les données pour une demande de réinitialisation de mot de passe.

### Structure

```typescript
{
  email: string // Format email valide
}
```

### Règles de validation

- `email` est obligatoire et doit avoir un format valide

### Type inféré

```typescript
type ResetPasswordRequest = z.infer<typeof resetPasswordRequestSchema>;
```

## resetPasswordConfirmSchema

Ce schéma valide les données pour confirmer une réinitialisation de mot de passe.

### Structure

```typescript
{
  token: string, // Non vide
  password: string // Règles complexes
}
```

### Règles de validation

- `token` est obligatoire et ne peut pas être vide
- `password` doit suivre les mêmes règles que pour l'inscription

### Type inféré

```typescript
type ResetPasswordConfirm = z.infer<typeof resetPasswordConfirmSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { loginSchema } from '../../validators/schemas/authSchemas';

// Dans une route Hono
router.post('/login', validateZod({ body: loginSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const validatedData = c.get('validatedBody');
    
    // Utilisation des données validées
    const authResponse = await authService.login(validatedData);
    
    return c.json(authResponse, 200);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateLogin } from '../../validators/authValidation';

// Dans une fonction
try {
  const body = await request.json();
  const validatedData = validateLogin(body);
  
  // Utilisation des données validées
  const authResponse = await authService.login(validatedData);
  
  return { success: true, data: authResponse };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Utiliser les types inférés (par exemple `Login`, `Register`, etc.) pour typer les données validées
3. Vérifier les cas limites et gérer correctement les erreurs de validation
4. Retourner des messages d'erreur clairs aux utilisateurs
5. Utiliser le logger structuré pour tracer les erreurs de validation 