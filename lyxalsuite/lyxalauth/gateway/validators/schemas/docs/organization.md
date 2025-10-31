# Documentation des schémas de validation pour les Organisations

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux organisations dans l'API Gateway.

## createOrganizationSchema

Ce schéma valide les données pour la création d'une organisation.

### Structure

```typescript
{
  name: string,         // Nom de l'organisation (obligatoire, non vide)
  description?: string  // Description de l'organisation (optionnel)
}
```

### Type inféré

```typescript
type CreateOrganizationData = z.infer<typeof createOrganizationSchema>;
```

## updateOrganizationSchema

Ce schéma valide les données pour la mise à jour d'une organisation.

### Structure

```typescript
{
  name?: string,        // Nom de l'organisation (optionnel, non vide si présent)
  description?: string  // Description de l'organisation (optionnel)
}
```

### Type inféré

```typescript
type UpdateOrganizationData = z.infer<typeof updateOrganizationSchema>;
```

## organizationUserMembersSchema

Ce schéma valide les données pour l'ajout/attribution de membres utilisateurs à une organisation.

### Structure

```typescript
{
  userIds: string[]     // Liste des IDs utilisateurs (obligatoire, non vide)
}
```

### Type inféré

```typescript
type OrganizationUserMembersData = z.infer<typeof organizationUserMembersSchema>;
```

## assignRolesToUserSchema

Ce schéma valide les données pour l'attribution de rôles à des utilisateurs dans une organisation.

### Structure

```typescript
{
  roleIds: string[]     // Liste des IDs de rôles (obligatoire, non vide)
}
```

### Type inféré

```typescript
type AssignRolesToUserData = z.infer<typeof assignRolesToUserSchema>;
```

## organizationApplicationsSchema

Ce schéma valide les données pour l'ajout/attribution d'applications à une organisation.

### Structure

```typescript
{
  applicationIds: string[]  // Liste des IDs d'applications (obligatoire, non vide)
}
```

### Type inféré

```typescript
type OrganizationApplicationsData = z.infer<typeof organizationApplicationsSchema>;
```

## assignRolesToApplicationSchema

Ce schéma valide les données pour l'attribution de rôles à des applications dans une organisation.

### Structure

```typescript
{
  roleIds: string[]     // Liste des IDs de rôles (obligatoire, non vide)
}
```

### Type inféré

```typescript
type AssignRolesToApplicationData = z.infer<typeof assignRolesToApplicationSchema>;
```

## jitEmailDomainsSchema

Ce schéma valide les données pour la gestion des domaines email JIT (Just-In-Time).

### Structure

```typescript
{
  domains: string[]     // Liste des domaines email (obligatoire, non vide, format email valide)
}
```

### Type inféré

```typescript
type JitEmailDomainsData = z.infer<typeof jitEmailDomainsSchema>;
```

## jitDefaultRolesSchema

Ce schéma valide les données pour la gestion des rôles par défaut JIT.

### Structure

```typescript
{
  roleIds: string[]     // Liste des IDs de rôles (obligatoire, non vide)
}
```

### Type inféré

```typescript
type JitDefaultRolesData = z.infer<typeof jitDefaultRolesSchema>;
```

## jitSsoConnectorsSchema

Ce schéma valide les données pour la gestion des connecteurs SSO JIT.

### Structure

```typescript
{
  connectorIds: string[]  // Liste des IDs de connecteurs (obligatoire, non vide)
}
```

### Type inféré

```typescript
type JitSsoConnectorsData = z.infer<typeof jitSsoConnectorsSchema>;
```

## paginationSchema

Ce schéma valide les données pour la pagination.

### Structure

```typescript
{
  page?: number,        // Numéro de page (optionnel, entier positif, défaut: 1)
  pageSize?: number     // Taille de la page (optionnel, entier positif, défaut: 20)
}
```

### Type inféré

```typescript
type PaginationData = z.infer<typeof paginationSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { createOrganizationSchema } from '../../validators/schemas/organizationSchemas';

// Dans une route Hono
router.post('/', validateZod({ body: createOrganizationSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await organizationService.createOrganization(data);
    
    return c.json(result, 201);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation directe des schémas

```typescript
import { paginationSchema } from '../../validators/schemas/organizationSchemas';

// Dans une fonction
try {
  const queryParams = {
    page: 2,
    pageSize: 10
  };
  
  // Validation avec le schéma et application des valeurs par défaut
  const pagination = paginationSchema.parse(queryParams);
  
  // Utilisation des données validées
  const result = await organizationService.getOrganizations(pagination.page, pagination.pageSize);
  
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
4. Pour les propriétés optionnelles qui doivent avoir des valeurs par défaut, utiliser le `.transform()`
5. Utiliser le logger structuré pour tracer les erreurs de validation 