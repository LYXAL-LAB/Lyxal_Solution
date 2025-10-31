# Documentation des schémas de validation pour CAPTCHA

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion des CAPTCHA dans l'API Gateway.

## captchaConfigSchema

Ce schéma valide la configuration d'un fournisseur de CAPTCHA.

### Structure

```typescript
{
  siteKey: string, // Clé du site, non vide
  secretKey: string // Clé secrète, non vide
}
```

### Règles de validation

- `siteKey` est obligatoire et ne peut pas être vide
- `secretKey` est obligatoire et ne peut pas être vide

### Type inféré

```typescript
type CaptchaConfig = z.infer<typeof captchaConfigSchema>;
```

## updateCaptchaProviderSchema

Ce schéma valide les données pour la mise à jour ou la configuration d'un fournisseur de CAPTCHA.

### Structure

```typescript
{
  provider: string, // Nom du fournisseur, non vide
  config: {
    siteKey: string, // Clé du site, non vide
    secretKey: string // Clé secrète, non vide
  }
}
```

### Règles de validation

- `provider` est obligatoire et ne peut pas être vide
- `config` est un objet qui doit respecter les règles du schéma `captchaConfigSchema`

### Type inféré

```typescript
type UpdateCaptchaProvider = z.infer<typeof updateCaptchaProviderSchema>;
```

## verifyCaptchaSchema

Ce schéma valide les données nécessaires pour vérifier une réponse CAPTCHA.

### Structure

```typescript
{
  response: string, // Jeton de réponse CAPTCHA, non vide
  remoteIp?: string // Adresse IP du client, optionnelle
}
```

### Règles de validation

- `response` est obligatoire et ne peut pas être vide
- `remoteIp` est optionnel

### Type inféré

```typescript
type VerifyCaptcha = z.infer<typeof verifyCaptchaSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { updateCaptchaProviderSchema } from '../../validators/schemas/captchaSchemas';

// Dans une route Hono
router.put('/', validateZod({ body: updateCaptchaProviderSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await captchaService.updateCaptchaProvider(data);
    
    return c.json(result, 200);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateUpdateCaptchaProvider } from '../../validators/captchaValidation';

// Dans une fonction
try {
  const data = {
    provider: 'recaptcha',
    config: {
      siteKey: 'your-site-key',
      secretKey: 'your-secret-key'
    }
  };
  
  const validatedData = validateUpdateCaptchaProvider(data);
  
  // Utilisation des données validées
  const result = await captchaService.updateCaptchaProvider(validatedData);
  
  return { success: true, data: result };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Validation d'une réponse CAPTCHA

```typescript
import { validateVerifyCaptcha } from '../../validators/captchaValidation';

// Dans une fonction
try {
  const data = {
    response: 'captcha-response-token',
    remoteIp: '192.168.1.1'
  };
  
  const validatedData = validateVerifyCaptcha(data);
  
  // Vérification du CAPTCHA
  const result = await captchaService.verifyCaptcha(validatedData.response, validatedData.remoteIp);
  
  return { success: result.success };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Utiliser les types inférés pour typer les données validées
3. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
4. Utiliser le logger structuré pour tracer les erreurs de validation 