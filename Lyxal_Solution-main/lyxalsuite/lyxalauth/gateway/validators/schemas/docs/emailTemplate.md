# Documentation des schémas de validation pour Modèles d'Emails

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion des modèles d'emails dans l'API Gateway.

## updateEmailTemplateSchema

Ce schéma valide les données pour la mise à jour partielle d'un modèle d'email existant.

### Structure

```typescript
{
  subject?: string,       // Le sujet de l'email
  htmlContent?: string,   // Le contenu HTML de l'email
  textContent?: string,   // Le contenu texte de l'email
  language?: string       // La langue du modèle d'email
}
```

### Règles de validation

- Au moins un des champs doit être fourni
- Si `subject` est fourni, il doit être une chaîne non vide
- Si `htmlContent` est fourni, il doit être une chaîne non vide
- Si `textContent` est fourni, il doit être une chaîne non vide
- Si `language` est fourni, il doit être une chaîne non vide

### Type inféré

```typescript
type UpdateEmailTemplateData = z.infer<typeof updateEmailTemplateSchema>;
```

## emailTemplateSchema

Ce schéma valide les données pour un modèle d'email complet.

### Structure

```typescript
{
  id: string,          // L'identifiant unique du modèle
  type: string,        // Le type du modèle d'email
  subject: string,     // Le sujet de l'email
  htmlContent: string, // Le contenu HTML de l'email
  textContent?: string, // Le contenu texte de l'email (optionnel)
  language: string     // La langue du modèle d'email
}
```

### Règles de validation

- `id` est obligatoire et doit être une chaîne non vide
- `type` est obligatoire et doit être une chaîne non vide
- `subject` est obligatoire et doit être une chaîne non vide
- `htmlContent` est obligatoire et doit être une chaîne non vide
- `textContent` est optionnel, mais s'il est fourni, il doit être une chaîne non vide
- `language` est obligatoire et doit être une chaîne non vide

### Type inféré

```typescript
type EmailTemplateData = z.infer<typeof emailTemplateSchema>;
```

## replaceEmailTemplatesSchema

Ce schéma valide les données pour le remplacement de tous les modèles d'emails.

### Structure

```typescript
[
  {
    id: string,          // L'identifiant unique du modèle
    type: string,        // Le type du modèle d'email
    subject: string,     // Le sujet de l'email
    htmlContent: string, // Le contenu HTML de l'email
    textContent?: string, // Le contenu texte de l'email (optionnel)
    language: string     // La langue du modèle d'email
  },
  // ...autres modèles
]
```

### Règles de validation

- Doit être un tableau (même vide)
- Chaque élément du tableau doit respecter les règles du `emailTemplateSchema`

### Type inféré

```typescript
type ReplaceEmailTemplatesData = z.infer<typeof replaceEmailTemplatesSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { updateEmailTemplateSchema } from '../../validators/schemas/emailTemplateSchemas';

// Dans une route Hono
router.patch('/:id', validateZod({ body: updateEmailTemplateSchema }), async (c) => {
  try {
    const id = c.req.param('id');
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await emailTemplateService.updateEmailTemplateDetails(id, data);
    
    return c.json({ data: result, success: true });
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateUpdateEmailTemplate } from '../../validators/emailTemplateValidation';

// Dans une fonction
try {
  const data = {
    subject: 'Nouveau sujet',
    htmlContent: '<p>Nouveau contenu</p>'
  };
  
  const validatedData = validateUpdateEmailTemplate(data);
  
  // Utilisation des données validées
  const result = await emailTemplateService.updateEmailTemplateDetails(id, validatedData);
  
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
4. Pour les opérations de mise à jour partielle, vérifier qu'au moins un champ est fourni
5. Utiliser le logger structuré pour tracer les erreurs de validation 